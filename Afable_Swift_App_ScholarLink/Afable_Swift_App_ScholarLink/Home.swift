import SwiftUI
import SwiftData

struct HomeView: View {
    // Query tutors who have completed their profile setup (fixed predicate using raw string)
    @Query(filter: #Predicate<User> { user in
        // Compare to the stored raw value (string) rather than to enum case
        user.userRoleRaw == "tutor" && user.isProfileComplete
    }) private var tutors: [User]
    
    // Query to get all users for counting
    @Query private var allUsers: [User]
    
    // State for expanding popular topics
    @State private var showAllTopics = false
    
    // All available subjects
    let allSubjects = [
        "Mathematics", "Programming", "Science", "English",
        "History", "Physics", "Chemistry", "Biology",
        "Psychology", "Economics", "Art", "Music"
    ]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 30) {
                // WELCOME SECTION
                VStack(alignment: .leading, spacing: 12) {
                    Text("Find Your Perfect Tutor")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    
                    Text("Connect with expert tutors and accelerate your learning journey")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                }
                .padding(.top, 20)
                
                // FEATURED SERVICES
                VStack(alignment: .leading, spacing: 16) {
                    Text("Learning Options")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            NavigationLink(destination: PersonalTutorListView()) {
                                ImprovedFeatureCard(
                                    title: "Personal Tutor",
                                    subtitle: "1-on-1 sessions",
                                    icon: "person.circle.fill",
                                    color: .blue
                                )
                            }
                            NavigationLink(destination: TutoringCentersView()) {
                                ImprovedFeatureCard(
                                    title: "Tutoring Centers",
                                    subtitle: "Group learning",
                                    icon: "building.2.fill",
                                    color: .green
                                )
                            }
                            NavigationLink(destination: SelfLearningView()) {
                                ImprovedFeatureCard(
                                    title: "Self Learning",
                                    subtitle: "Study resources",
                                    icon: "book.fill",
                                    color: .orange
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                }

                // POPULAR TOPICS
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("Popular Topics")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Spacer()
                        
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                showAllTopics.toggle()
                            }
                        }) {
                            Text(showAllTopics ? "Show Less" : "View All")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.horizontal)
                    
                    if showAllTopics {
                        // Grid view for all topics
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                            ForEach(allSubjects, id: \.self) { subject in
                                ImprovedTopicCard(
                                    topic: subject,
                                    tutorCount: getTutorCount(for: subject),
                                    icon: getSubjectIcon(for: subject),
                                    color: getSubjectColor(for: subject)
                                )
                            }
                        }
                        .padding(.horizontal)
                    } else {
                        // Horizontal scroll for popular topics
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(Array(allSubjects.prefix(5)), id: \.self) { subject in
                                    ImprovedTopicCard(
                                        topic: subject,
                                        tutorCount: getTutorCount(for: subject),
                                        icon: getSubjectIcon(for: subject),
                                        color: getSubjectColor(for: subject)
                                    )
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                    
                // RECOMMENDED TUTORS
                VStack(alignment: .leading, spacing: 16) {
                    Text("Recommended Tutors")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            if tutors.isEmpty {
                                EmptyTutorCard()
                            } else {
                                ForEach(tutors.prefix(5), id: \.id) { tutor in
                                    NavigationLink(destination: TutorDetailView(tutor: tutor)) {
                                        ImprovedTutorCard(tutor: tutor)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.bottom, 30)
            }
        }
    }
    
    // Helper functions for subject styling
    func getSubjectIcon(for subject: String) -> String {
        switch subject {
        case "Mathematics": return "function"
        case "Programming": return "laptopcomputer"
        case "Science": return "atom"
        case "English": return "book.closed"
        case "History": return "clock"
        case "Physics": return "waveform"
        case "Chemistry": return "testtube.2"
        case "Biology": return "leaf"
        case "Psychology": return "brain.head.profile"
        case "Economics": return "chart.line.uptrend.xyaxis"
        case "Art": return "paintbrush"
        case "Music": return "music.note"
        default: return "book"
        }
    }
    
    func getSubjectColor(for subject: String) -> Color {
        switch subject {
        case "Mathematics": return .blue
        case "Programming": return .green
        case "Science": return .purple
        case "English": return .orange
        case "History": return .brown
        case "Physics": return .indigo
        case "Chemistry": return .mint
        case "Biology": return .green
        case "Psychology": return .pink
        case "Economics": return .yellow
        case "Art": return .red
        case "Music": return .cyan
        default: return .gray
        }
    }
    
    // Function to count tutors for each subject (use allUsers to compute accurate counts)
    func getTutorCount(for subject: String) -> Int {
        return allUsers.filter { user in
            user.userRoleRaw == "tutor"
            && user.isProfileComplete
            && user.selectedSubjects.contains(subject)
        }.count
    }
}

// IMPROVED COMPONENTS

struct ImprovedFeatureCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 30))
                .foregroundColor(color)
                .frame(width: 60, height: 60)
                .background(color.opacity(0.1))
                .clipShape(Circle())
            
            VStack(spacing: 4) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .frame(width: 140, height: 120)
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}

