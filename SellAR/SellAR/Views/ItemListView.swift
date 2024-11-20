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
            HStack(alignment: .top, spacing: 2) {
                // Thumbnail View Section
                if let imageURLString = item.thumbnailLink?.isEmpty ?? true ? item.images.first : item.thumbnailLink,
                   let imageURL = URL(string: imageURLString) {
                    AsyncImage(url: imageURL) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(width: 120, height: 120)
                                .background(Color.gray)
                                .cornerRadius(8)
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
                    .padding()
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
                        .padding()
                }
                
                // Item Info Section
                VStack(alignment: .leading, spacing: 4) {
                    Spacer()
                    
                    HStack {
                        Text(item.itemName)
                            .font(.headline)
                            .foregroundColor(colorScheme == .dark ? .white : .black)
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
                    }
                    
                    Text("\(formattedPriceInTenThousandWon)")
                        .font(.subheadline)
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                        .padding(.top, 0)
                    
                    Divider()
                        .frame(height: 1)
                        .background(Color.gray)
                        .padding(.vertical, 4)
                        .padding(.trailing, 16)
                    
                    
                    HStack(spacing: 4) {
                        Text("\(item.formattedCreatedAt)")  // 생성 시간 표시
                            .font(.footnote)
                            .foregroundColor(.secondary)
                        
                        Divider()
                            .frame(width: 1, height: 14)
                            .background(Color.gray)
                        
                        Text("\(item.location)")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                }
                .padding(.top, -50)
                .frame(maxWidth: .infinity, alignment: .leading)
                
                VStack {
                    // Ellipsis Button
                    Button(action: {
                        selectedItem = item
                        showDetailSheet = true
                    }) {
                        Image(systemName: "ellipsis")
//                            .foregroundStyle(Color.black)
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                            .padding(8)
//                            .background(colorScheme == .dark ? Color.white : Color.black, in: Circle())
                    }
                    Spacer()
                    
                    if let usdzLink = item.usdzLink, !usdzLink.isEmpty {
                        arIcon
                    }

                    
                }
                .padding(.trailing, 4)
            }
            .padding(.vertical, 10)
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .padding(.horizontal, 10)
            .shadow(radius: 1)
            
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
