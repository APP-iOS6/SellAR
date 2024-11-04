//
//  Item.swift
//  SellAR
//
//  Created by Juno Lee on 11/1/24.
//

import SwiftUI

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
}

