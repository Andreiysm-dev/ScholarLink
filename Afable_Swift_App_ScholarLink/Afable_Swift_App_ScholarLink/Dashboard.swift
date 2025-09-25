import SwiftUI
import SwiftData

struct DashboardView: View {
    @State private var selectedTab = 0
    
    // Query tutors who have completed their profile setup
    @Query(filter: #Predicate<User> { user in
        user.userRoleRaw == "tutor" && user.isProfileComplete
    }) private var tutors: [User]
    
    // Query all users to find current user (for now, we'll use the first user as current user)
    @Query private var allUsers: [User]
    
    // Query session requests to show accepted sessions
    @Query private var allSessionRequests: [SessionRequest]
    
    // No more hardcoded data - we'll use real tutors from SwiftData
    
    // Get current logged-in user
    var currentUser: User? {
        return UserSession.shared.currentUser
    }
    
    // Get accepted sessions for current user
    var acceptedSessions: [SessionRequest] {
        guard let user = currentUser else { return [] }
        return allSessionRequests.filter { 
            $0.studentId == user.id.hashValue.description && $0.status == "accepted" 
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Tab Selection
            tabSelection
            
            // Content Section
                ScrollView {
                    VStack(spacing: 20) {
                        // Available Tutors (replacing course progress)
                        tutorCardsSection
                        
                        // Recent Activity (replacing work completed)
                        recentActivitySection
                        
                        Spacer(minLength: 100) // Space for tab bar
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
        }
        .background(Color(UIColor.systemGroupedBackground))
    }
    
    // MARK: - Header Section Removed (using header from index)
    
    // MARK: - Tab Selection
    var tabSelection: some View {
        HStack(spacing: 40) {
            TabButton(title: "Dashboard", isSelected: selectedTab == 0) {
                selectedTab = 0
            }
            
            TabButton(title: "Tutors", isSelected: selectedTab == 1) {
                selectedTab = 1
            }
            
            TabButton(title: "Activity", isSelected: selectedTab == 2) {
                selectedTab = 2
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }
    
    // MARK: - Tutor Cards Section (replacing course progress)
    var tutorCardsSection: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
            if tutors.isEmpty {
                // Show empty state when no tutors are available
                VStack(spacing: 12) {
                    Image(systemName: "person.3")
                        .font(.largeTitle)
                        .foregroundColor(.gray.opacity(0.6))
                    
                    Text("No Tutors Available")
                        .font(.headline)
                        .foregroundColor(.gray)
                    
                    Text("Register as a tutor to appear here")
                        .font(.subheadline)
                        .foregroundColor(.gray.opacity(0.8))
                        .multilineTextAlignment(.center)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
            } else {
                ForEach(tutors, id: \.id) { tutor in
                    NavigationLink(destination: TutorDetailView(tutor: tutor)) {
                        RealTutorCard(tutor: tutor)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
    
    // MARK: - Recent Activity Section (replacing work completed)
    var recentActivitySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Your Sessions")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
                if !acceptedSessions.isEmpty {
                    Text("\(acceptedSessions.count) Booked")
                        .font(.caption)
                        .foregroundColor(.green)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(8)
                }
            }
            .padding(.horizontal, 4)
            
            if acceptedSessions.isEmpty {
                EmptySessionCard()
            } else {
                ForEach(acceptedSessions.prefix(3), id: \.id) { session in
                    SessionActivityRow(session: session)
                }
            }
        }
    }
}

// MARK: - Supporting Views

struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .blue : .gray)
                .padding(.bottom, 8)
                .overlay(
                    Rectangle()
                        .frame(height: 2)
                        .foregroundColor(isSelected ? .blue : .clear),
                    alignment: .bottom
                )
        }
    }
}

// Note: Using RealTutorCard from Home.swift - no need to redeclare

// MARK: - Simple Activity Row (replacing completed task row)
struct SimpleActivityRow: View {
    let activity: String
    let detail: String
    
    var body: some View {
        HStack {
            // Activity Info
            VStack(alignment: .leading, spacing: 4) {
                Text(activity)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text("Completed")
                    .font(.caption)
                    .foregroundColor(.green)
            }
            
            Spacer()
            
            // Simple detail
            Text(detail)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.blue)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

// Note: Using TutorDetailView from Home.swift for tutor profiles

// MARK: - Session Components

struct SessionActivityRow: View {
    let session: SessionRequest
    @Query private var allUsers: [User]
    
    var tutor: User? {
        allUsers.first { $0.id.hashValue.description == session.tutorId }
    }
    
    var body: some View {
        HStack {
            // Tutor Info
            VStack(alignment: .leading, spacing: 4) {
                Text("\(session.subject) with \(tutor?.firstName ?? "Tutor")")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(session.requestedDate.sessionDateFormat)
                    .font(.caption)
                    .foregroundColor(.blue)
            }
            
            Spacer()
            
            // Session details
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(session.duration) min")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.green)
                
                Text("Confirmed")
                    .font(.caption2)
                    .foregroundColor(.green)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(4)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

struct EmptySessionCard: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "calendar.badge.plus")
                .font(.system(size: 40))
                .foregroundColor(.gray.opacity(0.6))
            
            Text("No Sessions Yet")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.gray)
            
            Text("Book a session with a tutor to get started!")
                .font(.caption)
                .foregroundColor(.gray.opacity(0.8))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
}

// Note: Removed duplicate components - using existing ones from Home.swift

// MARK: - Data Models

struct SimpleTutor {
    let name: String
    let subject: String
    let rating: Double
    let price: Int
}

// MARK: - Preview

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
    }
}
