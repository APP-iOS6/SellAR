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
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var userName = ""
    @State private var profileImage: UIImage? = nil
    @State private var isRegistrationSuccessful = false
    
    @Environment(\.colorScheme) var colorScheme
    
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedItemData: Data? = nil
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(colorScheme == .dark ? Color(hex: "#242427") : .white)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        hideKeyboard()
                    }
                GeometryReader{ geometry in
                    VStack (spacing: 20) {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("이메일")
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.vertical, 5)
                                .padding(.leading, 20)
                                .bold()
                            
                            TextField("이메일을 입력해 주세요", text: $email)
                                .padding()
                                .frame(width: geometry.size.width * 0.9, height: max(geometry.size.height / 15, 50))
                                .background(colorScheme == .dark ? Color.black : Color(hex: "#F3F2F8"))
                                .foregroundColor(.black)
                                .cornerRadius(10)
                                .padding(.horizontal, 20)
                                .shadow(color: Color.black.opacity(0.16), radius: 3, x: 0, y: 2)
                            
                            if !errorViewModel.emailError.isEmpty {
                                Text(errorViewModel.emailError)
                                    .foregroundColor(.red)
                                    .font(.caption)
                                    .padding(.bottom, 20)
                                    .padding(.horizontal, 20)
                            }
                            
                            Text("비밀번호")
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.vertical, 5)
                                .padding(.leading, 20)
                                .bold()
                            
                            SecureField("비밀번호를 입력해 주세요", text: $password)
                                .padding()
                                .frame(width: geometry.size.width * 0.9, height: max(geometry.size.height / 15, 50))
                                .background(colorScheme == .dark ? Color.black : Color(hex: "#F3F2F8"))
                                .foregroundColor(.black)
                                .cornerRadius(10)
                                .padding(.horizontal, 20)
                                .shadow(color: Color.black.opacity(0.16), radius: 3, x: 0, y: 2)
                            
                            if !errorViewModel.passwordError.isEmpty {
                                Text(errorViewModel.passwordError)
                                    .foregroundColor(.red)
                                    .font(.caption)
                                    .padding(.bottom, 20)
                                    .padding(.horizontal, 20)
                            }
                            
                            Text("비밀번호 확인")
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.vertical, 5)
                                .padding(.leading, 20)
                                .bold()
                            
                            SecureField("비밀번호를 똑같이 입력해 주세요", text: $confirmPassword)
                                .padding()
                                .frame(width: geometry.size.width * 0.9, height: max(geometry.size.height / 15, 50))
                                .background(colorScheme == .dark ? Color.black : Color(hex: "#F3F2F8"))
                                .cornerRadius(10)
                                .foregroundColor(.black)
                                .padding(.horizontal, 20)
                                .shadow(color: Color.black.opacity(0.16), radius: 3, x: 0, y: 2)
                            
                            if !errorViewModel.confirmPasswordError.isEmpty {
                                Text(errorViewModel.confirmPasswordError)
                                    .foregroundColor(.red)
                                    .font(.caption)
                                    .padding(.bottom, 20)
                                    .padding(.horizontal, 20)
                            }
                            
                            Text("닉네임")
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.vertical, 5)
                                .padding(.leading, 20)
                                .bold()
                            
                            TextField("닉네임을 입력해 주세요", text: $userName)
                                .padding()
                                .frame(width: geometry.size.width * 0.9, height: max(geometry.size.height / 15, 50))
                                .background(colorScheme == .dark ? Color.black : Color(hex: "#F3F2F8"))
                                .foregroundColor(.black)
                                .cornerRadius(10)
                                .padding(.horizontal, 20)
                                .shadow(color: Color.black.opacity(0.16), radius: 3, x: 0, y: 2)
                            
                            if !errorViewModel.nicknameError.isEmpty {
                                Text(errorViewModel.nicknameError)
                                    .foregroundColor(.red)
                                    .font(.caption)
                                    .padding(.bottom, 20)
                                    .padding(.horizontal, 20)
                            }
                            
                            PhotosPicker(
                                selection: $selectedItem,
                                matching: .images,
                                photoLibrary: .shared()
                            ) {
                                ZStack {
                                    Circle()
                                        .fill(colorScheme == .dark ? Color.black : Color(hex: "#F3F2F8"))
                                        .frame(width: 120, height: 120)
                                        .shadow(color: Color.black.opacity(0.16), radius: 3, x: 0, y: 2)

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
                                                .padding(.top, 5)
                                        }
                                        .foregroundColor(colorScheme == .dark ? .white : .black)
                                        .bold()
                                    }
                                }
                            }
                            .onChange(of: selectedItem) { newItem in
                                Task {
                                    print("이미지 선택됨")
                                    if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                        print("이미지 데이터 로드 성공")
                                        selectedItemData = data
                                        if let image = UIImage(data: data) {
                                            print("UIImage 변환 성공")
                                            profileImage = image
                                        } else {
                                            print("UIImage 변환 실패")
                                        }
                                    } else {
                                        print("이미지 데이터 로드 실패")
                                    }
                                }
                            }
                            .padding(.leading, 140)
                            .padding(.bottom, 20)
                            HStack {
                                Spacer()
                                Button(action: {
                                    if password != confirmPassword {
                                        errorViewModel.handleLoginError(.passwordMismatch)
                                    } else {
                                        errorViewModel.handleLoginError(nil)
                                        viewModel.registerWithEmailPassword(
                                            email: email,
                                            password: password,
                                            username: userName,
                                            profileImage: profileImage
                                        )
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                            isRegistrationSuccessful = true
                                        }
                                    }
                                }) {
                                    ZStack {
                                        Rectangle()
                                            .fill(Color(hex: "#1BD6F5"))
                                            .frame(width: geometry.size.width * 0.5, height: geometry.size.height / 15)
                                            .cornerRadius(10)
                                            .shadow(color: Color.black.opacity(0.16), radius: 3, x: 0, y: 2)

                                        Text("가입완료")
                                            .font(.system(size: 18, weight: .bold))
                                            .foregroundColor(colorScheme == .dark ? .white : .black)
                                    }
                                }
                                Spacer()
                            }
                            .padding(.bottom, 40)
                        }
                    }
                }
            }
            .padding(.bottom, -keyboardViewModel.keyboardHeight)
            .background(
                NavigationLink(destination: LoginView(), isActive: $isRegistrationSuccessful) {
                    EmptyView()
                }
            )
        }
    }
}
#Preview {
    RegisterView()
}
