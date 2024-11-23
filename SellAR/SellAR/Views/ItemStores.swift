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
    @Published var items: [Items] = []
    
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
            
            db.collection("items")
                .whereField("userId", isEqualTo: userId)
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
                    
                    // 가져온 문서를 Items 모델로 변환
                    var items: [Items] = []
                    for document in documents {
                        do {
                            let item = try document.data(as: Items.self)
                            items.append(item)
                        } catch {
                            print("아이템 데이터 변환 오류: \(error.localizedDescription)")
                        }
                    }
                    
                    // 변환된 아이템 배열을 상태에 저장
                    DispatchQueue.main.async {
                        self.items = items
                    }
                }
        }

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

                    // 가져온 데이터를 Items 모델로 변환
                    var fetchedItems: [Items] = []
                    for document in documents {
                        do {
                            let item = try document.data(as: Items.self)
                            fetchedItems.append(item)
                        } catch {
                            print("아이템 데이터 변환 오류: \(error.localizedDescription)")
                        }
                    }

                    // 변환된 아이템 배열을 상태에 저장
                    DispatchQueue.main.async {
                        self.items = fetchedItems
                    }
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
    
    func updateItem(_ item: Items, vm: ItemFormVM, completion: @escaping (Error?) -> Void) {
        // 이미지를 Firebase Storage에 업로드
        uploadImages(for: vm) { imageURLs, uploadError in
            if let uploadError = uploadError {
                print("이미지 업로드 중 오류 발생: \(uploadError.localizedDescription)")
                completion(uploadError)
                return
            }
            
            // Firestore에 업데이트할 데이터 준비
            var updateData: [String: Any] = [
                "itemName": item.itemName,
                "description": item.description,
                "price": item.price,
                "location": item.location
            ]
            
            // 업로드된 이미지 URL이 있을 경우 추가
            if let imageURLs = imageURLs, !imageURLs.isEmpty {
                updateData["images"] = imageURLs.map { $0.absoluteString }
            }
            
            // `usdzURL`이 있을 경우 해당 URL 추가
            if let usdzLink = vm.usdzURL?.absoluteString {
                updateData["usdzLink"] = usdzLink
            }
            
            // `thumbnailURL`이 있을 경우 해당 URL 추가
            if let thumbnailLink = vm.thumbnailURL?.absoluteString {
                updateData["thumbnailLink"] = thumbnailLink
            }
            
            // Firestore에 업데이트
            self.db.collection("items").document(item.id).updateData(updateData) { error in
                if let error = error {
                    print("문서 업데이트 중 오류 발생: \(error.localizedDescription)")
                    completion(error)
                } else {
                    print("문서가 성공적으로 업데이트되었습니다.")
                    completion(nil)
                }
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
    func uploadImages(for vm: ItemFormVM, completion: @escaping ([URL]?, Error?) -> Void) {
        guard !vm.selectedImages.isEmpty else {
            completion([], nil) // 선택된 이미지가 없을 경우 빈 배열 반환
            return
        }
        
        let dispatchGroup = DispatchGroup()
        var uploadedURLs: [URL] = []
        var uploadError: Error?
        
        for (index, image) in vm.selectedImages.enumerated() {
            dispatchGroup.enter()
            
            uploadImage(image: image, itemId: vm.id, index: index) { url, error in
                if let error = error {
                    print("이미지 업로드 실패: \(error.localizedDescription)")
                    uploadError = error
                } else if let url = url {
                    uploadedURLs.append(url)
                    print("이미지 업로드 성공: \(url.absoluteString)")
                }
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            if let uploadError = uploadError {
                completion(nil, uploadError)
            } else {
                completion(uploadedURLs, nil)
            }
        }
    }
    
    func uploadImage(image: UIImage, itemId: String, index: Int, completion: @escaping (URL?, Error?) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(nil, NSError(domain: "ImageError", code: 0, userInfo: [NSLocalizedDescriptionKey: "이미지 데이터를 생성할 수 없습니다."]))
            return
        }
        
        let storageRef = Storage.storage().reference().child("\(itemId)_image_\(index).jpg")
        
        storageRef.putData(imageData, metadata: .init(dictionary: ["contentType": "image/jpeg"])) { _, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            storageRef.downloadURL { url, error in
                if let error = error {
                    completion(nil, error)
                } else if let url = url {
                    completion(url, nil)
                }
            }
        }
    }


    
    deinit {
        // ItemStore가 해제될 때 리스너를 제거합니다.
        listener?.remove()
    }
}
