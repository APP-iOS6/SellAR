//
//  MainView.swift
//  SellAR
//
//  Created by Juno Lee on 11/1/24.
//

import SwiftUI

struct MainView: View {
    
    @StateObject var vm = ItemListVM()
    @State var formType: FormType?
    
    var body: some View {
        List {
            ForEach(vm.items) { item in
                ListItemView(item: item)
                    .listRowSeparator(.hidden)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        formType = .edit(item)
                    }
            }
            
        }
        .navigationTitle("상품 목록")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("상품 추가") {
                    formType = .add
                }
            }
        }
        .sheet(item: $formType) { type in
            NavigationStack {
                ItemFormView(vm: .init(formType: type))
            }
            .presentationDetents([.fraction(0.85)])
            .interactiveDismissDisabled()
        }
        
        .onAppear {
            vm.listenToItems()
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

