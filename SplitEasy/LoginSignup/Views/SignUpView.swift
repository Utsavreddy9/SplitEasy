//
//  SignUpView.swift
//  SplitEasy
//
//  Created by Mohammed Mustafa Siddiq on 3/16/26.
//

import SwiftUI
import FirebaseAuth
import FirebaseCore

struct SignUpView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var email: String = ""
    @State private var phoneNumber: String = ""
    @State private var userName: String = ""
    @State private var password: String = ""
    @State private var reenterPassword: String = ""
    
    @State private var signupError: String? = nil
    @State private var signupSuccess: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.white
                    .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        
                        Spacer()
                            .frame(height: 70)
                        
                        HStack {
                            Spacer()
                            
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 82, height: 82)
                                .foregroundColor(Color.black.opacity(0.85))
                            
                            Spacer()
                        }
                        
                        Spacer()
                            .frame(height: 50)
                        
                        VStack(spacing: 22) {
                            
                            HStack(spacing: 14) {
                                customField(
                                    title: "First Name",
                                    placeholder: "Enter first name",
                                    text: $firstName
                                )
                                
                                customField(
                                    title: "Last Name",
                                    placeholder: "Enter last name",
                                    text: $lastName
                                )
                            }
                            
                            customField(
                                title: "Email",
                                placeholder: "Enter your email",
                                text: $email,
                                keyboard: .emailAddress,
                                autocapitalization: .never
                            )
                            
                            customField(
                                title: "Phone No",
                                placeholder: "Enter your phone number",
                                text: $phoneNumber,
                                keyboard: .phonePad
                            )
                            
                            customField(
                                title: "UserName",
                                placeholder: "Choose a username",
                                text: $userName,
                                autocapitalization: .never
                            )
                            
                            customSecureField(
                                title: "Create Password",
                                placeholder: "Enter password",
                                text: $password
                            )
                            
                            customSecureField(
                                title: "Reenter Password",
                                placeholder: "Reenter password",
                                text: $reenterPassword
                            )
                        }
                        .frame(maxWidth: 320)
                        
                        Spacer()
                            .frame(height: 22)
                        
                        if let error = signupError {
                            Text(error)
                                .foregroundColor(.red)
                                .font(.system(size: 14, weight: .medium))
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: 320)
                                .padding(.horizontal, 12)
                        }
                        
                        if signupSuccess {
                            Text("Account created successfully! You can login now.")
                                .foregroundColor(.green)
                                .font(.system(size: 14, weight: .medium))
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: 320)
                                .padding(.horizontal, 12)
                        }
                        
                        Spacer()
                            .frame(height: 28)
                        
                        Button {
                            signupUser()
                        } label: {
                            Text("Register")
                                .font(.system(size: 18, weight: .semibold))
                                .italic()
                                .foregroundColor(.black)
                                .frame(width: 160, height: 46)
                                .background(Color.gray.opacity(0.22))
                        }
                        
                        Spacer()
                            .frame(height: 60)
                    }
                    .frame(maxWidth: .infinity)
                }
                .scrollDismissesKeyboard(.interactively)
            }
            .navigationBarBackButtonHidden(false)
        }
    }
    
    // MARK: - Reusable Text Field
    private func customField(
        title: String,
        placeholder: String,
        text: Binding<String>,
        keyboard: UIKeyboardType = .default,
        autocapitalization: TextInputAutocapitalization = .words
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 17, weight: .bold))
                .italic()
                .foregroundColor(.black)
            
            TextField(
                "",
                text: text,
                prompt: Text(placeholder)
                    .foregroundColor(.black.opacity(0.55))
                    .italic()
            )
            .font(.system(size: 16, weight: .medium))
            .foregroundColor(.black)
            .padding(.horizontal, 14)
            .frame(height: 46)
            .background(Color.gray.opacity(0.22))
            .textInputAutocapitalization(autocapitalization)
            .autocorrectionDisabled(true)
            .keyboardType(keyboard)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - Reusable Secure Field
    private func customSecureField(
        title: String,
        placeholder: String,
        text: Binding<String>
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 17, weight: .bold))
                .italic()
                .foregroundColor(.black)
            
            SecureField(
                "",
                text: text,
                prompt: Text(placeholder)
                    .foregroundColor(.black.opacity(0.55))
                    .italic()
            )
            .font(.system(size: 16, weight: .medium))
            .foregroundColor(.black)
            .padding(.horizontal, 14)
            .frame(height: 46)
            .background(Color.gray.opacity(0.22))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - Firebase Sign Up
    func signupUser() {
        signupError = nil
        signupSuccess = false
        
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedFirstName = firstName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedLastName = lastName.trimmingCharacters(in: .whitespacesAndNewlines)
        let fullName = "\(trimmedFirstName) \(trimmedLastName)".trimmingCharacters(in: .whitespaces)
        
        guard !trimmedFirstName.isEmpty,
              !trimmedLastName.isEmpty,
              !trimmedEmail.isEmpty,
              !userName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !password.isEmpty,
              !reenterPassword.isEmpty else {
            signupError = "Please fill in all required fields."
            return
        }
        
        guard password == reenterPassword else {
            signupError = "Passwords do not match."
            return
        }
        
        guard password.count >= 5 else {
            signupError = "Password must be at least 6 characters."
            return
        }
        
        Auth.auth().createUser(withEmail: trimmedEmail, password: password) { result, error in
            if let error = error {
                signupError = "Sign Up Error: \(error.localizedDescription)"
                return
            }
            
            if let user = result?.user {
                let changeRequest = user.createProfileChangeRequest()
                changeRequest.displayName = fullName
                
                changeRequest.commitChanges { err in
                    if let err = err {
                        signupError = "Failed to set display name: \(err.localizedDescription)"
                        return
                    }
                    
                    signupSuccess = true
                    print("User created: \(user.email ?? "unknown")")

                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        dismiss()}
                }
            }
        }
    }
}

#Preview {
    SignUpView()
}
