//
//  FirebaseManager.swift
//  SplitEasy
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

// MARK: - User Model (Better than raw dictionary)
struct AppUser {
    let uid: String
    let email: String
    let username: String
    let createdAt: Date
}

class FirebaseManager {
    
    static let shared = FirebaseManager()
    
    private let auth = Auth.auth()
    private let db = Firestore.firestore()
    
    private init() {}
    
    // MARK: - Get Current User ID
    func getCurrentUserID() -> String? {
        return auth.currentUser?.uid
    }
    
    // MARK: - Save User Data (Signup / First Login)
    func saveUserData(email: String, username: String = "", completion: @escaping (Bool, String?) -> Void) {
        
        guard let uid = auth.currentUser?.uid else {
            completion(false, "User not logged in")
            return
        }
        
        let userData: [String: Any] = [
            "email": email,
            "username": username.isEmpty ? email.components(separatedBy: "@").first ?? "User" : username,
            "createdAt": Timestamp(date: Date())
        ]
        
        db.collection("users").document(uid).setData(userData, merge: true) { error in
            if let error = error {
                completion(false, error.localizedDescription)
            } else {
                completion(true, nil)
            }
        }
    }
    
    // MARK: - Fetch User Data (Typed Model)
    func fetchUserData(completion: @escaping (Result<AppUser, Error>) -> Void) {
        
        guard let uid = auth.currentUser?.uid else {
            completion(.failure(NSError(domain: "NoUser", code: 401)))
            return
        }
        
        db.collection("users").document(uid).getDocument { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = snapshot?.data(),
                  let email = data["email"] as? String,
                  let username = data["username"] as? String,
                  let timestamp = data["createdAt"] as? Timestamp else {
                
                completion(.failure(NSError(domain: "DataParsingError", code: 500)))
                return
            }
            
            let user = AppUser(
                uid: uid,
                email: email,
                username: username,
                createdAt: timestamp.dateValue()
            )
            
            completion(.success(user))
        }
    }
    
    // MARK: - Update Username
    func updateUsername(newUsername: String, completion: @escaping (Bool, String?) -> Void) {
        
        guard let uid = auth.currentUser?.uid else {
            completion(false, "User not logged in")
            return
        }
        
        db.collection("users").document(uid).updateData([
            "username": newUsername
        ]) { error in
            if let error = error {
                completion(false, error.localizedDescription)
            } else {
                completion(true, nil)
            }
        }
    }
    
    // MARK: - Check if User Exists (useful for Google Sign-In)
    func checkIfUserExists(completion: @escaping (Bool) -> Void) {
        
        guard let uid = auth.currentUser?.uid else {
            completion(false)
            return
        }
        
        db.collection("users").document(uid).getDocument { snapshot, _ in
            completion(snapshot?.exists ?? false)
        }
    }
    
    // MARK: - Logout
    func logout() throws {
        try auth.signOut()
    }
}
