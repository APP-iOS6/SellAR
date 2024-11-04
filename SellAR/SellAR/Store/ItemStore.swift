//
//  ItemStore.swift
//  SellAR
//
//  Created by Min on 11/4/24.
//

import Foundation
import FirebaseFirestore

class ItemStore: ObservableObject {
    @Published var items: [Item] = []
    
    private var db = Firestore.firestore()
    
    func fetchItems() {
        db.collection("items").getDocuments { (snapshot, error) in
            if let error = error {
                print("Error fetching documents: \(error)")
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("No documents found")
                return
            }
            
            self.items = documents.compactMap { queryDocumentSnapshot -> Item? in
                let data = queryDocumentSnapshot.data()
                print("Document data: \(data)")  // 데이터를 출력하여 확인
                return Item(document: data)
            }
            
            print("Items loaded: \(self.items)")  // 로드된 items를 확인
        }
    }

}
