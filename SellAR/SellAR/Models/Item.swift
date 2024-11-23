//
//  Item.swift
//  SellAR
//
//  Created by Juno Lee on 11/1/24.
//

import SwiftUI
import Foundation
import FirebaseFirestore

struct Items: Identifiable, Codable, Equatable {
    
    var id = UUID().uuidString
    var userId: String
    @ServerTimestamp var createdAt: Date?
    @ServerTimestamp var updatedAT: Date?
    var itemName: String
    var usdzLink: String?
    var usdzURL: URL? {
        guard let usdzLink else { return nil }
        return URL(string: usdzLink)
    }
    
    var thumbnailLink: String?
    var thumbnailURL: URL? {
        guard let thumbnailLink else { return nil }
        return URL(string: thumbnailLink)
    }
    var description: String
    var price: String
    var images: [String]
    var location: String
    var isSold: Bool = false
    var isReserved: Bool = false  // 예약 상태 추가
    
    

    // 생성된 시간의 읽기 쉬운 형식
    var formattedCreatedAt: String {
        guard let createdAt = createdAt else { return "알 수 없음" }
        return timeAgoSinceDate(createdAt)
    }
    
    // 시간이 경과한 문자열을 반환하는 함수
    private func timeAgoSinceDate(_ date: Date) -> String {
        let interval = Date().timeIntervalSince(date)
        
        let minutes = Int(interval / 60)
        let hours = minutes / 60
        let days = hours / 24
        let weeks = days / 7
        let months = weeks / 4
        let years = months / 12

        if years > 0 { return "\(years)년 전" }
        else if months > 0 { return "\(months)달 전" }
        else if weeks > 0 { return "\(weeks)주 전" }
        else if days > 0 { return "\(days)일 전" }
        else if hours > 0 { return "\(hours)시간 전" }
        else if minutes > 0 { return "\(minutes)분 전" }
        else { return "방금 전" }
    }
}
