import SwiftUI

struct QuizView: View {
    @State private var currentStep = 0
    @State private var name = ""
    @State private var skinType = ""
    @State private var skinGoals: [String] = []
    @State private var sensitivityLevel = ""
    @State private var showRoutinePreview = false
    @State private var isGeneratingRoutine = false
    @State private var errorMessage: String?
    @State private var showError = false
    @State private var routine: Routine?
    @EnvironmentObject private var appState: AppState
    
    let skinTypes = ["Dry", "Oily", "Combination", "Normal", "Sensitive"]
    let skinGoalOptions = ["Hydration", "Anti-Aging", "Acne Control", "Brightening", "Even Tone", "Pore Reduction"]
    let sensitivityLevels = ["Low", "Medium", "High"]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.glowPink
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // Progress bar with fixed frame
                    ProgressView(value: Double(currentStep), total: 4)
                        .tint(.glowCoral)
                        .padding(.horizontal)
                        .frame(height: 2)
                    
                    ScrollView {
                        VStack(spacing: 25) {
                            // Quiz steps
                            Group {
                                switch currentStep {
                                case 0:
                                    QuizStepView(title: "What's your name?") {
                                        VStack(spacing: 10) {
                                            TextField("Enter your name", text: $name)
                                                .padding()
                                                .background(Color.white)
                                                .cornerRadius(10)
                                                .foregroundColor(.black)
                                                .font(.body)
                                                .frame(maxWidth: .infinity)
                                        }
                                        .padding(.horizontal)
                                    }
                                    
                                case 1:
                                    QuizStepView(title: "What's your skin type?") {
                                        VStack(spacing: 10) {
                                            ForEach(skinTypes, id: \.self) { type in
                                                Button {
                                                    skinType = type
                                                } label: {
                                                    HStack {
                                                        Text(type)
                                                            .foregroundColor(skinType == type ? .white : .black)
                                                            .frame(maxWidth: .infinity, alignment: .leading)
                                                        if skinType == type {
                                                            Image(systemName: "checkmark")
                                                                .foregroundColor(.white)
                                                        }
                                                    }
                                                    .padding()
                                                    .frame(maxWidth: .infinity)
                                                    .background(skinType == type ? Color.glowCoral : Color.white)
                                                    .cornerRadius(10)
                                                }
                                            }
                                        }
                                        .padding(.horizontal)
                                    }
                                    
                                case 2:
                                    QuizStepView(title: "What are your skin goals?") {
                                        VStack(spacing: 10) {
                                            ForEach(skinGoalOptions, id: \.self) { goal in
                                                Button {
                                                    if skinGoals.contains(goal) {
                                                        skinGoals.removeAll { $0 == goal }
                                                    } else {
                                                        skinGoals.append(goal)
                                                    }
                                                } label: {
                                                    HStack {
                                                        Text(goal)
                                                            .foregroundColor(skinGoals.contains(goal) ? .white : .black)
                                                            .frame(maxWidth: .infinity, alignment: .leading)
                                                        if skinGoals.contains(goal) {
                                                            Image(systemName: "checkmark")
                                                                .foregroundColor(.white)
                                                        }
                                                    }
                                                    .padding()
                                                    .frame(maxWidth: .infinity)
                                                    .background(skinGoals.contains(goal) ? Color.glowCoral : Color.white)
                                                    .cornerRadius(10)
                                                }
                                            }
                                        }
                                        .padding(.horizontal)
                                    }
                                    
                                case 3:
                                    QuizStepView(title: "How sensitive is your skin?") {
                                        VStack(spacing: 10) {
                                            ForEach(sensitivityLevels, id: \.self) { level in
                                                Button {
                                                    sensitivityLevel = level
                                                } label: {
                                                    HStack {
                                                        Text(level)
                                                            .foregroundColor(sensitivityLevel == level ? .white : .black)
                                                            .frame(maxWidth: .infinity, alignment: .leading)
                                                        if sensitivityLevel == level {
                                                            Image(systemName: "checkmark")
                                                                .foregroundColor(.white)
                                                        }
                                                    }
                                                    .padding()
                                                    .frame(maxWidth: .infinity)
                                                    .background(sensitivityLevel == level ? Color.glowCoral : Color.white)
                                                    .cornerRadius(10)
                                                }
                                            }
                                        }
                                        .padding(.horizontal)
                                    }
                                default:
                                    EmptyView()
                                }
                            }
                            .animation(.easeInOut, value: currentStep)
                            
                            // Next/Finish button
                            Button {
                                if canProceed {
                                    if currentStep < 3 {
                                        withAnimation {
                                            currentStep += 1
                                        }
                                    } else {
                                        generateRoutine()
                                    }
                                }
                            } label: {
                                Text(currentStep == 3 ? "Finish" : "Next")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(canProceed ? Color.glowCoral : Color.gray.opacity(0.5))
                                    .cornerRadius(10)
                            }
                            .padding(.horizontal)
                            .disabled(!canProceed || isGeneratingRoutine)
                        }
                        .padding(.vertical)
                    }
                }
                
                // Loading overlay
                if isGeneratingRoutine {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .overlay(
                            VStack(spacing: 20) {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(1.5)
                                
                                Text("Creating your personalized routine...")
                                    .font(.headline)
                                    .foregroundColor(.white)
                            }
                        )
                }
            }
            .navigationDestination(isPresented: $showRoutinePreview) {
                if let routine = routine {
                    RoutinePreviewView(
                        quizResult: QuizResult(
                            name: name,
                            skinType: skinType,
                            skinGoals: skinGoals,
                            sensitivity: sensitivityLevel
                        ),
                        routine: routine
                    )
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK") {
                    errorMessage = nil
                }
            } message: {
                Text(errorMessage ?? "An unknown error occurred")
            }
        }
    }
    
    private var canProceed: Bool {
        switch currentStep {
        case 0:
            return !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case 1:
            return !skinType.isEmpty
        case 2:
            return !skinGoals.isEmpty
        case 3:
            return !sensitivityLevel.isEmpty
        default:
            return false
        }
    }
    
    private func generateRoutine() {
        isGeneratingRoutine = true
        errorMessage = nil
        showError = false
        
        Task {
            do {
                routine = try await RoutineGenerator.shared.generateRoutine(
                    name: name,
                    skinType: skinType,
                    skinGoals: skinGoals,
                    sensitivityLevel: sensitivityLevel
                )
                
                await MainActor.run {
                    isGeneratingRoutine = false
                    if routine != nil {
                        showRoutinePreview = true
                    } else {
                        errorMessage = "Failed to generate routine. Please try again."
                        showError = true
                    }
                }
            } catch let error as RoutineError {
                await MainActor.run {
                    isGeneratingRoutine = false
                    errorMessage = error.localizedDescription
                    showError = true
                }
            } catch {
                await MainActor.run {
                    isGeneratingRoutine = false
                    errorMessage = "An unexpected error occurred. Please try again."
                    showError = true
                }
            }
        }
    }
}

struct QuizStepView<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            content
        }
    }
} 