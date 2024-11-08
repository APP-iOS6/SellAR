//
//  ChatData.swift
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
    
    // Firebase 데이터로부터 초기화하는 생성자 추가
    init?(dictionary: [String: Any], id: String? = nil) {
        guard let userID = dictionary["userID"] as? String,
              let content = dictionary["content"] as? String,
              let date = dictionary["date"] as? String else {
            return nil
        }
        
        self.id = id ?? UUID().uuidString
        self.userID = userID
        self.content = content
        self.date = date
        self.isRead = dictionary["isRead"] as? Bool ?? false
    }
    
    // 기본 생성자
    init(id: String, userID: String, content: String, date: String, isRead: Bool) {
        self.id = id
        self.userID = userID
        self.content = content
        self.date = date
        self.isRead = isRead
    }
}
