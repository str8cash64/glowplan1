import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct HomeView: View {
    @State private var userName: String = ""
    @State private var isLoading = true
    @State private var selectedCard: String?
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.glowPink
                    .ignoresSafeArea()
                
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .glowCoral))
                        .scaleEffect(1.5)
                } else {
                    ScrollView {
                        VStack(spacing: 25) {
                            // Welcome Message
                            Text(userName.isEmpty ? "Welcome to GlowPlan ✨" : "Welcome, \(userName) ✨")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                                .multilineTextAlignment(.center)
                                .padding(.top, 10)
                                .shadow(color: .black.opacity(0.1), radius: 1)
                            
                            // Quick Actions Section
                            VStack(spacing: 15) {
                                Text("Quick Actions")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                LazyVGrid(columns: [
                                    GridItem(.flexible()),
                                    GridItem(.flexible())
                                ], spacing: 15) {
                                    NavigationLink {
                                        RoutinesView()
                                    } label: {
                                        QuickActionButton(
                                            title: "My Routines",
                                            systemImage: "list.bullet.clipboard",
                                            color: Color.glowCoral,
                                            isSelected: selectedCard == "routines"
                                        )
                                    }
                                    .simultaneousGesture(TapGesture().onEnded {
                                        withAnimation {
                                            selectedCard = "routines"
                                        }
                                    })
                                    
                                    NavigationLink {
                                        RecommendedView()
                                    } label: {
                                        QuickActionButton(
                                            title: "Products",
                                            systemImage: "star.fill",
                                            color: Color.glowCoral,
                                            isSelected: selectedCard == "products"
                                        )
                                    }
                                    .simultaneousGesture(TapGesture().onEnded {
                                        withAnimation {
                                            selectedCard = "products"
                                        }
                                    })
                                    
                                    NavigationLink {
                                        GlowChatView()
                                    } label: {
                                        QuickActionButton(
                                            title: "Glow Chat",
                                            systemImage: "message.fill",
                                            color: Color.glowCoral,
                                            isSelected: selectedCard == "chat"
                                        )
                                    }
                                    .simultaneousGesture(TapGesture().onEnded {
                                        withAnimation {
                                            selectedCard = "chat"
                                        }
                                    })
                                    
                                    NavigationLink {
                                        AccountView()
                                    } label: {
                                        QuickActionButton(
                                            title: "Profile",
                                            systemImage: "person.fill",
                                            color: Color.glowCoral,
                                            isSelected: selectedCard == "profile"
                                        )
                                    }
                                    .simultaneousGesture(TapGesture().onEnded {
                                        withAnimation {
                                            selectedCard = "profile"
                                        }
                                    })
                                }
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(15)
                            .shadow(color: Color.black.opacity(0.1), radius: 5)
                            
                            // Today's Routine Section
                            VStack(spacing: 15) {
                                Text("Today's Routine")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                VStack(spacing: 20) {
                                    RoutineCard(title: "Morning Routine", time: "AM", items: [
                                        "Cleanser",
                                        "Toner",
                                        "Moisturizer",
                                        "Sunscreen"
                                    ])
                                    .transition(.scale)
                                    
                                    RoutineCard(title: "Evening Routine", time: "PM", items: [
                                        "Makeup Remover",
                                        "Cleanser",
                                        "Treatment",
                                        "Night Cream"
                                    ])
                                    .transition(.scale)
                                }
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(15)
                            .shadow(color: Color.black.opacity(0.1), radius: 5)
                        }
                        .padding()
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                fetchUserName()
            }
        }
    }
    
    private func fetchUserName() {
        guard let userId = Auth.auth().currentUser?.uid else {
            isLoading = false
            return
        }
        
        Firestore.firestore().collection("users").document(userId).getDocument { document, error in
            DispatchQueue.main.async {
                if let document = document, document.exists {
                    userName = document.data()?["Name"] as? String ?? ""
                }
                isLoading = false
            }
        }
    }
}

struct QuickActionButton: View {
    let title: String
    let systemImage: String
    let color: Color
    var isSelected: Bool = false
    
    var body: some View {
        VStack {
            Image(systemName: systemImage)
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(isSelected ? .white : color)
                .frame(width: 60, height: 60)
                .background(
                    Circle()
                        .fill(isSelected ? color : color.opacity(0.1))
                )
                .scaleEffect(isSelected ? 1.1 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
            
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .medium)
                .foregroundColor(isSelected ? color : .black)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: isSelected ? color.opacity(0.3) : Color.black.opacity(0.05),
                       radius: isSelected ? 8 : 5,
                       x: 0,
                       y: isSelected ? 4 : 2)
        )
    }
}

struct RoutineCard: View {
    let title: String
    let time: String
    let items: [String]
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    Text(title)
                        .font(.headline)
                    Text("(\(time))")
                        .foregroundColor(.gray)
                        .font(.subheadline)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.glowCoral)
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                }
            }
            
            if isExpanded {
                ForEach(items, id: \.self) { item in
                    HStack(spacing: 10) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.glowCoral)
                        Text(item)
                            .font(.subheadline)
                        Spacer()
                    }
                    .transition(.opacity.combined(with: .slide))
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.glowCoral.opacity(0.05))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.glowCoral.opacity(0.1), lineWidth: 1)
        )
    }
} 