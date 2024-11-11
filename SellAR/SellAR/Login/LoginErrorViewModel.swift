//
//  LoginErrorViewModel.swift
//  SellAR
//
//  Created by Mac on 11/6/24.
//

import FirebaseAuth
import SwiftUI

enum LoginError: Error {
    case invalidEmail
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
    
    // 이메일 형식 검사
    func validateEmailFormat(_ email: String) -> LoginError? {
        let emailRegEx = "[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        if !emailTest.evaluate(with: email) {
            return .invalidEmailFormat
        }
        return nil
    }
    
    func handleLoginError(_ error: LoginError?) {
        self.emailError = ""
        self.passwordError = ""
        self.confirmPasswordError = ""
        self.nicknameError = ""
        
        switch error {
        case .invalidEmail:
            self.emailError = "유효한 이메일을 입력해주세요."
        case .invalidEmailFormat: 
            self.emailError = "유효한 이메일 형식이 아닙니다."
        case .emailNotFound:
            self.emailError = "이메일을 찾을 수 없습니다."
        case .incorrectPassword:
            self.passwordError = "비밀번호가 틀렸습니다."
        case .passwordTooShort:
            self.passwordError = "비밀번호는 6자 이상이어야 합니다."
        case .passwordMismatch:
            self.confirmPasswordError = "비밀번호가 일치하지 않습니다."
        case .emptyFields:
            self.nicknameError = "모든 필드를 채워주세요."
        case .none:
            break
        }
    }
}
