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
        // Validate input parameters
        guard !name.isEmpty, !skinType.isEmpty, !skinGoals.isEmpty, !sensitivityLevel.isEmpty else {
            throw RoutineError.invalidResponse
        }
        
        // Validate API key first
        guard Secrets.validateAPIKey() else {
            throw RoutineError.invalidAPIKey
        }
        
        let prompt = """
        Generate a personalized skincare routine based on this profile:
        Name: \(name)
        Skin Type: \(skinType)
        Skin Goals: \(skinGoals.joined(separator: ", "))
        Sensitivity: \(sensitivityLevel)

        Return ONLY a JSON object in this exact format:
        {
            "morningRoutine": [
                {
                    "title": "Step title (e.g., 'Cleanse with Gentle Cleanser')",
                    "description": "1-2 line description of what to do",
                    "duration": "Estimated time (e.g., '1 min')",
                    "tip": "Optional helpful tip"
                }
            ],
            "eveningRoutine": [
                {
                    "title": "Step title",
                    "description": "Step description",
                    "duration": "Estimated time",
                    "tip": "Optional tip"
                }
            ]
        }
        
        Include 3-5 steps for each routine. Focus on providing a safe, effective routine suitable for the user's skin type and concerns.
        Each step should be specific and actionable.
        The response must be valid JSON and nothing else.
        Consider sensitivity level when recommending active ingredients.
        """
        
        let url = URL(string: "https://api.openai.com/v1/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(Secrets.openAIAPIKey)", forHTTPHeaderField: "Authorization")
        
        let requestBody: [String: Any] = [
            "model": "gpt-4-1106-preview",
            "messages": [
                ["role": "system", "content": "You are a skincare expert AI that generates personalized routines. Always return valid JSON in the exact format requested. Focus on safety and effectiveness."],
                ["role": "user", "content": prompt]
            ],
            "temperature": 0.2,
            "max_tokens": 1000,
            "response_format": ["type": "json_object"]
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch {
            throw RoutineError.decodingError("Failed to create request")
        }
        
        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch {
            throw RoutineError.networkError
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw RoutineError.networkError
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            if httpResponse.statusCode == 401 {
                throw RoutineError.invalidAPIKey
            }
            throw RoutineError.apiError
        }
        
        let openAIResponse: OpenAIResponse
        do {
            openAIResponse = try JSONDecoder().decode(OpenAIResponse.self, from: data)
        } catch {
            throw RoutineError.decodingError("Failed to decode API response")
        }
        
        guard let routineJSON = openAIResponse.choices.first?.message.content else {
            throw RoutineError.invalidResponse
        }
        
        do {
            let routineData = Data(routineJSON.utf8)
            let routine = try JSONDecoder().decode(Routine.self, from: routineData)
            
            // Validate routine has required steps
            guard !routine.morningRoutine.isEmpty && !routine.eveningRoutine.isEmpty else {
                throw RoutineError.decodingError("Generated routine is missing required steps")
            }
            
            // Validate each step has required fields
            for step in routine.morningRoutine + routine.eveningRoutine {
                guard !step.title.isEmpty && !step.description.isEmpty else {
                    throw RoutineError.decodingError("Generated routine steps are missing required fields")
                }
            }
            
            return routine
        } catch let decodingError {
            print("JSON Decoding Error: \(decodingError)")
            throw RoutineError.decodingError("Failed to create routine from API response")
        }
    }
    
    func saveRoutineToFirestore(routine: Routine) async throws {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw RoutineError.userNotFound
        }
        
        let routineData: [String: Any] = [
            "morningRoutine": routine.morningRoutine.map { step in
                [
                    "id": step.id,
                    "title": step.title,
                    "description": step.description,
                    "duration": step.duration as Any,
                    "tip": step.tip as Any
                ]
            },
            "eveningRoutine": routine.eveningRoutine.map { step in
                [
                    "id": step.id,
                    "title": step.title,
                    "description": step.description,
                    "duration": step.duration as Any,
                    "tip": step.tip as Any
                ]
            },
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
    case invalidAPIKey
    case networkError
    case decodingError(String)
    
    var localizedDescription: String {
        switch self {
        case .apiError:
            return "Failed to connect to the AI service. Please try again."
        case .invalidResponse:
            return "Unable to generate a routine. Please try again."
        case .userNotFound:
            return "User not found. Please log in again."
        case .invalidAPIKey:
            return "Configuration error: Invalid API key"
        case .networkError:
            return "Network error: Please check your connection and try again"
        case .decodingError(let message):
            return "Error creating your routine: \(message)"
        }
    }
} 