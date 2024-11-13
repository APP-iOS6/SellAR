//
//  MyPageDataManager.swift
//  SellAR
//
//  Created by 배문성 on 11/12/24.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

class UserDataManager: ObservableObject {
    @Published var currentUser: User?
    private let db = Firestore.firestore()
    
    func fetchCurrentUser(completion: @escaping (Result<User, Error>) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "사용자가 로그인되어 있지 않습니다."])))
            return
        }
        
        db.collection("users").document(userId).getDocument { (document, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let document = document, document.exists else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "사용자 정보를 찾을 수 없습니다."])))
                return
            }
            
            do {
                let user = try document.data(as: User.self)
                DispatchQueue.main.async {
                    self.currentUser = user
                    completion(.success(user))
                }
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    func updateUserProfile(username: String, profileImageUrl: String?, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "사용자가 로그인되어 있지 않습니다."])))
            return
        }
        
        var updateData: [String: Any] = ["username": username]
        if let profileImageUrl = profileImageUrl {
            updateData["profileImageUrl"] = profileImageUrl
        }
        
        db.collection("users").document(userId).updateData(updateData) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                self.fetchCurrentUser { _ in
                    completion(.success(()))
                }
            }
        }
    }
    
    func logout(completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            try Auth.auth().signOut()
            self.currentUser = nil
            completion(.success(()))
        } catch {
            completion(.failure(error))
        }
    }
    
    func deleteAccount(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let user = Auth.auth().currentUser else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "사용자가 로그인되어 있지 않습니다."])))
            return
        }
        
        db.collection("users").document(user.uid).delete { error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            user.delete { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    self.currentUser = nil
                    completion(.success(()))
                }
            }
        }
    }
}
