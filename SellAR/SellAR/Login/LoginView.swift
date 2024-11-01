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
                Color(hex: "#0d0d0d")
                    .edgesIgnoringSafeArea(.all)
                GeometryReader{ geometry in
                    /// 이메일 비밀번호 로그인
                    VStack (spacing: 20) {
                        Text("이메일")
                            .padding()
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        TextField("이메일을 입력해 주세요", text: $email)
                            .padding()
                            .frame(width: geometry.size.width * 0.9, height: geometry.size.height / 20)
                            .background(.white)
                            .cornerRadius(10)
                            .padding(.horizontal, 20)
                        Text("비밀번호")
                            .padding()
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        SecureField("비밀번호를 입력해 주세요", text: $password)
                            .padding()
                            .frame(width: geometry.size.width * 0.9, height: geometry.size.height / 20)
                            .background(.white)
                            .cornerRadius(10)
                            .padding(.horizontal, 20)
                            .padding(.bottom, 20)
                        
                        // 로그인 회원가입 버튼
                        HStack (spacing: 20) {
                            Button(action: {
                                viewModel.loginWithEmailPassword(email: email, password: password)
                            }){
                                Text("로그인")
                                    .frame(width: geometry.size.width * 0.3, height: geometry.size.height / 50)
                                    .padding()
                                    .background(.white)
                                    .foregroundColor(.black)
                                    .cornerRadius(10)
                            }
                            Button(action: {
                                viewModel.registerWithEmailPassword(email: email, password: password)
                            }){
                                Text("회원가입")
                            }
                            .frame(width: geometry.size.width * 0.3, height: geometry.size.height / 50)
                            .padding()
                            .foregroundColor(.white)
                            .background(Color(hex: "#181818"))
                            .cornerRadius(10)
                            
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    LoginView()
}
