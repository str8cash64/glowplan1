import SwiftUI

struct SplashScreen: View {
    @State private var isActive = false
    
    var body: some View {
        if isActive {
            WelcomeView()
        } else {
            ZStack {
                Color.glowPink
                    .ignoresSafeArea()
                
                VStack {
                    Image(systemName: "sparkles")
                        .font(.system(size: 80))
                        .foregroundColor(.glowCoral)
                    
                    Text("GlowPlan")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .padding(.top, 20)
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation {
                        self.isActive = true
                    }
                }
            }
        }
    }
} 