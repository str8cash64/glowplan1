import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct AccountView: View {
    @State private var showLogoutAlert = false
    @State private var userName: String = ""
    @State private var skinType: String = ""
    @State private var skinGoals: [String] = []
    @State private var sensitivity: String = ""
    @State private var isLoading = true
    @EnvironmentObject private var appState: AppState
    
    var body: some View {
        ZStack {
            Color.glowPink
                .ignoresSafeArea()
            
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .glowCoral))
                    .scaleEffect(1.5)
            } else {
                ScrollView {
                    VStack(spacing: 20) {
                        // Profile Header
                        VStack(spacing: 15) {
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 80))
                                .foregroundColor(.glowCoral)
                            
                            Text(userName)
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text(Auth.auth().currentUser?.email ?? "")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .padding(.vertical)
                        
                        // Skin Profile Card
                        AccountCard(title: "My Skin Profile", icon: "sparkles") {
                            VStack(alignment: .leading, spacing: 15) {
                                InfoRow(title: "Skin Type", value: skinType)
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Skin Goals")
                                        .font(.headline)
                                    
                                    ForEach(skinGoals, id: \.self) { goal in
                                        HStack(spacing: 8) {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(.glowCoral)
                                            Text(goal)
                                                .font(.subheadline)
                                        }
                                    }
                                }
                                
                                InfoRow(title: "Sensitivity", value: sensitivity)
                            }
                        }
                        
                        // Settings Card
                        AccountCard(title: "Settings", icon: "gear") {
                            VStack(spacing: 5) {
                                NavigationLink {
                                    Text("Notifications Settings")
                                } label: {
                                    SettingsRow(title: "Notifications", icon: "bell.fill")
                                }
                                
                                Divider()
                                    .padding(.vertical, 5)
                                
                                NavigationLink {
                                    Text("Privacy Settings")
                                } label: {
                                    SettingsRow(title: "Privacy", icon: "lock.fill")
                                }
                                
                                Divider()
                                    .padding(.vertical, 5)
                                
                                NavigationLink {
                                    Text("Help & Support")
                                } label: {
                                    SettingsRow(title: "Help", icon: "questionmark.circle.fill")
                                }
                            }
                        }
                        
                        // Logout Button
                        Button(action: { showLogoutAlert = true }) {
                            HStack {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                Text("Log Out")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.glowCoral)
                            .cornerRadius(12)
                            .shadow(color: Color.glowCoral.opacity(0.3), radius: 5, y: 2)
                        }
                        .padding(.top, 10)
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Account")
        .navigationBarTitleDisplayMode(.large)
        .alert("Log Out", isPresented: $showLogoutAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Log Out", role: .destructive) {
                do {
                    try Auth.auth().signOut()
                    appState.isLoggedIn = false
                } catch {
                    print("Error signing out: \(error.localizedDescription)")
                }
            }
        } message: {
            Text("Are you sure you want to log out?")
        }
        .onAppear {
            fetchUserData()
        }
    }
    
    private func fetchUserData() {
        guard let userId = Auth.auth().currentUser?.uid else {
            isLoading = false
            return
        }
        
        Firestore.firestore().collection("users").document(userId).getDocument { document, error in
            DispatchQueue.main.async {
                if let document = document, document.exists {
                    let data = document.data()
                    userName = data?["Name"] as? String ?? ""
                    skinType = data?["SkinType"] as? String ?? ""
                    skinGoals = data?["SkinGoals"] as? [String] ?? []
                    sensitivity = data?["Sensitivity"] as? String ?? ""
                }
                isLoading = false
            }
        }
    }
}

struct AccountCard<Content: View>: View {
    let title: String
    let icon: String
    let content: Content
    
    init(title: String, icon: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(.glowCoral)
                Text(title)
                    .font(.title3)
                    .fontWeight(.bold)
            }
            
            content
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.1), radius: 5)
    }
}

struct InfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.headline)
            Text(value)
                .font(.subheadline)
                .foregroundColor(.gray)
        }
    }
}

struct SettingsRow: View {
    let title: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.glowCoral)
                .frame(width: 30)
            Text(title)
                .foregroundColor(.primary)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.gray)
        }
        .contentShape(Rectangle())
    }
} 