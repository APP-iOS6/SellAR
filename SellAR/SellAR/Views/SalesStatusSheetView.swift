//
//  SalesStatusView.swift
//  SellAR
//
//  Created by Min on 11/1/24.
//
// 상품의 판매상태를 고를 수 있는 시트 뷰
import SwiftUI

struct SalesStatusSheetView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    @Binding var showSalesStatusSheet: Bool
    @Binding var showDetail: Bool
    @Binding var selectedItem: Item?
    
    @ObservedObject var itemStore: ItemStore

    var body: some View {
        VStack {
            Button(action: {
                if let itemId = selectedItem?.id {
                    itemStore.updateItemStatus(itemId: itemId, isSold: false, isReserved: false) // 판매 중으로 설정
                }
                showDetail = false
                print("판매 중")
            }) {
                Text("판매 중")
                    .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
            }
            .padding()
            
            Divider()
            
            Button(action: {
                if let itemId = selectedItem?.id {
                    itemStore.updateItemStatus(itemId: itemId, isSold: true, isReserved: false) // 판매 완료로 설정
                }
                showDetail = false
                print("판매 완료")
            }) {
                Text("판매 완료")
                    .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
            }
            .padding()
            
            Divider()
            
            Button(action: {
                // 예약 중 상태 업데이트 기능 추가
                if let itemId = selectedItem?.id {
                    itemStore.updateItemStatus(itemId: itemId, isSold: false, isReserved: true) // 예약 중 상태로 설정
                }
                showDetail = false
                print("예약 중")
            }) {
                Text("예약 중")
                    .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
            }
            .padding(.top, 10)
        }
    }
}
