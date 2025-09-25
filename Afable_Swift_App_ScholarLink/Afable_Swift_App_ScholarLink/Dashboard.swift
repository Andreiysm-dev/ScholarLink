import SwiftUI

struct DashboardView: View {
    @State private var selectedTab = 0
    
    // Sample data
    let courses = [
        Course(name: "Science", instructor: "Ron Iverson Roquel", progress: 0.30, color: .blue),
        Course(name: "Python Basics", instructor: "Voltaire Parraba", progress: 0.85, color: .blue)
    ]
    
    let completedTasks = [
        CompletedTask(name: "Science", completed: 9, total: 30, averageScore: 80),
        CompletedTask(name: "Python Basics", completed: 34, total: 40, averageScore: 92)
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
                        // Course Progress Cards
                        coursesSection
                        
                        // Work Completed Section
                        workCompletedSection
                        
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
                    Text("Hi Andrei")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    // Profile Picture Placeholder
                    Circle()
                        .fill(Color.white.opacity(0.3))
                        .frame(width: 80, height: 80)
                        .overlay(
                            Image(systemName: "person.fill")
                                .font(.title)
                                .foregroundColor(.white.opacity(0.7))
                        )
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
            
            TabButton(title: "Announcement", isSelected: selectedTab == 2) {
                selectedTab = 2
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }
    
    // MARK: - Courses Section
    var coursesSection: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
            ForEach(courses.indices, id: \.self) { index in
                CourseProgressCard(course: courses[index])
            }
        }
    }
    
    // MARK: - Work Completed Section
    var workCompletedSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Work Completed")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
                Text("Average Score")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            .padding(.horizontal, 4)
            
            ForEach(completedTasks.indices, id: \.self) { index in
                CompletedTaskRow(task: completedTasks[index])
            }
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

struct CourseProgressCard: View {
    let course: Course
    
    var body: some View {
        VStack(spacing: 16) {
            // Circular Progress
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 8)
                    .frame(width: 80, height: 80)
                
                Circle()
                    .trim(from: 0, to: course.progress)
                    .stroke(course.color, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .frame(width: 80, height: 80)
                    .rotationEffect(.degrees(-90))
                
                Text("\(Int(course.progress * 100))%")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(course.color)
            }
            
            // Course Info
            VStack(spacing: 4) {
                Text(course.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                
                Text(course.instructor)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

struct CompletedTaskRow: View {
    let task: CompletedTask
    
    var body: some View {
        HStack {
            // Task Info
            VStack(alignment: .leading, spacing: 4) {
                Text(task.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text("\(task.completed)/\(task.total)")
                    .font(.title2)
                    .fontWeight(.bold)
            }
            
            Spacer()
            
            // Progress Bar
            VStack(alignment: .trailing, spacing: 8) {
                Text("\(task.averageScore)%")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Color.blue)
                    .cornerRadius(12)
                
                ProgressView(value: Double(task.averageScore) / 100.0)
                    .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                    .frame(width: 100)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Data Models

struct Course {
    let name: String
    let instructor: String
    let progress: Double
    let color: Color
}

struct CompletedTask {
    let name: String
    let completed: Int
    let total: Int
    let averageScore: Int
}

// MARK: - Preview

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
    }
}
