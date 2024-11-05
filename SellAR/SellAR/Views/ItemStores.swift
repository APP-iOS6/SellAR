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
    private var listener: ListenerRegistration?  // 리스너를 위한 변수 추가

    func fetchItems() {
        // 기존 리스너가 존재할 경우 제거
        listener?.remove()

        // Firestore에서 실시간 업데이트를 수신하기 위해 리스너를 추가합니다.
        listener = db.collection("items").addSnapshotListener { [weak self] (snapshot, error) in
            if let error = error {
                print("Error fetching documents: \(error)")
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("No documents found")
                return
            }
            
            self?.items = documents.compactMap { queryDocumentSnapshot -> Item? in
                let data = queryDocumentSnapshot.data()
                print("Document data: \(data)")  // 데이터를 출력하여 확인
                return Item(document: data)  // Item의 초기화 메서드에 맞춰 데이터 매핑
            }
            
            print("Items loaded: \(String(describing: self?.items))")  // 로드된 items를 확인
        }
    }

    deinit {
        // ItemStore가 해제될 때 리스너를 제거합니다.
        listener?.remove()
    }
}
