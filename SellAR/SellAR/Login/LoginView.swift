//  LoginView.swift
//  SellAR
//
//  Created by Mac on 11/1/24.
//

import FirebaseAuth
import FirebaseCore
import SwiftUI

struct LoginView: View {
    @ObservedObject private var viewModel = LoginViewModel()
    @StateObject private var keyboardViewModel = KeyboardViewModel()
    @StateObject private var errorViewModel = LoginErrorViewModel()
    @State private var email = ""
    @State private var password = ""
    @State private var isNicknameEntryActive = false
    @State private var isMainViewActive = false
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(colorScheme == .dark ? Color(red: 0.14, green: 0.14, blue: 0.15) : .white)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        hideKeyboard()
                    }
                
                GeometryReader { geometry in
                    VStack(spacing: 20) {
                        Image(colorScheme == .dark ? "SellarLogoDark" : "SellarLogoWhite")
                            .resizable()
                            .scaledToFit()
                            .frame(width: min(geometry.size.width * 0.4, geometry.size.height * 0.185),
                                   height: min(geometry.size.width * 0.4, geometry.size.height * 0.185))
                            .padding(.top, 40)
                        
                        VStack(alignment: .leading, spacing: 5) {
                            Text("이메일")
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.vertical, 5)
                                .bold()
                            
                            TextField("이메일을 입력해 주세요", text: $email)
                                .padding()
                                .foregroundColor(.black)
                                .frame(width: geometry.size.width * 0.9, height: max(geometry.size.height / 15, 50))
                                .background(Color(red: 0.95, green: 0.95, blue: 0.97))
                                .cornerRadius(10)
                                .shadow(color: Color.black.opacity(0.16), radius: 3, x: 0, y: 2)
                                .autocapitalization(.none)
                            
                            Text(errorViewModel.emailError)
                                .foregroundColor(.red)
                                .font(.caption)
                                .padding(.top, 5)
                        }
                        .padding(.horizontal, 20)
                        
                        VStack(alignment: .leading, spacing: 5) {
                            Text("비밀번호")
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.vertical, 5)
                                .bold()
                            
                            SecureField("비밀번호를 입력해 주세요", text: $password)
                                .padding()
                                .frame(width: geometry.size.width * 0.9, height: max(geometry.size.height / 15, 50))
                                .background(Color(red: 0.95, green: 0.95, blue: 0.97))
                                .foregroundColor(.black)
                                .cornerRadius(10)
                                .shadow(color: Color.black.opacity(0.16), radius: 3, x: 0, y: 2)
                            
                            Text(errorViewModel.passwordError)
                                .foregroundColor(.red)
                                .font(.caption)
                                .padding(.top, 5)
                        }
                        .padding(.horizontal, 20)
                        
                        // 로그인 회원가입 버튼
                        HStack(spacing: 20) {
                            Button(action: {
                                // 로그인 검증
                                if email.isEmpty || password.isEmpty {
                                    errorViewModel.handleLoginError(.emptyFields)
                                } else {
                                    viewModel.loginWithEmailPassword(email: email, password: password) { success in
                                        if success {
                                            if let user = Auth.auth().currentUser {
                                                viewModel.userID = user.uid
                                            }
                                            isMainViewActive = true
                                        }
                                    }
                                }
                            }) {
                                Text("로그인")
                                    .frame(width: geometry.size.width * 0.34, height: geometry.size.height / 50)
                                    .padding()
                                    .background(Color(red: 0.30, green: 0.50, blue: 0.78))
                                    .foregroundColor(colorScheme == .dark ? .white : .white)
                                    .cornerRadius(10)
                                    .bold()
                                    .shadow(color: Color.black.opacity(0.16), radius: 3, x: 0, y: 2)
                            }
                            
                            NavigationLink(destination: RegisterView()) {
                                Text("회원가입")
                                    .frame(width: geometry.size.width * 0.34, height: geometry.size.height / 50)
                                    .padding()
                                    .foregroundColor(.black)
                                    .background(Color(red: 0.95, green: 0.95, blue: 0.97))
                                    .cornerRadius(10)
                                    .bold()
                                    .shadow(color: Color.black.opacity(0.16), radius: 3, x: 0, y: 2)
                            }
                        }
                        
                        VStack {
                            HStack {
                                VStack {
                                    Divider()
                                        .frame(height: 1)
                                        .background(Color.gray)
                                }
                                Text("또는")
                                    .foregroundColor(.gray)
                                VStack {
                                    Divider()
                                        .frame(height: 1)
                                        .background(Color.gray)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                        
                        // 소셜 로그인 버튼
                        Button(action: {
                            viewModel.loginWithGoogle { success in
                                if success {
                                    isMainViewActive = viewModel.isMainViewActive
                                    isNicknameEntryActive = viewModel.isNicknameEntryActive
                                }
                            }
                        }) {
                            HStack {
                                Image("GoogleIcon")
                                    .foregroundColor(colorScheme == .dark ? .white : .black)
                                Text("Google로 로그인")
                                    .foregroundColor(colorScheme == .dark ? .white : .black)
                            }
                            .frame(width: geometry.size.width * 0.8, height: geometry.size.height / 50)
                            .padding()
                            .background(colorScheme == .dark ? Color(red: 20/255, green: 20/255, blue: 20/255) : Color(red: 0.95, green: 0.95, blue: 0.97))
                            .cornerRadius(10)
                            .bold()
                            .shadow(color: Color.black.opacity(0.16), radius: 3, x: 0, y: 2)
                        }
                        .padding(.top, 20)
                        
                        Button(action: {
                            viewModel.loginWithApple { success in
                                if success {
                                    isMainViewActive = viewModel.isMainViewActive
                                    isNicknameEntryActive = !viewModel.isMainViewActive
                                }
                            }
                        }) {
                            HStack {
                                Image(systemName: "applelogo")
                                    .foregroundColor(colorScheme == .dark ? .white : .black)
                                Text("Apple로 로그인")
                                    .foregroundColor(colorScheme == .dark ? .white : .black)
                            }
                            .frame(width: geometry.size.width * 0.8, height: geometry.size.height / 50)
                            .padding()
                            .bold()
                            .background(colorScheme == .dark ? Color(red: 20/255, green: 20/255, blue: 20/255) : Color(red: 0.95, green: 0.95, blue: 0.97))
                            .cornerRadius(10)
                            .shadow(color: Color.black.opacity(0.16), radius: 3, x: 0, y: 2)
                        }
                    }
                }
            }
            .background(
                NavigationLink(destination: MainView().navigationBarBackButtonHidden(true), isActive: $isMainViewActive) {
                    EmptyView()
                }
            )
            .background(
                NavigationLink(destination: NicknameEntryView(viewModel: viewModel), isActive: $isNicknameEntryActive) {
                    EmptyView()
                }
            )
        }
    }
}

#Preview {
    LoginView()
}
