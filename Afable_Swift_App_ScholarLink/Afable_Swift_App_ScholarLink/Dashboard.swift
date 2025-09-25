import SwiftUI
import SwiftData

struct DashboardView: View {
    @State private var selectedTab = 0
    
    // Query tutors who have completed their profile setup
    @Query(filter: #Predicate<User> { user in
        user.userRoleRaw == "tutor" && user.isProfileComplete
    }) private var tutors: [User]
    
    // No more hardcoded data - we'll use real tutors from SwiftData
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header Section
                headerSection
                
                // Tab Selection
                tabSelection
                
                // Content Section
                ScrollView {
                    VStack(spacing: 20) {
                        // Available Tutors (replacing course progress)
                        tutorCardsSection
                        
                        // Recent Activity (replacing work completed)
                        recentActivitySection
                        
                        Spacer(minLength: 100) // Space for tab bar
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
            .background(Color(UIColor.systemGroupedBackground))
            .ignoresSafeArea(.all, edges: .top)
        }
        .navigationBarHidden(true)
    }
    
    // MARK: - Header Section
    var headerSection: some View {
        ZStack {
            // Gradient Background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.blue.opacity(0.9),
                    Color.blue.opacity(0.7)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            VStack(spacing: 20) {
                // Top Bar
                HStack {
                    // ScholarLink Logo
                    HStack(spacing: 8) {
                        Text("Scholar")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        Text("Link")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        Image(systemName: "graduationcap.fill")
                            .foregroundColor(.white)
                            .font(.title2)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(20)
                    
                    Spacer()
                    
                    // Icons
                    HStack(spacing: 15) {
                        Button(action: {}) {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.white)
                                .font(.title3)
                                .frame(width: 35, height: 35)
                                .background(Color.white.opacity(0.2))
                                .clipShape(Circle())
                        }
                        
                        Button(action: {}) {
                            Image(systemName: "line.horizontal.3")
                                .foregroundColor(.white)
                                .font(.title3)
                                .frame(width: 35, height: 35)
                                .background(Color.white.opacity(0.2))
                                .clipShape(Circle())
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 50)
                
                // Welcome Message
                VStack(spacing: 8) {
                    Text("Hi Student")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Find tutors and track your learning")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.9))
                    
                    // Simple stats
                    Text("\(tutors.count) tutors available")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(.bottom, 30)
            }
        }
        .frame(height: 250)
        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
    }
    
    // MARK: - Tab Selection
    var tabSelection: some View {
        HStack(spacing: 40) {
            TabButton(title: "Dashboard", isSelected: selectedTab == 0) {
                selectedTab = 0
            }
            
            TabButton(title: "Tutors", isSelected: selectedTab == 1) {
                selectedTab = 1
            }
            
            TabButton(title: "Activity", isSelected: selectedTab == 2) {
                selectedTab = 2
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }
    
    // MARK: - Tutor Cards Section (replacing course progress)
    var tutorCardsSection: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
            if tutors.isEmpty {
                // Show empty state when no tutors are available
                VStack(spacing: 12) {
                    Image(systemName: "person.3")
                        .font(.largeTitle)
                        .foregroundColor(.gray.opacity(0.6))
                    
                    Text("No Tutors Available")
                        .font(.headline)
                        .foregroundColor(.gray)
                    
                    Text("Register as a tutor to appear here")
                        .font(.subheadline)
                        .foregroundColor(.gray.opacity(0.8))
                        .multilineTextAlignment(.center)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
            } else {
                ForEach(tutors, id: \.id) { tutor in
                    NavigationLink(destination: RealTutorProfileView(tutor: tutor)) {
                        RealTutorCard(tutor: tutor)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
    
    // MARK: - Recent Activity Section (replacing work completed)
    var recentActivitySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Recent Activity")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
                Text("This Week")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            .padding(.horizontal, 4)
            
            SimpleActivityRow(activity: "Mathematics session with Sarah", detail: "2 hours")
            SimpleActivityRow(activity: "Programming session with Mike", detail: "1.5 hours")
        }
    }
}

// MARK: - Supporting Views

struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .blue : .gray)
                .padding(.bottom, 8)
                .overlay(
                    Rectangle()
                        .frame(height: 2)
                        .foregroundColor(isSelected ? .blue : .clear),
                    alignment: .bottom
                )
        }
    }
}

// MARK: - Real Tutor Card (using SwiftData User model)
struct RealTutorCard: View {
    let tutor: User
    
    var body: some View {
        VStack(spacing: 16) {
            // Profile picture placeholder (replacing circular progress)
            VStack(spacing: 8) {
                Circle()
                    .fill(Color.blue.opacity(0.2))
                    .frame(width: 60, height: 60)
                    .overlay(
                        Text("\(String(tutor.firstName.prefix(1)))\(String(tutor.lastName.prefix(1)))")
                            .font(.headline)
                            .foregroundColor(.blue)
                            .fontWeight(.semibold)
                    )
                
                Text("4.8 ⭐") // Default rating for now
                    .font(.caption)
                    .foregroundColor(.orange)
            }
            
            // Tutor Info (replacing course info)
            VStack(spacing: 4) {
                Text("\(tutor.firstName) \(tutor.lastName)")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .lineLimit(1)
                
                Text(tutor.selectedSubjects.first ?? "General")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                
                Text("$\(Int(tutor.hourlyRate ?? 0))/hr")
                    .font(.caption)
                    .foregroundColor(.green)
                    .fontWeight(.medium)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

// MARK: - Simple Activity Row (replacing completed task row)
struct SimpleActivityRow: View {
    let activity: String
    let detail: String
    
    var body: some View {
        HStack {
            // Activity Info
            VStack(alignment: .leading, spacing: 4) {
                Text(activity)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text("Completed")
                    .font(.caption)
                    .foregroundColor(.green)
            }
            
            Spacer()
            
            // Simple detail
            Text(detail)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.blue)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Real Tutor Profile View (using SwiftData User model)
struct RealTutorProfileView: View {
    let tutor: User
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Profile Header
                VStack(spacing: 16) {
                    // Large profile picture placeholder with initials
                    Circle()
                        .fill(Color.blue.opacity(0.2))
                        .frame(width: 120, height: 120)
                        .overlay(
                            Text("\(String(tutor.firstName.prefix(1)))\(String(tutor.lastName.prefix(1)))")
                                .font(.system(size: 50))
                                .foregroundColor(.blue)
                                .fontWeight(.bold)
                        )
                    
                    VStack(spacing: 8) {
                        Text("\(tutor.firstName) \(tutor.lastName)")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text(tutor.selectedSubjects.first ?? "General Tutor")
                            .font(.headline)
                            .foregroundColor(.blue)
                        
                        HStack(spacing: 16) {
                            Text("4.8 ⭐") // Default rating for now
                                .font(.subheadline)
                                .foregroundColor(.orange)
                            
                            Text("$\(Int(tutor.hourlyRate ?? 0))/hour")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.green)
                        }
                    }
                }
                .padding()
                
                // About Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("About")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text(tutor.bio.isEmpty ? "Experienced tutor with a passion for helping students achieve their goals. I focus on making complex concepts easy to understand." : tutor.bio)
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                
                // Subjects Section
                if !tutor.selectedSubjects.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Expertise Areas")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
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
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                }
                
                // Experience Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Experience")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    VStack(spacing: 8) {
                        ExperienceRow(title: "Years Teaching", value: "\(tutor.yearsExperience ?? 0)+ years")
                        ExperienceRow(title: "Hourly Rate", value: "$\(Int(tutor.hourlyRate ?? 0))")
                        ExperienceRow(title: "Profile Complete", value: tutor.isProfileComplete ? "Yes" : "No")
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                
                // Book Session Button
                Button(action: {
                    // TODO: Add booking functionality
                }) {
                    Text("Book a Session")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
                
                Spacer()
            }
        }
        .navigationTitle("Tutor Profile")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Experience Row Component
struct ExperienceRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Data Models

struct SimpleTutor {
    let name: String
    let subject: String
    let rating: Double
    let price: Int
}

// MARK: - Preview

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
    }
}
