import SwiftUI

struct RoutinePreviewView: View {
    let quizResult: QuizResult
    let routine: Routine
    @State private var showAuthView = false
    @State private var showHome = false
    @State private var selectedRoutine: String = "morning"
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var appState: AppState
    
    var body: some View {
        ZStack {
            Color.glowPink
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 25) {
                    Text("Your Personalized Glow Plan ✨")
                        .font(.title)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .padding(.top)
                        .frame(maxWidth: .infinity)
                    
                    // Routine Type Picker
                    Picker("Routine", selection: $selectedRoutine) {
                        Text("Morning").tag("morning")
                        Text("Evening").tag("evening")
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    
                    // Routine Steps
                    VStack(spacing: 20) {
                        if selectedRoutine == "morning" {
                            routineStepsList(steps: routine.morningRoutine)
                        } else {
                            routineStepsList(steps: routine.eveningRoutine)
                        }
                    }
                    .padding(.horizontal)
                    .animation(.easeInOut, value: selectedRoutine)
                    
                    // Action Buttons
                    VStack(spacing: 15) {
                        Button {
                            showAuthView = true
                        } label: {
                            Text("Save My Glow Routine")
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
                            Text("Skip for Now")
                                .font(.headline)
                                .foregroundColor(.glowCoral)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                }
                .padding(.vertical)
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: $showAuthView) {
            AuthView(quizResult: quizResult, routine: routine)
                .environmentObject(appState)
        }
        .navigationDestination(isPresented: $showHome) {
            HomeView()
                .environmentObject(appState)
        }
    }
    
    private func routineStepsList(steps: [RoutineStep]) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            ForEach(steps) { step in
                routineStepCard(step: step)
            }
        }
    }
    
    private func routineStepCard(step: RoutineStep) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(step.title)
                    .font(.headline)
                    .foregroundColor(.black)
                    .fixedSize(horizontal: false, vertical: true)
                
                Spacer()
                
                if let duration = step.duration {
                    Text(duration)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
            
            Text(step.description)
                .font(.subheadline)
                .foregroundColor(.black.opacity(0.8))
                .fixedSize(horizontal: false, vertical: true)
            
            if let tip = step.tip {
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "lightbulb.fill")
                        .foregroundColor(.glowCoral)
                    Text(tip)
                        .font(.caption)
                        .foregroundColor(.black.opacity(0.7))
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.top, 4)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.05), radius: 5)
    }
} 