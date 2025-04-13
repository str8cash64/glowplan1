import SwiftUI

struct WelcomeView: View {
    @State private var showQuiz = false
    @EnvironmentObject private var appState: AppState
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.glowPink
                    .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    Text("Welcome to GlowPlan")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                        .padding(.top, 50)
                    
                    Spacer()
                    
                    Button(action: {
                        showQuiz = true
                    }) {
                        HStack {
                            Text("Start My Glow")
                            Image(systemName: "arrow.right")
                        }
                    }
                    .buttonStyle(GlowButtonStyle())
                    .padding(.bottom, 50)
                }
                .padding()
            }
            .navigationDestination(isPresented: $showQuiz) {
                QuizView()
                    .environmentObject(appState)
            }
        }
    }
} 