//
//  ContentView.swift
//  SellAR
//
//  Created by Juno Lee on 10/30/24.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel: LoginViewModel

    let userdata = User( //UserData 였음
        id: "12345",
        email: "aaaaaa@gmail.com",
        username: "가나다",
        profileImageUrl: nil
//        userLocation: "서울시 강남구",
//        intro: "자신을 소개해주세요"
    )

    var body: some View {
        TabView {
            MainView()
                .tabItem {
                    Image(systemName: "1.square.fill")
                    Text("홈")
                }
            StartMessageView(loginViewModel: viewModel)
                .tabItem {
                    Image(systemName: "2.square.fill")
                    Text("채팅")
                }
            MyPageView()
                .tabItem {
                    Image(systemName: "3.square.fill")
                    Text("마이페이지")
                }
                .font(.headline)
        }
    }
}

#Preview {
    ContentView(viewModel: LoginViewModel())
}
