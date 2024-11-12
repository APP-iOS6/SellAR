//
//  MyPageDataManager.swift
//  SellAR
//
//  Created by 배문성 on 11/12/24.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class MyPageDataManager: ObservableObject {
    @Published var userData: User?
    private var db = Firestore.firestore()
    
    func fetchUserData() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("No user is currently logged in.")
            return
        }
        
        db.collection("users").document(userId).getDocument { [weak self] (document, error) in
            if let error = error {
                print("Error fetching user data: \(error.localizedDescription)")
                return
            }
            
            guard let document = document, document.exists else {
                print("User document does not exist")
                return
            }
            
            do {
                let userData = try document.data(as: User.self)
                DispatchQueue.main.async {
                    self?.userData = userData
                }
            } catch {
                print("Error decoding user data: \(error.localizedDescription)")
            }
        }
    }
}

//struct User: Codable {
//    var id: String
//    var email: String
//    var username: String
//    var profileImageUrl: String?
//    var intro: String?
//    var userLocation: String?
//}
