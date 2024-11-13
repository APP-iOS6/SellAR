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
    @StateObject private var userVM = UserViewModel()
    @State private var showAlert = false
    
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
                        case .failure:
                            Text("썸네일을 불러올 수 없습니다")
                        @unknown default:
                            EmptyView()
                        }
                    }
                }
                
                // 등록된 이미지들
                if !item.images.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("상품 이미지")
                            .font(.headline)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(item.images, id: \.self) { imageURL in
                                    if let url = URL(string: imageURL) {
                                        AsyncImage(url: url) { phase in
                                            switch phase {
                                            case .empty:
                                                ProgressView()
                                            case .success(let image):
                                                image.resizable()
                                                    .aspectRatio(contentMode: .fit)
                                            case .failure:
                                                Text("이미지를 불러올 수 없습니다")
                                            @unknown default:
                                                EmptyView()
                                            }
                                        }
                                        .frame(width: 300, height: 300)
                                        .cornerRadius(8)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.vertical)
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
                            .imageScale(.small)
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
            userVM.setUserId(item.userId)
        }
        .navigationTitle("상품 상세 정보")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showAlert = true
                }) {
                    Image(systemName: "exclamationmark.triangle")
                        .imageScale(.large)
                        .foregroundColor(.red)
                }
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("신고하기"),
                message: Text("이 상품을 신고하시겠습니까?"),
                primaryButton: .destructive(Text("신고하기")) {
                    reportItem()
                },
                secondaryButton: .cancel(Text("취소"))
            )
        }
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
    
    // 신고하기 기능
    func reportItem() {
        // 신고 기능 로직을 여기에 추가
        print("신고가 완료되었습니다.")
    }
}
