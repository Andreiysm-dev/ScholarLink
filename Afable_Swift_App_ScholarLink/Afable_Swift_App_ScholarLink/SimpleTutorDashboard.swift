import SwiftUI

struct SimpleTutorDashboardView: View {
    @StateObject private var sessionManager = SimpleSessionManager.shared
    
    var currentTutor: User? {
        return UserSession.shared.currentUser
    }
    
    var tutorSessions: [SimpleSession] {
        guard let tutor = currentTutor else { return [] }
        return sessionManager.getSessionsForTutor(email: tutor.email)
    }
    
    var pendingRequests: [SimpleSession] {
        tutorSessions.filter { $0.isPending }
    }
    
    var acceptedSessions: [SimpleSession] {
        tutorSessions.filter { $0.isAccepted }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 12) {
                        Text("Tutor Dashboard")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        if let tutor = currentTutor {
                            Text("Welcome, \(tutor.firstName)!")
                                .font(.headline)
                                .foregroundColor(.gray)
                            
                            // Debug information
                            VStack(spacing: 4) {
                                Text("Debug Info:")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                Text("Tutor Email: \(tutor.email)")
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                                Text("Total Sessions in System: \(sessionManager.sessions.count)")
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                                Text("Sessions for this tutor: \(tutorSessions.count)")
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                                Text("Pending requests: \(pendingRequests.count)")
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                            }
                            .padding(8)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                        }
                        
                        // Stats
                        HStack(spacing: 20) {
                            StatCard(title: "Pending", count: pendingRequests.count, color: .orange)
                            StatCard(title: "Accepted", count: acceptedSessions.count, color: .green)
                            StatCard(title: "Total Requests", count: tutorSessions.count, color: .blue)
                        }
                    }
                    .padding()
                    
                    // Show all sessions for debugging
                    if !sessionManager.sessions.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("All Sessions in System (Debug):")
                                .font(.caption)
                                .foregroundColor(.red)
                            
                            ForEach(sessionManager.sessions.prefix(5)) { session in
                                Text("Session: \(session.studentName) → \(session.tutorName) (\(session.subject))")
                                    .font(.caption2)
                                    .foregroundColor(.red)
                            }
                        }
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(8)
                        .padding(.horizontal)
                    }
                    
                    // Pending Requests Section
                    if !pendingRequests.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Pending Requests")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .padding(.horizontal)
                            
                            ForEach(pendingRequests) { request in
                                SimpleSessionRequestCard(
                                    session: request,
                                    onAccept: { acceptSession(request) },
                                    onReject: { rejectSession(request) }
                                )
                            }
                        }
                    }
                    
                    // Accepted Sessions Section
                    if !acceptedSessions.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Upcoming Sessions")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .padding(.horizontal)
                            
                            ForEach(acceptedSessions) { session in
                                SimpleAcceptedSessionCard(session: session)
                            }
                        }
                    }
                    
                    // Empty State
                    if tutorSessions.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "calendar.badge.plus")
                                .font(.system(size: 60))
                                .foregroundColor(.gray.opacity(0.6))
                            
                            Text("No Session Requests Yet")
                                .font(.headline)
                                .foregroundColor(.gray)
                            
                            Text("Students will see your profile and can request sessions with you.")
                                .font(.subheadline)
                                .foregroundColor(.gray.opacity(0.8))
                                .multilineTextAlignment(.center)
                        }
                        .padding()
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
    
    private func acceptSession(_ session: SimpleSession) {
        sessionManager.acceptSession(session)
    }
    
    private func rejectSession(_ session: SimpleSession) {
        sessionManager.rejectSession(session)
    }
}

struct SimpleSessionRequestCard: View {
    let session: SimpleSession
    let onAccept: () -> Void
    let onReject: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Student Info
            HStack {
                Circle()
                    .fill(Color.green.opacity(0.2))
                    .frame(width: 50, height: 50)
                    .overlay(
                        Text(String(session.studentName.prefix(2)))
                            .font(.headline)
                            .foregroundColor(.green)
                            .fontWeight(.bold)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(session.studentName)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text(session.studentEmail)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Text("$\(Int(session.totalCost))")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
            }
            
            // Session Details
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Label(session.subject, systemImage: "book.fill")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                    
                    Spacer()
                    
                    Label("\(session.duration) min", systemImage: "clock")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Label(session.date.formatted(date: .abbreviated, time: .shortened), systemImage: "calendar")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                if !session.message.isEmpty {
                    Text("Message: \(session.message)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top, 4)
                }
            }
            
            // Action Buttons
            HStack(spacing: 12) {
                Button(action: onReject) {
                    Text("Decline")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(8)
                }
                
                Button(action: onAccept) {
                    Text("Accept")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color.green)
                        .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        .padding(.horizontal)
    }
}

struct SimpleAcceptedSessionCard: View {
    let session: SimpleSession
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Circle()
                    .fill(Color.green.opacity(0.2))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Text(String(session.studentName.prefix(2)))
                            .font(.subheadline)
                            .foregroundColor(.green)
                            .fontWeight(.bold)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(session.studentName)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    Text(session.subject)
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(session.date.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Text("\(session.duration) min")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
        .background(Color.green.opacity(0.05))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.green.opacity(0.2), lineWidth: 1)
        )
        .padding(.horizontal)
    }
}

struct SimpleTutorDashboardView_Previews: PreviewProvider {
    static var previews: some View {
        SimpleTutorDashboardView()
    }
}
