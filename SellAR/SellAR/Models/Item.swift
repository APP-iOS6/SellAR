//
//  Item.swift
//  SellAR
//
//  Created by Juno Lee on 11/1/24.
//

import Foundation
import FirebaseFirestore

struct Item: Identifiable, Codable, Equatable {
    var id: String
    var userId: String
    var title: String
    var description: String
    var price: String
    var images: [String]
    var category: String
    var location: String
    var isSold: Bool
    @ServerTimestamp var createdAt: Date?
    @ServerTimestamp var updatedAt: Date?
    var thumbnailLink: String?
    var usdzLink: String

    init?(document: [String: Any]) {
        guard let id = document["id"] as? String,
              let title = document["itemName"] as? String else {
            return nil
        }

        self.id = id
        self.userId = document["userId"] as? String ?? ""
        self.title = title
        self.description = document["description"] as? String ?? ""
        self.price = document["price"] as? String ?? "0"
        self.images = [document["thumbnailLink"] as? String ?? "placeholder"]
        self.category = "카테고리" // 기본 카테고리 설정
        self.location = document["location"] as? String ?? ""
        self.isSold = document["isSold"] as? Bool ?? false
        self.createdAt = (document["createdAt"] as? Timestamp)?.dateValue() ?? Date()
        self.updatedAt = (document["updatedAT"] as? Timestamp)?.dateValue() ?? Date()
        self.thumbnailLink = document["thumbnailLink"] as? String ?? ""
        self.usdzLink = document["usdzLink"] as? String ?? ""
    }
}
