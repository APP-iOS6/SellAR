//
//  Item.swift
//  SellAR
//
//  Created by Juno Lee on 11/1/24.
//

import Foundation
import FirebaseFirestore

struct Item: Identifiable {
    var id: String
    var userId: String
    var title: String
    var description: String
    var price: Double
    var images: [String]
    var category: String
    var location: String
    var isSold: Bool
    var createdAt: Date
    var updatedAt: Date
    var thumbnailLink: String
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
        self.price = Double(document["price"] as? String ?? "0") ?? 0
        self.images = [(document["thumbnailLink"] as? String ?? "placeholder")]
        self.category = "카테고리" // 카테고리를 기본값으로 설정
        self.location = document["location"] as? String ?? ""
        self.isSold = false
        self.createdAt = (document["createdAt"] as? Timestamp)?.dateValue() ?? Date()
        self.updatedAt = (document["updatedAT"] as? Timestamp)?.dateValue() ?? Date()
        self.thumbnailLink = document["thumbnailLink"] as? String ?? ""
        self.usdzLink = document["usdzLink"] as? String ?? ""
    }

}


