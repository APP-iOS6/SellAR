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
        HStack {
            VStack {
                // AsyncImage를 사용하여 URL에서 이미지를 로드
                AsyncImage(url: URL(string: item.thumbnailLink ?? "")) { phase in
                    switch phase {
                    case .empty:
                        // 로딩 중일 때 표시할 뷰
                        ProgressView()
                            .frame(width: 150, height: 150)
                    case .success(let image):
                        // 성공적으로 로드되면 이미지를 표시
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 150, height: 150)
                            .clipped()
                            .cornerRadius(10)
                    case .failure:
                        // 로드 실패 시 기본 이미지를 표시
                        Image("placeholder")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 150, height: 150)
                            .clipped()
                            .cornerRadius(10)
                    @unknown default:
                        // 기타 예외 처리
                        EmptyView()
                    }
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray, lineWidth: 2)
                )
                .padding(.leading, 10)
                .padding(.vertical, 10)
            }

            VStack(alignment: .leading, spacing: 10) {
                Text("\(item.price) 원")
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
                    selectedItem = item
                    print("아이템 선택됨: \(item.title)")
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
                .background(colorScheme == .dark ? Color(.systemGray5) : Color.white) // 배경색을 다르게 설정
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray, lineWidth: 2)
                )
                .padding(.horizontal, 16)
                
                ForEach(filteredItems) { item in
                    ItemRowView(item: item, showDetailSheet: $showDetailSheet, selectedItem: $selectedItem)
                }
                
                Spacer()
            }
        }
        .onAppear {
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
