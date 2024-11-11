//
//  UserViewModel.swift
//  SellAR
//
//  Created by Juno Lee on 11/11/24.
//

import Foundation
import FirebaseFirestore

class UserViewModel: ObservableObject {
    @Published var user: User?
    private var userId: String?
    
    func setUserId(_ id: String) {
        self.userId = id
        fetchUser()
    }
    
    private func fetchUser() {
        guard let userId = userId else { return }
        
        let db = Firestore.firestore()
        db.collection("users").document(userId).getDocument { document, error in
            if let document = document, document.exists {
                if let data = document.data(),
                   let email = data["email"] as? String,
                   let username = data["username"] as? String {
                    DispatchQueue.main.async {
                        self.user = User(id: userId, email: email, username: username, profileImageUrl: data["profileImageUrl"] as? String)
                    }
                }
            } else {
                print("User 데이터 로드 실패: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
}
