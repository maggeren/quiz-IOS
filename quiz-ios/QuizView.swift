import SwiftUI

struct QuizView: View {
    var category: QuizCategory
    var difficulty: String
    var totalQuestions: Int

    @State private var questions: [QuizQuestion] = []
    @State private var currentQuestionIndex = 0
    @State private var isLoading = true
    @State private var showResult = false
    @State private var lastAnswerCorrect = false
    @State private var correctAnswers = 0
    @State private var incorrectAnswers = 0
    @State private var questionsFetched = 0
    @EnvironmentObject var navigationManager: NavigationManager

    var body: some View {
        VStack {
            if isLoading {
                ProgressView("Loading questions...")
                    .onAppear {
                        fetchQuestions()
                    }
            } else if showResult {
                if currentQuestionIndex < questions.count {
                    ResultView(
                        isCorrect: lastAnswerCorrect,
                        correctAnswer: questions[currentQuestionIndex].decodedCorrectAnswer,
                        nextQuestionAction: loadNextQuestion,
                        difficulty: difficulty
                    )
                } else {
                    FinishView(
                        correctAnswers: correctAnswers,
                        incorrectAnswers: incorrectAnswers,
                        totalQuestions: totalQuestions,
                        category: category.name,
                        difficulty: difficulty
                    )
                    .environmentObject(navigationManager)
                }
            } else if currentQuestionIndex < questions.count {
                QuestionView(
                    question: questions[currentQuestionIndex],
                    difficulty: difficulty,
                    answerQuestion: { isCorrect in
                        lastAnswerCorrect = isCorrect
                        if isCorrect {
                            correctAnswers += 1
                        } else {
                            incorrectAnswers += 1
                        }
                        showResult = true
                    }
                )
            } else {
                // Display the result screen if no more questions are available
                FinishView(
                    correctAnswers: correctAnswers,
                    incorrectAnswers: incorrectAnswers,
                    totalQuestions: totalQuestions,
                    category: category.name,
                    difficulty: difficulty
                )
                .environmentObject(navigationManager)
            }
        }
        .navigationTitle(category.displayName)
    }

    func fetchQuestions() {
        let amount = min(10, totalQuestions - questionsFetched)
        if amount <= 0 {
            // No more questions to fetch, display the result screen
            isLoading = false
            return
        }
        QuizAPI.shared.fetchQuestions(category: category.id, difficulty: difficulty, amount: amount) { fetchedQuestions in
            DispatchQueue.main.async {
                if let fetchedQuestions = fetchedQuestions, !fetchedQuestions.isEmpty {
                    self.questions.append(contentsOf: fetchedQuestions)
                    self.questionsFetched += fetchedQuestions.count
                    self.isLoading = false
                    // Reset currentQuestionIndex to show the next set of questions correctly
                    if self.currentQuestionIndex >= self.questions.count {
                        self.currentQuestionIndex = self.questionsFetched - fetchedQuestions.count
                    }
                    self.showResult = false
                } else {
                    print("Failed to fetch questions or no questions available")
                    self.isLoading = false
                    // Trigger showing results if no questions fetched
                    if questions.isEmpty {
                        showResult = true
                    }
                }
            }
        }
    }

    func loadNextQuestion() {
        currentQuestionIndex += 1
        if currentQuestionIndex >= questions.count && questionsFetched < totalQuestions {
            isLoading = true
            fetchQuestions()
        } else if currentQuestionIndex < questions.count {
            showResult = false
        } else {
            // No more questions to load, show final result
            showResult = true
        }
    }
}
