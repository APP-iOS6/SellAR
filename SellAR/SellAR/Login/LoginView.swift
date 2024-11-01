//
//  LoginView.swift
//  SellAR
//
//  Created by Mac on 11/1/24.
//

import FirebaseAuth
import FirebaseCore
import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    @State private var email = ""
    @State private var password = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    Text("이메일")
                        .padding()
                    TextField("이메일을 입력해 주세요", text: $email)
                        .padding()
                    Text("비밀번호")
                        .padding()
                    SecureField("비밀번호를 입력해 주세요", text: $password)
                        .padding()
                }
                HStack{
                    Button("로그인"){
                        viewModel.loginWithEmailPassword(email: email, password: password)
                    }
                    .padding()
                    Button("회원가입"){
                        viewModel.registerWithEmailPassword(email: email, password: password)
                    }
                    .padding()
                }
            }
        }
    }
}

#Preview {
    LoginView()
}
