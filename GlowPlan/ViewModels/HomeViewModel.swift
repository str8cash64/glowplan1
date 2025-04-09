import SwiftUI
import FirebaseAuth
import FirebaseFirestore

@MainActor
class HomeViewModel: ObservableObject {
    @Published var userName: String?
    @Published var isLoading = true
    
    private let db = Firestore.firestore()
    
    var welcomeMessage: String {
        if let name = userName {
            return "Welcome, \(name) ✨"
        }
        return "Welcome to GlowPlan ✨"
    }
    
    func fetchUserData() async {
        guard let userId = Auth.auth().currentUser?.uid else {
            isLoading = false
            return
        }
        
        do {
            let document = try await db.collection("users").document(userId).getDocument()
            if let data = document.data(), let name = data["Name"] as? String {
                userName = name
            }
        } catch {
            print("Error fetching user data: \(error.localizedDescription)")
        }
        
        isLoading = false
    }
} 