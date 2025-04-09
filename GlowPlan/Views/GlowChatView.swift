import SwiftUI

struct GlowChatView: View {
    @State private var message = ""
    @State private var messages: [ChatMessage] = [
        ChatMessage(text: "Hi! I'm your GlowPlan AI assistant. How can I help you with your skincare routine today?", isUser: false)
    ]
    
    var body: some View {
        ZStack {
            Color.glowPink
                .ignoresSafeArea()
            
            VStack {
                ScrollView {
                    LazyVStack(spacing: 20) {
                        ForEach(messages) { message in
                            chatBubble(message: message)
                        }
                    }
                    .padding()
                }
                
                HStack {
                    TextField("Type your message...", text: $message)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                    
                    Button(action: {
                        sendMessage()
                    }) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.title)
                            .foregroundColor(.glowCoral)
                    }
                    .padding(.trailing)
                }
                .padding(.vertical)
                .background(Color.white)
            }
        }
        .navigationTitle("Glow Chat")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func chatBubble(message: ChatMessage) -> some View {
        HStack {
            if message.isUser {
                Spacer()
            }
            
            Text(message.text)
                .padding()
                .background(message.isUser ? Color.glowCoral : Color.white)
                .foregroundColor(message.isUser ? .white : .black)
                .cornerRadius(15)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            
            if !message.isUser {
                Spacer()
            }
        }
    }
    
    private func sendMessage() {
        guard !message.isEmpty else { return }
        
        // Add user message
        messages.append(ChatMessage(text: message, isUser: true))
        
        // Clear input
        message = ""
        
        // Simulate AI response (replace with actual API call later)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            messages.append(ChatMessage(text: "I'm here to help! What specific skincare concerns would you like to discuss?", isUser: false))
        }
    }
}

struct ChatMessage: Identifiable {
    let id = UUID()
    let text: String
    let isUser: Bool
} 