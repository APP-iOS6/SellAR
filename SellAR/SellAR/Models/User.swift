//
//  User.swift
//  SellAR
//
//  Created by Juno Lee on 11/1/24.
//

import SwiftUI

struct User: Identifiable, Codable {
    var id: String
    var email: String
    var username: String
    var profileImageUrl: String?
}
