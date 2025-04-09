import SwiftUI
import FirebaseAuth

class AppState: ObservableObject {
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            isLoggedIn = false
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
} 