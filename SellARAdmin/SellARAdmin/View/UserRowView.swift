//
//  Untitled.swift
//  SellARAdmin
//
//  Created by 박범규 on 11/20/24.
//
import SwiftUI

struct UserRowView: View {
    let user: User
    
    var body: some View {
        HStack {
            AsyncImage(url: URL(string: user.profileImageUrl ?? "")) { image in
                image.resizable()
                    .scaledToFill()
            } placeholder: {
                Circle().fill(Color.gray)
            }
            .frame(width: 50, height: 50)
            .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(user.username)
                    .font(.headline)
                Text(user.email)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            if user.isBlocked {
                Text("정지됨")
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.red)
                    .cornerRadius(4)
            }
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle()) // 전체 영역을 탭 가능하게 만듦
    }
}
