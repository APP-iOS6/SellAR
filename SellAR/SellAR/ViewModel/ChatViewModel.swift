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
                   if let error = error {
                       print("채팅방을 불러오는 중 에러 발생: \(error.localizedDescription)")
                       return
                   }
                   
                   guard let documents = querySnapshot?.documents else {
                       print("No chat rooms found")
                       return
                   }
                   
                   self?.chatRooms = documents.compactMap { doc -> ChatRoom? in
                       let data = doc.data()
                       guard let participants = data["participants"] as? [String] else {
                           print("No participants found in chat room")
                           return nil
                       }
                       
                       // 상대방 ID 찾기
                       if let otherUserID = participants.first(where: { $0 != self?.senderID }) {
                           // 상대방 정보 가져오기
                           self?.fetchUserInfo(userID: otherUserID)
                       }
                       
                       return ChatRoom(
                           id: doc.documentID,
                           name: data["name"] as? String ?? "알 수 없음",
                           profileImageURL: data["profileImageURL"] as? String ?? "",
                           latestMessage: data["latestMessage"] as? String ?? "",
                           timestamp: (data["latestTimestamp"] as? Timestamp)?.dateValue() ?? Date(),
                           unreadCount: data["unreadCount"] as? Int ?? 0,
                           participants: participants
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
