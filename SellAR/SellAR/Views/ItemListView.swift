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
                    .padding(.leading, 10)
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
                        .padding(.leading, 10)
                }
                
                // Item Info Section
                VStack(alignment: .leading, spacing: 6) {
                    Text(item.itemName)
                        .font(.headline)
                        .foregroundStyle(Color.black)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Text("가격: \(formattedPriceInTenThousandWon)")
                        .font(.subheadline)
                        .foregroundStyle(Color.gray)
                    
                    Text("지역: \(item.location)")
                        .font(.subheadline)
                        .foregroundStyle(Color.gray)
                    
                    Text(item.isSold ? "판매 완료" : (item.isReserved ? "예약 중" : "판매 중"))
                        .font(.subheadline)
                        .foregroundColor(item.isSold ? .gray : (item.isReserved ? .gray : .red))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                VStack {
                    // Ellipsis Button
                    Button(action: {
                        selectedItem = item
                        showDetailSheet = true
                    }) {
                        Image(systemName: "ellipsis")
                            .foregroundStyle(Color.black)
//                            .foregroundColor(colorScheme == .dark ? .black : .white)
                            .padding(8)
//                            .background(colorScheme == .dark ? Color.white : Color.black, in: Circle())
                    }
                    Spacer()
                    
                    if !item.usdzLink.isEmpty {
                        arIcon
                    }
                    
                }
            }
            .padding(.vertical, 10)
            .background(Color(.white))
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
    
    private var arIcon: some View {
        Text("AR")
            .font(.caption)
            .fontWeight(.bold)
            .foregroundColor(.blue)
            .padding(6)
            .background(Color.white.opacity(0.8))
            .clipShape(Circle())
            .shadow(radius: 2)
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
        ZStack {
            Color(colorScheme == .dark ?
                  Color(red: 23 / 255, green: 34 / 255, blue: 67 / 255) : Color(red: 203 / 255, green: 217 / 255, blue: 238 / 255))
                .edgesIgnoringSafeArea(.all)
            ScrollView {
                VStack(spacing: 6) {
                    // Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                            .padding(.leading, 6)
                        
                        TextField("상품 이름을 입력해주세요.", text: $searchText)
                            .padding(8)
                            .foregroundColor(.primary)
                            .focused($isSearchTextFocused)
                            .font(.body)
                        
                        if !searchText.isEmpty {
                            Button(action: {
                                searchText = ""
                            }) {
                                Image(systemName: "xmark.circle.fill")
//                                    .font(.system(size: 18))
                                    .foregroundStyle(Color.gray)
                                    .padding(.trailing, 10)
                            }
                        }
                    }
                    .background(Color.gray.opacity(0.2), in: RoundedRectangle(cornerRadius: 8))
                    .padding(.top, 15)
                    .padding(.horizontal, 16)
                    .padding(.bottom,15)
                    
                    // Item Rows
                    ForEach(filteredItems) { item in
                        ItemRowView(item: item, showDetailSheet: $showDetailSheet, selectedItem: $selectedItem)
                    }
                    
                    Spacer()
                }
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
