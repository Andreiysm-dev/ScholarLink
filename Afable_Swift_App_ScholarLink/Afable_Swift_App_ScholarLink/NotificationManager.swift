import SwiftUI
import Foundation

// Simple notification structure
struct AppNotification: Identifiable {
    let id = UUID()
    let title: String
    let message: String
    let type: NotificationType
    let userEmail: String // Who should see this notification
    let relatedSessionId: UUID? // Link to session if applicable
    let timestamp: Date = Date()
    var isRead: Bool = false
    
    enum NotificationType {
        case sessionRequest    // New session request for tutor
        case sessionAccepted   // Session accepted for student
        case sessionRejected   // Session rejected for student
        case general           // General notification
        
        var icon: String {
            switch self {
            case .sessionRequest: return "calendar.badge.plus"
            case .sessionAccepted: return "checkmark.circle.fill"
            case .sessionRejected: return "xmark.circle.fill"
            case .general: return "bell.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .sessionRequest: return .blue
            case .sessionAccepted: return .green
            case .sessionRejected: return .red
            case .general: return .gray
            }
        }
    }
}

// Simple notification manager
class NotificationManager: ObservableObject {
    @Published var notifications: [AppNotification] = []
    
    static let shared = NotificationManager()
    
    private init() {}
    
    // Add a new notification
    func addNotification(_ notification: AppNotification) {
        notifications.insert(notification, at: 0) // Add to beginning for newest first
        print("📢 Notification added: \(notification.title) for \(notification.userEmail)")
    }
    
    // Get notifications for a specific user
    func getNotificationsForUser(email: String) -> [AppNotification] {
        return notifications.filter { $0.userEmail == email }
    }
    
    // Get unread notifications for a user
    func getUnreadNotificationsForUser(email: String) -> [AppNotification] {
        return getNotificationsForUser(email: email).filter { !$0.isRead }
    }
    
    // Mark notification as read
    func markAsRead(_ notification: AppNotification) {
        if let index = notifications.firstIndex(where: { $0.id == notification.id }) {
            notifications[index].isRead = true
        }
    }
    
    // Mark all notifications as read for a user
    func markAllAsReadForUser(email: String) {
        for i in notifications.indices {
            if notifications[i].userEmail == email {
                notifications[i].isRead = true
            }
        }
    }
    
    // Convenience methods for common notifications
    func notifyTutorOfNewRequest(tutorEmail: String, studentName: String, subject: String, sessionId: UUID) {
        let notification = AppNotification(
            title: "New Session Request",
            message: "\(studentName) wants to book a \(subject) session with you",
            type: .sessionRequest,
            userEmail: tutorEmail,
            relatedSessionId: sessionId
        )
        addNotification(notification)
    }
    
    func notifyStudentOfAcceptance(studentEmail: String, tutorName: String, subject: String, sessionId: UUID) {
        let notification = AppNotification(
            title: "Session Accepted! 🎉",
            message: "\(tutorName) accepted your \(subject) session request",
            type: .sessionAccepted,
            userEmail: studentEmail,
            relatedSessionId: sessionId
        )
        addNotification(notification)
    }
    
    func notifyStudentOfRejection(studentEmail: String, tutorName: String, subject: String, sessionId: UUID) {
        let notification = AppNotification(
            title: "Session Request Declined",
            message: "\(tutorName) declined your \(subject) session request",
            type: .sessionRejected,
            userEmail: studentEmail,
            relatedSessionId: sessionId
        )
        addNotification(notification)
    }
    
    // Get notification count for badge
    func getUnreadCount(for email: String) -> Int {
        return getUnreadNotificationsForUser(email: email).count
    }
}
