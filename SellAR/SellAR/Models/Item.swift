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
    // var category: String
     var location: String
    // var isSold: Bool
    
}
    // 이정민이 추가한 Item
    struct Item: Identifiable, Codable, Equatable {
        var id: String
        var userId: String
        var title: String
        var itemName: String
        var description: String
        var price: String
        var images: [String]
        var category: String
        var location: String
        var isSold: Bool
        var createdAt: Date?
        var updatedAt: Date?
        var thumbnailLink: String?
        var usdzLink: String
        
        init?(document: [String: Any]) {
            print("Document data: \(document)") // 데이터 출력
            
            guard let id = document["id"] as? String,
                  let itemName = document["itemName"] as? String else {
                print("Missing required fields: id or itemName")
                return nil
            }

            self.id = id
            self.userId = document["userId"] as? String ?? ""
            self.title = document["title"] as? String ?? ""
            self.itemName = itemName
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

