import SwiftUI
import FirebaseAuth
import FirebaseFirestore

@MainActor
class SaveRoutineViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var showHome = false
    @Published var errorMessage: String?
    
    private let db = Firestore.firestore()
    
    func generateRoutines(skinType: String, goals: [String], sensitivity: String) -> (morning: [String], evening: [String]) {
        // Generate placeholder routines based on skin type and goals
        let morningRoutine = [
            "Gentle Cleanser",
            "Vitamin C Serum",
            "Hydrating Moisturizer",
            "Broad Spectrum SPF 50"
        ]
        
        let eveningRoutine = [
            "Oil Cleanser",
            "Gentle Cleanser",
            sensitivity == "High" ? "Gentle Retinol Serum" : "Retinol Serum",
            "Night Moisturizer"
        ]
        
        return (morningRoutine, eveningRoutine)
    }
    
    func saveUserData(quizResult: QuizResult) async {
        guard let userId = Auth.auth().currentUser?.uid else {
            errorMessage = "No authenticated user found"
            return
        }
        
        isLoading = true
        
        let (morningRoutine, eveningRoutine) = generateRoutines(
            skinType: quizResult.skinType,
            goals: quizResult.skinGoals,
            sensitivity: quizResult.sensitivity
        )
        
        let userData: [String: Any] = [
            "Name": quizResult.name,
            "SkinType": quizResult.skinType,
            "SkinGoals": quizResult.skinGoals,
            "Sensitivity": quizResult.sensitivity,
            "MorningRoutine": morningRoutine,
            "EveningRoutine": eveningRoutine
        ]
        
        do {
            try await db.collection("users").document(userId).setData(userData)
            showHome = true
        } catch {
            errorMessage = "Failed to save data: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
} 