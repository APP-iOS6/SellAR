//
//  ItemManagementView.swift
//  SellAR
//
//  Created by Min on 11/1/24.
//

import SwiftUI

struct ItemRowView: View {
    var item: Item
    @Environment(\.colorScheme) var colorScheme
    @Binding var showDetailSheet: Bool
    
    var body: some View {
        HStack {
            Image(item.images.first ?? "placeholder")
                .resizable()
                .scaledToFill()
                .frame(maxWidth: 150, maxHeight: 150)
                .clipped()
                .cornerRadius(10)
                .padding(.leading, 10)
                .padding(.vertical, 10)
            
            VStack(alignment: .leading, spacing: 10) {
                Text("\(Int(item.price)) 원")
                    .font(.system(size: 16, weight: .bold))
                Text(item.title)
                    .font(.headline)
                Text(item.description)
                    .font(.subheadline)
                Text(item.location)
                Text(item.isSold ? "판매 완료" : "판매 중")
                    .foregroundColor(item.isSold ? .gray : .red)
            }
            .padding(.leading, 8)
            
            Spacer()
            
            VStack {
                Button(action: {
                    print("아이템 선택됨")
                    showDetailSheet = true
                }) {
                    Image(systemName: "ellipsis")
                        .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                }
                .padding(.top, -70)
            }
            .padding(.trailing, 15)
        }
        .frame(maxWidth: .infinity, maxHeight: 200)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray, lineWidth: 3)
        )
        .padding(.top, 10)
        .padding(.horizontal, 16)
    }
}

struct ItemListView: View {
    
    @State private var searchText: String = ""
    @FocusState private var isSearchTextFocused: Bool
    @Environment(\.colorScheme) var colorScheme
    @State private var showDetailSheet = false

    let items: [Item] = [
        Item(id: UUID().uuidString, userId: "user1", title: "Tumbler", description: "아이템 1 설명", price: 999999999, images: ["tumbler"], category: "생활용품", location: "서울시 강남", isSold: false, createdAt: Date()),
        Item(id: UUID().uuidString, userId: "user2", title: "Humanmade", description: "아이템 2 설명", price: 500000, images: ["humanmade"], category: "의류", location: "부산시 해운대", isSold: false, createdAt: Date()),
        Item(id: UUID().uuidString, userId: "user3", title: "Diffuser", description: "아이템 3 설명", price: 300000, images: ["diffuser"], category: "향수/디퓨저", location: "대구시 수성구", isSold: false, createdAt: Date())
    ]
    
    var filteredItems: [Item] {
        if searchText.isEmpty {
            return items
        } else {
            return items.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
        }
    }

    var body: some View {
        ScrollView {
            VStack {
                Text("내 상품 관리")
                    .font(.title3)
                    .bold()
                
                HStack {
                    TextField("상품 이름을 입력해주세요.", text: $searchText)
                        .frame(maxWidth: .infinity, maxHeight: 25)
                        .textFieldStyle(.plain)
                        .focused($isSearchTextFocused)
                        .padding(.vertical, 10)
                        .padding(.leading, 10)
                    
                    if !searchText.isEmpty {
                        Button(action: {
                            searchText = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 20))
                                .foregroundStyle(Color.red)
                                .padding(.trailing, 10)
                        }
                    }
                }
                .background(Color(.systemGray5))
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray, lineWidth: 2)
                )
                .padding(.horizontal, 16)
                
                ForEach(filteredItems) { item in
                    ItemRowView(item: item, showDetailSheet: $showDetailSheet)
                }
                
                Spacer()
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            isSearchTextFocused = false
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                HStack {
                    Spacer()
                    Button("완료") {
                        isSearchTextFocused = false
                    }
                }
            }
        }
        .sheet(isPresented: $showDetailSheet) {
            ItemStatusView(showDetail: $showDetailSheet)
                .presentationDetents([.fraction(0.25)])
        }
    }
}
