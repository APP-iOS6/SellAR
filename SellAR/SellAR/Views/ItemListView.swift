//
//  ItemManagementView.swift
//  SellAR
//
//  Created by Min on 11/1/24.
//
// 내 상품 게시물 보여주는 뷰
import SwiftUI

struct ItemRowView: View {
    var item: Item
    @Environment(\.colorScheme) var colorScheme
    @Binding var showDetailSheet: Bool
    @Binding var selectedItem: Item?
    
    var body: some View {
        VStack {
            HStack {
                // Image Section
                if let imageURLString = item.thumbnailLink?.isEmpty ?? true ? item.images.first : item.thumbnailLink,
                   let imageURL = URL(string: imageURLString) {
                    // URL이 유효하면 AsyncImage로 이미지를 비동기적으로 로딩
                    AsyncImage(url: imageURL) { phase in
                        switch phase {
                        case .empty:
                            // 이미지 로딩 중
                            ProgressView()
                                .frame(width: 150, height: 150)
                        case .success(let image):
                            // 이미지 로딩 성공 시
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 150, height: 150)
                                .clipped()
                                .cornerRadius(12)
                        case .failure:
                            // 이미지를 불러오지 못했을 때 흰색 배경
                            Color.white
                                .frame(width: 150, height: 150)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(colorScheme == .dark ? Color.white.opacity(0.3) : Color.gray.opacity(0.5), lineWidth: 1)
                                )
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(colorScheme == .dark ? Color.white.opacity(0.3) : Color.gray.opacity(0.5), lineWidth: 1)
                    )
                    .padding(.leading, 12)
                    .padding(.vertical, 10)
                } else {
                    // 이미지 URL이 비어있으면 "없음" 표시
                    Color.white
                        .frame(width: 150, height: 150)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(colorScheme == .dark ? Color.white.opacity(0.3) : Color.gray.opacity(0.5), lineWidth: 1)
                        )
                        .overlay(
                            Text("없음")
                                .foregroundColor(.gray)
                                .font(.system(size: 16, weight: .bold))
                        )
                }


                
                
                // Item Info Section
                VStack(alignment: .leading, spacing: 10) {
                    Text("\(item.price) 원")
                        .font(.title2.bold())
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    Text(item.itemName)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    Text(item.location)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text(item.isSold ? "판매 완료" : "판매 중")
                        .font(.subheadline)
                        .foregroundColor(item.isSold ? .gray : .red)
                }
                .padding(.leading, 12)
                
                Spacer()
                
                // Ellipsis Button
                Button(action: {
                    selectedItem = item
                    showDetailSheet = true
                }) {
                    Image(systemName: "ellipsis")
                        .foregroundColor(colorScheme == .dark ? .black : .white)
                        .padding(8)
                        .background(colorScheme == .dark ? Color.white : Color.black, in: Circle())
                }
                .padding(.top, -70)
                .padding(.trailing, 12)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: 200)
        .padding(.vertical, 8)
        .background(
            colorScheme == .dark ? Color.gray.opacity(0.2) : Color.white
        )
        .cornerRadius(15)
        .shadow(color: colorScheme == .dark ? Color.gray.opacity(0.2) : Color.gray.opacity(0.2), radius: 5, x: 0, y: 2)
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }
}


struct ItemListView: View {
    @State private var searchText: String = ""
    @FocusState private var isSearchTextFocused: Bool
    @Environment(\.colorScheme) var colorScheme
    @State private var showDetailSheet = false
    
    @ObservedObject var itemStore = ItemStore()
    
    @State private var selectedItem: Item?
    
    var filteredItems: [Item] {
        if searchText.isEmpty {
            return itemStore.items
        } else {
            return itemStore.items.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Search Bar
                HStack {
                    TextField("상품 이름을 입력해주세요.", text: $searchText)
                        .padding(12)
                        .background(Color.gray.opacity(0.2), in: RoundedRectangle(cornerRadius: 8))
                        .foregroundColor(.primary)
                        .focused($isSearchTextFocused)
                        .font(.body)
                    
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
                .padding(.top, 15)
                .padding(.horizontal, 16)
                
                // Item Rows
                ForEach(filteredItems) { item in
                    ItemRowView(item: item, showDetailSheet: $showDetailSheet, selectedItem: $selectedItem)
                }
                
                Spacer()
            }
        }
        .navigationTitle("내 상품 관리")
        .onAppear {
            itemStore.fetchItems()
        }
        .refreshable {
            itemStore.fetchItems()
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
            ItemStatusSheetView(showDetail: $showDetailSheet, selectedItem: $selectedItem, itemStore: itemStore)
                .presentationDetents([.fraction(0.25)])
        }
    }
}
