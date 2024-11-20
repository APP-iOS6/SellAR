//
//  Untitled.swift
//  SellARAdmin
//
//  Created by 박범규 on 11/20/24.
//
import SwiftUI

struct Message: Identifiable {
    let id: String
    let senderId: String
    let receiverId: String
    let content: String
    let timestamp: Date
}
