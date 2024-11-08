//
//  MyPageView.swift
//  SellAR
//
//  Created by 배문성 on 11/1/24.
//

import SwiftUI

struct MyPageView: View {
    
    let userdata: UserData
    //추후 데이터 연결 공간
    //    @State private var id: String = UUID().uuidString
    //    @State private var email: String = "aaaaaa@gmail.com"
    //    @State private var username: String = "가나다"
    //    @State private var profileImageUrl: String = "image"
    //    @State private var intro: String = "자신을 소개해주세요."
    //    @State private var userlocation: String = "서울시 강남구"
    //    @State private var isLoggedIn: Bool = false //로그인상태 확인변수
    @ObservedObject var itemStore = ItemStore()
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
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
                        
                        //프로필 수정버튼
                        NavigationLink(destination: ProfileFixView()) {
                            Image(systemName: "square.and.pencil" )
                                .resizable()
                                .frame(width: 28, height: 28)
                                .foregroundColor(.gray)
                            
                        }
                    }
                    .padding(.horizontal, 10)
                    .padding(.bottom, 10)
                    
                    
                    ScrollView {
                        Spacer()
                            .frame(height: 5)
                        // 프로필 사진과 닉네임/이메일을 병렬 배치
                        HStack(alignment: .center, spacing: 20) {
                            // 프로필 사진
                            Image(systemName: "camera.fill")
                            //Image("userdata.profileImageUrl")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .padding(30)
                                .frame(width: 120, height: 120)
                                .foregroundColor(.gray)
                                .background(Color.white.opacity(0.1))
                                .clipShape(Circle())
                            
                            // 닉네임 및 이메일
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    Text("닉네임")
                                        .font(.system(size: 15))
                                        .foregroundColor(.white)
                                    Spacer()
                                    Text(userdata.username)  // 닉네임 표시
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .lineLimit(1)
                                        .font(.system(size: 14))
                                }
                                .padding(10)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(10)
                                
                                HStack {
                                    Text("이메일")
                                        .font(.system(size: 15))
                                        .foregroundColor(.white)
                                    Text(userdata.email)  // 이메일 표시
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .lineLimit(1)
                                        .font(.system(size: 14))
                                }
                                .padding(10)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(10)
                            }
                        }
                        Spacer()
                            .frame(height: 50)
                        
                        VStack {
                            HStack {
                                Text(userdata.userLocation)
                                    .frame(width: 100, alignment: .leading)
                                    .foregroundColor(.white)
                                Image(systemName: "location.fill")
                                    .foregroundColor(.white)
                            }
                            .padding(10)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(10)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.bottom, 10)
                            // 자기소개 구문 (텍스트만 출력하는 형태로 변경)
                            Text(userdata.intro)
                                .frame(maxWidth: .infinity, maxHeight: 150, alignment: .topLeading)  // 좌측 정렬
                                .padding()
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(10)
                                .foregroundColor(.white)
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
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                }
                                .padding(10)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(10)
                                .foregroundColor(.white)
                            }
                            Text("계정관리")
                                .font(.system(size: 20))
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Button(action: {
                                // 로그아웃 액션
                            }) {
                                HStack {
                                    Image(systemName: "person.fill")
                                    Text("로그아웃")
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                }
                                .foregroundColor(.white)
                                .padding(10)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(10)
                            }
                            
                            Button(action: {
                                // 회원 탈퇴 액션
                            }) {
                                HStack {
                                    Image(systemName: "person.fill.xmark")
                                    Text("회원 탈퇴")
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                }
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
        }
    }
}
//struct PostListView: View {
//    var body: some View {
//        Text("내 글 목록 화면")
//            .navigationTitle("내 글 목록")
//    }
//}

//struct ProfileFixView: View {
//    var body: some View {
//        Text("프로필 수정 화면")
//            .navigationTitle("프로필 수정")
//    }
//}

#Preview {
    MyPageView(userdata: UserData(id: "12345", email: "aaaaaa@gmail.com", username: "가나다", profileImageUrl:nil, userLocation: "서울시 강남구", intro: "자신을 소개해주세요"))
}
