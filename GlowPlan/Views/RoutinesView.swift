import SwiftUI

struct RoutinesView: View {
    var body: some View {
        ZStack {
            Color.glowPink
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 30) {
                    Text("My Routines")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .padding(.top)
                    
                    // Morning Routine
                    routineSection(title: "Morning Routine", time: "7:00 AM", steps: [
                        "Cleanse with gentle cleanser",
                        "Apply vitamin C serum",
                        "Moisturize with SPF 30",
                        "Apply eye cream"
                    ])
                    
                    // Evening Routine
                    routineSection(title: "Evening Routine", time: "9:00 PM", steps: [
                        "Double cleanse",
                        "Apply retinol serum",
                        "Use hydrating moisturizer",
                        "Apply night eye cream"
                    ])
                }
                .padding()
            }
        }
        .navigationTitle("Routines")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func routineSection(title: String, time: String, steps: [String]) -> some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text(title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                
                Spacer()
                
                Text(time)
                    .foregroundColor(.gray)
            }
            
            ForEach(steps, id: \.self) { step in
                HStack {
                    Image(systemName: "circle.fill")
                        .font(.system(size: 8))
                        .foregroundColor(.glowCoral)
                    Text(step)
                        .foregroundColor(.black)
                }
            }
            
            Button(action: {
                // Edit routine
            }) {
                Text("Edit Routine")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(GlowButtonStyle())
            .padding(.top)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
} 