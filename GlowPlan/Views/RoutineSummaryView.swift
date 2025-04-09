import SwiftUI

struct RoutineSummaryView: View {
    let quizResult: QuizResult
    @State private var showAuth = false
    
    var body: some View {
        ZStack {
            Color.glowPink
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    Text("Your Personalized Routine")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.top)
                    
                    routineCard(title: "Morning Routine", steps: [
                        "Gentle Cleanser",
                        "Vitamin C Serum",
                        "Moisturizer",
                        "SPF"
                    ])
                    
                    routineCard(title: "Evening Routine", steps: [
                        "Oil Cleanser",
                        "Gentle Cleanser",
                        quizResult.sensitivity == "High" ? "Gentle Retinol" : "Retinol",
                        "Night Moisturizer"
                    ])
                    
                    Spacer()
                    
                    Button(action: {
                        showAuth = true
                    }) {
                        Text("Save My Glow Plan")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.glowCoral)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    .padding()
                }
                .padding()
            }
        }
        .navigationDestination(isPresented: $showAuth) {
            AuthView(quizResult: quizResult)
        }
    }
    
    private func routineCard(title: String, steps: [String]) -> some View {
        VStack(alignment: .leading, spacing: 15) {
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.black)
            
            ForEach(steps, id: \.self) { step in
                HStack {
                    Image(systemName: "circle.fill")
                        .font(.system(size: 8))
                        .foregroundColor(.glowCoral)
                    
                    Text(step)
                        .foregroundColor(.black)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 2)
    }
} 