//
//  NicknameEntryView.swift
//  SellAR
//
//  Created by Mac on 11/4/24.
//

import SwiftUI
import PhotosUI

struct NicknameEntryView: View {
    @ObservedObject var viewModel: LoginViewModel
    @StateObject private var keyboardViewModel = KeyboardViewModel()
    @StateObject private var errorViewModel = LoginErrorViewModel()
    @State private var nickname = ""
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedItemData: Data? = nil
    @State private var isNicknameSaved = false
    @State private var isNavigationActive = false
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack {
            if isNicknameSaved {
                MainView(loginViewModel: viewModel)
            } else {
                NavigationStack {
                    ZStack {
                        Color(colorScheme == .dark ? Color(red: 0.14, green: 0.14, blue: 0.15) : .white)
                            .edgesIgnoringSafeArea(.all)
                            .onTapGesture {
                                hideKeyboard()
                            }
                        GeometryReader { geometry in
                            VStack(spacing: 20) {
                                PhotosPicker(
                                    selection: $selectedItem,
                                    matching: .images,
                                    photoLibrary: .shared()
                                ) {
                                    ZStack {
                                        Circle()
                                            .fill(colorScheme == .dark ? Color(red: 20/255, green: 20/255, blue: 20/255) : Color(red: 0.95, green: 0.95, blue: 0.97))
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
                                
                                HStack {
                                    Text("닉네임 입력")
                                        .foregroundColor(colorScheme == .dark ? .white : .black)
                                        .padding(.leading, 20)
                                        .padding(.vertical, 5)
                                        .bold()
                                    Spacer()
                                }
                                
                                TextField("닉네임을 입력해 주세요", text: $nickname)
                                    .padding()
                                    .frame(width: geometry.size.width * 0.9, height: max(geometry.size.height / 15, 50))
                                    .background(colorScheme == .dark ? Color(red: 20/255, green: 20/255, blue: 20/255) : Color(red: 0.95, green: 0.95, blue: 0.97))
                                    .cornerRadius(10)
                                    .padding(.horizontal, 10)
                                    .shadow(color: Color.black.opacity(0.16), radius: 3, x: 0, y: 2)
                                
                                Text(errorViewModel.nicknameError)
                                    .foregroundColor(.red)
                                    .font(.caption)
                                    .padding(.top, 5)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal, 20)
                                
                                Button(action: {
                                    if nickname.isEmpty {
                                        errorViewModel.handleLoginError(.emptyFields)
                                    } else {
                                        if let imageData = selectedItemData, let uiImage = UIImage(data: imageData) {
                                            viewModel.uploadProfileImage(uiImage) { url in
                                                viewModel.saveNickname(nickname, profileImageUrl: url?.absoluteString)
                                            }
                                        } else {
                                            viewModel.saveNickname(nickname)
                                        }
                                        isNicknameSaved = true
                                    }
                                }) {
                                    Text("닉네임 저장")
                                        .frame(width: geometry.size.width * 0.4, height: geometry.size.height / 30)
                                        .padding()
                                        .background(nickname.isEmpty ? Color(red: 0.95, green: 0.95, blue: 0.97) : Color(red: 0.30, green: 0.50, blue: 0.78))
                                        .foregroundColor(nickname.isEmpty ? .gray : .white)
                                        .cornerRadius(10)
                                        .bold()
                                        .shadow(color: Color.black.opacity(0.16), radius: 3, x: 0, y: 2)
                                        .disabled(nickname.isEmpty)
                                }
                                
                                NavigationLink(destination: MainView(loginViewModel: viewModel).navigationBarBackButtonHidden(true), isActive: $isNicknameSaved) {
                                    EmptyView()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
