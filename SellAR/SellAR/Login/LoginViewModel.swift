//
//  LoginViewModel.swift
//  SellAR
//
//  Created by Mac on 11/1/24.
//

import AuthenticationServices
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
import FirebaseStorage
import GoogleSignIn
import SwiftUI

@objcMembers
class LoginViewModel: NSObject, ObservableObject {
    @Published var user = User(id: "", email: "", username: "", profileImageUrl: nil)
    @ObservedObject private var errorViewModel = LoginErrorViewModel()
    var completionHandler: ((Bool) -> Void)?
    
    private var db = Firestore.firestore()
    private var storage = Storage.storage().reference()
    
    
    // MARK: Firestore에 사용자 데이터를 저장하는 공통 메서드
    func saveUserToFirestore(uid: String, email: String, username: String, profileImageUrl: String?) {
        let userData: [String:Any]  = [
            "id": uid,
            "email": email,
            "username": username,
            "profileImageUrl": profileImageUrl ?? ""
        ]
        
        db.collection("users").document(uid).setData(userData) { error in
             if let error = error {
                 print("Firestore에 사용자 데이터 저장 실패 \(error.localizedDescription)")
            } else {
                 print("회원가입 성공, Firestore에 사용자 데이터 저장됨")
                 self.user = User(id: uid, email: email, username: username, profileImageUrl: profileImageUrl)
            }
        }
        
    }
    
    // MARK: 이메일과 비밀번호로 가입하는 회원가입 메서드
    func registerWithEmailPassword(email: String, password: String, username: String, profileImage: UIImage?) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                print("회원가입 실패 \(error.localizedDescription)")
                return
            }
            if let user = authResult?.user {
                self.uploadProfileImage(profileImage) { url in
                    self.saveUserToFirestore(uid: user.uid, email: email, username: username, profileImageUrl: url?.absoluteString)
                }
            }
        }
    }
    // MARK: - Firebase Storage에 이미지 업로드 메서드
    
    private func uploadProfileImage(_ image: UIImage?, completion: @escaping (URL?)-> Void) {
        guard let image = image,
              let imageData = image.jpegData(compressionQuality: 0.5) else {
            completion(nil)
            return
        }
        
        let fileName = UUID().uuidString
        let imageRef = storage.child("profileImages/\(fileName).jpg")
        
        imageRef.putData(imageData, metadata: nil) { _, error in
            if let error = error {
                print("이미지 업로드 실패: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            imageRef.downloadURL() { url, error in
                if let error = error {
                    print("이미지 가져오기 실패: \(error.localizedDescription)")
                    completion(nil)
                } else {
                    completion(url)
                }
            }
        }
    }
    
    // 로그인 메서드
    func loginWithEmailPassword(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                print("로그인 실패 \(error.localizedDescription)")
                if (error as NSError).code == AuthErrorCode.invalidEmail.rawValue {
                    self.errorViewModel.handleLoginError(.invalidEmail)
                } else if (error as NSError).code == AuthErrorCode.userNotFound.rawValue {
                    self.errorViewModel.handleLoginError(.emailNotFound)
                } else if (error as NSError).code == AuthErrorCode.wrongPassword.rawValue {
                    self.errorViewModel.handleLoginError(.incorrectPassword)
                } else {
                    self.errorViewModel.handleLoginError(nil)
                }
                return
            }
            self.errorViewModel.handleLoginError(nil)
                
                if let firebaseUser = authResult?.user {
                    self.user = User(id: firebaseUser.uid, email: email, username: firebaseUser.displayName ?? "", profileImageUrl: nil)
                    print("로그인 성공")
                }
            }
        }
    // 이메일 유효성 검사
    private func isValidEmail(_ email: String) -> Bool {
        return email.contains("@")
    }
    // MARK: 구글 로그인 메서드
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
                    self.saveUserToFirestore(uid: firebaseUser.uid, email: firebaseUser.email ?? "", username: firebaseUser.displayName ?? "", profileImageUrl: nil)
                    print("Google 로그인 및 데이터 저장 성공!")
                    completion(true)
                }
            }
        }
    }
    
    // MARK: 애플 로그인 메서드 세부 코드는 AppleExtention.swift에서 구현
    
    func loginWithApple(completion: @escaping (Bool) -> Void) {
        self.completionHandler = completion
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.performRequests()
        
        controller.delegate = self
        controller.presentationContextProvider = self
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
