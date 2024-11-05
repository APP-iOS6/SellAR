//
//  PostListView.swift
//  SellAR
//
//  Created by 배문성 on 11/1/24.
//
import SwiftUI

struct Post: Identifiable {
    let id = UUID()
    var title: String
    let price: String
    let location: String
    let status: String
}

struct PostListView: View {
    @State var posts: [Post] = [
        Post(title: "주전자 팝니다",price: "2000원", location: "서울시 명동", status: "판매중"),
        Post(title: "자전거 팝니다",price: "120000원", location: "서울시 송파구",status: "판매완료")
    ]
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                VStack(alignment: .leading) {
                    Text("내 글 목록")
                        .font(.headline)
                        .padding(.bottom ,15)
                        .foregroundColor(.white)
                    ScrollView {
                        VStack(alignment: .leading) {
                            //이 타이틀은 스크롤뷰로 같이내려가는지?
                            //Text("내 글 목록")
                            //    .font(.headline)
                            //    .padding(.bottom ,5)
                            //    .foregroundColor(.white)
                            ForEach(posts) { post in
                                ZStack {
                                    HStack(spacing: 25) {
                                        Image(systemName: "archivebox.fill")
                                        //Image("게시물 이미지 데이터 입력예정")
                                            .resizable()
                                            .frame(width: 100 , height: 100, alignment: .leading)
                                            .cornerRadius(15)
                                            .foregroundColor(.gray)
                                        
                                        VStack(alignment: .leading) {
                                            HStack {
                                                Text("제목")
                                                    .foregroundColor(.white)
                                                    .padding(.trailing)
                                                Text(post.title)
                                                    .foregroundColor(.white)
                                            }
                                            
                                            Spacer()
                                            
                                            HStack {
                                                Text("가격")
                                                    .foregroundColor(.white)
                                                    .padding(.trailing)
                                                Text(post.price)
                                                    .foregroundColor(.white)
                                            }
                                            
                                            Spacer()
                                            
                                            HStack {
                                                Text("위치")
                                                    .foregroundColor(.white)
                                                    .padding(.trailing)
                                                Text(post.location)
                                                    .foregroundColor(.white)
                                            }
                                            
                                            Spacer()
                                            
                                            HStack {
                                                Text("상태")
                                                    .padding(.trailing)
                                                    .foregroundColor(.white)
                                                Text(post.status)
                                                    .foregroundColor(post.status == "판매중" ? .white : .gray)
                                            }
                                            
                                        }
                                        .font(.subheadline)
                                        .padding(.horizontal)
                                        //이건무슨용도? ...내용
                                        Image(systemName: "ellipsis")
                                            .padding(.top, 3)
                                            .foregroundColor(.white)
                                            .frame(maxHeight: .infinity, alignment: .top)
                                    }
                                    .padding()
                                    .frame(maxWidth: .infinity) // 게시물 가로넓이
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(10)
                                }
                                .padding(.bottom, 15) //게시물간 여백
                            }
                        }
                    }
                }
                .padding(10) //내글목록 VStack부분 포함하는 좌우여백
            }
        }
    }
}
#Preview {
    PostListView()
}
