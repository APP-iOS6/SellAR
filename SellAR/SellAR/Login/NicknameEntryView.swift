//
//  NicknameEntryView.swift
//  SellAR
//
//  Created by Mac on 11/4/24.
//

import SwiftUI

struct NicknameEntryView: View {
    @StateObject private var viewModel: LoginViewModel
    @State private var nickname = ""

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black
                    .edgesIgnoringSafeArea(.all)
                VStack(spacing: 20) {
                    Text("닉네임 입력")
                        .foregroundColor(.white)
                        .font(.title)
                    
                    TextField("닉네임을 입력해 주세요", text: $nickname)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .padding(.horizontal, 20)
                    
                    Button(action: {
                        viewModel.saveNickname(nickname)
                    }) {
                        Text("닉네임 저장")
                            .padding()
                            .background(Color.gray)
                            .cornerRadius(10)
                            .foregroundColor(.white)
                    }
                }
            }
        }
    }
}
