//  LoginErrorViewModel.swift
//  SellAR
//
//  Created by Mac on 11/6/24.
//

import FirebaseAuth
import SwiftUI
import Combine

enum LoginError: Error {
    case emailNotFound
    case incorrectPassword
    case passwordTooShort
    case passwordMismatch
    case emptyFields
    case invalidEmailFormat
}

final class LoginErrorViewModel: ObservableObject {
    @Published var emailError: String = ""
    @Published var passwordError: String = ""
    @Published var confirmPasswordError: String = ""
    @Published var nicknameError: String = ""
    
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    @Published var userName: String = ""
    
    @Published var isRegisterButtonEnabled: Bool = false
    
    private var timer: Timer?

    func startValidationTimer() {
        stopValidationTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.validateFields()
        }
    }
    
    func stopValidationTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func validateFields() {
        handleLoginError(nil)
        
        if email.isEmpty || password.isEmpty || userName.isEmpty {
            handleLoginError(.emptyFields)
        } else if !isEmailValid(email) {
            handleLoginError(.invalidEmailFormat)
        } else if password.count < 6 {
            handleLoginError(.passwordTooShort)
        } else if password != confirmPassword {
            handleLoginError(.passwordMismatch)
        }
        
        updateRegisterButtonState()
    }
    
    private let allowedEmailDomains = [
        "@gmail.com", "@naver.com", "@daum.net", "@hanmail.net",
        "@nate.com", "@korea.com", "@icloud.com", "@hotmail.com",
        "@yahoo.co.kr", "@outlook.com"
    ]
    private func isEmailValid(_ email: String) -> Bool {
        return allowedEmailDomains.contains { domain in
            email.lowercased().hasSuffix(domain)
        }
    }
    
    private func updateRegisterButtonState() {
        isRegisterButtonEnabled = !email.isEmpty &&
                                  !password.isEmpty &&
                                  !confirmPassword.isEmpty &&
                                  !userName.isEmpty &&
                                isEmailValid(email) &&
                                  password.count >= 6 &&
                                  password == confirmPassword
    }
    
    func handleLoginError(_ error: LoginError?) {
        emailError = ""
        passwordError = ""
        confirmPasswordError = ""
        nicknameError = ""
        
        switch error {
        case .emailNotFound:
            emailError = "이메일을 찾을 수 없습니다."
        case .incorrectPassword:
            passwordError = "아이디 혹은 비밀번호가 틀렸습니다."
        case .passwordTooShort:
            passwordError = "비밀번호는 6자 이상이어야 합니다."
        case .passwordMismatch:
            confirmPasswordError = "비밀번호가 일치하지 않습니다."
        case .emptyFields:
            emailError = email.isEmpty ? "" : ""
            passwordError = password.isEmpty ? "" : ""
            nicknameError = userName.isEmpty ? "" : ""
        case .invalidEmailFormat:
            emailError = "올바른 이메일 형식만 가능합니다."
        case .none:
            break
        }
    }
}
