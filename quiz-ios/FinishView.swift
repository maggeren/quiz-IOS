

import SwiftUI
import Foundation
struct FinishView: View {
    var correctAnswers: Int
    var incorrectAnswers: Int
    var totalQuestions: Int
    var category: String
    var difficulty: String
    @EnvironmentObject var navigationManager: NavigationManager

    var body: some View {
        VStack {
            Spacer()
            Text("Quiz Completed!")
                .font(.largeTitle)
            Spacer()
            Text("Correct Answers: \(correctAnswers)").foregroundStyle(.green)
            Text("Incorrect Answers: \(incorrectAnswers)").foregroundStyle(.red)
            Text("Total Questions: \(totalQuestions)")
            Spacer()
            Button(action: {
                navigationManager.clearPath()
            }) {
                Text("Back to Categories")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            Spacer().frame(height: 80)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity) // Ensure the VStack takes up the full space
        .background(backgroundColor(for: difficulty))
        .navigationBarBackButtonHidden(true)
    }
}
