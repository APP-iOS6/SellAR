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
    let currentUserID: String
    @ObservedObject var chatViewModel: ChatViewModel
    
    var body: some View {
        HStack(spacing: 15) {
            // 상대방의 프로필을 가져오기
            if let otherUserID = chatRoom.participants.first(where: { $0 != currentUserID }),
               let otherUser = chatViewModel.chatUsers[otherUserID] {
                AsyncImage(url: URL(string: otherUser.profileImageUrl ?? "")) { image in
                    image.resizable()
                } placeholder: {
                    Circle().fill(Color.gray)
                }
                .frame(width: 50, height: 50)
                .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 5) {
                    Text(otherUser.username)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(chatRoom.latestMessage)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
                
                Spacer()
                
                VStack {
                    Text(chatRoom.formattedTime)
                        .font(.caption)
                        .foregroundColor(.gray)
                    
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
    var chatRoomID: String
    var currentUserID: String
    var otherUserID: String
    
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
            
            // 메시지 입력 영역
            ChatInputView(messageContent: $messageContent) { content in
                chatViewModel.sendMessage(content: content, to: chatRoomID)
            }
        }
        .onAppear {
            // 채팅방 입장 시 호출
            chatViewModel.enterChatRoom(chatRoomID: chatRoomID, currentUserID: currentUserID)
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
        .navigationTitle("채팅방")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(UIColor.systemBackground).edgesIgnoringSafeArea(.all))
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
    
    var body: some View {
        HStack {
            TextField("메시지를 입력하세요", text: $messageContent)
                .frame(height: 35) // TextField의 높이를 늘림
                .padding(.horizontal, 15)
                .foregroundColor(Color.primary)
                .overlay {
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color(uiColor: .systemCyan), lineWidth: 2)
                }
                .padding(.vertical, 10)
            
            Spacer().frame(width: 15) // 간격을 10에서 15로 늘림
            
            Button(action: {
                guard !messageContent.isEmpty else { return }
                onSend(messageContent)
                messageContent = ""
            }) {
                Image(systemName: "paperplane.fill")
                    .foregroundColor(.blue)
                    .padding(.trailing, 5) // 오른쪽 패딩을 추가
                    .frame(width: 40, height: 40) // 버튼 영역을 명확하게 지정
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
}
