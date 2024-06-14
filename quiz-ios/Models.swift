import Foundation
import SwiftUI

struct QuizCategory: Codable, Identifiable, Hashable, Equatable {
    let id: Int
    let name: String
    var questionCount: QuestionCount?

    var displayName: String {
        return Self.displayName(from: name)
    }

    static func displayName(from name: String) -> String {
        let components = name.components(separatedBy: ":")
        if components.count > 1 {
            return components[1].trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return name
    }
}

struct QuestionCount: Codable, Hashable, Equatable {
    let total_question_count: Int
    let total_easy_question_count: Int
    let total_medium_question_count: Int
    let total_hard_question_count: Int
}

struct QuizQuestion: Codable, Identifiable {
    var id = UUID()
    let question: String
    let correct_answer: String
    let incorrect_answers: [String]

    enum CodingKeys: String, CodingKey {
        case question
        case correct_answer
        case incorrect_answers
    }

    var decodedQuestion: String {
        return question.decoded()
    }

    var decodedCorrectAnswer: String {
        return correct_answer.decoded()
    }

    var decodedIncorrectAnswers: [String] {
        return incorrect_answers.map { $0.decoded() }
    }

    var allDecodedAnswers: [String] {
        return (decodedIncorrectAnswers + [decodedCorrectAnswer]).shuffled()
    }
}

extension String {
    func decoded() -> String {
        let encodedData = Data(self.utf8)
        let attributedString = try? NSAttributedString(
            data: encodedData,
            options: [.documentType: NSAttributedString.DocumentType.html],
            documentAttributes: nil
        )
        return attributedString?.string ?? self
    }
}


//-----------------------VIEW DATA-----------------------------

struct QuizViewData: Hashable {
    var category: QuizCategory
    var difficulty: String
    var totalQuestions: Int
}

struct ResultViewData: Hashable {
    let correctAnswers: Int
    let incorrectAnswers: Int
    let totalQuestions: Int
    let category: String
    let difficulty: String
}


//-------------------------------API--------------------------------


struct QuestionCountResponse: Codable {
    let category_id: Int
    let category_question_count: QuestionCount
}

struct ResponseCode: Codable {
    let response_code: Int
}

struct CategoryResponse: Codable {
    var trivia_categories: [QuizCategory]
}

struct QuestionResponse: Codable {
    let response_code: Int
    let results: [QuizQuestion]
}

struct SessionTokenResponse: Codable {
    let token: String
}


//----------------------MANAGERS--------------------
class NavigationManager: ObservableObject {
    @Published var path = NavigationPath()
    func clearPath() {
            path.removeLast(path.count)
        }
}
