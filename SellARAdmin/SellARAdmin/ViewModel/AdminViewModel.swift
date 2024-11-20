//
//  AdminViewModel.swift
//  SellARAdmin
//
//  Created by 박범규 on 11/20/24.
//
import SwiftUI
import Firebase
import FirebaseCore

class AdminViewModel: ObservableObject {
    @Published var users: [User] = []
    @Published var userStats = UserStats()
    private let db = Firestore.firestore()
    private let adminId = "ADMIN_USER_ID" // 관리자 계정 ID 설정
    
    func fetchUsers() {
        db.collection("users")
            .getDocuments { [weak self] snapshot, error in
                if let documents = snapshot?.documents {
                    self?.users = documents.compactMap { doc -> User? in
                        let data = doc.data()
                        return User(
                            id: doc.documentID,
                            email: data["email"] as? String ?? "",
                            username: data["username"] as? String ?? "",
                            profileImageUrl: data["profileImageUrl"] as? String,
                            isBlocked: false  // isBlocked 상태를 기본값 false로 설정
                        )
                    }
                }
            }
    }
    
    func fetchUserStats(for userId: String) {
        // items 컬렉션에서 해당 사용자의 게시물 수 가져오기
        db.collection("items")
            .whereField("userId", isEqualTo: userId)
            .getDocuments { [weak self] snapshot, error in
                if let error = error {
                    print("Error fetching items: \(error)")
                    return
                }
                self?.userStats.postCount = snapshot?.documents.count ?? 0
            }
        
        // userReports 컬렉션에서 해당 사용자에 대한 신고 수 가져오기
        db.collection("userReports")
            .whereField("reportedUserId", isEqualTo: userId)
            .getDocuments { [weak self] snapshot, error in
                if let error = error {
                    print("Error fetching reports: \(error)")
                    return
                }
                self?.userStats.reportCount = snapshot?.documents.count ?? 0
            }
    }
    
    // 사용자 상태 토글 (앱 내부에서만 관리)
    func toggleUserStatus(_ user: User) {
        if let index = users.firstIndex(where: { $0.id == user.id }) {
            users[index].isBlocked.toggle()
        }
    }
    
    func sendWarningMessage(to user: User) {
        // 새로운 채팅방 생성 또는 기존 채팅방 찾기
        let chatRoomId = "\(adminId)_\(user.id)"
        let message = Message(
            id: UUID().uuidString,
            senderId: adminId,
            receiverId: user.id,
            content: "신고가 들어왔습니다. 주의 부탁드립니다.",
            timestamp: Date()
        )
        
        // Firestore에 메시지 저장
        db.collection("chatRooms").document(chatRoomId)
            .collection("messages")
            .document(message.id)
            .setData([
                "senderId": message.senderId,
                "receiverId": message.receiverId,
                "content": message.content,
                "timestamp": Timestamp(date: message.timestamp)
            ])
    }
    
    // 신고 생성 함수
    func createReport(reportedUserId: String, reporterId: String, reason: String) {
        let reportData: [String: Any] = [
            "reportedUserId": reportedUserId,
            "reporterId": reporterId,
            "reason": reason,
            "timestamp": Timestamp(date: Date())
        ]
        
        db.collection("userReports").addDocument(data: reportData) { error in
            if let error = error {
                print("Error creating report: \(error)")
                return
            }
            // 신고가 성공적으로 생성되면 해당 사용자의 통계를 다시 불러옵니다
            self.fetchUserStats(for: reportedUserId)
        }
    }
}
