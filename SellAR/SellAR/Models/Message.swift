//
//  Message.swift
//  SellAR
//
//  Created by Juno Lee on 11/1/24.
//

import SwiftUI

struct Message: Identifiable {
    var id: String
    var chatRoomId: String
    var senderId: String
    var text: String
    var sentAt: Date
}
