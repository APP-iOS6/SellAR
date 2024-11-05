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
}
