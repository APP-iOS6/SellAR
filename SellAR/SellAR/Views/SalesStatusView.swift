//
//  SalesStatusView.swift
//  SellAR
//
//  Created by Min on 11/1/24.
//

import SwiftUI

struct SalesStatusView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    @Binding var showSalesStatusSheet: Bool
    @Binding var showDetail: Bool
    
    var body: some View {
        VStack {
            Button(action: {
                showDetail = false
                print("판매 중")
            }) {
                Text("판매 중")
                    .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
            }
            .padding()
            
            Divider()
            
            Button(action: {
                showDetail = false
                print("판매 완료")
            }) {
                Text("판매 완료")
                    .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
            }
            .padding()
            
            Divider()
            
            Button(action: {
                showDetail = false
                print("예약 중")
            }) {
                Text("예약 중")
                    .foregroundStyle(Color.red)
            }
            .padding(.top, 10)
        }
    }
}
