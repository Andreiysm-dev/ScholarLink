import SwiftUI

struct NotificationView: View {
    @StateObject private var notificationManager = NotificationManager.shared
    @Environment(\.dismiss) private var dismiss
    
    var currentUser: User? {
        return UserSession.shared.currentUser
    }
    
    var userNotifications: [AppNotification] {
        guard let user = currentUser else { return [] }
        return notificationManager.getNotificationsForUser(email: user.email)
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if userNotifications.isEmpty {
                    // Empty state
                    VStack(spacing: 16) {
                        Image(systemName: "bell.slash")
                            .font(.system(size: 60))
                            .foregroundColor(.gray.opacity(0.6))
                        
                        Text("No Notifications")
                            .font(.headline)
                            .foregroundColor(.gray)
                        
                        Text("You'll see session updates and other important information here.")
                            .font(.subheadline)
                            .foregroundColor(.gray.opacity(0.8))
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    
                    Spacer()
                } else {
                    List {
                        ForEach(userNotifications) { notification in
                            NotificationRow(notification: notification)
                                .onTapGesture {
                                    notificationManager.markAsRead(notification)
                                }
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("Notifications")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
                
                if !userNotifications.isEmpty {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Mark All Read") {
                            if let user = currentUser {
                                notificationManager.markAllAsReadForUser(email: user.email)
                            }
                        }
                        .font(.caption)
                    }
                }
            }
        }
    }
}

struct NotificationRow: View {
    let notification: AppNotification
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon
            Image(systemName: notification.type.icon)
                .font(.title2)
                .foregroundColor(notification.type.color)
                .frame(width: 30)
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(notification.title)
                    .font(.headline)
                    .fontWeight(notification.isRead ? .medium : .semibold)
                    .foregroundColor(.primary)
                
                Text(notification.message)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                Text(notification.timestamp.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            // Unread indicator
            if !notification.isRead {
                Circle()
                    .fill(notification.type.color)
                    .frame(width: 8, height: 8)
            }
        }
        .padding(.vertical, 8)
        .background(notification.isRead ? Color.clear : notification.type.color.opacity(0.05))
        .cornerRadius(8)
    }
}

struct NotificationView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationView()
    }
}
