import SwiftUI
import Foundation

// Simple session data structure
struct SimpleSession: Identifiable {
    let id = UUID()
    let studentName: String
    let studentEmail: String
    let tutorName: String
    let tutorEmail: String
    let subject: String
    let date: Date
    let duration: Int
    let message: String
    let hourlyRate: Double
    var status: String = "pending" // pending, accepted, rejected
    let dateCreated: Date = Date()
    
    var totalCost: Double {
        return hourlyRate * (Double(duration) / 60.0)
    }
    
    var isAccepted: Bool { status == "accepted" }
    var isPending: Bool { status == "pending" }
    var isRejected: Bool { status == "rejected" }
}

// Simple session manager using ObservableObject
class SimpleSessionManager: ObservableObject {
    @Published var sessions: [SimpleSession] = []
    
    static let shared = SimpleSessionManager()
    
    private init() {}
    
    // Add a new session request
    func addSession(_ session: SimpleSession) {
        sessions.append(session)
        print("✅ Session added! Total sessions: \(sessions.count)")
        
        // Notify tutor of new request
        NotificationManager.shared.notifyTutorOfNewRequest(
            tutorEmail: session.tutorEmail,
            studentName: session.studentName,
            subject: session.subject,
            sessionId: session.id
        )
    }
    
    // Get sessions for a specific tutor
    func getSessionsForTutor(email: String) -> [SimpleSession] {
        return sessions.filter { $0.tutorEmail == email }
    }
    
    // Get sessions for a specific student
    func getSessionsForStudent(email: String) -> [SimpleSession] {
        return sessions.filter { $0.studentEmail == email }
    }
    
    // Accept a session
    func acceptSession(_ session: SimpleSession) {
        if let index = sessions.firstIndex(where: { $0.id == session.id }) {
            sessions[index].status = "accepted"
            
            // Notify student of acceptance
            NotificationManager.shared.notifyStudentOfAcceptance(
                studentEmail: session.studentEmail,
                tutorName: session.tutorName,
                subject: session.subject,
                sessionId: session.id
            )
        }
    }
    
    // Reject a session
    func rejectSession(_ session: SimpleSession) {
        if let index = sessions.firstIndex(where: { $0.id == session.id }) {
            sessions[index].status = "rejected"
            
            // Notify student of rejection
            NotificationManager.shared.notifyStudentOfRejection(
                studentEmail: session.studentEmail,
                tutorName: session.tutorName,
                subject: session.subject,
                sessionId: session.id
            )
        }
    }
    
    // Get pending sessions for tutor
    func getPendingSessionsForTutor(email: String) -> [SimpleSession] {
        return getSessionsForTutor(email: email).filter { $0.isPending }
    }
    
    // Get accepted sessions for student
    func getAcceptedSessionsForStudent(email: String) -> [SimpleSession] {
        return getSessionsForStudent(email: email).filter { $0.isAccepted }
    }
}
