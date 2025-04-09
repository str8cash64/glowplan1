import Foundation
import FirebaseFirestore

struct QuizResult: Codable {
    let name: String
    let skinType: String
    let skinGoals: [String]
    let sensitivity: String
    
    init(name: String, skinType: String, skinGoals: [String], sensitivity: String) {
        self.name = name
        self.skinType = skinType
        self.skinGoals = skinGoals
        self.sensitivity = sensitivity
    }
    
    func toFirestoreData() -> [String: Any] {
        // Ensure skinGoals is properly formatted as an array
        let validatedGoals = Array(Set(skinGoals)) // Remove any duplicates
        print("DEBUG: Converting to Firestore - Goals:", validatedGoals)
        
        return [
            "Name": name,
            "SkinType": skinType,
            "SkinGoals": validatedGoals,
            "Sensitivity": sensitivity,
            "createdAt": FieldValue.serverTimestamp()
        ]
    }
    
    // Debug description
    var description: String {
        return """
        QuizResult:
        - Name: \(name)
        - Skin Type: \(skinType)
        - Goals (\(skinGoals.count)): \(skinGoals.joined(separator: ", "))
        - Sensitivity: \(sensitivity)
        """
    }
} 