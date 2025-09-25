import SwiftUI
import SwiftData

struct BookSessionView: View {
    let tutor: User
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var allUsers: [User]
    
    @State private var selectedSubject = ""
    @State private var selectedDate = Date()
    @State private var duration = 60 // minutes
    @State private var message = ""
    @State private var showingConfirmation = false
    @State private var bookingMessage = ""
    
    // Get current logged-in user
    var currentUser: User? {
        return UserSession.shared.currentUser
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Tutor Info Header
                    HStack {
                        Circle()
                            .fill(Color.blue.opacity(0.2))
                            .frame(width: 60, height: 60)
                            .overlay(
                                Text("\(String(tutor.firstName.prefix(1)))\(String(tutor.lastName.prefix(1)))")
                                    .font(.headline)
                                    .foregroundColor(.blue)
                                    .fontWeight(.bold)
                            )
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(tutor.firstName) \(tutor.lastName)")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            Text("$\(Int(tutor.hourlyRate ?? 0))/hour")
                                .font(.subheadline)
                                .foregroundColor(.green)
                        }
                        
                        Spacer()
                    }
                    .padding()
                    .background(Color.gray.opacity(0.05))
                    .cornerRadius(12)
                    
                    // Booking Form
                    VStack(alignment: .leading, spacing: 20) {
                        // Subject Selection
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Subject")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            Menu {
                                ForEach(tutor.selectedSubjects, id: \.self) { subject in
                                    Button(subject) {
                                        selectedSubject = subject
                                    }
                                }
                            } label: {
                                HStack {
                                    Text(selectedSubject.isEmpty ? "Select a subject" : selectedSubject)
                                        .foregroundColor(selectedSubject.isEmpty ? .gray : .primary)
                                    Spacer()
                                    Image(systemName: "chevron.down")
                                        .foregroundColor(.gray)
                                }
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                            }
                        }
                        
                        // Date & Time Selection
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Preferred Date & Time")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            DatePicker("Session Date", selection: $selectedDate, in: Date()...)
                                .datePickerStyle(CompactDatePickerStyle())
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                        }
                        
                        // Duration Selection
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Duration")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            Picker("Duration", selection: $duration) {
                                Text("30 minutes").tag(30)
                                Text("60 minutes").tag(60)
                                Text("90 minutes").tag(90)
                                Text("120 minutes").tag(120)
                            }
                            .pickerStyle(SegmentedPickerStyle())
                        }
                        
                        // Message
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Message (Optional)")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            TextField("Tell the tutor what you'd like to focus on...", text: $message, axis: .vertical)
                                .lineLimit(3...6)
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                        }
                        
                        // Cost Summary
                        VStack(spacing: 8) {
                            HStack {
                                Text("Duration:")
                                Spacer()
                                Text("\(duration) minutes")
                            }
                            
                            HStack {
                                Text("Rate:")
                                Spacer()
                                Text("$\(Int(tutor.hourlyRate ?? 0))/hour")
                            }
                            
                            Divider()
                            
                            HStack {
                                Text("Total Cost:")
                                    .fontWeight(.semibold)
                                Spacer()
                                Text("$\(Int(calculateTotalCost()))")
                                    .fontWeight(.semibold)
                                    .foregroundColor(.green)
                            }
                        }
                        .padding()
                        .background(Color.blue.opacity(0.05))
                        .cornerRadius(8)
                    }
                    
                    // Book Session Button
                    Button(action: bookSession) {
                        Text("Request Session")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(selectedSubject.isEmpty ? Color.gray : Color.blue)
                            .cornerRadius(12)
                    }
                    .disabled(selectedSubject.isEmpty)
                    
                    Text(bookingMessage)
                        .foregroundColor(bookingMessage.contains("Success") ? .green : .red)
                        .font(.caption)
                }
                .padding()
            }
            .navigationTitle("Book Session")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Session Requested", isPresented: $showingConfirmation) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("Your session request has been sent to \(tutor.firstName). They will respond soon!")
            }
        }
    }
    
    private func calculateTotalCost() -> Double {
        let hourlyRate = tutor.hourlyRate ?? 0
        let hours = Double(duration) / 60.0
        return hourlyRate * hours
    }
    
    private func bookSession() {
        guard let student = currentUser else {
            bookingMessage = "Error: No student account found"
            return
        }
        
        guard !selectedSubject.isEmpty else {
            bookingMessage = "Please select a subject"
            return
        }
        
        // Create session request
        let sessionRequest = SessionRequest(
            studentId: student.id.hashValue.description,
            tutorId: tutor.id.hashValue.description,
            subject: selectedSubject,
            requestedDate: selectedDate,
            duration: duration,
            message: message,
            hourlyRate: tutor.hourlyRate ?? 0
        )
        
        modelContext.insert(sessionRequest)
        
        do {
            try modelContext.save()
            bookingMessage = "Success! Session request sent."
            showingConfirmation = true
        } catch {
            bookingMessage = "Failed to send request. Please try again."
            print("Booking error: \(error)")
        }
    }
}

struct BookSessionView_Previews: PreviewProvider {
    static var previews: some View {
        BookSessionView(tutor: User(email: "tutor@test.com", username: "tutor", password: "test"))
            .modelContainer(for: [User.self, SessionRequest.self], inMemory: true)
    }
}
