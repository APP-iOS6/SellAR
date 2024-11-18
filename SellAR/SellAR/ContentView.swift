//
//  ContentView.swift
//  SellAR
//
//  Created by Juno Lee on 10/30/24.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel: LoginViewModel
    @StateObject private var chatViewModel: ChatViewModel

    
    init(viewModel: LoginViewModel) {
        self.viewModel = viewModel
        // viewModel.userID를 사용하여 ChatViewModel 초기화
        _chatViewModel = StateObject(wrappedValue: ChatViewModel(senderID: viewModel.userID ?? ""))
    }
    
    var body: some View {
        TabView {
            MainView(loginViewModel: viewModel)
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("홈")
                }
            
            StartMessageView(loginViewModel: viewModel)
                .tabItem {
                    Image(systemName: "2.square.fill")
                    Text("채팅")
                }
                .badge(chatViewModel.totalUnreadCount > 0 ? chatViewModel.totalUnreadCount : 0)
            
            MyPageView()
                .tabItem {
                    Image(systemName: "3.square.fill")
                    Text("마이페이지")
                }
                .environmentObject(viewModel)
        }
        .onChange(of: viewModel.userID ?? "") { userID in
            // userID가 변경될 때 ChatViewModel의 senderID 업데이트
            chatViewModel.senderID = userID ?? ""
            if !userID.isEmpty {
                chatViewModel.fetchChatRooms()
            }
        }
    }
}

#Preview {
    ContentView(viewModel: LoginViewModel())
}
