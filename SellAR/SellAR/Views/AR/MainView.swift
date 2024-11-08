//
//  MainView.swift
//  SellAR
//
//  Created by Juno Lee on 11/1/24.
//

import SwiftUI

struct MainView: View {
    @StateObject var vm = ItemListVM()
    @State private var showAddItemView = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    // 검색어 입력 필드
                    TextField("검색어를 입력하세요", text: $vm.searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding([.top, .horizontal])
                    
                    LazyVStack {
                        ForEach(vm.filteredItems) { item in
                            NavigationLink(destination: DetailItemView(item: item)) {
                                ListItemView(item: item)
                                    .contentShape(Rectangle())
                                    .padding(.horizontal)
                                    .padding(.top, 5)
                            }
                            .buttonStyle(.plain) // 화살표 없애기
                        }
                    }
                }
            }
            .navigationTitle("SellAR")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("상품 추가") {
                        showAddItemView = true
                    }
                }
            }
            .onAppear {
                vm.listenToItems()
            }
            .sheet(isPresented: $showAddItemView) {
                NavigationStack {
                    ItemFormView(vm: .init(formType: .add))
                }
                .interactiveDismissDisabled()
            }
        }
    }
}


struct ListItemView: View {
    let item: Items
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .foregroundStyle(Color.gray.opacity(0.3))
                
                if let thumbnailURL = item.thumbnailURL {
                    AsyncImage(url: thumbnailURL) { phase in
                        switch phase {
                        case.success(let image):
                            image.resizable()
                                .aspectRatio(contentMode: .fit)
                        default:
                            ProgressView()
                        }
                    }
                }
                
            }
            .overlay(RoundedRectangle(cornerRadius: 8).stroke( Color.gray.opacity(0.3), lineWidth: 1))
            .frame(width: 150, height: 150)
            
            VStack(alignment: .leading) {
                Text(item.itemName)
                    .font(.headline)
                Text("가격: \(item.price) ₩")
                    .font(.subheadline)
                Text("상품 설명: \(item.description)")
                    .font(.subheadline)
                Text("지역: \(item.location)")
                    .font(.subheadline)
                Text("판매자: \(item.userId)")
                    .font(.subheadline)
            }
        }
    }
}

