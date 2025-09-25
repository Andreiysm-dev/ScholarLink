import SwiftUI
import SwiftData

struct RegisterView: View {
    @State private var email = ""
    @State private var username = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var registrationMessage = ""
    @State private var isRegistered = false
    @State private var registeredUser: User?

    @Environment(\.modelContext) private var modelContext
    @Query private var users: [User]

    var body: some View {
        ScrollView {
            VStack {
                Spacer(minLength: 90)
                
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
                        .resizable()
                        .scaledToFit()
                        .frame(width: 35, height: 35)
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom, 20)

                VStack(spacing: 30) {
                    Text("Create your account")
                        .font(.headline)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 10)

                    TextField("Enter your email", text: $email)
                        .autocapitalization(.none)
                        .multilineTextAlignment(.center)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.gray.opacity(0.4), lineWidth: 1))
                        .frame(maxWidth: 300)

                    TextField("Enter your Username", text: $username)
                        .autocapitalization(.none)
                        .multilineTextAlignment(.center)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.gray.opacity(0.4), lineWidth: 1))
                        .frame(maxWidth: 300)

                    SecureField("Enter your password", text: $password)
                        .multilineTextAlignment(.center)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.4), lineWidth: 1))
                        .frame(maxWidth: 300)

                    SecureField("Re-enter your password", text: $confirmPassword)
                        .multilineTextAlignment(.center)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.4), lineWidth: 1))
                        .frame(maxWidth: 300)

                    Button(action: registerUser) {
                        Text("Register")
                            .font(.headline)
                            .padding(.vertical, 13)
                            .padding(.horizontal, 130)
                            .foregroundColor(.white)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }

                    Text(registrationMessage)
                        .foregroundColor(registrationMessage == "User registered successfully!" ? .green : .red)
                        .font(.caption)

                    HStack {
                        Text("Already have an account?")
                            .font(.subheadline)
                            .fontWeight(.regular)
                            .foregroundColor(.gray.opacity(0.8))

                        NavigationLink(destination: LoginView()) {
                            Text("Login")
                                .foregroundColor(.blue)
                        }
                        .font(.headline)
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .frame(maxWidth: .infinity, minHeight: 350, alignment: .center)
        }
        .navigationDestination(isPresented: $isRegistered) {
            if let user = registeredUser {
                ProfileSetupView(user: user)
            }
        }
    }

    func registerUser() {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let trimmedUsername = username.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedConfirmPassword = confirmPassword.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedEmail.isEmpty, !trimmedUsername.isEmpty, !trimmedPassword.isEmpty else {
            registrationMessage = "Please fill in all fields."
            return
        }

        guard trimmedPassword == trimmedConfirmPassword else {
            registrationMessage = "Passwords do not match."
            return
        }

        let emailExists = users.contains { user in
            user.email.lowercased() == trimmedEmail
        }
        
        if emailExists {
            registrationMessage = "This email is already registered."
            return
        }

        let usernameExists = users.contains { user in
            user.username.lowercased() == trimmedUsername.lowercased()
        }
        
        if usernameExists {
            registrationMessage = "This username is already taken."
            return
        }

        let newUser = User(email: trimmedEmail, username: trimmedUsername, password: trimmedPassword)
        modelContext.insert(newUser)

        do {
            try modelContext.save()
            registrationMessage = "User registered successfully!"
            registeredUser = newUser
            isRegistered = true
        } catch {
            registrationMessage = "Failed to save user."
            print("Save error: \(error)")
        }
    }
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView()
            .modelContainer(for: User.self, inMemory: true)
    }
}
