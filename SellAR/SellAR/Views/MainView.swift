//
//  MainView.swift
//  SellAR
//
//  Created by Juno Lee on 11/1/24.
//

import SwiftUI

struct MainView: View {
    
    @StateObject var vm = ItemList()
    
    var body: some View {
        List {
            ForEach(vm.items) { item in
                Text(item.itemName)
            }
        }
        .navigationTitle("상품 목록")
    }
}

#Preview {
    NavigationStack {
        MainView()
    }
    
}
