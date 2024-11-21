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
    @StateObject var viewModel: LoginViewModel
    @State private var selectedTab = 0
    @Environment(\.colorScheme) var colorScheme // 라이트/다크 모드 감지

    
    
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
                .badge(chatViewModel.totalUnreadCount > 0 ? String(chatViewModel.totalUnreadCount) : nil)
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
            .onChange(of: chatViewModel.totalUnreadCount) { newValue in
                print("Total unread messages: \(newValue)")
            }
            .onAppear {
                chatViewModel.fetchChatRooms() // 채팅방 목록과 안읽은 메시지 수를 가져옵니다
                updateTabBarAppearance() // 색상 업데이트
            }
        }
    }
    
    private func setupTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.systemBackground
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    
    private func updateTabBarAppearance() {
        let tabBarAppearance = UITabBar.appearance()
        let selectedColor = UIColor(red: 76/255, green: 127/255, blue: 200/255, alpha: 1)
        let defaultColor: UIColor = colorScheme == .light ? .gray : .white

        tabBarAppearance.tintColor = selectedColor // 선택된 탭 색상
        tabBarAppearance.unselectedItemTintColor = defaultColor // 선택되지 않은 탭 색상
    }
}


