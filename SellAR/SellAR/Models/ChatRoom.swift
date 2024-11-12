//
//  ChatRoom.swift
//  SellAR
//
//  Created by Juno Lee on 11/1/24.
//
//
import SwiftUI
// 채팅방 데이터 타입
struct ChatRoom: Identifiable {
    var id: String
    var name: String
    var profileImageURL: String
    var latestMessage: String
    var timestamp: Date
    var participants: [String] // 참여자 ID 배열 추가
    var unreadCount: [String: Int] // 변경: 개별 사용자별 unreadCount를 저장
    
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        return formatter.string(from: timestamp)
    }
    // 현재 사용자의 unreadCount만 반환하는 계산 프로퍼티
    func getUnreadCount(for userID: String) -> Int {
        return unreadCount[userID] ?? 0
    }
}
