import SwiftUI

struct MessagesView: View {
    @State private var searchText = ""
    
    // Sample chat data
    let chats = [
        ChatItem(
            id: 1,
            name: "User(You)",
            lastMessage: "",
            timestamp: "",
            unreadCount: 0,
            profileImage: "person.circle.fill",
            isCurrentUser: true
        ),
        ChatItem(
            id: 2,
            name: "Voltaire Parraba",
            lastMessage: "2 new messages",
            timestamp: "Thursday",
            unreadCount: 2,
            profileImage: "person.crop.circle.fill"
        ),
        ChatItem(
            id: 3,
            name: "John Dave Briones",
            lastMessage: "2 new messages",
            timestamp: "Thursday",
            unreadCount: 2,
            profileImage: "person.crop.circle.fill"
        ),
        ChatItem(
            id: 4,
            name: "Iverson Roguel",
            lastMessage: "2 new messages",
            timestamp: "Thursday",
            unreadCount: 2,
            profileImage: "person.crop.circle.fill"
        ),
        ChatItem(
            id: 5,
            name: "Andrei Alexander Afable",
            lastMessage: "2 new messages",
            timestamp: "Thursday",
            unreadCount: 2,
            profileImage: "person.crop.circle.fill"
        ),
        ChatItem(
            id: 6,
            name: "Rovick Rumagasa",
            lastMessage: "2 new messages",
            timestamp: "Thursday",
            unreadCount: 2,
            profileImage: "person.crop.circle.fill"
        ),
        ChatItem(
            id: 7,
            name: "Dwayne \"The Rock\"",
            lastMessage: "2 new messages",
            timestamp: "Thursday",
            unreadCount: 2,
            profileImage: "person.crop.circle.fill"
        ),
        ChatItem(
            id: 8,
            name: "Anime Vanguards",
            lastMessage: "2 new messages",
            timestamp: "Thursday",
            unreadCount: 2,
            profileImage: "person.crop.circle.fill"
        )
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header Section
                headerSection
                
                // Content
                VStack(spacing: 0) {
                    // Title
                    HStack {
                        Text("Chats")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    
                    // Search Bar
                    searchBar
                    
                    // User Profile Section
                    currentUserSection
                    
                    // Chat List
                    chatListSection
                }
                .background(Color(UIColor.systemGroupedBackground))
            }
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
        }
        .frame(height: 120)
    }
    
    // MARK: - Search Bar
    var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Search", text: $searchText)
                .textFieldStyle(PlainTextFieldStyle())
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.white)
        .cornerRadius(25)
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }
    
    // MARK: - Current User Section
    var currentUserSection: some View {
        VStack(spacing: 16) {
            // Profile Picture
            Image(systemName: "person.crop.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.6))
            
            Text("User(You)")
                .font(.headline)
                .fontWeight(.semibold)
        }
        .padding(.vertical, 20)
    }
    
    // MARK: - Chat List Section
    var chatListSection: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(chats.filter { !$0.isCurrentUser }) { chat in
                    NavigationLink(destination: ChatDetailView(chat: chat)) {
                        ChatRowView(chat: chat)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Divider()
                        .padding(.leading, 80)
                }
            }
        }
    }
}

// MARK: - Chat Row View
struct ChatRowView: View {
    let chat: ChatItem
    
    var body: some View {
        HStack(spacing: 16) {
            // Profile Picture
            Image(systemName: chat.profileImage)
                .font(.system(size: 50))
                .foregroundColor(.gray.opacity(0.6))
                .frame(width: 50, height: 50)
                .background(Color.gray.opacity(0.1))
                .clipShape(Circle())
            
            // Chat Info
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(chat.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text(chat.timestamp)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                HStack {
                    Text(chat.lastMessage)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    if chat.unreadCount > 0 {
                        Text("\(chat.unreadCount)")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(minWidth: 20, minHeight: 20)
                            .background(Color.red)
                            .clipShape(Circle())
                    }
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color.white)
    }
}

// MARK: - Chat Detail View (Placeholder)
struct ChatDetailView: View {
    let chat: ChatItem
    
    var body: some View {
        VStack {
            Text("Chat with \(chat.name)")
                .font(.title)
                .fontWeight(.bold)
            
            Spacer()
            
            Text("Chat messages would appear here")
                .foregroundColor(.gray)
        }
        .navigationTitle(chat.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Data Models
struct ChatItem: Identifiable {
    let id: Int
    let name: String
    let lastMessage: String
    let timestamp: String
    let unreadCount: Int
    let profileImage: String
    var isCurrentUser: Bool = false
}

// MARK: - Preview
struct MessagesView_Previews: PreviewProvider {
    static var previews: some View {
        MessagesView()
    }
}
