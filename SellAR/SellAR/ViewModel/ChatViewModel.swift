//
//  ChatViewModel.swift
//  SellAR
//
//  Created by 박범규 on 11/5/24.
//

import SwiftUI
import Firebase


// Firestore와 연결된 ViewModel
class ChatViewModel: ObservableObject {
    @Published var messages: [ThreadDataType] = []
    @Published var chatRooms: [ChatRoom] = []
    @Published var chatUsers: [String: User] = [:] // 사용자 캐시
    @Published var lastReadMessageID: String?
    private var messageListener: ListenerRegistration?
    private var db = Firestore.firestore()
    
    var senderID: String
    
    init(senderID: String) {
        self.senderID = senderID
        // 현재 사용자 정보도 가져오기
        if !senderID.isEmpty {
            fetchUserInfo(userID: senderID)
        }
        fetchChatRooms()
    }
    // 메시지 구독 및 읽음 상태 추적
    func subscribeToMessages(for chatRoomID: String, currentUserID: String) {
        messageListener?.remove()
        
        let messagesRef = db.collection("chatRooms").document(chatRoomID).collection("messages")
        messageListener = messagesRef
            .order(by: "date", descending: false)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("메시지 구독 중 에러 발생: \(error.localizedDescription)")
                    return
                }
                
                guard let snapshot = snapshot else { return }
                
                let newMessages = snapshot.documentChanges.filter { $0.type == .added }
                for change in newMessages {
                    let messageData = change.document.data()
                    if let message = ThreadDataType(dictionary: messageData, id: change.document.documentID) {
                        self.messages.append(message)
                        
                        // 다른 사용자의 메시지이고 화면이 active 상태가 아닐 때만 unreadCount 증가
                        if message.userID != currentUserID {
                            self.incrementUnreadCount(for: chatRoomID, receiverID: currentUserID)
                        }
                    }
                }
                
