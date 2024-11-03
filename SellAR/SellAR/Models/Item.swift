//
//  Item.swift
//  SellAR
//
//  Created by Juno Lee on 11/1/24.
//

import SwiftUI
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
    var price: Double
    var images: [String]
    var category: String
    var location: String
    var isSold: Bool
}

