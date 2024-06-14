
import Foundation
import SwiftUI

func backgroundColor(for difficulty: String) -> Color {
switch difficulty.lowercased() {
case "easy":
    return Color.green.opacity(0.2)
case "medium":
    return Color.yellow.opacity(0.2)
case "hard":
    return Color.red.opacity(0.2)
default:
    return Color.gray.opacity(0.2)
}
}
