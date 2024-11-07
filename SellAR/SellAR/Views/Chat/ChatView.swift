//
//  ChatView.swift
//  SellAR
//
//  Created by 박범규 on 11/5/24.
//
//
//  ChatView.swift
//  SellAR
//
//  Created by 박범규 on 11/5/24.
//

import SwiftUI
import Firebase

// ChatRoomRow 컴포넌트 분리
struct ChatRoomRow: View {
    let chatRoom: ChatRoom
    
    var body: some View {
        HStack(spacing: 15) {
            AsyncImage(url: URL(string: chatRoom.profileImageURL)) { image in
                image.resizable()
            } placeholder: {
                Circle().fill(Color.gray)
            }
            .frame(width: 50, height: 50)
            .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 5) {
                Text(chatRoom.name)
                    .font(.headline)
                    .foregroundColor(.black)
                
                Text(chatRoom.latestMessage)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }
            
            Spacer()
            
            if chatRoom.unreadCount > 0 {
                Text("\(chatRoom.unreadCount)")
                    .padding(8)
                    .background(Color.red)
                    .clipShape(Circle())
                    .foregroundColor(.white)
            }
            
            Text(chatRoom.formattedTime)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding(.vertical, 8)
    }
}

// 채팅방 내용 View
// ChatMessagesView - 메시지 목록을 표시하는 컴포넌트
struct ChatMessagesView: View {
    let messages: [ThreadDataType]  // MessageData -> ThreadDataType으로 수정
    let senderID: String
    @ObservedObject var chatViewModel: ChatViewModel  // ViewModel 추가
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 4) {
                ForEach(0..<messages.count, id: \.self) { index in
                    let message = messages[index]
                    let isSameDayAsPrevious = shouldShowDate(for: index)
                    
                    DataRow(
                        data: message,
                        senderName: senderID,
                        isSameDayAsPrevious: isSameDayAsPrevious,
                        chatViewModel: chatViewModel
                    )
                }
            }
            .padding(.vertical)
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }
    
    // 날짜 표시 여부를 결정하는 함수
    private func shouldShowDate(for index: Int) -> Bool {
        guard index > 0 else { return false }
        let currentMessage = messages[index]
        let previousMessage = messages[index - 1]
        return currentMessage.formattedDate == previousMessage.formattedDate
    }
}


// 메인 ChatContentView
struct ChatContentView: View {
    @ObservedObject var chatViewModel: ChatViewModel
    @State private var messageContent: String = ""
    var chatRoomID: String
    
    var body: some View {
        VStack(spacing: 0) {
            // 메시지 목록
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 4) {
                        ForEach(0..<chatViewModel.messages.count, id: \.self) { index in
                            let message = chatViewModel.messages[index]
                            let isSameDayAsPrevious = index > 0 &&
                                chatViewModel.messages[index - 1].formattedDate == message.formattedDate
                            
                            DataRow(
                                data: message,
                                senderName: chatViewModel.senderID,
                                isSameDayAsPrevious: isSameDayAsPrevious,
                                chatViewModel: chatViewModel
                            )
                            .id(index)
                        }
                    }
                    .padding(.vertical)
                }
                .onChange(of: chatViewModel.messages.count) { _ in
                    // 새 메시지가 추가되면 자동으로 스크롤
                    if !chatViewModel.messages.isEmpty {
                        withAnimation {
                            proxy.scrollTo(chatViewModel.messages.count - 1, anchor: .bottom)
                        }
                    }
                }
            }
            
          
            Divider()
                .background(Color.gray)
            
            // 메시지 입력 영역
            ChatInputView(messageContent: $messageContent) { content in
                chatViewModel.sendMessage(content: content, to: chatRoomID)
            }
        }
        .onAppear {
            chatViewModel.fetchMessages(for: chatRoomID)
        }
        .navigationTitle("채팅방")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color.primary.edgesIgnoringSafeArea(.all))
    }
}

// 메시지 입력을 위한 ChatInputView
struct ChatInputView: View {
    @Binding var messageContent: String
    let onSend: (String) -> Void
    
    var body: some View {
        HStack {
            TextField("메시지를 입력하세요", text: $messageContent)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
                .foregroundColor(Color.primary)
            
            Button(action: {
                guard !messageContent.isEmpty else { return }
                onSend(messageContent)
                messageContent = ""
            }) {
                Image(systemName: "paperplane.fill")
                    .foregroundColor(.blue)
                    .padding(.trailing)
            }
        }
        .padding(.vertical, 8)
        .background(Color.primary.opacity(0.9))
    }
}
