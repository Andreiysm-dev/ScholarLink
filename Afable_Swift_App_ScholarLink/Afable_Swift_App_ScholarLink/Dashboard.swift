import SwiftUI
import SwiftData

struct DashboardView: View {
    @State private var selectedTab = 0
    @State private var searchText = ""
    @State private var selectedSubject = "All"
    
    // Query tutors who have completed their profile setup
    @Query(filter: #Predicate<User> { user in
        user.userRoleRaw == "tutor" && user.isProfileComplete
    }) private var tutors: [User]
    
    // Sample data for upcoming sessions and session history
    let upcomingSessions = [
        TutoringSession(tutorName: "Sarah Johnson", subject: "Mathematics", date: Date().addingTimeInterval(86400), duration: 60, price: 45.0, status: .confirmed),
        TutoringSession(tutorName: "Mike Chen", subject: "Programming", date: Date().addingTimeInterval(172800), duration: 90, price: 60.0, status: .pending)
    ]
    
    let recentSessions = [
        TutoringSession(tutorName: "Emma Wilson", subject: "Physics", date: Date().addingTimeInterval(-86400), duration: 60, price: 50.0, status: .completed),
        TutoringSession(tutorName: "David Brown", subject: "Chemistry", date: Date().addingTimeInterval(-172800), duration: 45, price: 40.0, status: .completed)
    ]
    
    let subjects = ["All", "Mathematics", "Programming", "Science", "English", "Physics", "Chemistry"]
    
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
                        if selectedTab == 0 {
                            // Dashboard Tab - Sessions and Quick Actions
                            dashboardContent
                        } else if selectedTab == 1 {
                            // Tutors Tab - Tutor Discovery
                            tutorsContent
                        } else {
                            // Analytics Tab - Learning Progress
                            analyticsContent
                        }
                        
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
                VStack(spacing: 12) {
                    Text("Find Your Perfect Tutor")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Connect with expert tutors for personalized learning")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                    
                    // Quick Stats
                    HStack(spacing: 30) {
                        StatItem(number: "\(tutors.count)", label: "Tutors")
                        StatItem(number: "\(subjects.count - 1)", label: "Subjects")
                        StatItem(number: "4.8", label: "Avg Rating")
                    }
                }
                .padding(.bottom, 20)
            }
        }
        .frame(height: 250)
        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
    }
    
    // MARK: - Tab Selection
    var tabSelection: some View {
        HStack(spacing: 40) {
            TabButton(title: "Sessions", isSelected: selectedTab == 0) {
                selectedTab = 0
            }
            
            TabButton(title: "Find Tutors", isSelected: selectedTab == 1) {
                selectedTab = 1
            }
            
            TabButton(title: "Progress", isSelected: selectedTab == 2) {
                selectedTab = 2
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }
    
    // MARK: - Dashboard Content (Sessions Tab)
    var dashboardContent: some View {
        VStack(spacing: 20) {
            // Upcoming Sessions
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Upcoming Sessions")
                        .font(.headline)
                        .fontWeight(.semibold)
                    Spacer()
                    Button("View All") {
                        // Navigate to all sessions
                    }
                    .font(.subheadline)
                    .foregroundColor(.blue)
                }
                
                if upcomingSessions.isEmpty {
                    EmptyStateView(
                        icon: "calendar.badge.plus",
                        title: "No Upcoming Sessions",
                        subtitle: "Book a session with a tutor to get started"
                    )
                } else {
                    ForEach(upcomingSessions.indices, id: \.self) { index in
                        SessionCard(session: upcomingSessions[index])
                    }
                }
            }
            
            // Quick Actions
            quickActionsSection
            
            // Recent Sessions
            VStack(alignment: .leading, spacing: 12) {
                Text("Recent Sessions")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                ForEach(recentSessions.prefix(3).indices, id: \.self) { index in
                    SessionCard(session: recentSessions[index])
                }
            }
        }
    }
    
    // MARK: - Tutors Content (Find Tutors Tab)
    var tutorsContent: some View {
        VStack(spacing: 20) {
            // Search and Filter
            VStack(spacing: 12) {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Search tutors by name or subject", text: $searchText)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                
                // Subject Filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(subjects, id: \.self) { subject in
                            SubjectFilterChip(
                                subject: subject,
                                isSelected: selectedSubject == subject
                            ) {
                                selectedSubject = subject
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            
            // Filtered Tutors
            VStack(alignment: .leading, spacing: 12) {
                Text("Available Tutors")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                if filteredTutors.isEmpty {
                    EmptyStateView(
                        icon: "person.3.sequence",
                        title: "No Tutors Found",
                        subtitle: "Try adjusting your search or filters"
                    )
                } else {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                        ForEach(filteredTutors, id: \.id) { tutor in
                            NavigationLink(destination: TutorDetailView(tutor: tutor)) {
                                TutorDiscoveryCard(tutor: tutor)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Analytics Content (Progress Tab)
    var analyticsContent: some View {
        VStack(spacing: 20) {
            // Learning Stats
            VStack(alignment: .leading, spacing: 16) {
                Text("Your Learning Journey")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                    AnalyticsCard(title: "Total Hours", value: "24.5", subtitle: "This month", color: .blue)
                    AnalyticsCard(title: "Sessions", value: "12", subtitle: "Completed", color: .green)
                    AnalyticsCard(title: "Subjects", value: "3", subtitle: "Learning", color: .orange)
                    AnalyticsCard(title: "Streak", value: "7", subtitle: "Days", color: .purple)
                }
            }
            
            // Subject Progress
            VStack(alignment: .leading, spacing: 12) {
                Text("Subject Progress")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                SubjectProgressCard(subject: "Mathematics", hoursSpent: 8.5, sessionsCount: 4, progress: 0.65)
                SubjectProgressCard(subject: "Programming", hoursSpent: 12.0, sessionsCount: 6, progress: 0.80)
                SubjectProgressCard(subject: "Physics", hoursSpent: 4.0, sessionsCount: 2, progress: 0.35)
            }
        }
    }
    
    // MARK: - Quick Actions Section
    var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Actions")
                .font(.headline)
                .fontWeight(.semibold)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                QuickActionCard(
                    icon: "magnifyingglass",
                    title: "Find Tutor",
                    subtitle: "Browse available tutors",
                    color: .blue
                ) {
                    selectedTab = 1
                }
                
                QuickActionCard(
                    icon: "calendar.badge.plus",
                    title: "Book Session",
                    subtitle: "Schedule with favorite tutor",
                    color: .green
                ) {
                    // Navigate to booking
                }
                
                QuickActionCard(
                    icon: "message",
                    title: "Messages",
                    subtitle: "Chat with tutors",
                    color: .orange
                ) {
                    // Navigate to messages
                }
                
                QuickActionCard(
                    icon: "star",
                    title: "Favorites",
                    subtitle: "Your saved tutors",
                    color: .purple
                ) {
                    // Navigate to favorites
                }
            }
        }
    }
    
    // MARK: - Computed Properties
    var filteredTutors: [User] {
        var filtered = tutors
        
        // Filter by search text
        if !searchText.isEmpty {
            filtered = filtered.filter { tutor in
                "\(tutor.firstName) \(tutor.lastName)".localizedCaseInsensitiveContains(searchText) ||
                tutor.selectedSubjects.contains { $0.localizedCaseInsensitiveContains(searchText) }
            }
        }
        
        // Filter by subject
        if selectedSubject != "All" {
            filtered = filtered.filter { tutor in
                tutor.selectedSubjects.contains(selectedSubject)
            }
        }
        
        return filtered
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

// MARK: - Session Card
struct SessionCard: View {
    let session: TutoringSession
    
    var body: some View {
        HStack(spacing: 12) {
            // Status indicator
            Circle()
                .fill(session.status.color)
                .frame(width: 12, height: 12)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(session.tutorName)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(session.subject)
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Text(session.formattedDate)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("$\(Int(session.price))")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.green)
                
                Text("\(session.duration)min")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Tutor Discovery Card
struct TutorDiscoveryCard: View {
    let tutor: User
    
    var body: some View {
        VStack(spacing: 12) {
            // Profile picture with initials
            Circle()
                .fill(Color.blue.opacity(0.2))
                .frame(width: 50, height: 50)
                .overlay(
                    Text("\(String(tutor.firstName.prefix(1)))\(String(tutor.lastName.prefix(1)))")
                        .font(.headline)
                        .foregroundColor(.blue)
                        .fontWeight(.semibold)
                )
            
            VStack(spacing: 4) {
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
            }
            
            // Rating stars (placeholder)
            HStack(spacing: 2) {
                ForEach(0..<5) { _ in
                    Image(systemName: "star.fill")
                        .font(.caption2)
                        .foregroundColor(.yellow)
                }
            }
            
            // Subject tags
            if !tutor.selectedSubjects.isEmpty {
                Text(tutor.selectedSubjects.prefix(2).joined(separator: ", "))
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .multilineTextAlignment(.center)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Additional Supporting Views

struct StatItem: View {
    let number: String
    let label: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(number)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            Text(label)
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
        }
    }
}

struct EmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.largeTitle)
                .foregroundColor(.gray.opacity(0.6))
            
            Text(title)
                .font(.headline)
                .foregroundColor(.gray)
            
            Text(subtitle)
                .font(.subheadline)
                .foregroundColor(.gray.opacity(0.8))
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

struct SubjectFilterChip: View {
    let subject: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(subject)
                .font(.caption)
                .fontWeight(.medium)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.blue : Color.gray.opacity(0.2))
                .foregroundColor(isSelected ? .white : .gray)
                .cornerRadius(20)
        }
    }
}

struct QuickActionCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct AnalyticsCard: View {
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Text(subtitle)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

struct SubjectProgressCard: View {
    let subject: String
    let hoursSpent: Double
    let sessionsCount: Int
    let progress: Double
    
    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(subject)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text("\(String(format: "%.1f", hoursSpent)) hours • \(sessionsCount) sessions")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(Int(progress * 100))%")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
                
                ProgressView(value: progress)
                    .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                    .frame(width: 80)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Data Models

struct TutoringSession {
    let tutorName: String
    let subject: String
    let date: Date
    let duration: Int // minutes
    let price: Double
    let status: SessionStatus
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

enum SessionStatus {
    case pending, confirmed, completed, cancelled
    
    var color: Color {
        switch self {
        case .pending: return .orange
        case .confirmed: return .green
        case .completed: return .blue
        case .cancelled: return .red
        }
    }
}

// MARK: - Preview

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
    }
}
