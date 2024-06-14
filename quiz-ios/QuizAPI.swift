import Foundation

class QuizAPI {
    static let shared = QuizAPI()
    private var sessionToken: String?
    private var cachedCategories: [QuizCategory]?
    private let rateLimitDelay: TimeInterval = 5.0 // 5 seconds delay for API limit

    init() {
        fetchSessionToken { _ in }
    }

    func fetchCategories(completion: @escaping ([QuizCategory]?) -> Void) {
        if let categories = cachedCategories {
            completion(categories)
            return
        }

        guard let url = URL(string: "https://opentdb.com/api_category.php") else {
            completion(nil)
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }

            do {
                var categoryResponse = try JSONDecoder().decode(CategoryResponse.self, from: data)
                let dispatchGroup = DispatchGroup()

                for (index, category) in categoryResponse.trivia_categories.enumerated() {
                    dispatchGroup.enter()
                    self.fetchQuestionCount(for: category.id) { questionCount in
                        if let questionCount = questionCount {
                            categoryResponse.trivia_categories[index].questionCount = questionCount
                        }
                        dispatchGroup.leave()
                    }
                }

                dispatchGroup.notify(queue: .main) {
                    self.cachedCategories = categoryResponse.trivia_categories
                    completion(categoryResponse.trivia_categories)
                }
            } catch {
                completion(nil)
            }
        }.resume()
    }

    func fetchQuestionCount(for categoryId: Int, completion: @escaping (QuestionCount?) -> Void) {
        guard let url = URL(string: "https://opentdb.com/api_count.php?category=\(categoryId)") else {
            completion(nil)
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }

            do {
                let countResponse = try JSONDecoder().decode(QuestionCountResponse.self, from: data)
                completion(countResponse.category_question_count)
            } catch {
                completion(nil)
            }
        }.resume()
    }

    func fetchSessionToken(completion: @escaping (String?) -> Void) {
        guard let url = URL(string: "https://opentdb.com/api_token.php?command=request") else {
            completion(nil)
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }

            do {
                let tokenResponse = try JSONDecoder().decode(SessionTokenResponse.self, from: data)
                self.sessionToken = tokenResponse.token
                print("Session token fetched: \(tokenResponse.token)")
                completion(tokenResponse.token)
            } catch {
                print("Failed to fetch session token: \(error)")
                completion(nil)
            }
        }.resume()
    }

    func fetchQuestions(category: Int, difficulty: String, amount: Int, completion: @escaping ([QuizQuestion]?) -> Void) {
        fetchQuestionsWithRetry(category: category, difficulty: difficulty, amount: amount, retries: 1, completion: completion)
    }

    private func fetchQuestionsWithRetry(category: Int, difficulty: String, amount: Int, retries: Int, completion: @escaping ([QuizQuestion]?) -> Void) {
        guard let token = sessionToken else {
            print("No session token available, fetching new token")
            fetchSessionToken { token in
                guard token != nil else {
                    completion(nil)
                    return
                }
                self.fetchQuestionsWithRetry(category: category, difficulty: difficulty, amount: amount, retries: retries, completion: completion)
            }
            return
        }

        guard let url = URL(string: "https://opentdb.com/api.php?amount=\(amount)&category=\(category)&difficulty=\(difficulty)&token=\(token)") else {
            completion(nil)
            return
        }

        print("Fetching questions with URL: \(url.absoluteString)")

        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Failed to fetch questions: \(error?.localizedDescription ?? "Unknown error")")
                completion(nil)
                return
            }

            // Print the raw response data for debugging
            if let responseString = String(data: data, encoding: .utf8) {
                print("Raw response data: \(responseString)")

                // Decode only the response code first
                do {
                    let basicResponse = try JSONDecoder().decode(ResponseCode.self, from: data)
                    if basicResponse.response_code == 5 {
                        if retries > 0 {
                            print("Rate limit encountered, retrying in \(self.rateLimitDelay) seconds...")
                            DispatchQueue.global().asyncAfter(deadline: .now() + self.rateLimitDelay) {
                                self.fetchQuestionsWithRetry(category: category, difficulty: difficulty, amount: amount, retries: retries - 1, completion: completion)
                            }
                        } else {
                            print("Exceeded maximum retries due to rate limit")
                            completion(nil)
                        }
                    } else if basicResponse.response_code == 4 {
                        print("Session token exhausted, resetting token...")
                        self.resetSessionToken {
                            self.fetchQuestionsWithRetry(category: category, difficulty: difficulty, amount: amount, retries: retries, completion: completion)
                        }
                    } else if basicResponse.response_code == 0 {
                        // Now decode the full response if the response code is 0
                        let questionResponse = try JSONDecoder().decode(QuestionResponse.self, from: data)
                        completion(questionResponse.results)
                    } else {
                        print("Error response code: \(basicResponse.response_code)")
                        completion(nil)
                    }
                } catch {
                    print("Failed to decode question response: \(error)")
                    completion(nil)
                }
            } else {
                print("Failed to convert response data to string")
                completion(nil)
            }
        }.resume()
    }

    func resetSessionToken(completion: @escaping () -> Void) {
        guard let token = sessionToken, let url = URL(string: "https://opentdb.com/api_token.php?command=reset&token=\(token)") else {
            completion()
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            print("Session token reset")
            self.sessionToken = token // Ensure the session token is updated
            completion()
        }.resume()
    }
}
