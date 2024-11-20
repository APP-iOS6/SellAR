//
//  ItemStore.swift
//  SellAR
//
//  Created by Min on 11/4/24.
//
// ItemStore
import Foundation
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage

class ItemStore: ObservableObject {
    @Published var items: [Item] = []
    
    private var db = Firestore.firestore()
    private var listener: ListenerRegistration?  // 리스너를 위한 변수 추가
    

    // 유저 아이디로 실시간 업데이트 되는 fetchItem
//    func fetchItems(for userId: String) {
//        db.collection("items")
//            .whereField("userId", isEqualTo: userId)
//            .addSnapshotListener { [weak self] (snapshot, error) in
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
//                    return Item(document: data)
//                }
//            }
//    }
    
    func getCurrentUserId() -> String? {
        // 현재 로그인된 사용자 가져오기
        if let currentUser = Auth.auth().currentUser {
            // 로그인된 사용자의 userId 가져오기
            return currentUser.uid
        } else {
            // 로그인된 사용자가 없을 경우
            print("로그인된 사용자가 없습니다.")
            return nil
        }
    }
    
//     실시간으로 업데이트되는 fetchItems
    func fetchItems() {
            guard let userId = getCurrentUserId() else {
                print("userId가 없습니다.")
                return
            }

            // Firestore에서 해당 userId에 맞는 아이템만 가져오기
            db.collection("items")
                .whereField("userId", isEqualTo: userId)  // userId로 필터링
                .order(by: "createdAt", descending: true)
                .addSnapshotListener { (snapshot, error) in
                    if let error = error {
                        print("아이템을 가져오는 중 오류 발생: \(error.localizedDescription)")
                        return
                    }

                    guard let documents = snapshot?.documents else {
                        print("아이템이 없습니다.")
                        return
                    }

                    self.items = documents.compactMap { doc in
                        let data = doc.data()
                        return Item(document: data)
                    }
                }
        }
    // 유저별 아이템 확인용
    func fetchAllItems() {
            db.collection("items")
                .order(by: "createdAt", descending: true)
                .addSnapshotListener { (snapshot, error) in
                    if let error = error {
                        print("아이템을 가져오는 중 오류 발생: \(error.localizedDescription)")
                        return
                    }

                    guard let documents = snapshot?.documents else {
                        print("아이템이 없습니다.")
                        return
                    }

                    self.items = documents.compactMap { doc in
                        let data = doc.data()
                        return Item(document: data)
                    }
                    print("Fetched all items:", self.items)
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
            "description": item.description,
            "price": item.price,
            "images": item.images,
            "location": item.location,
            "usdzLink": item.usdzLink ?? "", // USDZ 파일 링크 추가
            "thumbnailLink": item.thumbnailLink ?? "" // 썸네일 링크 추가

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
    
    func updateItemStatus(itemId: String, isSold: Bool, isReserved: Bool) {
        let db = Firestore.firestore()
        let itemRef = db.collection("items").document(itemId)
        
        itemRef.updateData([
            "isSold": isSold,
            "isReserved": isReserved
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
