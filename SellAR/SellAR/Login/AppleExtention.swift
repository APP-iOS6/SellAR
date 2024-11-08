//
//  AppleExtention.swift
//  SellAR
//
//  Created by Mac on 11/4/24.
//

import AuthenticationServices
import FirebaseAuth
import FirebaseCore

// MARK: - 애플 로그인을 위한 ASAuthorizationControllerDelegate
extension LoginViewModel: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            print("애플 아이디 인증 가져오기 실패")
            return
        }
        
        guard let idToken = appleIDCredential.identityToken,
              let tokenString = String(data: idToken, encoding: .utf8) else {
            print("ID 토큰 가져오기 실패")
            return
        }
        
        let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: tokenString, accessToken: nil)
        
        Auth.auth().signIn(with: credential) { authResult, error in
            if let error = error {
                print("Firebase 애플 인증 실패 \(error.localizedDescription)")
                self.completionHandler?(false)
                return
            }
            
            if let firebaseUser = authResult?.user {
                self.getUserDocument(uid: firebaseUser.uid) { document, error in
                    if let document = document, document.exists {
                        // 기존 사용자의 경우
                        print("애플로 로그인 성공")
                        let email = document.get("email") as? String ?? ""
                        self.user.email = email  // 사용자 이메일 업데이트
                        self.saveUserID(firebaseUser.uid, loginMethod: "apple")
                        self.isMainViewActive = true
                        self.completionHandler?(true)
                    } else {
                        // 새로운 사용자의 경우
                        var email = ""
                        
                        if let appleEmail = appleIDCredential.email {
                            email = appleEmail
                        } else {
                            email = firebaseUser.email ?? ""
                        }
                        
                        var username = "New User"
                        if let fullName = appleIDCredential.fullName {
                            let givenName = fullName.givenName ?? ""
                            let familyName = fullName.familyName ?? ""
                            username = [givenName, familyName].filter { !$0.isEmpty }.joined(separator: " ")
                        }
                        
                        print("저장될 이메일: \(email)")
                        
                        self.saveUserToFirestore(uid: firebaseUser.uid,
                                              email: email,
                                              username: username,
                                              profileImageUrl: nil)
                        
                        self.user.email = email
                        self.user.username = username
                        
                        print("회원가입 성공, Firestore에 사용자 데이터 저장됨")
                        self.saveUserID(firebaseUser.uid, loginMethod: "apple")
                        self.isNicknameEntryActive = true
                        self.completionHandler?(true)
                    }
                }
            }
        }
    }
        func authorizationController(controller: ASAuthorizationController, didFailWithError error: Error){
            print("애플 로그인 실패 \(error.localizedDescription)")
            self.completionHandler?(false)
        }
    }
// ASAuthorizationControllerPresentationContextProviding 구현
extension LoginViewModel: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return UIApplication.shared.windows.first!.rootViewController!.view.window!
    }
}
