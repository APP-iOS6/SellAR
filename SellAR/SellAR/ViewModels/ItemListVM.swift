//
//  ItemList.swift
//  SellAR
//
//  Created by Juno Lee on 11/4/24.
//

import Foundation
import SwiftUI
import FirebaseFirestore

class ItemListVM: ObservableObject {
    
    @Published var items = [Items]()
    @Published var searchText = ""
    
    var filteredItems: [Items] {
        if searchText.isEmpty {
            return items
        } else {
            return items.filter { $0.itemName.contains(searchText) || $0.location.contains(searchText) }
        }
    }
    
    @MainActor
    func listenToItems() {
        Firestore.firestore().collection("items")
            .order(by: "createdAt", descending: true)
            .limit(toLast: 100)
            .addSnapshotListener { snapshot, error in
                guard let snapshot = snapshot else {
                    print("Error fetching snapshot: \(error?.localizedDescription ?? "error")")
                    return
                }
                let docs = snapshot.documents
                let items = docs.compactMap {
                    try? $0.data(as: Items.self)
                }
                
                withAnimation {
                    self.items = items
                }
            }
    }
}

