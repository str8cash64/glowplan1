import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct AuthView: View {
    let quizResult: QuizResult?
    let routine: Routine?
    @State private var email = ""
    @State private var password = ""
    @State private var isSignUp = true
    @State private var errorMessage: String?
    @State private var isLoading = false
    @State private var navigateToHome = false
    @EnvironmentObject private var appState: AppState
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.glowPink
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 25) {
                        Text(isSignUp ? "Create Account" : "Welcome Back")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        VStack(spacing: 15) {
                            TextField("Email", text: $email)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .textInputAutocapitalization(.never)
                                .keyboardType(.emailAddress)
                            
                            SecureField("Password", text: $password)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        .padding(.horizontal)
                        
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .glowCoral))
                                .scaleEffect(1.5)
                        } else {
                            Button(action: handleAuth) {
                                Text(isSignUp ? "Sign Up" : "Log In")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.glowCoral)
                                    .cornerRadius(12)
                            }
                            .padding(.horizontal)
                            
                            Button {
                                isSignUp.toggle()
                            } label: {
                                Text(isSignUp ? "Already have an account? Log in" : "New here? Create account")
                                    .foregroundColor(.glowCoral)
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationDestination(isPresented: $navigateToHome) {
                HomeView()
                    .navigationBarBackButtonHidden(true)
            }
            .alert("Error", isPresented: .constant(errorMessage != nil)) {
                Button("OK") {
                    errorMessage = nil
                }
            } message: {
                Text(errorMessage ?? "")
            }
        }
    }
    
    private func handleAuth() {
        isLoading = true
        
        if isSignUp {
            Auth.auth().createUser(withEmail: email, password: password) { result, error in
                handleAuthResult(result: result, error: error)
            }
        } else {
            Auth.auth().signIn(withEmail: email, password: password) { result, error in
                handleAuthResult(result: result, error: error)
            }
        }
    }
    
    private func handleAuthResult(result: AuthDataResult?, error: Error?) {
        if let error = error {
            errorMessage = error.localizedDescription
            isLoading = false
            return
        }
        
        guard let user = result?.user else {
            errorMessage = "Authentication successful but user data is missing"
            isLoading = false
            return
        }
        
        if isSignUp, let quizResult = quizResult {
            // Save quiz data to Firestore
            let userData: [String: Any] = [
                "Name": quizResult.name,
                "SkinType": quizResult.skinType,
                "SkinGoals": quizResult.skinGoals,
                "Sensitivity": quizResult.sensitivity,
                "Email": email,
                "createdAt": FieldValue.serverTimestamp()
            ]
            
            Firestore.firestore().collection("users").document(user.uid).setData(userData) { error in
                DispatchQueue.main.async {
                    isLoading = false
                    if let error = error {
                        errorMessage = "Failed to save user data: \(error.localizedDescription)"
                        return
                    }
                    
                    // Save routine if available
                    if let routine = routine {
                        Task {
                            do {
                                try await RoutineGenerator.shared.saveRoutineToFirestore(routine: routine)
                            } catch {
                                print("Error saving routine: \(error.localizedDescription)")
                            }
                        }
                    }
                    
                    appState.isLoggedIn = true
                    navigateToHome = true
                }
            }
        } else {
            DispatchQueue.main.async {
                isLoading = false
                appState.isLoggedIn = true
                navigateToHome = true
            }
        }
    }
} 