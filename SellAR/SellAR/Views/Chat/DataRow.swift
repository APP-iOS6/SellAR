//
//  DataRow.swift
//  SellAR
//
//  Created by 박범규 on 11/5/24.
//

import SwiftUI
import Firebase
//import SDWebImageSwiftUI


// 개별 메시지 Row View
struct DataRow: View {
    var data: ThreadDataType
    var senderName: String
    var isSameDayAsPrevious: Bool
    @ObservedObject var chatViewModel: ChatViewModel
    @Environment(\.colorScheme) var colorScheme
    
    private var isCurrentUser: Bool {
        data.userID == chatViewModel.senderID
    }
    
    private var messageBackgroundColor: Color {
        isCurrentUser ? Color.indigo.opacity(1) : Color.cyan.opacity(1)
    }
    
    var body: some View {
        VStack(alignment: isCurrentUser ? .trailing : .leading) {
            if !isSameDayAsPrevious {
                Text(data.formattedDate)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.top, 8)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            
            HStack(alignment: .bottom, spacing: 15) {
                if !isCurrentUser {
                    // 상대방 프로필 이미지 및 닉네임 표시
                    if let user = chatViewModel.chatUsers[data.userID] {
                        VStack(alignment: .center, spacing: 4) {
                            Text(user.username)
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            AsyncImage(url: URL(string: user.profileImageUrl ?? "")) { image in
                                image.resizable()
                            } placeholder: {
                                Circle().fill(Color.gray)
                            }
                            .frame(width: 30, height: 30)
                            .clipShape(Circle())
                        }
                    }
                }
                
                VStack(alignment: isCurrentUser ? .trailing : .leading, spacing: 4) {
                    // 메시지 내용과 시간
                    HStack(alignment: .bottom, spacing: 4) {
                        if isCurrentUser {
                            Text(data.formattedTime)
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }
                        Text(data.content)
                            .padding(10)
                            .background(messageBackgroundColor)
                            .foregroundColor(.white)
                            .cornerRadius(15)
                        if !isCurrentUser {
                            Text(data.formattedTime)
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                if isCurrentUser {
                    // 현재 사용자 프로필 이미지
                    VStack(alignment: .center, spacing: 8) {
                        AsyncImage(url: URL(string: chatViewModel.chatUsers[chatViewModel.senderID]?.profileImageUrl ?? "")) { image in
                            image.resizable()
                        } placeholder: {
                            Circle().fill(Color.gray)
                        }
                        .frame(width: 30, height: 30)
                        .clipShape(Circle())
                    }
                }
            }
            .padding(.horizontal, 8)
        }
        .frame(maxWidth: .infinity, alignment: isCurrentUser ? .trailing : .leading)
    }
}
