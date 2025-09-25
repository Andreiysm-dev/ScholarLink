import SwiftUI
import SwiftData

struct TutorDashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var allUsers: [User]
    @Query private var allSessionRequests: [SessionRequest]
    
    // Get current tutor (simplified - in real app you'd have proper session management)
    var currentTutor: User? {
        return allUsers.first { $0.userRoleRaw == "tutor" }
    }
    
    // Get session requests for current tutor
    var tutorSessionRequests: [SessionRequest] {
        guard let tutor = currentTutor else { return [] }
        return allSessionRequests.filter { $0.tutorId == tutor.id.hashValue.description }
    }
    
    var pendingRequests: [SessionRequest] {
        tutorSessionRequests.filter { $0.status == "pending" }
    }
    
    var acceptedSessions: [SessionRequest] {
        tutorSessionRequests.filter { $0.status == "accepted" }
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
                        }
                        
                        // Stats
                        HStack(spacing: 20) {
                            StatCard(title: "Pending", count: pendingRequests.count, color: .orange)
                            StatCard(title: "Accepted", count: acceptedSessions.count, color: .green)
                            StatCard(title: "Total Requests", count: tutorSessionRequests.count, color: .blue)
                        }
                    }
                    .padding()
                    
                    // Pending Requests Section
                    if !pendingRequests.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Pending Requests")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .padding(.horizontal)
                            
                            ForEach(pendingRequests, id: \.id) { request in
                                SessionRequestCard(request: request, onAccept: {
                                    acceptRequest(request)
                                }, onReject: {
                                    rejectRequest(request)
                                })
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
                            
                            ForEach(acceptedSessions, id: \.id) { session in
                                AcceptedSessionCard(session: session)
                            }
                        }
                    }
                    
                    // Empty State
                    if tutorSessionRequests.isEmpty {
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
    
    private func acceptRequest(_ request: SessionRequest) {
        request.status = "accepted"
        try? modelContext.save()
    }
    
    private func rejectRequest(_ request: SessionRequest) {
        request.status = "rejected"
        try? modelContext.save()
    }
}

struct StatCard: View {
    let title: String
    let count: Int
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text("\(count)")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}

struct SessionRequestCard: View {
    let request: SessionRequest
    let onAccept: () -> Void
    let onReject: () -> Void
    @Query private var allUsers: [User]
    
    var student: User? {
        allUsers.first { $0.id.hashValue.description == request.studentId }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Student Info
            HStack {
                Circle()
                    .fill(Color.green.opacity(0.2))
                    .frame(width: 50, height: 50)
                    .overlay(
                        Text("\(String(student?.firstName.prefix(1) ?? "S"))\(String(student?.lastName.prefix(1) ?? "T"))")
                            .font(.headline)
                            .foregroundColor(.green)
                            .fontWeight(.bold)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(student?.firstName ?? "Unknown") \(student?.lastName ?? "Student")")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text(student?.email ?? "")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Text("$\(Int(request.hourlyRate * Double(request.duration) / 60.0))")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
            }
            
            // Session Details
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Label(request.subject, systemImage: "book.fill")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                    
                    Spacer()
                    
                    Label("\(request.duration) min", systemImage: "clock")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Label(request.requestedDate.sessionDateFormat, systemImage: "calendar")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                if !request.message.isEmpty {
                    Text("Message: \(request.message)")
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

struct AcceptedSessionCard: View {
    let session: SessionRequest
    @Query private var allUsers: [User]
    
    var student: User? {
        allUsers.first { $0.id.hashValue.description == session.studentId }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Circle()
                    .fill(Color.green.opacity(0.2))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Text("\(String(student?.firstName.prefix(1) ?? "S"))\(String(student?.lastName.prefix(1) ?? "T"))")
                            .font(.subheadline)
                            .foregroundColor(.green)
                            .fontWeight(.bold)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(student?.firstName ?? "Unknown") \(student?.lastName ?? "Student")")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    Text(session.subject)
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(session.requestedDate.sessionDateFormat)
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

struct TutorDashboardView_Previews: PreviewProvider {
    static var previews: some View {
        TutorDashboardView()
            .modelContainer(for: [User.self, SessionRequest.self], inMemory: true)
    }
}
