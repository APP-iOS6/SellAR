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

// 메시지 데이터 타입
struct ThreadDataType: Identifiable {
    var id: String
    var userID: String
    var content: String
    var date: String
    var isRead: Bool
    
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        if let date = ISO8601DateFormatter().date(from: self.date) {
            return formatter.string(from: date)
        }
        return ""
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        if let date = ISO8601DateFormatter().date(from: self.date) {
            return formatter.string(from: date)
        }
        return ""
    }
}

// 채팅방 데이터 타입
struct ChatRoom: Identifiable {
    var id: String
    var name: String
    var profileImageURL: String
    var latestMessage: String
    var timestamp: Date
    var unreadCount: Int
    
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        return formatter.string(from: timestamp)
    }
}

// Firestore와 연결된 ViewModel
class ChatViewModel: ObservableObject {
    @Published var messages: [ThreadDataType] = []
    @Published var chatRooms: [ChatRoom] = []
    private var db = Firestore.firestore()
    
    var senderID: String
    
    init(senderID: String) {
        self.senderID = senderID
        fetchChatRooms()
    }
    
    func fetchChatRooms() {
        db.collection("chatRooms").order(by: "latestTimestamp", descending: true)
            .addSnapshotListener { querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    print("채팅방을 불러오는 중 에러 발생: \(error?.localizedDescription ?? "알 수 없는 에러")")
                    return
                }
                
                self.chatRooms = documents.map { doc in
                    let data = doc.data()
                    return ChatRoom(
                        id: doc.documentID,
                        name: data["name"] as? String ?? "알 수 없음",
                        profileImageURL: data["profileImageURL"] as? String ?? "",
                        latestMessage: data["latestMessage"] as? String ?? "",
                        timestamp: (data["latestTimestamp"] as? Timestamp)?.dateValue() ?? Date(),
                        unreadCount: data["unreadCount"] as? Int ?? 0
                    )
                }
            }
    }
    
    func fetchMessages(for chatRoomID: String) {
        db.collection("chatRooms").document(chatRoomID).collection("messages")
            .order(by: "date", descending: false)
            .addSnapshotListener { querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    print("메시지를 불러오는 중 에러 발생: \(error?.localizedDescription ?? "알 수 없는 에러")")
                    return
                }
                
                self.messages = documents.map { doc in
                    let data = doc.data()
                    return ThreadDataType(
                        id: doc.documentID,
                        userID: data["userID"] as? String ?? "",
                        content: data["content"] as? String ?? "",
                        date: data["date"] as? String ?? "",
                        isRead: data["isRead"] as? Bool ?? false
                    )
                }
            }
    }
    
    func sendMessage(content: String, to chatRoomID: String) {
        let date = ISO8601DateFormatter().string(from: Date())
        let newMessage: [String: Any] = [
            "userID": senderID,
            "content": content,
            "date": date,
            "isRead": false
        ]
        
        db.collection("chatRooms").document(chatRoomID).collection("messages")
            .addDocument(data: newMessage) { error in
                if let error = error {
                    print("문서를 추가하는 중 에러 발생: \(error)")
                    return
                }
                
                // 최신 메시지와 시간 업데이트
                self.db.collection("chatRooms").document(chatRoomID).updateData([
                    "latestMessage": content,
                    "latestTimestamp": Timestamp(date: Date())
                ])
            }
    }
}

// 개별 메시지 Row View
struct DataRow: View {
    var data: ThreadDataType
    var senderName: String
    var isSameDayAsPrevious: Bool
    var messageBackgroundColor: Color {
        return data.userID == senderName ? Color.orange : Color.green
    }
    
    var body: some View {
        VStack(alignment: data.userID == senderName ? .trailing : .leading) {
            if !isSameDayAsPrevious {
                Text(data.formattedDate)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.top, 8)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            
            HStack {
                Text(data.content)
                    .padding(8)
                    .background(messageBackgroundColor)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .font(.body)
                
                Text(data.formattedTime)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
        .frame(maxWidth: .infinity, alignment: data.userID == senderName ? .trailing : .leading)
    }
}

// 채팅방 리스트 View
struct StartMessageView: View {
    @ObservedObject var viewModel: ChatViewModel
    
    var body: some View {
        NavigationView {
            List(viewModel.chatRooms) { chatRoom in
                NavigationLink(destination: ChatContentView(chatViewModel: viewModel, chatRoomID: chatRoom.id)) {
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
                                .foregroundColor(.white)
                            
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
            .listStyle(PlainListStyle())
            .background(Color.black.edgesIgnoringSafeArea(.all))
            .navigationTitle("채팅")
            .onAppear {
                viewModel.fetchChatRooms()
            }
        }
        .background(Color.black)
    }
}

// 채팅방 내용 View
struct ChatContentView: View {
    @ObservedObject var chatViewModel: ChatViewModel
    @State private var messageContent: String = ""
    var chatRoomID: String
    
    var body: some View {
        VStack {
            ScrollView {
                VStack(spacing: 4) {
                    ForEach(Array(chatViewModel.messages.enumerated()), id: \.element.id) { index, data in
                        DataRow(
                            data: data,
                            senderName: chatViewModel.senderID,
                            isSameDayAsPrevious: index > 0 && chatViewModel.messages[index - 1].formattedDate == data.formattedDate
                        )
                    }
                }
            }
            .background(Color.black.edgesIgnoringSafeArea(.all))
            
            HStack {
                TextField("메시지를 입력하세요", text: $messageContent)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(10)

                Button(action: {
                    chatViewModel.sendMessage(content: messageContent, to: chatRoomID)
                    messageContent = ""
                }) {
                    Text("Send").font(.body).foregroundColor(.white)
                }
                .padding(10)
            }
            .background(Color.black)
        }
        .onAppear {
            chatViewModel.fetchMessages(for: chatRoomID)
        }
        .navigationTitle("채팅방")
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }
}
