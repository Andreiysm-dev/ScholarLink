import SwiftData
import Foundation

enum UserRole: String, CaseIterable, Codable {
    case learner = "learner"
    case tutor = "tutor"
}

@Model
class User {
    var email: String
    var username: String
    var password: String
    var dateCreated: Date

    var firstName: String
    var lastName: String
    var bio: String
    var isProfileComplete: Bool

    // Stored raw role string for SwiftData
    var userRoleRaw: String

    // Computed enum role
    var userRole: UserRole {
        get { UserRole(rawValue: userRoleRaw) ?? .learner }
        set { userRoleRaw = newValue.rawValue }
    }

    var selectedSubjects: [String]
    var hourlyRate: Double?        // ✅ optional
    var yearsExperience: Int?      // ✅ optional

    init(email: String, username: String, password: String) {
        self.email = email
        self.username = username
        self.password = password
        self.dateCreated = Date()

        self.firstName = ""
        self.lastName = ""
        self.bio = ""
        self.isProfileComplete = false
        self.userRoleRaw = UserRole.learner.rawValue
        self.selectedSubjects = []
        self.hourlyRate = nil
        self.yearsExperience = nil
    }
}
