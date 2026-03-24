
//
//  FirebaseManager.swift
//  SplitEasy
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

class FirebaseManager {
    
    static let shared = FirebaseManager()
    
    private let auth = Auth.auth()
    private let db = Firestore.firestore()
    
    private init() {}
    
    // MARK: - Get Current User
    func getCurrentUserID() -> String? {
        return auth.currentUser?.uid
    }
    
    // MARK: - Save User Data (after signup/login)
    func saveUserData(email: String, completion: @escaping (Bool, String?) -> Void) {
        
        guard let uid = auth.currentUser?.uid else {
            completion(false, "User not logged in")
            return
        }
        
        let userData: [String: Any] = [
            "email": email,
            "createdAt": Timestamp(date: Date())
        ]
        
        db.collection("users").document(uid).setData(userData) { error in
            if let error = error {
                completion(false, error.localizedDescription)
            } else {
                completion(true, nil)
            }
        }
    }
    
    // MARK: - Fetch User Data
    func fetchUserData(completion: @escaping (Result<[String: Any], Error>) -> Void) {
        
        guard let uid = auth.currentUser?.uid else { return }
        
        db.collection("users").document(uid).getDocument { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            if let data = snapshot?.data() {
                completion(.success(data))
            }
        }
    }
    
    // MARK: - Logout
    func logout() throws {
        try auth.signOut()
    }
}
