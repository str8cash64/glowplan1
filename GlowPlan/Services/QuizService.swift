import SwiftUI
import FirebaseFirestore
import FirebaseAuth

class QuizService: ObservableObject {
    private let db = Firestore.firestore()
    private let userDefaults = UserDefaults.standard
    
    // Keys for UserDefaults
    private let quizResultKey = "savedQuizResult"
    private let shouldSaveToFirestoreKey = "shouldSaveQuizToFirestore"
    
    init() {
        print("QuizService initialized")
    }
    
    func saveQuizLocally(_ result: QuizResult, shouldSaveToFirestore: Bool = false) {
        print("Saving quiz locally:", result)
        if let encoded = try? JSONEncoder().encode(result) {
            userDefaults.set(encoded, forKey: quizResultKey)
            userDefaults.set(shouldSaveToFirestore, forKey: shouldSaveToFirestoreKey)
            print("Quiz saved locally successfully")
        }
    }
    
    func getLocalQuizResult() -> QuizResult? {
        guard let data = userDefaults.data(forKey: quizResultKey),
              let result = try? JSONDecoder().decode(QuizResult.self, from: data) else {
            print("No local quiz result found")
            return nil
        }
        print("Retrieved local quiz result:", result)
        return result
    }
    
    func shouldSaveToFirestore() -> Bool {
        let should = userDefaults.bool(forKey: shouldSaveToFirestoreKey)
        print("Should save to Firestore:", should)
        return should
    }
    
    func saveQuizToFirestore() async throws {
        print("Attempting to save quiz to Firestore")
        
        guard let userId = Auth.auth().currentUser?.uid else {
            print("No authenticated user found")
            throw NSError(domain: "QuizService", code: 1, userInfo: [NSLocalizedDescriptionKey: "No authenticated user"])
        }
        
        guard let quizResult = getLocalQuizResult() else {
            print("No quiz result found locally")
            throw NSError(domain: "QuizService", code: 2, userInfo: [NSLocalizedDescriptionKey: "No quiz result found"])
        }
        
        guard shouldSaveToFirestore() else {
            print("Quiz not marked for Firestore saving")
            return
        }
        
        let firestoreData = quizResult.toFirestoreData()
        print("Saving to Firestore - User ID:", userId)
        print("Data to save:", firestoreData)
        
        try await db.collection("users").document(userId).setData(firestoreData, merge: true)
        print("Quiz data successfully saved to Firestore")
        
        // Clear the local flag after successful save
        userDefaults.set(false, forKey: shouldSaveToFirestoreKey)
    }
    
    func clearLocalQuizData() {
        print("Clearing local quiz data")
        userDefaults.removeObject(forKey: quizResultKey)
        userDefaults.removeObject(forKey: shouldSaveToFirestoreKey)
    }
} 