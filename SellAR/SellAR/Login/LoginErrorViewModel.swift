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
}

final class LoginErrorViewModel: ObservableObject {
    @Published var emailError: String = ""
    @Published var passwordError: String = ""
    @Published var confirmPasswordError: String = ""
    @Published var nicknameError: String = ""
    
    // 검증에 필요한 상태 변수
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    @Published var userName: String = ""
    
    // 버튼 활성화 여부 상태
    @Published var isRegisterButtonEnabled: Bool = false
    
    private var timer: Timer?

    // 타이머 시작
    func startValidationTimer() {
        // 타이머가 이미 실행 중이라면 중지
        stopValidationTimer()

        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.validateFields()
        }
    }
    
    // 타이머 중지
    func stopValidationTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    // 필드 검증
    private func validateFields() {
        handleLoginError(nil)
        
        // 빈 필드 확인
        if email.isEmpty || password.isEmpty {
            handleLoginError(.emptyFields)
        }
        
        // 비밀번호 길이 검증
        if password.count < 6 {
            handleLoginError(.passwordTooShort)
        }
        
        // 비밀번호 확인 일치 여부 검증
        if password != confirmPassword {
            handleLoginError(.passwordMismatch)
        }
        
        // 버튼 활성화 상태 갱신
        updateRegisterButtonState()
    }
    
    // 가입 버튼 활성화 상태 업데이트
    private func updateRegisterButtonState() {
        // 이메일, 비밀번호, 비밀번호 확인, 닉네임 모두 유효해야만 버튼이 활성화됨
        isRegisterButtonEnabled = !email.isEmpty &&
                                  !password.isEmpty &&
                                  !confirmPassword.isEmpty &&
                                  !userName.isEmpty &&
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
            if email.isEmpty || password.isEmpty {
                emailError = "아이디 및 비밀번호를 입력해주세요."
            }
            nicknameError = "닉네임을 입력해주세요."
        case .none:
            break
        }
    }
}
