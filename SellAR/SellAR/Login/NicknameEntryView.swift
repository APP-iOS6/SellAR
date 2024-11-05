//
//  NicknameEntryView.swift
//  SellAR
//
//  Created by Mac on 11/4/24.
//

import SwiftUI

struct NicknameEntryView: View {
    @ObservedObject var viewModel: LoginViewModel
    @State private var nickname = ""
    @State private var isNicknameSaved = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black
                    .edgesIgnoringSafeArea(.all)
                GeometryReader { geometry in
                    VStack(spacing: 20) {
                        Image(systemName: "person.fill")
                            .resizable()
                            .frame(width: geometry.size.width * 0.3, height: geometry.size.height * 0.16)
                            .foregroundColor(.white)
                            .padding(.top, 5)
                        HStack {
                            Text("닉네임 입력")
                                .foregroundColor(.white)
                                .padding(.top, 40)
                                .padding(.leading, 20)
                                .padding(.vertical, 5)
                            Spacer()
                        }
                        TextField("닉네임을 입력해 주세요", text: $nickname)
                            .padding()
                            .frame(width: geometry.size.width * 0.9, height: geometry.size.height / 20)
                            .background(Color.white)
                            .cornerRadius(10)
                            .padding(.horizontal, 10)
                        
                        Button(action: {
                            viewModel.saveNickname(nickname)
                            isNicknameSaved = true
                        }) {
                            Text("닉네임 저장")
                                .frame(width: geometry.size.width * 0.4, height: geometry.size.height / 30)
                                .padding()
                                .background(Color.gray)
                                .cornerRadius(10)
                                .foregroundColor(.white)
                        }
                        .padding(.top, 20)
                        
                        // 수정된 NavigationLink
                        NavigationLink(
                                destination: StartMessageView(loginViewModel: viewModel),
                            isActive: $isNicknameSaved
                        ) {
                            EmptyView()
                        }
                    }
                }
            }
        }
    }
}
