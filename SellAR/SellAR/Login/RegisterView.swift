//
//  RegisterView.swift
//  SellAR
//
//  Created by Mac on 11/1/24.
//

import FirebaseAuth
import FirebaseCore
import PhotosUI
import SwiftUI

struct RegisterView: View {
    @StateObject private var viewModel = LoginViewModel()
    @StateObject private var keyboardViewModel = KeyboardViewModel()
    @StateObject private var errorViewModel = LoginErrorViewModel()
    
    @State private var isRegistrationSuccessful = false
    @State private var isPasswordValid: Bool = false
    @Environment(\.colorScheme) var colorScheme
    
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedItemData: Data? = nil
    
    var body: some View {
            ZStack {
                Color(colorScheme == .dark ? .black : .white)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        hideKeyboard()
                    }
                GeometryReader { geometry in
                    VStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 5) {
                            // 이메일 필드
                            Text("이메일")
                                .bold()
                                .foregroundColor(colorScheme == .dark ? .white : Color(red: 36/255, green: 36/255, blue: 39/255))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.leading, 20)
                            TextField("이메일을 입력해 주세요", text: $errorViewModel.email)
                                .padding()
                                .frame(width: geometry.size.width * 0.9, height: max(geometry.size.height / 15, 50))
                                .background(colorScheme == .dark ? Color(red: 0.21, green: 0.23, blue: 0.25) : .white)
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                                .cornerRadius(10)
                                .keyboardType(.emailAddress)
                                .overlay(RoundedRectangle(cornerRadius: 10)
                                    .stroke(colorScheme == .dark ? Color(red: 0.21, green: 0.23, blue: 0.25) : .black, lineWidth: 0.5)
                                )
                                .padding(.horizontal, 20)
                                .autocapitalization(.none)
                            
                            Text(errorViewModel.emailError)
                                .foregroundColor(.red)
                                .font(.caption)
                                .padding(.horizontal, 20)
                                .opacity(errorViewModel.emailError.isEmpty ? 0 : 1)
                                .padding(.bottom, 10)
                            
                            // 비밀번호 필드
                            Text("비밀번호")
                                .bold()
                                .foregroundColor(colorScheme == .dark ? .white : Color(red: 36/255, green: 36/255, blue: 39/255))
                                .padding(.leading, 20)
                            SecureField("비밀번호를 입력해 주세요", text: $errorViewModel.password)
                                .padding()
                                .frame(width: geometry.size.width * 0.9, height: max(geometry.size.height / 15, 50))
                                .background(colorScheme == .dark ? Color(red: 0.21, green: 0.23, blue: 0.25) : .white)
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                                .cornerRadius(10)
                                .overlay(RoundedRectangle(cornerRadius: 10)
                                    .stroke(colorScheme == .dark ? Color(red: 0.21, green: 0.23, blue: 0.25) : .black, lineWidth: 0.5)
                                )
                                .padding(.horizontal, 20)
                            
                            Text(errorViewModel.passwordError)
                                .foregroundColor(.red)
                                .font(.caption)
                                .padding(.horizontal, 20)
                                .opacity(errorViewModel.passwordError.isEmpty ? 0 : 1)
                                .frame(height: 20)
                            
                            // 비밀번호 확인 필드
                            Text("비밀번호 확인")
                                .bold()
                                .foregroundColor(colorScheme == .dark ? .white : Color(red: 36/255, green: 36/255, blue: 39/255))
                                .padding(.leading, 20)
                            SecureField("비밀번호를 똑같이 입력해 주세요", text: $errorViewModel.confirmPassword)
                                .padding()
                                .frame(width: geometry.size.width * 0.9, height: max(geometry.size.height / 15, 50))
                                .background(colorScheme == .dark ? Color(red: 0.21, green: 0.23, blue: 0.25) : .white)
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                                .cornerRadius(10)
                                .overlay(RoundedRectangle(cornerRadius: 10)
                                    .stroke(colorScheme == .dark ? Color(red: 0.21, green: 0.23, blue: 0.25) : .black, lineWidth: 0.5)
                                )
                                .padding(.horizontal, 20)
                            
                            Text(errorViewModel.confirmPasswordError)
                                .foregroundColor(.red)
                                .font(.caption)
                                .padding(.horizontal, 20)
                                .opacity(errorViewModel.confirmPasswordError.isEmpty ? 0 : 1)
                                .frame(height: 20)
                            
                            // 닉네임 필드
                            Text("닉네임")
                                .bold()
                                .foregroundColor(colorScheme == .dark ? .white : Color(red: 36/255, green: 36/255, blue: 39/255))
                                .padding(.leading, 20)
                            TextField("닉네임을 입력해 주세요", text: $errorViewModel.userName)
                                .padding()
                                .frame(width: geometry.size.width * 0.9, height: max(geometry.size.height / 15, 50))
                                .background(colorScheme == .dark ? Color(red: 0.21, green: 0.23, blue: 0.25) : .white)
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                                .cornerRadius(10)
                                .overlay(RoundedRectangle(cornerRadius: 10)
                                    .stroke(colorScheme == .dark ? Color(red: 0.21, green: 0.23, blue: 0.25) : .black, lineWidth: 0.5)
                                )
                                .padding(.horizontal, 20)
                            
                            Text(errorViewModel.nicknameError)
                                .foregroundColor(.red)
                                .font(.caption)
                                .padding(.horizontal, 20)
                                .opacity(errorViewModel.nicknameError.isEmpty ? 0 : 1)
                                .frame(height: 20)
                            
                            // 프로필 이미지 선택
                            PhotosPicker(
                                selection: $selectedItem,
                                matching: .images,
                                photoLibrary: .shared()
                            ) {
                                ZStack {
                                    Circle()
                                        .fill(colorScheme == .dark ? Color(red: 0.21, green: 0.23, blue: 0.25) : .white)
                                        .frame(width: 120, height: 120)
                                        .overlay(Circle()
                                            .stroke(colorScheme == .dark ? Color(red: 0.21, green: 0.23, blue: 0.25) : .black, lineWidth: 0.5)
                                        )

                                    if let data = selectedItemData, let image = UIImage(data: data) {
                                        Image(uiImage: image)
                                            .resizable()
                                            .clipShape(Circle())
                                            .frame(width: 120, height: 120)
                                    } else {
                                        VStack {
                                            Image(systemName: "camera")
                                                .font(.system(size: 30))
                                            Text("프로필 (선택)")
                                                .font(.caption)
                                                .padding(.top,3)
                                        }
                                        .background(colorScheme == .dark ? Color(red: 0.21, green: 0.23, blue: 0.25) : .white)
                                        .foregroundColor(Color(red: 0.30, green: 0.50, blue: 0.78))
                                        .bold()
                                    }
                                }
                            }
                            .onChange(of: selectedItem) { newItem in
                                Task {
                                    if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                        selectedItemData = data
                                    }
                                }
                            }
                            .padding(.leading, 140)
                            .padding(.bottom, 20)
                            