struct ImprovedTopicCard: View {
    let topic: String
    let tutorCount: Int
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Spacer()
                
                Text("\(tutorCount)")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(topic)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text("\(tutorCount) tutors available")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(color.opacity(0.05))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(color.opacity(0.2), lineWidth: 1)
        )
    }
}

struct ImprovedTutorCard: View {
    let tutor: User
    
    var body: some View {
        VStack(spacing: 12) {
            // Profile picture with initials
            Circle()
                .fill(Color.blue.opacity(0.2))
                .frame(width: 60, height: 60)
                .overlay(
                    Text("\(String(tutor.firstName.prefix(1)))\(String(tutor.lastName.prefix(1)))")
                        .font(.headline)
                        .foregroundColor(.blue)
                        .fontWeight(.bold)
                )
            
            VStack(spacing: 6) {
                Text("\(tutor.firstName) \(tutor.lastName)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                Text("\(tutor.yearsExperience ?? 0) years exp")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Text("$\(Int(tutor.hourlyRate ?? 0))/hr")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.green)
                
                // Subject tag
                if let firstSubject = tutor.selectedSubjects.first {
                    Text(firstSubject)
                        .font(.caption2)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.blue.opacity(0.1))
                        .foregroundColor(.blue)
                        .cornerRadius(8)
                }
            }
        }
        .frame(width: 140, height: 160)
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}

struct EmptyTutorCard: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "person.badge.plus")
                .font(.system(size: 40))
                .foregroundColor(.gray.opacity(0.6))
            
            Text("No tutors yet")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.gray)
            
            Text("Be the first to register!")
                .font(.caption)
                .foregroundColor(.gray.opacity(0.8))
        }
        .frame(width: 140, height: 160)
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
}

// LEGACY COMPONENTS (kept for compatibility)

struct FeatureCard: View { // COMPONENT FOR FEATURED
    let title: String
    let imageName: String
    var body: some View {
        VStack {
            Image(imageName)
                .resizable()
                .frame(width: 140, height: 100)
                .cornerRadius(10)
            Text(title)
                .font(.subheadline)
                .foregroundColor(.primary)
        }
        .frame(width: 120)
        .padding(.horizontal, 5)
    }
}

