//
//  User.swift
//  SellAR
//
//  Created by Juno Lee on 11/1/24.
//

import SwiftUI

@Observable
struct User: Identifiable {
    var id: String
    var email: String
    var username: String
    var profileImageUrl: String?
}