                            // 가입 완료 버튼
                            HStack {
                                Spacer()
                                Button(action: {
                                    if errorViewModel.isRegisterButtonEnabled {
                                        errorViewModel.startValidationTimer()
                                        if errorViewModel.password != errorViewModel.confirmPassword {
                                            errorViewModel.handleLoginError(.passwordMismatch)
                                        } else {
                                            errorViewModel.handleLoginError(nil)
                                            viewModel.registerWithEmailPassword(
                                                email: errorViewModel.email,
                                                password: errorViewModel.password,
                                                username: errorViewModel.userName,
                                                profileImage: selectedItemData != nil ? UIImage(data: selectedItemData!) : nil
                                            )
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                                isRegistrationSuccessful = true
                                            }
                                        }
                                    }
                                }) {
                                    ZStack {
                                        Rectangle()
                                            .fill(errorViewModel.isRegisterButtonEnabled ? Color(red: 0.30, green: 0.50, blue: 0.78) : .white)
                                            .frame(width: geometry.size.width * 0.5, height: geometry.size.height / 15)
                                            .cornerRadius(10)
                                            .overlay(RoundedRectangle(cornerRadius: 10)
                                                .stroke(colorScheme == .dark ? Color(red: 0.21, green: 0.23, blue: 0.25) : .black, lineWidth: 0.5)
                                            )
                                        
                                        Text("가입완료")
                                            .foregroundColor(errorViewModel.isRegisterButtonEnabled ? .white : .black)
                                            .bold()
                                    }
                                    .disabled(!errorViewModel.isRegisterButtonEnabled)
                                }
                                Spacer()
                            }
                            .padding(.bottom, 40)
                        }
                    }
                }
            }
            .background(
                NavigationLink(destination: LoginView().navigationBarBackButtonHidden(true), isActive: $isRegistrationSuccessful) {
                    EmptyView()
                }
            )
            .onAppear {
                errorViewModel.startValidationTimer()
            }
            .onDisappear {
                errorViewModel.stopValidationTimer()
            }
        }
    }
#Preview {
    RegisterView()
}
