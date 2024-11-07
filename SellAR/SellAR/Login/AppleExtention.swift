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
                self.saveUserToFirestore(uid: firebaseUser.uid, email: firebaseUser.email ?? "", username: appleIDCredential.fullName?.givenName ?? "", profileImageUrl: nil)
                print("애플 로그인 성공!")
                
                self.saveUserID(firebaseUser.uid, loginMethod: "apple")
                
                if let completion = self.completionHandler {
                    completion(true)
                }
            }
        }
        
        func authorizationController(controller: ASAuthorizationController, didFailWithError error: Error){
            print("애플 로그인 실패 \(error.localizedDescription)")
            self.completionHandler?(false)
        }
    }
}
// ASAuthorizationControllerPresentationContextProviding 구현
extension LoginViewModel: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return UIApplication.shared.windows.first!.rootViewController!.view.window!
    }
}
