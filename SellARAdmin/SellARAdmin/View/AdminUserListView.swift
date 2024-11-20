//
//  Untitled 2.swift
//  SellARAdmin
//
//  Created by 박범규 on 11/20/24.
//

import SwiftUI
import Firebase

struct AdminUserListView: View {
    @StateObject private var viewModel = AdminViewModel()
    @State private var selectedUserId: String? // User ID로 selection 관리
    
    var body: some View {
        NavigationSplitView {
            List(viewModel.users, selection: $selectedUserId) { user in
                UserRowView(user: user)
                    .tag(user.id) // 각 행에 user.id를 tag로 지정
            }
            .navigationTitle("사용자 관리")
            .refreshable {
                viewModel.fetchUsers()
            }
        } detail: {
            if let userId = selectedUserId,
               let selectedUser = viewModel.users.first(where: { $0.id == userId }) {
                UserDetailView(user: selectedUser, viewModel: viewModel)
            } else {
                Text("사용자를 선택해주세요")
                    .font(.title2)
                    .foregroundColor(.gray)
            }
        }
        .onAppear {
            viewModel.fetchUsers()
        }
    }
}
