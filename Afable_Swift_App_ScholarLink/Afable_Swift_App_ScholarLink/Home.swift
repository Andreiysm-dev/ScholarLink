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
    
    var body: some View {
        ScrollView {
            ZStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 20) {
                    // FEATURED
                    Spacer()
                    ScrollView(.horizontal, showsIndicators: false) {
                        VStack {
                            HStack(spacing: 16) {
                                NavigationLink(destination: PersonalTutorListView()) {
                                    FeatureCard(title: "Personal Tutor", imageName: "Personal_Tutor")
                                }
                                NavigationLink(destination: TutoringCentersView()) {
                                    FeatureCard(title: "Tutoring Centers", imageName: "Tutoring_Center")
                                }
                                NavigationLink(destination: SelfLearningView()) {
                                    FeatureCard(title: "Self Learning", imageName: "Self_Learning")
                                }
                            }
                            .padding(.horizontal)
                        }
                    }

                    // POPULAR TOPICS
                    Text("Popular Topics")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            TopicCard(topic: "Mathematics", tutorsAvailable: "\(getTutorCount(for: "Mathematics")) Tutors available")
                            TopicCard(topic: "Programming", tutorsAvailable: "\(getTutorCount(for: "Programming")) Tutors available")
                            TopicCard(topic: "Science", tutorsAvailable: "\(getTutorCount(for: "Science")) Tutors available")
                            TopicCard(topic: "English", tutorsAvailable: "\(getTutorCount(for: "English")) Tutors available")
                            TopicCard(topic: "Physics", tutorsAvailable: "\(getTutorCount(for: "Physics")) Tutors available")
                        }.padding(.horizontal)
                    }
                    
                    // RECOMMENDED TUTORS
                    Text("Recommended Tutors")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            if tutors.isEmpty {
                                Text("No tutors available yet")
                                    .foregroundColor(.gray)
                                    .padding()
                            } else {
                                ForEach(tutors.prefix(5), id: \.id) { tutor in
                                    NavigationLink(destination: TutorDetailView(tutor: tutor)) {
                                        RealTutorCard(tutor: tutor)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        }.padding(.horizontal)
                    }
                    .padding(.bottom, 50)
                }
                Spacer()
            }
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

// COMPONENTS

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
