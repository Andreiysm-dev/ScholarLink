import SwiftData
import Foundation

@Model
class SessionRequest {
    var id: UUID
    var studentId: UUID
    var tutorId: UUID
    var subject: String
    var requestedDate: Date
    var duration: Int // in minutes
    var message: String
    var status: String // "pending", "accepted", "rejected"
    var dateCreated: Date
    var hourlyRate: Double
    
    // Computed properties for easy access
    var isAccepted: Bool { status == "accepted" }
    var isPending: Bool { status == "pending" }
    var isRejected: Bool { status == "rejected" }
    
    init(studentId: UUID, tutorId: UUID, subject: String, requestedDate: Date, duration: Int, message: String, hourlyRate: Double) {
        self.id = UUID()
        self.studentId = studentId
        self.tutorId = tutorId
        self.subject = subject
        self.requestedDate = requestedDate
        self.duration = duration
        self.message = message
        self.status = "pending"
        self.dateCreated = Date()
        self.hourlyRate = hourlyRate
    }
}

enum SessionStatus: String, CaseIterable {
    case pending = "pending"
    case accepted = "accepted"
    case rejected = "rejected"
    
    var displayName: String {
        switch self {
        case .pending: return "Pending"
        case .accepted: return "Accepted"
        case .rejected: return "Rejected"
        }
    }
    
    var color: Color {
        switch self {
        case .pending: return .orange
        case .accepted: return .green
        case .rejected: return .red
        }
    }
}

import SwiftUI

// Extension to help with date formatting
extension Date {
    var sessionDateFormat: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }
}
