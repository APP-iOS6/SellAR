//
//  ItemManagementView.swift
//  SellAR
//
//  Created by Min on 11/1/24.
//
// 내 상품 게시물 보여주는 뷰
import SwiftUI

struct ItemRowView: View {
    var item: Items
    @Environment(\.colorScheme) var colorScheme
    @Binding var showDetailSheet: Bool
    @Binding var selectedItem: Items?
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            HStack(alignment: .top, spacing: 2) {
                thumbnailView
                    .frame(width: 120, height: 120)
                    .cornerRadius(8)
                    .padding()
                
                VStack(alignment: .leading, spacing: 4) {
                    Spacer()
                    
                    HStack {
                        Text(item.itemName)
                            .font(.headline)
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        Spacer()
                        
                        Text(item.isSold ? "판매 완료" : (item.isReserved ? "예약 중" : "판매 중"))
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(item.isSold ? Color.gray : (item.isReserved ? Color.orange : Color(red: 0.0, green: 0.6, blue: 0.2)))
                            )
                            .foregroundColor(.white)
                            .padding(6)
                            .offset(x: -9)
                        
                        Button(action: {
                            selectedItem = item
                            showDetailSheet = true
                        }) {
                            Image(systemName: "ellipsis")
                            //                            .foregroundStyle(Color.black)
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                                .padding(.trailing, 15)
                        }
                    }
                    
                    Text("\(formattedPriceInTenThousandWon)")
                        .font(.subheadline)
                        .padding(.top, 0)
                    
                    Divider()
                        .frame(height: 1)
                        .background(Color.gray)
                        .padding(.vertical, 4)
                        .padding(.trailing, 16)
                    
                    HStack(spacing: 4) {
                        Text("\(item.formattedCreatedAt)")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                        
                        Divider()
                            .frame(width: 1, height: 14)
                            .background(Color.gray)
                        
                        Text("\(item.location)")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                .padding(.top, -50)
                .frame(maxWidth: .infinity, alignment: .leading)
                
            }
            .padding(.vertical, 10)
//            .background(Color(.systemGray6))
            .cornerRadius(12)
            .padding(.horizontal, 10)
            
            
            if item.usdzLink != nil {
                arIcon
                    .padding(15)
            }
        }
        .padding(.vertical, 8)
    }
    
    private var thumbnailView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .foregroundStyle(Color.clear)
            
            if let thumbnailURL = item.thumbnailURL {
                AsyncImage(url: thumbnailURL) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable()
                            .aspectRatio(contentMode: .fill)
                    default:
                        ProgressView()
                    }
                }
            } else if let firstImageURL = item.images.first, let url = URL(string: firstImageURL) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable()
                            .aspectRatio(contentMode: .fill)
                    default:
                        ProgressView()
                    }
                }
            }
        }
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3), lineWidth: 1))
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
        HStack(spacing: 4) {
            Image(systemName: "arkit") // ARKit 아이콘
                .foregroundColor(.blue) // 아이콘 파란색
            Text("AR")
                .font(.caption)
                .foregroundColor(.blue) // 글씨 파란색
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.blue.opacity(0.2)) // 하늘색 배경
        )
        .padding(6)
    }
}

// UserItemsView에서 쓰는 뷰
struct UserItemRowView: View {
    var item: Items
    @Environment(\.colorScheme) var colorScheme
    @Binding var showDetailSheet: Bool
    @Binding var selectedItem: Items?
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            HStack(alignment: .top, spacing: 2) {
                thumbnailView
                    .frame(width: 120, height: 120)
                    .cornerRadius(8)
                    .padding()
                
                VStack(alignment: .leading, spacing: 4) {
                    Spacer()
                    
                    HStack {
                        Text(item.itemName)
                            .font(.headline)
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        Spacer()
                        
                        Text(item.isSold ? "판매 완료" : (item.isReserved ? "예약 중" : "판매 중"))
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(item.isSold ? Color.gray : (item.isReserved ? Color.orange : Color(red: 0.0, green: 0.6, blue: 0.2)))
                            )
                            .foregroundColor(.white)
                            .padding(6)
                            .offset(x: -9)
                    }
                    
                    Text("\(formattedPriceInTenThousandWon)")
                        .font(.subheadline)
                        .padding(.top, 0)
                    
                    Divider()
                        .frame(height: 1)
                        .background(Color.gray)
                        .padding(.vertical, 4)
                        .padding(.trailing, 16)
                    
                    HStack(spacing: 4) {
                        Text("\(item.formattedCreatedAt)")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                        
                        Divider()
                            .frame(width: 1, height: 14)
                            .background(Color.gray)
                        
                        Text("\(item.location)")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                .padding(.top, -50)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.vertical, 10)
//            .background(Color(.systemGray6))
            .cornerRadius(12)
            .padding(.horizontal, 10)
            
            
            if item.usdzLink != nil {
                arIcon
                    .padding(15)
            }
        }
        .padding(.vertical, 8)
    }
    
    private var thumbnailView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .foregroundStyle(Color.clear)
            
            if let thumbnailURL = item.thumbnailURL {
                AsyncImage(url: thumbnailURL) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable()
                            .aspectRatio(contentMode: .fill)
                    default:
                        ProgressView()
                    }
                }
            } else if let firstImageURL = item.images.first, let url = URL(string: firstImageURL) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable()
                            .aspectRatio(contentMode: .fill)
                    default:
                        ProgressView()
                    }
                }
            }
        }
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3), lineWidth: 1))
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
        HStack(spacing: 4) {
            Image(systemName: "arkit") // ARKit 아이콘
                .foregroundColor(.blue) // 아이콘 파란색
            Text("AR")
                .font(.caption)
                .foregroundColor(.blue) // 글씨 파란색
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.blue.opacity(0.2)) // 하늘색 배경
        )
        .padding(6)
    }
}


struct ItemListView: View {
    @State private var searchText: String = ""
    @FocusState private var isSearchTextFocused: Bool
    @Environment(\.colorScheme) var colorScheme
    @State private var showDetailSheet = false
    
    @ObservedObject var itemStore = ItemStore()
    
    @State private var selectedItem: Items?
    
    var filteredItems: [Items] {
        if searchText.isEmpty {
            return itemStore.items
        } else {
            return itemStore.items.filter { $0.itemName.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        ZStack {
            Color(colorScheme == .dark ? Color.black : Color.white).edgesIgnoringSafeArea(.all)

            ScrollView {
                VStack(spacing: 6) {
                    // Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                            .padding(.leading, 8)
                        
                        TextField("상품 이름을 입력해주세요.", text: $searchText)
                            .textFieldStyle(PlainTextFieldStyle())
                            .focused($isSearchTextFocused)
                        
                        if !searchText.isEmpty {
                            Button(action: {
                                searchText = ""
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                //                                    .font(.system(size: 18))
                                    .foregroundStyle(Color.gray)
                            }
                            .padding(.trailing, 8)
                        }
                    }
                    .padding(8)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .frame(maxWidth: UIScreen.main.bounds.width * 0.85)
                    .padding(.top, 15)
                    .padding(.horizontal, 10)
                    .padding(.bottom,15)
                    
                    // Item Rows
                    ForEach(filteredItems) { item in
                        ItemRowView(item: item, showDetailSheet: $showDetailSheet, selectedItem: $selectedItem)
                    }
                    
                    Spacer()
                }
            }
            .padding(.horizontal, 10)
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
