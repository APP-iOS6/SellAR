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
//import SDWebImageSwiftUI

// ChatRoomRow 컴포넌트 분리
struct ChatRoomRow: View {
    let chatRoom: ChatRoom
    let currentUserID: String
    @ObservedObject var chatViewModel: ChatViewModel
    let hasLeftChat: Bool
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(spacing: 15) {
            if let otherUserID = chatRoom.participants.first(where: { $0 != currentUserID }) {
                if let otherUser = chatViewModel.chatUsers[otherUserID] {
                    // 사용자가 존재하는 경우
                    AsyncImage(url: URL(string: otherUser.profileImageUrl ?? "")) { image in
                        image.resizable()
                    } placeholder: {
                        Circle().fill(Color.gray)
                    }
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
                    
                    VStack(alignment: .leading, spacing: 5) {
                        Text(hasLeftChat ? "\(otherUser.username) (나갔음)" : otherUser.username)
                            .font(.headline)
                            .foregroundColor(hasLeftChat ? .gray : .primary)
                        
                        Text(hasLeftChat ? "대화가 종료되었습니다." : chatRoom.latestMessage)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .lineLimit(1)
                    }
                } else {
                    // 사용자가 존재하지 않는 경우
                    Circle()
                        .fill(Color.gray)
                        .frame(width: 50, height: 50)
                    
                    VStack(alignment: .leading, spacing: 5) {
                        Text("알 수 없음")
                            .font(.headline)
                            .foregroundColor(.gray)
                        
                        Text("사용자가 존재하지 않습니다")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .lineLimit(1)
                    }
                }
                
                Spacer()
                
                VStack {
                    Text(chatRoom.formattedTime)
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    if !hasLeftChat {
                        let unreadCount = chatRoom.getUnreadCount(for: currentUserID)
                        if unreadCount > 0 {
                            Text("\(unreadCount)")
                                .font(.caption)
                                .foregroundColor(.white)
                                .frame(minWidth: 20, minHeight: 20)
                                .background(Color.red)
                                .clipShape(Circle())
                        }
                    }
                }
            }
        }
        .padding(.vertical, 8)
    }
}
// 채팅방 내용 View
// ChatMessagesView - 메시지 목록을 표시하는 컴포넌트
struct ChatMessagesView: View {
    let messages: [ThreadDataType]
    let senderID: String
    @ObservedObject var chatViewModel: ChatViewModel
    
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
        .background(Color(UIColor.systemBackground).edgesIgnoringSafeArea(.all))
    }
    
    // 날짜 표시 여부를 결정하는 함수
    private func shouldShowDate(for index: Int) -> Bool {
        guard index > 0 else { return false }
        let currentMessage = messages[index]
        let previousMessage = messages[index - 1]
        return currentMessage.formattedDate == previousMessage.formattedDate
    }
}


// 메인 개별 채팅 기능 보여주기
struct ChatContentView: View {
    @ObservedObject var chatViewModel: ChatViewModel
    @State private var messageContent: String = ""
    @State private var otherUserName: String = "채팅방"
    @Environment(\.colorScheme) var colorScheme
    var chatRoomID: String
    var currentUserID: String
    var otherUserID: String
    
    var body: some View {
        VStack(spacing: 0) {
            
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
            
            // 메시지 입력 영역
            ChatInputView(messageContent: $messageContent) { content in
                chatViewModel.sendMessage(content: content, to: chatRoomID)
            }
        }
        .background(Color(UIColor.systemBackground))
        .onAppear {
            // 채팅방 입장 시 호출
            chatViewModel.enterChatRoom(chatRoomID: chatRoomID, currentUserID: currentUserID)
            
            // 상대방 유저 이름 설정
            if let otherUser = chatViewModel.chatUsers[otherUserID] {
                otherUserName = otherUser.username
            }
        }
        .onDisappear {
            // 채팅방 퇴장 시 호출
            chatViewModel.leaveChatRoom()
        }
        // 스크롤할 때마다 메시지를 읽은 것으로 처리
        .simultaneousGesture(
            DragGesture().onChanged { _ in
                chatViewModel.resetUnreadCount(for: chatRoomID, userID: currentUserID)
            }
        )
        .navigationTitle(otherUserName)  
        .navigationBarTitleDisplayMode(.inline)
        .onTapGesture {
            // 빈 화면을 클릭하면 키보드 내리기
            hideKeyboard()
        }
    }
    
    private func hideKeyboard() {
        UIApplication.shared.windows.first { $0.isKeyWindow }?.endEditing(true)
    }
}


// 메시지 입력을 위한 ChatInputView
struct ChatInputView: View {
    @Binding var messageContent: String
    var onSend: (String) -> Void
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(spacing: 12) {
            // 메시지 입력 필드
            TextField("메시지를 입력하세요", text: $messageContent)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(.systemGray6))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                )
            
            // 전송 버튼
            Button(action: {
                guard !messageContent.isEmpty else { return }
                onSend(messageContent)
                messageContent = ""
            }) {
                Image(systemName: "paperplane.fill")
                    .foregroundColor(.white)
                    .padding(10)
                    .background(Circle().fill(Color.blue))
                    .frame(width: 36, height: 36)
            }
            .disabled(messageContent.isEmpty)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color(UIColor.systemBackground))
    }
}
