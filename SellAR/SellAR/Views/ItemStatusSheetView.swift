//
//  ItemStatusView.swift
//  SellAR
//
//  Created by Min on 11/1/24.
//
// 게시물 마다 오른쪽 위의 버튼을 클릭하면 보여주는 시트뷰
import SwiftUI

struct ItemStatusSheetView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    @Binding var showDetail: Bool
    @Binding var selectedItem: Item?
    @State private var isEditing = false

    @State private var showAlert = false
    @State private var showSalesStatusSheet = false
    
    @ObservedObject var itemStore: ItemStore
    
    var body: some View {
            NavigationStack {
//                ZStack {
//                    Color(colorScheme == .dark ?
//                          Color(red: 23 / 255, green: 34 / 255, blue: 67 / 255) : Color(red: 203 / 255, green: 217 / 255, blue: 238 / 255))
//                        .edgesIgnoringSafeArea(.all)
                VStack {
                    Button(action: {
                        isEditing = true
                        print("상품 수정")
                    }) {
                        Text("상품 수정")
                            .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                    }
                    .padding()
                    .fullScreenCover(isPresented: $isEditing) {
                        if let selectedItem = selectedItem {
                            ItemEditView(selectedItem: $selectedItem) // 바인딩으로 전달
                        }
                    }
                    
                    
                    Divider()
                    
                    Button(action: {
                        showSalesStatusSheet = true
                        print("상태 변경하기")
                    }) {
                        Text("상태 변경")
                            .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                    }
                    .padding()
                    
                    Divider()
                    
                    Button(action: {
                        showAlert = true
                        print("상품 삭제하기")
                    }) {
                        Text("상품 삭제")
                            .foregroundStyle(Color.red)
                    }
                    .padding(.top, 10)
                }
//            }
                
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("상품 삭제"),
                message: Text("정말로 상품을 삭제하시겠습니까?"),
                primaryButton: .destructive(Text("삭제")) {
                    if let itemId = selectedItem?.id {
                        itemStore.deldeItem(itemId: itemId)
                        dismiss()
                    }
                    print("상품이 삭제되었습니다.")
                },
                secondaryButton: .cancel(Text("취소"))
            )
        }
        .sheet(isPresented: $showSalesStatusSheet) {
            SalesStatusSheetView(showSalesStatusSheet: $showSalesStatusSheet,
                                 showDetail: $showDetail,
                                 selectedItem: $selectedItem,  // 선택된 아이템을 바인딩으로 전달
                                 itemStore: itemStore)          // 아이템 저장소도 전달
                .presentationDetents([.fraction(0.25)])
//                .background(colorScheme == .dark ?  Color(red: 23 / 255, green: 34 / 255, blue: 67 / 255) : Color(red: 203 / 255, green: 217 / 255, blue: 238 / 255))
        }

    }
}
