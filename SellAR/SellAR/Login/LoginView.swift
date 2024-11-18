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
                Color(colorScheme == .dark ? .black : .white)
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
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                                .frame(width: geometry.size.width * 0.9, height: max(geometry.size.height / 15, 50))
                                .background(colorScheme == .dark ? Color(red: 0.21, green: 0.23, blue: 0.25) : .white)
                                .cornerRadius(10)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .overlay(RoundedRectangle(cornerRadius: 10)
                                    .stroke(colorScheme == .dark ? Color(red: 0.21, green: 0.23, blue: 0.25) : .black, lineWidth: 0.5)
                                )
                            
                            Text(errorViewModel.emailError)
                                .foregroundColor(.red)
                                .font(.caption)
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
                                .background(colorScheme == .dark ? Color(red: 0.21, green: 0.23, blue: 0.25) : .white)
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                                .cornerRadius(10)
                                .overlay(RoundedRectangle(cornerRadius: 10)
                                    .stroke(colorScheme == .dark ? Color(red: 0.21, green: 0.23, blue: 0.25) : .black, lineWidth: 0.5)
                                )
                            
                            Text(errorViewModel.passwordError)
                                .foregroundColor(.red)
                                .font(.caption)
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
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                    .bold()
                            }
                            
                            NavigationLink(destination: RegisterView()) {
                                Text("회원가입")
                                    .frame(width: geometry.size.width * 0.34, height: geometry.size.height / 50)
                                    .padding()
                                    .background(Color(red: 0.30, green: 0.50, blue: 0.78))
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                    .bold()
                            }
                        }
                        
                        VStack {
                            HStack {
                                VStack {
                                }
                                Text("다음으로 로그인: ")
                                VStack {
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                        HStack(spacing: 20) {
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
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 40, height: 40)
                                }
                                .frame(width: 70, height: 70)
                                .background(Color.white)
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color(colorScheme == .light ?.black : .clear), lineWidth: 0.5)
                                )
                            }

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
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 40, height: 40)
                                }
                                .frame(width: 70, height: 70)
                                .background(Color.white)
                                .foregroundColor(.black)
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color(colorScheme == .light ? .black : .clear), lineWidth: 0.5)
                                )
                            }
                        }
                    }
                }
            }
            .background(
                NavigationLink(destination: ContentView(viewModel: viewModel), isActive: $isMainViewActive) {
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
