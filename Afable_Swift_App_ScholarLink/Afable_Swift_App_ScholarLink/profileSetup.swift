import SwiftUI
import SwiftData

struct ProfileSetupView: View {
    let user: User
    
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var bio = ""
    @State private var selectedRole: UserRole = .learner
    @State private var selectedSubjects: Set<String> = []
    @State private var hourlyRate = ""
    @State private var yearsExperience = ""
    @State private var setupMessage = ""
    @State private var isSetupComplete = false
    
    @Environment(\.modelContext) private var modelContext
    
    let availableSubjects = [
        "Mathematics", "Programming", "Science", "English",
        "History", "Physics", "Chemistry", "Biology",
        "Psychology", "Economics", "Art", "Music"
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 30) {
                    // Header
                    VStack(spacing: 10) {
                        Text("Complete Your Profile")
                            .font(.title)
                            .fontWeight(.bold)
                        Text("Let's set up your ScholarLink experience")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 20)
                    
                    // Basic Info Section
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Basic Information")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        TextField("First Name", text: $firstName)
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray.opacity(0.4), lineWidth: 1))
                            .frame(maxWidth: 300)
                        
                        TextField("Last Name", text: $lastName)
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray.opacity(0.4), lineWidth: 1))
                            .frame(maxWidth: 300)
                        
                        TextField("Tell us about yourself (optional)", text: $bio, axis: .vertical)
                            .lineLimit(3...6)
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray.opacity(0.4), lineWidth: 1))
                            .frame(maxWidth: 300)
                    }
                    
                    // Role Selection
                    VStack(alignment: .leading, spacing: 15) {
                        Text("How will you use ScholarLink?")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        VStack(spacing: 10) {
                            ForEach(UserRole.allCases, id: \.self) { role in
                                RoleSelectionCard(
                                    role: role,
                                    isSelected: selectedRole == role
                                ) {
                                    selectedRole = role
                                }
                            }
                        }
                    }
                    
                    // Tutor-specific fields
                    if selectedRole == .tutor {
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Tutor Information")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            // Subject Selection
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Select your expertise areas:")
                                    .font(.subheadline)
                                    .padding(.horizontal)
                                
                                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 10) {
                                    ForEach(availableSubjects, id: \.self) { subject in
                                        SubjectTag(
                                            subject: subject,
                                            isSelected: selectedSubjects.contains(subject)
                                        ) {
                                            if selectedSubjects.contains(subject) {
                                                selectedSubjects.remove(subject)
                                            } else {
                                                selectedSubjects.insert(subject)
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                            
                            // Experience and Rate
                            HStack(spacing: 15) {
                                VStack(alignment: .leading) {
                                    Text("Years of Experience")
                                        .font(.caption)
                                    TextField("0", text: $yearsExperience)
                                        .keyboardType(.numberPad)
                                        .padding()
                                        .background(RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.gray.opacity(0.4), lineWidth: 1))
                                }
                                
                                VStack(alignment: .leading) {
                                    Text("Hourly Rate ($)")
                                        .font(.caption)
                                    TextField("25", text: $hourlyRate)
                                        .keyboardType(.decimalPad)
                                        .padding()
                                        .background(RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.gray.opacity(0.4), lineWidth: 1))
                                }
                            }
                            .frame(maxWidth: 300)
                        }
                    }
                    
                    // Complete Setup Button
                    Button(action: completeSetup) {
                        Text("Complete Setup")
                            .font(.headline)
                            .padding(.vertical, 15)
                            .padding(.horizontal, 80)
                            .foregroundColor(.white)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .padding(.top, 20)
                    
                    Text(setupMessage)
                        .foregroundColor(setupMessage.contains("Success") ? .green : .red)
                        .font(.caption)
                    
                    // Hidden NavigationLink
                    NavigationLink(
                        destination: IndexView(),
                        isActive: $isSetupComplete
                    ) {
                        EmptyView()
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal)
            }
            .onAppear {
                // Pre-fill if user already has some data
                firstName = user.firstName
                lastName = user.lastName
                bio = user.bio
                selectedRole = user.userRole
                selectedSubjects = Set(user.selectedSubjects)
            }
        }
    }
    
    func completeSetup() {
        guard !firstName.isEmpty, !lastName.isEmpty else {
            setupMessage = "Please fill in your name."
            return
        }
        
        if selectedRole == .tutor {
            guard !selectedSubjects.isEmpty else {
                setupMessage = "Please select at least one subject area."
                return
            }
            
            guard let rate = Double(hourlyRate), rate > 0 else {
                setupMessage = "Please enter a valid hourly rate."
                return
            }
            
            guard let experience = Int(yearsExperience), experience >= 0 else {
                setupMessage = "Please enter valid years of experience."
                return
            }
            
            user.hourlyRate = rate
            user.yearsExperience = experience
        }
        
        // Update user with profile data
        user.firstName = firstName.trimmingCharacters(in: .whitespacesAndNewlines)
        user.lastName = lastName.trimmingCharacters(in: .whitespacesAndNewlines)
        user.bio = bio.trimmingCharacters(in: .whitespacesAndNewlines)
        user.userRole = selectedRole
        user.selectedSubjects = Array(selectedSubjects)
        user.isProfileComplete = true
        
        do {
            try modelContext.save()
            setupMessage = "Profile setup complete!"
            isSetupComplete = true
        } catch {
            setupMessage = "Failed to save profile."
            print("Profile setup error: \(error)")
        }
    }
}

// Supporting Views
struct RoleSelectionCard: View {
    let role: UserRole
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading) {
                    Text(role.rawValue)
                        .font(.headline)
                        .foregroundColor(.primary)
                    Text(role == .learner ? "Find tutors and learn new skills" : "Share your knowledge and help others")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .blue : .gray)
            }
            .padding()
            .frame(maxWidth: 300)
            .background(RoundedRectangle(cornerRadius: 10)
                .stroke(isSelected ? Color.blue : Color.gray.opacity(0.4), lineWidth: isSelected ? 2 : 1))
        }
    }
}

struct SubjectTag: View {
    let subject: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(subject)
                .font(.caption)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.blue : Color.gray.opacity(0.2))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(15)
        }
    }
}

struct ProfileSetupView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileSetupView(user: User(email: "test@test.com", username: "test", password: "test"))
            .modelContainer(for: User.self, inMemory: true)
    }
}
