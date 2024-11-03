//
//  ItemList.swift
//  SellAR
//
//  Created by Juno Lee on 11/4/24.
//

import Foundation
import SwiftUI
import FirebaseFirestore

class ItemList: ObservableObject {
    
    @Published var items = [Items]()
    
    @MainActor
    func listenToItems() {
        Firestore.firestore().collection("items")
            .order(by: "name")
            .limit(toLast: 100)
            .addSnapshotListener{ snapshot, error in
                guard let snapshot else {
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
