import SwiftUI

struct CategoryRowView: View {
    var category: QuizCategory
    @Binding var expandedCategoryId: Int?
    @EnvironmentObject var navigationManager: NavigationManager

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(category.displayName)
                    .font(.headline)
                Spacer()
                if expandedCategoryId == category.id {
                    Button(action: {
                        expandedCategoryId = nil
                    }) {
                        Image(systemName: "chevron.up")
                    }
                } else {
                    Button(action: {
                        expandedCategoryId = category.id
                    }) {
                        Image(systemName: "chevron.down")
                    }
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation {
                    expandedCategoryId = (expandedCategoryId == category.id) ? nil : category.id
                }
            }
            
            if expandedCategoryId == category.id {
                ForEach(["easy", "medium", "hard"], id: \.self) { difficulty in
                    if let questionCount = questionCount(for: difficulty) {
                        DifficultyButton(difficulty: difficulty, count: questionCount, category: category) {
                            let totalQuestions = self.totalQuestions(for: difficulty)
                            let quizData = QuizViewData(category: category, difficulty: difficulty, totalQuestions: totalQuestions)
                            navigationManager.path.append(quizData)
                        }
                    }
                }
            }
        }
        .padding()
    }

    private func questionCount(for difficulty: String) -> Int? {
        switch difficulty {
        case "easy":
            return category.questionCount?.total_easy_question_count
        case "medium":
            return category.questionCount?.total_medium_question_count
        case "hard":
            return category.questionCount?.total_hard_question_count
        default:
            return nil
        }
    }

    private func color(for difficulty: String) -> Color {
        switch difficulty {
        case "easy":
            return .green
        case "medium":
            return .orange
        case "hard":
            return .red
        default:
            return .blue
        }
    }

    private func totalQuestions(for difficulty: String) -> Int {
        switch difficulty {
        case "easy":
            return category.questionCount?.total_easy_question_count ?? 0
        case "medium":
            return category.questionCount?.total_medium_question_count ?? 0
        case "hard":
            return category.questionCount?.total_hard_question_count ?? 0
        default:
            return 0
        }
    }
}
