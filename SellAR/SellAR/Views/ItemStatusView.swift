//
//  ItemStatusView.swift
//  SellAR
//
//  Created by Min on 11/1/24.
//

import SwiftUI

struct ItemStatusView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    @Binding var showDetail: Bool
    
    @State private var showAlert = false
    @State private var showSalesStatusSheet = false
    
    var body: some View {
        
        VStack {
            Button(action: {
                dismiss()
                print("상품 수정으로 들어가기")
            }) {
                Text("상품 수정")
                    .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
            }
            .padding()
            
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
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("상품 삭제"),
                message: Text("정말로 상품을 삭제하시겠습니까?"),
                primaryButton: .destructive(Text("삭제")) {
                    print("상품이 삭제되었습니다.")
                    dismiss()
                    
                },
                secondaryButton: .cancel(Text("취소"))
            )
        }
        .sheet(isPresented: $showSalesStatusSheet) {
            SalesStatusView(showSalesStatusSheet: $showSalesStatusSheet, showDetail: $showDetail)
                .presentationDetents([.fraction(0.25)])
        }
        
    }
    
}
