import Foundation

struct Routine: Codable {
    var morningRoutine: [String]
    var eveningRoutine: [String]
    var timestamp: Date
    
    enum CodingKeys: String, CodingKey {
        case morningRoutine
        case eveningRoutine
        case timestamp
    }
    
    init(morningRoutine: [String], eveningRoutine: [String]) {
        self.morningRoutine = morningRoutine
        self.eveningRoutine = eveningRoutine
        self.timestamp = Date()
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        morningRoutine = try container.decode([String].self, forKey: .morningRoutine)
        eveningRoutine = try container.decode([String].self, forKey: .eveningRoutine)
        timestamp = Date() // Set current date when decoding from JSON
    }
}

// OpenAI API Response structure
struct OpenAIResponse: Codable {
    struct Choice: Codable {
        var message: Message
        
        struct Message: Codable {
            var content: String
        }
    }
    
    var choices: [Choice]
} 