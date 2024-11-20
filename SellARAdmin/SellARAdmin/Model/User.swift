//
//  User.swift
//  SellARAdmin
//
//  Created by 박범규 on 11/20/24.
//
import SwiftUI

struct User: Identifiable, Hashable {
    let id: String
    let email: String
    let username: String
    let profileImageUrl: String?
    var isBlocked: Bool
    
    // Hashable 구현 개선
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(email)
        hasher.combine(username)
        hasher.combine(isBlocked)
    }
    
    static func == (lhs: User, rhs: User) -> Bool {
        lhs.id == rhs.id &&
        lhs.email == rhs.email &&
        lhs.username == rhs.username &&
        lhs.isBlocked == rhs.isBlocked
    }
}
