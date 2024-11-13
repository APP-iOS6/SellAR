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
    @Published var isMainViewActive = false
    @Published var isNicknameEntryActive = false
    @Published var isLoggedIn = false
    @Published var userID: String? = nil
    
    @ObservedObject private var errorViewModel = LoginErrorViewModel()
    var completionHandler: ((Bool) -> Void)?
    
    private var db = Firestore.firestore()
    private var storage = Storage.storage().reference()
    
    private var isLoginPrinted = false
    
    // MARK: UserDefaults에서 userID 불러오기
    override init() {
            super.init()
            
                if let savedUserID = UserDefaults.standard.string(forKey: "userID"), user.id.isEmpty, !isLoginPrinted {
                    self.user.id = savedUserID
                    print("유지된 로그인: userID = \(savedUserID)")
                    isLoginPrinted = true
                }
                
                if let savedGoogleUserID = UserDefaults.standard.string(forKey: "googleUserID"), user.id.isEmpty, !isLoginPrinted {
                    self.user.id = savedGoogleUserID
                    print("유지된 구글 로그인: userID = \(savedGoogleUserID)")
                    isLoginPrinted = true
                }
                
                if let savedAppleUserID = UserDefaults.standard.string(forKey: "appleUserID"), user.id.isEmpty, !isLoginPrinted {
                    self.user.id = savedAppleUserID
                    print("유지된 애플 로그인: userID = \(savedAppleUserID)")
                    isLoginPrinted = true
                }
            }
    // 로그인 성공 시 userID 저장
    func saveUserID(_ userID: String, loginMethod: String) {
        switch loginMethod {
        case "email":
            // 이메일로 로그인 시 구글과 애플 ID 지우기
            UserDefaults.standard.removeObject(forKey: "googleUserID")
            UserDefaults.standard.removeObject(forKey: "appleUserID")
        case "google":
            // 구글로 로그인 시 이메일과 애플 ID 지우기
            UserDefaults.standard.removeObject(forKey: "userID")
            UserDefaults.standard.removeObject(forKey: "appleUserID")
        case "apple":
            // 애플로 로그인 시 이메일과 구글 ID 지우기
            UserDefaults.standard.removeObject(forKey: "userID")
            UserDefaults.standard.removeObject(forKey: "googleUserID")
        default:
            break
        }
        
        // 새로운 로그인 방식의 ID 저장
        self.user.id = userID
        UserDefaults.standard.set(userID, forKey: "userID")
    }

    
    // MARK: Firestore에 사용자 데이터를 저장하는 공통 메서드
    func saveUserToFirestore(uid: String, email: String, username: String, profileImageUrl: String?) {
        print("Firestore에 저장할 이메일: \(email)")
        let userData: [String:Any]  = [
            "id": uid,
            "email": email,
            "username": username,
            "profileImageUrl": profileImageUrl ?? ""
        ]
        
        print("저장할 데이터:", userData)
            
            db.collection("users").document(uid).setData(userData) { error in
                if let error = error {
                    print("Firestore에 사용자 데이터 저장 실패: \(error.localizedDescription)")
                } else {
                    print("Firestore에 사용자 데이터 저장 성공")
                    DispatchQueue.main.async {
                        self.user = User(
                            id: uid,
                            email: email,
                            username: username,
                            profileImageUrl: profileImageUrl
                        )
                    }
                }
            }
        }
    
    // MARK: 이메일과 비밀번호로 가입하는 회원가입 메서드
    func registerWithEmailPassword(email: String, password: String, username: String, profileImage: UIImage?, completion: @escaping (Bool) -> Void = { _ in }) {
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            guard let self = self else { return }
            
            if let error = error {
                print("회원가입 실패: \(error.localizedDescription)")
                completion(false)
                return
            }
            
            if let user = authResult?.user {
                if let profileImage = profileImage {
                    print("프로필 이미지 업로드 시작")
                    self.uploadProfileImage(profileImage) { [weak self] url in
                        guard let self = self else { return }
                        
                        print("이미지 업로드 완료, URL 저장 시작:", url?.absoluteString ?? "URL 없음")
                        let imageUrl = url?.absoluteString
                        
                        DispatchQueue.main.async {
                            self.saveUserToFirestore(
                                uid: user.uid,
                                email: email,
                                username: username,
                                profileImageUrl: imageUrl
                            )
                            completion(true)
                        }
                    }
                } else {
                    self.saveUserToFirestore(
                        uid: user.uid,
                        email: email,
                        username: username,
                        profileImageUrl: nil
                    )
                    completion(true)
                }
            }
        }
    }

    func uploadProfileImage(_ image: UIImage?, completion: @escaping (URL?) -> Void) {
        guard let image = image,
              let imageData = image.jpegData(compressionQuality: 0.5) else {
            print("이미지 변환 실패")
            completion(nil)
            return
        }
        
        let fileName = UUID().uuidString
        let imageRef = storage.child("profileImages/\(fileName).jpg")
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        imageRef.putData(imageData, metadata: metadata) { metadata, error in
            if let error = error {
                print("이미지 업로드 실패: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            imageRef.downloadURL { url, error in
                if let error = error {
                    print("다운로드 URL 가져오기 실패: \(error.localizedDescription)")
                    completion(nil)
                } else if let url = url {
                    print("다운로드 URL 생성 성공:", url.absoluteString)
                    completion(url)
                }
            }
        }
    }
    
    // 로그인 메서드
    func loginWithEmailPassword(email: String, password: String, completion: @escaping (Bool) -> Void = { _ in }) {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                print("로그인 실패 \(error.localizedDescription)")
                
                if (error as NSError).code == AuthErrorCode.invalidEmail.rawValue {
                    self.errorViewModel.handleLoginError(.emailNotFound)
                } else if (error as NSError).code == AuthErrorCode.userNotFound.rawValue {
                    self.errorViewModel.handleLoginError(.emailNotFound)
                } else if (error as NSError).code == AuthErrorCode.wrongPassword.rawValue {
                    self.errorViewModel.handleLoginError(.incorrectPassword)
                } else {
                    self.errorViewModel.handleLoginError(.emailNotFound)
                }
                completion(false)
                return
            }

            self.errorViewModel.handleLoginError(nil)

            if let firebaseUser = authResult?.user {
                self.user = User(id: firebaseUser.uid, email: email, username: firebaseUser.displayName ?? "", profileImageUrl: nil)
                print("로그인 성공")
                self.saveUserID(firebaseUser.uid, loginMethod: "email")
                self.isLoggedIn = true
            }
            completion(true)
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
        
        guard let presentingVC = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first(where: { $0.isKeyWindow })?.rootViewController else {
            print("Root View Controller를 찾을 수 없습니다.")
            completion(false)
            return
        }
        
        GIDSignIn.sharedInstance.signIn(withPresenting: presentingVC) { signInResult, error in
            if let error = error {
                print("구글 로그인 실패 \(error.localizedDescription)")
                completion(false)
                return
            }
            
            guard let idToken = signInResult?.user.idToken?.tokenString,
                  let accessToken = signInResult?.user.accessToken.tokenString else {
                print("ID 토큰 또는 액세스 토큰을 가져올 수 없습니다.")
                completion(false)
                return
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
            
            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    print("Firebase Google 인증 실패 \(error.localizedDescription)")
                    completion(false)
                } else if let firebaseUser = authResult?.user {
                    self.saveUserID(firebaseUser.uid, loginMethod: "google")
                    print("Google 로그인 성공!")
                    
                    self.checkIfUserExists(uid: firebaseUser.uid) { exists in
                        DispatchQueue.main.async {
                            if !exists {
                                let email = signInResult?.user.profile?.email ?? ""
                                let username = signInResult?.user.profile?.name ?? "New User"
                                self.saveUserToFirestore(uid: firebaseUser.uid, email: email, username: username, profileImageUrl: nil)
                                self.isNicknameEntryActive = true
                            } else {
                                self.isMainViewActive = true
                            }
                            completion(true)
                        }
                    }
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
    // MARK: 닉네임 저장 메서드
    func saveNickname(_ nickname: String, profileImageUrl: String? = nil) {
        guard !nickname.isEmpty else { return }
        
        // Firestore에 사용자 데이터 저장
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        self.saveUserToFirestore(uid: userID, email: self.user.email, username: nickname, profileImageUrl: profileImageUrl ?? self.user.profileImageUrl)
    }
    // MARK: 닉네임이 이미 저장되어있는지 확인하는 메서드
    private func checkIfUserExists(uid: String, completion: @escaping (Bool) -> Void) {
            db.collection("users").document(uid).getDocument { document, error in
                if let document = document, document.exists {
                    completion(true)
                } else {
                    completion(false)
                }
            }
        }
    // 다른곳에서 db 가져올 수 있는 메서드
    func getUserDocument(uid: String, completion: @escaping (DocumentSnapshot?, Error?) -> Void) {
        db.collection("users").document(uid).getDocument(completion: completion)
    }

// MARK: 로그아웃 버튼 클릭 시 로그아웃 되는 함수
    func logout() {
        if Auth.auth().currentUser == nil {
            print("이미 로그아웃 상태입니다.")
            return
        }
        
        do {
            try Auth.auth().signOut()
            self.isLoggedIn = false
            UserDefaults.standard.removeObject(forKey: "userID")
            UserDefaults.standard.removeObject(forKey: "googleUserID")
            UserDefaults.standard.removeObject(forKey: "appleUserID")
            
            self.user = User(id: "", email: "", username: "", profileImageUrl: nil)
            self.isMainViewActive = true // ContentView로 이동
            self.isNicknameEntryActive = false
            print("로그아웃 성공")
        } catch let signOutError as NSError {
            print("로그아웃 실패: \(signOutError.localizedDescription)")
        }
    }

}
