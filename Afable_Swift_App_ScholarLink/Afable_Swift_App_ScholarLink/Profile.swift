import SwiftUI

struct ProfileView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var isLoggedOut = false

    var body: some View {
            ZStack(alignment: .bottom) {
                ScrollView {
                    VStack {
                        Text("Profile")
                            .font(.largeTitle)
                            .padding()
                        // Other profile info goes here
                    }
                }
                VStack {
                    Button(action: logout) {
                        Text("Logout")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.red)
                            .cornerRadius(10)
                            .padding([.horizontal, .bottom])
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            // Optional: Navigate to LoginView on logout using NavigationLink
            .background(
                NavigationLink(destination: LoginView(), isActive: $isLoggedOut) { EmptyView() }
            )
    }

    func logout() {
        // Add your logout/auth reset logic here.
        isLoggedOut = true // Triggers navigation to LoginView
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
