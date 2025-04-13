import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct RoutinesView: View {
    @State private var routines: [Routine] = []
    @State private var isLoading = true
    @State private var selectedRoutine: String = "morning"
    
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
                    VStack(spacing: 30) {
                        Text("My Routines")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                            .padding(.top)
                        
                        if let currentRoutine = routines.first {
                            // Routine Type Picker
                            Picker("Routine", selection: $selectedRoutine) {
                                Text("Morning").tag("morning")
                                Text("Evening").tag("evening")
                            }
                            .pickerStyle(.segmented)
                            .padding(.horizontal)
                            
                            // Display current routine steps
                            VStack(spacing: 20) {
                                let steps = selectedRoutine == "morning" ? currentRoutine.morningRoutine : currentRoutine.eveningRoutine
                                ForEach(steps) { step in
                                    routineStepCard(step: step)
                                }
                            }
                            .padding(.horizontal)
                        } else {
                            Text("No routines found")
                                .foregroundColor(.gray)
                                .padding()
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("My Routines")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            fetchRoutines()
        }
    }
    
    private func routineStepCard(step: RoutineStep) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(step.title)
                    .font(.headline)
                    .foregroundColor(.black)
                
                Spacer()
                
                if let duration = step.duration {
                    Text(duration)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
            
            Text(step.description)
                .font(.subheadline)
                .foregroundColor(.black.opacity(0.8))
            
            if let tip = step.tip {
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "lightbulb.fill")
                        .foregroundColor(.glowCoral)
                    Text(tip)
                        .font(.caption)
                        .foregroundColor(.black.opacity(0.7))
                }
                .padding(.top, 4)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.05), radius: 5)
    }
    
    private func fetchRoutines() {
        guard let userId = Auth.auth().currentUser?.uid else {
            isLoading = false
            return
        }
        
        Firestore.firestore()
            .collection("users")
            .document(userId)
            .collection("routines")
            .order(by: "timestamp", descending: true)
            .limit(to: 1)
            .addSnapshotListener { snapshot, error in
                isLoading = false
                
                if let error = error {
                    print("Error fetching routines: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    return
                }
                
                routines = documents.compactMap { document -> Routine? in
                    do {
                        let data = document.data()
                        let morningData = data["morningRoutine"] as? [[String: Any]] ?? []
                        let eveningData = data["eveningRoutine"] as? [[String: Any]] ?? []
                        
                        let morningSteps = try morningData.map { stepData -> RoutineStep in
                            return RoutineStep(
                                id: stepData["id"] as? String ?? UUID().uuidString,
                                title: stepData["title"] as? String ?? "",
                                description: stepData["description"] as? String ?? "",
                                duration: stepData["duration"] as? String,
                                tip: stepData["tip"] as? String
                            )
                        }
                        
                        let eveningSteps = try eveningData.map { stepData -> RoutineStep in
                            return RoutineStep(
                                id: stepData["id"] as? String ?? UUID().uuidString,
                                title: stepData["title"] as? String ?? "",
                                description: stepData["description"] as? String ?? "",
                                duration: stepData["duration"] as? String,
                                tip: stepData["tip"] as? String
                            )
                        }
                        
                        return Routine(
                            morningRoutine: morningSteps,
                            eveningRoutine: eveningSteps
                        )
                    } catch {
                        print("Error decoding routine: \(error)")
                        return nil
                    }
                }
            }
    }
} 