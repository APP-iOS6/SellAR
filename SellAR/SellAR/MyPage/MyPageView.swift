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
    @Environment(\.colorScheme) var colorScheme // 다크모드/라이트모드 관련
    
    var body: some View {
        ZStack {
            Color(colorScheme == .dark ?
                  Color(red: 36 / 255, green: 36 / 255, blue: 39 / 255) : Color(red: 255 / 255, green: 255 / 255, blue: 255 / 255))
                .edgesIgnoringSafeArea(.all)
            // 진회색 : 순백색
            // 다크모드 : 라이트모드 순서
            VStack(spacing: 0) {
                HStack {
                    //                Button(action: {
                    //                    //버튼기능 추가예정
                    //                }) {
                    //                    Image(systemName: "chevron.left")
                    //                        .resizable()
                    //                        .frame(width: 11, height: 22)
                    //                        .frame(maxWidth: .infinity, alignment: .leading)
                    //                        .foregroundColor(.gray)
                    //                }
                    //                .buttonStyle(PlainButtonStyle())
                    
                    if userDataManager.currentUser != nil {
                        
                        Spacer()
                            .frame(maxWidth: .infinity, alignment: .leading) // 뒤로가기 버튼 대신한 여백생성으로 가운데 정렬
                        
                        Text("마이페이지")
                            .foregroundColor(colorScheme == .dark ?
                            Color(red: 243 / 255, green: 242 / 255, blue: 248 / 255) : Color(red: 16 / 255, green: 16 / 255, blue: 17 / 255)) // 흐린흰색:검정
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
                                .foregroundColor(Color(red: 76 / 255, green: 127 / 255, blue: 200 / 255)) //연파랑
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
                            Image(systemName: "person")
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 135, height: 135)
                                .foregroundColor(Color(red: 76 / 255, green: 127 / 255, blue: 200 / 255)) //연파랑
                                .clipShape(Circle())
                        @unknown default:
                            EmptyView()
                    }
                }
            } else {
                Image(systemName: "person")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(40)
                    .frame(width: 135, height: 135)
                    .foregroundColor(Color(red: 76 / 255, green: 127 / 255, blue: 200 / 255)) // 연파랑
                    .background(colorScheme == .dark ?
                        Color(red: 16 / 255, green: 16 / 255, blue: 17 / 255) : Color(red: 243 / 255, green: 242 / 255, blue: 248 / 255)) //검정:연회색
                    .clipShape(Circle())
                                }
                // 닉네임 및 이메일
                VStack(alignment: .leading, spacing: 10) {
                    Text("이름")
                        .font(.headline)
                        .foregroundColor(colorScheme == .dark ?
                        Color(red: 243 / 255, green: 242 / 255, blue: 248 / 255) : Color(red: 16 / 255, green: 16 / 255, blue: 17 / 255)) // 흐린흰색:검정
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack {
                        Image(systemName: "person.text.rectangle")
                            .foregroundColor(Color(red: 76 / 255, green: 127 / 255, blue: 200 / 255)) // 연파랑
                        Text(user.username)
                    }
                    .padding(15) // 검정칸 크기
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(colorScheme == .dark ?
                        Color(red: 243 / 255, green: 242 / 255, blue: 248 / 255) : Color(red: 16 / 255, green: 16 / 255, blue: 17 / 255)) // 흐린흰색:검정
                    .background(colorScheme == .dark ?
                        Color(red: 16 / 255, green: 16 / 255, blue: 17 / 255) : Color(red: 243 / 255, green: 242 / 255, blue: 248 / 255)) //검정:연회색
                    .cornerRadius(10)
                }
                .padding(.bottom, 20)
                
                // 게시물 및 계정 관리 버튼들
                VStack(spacing: 10) {
                    Text("게시물")
                        .font(.system(size: 20))
                        .font(.headline)
                        .foregroundColor(colorScheme == .dark ?
                            Color(red: 243 / 255, green: 242 / 255, blue: 248 / 255) : Color(red: 16 / 255, green: 16 / 255, blue: 17 / 255)) // 흐린흰색:검정
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    NavigationLink(destination: ItemListView(itemStore: itemStore)) {
                        HStack {
                            Image(systemName: "list.bullet")
                                .foregroundColor(Color(red: 76 / 255, green: 127 / 255, blue: 200 / 255)) // 연파랑
                            Text("내 글 목록")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(Color(red: 76 / 255, green: 127 / 255, blue: 200 / 255)) // 연파랑
                        }
                        .padding(15)
                        .background(colorScheme == .dark ?
                            Color(red: 16 / 255, green: 16 / 255, blue: 17 / 255) : Color(red: 243 / 255, green: 242 / 255, blue: 248 / 255)) //검정:연회색
                        .cornerRadius(10)
                        .foregroundColor(colorScheme == .dark ?
                            Color(red: 243 / 255, green: 242 / 255, blue: 248 / 255) : Color(red: 16 / 255, green: 16 / 255, blue: 17 / 255)) // 흰색:검정
                    }
                    .padding(.bottom, 20)
                    
                    Text("계정관리")
                        .font(.system(size: 20))
                        .font(.headline)
                        .foregroundColor(colorScheme == .dark ?
                            Color(red: 243 / 255, green: 242 / 255, blue: 248 / 255) : Color(red: 16 / 255, green: 16 / 255, blue: 17 / 255)) // 흐린흰색:검정
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Button(action: {
                        loginViewModel.logout()
                        userDataManager.currentUser = nil
                    }) {
                        HStack {
                            Image(systemName: "person.fill")
                                .foregroundColor(Color(red: 76 / 255, green: 127 / 255, blue: 200 / 255)) // 연파랑
                            Text("로그아웃")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(Color(red: 76 / 255, green: 127 / 255, blue: 200 / 255)) // 연파랑
                            
                        }
                        .padding(15) //검정칸 크기
                        .foregroundColor(colorScheme == .dark ?
                            Color(red: 243 / 255, green: 242 / 255, blue: 248 / 255) : Color(red: 16 / 255, green: 16 / 255, blue: 17 / 255)) // 흰색:검정
                        .background(colorScheme == .dark ?
                            Color(red: 16 / 255, green: 16 / 255, blue: 17 / 255) : Color(red: 243 / 255, green: 242 / 255, blue: 248 / 255)) //검정:연회색
                        .cornerRadius(10)
                    }
                    NavigationLink(destination: ContentView(viewModel: loginViewModel).navigationBarBackButtonHidden(true), isActive: $loginViewModel.isMainViewActive) {
                        EmptyView()
                    }
                    
                    Button(action: {
                        // 회원 탈퇴 액션
                    }) {
                        HStack {
                            Image(systemName: "person.fill.xmark")
                                .foregroundColor(Color(red: 76 / 255, green: 127 / 255, blue: 200 / 255)) // 연파랑
                            Text("회원 탈퇴")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(Color(red: 76 / 255, green: 127 / 255, blue: 200 / 255)) // 연파랑
                        }
                        .padding(15) //검정칸 크기
                        .foregroundColor(colorScheme == .dark ?
                            Color(red: 243 / 255, green: 242 / 255, blue: 248 / 255) : Color(red: 16 / 255, green: 16 / 255, blue: 17 / 255)) // 흐린흰색:검정
                        .background(colorScheme == .dark ?
                            Color(red: 16 / 255, green: 16 / 255, blue: 17 / 255) : Color(red: 243 / 255, green: 242 / 255, blue: 248 / 255)) //검정:연회색
                        
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
                
                Image(colorScheme == .dark ? "SellarLogoDark" : "SellarLogoWhite")
                    .resizable()
                    .frame(width: 150, height: 150)
                    .padding()
                    .padding(.bottom,10)
                
                Text("로그인이 필요합니다.")
                    .fontWeight(.bold)
                    .foregroundColor(colorScheme == .dark ?
                        Color(red: 243 / 255, green: 242 / 255, blue: 248 / 255) : Color(red: 16 / 255, green: 16 / 255, blue: 17 / 255)) // 흐린흰색:검정
                    .padding(.bottom,30)
                
                NavigationLink(destination: LoginView()) {
                    Text("로그인하기")
                        .frame(width: 150, height: 50)
                        .padding(2)
                        .foregroundColor(Color(red: 243 / 255, green: 242 / 255, blue: 248 / 255)) // 흐린흰색
                        .background(Color(red: 76 / 255, green: 127 / 255, blue: 200 / 255)) // 연파랑
                        .cornerRadius(26.5)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
