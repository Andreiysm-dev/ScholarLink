import SwiftUI
import SwiftData

// HEADER
struct HeaderView: View {
    var body: some View {
        HStack {
            HStack {
                HStack {
                    Text("Scholar")
                        .foregroundColor(.blue)
                        .font(.title)
                        .fontWeight(.bold)
                    Text("Link")
                        .foregroundColor(.black)
                        .font(.title)
                        .fontWeight(.bold)
                    Image(systemName: "graduationcap.fill")
                }
                .padding(.horizontal,15)
            }
            .background(Color.white)
            .cornerRadius(20)
            .padding(.vertical, 10)
            .padding(.horizontal)
            Spacer()
                
            HStack {
                Image(systemName: "magnifyingglass.circle.fill")
                    .foregroundColor(.white)
                    .font(.title2)
                    .background(Color.black)
                    .cornerRadius(20)
                Image(systemName: "bell.circle.fill")
                    .foregroundColor(.white)
                    .font(.title2)
                    .background(Color.black)
                    .cornerRadius(20)
            }
            .padding(.horizontal,10)
            
        }
        .background(Color.blue.shadow(radius: 100))
    }
}


//NAVIGATION OF PAGES
struct IndexView: View {
    @StateObject private var userSession = UserSession.shared
    
    var body: some View {
        VStack {
            HeaderView()
            TabView {
                HomeView()
                    .tabItem {
                        Image(systemName: "house.fill")
                        Text("Home")
                    }
                
                // Show different dashboard based on logged-in user role
                if userSession.isCurrentUserTutor {
                    SimpleTutorDashboardView()
                        .tabItem {
                            Image(systemName: "calendar.badge.clock")
                            Text("Sessions")
                        }
                } else {
                    DashboardView()
                        .tabItem {
                            Image(systemName: "book")
                            Text("Dashboard")
                        }
                }
                
                MessagesView()
                    .tabItem {
                        Image(systemName: "bubble.left")
                        Text("Messages")
                    }
                ProfileView()
                    .tabItem {
                        Image(systemName: "person.crop.circle")
                        Text("Profile")
                    }
            }
        }
    }
}

struct ContentView: View {
    var body: some View {
        LandingView()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
