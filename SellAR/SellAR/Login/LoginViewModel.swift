//
//  LoginViewModel.swift
//  SellAR
//
//  Created by Mac on 11/1/24.
//

import FirebaseAuth
import FirebaseCore
import GoogleSignIn

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
    // 구글 로그인 메서드
    func loginWithGoogle(completion: @escaping (Bool) -> Void) {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        // 현재 rootViewController를 가져온다
        guard let presentingVC = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first(where: { $0.isKeyWindow })?.rootViewController else {
            print("Root View Controller를 찾을 수 없습니다.")
            completion(false)
            return
        }
        
        GIDSignIn.sharedInstance.signIn(withPresenting: presentingVC, hint: nil, additionalScopes: nil) {
            signInResult, error in
            if let error = error {
                print ("구글 로그인 실패 \(error.localizedDescription)")
                completion(false)
                return
            }
            // 사용자 인증 정보 가져오기
            guard let idToken = signInResult?.user.idToken?.tokenString,
                  let accessToken = signInResult?.user.accessToken.tokenString else {
                print("ID 토큰 또는 액세스 토큰을 가져올 수 없습니다.")
                completion(false)
                return
            }
            
            // Firebase용 Google 자격 증명 생성
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
            
            // 파이어베이스에 로그인 정보 전달
            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    print ("Firebase Google 인증 실패 \(error.localizedDescription)")
                    completion(false)
                } else if let firebaseUser = authResult?.user {
                    self.user = User(id: firebaseUser.uid, email: firebaseUser.email ?? "" , username: firebaseUser.displayName ?? "", profileImageUrl: nil)
                    print("Google 로그인 성공!")
                    completion(true)
                }
            }
        }
    }
    
    
    // 닉네임 저장 메서드
    func saveNickname(_ nickname: String) {
        guard !nickname.isEmpty else { return }
        
        // Firebase 사용자 프로필 업데이트
        let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
        changeRequest?.displayName = nickname
        changeRequest?.commitChanges { error in
            if let error = error {
                print("닉네임 저장 실패: \(error.localizedDescription)")
            } else {
                print("닉네임 저장 성공")
                // 닉네임이 성공적으로 저장된 후 사용자 정보를 업데이트합니다.
                self.user.username = nickname
            }
        }
    }
}
