//
//  LoginViewModel.swift
//  SellAR
//
//  Created by Mac on 11/1/24.
//

import FirebaseAuth
import FirebaseCore
import SwiftUI

class LoginViewModel: ObservableObject {
    @Published var user = User(id: "", email: "", username: "", profileImageUrl: nil)
    
    // 이메일과 비밀번호로 가입하는 회원가입 메서드
    func registerWithEmailPassword(email :String, password: String) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                print("회원가입 실패 \(error.localizedDescription)")
                return
            }
            // 가입 후 닉네임 설정 메서드
            if let user = authResult?.user {
                let changeRequest = user.createProfileChangeRequest()
                changeRequest.displayName = self.user.username
                changeRequest.commitChanges() { error in
                    if let error = error {
                        print("닉네임 설정 실패\(error.localizedDescription)")
                    }   else {
                        print("회원가입 성공")
                        
                    }
                }
            }
        }
    }
    // 로그인 메서드
    func loginWithEmailPassword(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                print("로그인 실패 \(error.localizedDescription)")
                return
            }
            
            if let firebaseUser = authResult?.user {
                self.user = User(id: firebaseUser.uid, email: email, username: firebaseUser.displayName ?? "", profileImageUrl: nil)
                print("로그인 성공")
            }
        }
    }
}
