import SwiftUI
import SwiftData

struct DashboardView: View {
    @State private var selectedTab = 0
    
    @StateObject private var sessionManager = SimpleSessionManager.shared
    
    // Get current logged-in user
    var currentUser: User? {
        return UserSession.shared.currentUser
    }
    
    // Get accepted sessions for current student
    var acceptedSessions: [SimpleSession] {
        guard let user = currentUser else { return [] }
        return sessionManager.getAcceptedSessionsForStudent(email: user.email)
    }
    
    // Get all sessions for current student (for stats)
    var allStudentSessions: [SimpleSession] {
        guard let user = currentUser else { return [] }
        return sessionManager.getSessionsForStudent(email: user.email)
    }
    
    var pendingSessions: [SimpleSession] {
        allStudentSessions.filter { $0.isPending }
    }
    
    var rejectedSessions: [SimpleSession] {
        allStudentSessions.filter { $0.isRejected }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Tab Selection
            tabSelection
            
            // Content Section
                ScrollView {
                    VStack(spacing: 20) {
                        // Session Statistics
                        sessionStatsSection
                        
                        // My Tutors (only tutors who accepted sessions)
                        tutorCardsSection
                        
                        // Recent Activity (accepted sessions)
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
    
    // MARK: - Session Statistics Section
    var sessionStatsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Session Overview")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
                if let user = currentUser {
                    Text("Welcome, \(user.firstName)!")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal, 4)
            
            HStack(spacing: 12) {
                SessionStatCard(
                    title: "Confirmed",
                    count: acceptedSessions.count,
                    color: .green,
                    icon: "checkmark.circle.fill"
                )
                
                SessionStatCard(
                    title: "Pending",
                    count: pendingSessions.count,
                    color: .orange,
                    icon: "clock.fill"
                )
                
                SessionStatCard(
                    title: "Total",
                    count: allStudentSessions.count,
                    color: .blue,
                    icon: "calendar"
                )
            }
        }
    }
    
    // MARK: - My Tutors Section (only tutors who accepted sessions)
    var tutorCardsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("My Tutors")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
                if !acceptedSessions.isEmpty {
                    Text("\(Set(acceptedSessions.map { $0.tutorEmail }).count) Tutors")
                        .font(.caption)
                        .foregroundColor(.blue)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                }
            }
            .padding(.horizontal, 4)
            
            if acceptedSessions.isEmpty {
                // Show empty state when no accepted sessions
                VStack(spacing: 12) {
                    Image(systemName: "person.3")
                        .font(.largeTitle)
                        .foregroundColor(.gray.opacity(0.6))
                    
                    Text("No Tutors Yet")
                        .font(.headline)
                        .foregroundColor(.gray)
                    
                    Text("Book sessions with tutors to see them here")
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
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                    // Get unique tutors from accepted sessions
                    ForEach(Array(Set(acceptedSessions.map { $0.tutorEmail })), id: \.self) { tutorEmail in
                        MyTutorCard(tutorEmail: tutorEmail, sessions: acceptedSessions.filter { $0.tutorEmail == tutorEmail })
                    }
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
    let session: SimpleSession
    
    var body: some View {
        HStack {
            // Tutor Info
            VStack(alignment: .leading, spacing: 4) {
                Text("\(session.subject) with \(session.tutorName)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(session.date.formatted(date: .abbreviated, time: .shortened))
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
                
                Text("$\(Int(session.totalCost))")
                    .font(.caption)
                    .fontWeight(.semibold)
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

struct MyTutorCard: View {
    let tutorEmail: String
    let sessions: [SimpleSession]
    
    var tutorName: String {
        sessions.first?.tutorName ?? "Tutor"
    }
    
    var totalSessions: Int {
        sessions.count
    }
    
    var nextSession: SimpleSession? {
        sessions.filter { $0.date > Date() }.sorted { $0.date < $1.date }.first
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Tutor Info
            HStack {
                Circle()
                    .fill(Color.blue.opacity(0.2))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Text(String(tutorName.prefix(2)))
                            .font(.subheadline)
                            .foregroundColor(.blue)
                            .fontWeight(.bold)
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(tutorName)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .lineLimit(1)
                    
                    Text("\(totalSessions) session\(totalSessions == 1 ? "" : "s")")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
            }
            
            // Next Session or Status
            if let next = nextSession {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Next Session")
                        .font(.caption)
                        .foregroundColor(.green)
                        .fontWeight(.medium)
                    
                    Text(next.subject)
                        .font(.caption)
                        .fontWeight(.semibold)
                    
                    Text(next.date.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
            } else {
                Text("All sessions completed")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .italic()
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

struct SessionStatCard: View {
    let title: String
    let count: Int
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Spacer()
                
                Text("\(count)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(color)
            }
            
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
                .frame(maxWidth: .infinity, alignment: .leading)
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
