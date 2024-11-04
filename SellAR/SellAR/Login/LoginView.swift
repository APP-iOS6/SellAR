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
    @State private var isNavigation = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black
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
                            NavigationLink(destination: RegisterView()){
                                Text ("회원가입")
                                    .frame(width: geometry.size.width * 0.3, height: geometry.size.height / 50)
                                    .padding()
                                    .foregroundColor(.white)
                                    .background(.gray)
                                    .cornerRadius(10)
                            }
                        }
                        
                        Button(action: { viewModel.loginWithGoogle
                            { success in
                            if success {
                                isNavigation = true
                            }
                        }
                        }) {
                            Text("Google로 로그인")
                                .frame(width: geometry.size.width * 0.7, height: geometry.size.height / 50)
                                .padding()
                                .foregroundColor(.white)
                                .background(.blue)
                                .cornerRadius(10)
                        }
                        .padding(.top, 20)
                        
                    NavigationLink(destination: NicknameEntryView(viewModel: viewModel), isActive: $isNavigation) {
                        EmptyView() // 네비게이션 링크 안보이게
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
