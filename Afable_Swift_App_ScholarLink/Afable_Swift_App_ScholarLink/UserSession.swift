import SwiftUI
import SwiftData

// Simple user session manager
class UserSession: ObservableObject {
    @Published var currentUser: User?
    @Published var isLoggedIn: Bool = false
    
    static let shared = UserSession()
    
    private init() {}
    
    func login(user: User) {
        self.currentUser = user
        self.isLoggedIn = true
    }
    
    func logout() {
        self.currentUser = nil
        self.isLoggedIn = false
    }
    
    var isCurrentUserTutor: Bool {
        return currentUser?.userRoleRaw == "tutor"
    }
    
    var isCurrentUserStudent: Bool {
        return currentUser?.userRoleRaw == "learner"
    }
}
