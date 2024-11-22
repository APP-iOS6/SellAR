//
//  Untitled.swift
//  SellARAdmin
//
//  Created by 박범규 on 11/22/24.
//
import SwiftUI
import Firebase
import FirebaseAuth

struct AdminApp: View {
    @StateObject private var authViewModel = AdminAuthViewModel()
    
    var body: some View {
        Group {
            if authViewModel.isAuthenticated {
                AdminUserListView()
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("로그아웃") {
                                authViewModel.signOut()
                            }
                        }
                    }
            } else {
                AdminLoginView()
            }
        }
    }
}
