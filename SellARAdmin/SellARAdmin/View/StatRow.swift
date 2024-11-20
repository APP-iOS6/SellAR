//
//  Untitled.swift
//  SellARAdmin
//
//  Created by 박범규 on 11/20/24.
//
import SwiftUI

struct StatRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.gray)
            Spacer()
            Text(value)
                .bold()
        }
    }
}
