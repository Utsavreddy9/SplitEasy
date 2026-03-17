//
//  TotalLogin.swift
//  SplitEasy
//
//  Created by Mohammed Mustafa Siddiq on 3/16/26.
//

import SwiftUI
import GoogleSignIn
import GoogleSignInSwift
import FirebaseAuth
import FirebaseCore

struct TotalWelcomeView: View {
    
    @State private var selectedTab: AuthTab = .login
    @State private var userIdOrEmail: String = ""
    @State private var password: String = ""
    
    @State private var loginError: String? = nil
    
    enum AuthTab {
        case login
        case signup
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                
                Spacer().frame(height: 95)
                
                Text("Welcome to\nsplitEasy")
                    .font(.system(size: 34, weight: .bold))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.black)
                
                Spacer().frame(height: 50)
                
                // Login / Signup toggle
                HStack(spacing: 0) {
                    
                    Button {
                        selectedTab = .login
                    } label: {
                        Text("Login")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.black)
                            .frame(width: 217 / 2, height: 58)
                            .background(Color.gray.opacity(0.22))
                    }
                    .overlay(
                        Rectangle()
                            .stroke(Color.black.opacity(0.5), lineWidth: 0.8)
                    )
                    
                    NavigationLink(destination: SignUpView()) {
                        Text("Signup")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.black)
                            .frame(width: 217 / 2, height: 58)
                            .background(Color.gray.opacity(0.22))
                    }
                    .overlay(
                        Rectangle()
                            .stroke(Color.black.opacity(0.5), lineWidth: 0.8)
                    )
                }
                .background(Color.gray.opacity(0.22))
                .overlay(
                    Rectangle()
                        .stroke(Color.black.opacity(0.5), lineWidth: 0.8)
                )
                .shadow(color: .black.opacity(0.18), radius: 4, x: 0, y: 4)
                
                Spacer().frame(height: 20)
                
                VStack(alignment: .leading, spacing: 22) {
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("UserId/Email")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.black)
                        
                        TextField(
                            "",
                            text: $userIdOrEmail,
                            prompt: Text("Enter your Email or user ID")
                                .foregroundColor(.black.opacity(0.9))
                                .italic()
                        )
                        .font(.system(size: 16, weight: .semibold))
                        .padding(.horizontal, 20)
                        .frame(width: 255, height: 48)
                        .background(Color.gray.opacity(0.22))
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Password")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.black)
                        
                        SecureField(
                            "",
                            text: $password,
                            prompt: Text("Enter Password")
                                .foregroundColor(.black.opacity(0.9))
                                .italic()
                        )
                        .font(.system(size: 16, weight: .semibold))
                        .padding(.horizontal, 20)
                        .frame(width: 255, height: 48)
                        .background(Color.gray.opacity(0.22))
                    }
                    
                    if let error = loginError {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.system(size: 14))
                            .frame(width: 255, alignment: .leading)
                    }
                }
                
                Spacer().frame(height: 55)
                
                // EMAIL LOGIN BUTTON
                Button {
                    loginUser()
                } label: {
                    Text("Login")
                        .font(.system(size: 18, weight: .semibold))
                        .italic()
                        .foregroundColor(.black)
                        .frame(width: 150, height: 48)
                        .background(Color.gray.opacity(0.22))
                }
                
                Spacer().frame(height: 24)
                
                // GOOGLE LOGIN BUTTON
                Button {
                    signInWithGoogle()
                } label: {
                    HStack(spacing: 10) {
                        Image("google_logo")
                            .resizable()
                            .frame(width: 20, height: 20)
                        
                        Text("Sign in with Google")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.black)
                    }
                    .frame(width: 240, height: 44)
                    .background(Color.gray.opacity(0.22))
                }
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white.ignoresSafeArea())
        }
    }
    
    // MARK: - Email/Password Login
    func loginUser() {
        loginError = nil
        
        Auth.auth().signIn(withEmail: userIdOrEmail, password: password) { result, error in
            if let error = error {
                loginError = "Login failed: \(error.localizedDescription)"
                return
            }
            
            if let user = result?.user {
                print("Logged in with email: \(user.email ?? "unknown")")
                // TODO: Navigate to your main app screen
            }
        }
    }
    
    // MARK: - Google Sign-In
    func signInWithGoogle() {
        loginError = nil
        
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootVC = scene.windows.first?.rootViewController else {
            loginError = "Unable to access root view controller."
            return
        }
        
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            loginError = "Missing Firebase ClientID."
            return
        }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        GIDSignIn.sharedInstance.signIn(withPresenting: rootVC) { result, error in
            if let error = error {
                loginError = "Google Login Error: \(error.localizedDescription)"
                return
            }
            
            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString else {
                loginError = "Google token not found."
                return
            }
            
            let accessToken = user.accessToken.tokenString
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
            
            Auth.auth().signIn(with: credential) { result, error in
                if let error = error {
                    loginError = "Firebase Google Login Error: \(error.localizedDescription)"
                    return
                }
                
                if let user = result?.user {
                    print("Logged in with Google: \(user.email ?? "unknown")")
                    // TODO: Navigate to your main app screen
                }
            }
        }
    }
}

#Preview {
    TotalWelcomeView()
}
