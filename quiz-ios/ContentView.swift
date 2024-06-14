import SwiftUI

struct ContentView: View {
    @State private var categories: [QuizCategory] = []
    @State private var isLoading = true
    @State private var expandedCategoryId: Int? = nil
    @EnvironmentObject var navigationManager: NavigationManager

    var body: some View {
        NavigationStack(path: $navigationManager.path) {
            VStack {
                if isLoading {
                    ProgressView("Loading categories...")
                } else {
                    List(categories) { category in
                        CategoryRowView(category: category, expandedCategoryId: $expandedCategoryId)
                    }
                }
            }
            .navigationTitle("Quiz Categories")
            .onAppear(perform: loadCategories)
            .navigationDestination(for: QuizViewData.self) { quizData in
                QuizView(category: quizData.category, difficulty: quizData.difficulty, totalQuestions: quizData.totalQuestions)
            }
            .navigationDestination(for: ResultViewData.self) { resultData in
                FinishView(
                    correctAnswers: resultData.correctAnswers,
                    incorrectAnswers: resultData.incorrectAnswers,
                    totalQuestions: resultData.totalQuestions,
                    category: resultData.category,
                    difficulty: resultData.difficulty
                )
            }
        }
        .onChange(of: navigationManager.path.count) { oldCount, newCount in
            if newCount == 0 {
                QuizAPI.shared.resetSessionToken{}
            }
        }
    }

    func loadCategories() {
        print("Loading categories...")
        QuizAPI.shared.fetchCategories { categories in
            DispatchQueue.main.async {
                self.isLoading = false
                if let categories = categories {
                    self.categories = categories
                    print("Categories loaded: \(categories)")
                } else {
                    print("Failed to load categories")
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(NavigationManager())
    }
}
