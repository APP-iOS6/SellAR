//
//  ItemStore.swift
//  SellAR
//
//  Created by Min on 11/4/24.
//
// ItemStore
import Foundation
import FirebaseFirestore

class ItemStore: ObservableObject {
    @Published var items: [Item] = []
    
    private var db = Firestore.firestore()
    private var listener: ListenerRegistration?  // 리스너를 위한 변수 추가

    // 실시간으로 업데이트되는 fetchItems
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
//    func fetchItems() {
//            db.collection("items").getDocuments { [weak self] (snapshot, error) in
//                if let error = error {
//                    print("Error fetching documents: \(error)")
//                    return
//                }
//                
//                guard let documents = snapshot?.documents else {
//                    print("No documents found")
//                    return
//                }
//                
//                self?.items = documents.compactMap { queryDocumentSnapshot -> Item? in
//                    let data = queryDocumentSnapshot.data()
//                    print("Document data: \(data)")  // 데이터를 출력하여 확인
//                    return Item(document: data)  // Item의 초기화 메서드에 맞춰 데이터 매핑
//                }
//                
//                print("Items loaded: \(String(describing: self?.items))")  // 로드된 items를 확인
//            }
//        }
    
    func updateItem(_ item: Item, completion: @escaping (Error?) -> Void) {
        db.collection("items").document(item.id).updateData([
            "itemName": item.itemName,
            "title": item.title,
            "description": item.description,
            "price": item.price,
            // 필요한 경우 다른 필드도 추가
        ]) { error in
            if let error = error {
                print("Error updating document: \(error)")
            } else {
                print("Document successfully updated")
                // 성공적으로 수정된 후 다른 행동 추가 (예: dismiss)
            }
        }
    }
    
    func updateItemStatus(itemId: String, isSold: Bool) {
        let db = Firestore.firestore()
        let itemRef = db.collection("items").document(itemId)
        
        itemRef.updateData([
            "isSold": isSold
        ]) { error in
            if let error = error {
                print("문서 업데이트 중 오류 발생: \(error)")
            } else {
                print("문서가 성공적으로 업데이트되었습니다.")
            }
        }
    }
    
    func deldeItem(itemId: String) {
        let db = Firestore.firestore()
        db.collection("items").document(itemId).delete() { error in
            if let error = error {
                print("문서 삭제 중 오류 발생: \(error)")
            } else {
                print("정상적으로 삭제됨!")
            }
        }
    }
    deinit {
        // ItemStore가 해제될 때 리스너를 제거합니다.
        listener?.remove()
    }
}
