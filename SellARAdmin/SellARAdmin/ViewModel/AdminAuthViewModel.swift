//
//  Untitled.swift
//  SellARAdmin
//
//  Created by 박범규 on 11/22/24.
//

import SwiftUI
import Firebase
import FirebaseAuth

// MARK: - Admin Authentication Model
class AdminAuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var errorMessage: String?
    private let adminEmails = ["admin@sellar.com"] // 허용된 관리자 이메일 목록
    
    func signIn(email: String, password: String) {
        guard adminEmails.contains(email) else {
            self.errorMessage = "관리자 권한이 없는 계정입니다."
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                self?.errorMessage = error.localizedDescription
                self?.isAuthenticated = false
                return
            }
            
            // 관리자 권한 확인
            self?.checkAdminPrivileges(userId: result?.user.uid ?? "")
        }
    }
    
    private func checkAdminPrivileges(userId: String) {
        let db = Firestore.firestore()
        db.collection("admins").document(userId).getDocument { [weak self] snapshot, error in
            if let data = snapshot?.data(), data["isAdmin"] as? Bool == true {
                self?.isAuthenticated = true
            } else {
                self?.errorMessage = "관리자 권한이 없습니다."
                self?.isAuthenticated = false
                try? Auth.auth().signOut()
            }
        }
    }
    
    func signOut() {
        try? Auth.auth().signOut()
        isAuthenticated = false
    }
}
