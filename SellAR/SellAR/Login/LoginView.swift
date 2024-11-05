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
                    VStack (spacing: 20) {
                        Image(systemName: "person.fill")
                            .resizable()
                            .frame(width: geometry.size.width * 0.3, height: geometry.size.height * 0.16)
                            .foregroundColor(.white)
                            .padding(.top, 40)
                        VStack(alignment: .leading, spacing: 5) {
                            Text("이메일")
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.vertical, 5)
                            TextField("이메일을 입력해 주세요", text: $email)
                                .padding()
                                .frame(width: geometry.size.width * 0.9, height: geometry.size.height / 20)
                                .background(.white)
                                .cornerRadius(10)
                        }
                        .padding(.horizontal, 20)
                        
                        VStack(alignment: .leading, spacing: 5) {
                            Text("비밀번호")
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.vertical, 5)
                            SecureField("비밀번호를 입력해 주세요", text: $password)
                                .padding()
                                .frame(width: geometry.size.width * 0.9, height: geometry.size.height / 20)
                                .background(.white)
                                .cornerRadius(10)
                                .padding(.bottom, 40)
                        }
                        .padding(.horizontal, 20)
                            // 로그인 회원가입 버튼
                        HStack (spacing: 20) {
                            Button(action: {
                                viewModel.loginWithEmailPassword(email: email, password: password)
                            }){
                                Text("로그인")
                                    .frame(width: geometry.size.width * 0.34, height: geometry.size.height / 50)
                                    .padding()
                                    .background(.white)
                                    .foregroundColor(.black)
                                    .cornerRadius(10)
                            }
                            NavigationLink(destination: RegisterView()){
                                Text ("회원가입")
                                    .frame(width: geometry.size.width * 0.34, height: geometry.size.height / 50)
                                    .padding()
                                    .foregroundColor(.white)
                                    .background(.gray)
                                    .cornerRadius(10)
                            }
                        }
                    
                        VStack {
                            HStack {
                                VStack{
                                    Divider()
                                        .frame(height: 1)
                                        .background(Color.gray)
                                }
                                    Text("또는")
                                    .foregroundColor(.gray)
                                VStack{
                                    Divider()
                                        .frame(height: 1)
                                        .background(Color.gray)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                            
                        Button(action: { viewModel.loginWithGoogle
                            { success in
                                if success {
                                    isNavigation = true
                                }
                            }
                        }) {
                            HStack {
                                Image(systemName: "globe")
                                    .foregroundColor(.white)
                                Text("Google로 로그인")
                                    .foregroundColor(.white)
                            }
                            .frame(width: geometry.size.width * 0.8, height: geometry.size.height / 50)
                            .padding()                            .background(.blue)
                            .cornerRadius(10)
                        }
                        .padding(.top, 20)
                        
                        NavigationLink(destination: NicknameEntryView(viewModel: viewModel), isActive: $isNavigation) {
                            EmptyView() // 네비게이션 링크 안보이게
                        }
                        
                        Button(action: {
                            viewModel.loginWithApple { success in
                                if success {
                                    isNavigation = true
                                }
                            }
                        }) {
                            HStack {
                                Image(systemName: "applelogo")
                                    .foregroundColor(.white)
                                Text("Apple로 로그인")
                                    .foregroundColor(.white)
                            }
                                .frame(width: geometry.size.width * 0.8, height: geometry.size.height / 50)
                                .padding()
                                .background(.gray)
                                .cornerRadius(10)
                        }
                        
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
