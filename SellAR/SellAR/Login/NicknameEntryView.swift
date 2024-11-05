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
                        Text("닉네임 입력")
                            .foregroundColor(.white)
                            .font(.title)
                            .padding(.top, 40)
                        
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
                                .frame(width: geometry.size.width * 0.9, height: geometry.size.height / 20)
                                .padding()
                                .background(Color.gray)
                                .cornerRadius(10)
                                .foregroundColor(.white)
                        }
                        .padding(.top, 20)
                        NavigationLink(destination: EmptyView(), isActive: $isNicknameSaved) {
                            EmptyView()
                        }
                    }
                }
            }
        }
    }
}
