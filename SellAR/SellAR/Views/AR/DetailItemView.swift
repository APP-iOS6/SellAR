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
    
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
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
                
                Text("상품명: \(item.itemName)")
                    .font(.title2)
                    .padding(.bottom, 4)
                
                Text("가격: \(item.price) ₩")
                    .font(.title3)
                
                Text("설명: \(item.description)")
                    .padding(.top, 8)
                
                Text("지역: \(item.location)")
                    .padding(.top, 8)
                
                Text("펀매자: \(item.userId)")
                    .padding(.top, 8)
                
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
                }
            }
            .padding()
        }
        .navigationTitle("상품 상세 정보")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    func viewAR(url: URL) {
        let safariVC = SFSafariViewController(url: url)
        let vc = UIApplication.shared.firstKeyWindow?.rootViewController?.presentedViewController ?? UIApplication.shared.firstKeyWindow?.rootViewController
        vc?.present(safariVC, animated: true)
    }
}
