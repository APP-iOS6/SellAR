//
//  LoginErrorViewModel.swift
//  SellAR
//
//  Created by Mac on 11/6/24.
//

import FirebaseAuth
import SwiftUI

// MARK: 로그인 에러 처리 4개, 추후 더 생성 가능
enum LoginError: Error {
    case invalidEmail
    case emailNotFound
    case incorrectPassword
    case passwordTooShort
}

final class LoginErrorViewModel: ObservableObject {
    @Published var emailError: String = ""
    @Published var passwordError: String = ""
    
    func handleLoginError(_ error: LoginError?) {
        switch error {
        case .invalidEmail:
            self.emailError = "유효한 이메일을 입력해주세요."
        case .emailNotFound:
            self.emailError = "이메일을 찾을 수 없습니다."
        case .incorrectPassword:
            self.passwordError = "비밀번호가 틀렸습니다."
        case .passwordTooShort:
            self.passwordError = "비밀번호는 6자 이상이어야 합니다."
        case .none:
            self.emailError = ""
            self.passwordError = ""
        }
    }
}
