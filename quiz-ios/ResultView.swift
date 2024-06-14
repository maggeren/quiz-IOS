
import SwiftUI
struct ResultView: View {
    var isCorrect: Bool
    var correctAnswer: String
    var nextQuestionAction: () -> Void
    var difficulty: String

    var body: some View {
        VStack {
            Spacer() // Spacer to push content down
            Text(isCorrect ? "Correct!" : "Wrong!")
                .font(.largeTitle)
                .foregroundColor(isCorrect ? .green : .red)
                .padding()
            Text("Correct Answer: \(correctAnswer)")
                .padding()
            Spacer() // Spacer to separate text and button
            Button(action: nextQuestionAction) {
                Text("Next Question")
                    .padding()
                    .background(isCorrect ? Color.green : Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            Spacer().frame(height: 80) // Add a spacer with specific height to create space below the button
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity) // Ensure the VStack takes up the full space
        .background(backgroundColor(for: difficulty))
        .edgesIgnoringSafeArea(.all) // Ensure the background extends to the edges of the screen
    }
}
