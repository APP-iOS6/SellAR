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
            HStack(alignment: .top, spacing: 12) {
                // Thumbnail View Section
                if let imageURLString = item.thumbnailLink?.isEmpty ?? true ? item.images.first : item.thumbnailLink,
                   let imageURL = URL(string: imageURLString) {
                    AsyncImage(url: imageURL) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(width: 120, height: 120)
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 120, height: 120)
                                .clipped()
                                .cornerRadius(8)
                                .shadow(radius: 2)
                        case .failure:
                            Color.white
                                .frame(width: 120, height: 120)
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(colorScheme == .dark ? Color.white.opacity(0.3) : Color.gray.opacity(0.5), lineWidth: 1)
                                )
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(colorScheme == .dark ? Color.white.opacity(0.3) : Color.gray.opacity(0.5), lineWidth: 1)
                    )
                } else {
                    Color.white
                        .frame(width: 120, height: 120)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(colorScheme == .dark ? Color.white.opacity(0.3) : Color.gray.opacity(0.5), lineWidth: 1)
                        )
                        .overlay(
                            Text("없음")
                                .foregroundColor(.gray)
                                .font(.system(size: 16, weight: .bold))
                        )
                }
                
                // Item Info Section
                VStack(alignment: .leading, spacing: 6) {
                    Text(item.itemName)
                        .font(.headline)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Text("가격: \(formattedPriceInTenThousandWon)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("지역: \(item.location)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text(item.isSold ? "판매 완료" : (item.isReserved ? "예약 중" : "판매 중"))
                        .font(.subheadline)
                        .foregroundColor(item.isSold ? .gray : (item.isReserved ? .gray : .red))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
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
            }
            .padding(.vertical, 10)
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .shadow(radius: 1)
            .padding(.horizontal, 16)
        }
    }
             private var formattedPriceInTenThousandWon: String {
                let priceNumber = Int(item.price) ?? 0
                let tenThousandUnit = priceNumber / 10000
                let remaining = priceNumber % 10000
                
                let formatter = NumberFormatter()
                formatter.numberStyle = .decimal
                
                if tenThousandUnit > 0 {
                    if remaining == 0 {
                        return "\(tenThousandUnit)만원"
                    } else {
                        let remainingStr = formatter.string(from: NSNumber(value: remaining)) ?? "0"
                        return "\(tenThousandUnit)만 \(remainingStr)원"
                    }
                } else {
                    return formatter.string(from: NSNumber(value: remaining)) ?? "0원"
        }
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
            return itemStore.items.filter { $0.itemName.localizedCaseInsensitiveContains(searchText) }
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
