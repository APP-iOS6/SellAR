//
//  MyPageView.swift
//  SellAR
//
//  Created by 배문성 on 11/1/24.
//

import SwiftUI
import FirebaseAuth

struct MyPageView: View {
    
    @ObservedObject var itemStore = ItemStore()
    @EnvironmentObject var loginViewModel: LoginViewModel

    @StateObject private var userDataManager = UserDataManager()
    @State private var isLoading = true

    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: {
                    //버튼기능 추가예정
                }) {
                    Image(systemName: "chevron.left")
                        .resizable()
                        .frame(width: 11, height: 22)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(.gray)
                }
                .buttonStyle(PlainButtonStyle())
                
                if userDataManager.currentUser != nil {
                    Text("마이페이지")
                        .font(.system(size: 20))
                        .font(.title)
                        .fontWeight(.bold)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, alignment: .center)
                    
                    //프로필 수정버튼
                    NavigationLink(destination: ProfileFixView(userDataManager: userDataManager)) {
                        Image(systemName: "square.and.pencil" )
                            .resizable()
                            .frame(width: 28, height: 28)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                } else {
                    Spacer()
                }
            }
            .padding(.horizontal, 10)
            .padding(.bottom, 10)
            
            if isLoading {
                ProgressView()
            } else if let user = userDataManager.currentUser {
                loggedInView(user: user)
            } else {
                loggedOutView
            }
        }
            .padding(10)
            .navigationTitle("")
            .navigationBarHidden(true) // 상단여백제거
            .navigationBarBackButtonHidden(true) //네비게이션 시스템 백 버튼 젝
            .onAppear {
                userDataManager.fetchCurrentUser { _ in
                    isLoading = false
                }
            }
        }
    
    @ViewBuilder
    func loggedInView(user: User) -> some View {
        ScrollView {
            Spacer()
                .frame(height: 30)
            VStack(alignment: .center, spacing: 20) {
                // 프로필 사진
                if let imageUrl = user.profileImageUrl, let url = URL(string: imageUrl) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(width: 135, height: 135)
                                .clipShape(Circle())
                        case .success(let image):
                            image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 135, height: 135)
                            .clipShape(Circle())
                        case .failure:
                            Image(systemName: "person.circle.fill")
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 135, height: 135)
                                .clipShape(Circle())
                                .foregroundColor(.gray)
                        @unknown default:
                            EmptyView()
                    }
                }
            } else {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 135, height: 135)
                    .foregroundColor(.gray)
                                }
                // 닉네임 및 이메일
                VStack(alignment: .leading, spacing: 10) {
                    Text("이름")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack {
                        Image(systemName: "person.text.rectangle")
                        Text(user.username)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(10)
                    .foregroundColor(.white)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                }
                .padding(.bottom, 20)
                
                // 게시물 및 계정 관리 버튼들
                VStack(spacing: 15) {
                    Text("게시물")
                        .font(.system(size: 20))
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    NavigationLink(destination: ItemListView(itemStore: itemStore)) {
                        HStack {
                            Image(systemName: "list.bullet")
                            Text("내 글 목록")
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(10)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                        .foregroundColor(.white)
                    }
                    .padding(.bottom, 20)
                    
                    Text("계정관리")
                        .font(.system(size: 20))
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Button(action: {
                        loginViewModel.logout()
                        userDataManager.currentUser = nil
                    }) {
                        HStack {
                            Image(systemName: "person.fill")
                            Text("로그아웃")
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(.white)
                        .padding(10)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                    }
                   // NavigationLink for returning to ContentView after logout
                    NavigationLink(destination: ContentView(viewModel: loginViewModel).navigationBarBackButtonHidden(true), isActive: $loginViewModel.isMainViewActive) {
                        EmptyView()
                    }
                    
                    Button(action: {
                        // 회원 탈퇴 액션
                    }) {
                        HStack {
                            Image(systemName: "person.fill.xmark")
                            Text("회원 탈퇴")
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(.white)
                        .padding(10)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                    }

                }
            }
            .padding(10)
            .navigationTitle("")
            .navigationBarHidden(true) // 상단여백제거
        }
    }

    
    var loggedOutView: some View {
        ZStack {
            VStack(alignment: .center, spacing: 20) {
                
                Image(systemName: "person.fill")
//                Image("SellarLogoDark") 셀라아이콘 이미지 교체예정
                    .resizable()
                    .frame(width: 150, height: 150)

                    .padding()
                    .padding(.bottom,20)
                Text("표시할 마이페이지가 없어요.")
                    .foregroundColor(.white)
                    .padding(.bottom,10)
                Text("로그인하여 AR로 물건을 거래해보세요.")
                    .foregroundColor(.white)
                    .padding(.bottom,30)
                
                NavigationLink(destination: LoginView()) {
                    Text("로그인하기")
                        .frame(width: 150, height: 50)
                        .padding(2)
                        .foregroundColor(.white)
                        .background(Color.blue)
                        .cornerRadius(26.5)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
