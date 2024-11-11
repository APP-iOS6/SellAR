//
//  DetailItemView.swift
//  SellAR
//
//  Created by Juno Lee on 11/8/24.
//

import SwiftUI
import SafariServices

struct DetailItemView: View {
    let item: Items
    @StateObject private var userVM = UserViewModel() // userId 없이 초기화
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                
                // 상품 썸네일 이미지
                if let thumbnailURL = item.thumbnailURL {
                    AsyncImage(url: thumbnailURL) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                        case .success(let image):
                            image.resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxWidth: .infinity)
                        case .failure:
                            Text("썸네일을 불러올 수 없습니다")
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .frame(height: 300)
                }
                
                // 상품 정보
                VStack(alignment: .leading, spacing: 8) {
                    Text("판매자: \(userVM.user?.username ?? "알 수 없음")")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text(item.itemName)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("가격: \(item.price) 원")
                        .font(.title2)
                        .foregroundColor(.blue)
                    
                    Text("\(item.description)")
                        .font(.body)
                        .padding(.top, 8)
                    
                    Text("지역: \(item.location)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.top, 4)
                }
                
                // AR로 보기 버튼
                if let usdzURL = item.usdzURL {
                    Button(action: {
                        viewAR(url: usdzURL)
                    }) {
                        HStack {
                            Image(systemName: "arkit")
                                .imageScale(.large)
                            Text("AR로 보기")
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(8)
                    }
                    .padding(.top, 16)
                }
                
                // 채팅하기 버튼
                Button(action: {
                    startChat()
                }) {
                    HStack {
                        Image(systemName: "message")
                            .imageScale(.large)
                        Text("채팅하기")
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green.opacity(0.2))
                    .cornerRadius(8)
                }
                .padding(.top, 8)
                
            }
            .padding()
        }
        .onAppear {
            userVM.setUserId(item.userId)  // `onAppear`에서 `userId` 설정
        }
        .navigationTitle("상품 상세 정보")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // AR 보기 기능
    func viewAR(url: URL) {
        let safariVC = SFSafariViewController(url: url)
        let vc = UIApplication.shared.firstKeyWindow?.rootViewController?.presentedViewController ?? UIApplication.shared.firstKeyWindow?.rootViewController
        vc?.present(safariVC, animated: true)
    }
    
    // 채팅 시작 기능
    func startChat() {
        // 채팅 화면으로 이동하는 로직을 여기에 추가
    }
}
