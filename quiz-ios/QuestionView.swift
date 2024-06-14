import SwiftUI

struct QuestionView: View {
    var question: QuizQuestion
    var difficulty: String
    var answerQuestion: (Bool) -> Void
    
    var body: some View {
        VStack {
            Spacer()
            Text(question.decodedQuestion)
                .font(.title)
            Spacer()
            ForEach(question.allDecodedAnswers, id: \.self) { answer in
                Button(action: {
                    let isCorrect = answer == question.decodedCorrectAnswer
                    answerQuestion(isCorrect)
                }) {
                    Text(answer)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue.opacity(0.7))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
            }
            Spacer()
        }
        .padding()
        .background(backgroundColor(for: difficulty))
    }
    
}

struct QuestionView_Previews: PreviewProvider {
    static var previews: some View {
        // Mock quiz question
        let mockQuestion = QuizQuestion(
            question: "What is the capital of France?",
            correct_answer: "Paris",
            incorrect_answers: ["London", "Berlin", "Rome"]
        )

        return QuestionView(question: mockQuestion, difficulty: "medium") { isCorrect in
            print("Answer is \(isCorrect ? "correct" : "incorrect")")
        }
    }
}
