import SwiftUI

struct PrimaryButtonStyle: ButtonStyle {
    let isInverted: Bool
    
    init(isInverted: Bool = false) {
        self.isInverted = isInverted
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(isInverted ? GlowTheme.Colors.coral : Color.white)
            .foregroundColor(isInverted ? Color.white : GlowTheme.Colors.coral)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
} 