struct TopicCard: View { // COMPONENT FOR POPULAR TOPICS
    let topic: String
    let tutorsAvailable: String
    var body: some View {
        VStack(alignment: .leading) {
            Rectangle()
                .fill(Color.blue.opacity(0.2))
                .frame(width: 140, height: 120)
                .cornerRadius(10)
            Text(topic)
                .font(.headline)
            Text(tutorsAvailable)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(width: 130)
    }
}

struct TutorCard: View { // COMPONENT FOR TUTORS (kept for compatibility)
    let name: String
    let details: String
    var body: some View {
        VStack {
            Circle()
                .fill(Color.gray.opacity(0.4))
                .frame(width: 60, height: 60)
            Text(name)
                .font(.subheadline)
                .bold()
            Text(details)
                .font(.caption)
                .multilineTextAlignment(.center)
                .padding(.bottom, 10)
        }
        .frame(width: 130)
        .background(RoundedRectangle(cornerRadius: 10).fill(Color.white).shadow(radius: 1))
    }
}

struct RealTutorCard: View { // NEW COMPONENT FOR REAL TUTORS
    let tutor: User
    
    var body: some View {
        VStack(spacing: 8) {
            // Profile picture placeholder with initials
            Circle()
                .fill(Color.blue.opacity(0.2))
                .frame(width: 60, height: 60)
                .overlay(
                    Text("\(String(tutor.firstName.prefix(1)))\(String(tutor.lastName.prefix(1)))")
                        .font(.headline)
                        .foregroundColor(.blue)
                        .fontWeight(.semibold)
                )
            
            // Tutor name
            Text("\(tutor.firstName) \(tutor.lastName)")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .lineLimit(1)
            
            // Experience
            Text("\(tutor.yearsExperience) years exp")
                .font(.caption)
                .foregroundColor(.gray)
            
            // Hourly rate (safe unwrap)
            Text("$\(Int(tutor.hourlyRate ?? 0))/hr")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.green)
            
            // Subject tags (show first 2)
            if !tutor.selectedSubjects.isEmpty {
                Text(tutor.selectedSubjects.prefix(2).joined(separator: ", "))
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(width: 130)
        .padding(.vertical, 10)
        .background(RoundedRectangle(cornerRadius: 10)
            .fill(Color.white)
            .shadow(radius: 2))
    }
}

// Placeholder views for navigation destinations
struct PersonalTutorListView: View {
    var body: some View {
        Text("Personal Tutor List")
            .navigationTitle("Personal Tutors")
    }
}

struct TutoringCentersView: View {
    var body: some View {
        Text("Tutoring Centers")
            .navigationTitle("Tutoring Centers")
    }
}

struct SelfLearningView: View {
    var body: some View {
        Text("Self Learning")
            .navigationTitle("Self Learning")
    }
}

struct TutorDetailView: View {
    let tutor: User
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Profile section
                HStack {
                    Circle()
                        .fill(Color.blue.opacity(0.2))
                        .frame(width: 80, height: 80)
                        .overlay(
                            Text("\(String(tutor.firstName.prefix(1)))\(String(tutor.lastName.prefix(1)))")
                                .font(.title)
                                .foregroundColor(.blue)
                                .fontWeight(.bold)
                        )
                    
                    VStack(alignment: .leading, spacing: 5) {
                        Text("\(tutor.firstName) \(tutor.lastName)")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("\(tutor.yearsExperience) years of experience")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        Text("$\(Int(tutor.hourlyRate ?? 0))/hour")
                            .font(.headline)
                            .foregroundColor(.green)
                    }
                    Spacer()
                }
                .padding()
                
                // Bio section
                if !tutor.bio.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("About")
                            .font(.headline)
                        Text(tutor.bio)
                            .font(.body)
                    }
                    .padding(.horizontal)
                }
                
                // Subjects section
                VStack(alignment: .leading, spacing: 10) {
                    Text("Expertise Areas")
                        .font(.headline)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 10) {
                        ForEach(tutor.selectedSubjects, id: \.self) { subject in
                            Text(subject)
                                .font(.caption)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.blue.opacity(0.1))
                                .foregroundColor(.blue)
                                .cornerRadius(15)
                        }
                    }
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Contact button
                Button(action: {
                    // Add contact functionality
                }) {
                    Text("Contact Tutor")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding()
            }
        }
        .navigationTitle("Tutor Profile")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            HomeView()
                .modelContainer(for: User.self, inMemory: true)
        }
    }
}