                // 현재 사용자의 lastReadMessageID 업데이트
                if let lastMessage = self.messages.last {
                    self.updateLastReadMessage(chatRoomID: chatRoomID, userID: currentUserID, messageID: lastMessage.id)
                }
            }
    }
    
    // 마지막으로 읽은 메시지 ID 업데이트
    func updateLastReadMessage(chatRoomID: String, userID: String, messageID: String) {
        let chatRoomRef = db.collection("chatRooms").document(chatRoomID)
        chatRoomRef.updateData([
            "lastReadMessageID.\(userID)": messageID
        ]) { error in
            if let error = error {
                print("lastReadMessageID 업데이트 중 에러 발생: \(error.localizedDescription)")
            }
        }
    }
    
    // unreadCount 계산 및 업데이트
    func calculateUnreadCount(for chatRoomID: String, userID: String, otherUserID: String) {
        let chatRoomRef = db.collection("chatRooms").document(chatRoomID)
        
        chatRoomRef.getDocument { [weak self] document, error in
            guard let document = document,
                  let lastReadMessageIDs = document.data()?["lastReadMessageID"] as? [String: String] else { return }
            
            let lastReadMessageID = lastReadMessageIDs[userID] ?? ""
            
            // 마지막으로 읽은 메시지 이후의 메시지 수 계산
            let unreadMessages = self?.messages.filter { message in
                guard let messageIndex = self?.messages.firstIndex(where: { $0.id == lastReadMessageID }) else { return false }
                let messagePosition = self?.messages.firstIndex(where: { $0.id == message.id }) ?? 0
                return messagePosition > messageIndex && message.userID == otherUserID // senderID 대신 userID 사용
            }
            
            // unreadCount 업데이트
            chatRoomRef.updateData([
                "unreadCount.\(userID)": unreadMessages?.count ?? 0
            ])
        }
    }
    func incrementUnreadCount(for chatRoomID: String, receiverID: String) {
        let chatRoomRef = db.collection("chatRooms").document(chatRoomID)
        chatRoomRef.updateData([
            "unreadCount.\(receiverID)": FieldValue.increment(Int64(1))
        ]) { error in
            if let error = error {
                print("unreadCount 증가 중 에러 발생: \(error.localizedDescription)")
            } else {
                print("unreadCount 증가 성공")
            }
        }
    }
    func resetUnreadCount(for chatRoomID: String, userID: String) {
        guard !chatRoomID.isEmpty else { return }
        
        let chatRoomRef = db.collection("chatRooms").document(chatRoomID)
        chatRoomRef.updateData([
            "unreadCount.\(userID)": 0
        ]) { error in
            if let error = error {
                print("unreadCount 초기화 중 에러 발생: \(error.localizedDescription)")
            }
        }
    }
    
    
    // 사용자 정보 가져오기
    func fetchUserInfo(userID: String) {
        // userID가 비어있는지 확인
        guard !userID.isEmpty else {
            print("Error: User ID is empty")
            return
        }
        
        // 이미 캐시된 경우 스킵
        if chatUsers[userID] != nil { return }
        
        print("Fetching user info for ID: \(userID)")
        
        db.collection("users").document(userID).getDocument { [weak self] document, error in
            if let error = error {
                print("Error fetching user info: \(error.localizedDescription)")
                return
            }
            
            guard let document = document, document.exists else {
                print("User document doesn't exist for ID: \(userID)")
                return
            }
            
            if let userData = document.data() {
                print("Found user data: \(userData)")
                
                // 옵셔널 바인딩으로 안전하게 처리
                if let email = userData["email"] as? String,
                   let username = userData["username"] as? String {
                    let profileImageUrl = userData["profileImageUrl"] as? String
                    
                    DispatchQueue.main.async {
                        self?.chatUsers[userID] = User(
                            id: userID,
                            email: email,
                            username: username,
                            profileImageUrl: profileImageUrl
                        )
                    }
                } else {
                    print("Required user data fields missing")
                }
            }
        }
    }
    
    
    // 채팅방 생성 메서드
    func createNewChatRoom(with targetUser: User) {
        let participants = [self.senderID, targetUser.id]
        
        let newChatRoom: [String: Any] = [
            "name": targetUser.username,
            "profileImageURL": targetUser.profileImageUrl ?? "",
            "latestMessage": "대화를 시작해보세요",
            "latestTimestamp": Timestamp(date: Date()),
            "unreadCount": 0,
            "participants": participants
        ]
        
        db.collection("chatRooms").addDocument(data: newChatRoom) { [weak self] error in
            if let error = error {
                print("채팅방 생성 실패: \(error.localizedDescription)")
            } else {
                print("새 채팅방이 생성되었습니다")
                self?.fetchChatRooms()
            }
        }
    }
    
    func fetchChatRooms() {
            guard !senderID.isEmpty else {
                print("Error: Sender ID is empty")
                return
            }
            
            db.collection("chatRooms")
                .whereField("participants", arrayContains: senderID)
                .order(by: "latestTimestamp", descending: true)
                .addSnapshotListener { [weak self] querySnapshot, error in
                    guard let self = self else { return }
                    
                    if let error = error {
                        print("채팅방을 불러오는 중 에러 발생: \(error.localizedDescription)")
                        return
                    }
                    
                    guard let documents = querySnapshot?.documents else {
                        print("No chat rooms found")
                        return
                    }
                    
                    self.chatRooms = documents.compactMap { doc -> ChatRoom? in
                        let data = doc.data()
                        guard let participants = data["participants"] as? [String],
                              let unreadCounts = data["unreadCount"] as? [String: Int] else {
                            return nil
                        }
                        
                        // 상대방 정보 가져오기
                        if let otherUserID = participants.first(where: { $0 != self.senderID }) {
                            self.fetchUserInfo(userID: otherUserID)
                        }
                        
                        return ChatRoom(
                            id: doc.documentID,
                            name: data["name"] as? String ?? "알 수 없음",
                            profileImageURL: data["profileImageURL"] as? String ?? "",
                            latestMessage: data["latestMessage"] as? String ?? "",
                            timestamp: (data["latestTimestamp"] as? Timestamp)?.dateValue() ?? Date(),
                            participants: participants,
                            unreadCounts: unreadCounts
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
               .addDocument(data: newMessage) { [weak self] error in
                   guard let self = self else { return }
                   
                   if let error = error {
                       print("메시지 전송 중 에러 발생: \(error)")
                       return
                   }
                   
                   // 채팅방 정보 가져오기
                   self.db.collection("chatRooms").document(chatRoomID).getDocument { document, error in
                       guard let document = document,
                             let data = document.data(),
                             let participants = data["participants"] as? [String] else { return }
                       
                       // 받는 사람의 ID 찾기
                       if let receiverID = participants.first(where: { $0 != self.senderID }) {
                           // unreadCount 증가
                           self.incrementUnreadCount(for: chatRoomID, receiverID: receiverID)
                       }
                       
                       // 최신 메시지와 시간 업데이트
                       document.reference.updateData([
                           "latestMessage": content,
                           "latestTimestamp": Timestamp(date: Date())
                       ])
                   }
               }
       }
}
