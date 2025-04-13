import Foundation
import FirebaseFirestore
import FirebaseAuth

class RoutineGenerator {
    static let shared = RoutineGenerator()
    private init() {}
    
    func generateRoutine(
        name: String,
        skinType: String,
        skinGoals: [String],
        sensitivityLevel: String
    ) async throws -> Routine {
        let prompt = """
        Generate a personalized skincare routine based on this profile:
        Name: \(name)
        Skin Type: \(skinType)
        Skin Goals: \(skinGoals.joined(separator: ", "))
        Sensitivity: \(sensitivityLevel)

        Return ONLY a JSON object in this exact format:
        {
            "morningRoutine": ["step 1", "step 2", "step 3"],
            "eveningRoutine": ["step 1", "step 2", "step 3"]
        }
        
        Include 3-5 steps for each routine. Focus on providing a safe, effective routine suitable for the user's skin type and concerns.
        The response must be valid JSON and nothing else.
        """
        
        let url = URL(string: "https://api.openai.com/v1/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(Secrets.openAIAPIKey)", forHTTPHeaderField: "Authorization")
        
        guard Secrets.validateAPIKey() else {
            throw NSError(domain: "RoutineGenerator", code: 401, userInfo: [NSLocalizedDescriptionKey: "Invalid or missing API key"])
        }
        
        let requestBody: [String: Any] = [
            "model": "gpt-4-1106-preview",
            "messages": [
                ["role": "system", "content": "You are a skincare expert AI that generates personalized routines. Always return valid JSON in the exact format requested."],
                ["role": "user", "content": prompt]
            ],
            "temperature": 0.7,
            "max_tokens": 500,
            "response_format": ["type": "json_object"]
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw RoutineError.apiError
        }
        
        let openAIResponse = try JSONDecoder().decode(OpenAIResponse.self, from: data)
        guard let routineJSON = openAIResponse.choices.first?.message.content else {
            throw RoutineError.invalidResponse
        }
        
        do {
            let routineData = Data(routineJSON.utf8)
            let routine = try JSONDecoder().decode(Routine.self, from: routineData)
            
            // Validate routine has required steps
            guard !routine.morningRoutine.isEmpty && !routine.eveningRoutine.isEmpty else {
                throw RoutineError.invalidResponse
            }
            
            return routine
        } catch {
            print("JSON Decoding Error: \(error)")
            throw RoutineError.invalidResponse
        }
    }
    
    func saveRoutineToFirestore(routine: Routine) async throws {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw RoutineError.userNotFound
        }
        
        let routineData: [String: Any] = [
            "morningRoutine": routine.morningRoutine,
            "eveningRoutine": routine.eveningRoutine,
            "timestamp": Timestamp(date: routine.timestamp),
            "isActive": true
        ]
        
        try await Firestore.firestore()
            .collection("users")
            .document(userId)
            .collection("routines")
            .addDocument(data: routineData)
    }
}

enum RoutineError: Error {
    case apiError
    case invalidResponse
    case userNotFound
    
    var localizedDescription: String {
        switch self {
        case .apiError:
            return "Failed to connect to the AI service. Please try again."
        case .invalidResponse:
            return "Unable to generate a routine. Please try again."
        case .userNotFound:
            return "User not found. Please log in again."
        }
    }
} 