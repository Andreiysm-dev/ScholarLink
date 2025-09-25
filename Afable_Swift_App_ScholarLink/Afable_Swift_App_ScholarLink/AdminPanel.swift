import SwiftUI
import SwiftData

struct AdminPanelView: View {
    @Query private var allUsers: [User]
    @Environment(\.modelContext) private var modelContext
    @State private var showingDeleteAlert = false
    @State private var userToDelete: User?
    
    var body: some View {
        NavigationView {
            VStack {
                // Admin Header
                VStack(spacing: 8) {
                    Text("Admin Panel")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("User Management")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    // Stats
                    HStack(spacing: 30) {
                        StatView(title: "Total Users", count: allUsers.count)
                        StatView(title: "Tutors", count: tutorCount)
                        StatView(title: "Students", count: studentCount)
                    }
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(12)
                }
                .padding()
                
                // User List
                List {
                    ForEach(allUsers, id: \.id) { user in
                        UserRowView(user: user) {
                            userToDelete = user
                            showingDeleteAlert = true
                        }
                    }
                }
                .listStyle(PlainListStyle())
            }
            .navigationTitle("Admin")
            .navigationBarTitleDisplayMode(.inline)
            .alert("Delete User", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    if let user = userToDelete {
                        deleteUser(user)
                    }
                }
            } message: {
                Text("Are you sure you want to delete this user? This action cannot be undone.")
            }
        }
    }
    
    // MARK: - Computed Properties
    var tutorCount: Int {
        allUsers.filter { $0.userRoleRaw == "tutor" }.count
    }
    
    var studentCount: Int {
        allUsers.filter { $0.userRoleRaw == "learner" }.count
    }
    
    // MARK: - Functions
    private func deleteUser(_ user: User) {
        modelContext.delete(user)
        try? modelContext.save()
    }
}

// MARK: - Supporting Views

struct StatView: View {
    let title: String
    let count: Int
    
    var body: some View {
        VStack(spacing: 4) {
            Text("\(count)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.blue)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
}

struct UserRowView: View {
    let user: User
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Profile Circle
            Circle()
                .fill(roleColor.opacity(0.2))
                .frame(width: 50, height: 50)
                .overlay(
                    Text("\(String(user.firstName.prefix(1)))\(String(user.lastName.prefix(1)))")
                        .font(.headline)
                        .foregroundColor(roleColor)
                        .fontWeight(.semibold)
                )
            
            // User Info
            VStack(alignment: .leading, spacing: 4) {
                Text("\(user.firstName) \(user.lastName)")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text(user.email)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                HStack(spacing: 8) {
                    // Role Badge - show actual raw value
                    Text(user.userRoleRaw.isEmpty ? "No Role" : user.userRoleRaw)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(roleColor.opacity(0.2))
                        .foregroundColor(roleColor)
                        .cornerRadius(8)
                    
                    // Profile Status
                    Text(user.isProfileComplete ? "Complete" : "Incomplete")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(user.isProfileComplete ? Color.green.opacity(0.2) : Color.orange.opacity(0.2))
                        .foregroundColor(user.isProfileComplete ? .green : .orange)
                        .cornerRadius(8)
                    
                    Spacer()
                }
            }
            
            Spacer()
            
            // Delete Button
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
                    .font(.title3)
            }
        }
        .padding(.vertical, 8)
    }
    
    private var roleColor: Color {
        switch user.userRoleRaw {
        case "tutor": return .blue
        case "learner": return .green
        default: return .orange // Unknown or empty role
        }
    }
}

// MARK: - Preview
struct AdminPanelView_Previews: PreviewProvider {
    static var previews: some View {
        AdminPanelView()
            .modelContainer(for: User.self, inMemory: true)
    }
}
