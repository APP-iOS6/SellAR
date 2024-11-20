//
//  ContentView.swift
//  SellAR
//
//  Created by Juno Lee on 10/30/24.
//

import SwiftUI
import FirebaseAuth

struct ContentView: View {
    @StateObject private var chatViewModel = ChatViewModel(senderID: Auth.auth().currentUser?.uid ?? "")
    @ObservedObject var viewModel: LoginViewModel
    @State private var selectedTab = 0
    
    var body: some View {
        Group {
            TabView(selection: $selectedTab) {
                // 홈 탭
                NavigationStack {
                    MainView(loginViewModel: viewModel)
                }
                .tabItem {

                    Image(systemName: selectedTab == 0 ? "house.fill" : "house")

                    Text("홈")
                }
                .tag(0)
                
                // 채팅 탭
                NavigationStack {
                    StartMessageView(loginViewModel: viewModel)
                        .environmentObject(chatViewModel)
                }
                .tabItem {
                    Image(systemName: selectedTab == 1 ? "message.fill" : "message")
                    Text("채팅")
                }
                .badge(chatViewModel.totalUnreadCount > 0 ? String(chatViewModel.totalUnreadCount) : "0")
                .tag(1)
                
                // 마이페이지 탭
                NavigationStack {
                    MyPageView()
                        .environmentObject(viewModel)
                }
                .tabItem {

                    Image(systemName: selectedTab == 2 ? "person.fill" : "person")
                    Text("My")

                }
                .tag(2)
            }
            .tint(.black)
            .onChange(of: chatViewModel.totalUnreadCount) { newValue in
                print("Total unread messages: \(newValue)")
            }
            .onAppear {
                chatViewModel.fetchChatRooms() // 채팅방 목록과 안읽은 메시지 수를 가져옵니다
            }
        }
    }
}

#Preview {
    ContentView(viewModel: LoginViewModel())
}
