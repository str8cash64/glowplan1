import Foundation

struct RoutineStep: Codable, Identifiable {
    let id: String
    let title: String
    let description: String
    let duration: String?
    let tip: String?
    
    init(id: String = UUID().uuidString, title: String, description: String, duration: String? = nil, tip: String? = nil) {
        self.id = id
        self.title = title
        self.description = description
        self.duration = duration
        self.tip = tip
    }
}

struct Routine: Codable {
    var morningRoutine: [RoutineStep]
    var eveningRoutine: [RoutineStep]
    var timestamp: Date
    
    enum CodingKeys: String, CodingKey {
        case morningRoutine
        case eveningRoutine
        case timestamp
    }
    
    init(morningRoutine: [RoutineStep], eveningRoutine: [RoutineStep]) {
        self.morningRoutine = morningRoutine
        self.eveningRoutine = eveningRoutine
        self.timestamp = Date()
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        morningRoutine = try container.decode([RoutineStep].self, forKey: .morningRoutine)
        eveningRoutine = try container.decode([RoutineStep].self, forKey: .eveningRoutine)
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