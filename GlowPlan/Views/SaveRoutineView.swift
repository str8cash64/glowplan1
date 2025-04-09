import SwiftUI
import FirebaseAuth

struct SaveRoutineView: View {
    let quizResult: QuizResult
    let routine: Routine
    @StateObject private var viewModel = SaveRoutineViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var showAuthView = false
    @State private var showHome = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.glowPink
                    .ignoresSafeArea()
                
                VStack(spacing: 25) {
                    Text("We built your personalized routine based on your answers! ✨")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    if viewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .glowCoral))
                            .scaleEffect(1.5)
                    } else {
                        VStack(spacing: 20) {
                            Button {
                                showAuthView = true
                            } label: {
                                Text("Save My Glow")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.glowCoral)
                                    .cornerRadius(12)
                            }
                            
                            Button {
                                showHome = true
                            } label: {
                                Text("Skip")
                                    .font(.headline)
                                    .foregroundColor(.glowCoral)
                            }
                        }
                        .padding(.horizontal, 30)
                    }
                }
            }
            .navigationDestination(isPresented: $showAuthView) {
                AuthView(quizResult: quizResult, routine: routine)
            }
            .navigationDestination(isPresented: $showHome) {
                HomeView()
            }
            .navigationBarBackButtonHidden(true)
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") {
                    viewModel.errorMessage = nil
                }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
    }
}