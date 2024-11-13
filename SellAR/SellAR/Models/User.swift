//
//  User.swift
//  SellAR
//
//  Created by Juno Lee on 11/1/24.
//

import SwiftUI

struct User: Identifiable {
    var id: String
    var email: String
    var username: String
    var profileImageUrl: String?
    var userLocation: String
    var intro:String
}
