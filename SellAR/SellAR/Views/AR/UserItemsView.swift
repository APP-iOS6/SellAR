//
//  UserItemsView.swift
//  SellAR
//
//  Created by Juno Lee on 11/14/24.
//

import SwiftUI

struct UserItemsView: View {
    var userId: String
    @ObservedObject var itemStore = ItemStore()
    
    // `userId`를 기준으로 필터링된 아이템 목록
    var filteredItems: [Item] {
        itemStore.items.filter { $0.userId == userId }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if filteredItems.isEmpty {
                    Text("등록된 상품이 없습니다.")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    ForEach(filteredItems) { item in
                        ItemRowView(item: item, showDetailSheet: .constant(false), selectedItem: .constant(nil))
                    }
                }
            }
            .padding()
        }
        .background(
            Color(UIColor { traitCollection in
                traitCollection.userInterfaceStyle == .dark
                ? UIColor.black
                : UIColor.white
            }).ignoresSafeArea()
        )
        .navigationTitle("판매자의 상품 목록")
        .onAppear {
            itemStore.fetchAllItems() // 모든 아이템을 가져옴
        }
    }
}
