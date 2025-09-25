import SwiftUI
import SwiftData

struct DashboardView: View {
    @State private var selectedTab = 0
    
    // Query tutors who have completed their profile setup
    @Query(filter: #Predicate<User> { user in
        user.userRoleRaw == "tutor" && user.isProfileComplete
    }) private var tutors: [User]
    
    // Simple sample data - just replace courses with tutors
    let availableTutors = [
        SimpleTutor(name: "Sarah Johnson", subject: "Mathematics", rating: 4.8, price: 45),
        SimpleTutor(name: "Mike Chen", subject: "Programming", rating: 4.9, price: 60)
    ]
    
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
            ForEach(availableTutors.indices, id: \.self) { index in
                SimpleTutorCard(tutor: availableTutors[index])
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

// MARK: - Simple Tutor Card (replacing course progress card)
struct SimpleTutorCard: View {
    let tutor: SimpleTutor
    
    var body: some View {
        VStack(spacing: 16) {
            // Simple rating display (replacing circular progress)
            VStack(spacing: 8) {
                Text("⭐")
                    .font(.largeTitle)
                
                Text("\(String(format: "%.1f", tutor.rating))")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
            }
            
            // Tutor Info (replacing course info)
            VStack(spacing: 4) {
                Text(tutor.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                
                Text(tutor.subject)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                
                Text("$\(tutor.price)/hr")
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
