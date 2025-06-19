/*
OpenAI service for text completion.
*/

import SwiftUI
import OpenAI

class OpenAIService: ObservableObject {
    private let client: OpenAI
    
    init() {
        // Never hardcode API keys
        guard let apiKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] else {
            fatalError("Set OPENAI_API_KEY environment variable")
        }
        self.client = OpenAI(apiToken: apiKey)
    }
    
    func complete(text: String) async throws -> String {
        // Use chat completions, not responses endpoint
        let query = ChatQuery(
            messages: [
                .init(role: .system, content: "You are AI autocomplete text software. Help user complete their sentence in a natural way."),
                .init(role: .user, content: text)
            ],
            model: .gpt4o
        )
        
        let result = try await client.chats(query: query)
        return result.choices.first?.message.content?.string ?? ""
    }
} 