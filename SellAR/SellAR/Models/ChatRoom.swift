//
//  ChatRoom.swift
//  SellAR
//
//  Created by Juno Lee on 11/1/24.
//
//
//import SwiftUI
//
//struct ChatRoom: Identifiable {
//    var id: String
//    var buyerId: String
//    var sellerId: String
//    var itemId: String
//    var lastMessage: String?
//    var lastUpdated: Date 
//}

import SwiftUI
// 채팅방 데이터 타입
struct ChatRoom: Identifiable {
    var id: String
    var name: String
    var profileImageURL: String
    var latestMessage: String
    var timestamp: Date
    var unreadCount: Int
    var participants: [String] // 참여자 ID 배열 추가
    
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        return formatter.string(from: timestamp)
    }
}
