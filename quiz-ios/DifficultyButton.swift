import SwiftUI

struct DifficultyButton: View {
    var difficulty: String
    var count: Int
    var category: QuizCategory
    var action: () -> Void

    var body: some View {
        Button(action: {
            action()
        }) {
            HStack {
                Text("\(difficulty.capitalized): \(count)")
                    .padding(.vertical, 5)
                    .padding(.horizontal, 10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(backgroundColor(for: difficulty))
                    .cornerRadius(5)
                Spacer()
            }
        }
        .buttonStyle(PlainButtonStyle()) // Ensures the button does not inherit default button styles
    }
}
