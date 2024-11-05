//
//  ItemFormVM.swift
//  SellAR
//
//  Created by Juno Lee on 11/4/24.
//

import FirebaseFirestore
import FirebaseStorage
import Foundation
import SwiftUI
import QuickLookThumbnailing
import FirebaseAuth

class ItemFormVM: ObservableObject {
    
    let db = Firestore.firestore()
    let formType: FormType
    
    let id: String
    
    @Published var itemName = ""
    @Published var price = ""
    @Published var usdzURL: URL?
    @Published var thumbnailURL: URL?
    
    @Published var loadingState = LoadingType.none
    @Published var error: String?
    
    @Published var uploadProgress: UploadProgress?
    @Published var showUSDZSource = false
    @Published var selectedUSDZSource: USDZSourceType?
    
    let byteCountFormatter: ByteCountFormatter = {
        let f = ByteCountFormatter()
        f.countStyle = .file
        return f
    }()
    
    @Published var description = ""
    @Published var location = ""
    
    
    var navigationTitle: String {
        switch formType {
        case.add:
            return "상품 추가"
        case .edit:
            return "상품 수정"
        }
    }
    
    init(formType: FormType = .add) {
        self.formType = formType
        switch formType {
        case .add:
            id = UUID().uuidString
        case .edit(let item):
            id = item.id
            itemName = item.itemName
            price = item.price
            description = item.description
            location = item.location
            
            
            if let usdzURL = item.usdzURL {
                self.usdzURL = usdzURL
            }
            if let thumbnailURL = item.thumbnailURL {
                self.thumbnailURL = thumbnailURL
            }
        }
    }
    
    func save(fileURL: URL?) async throws {
           loadingState = .savingItem
           
           defer { loadingState = .none }
           
           
           if let fileURL = fileURL {
               await uploadUSDZ(fileURL: fileURL)
           }
           
           var item: Items
           switch formType {
           case .add:
               item = .init(id: id, userId: Auth.auth().currentUser?.uid ?? "", itemName: itemName, description: description, price: price, location: location)
           case .edit(let existingItem):
               item = existingItem
               item.itemName = itemName
               item.description = description
               item.price = price
               item.location = location
           }
           
          
           item.usdzLink = usdzURL?.absoluteString
           item.thumbnailLink = thumbnailURL?.absoluteString
           
           do {
               // Firestore에 아이템 저장
               try db.collection("items").document(item.id)
                   .setData(from: item)
           } catch {
               self.error = error.localizedDescription
               throw error
           }
       }
    
    @MainActor
    func deleteUSDZ() async {
        let storageRef = Storage.storage().reference()
        let usdzRef = storageRef.child("\(id).usdz")
        let thumbnailRef = storageRef.child("\(id).jpg")
        
        loadingState = .deleting(.usdzWithThumbnail)
        defer { loadingState = .none }
        
        do {
            try await usdzRef.delete()
            try? await thumbnailRef.delete()
            self.usdzURL = nil
            self.thumbnailURL = nil
        } catch {
            self.error = error.localizedDescription
        }
    }
    
    @MainActor
    func deleteItem() async throws {
        loadingState = .deleting(.item)
        do {
            try await db.document("items/\(id)").delete()
            try? await Storage.storage().reference().child("\(id).usdz").delete()
            try? await Storage.storage().reference().child("\(id).jpg").delete()
        } catch {
            loadingState = .none
            throw error
        }
    }
    
    @MainActor
    func uploadUSDZ(fileURL: URL, isSecurityScopedResource: Bool = false) async {
        if isSecurityScopedResource, !fileURL.startAccessingSecurityScopedResource() {
            return
        }
//        let gotAccess = fileURL.startAccessingSecurityScopedResource()
        guard let data = try? Data(contentsOf: fileURL) else { return }
        if isSecurityScopedResource {
            fileURL.stopAccessingSecurityScopedResource()
        }
        // 업로드 진행 상태 초기화
        uploadProgress = .init(fractionCompleted: 0, totalUnitCount: 0, completedUnitCount: 0)
        loadingState = .uploading(.usdz)
        
        do {
            let storageRef = Storage.storage().reference()
            let usdzRef = storageRef.child("\(id).usdz")
            
            // Firebase Storage에 데이터 업로드
            _ = try await usdzRef.putDataAsync(data, metadata: .init(dictionary: ["contentType": "model/vnd.usd+zip"])) { [weak self] progress in
                guard let self = self, let progress = progress else { return }
                self.uploadProgress = .init(fractionCompleted: progress.fractionCompleted, totalUnitCount: progress.totalUnitCount, completedUnitCount: progress.completedUnitCount)
            }
            
            
            let downloadURL = try await usdzRef.downloadURL()
            self.usdzURL = downloadURL
            
            // 썸네일 생성
            let cacheDirURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
            let fileCacheURL = cacheDirURL.appendingPathComponent("temp_\(id).usdz")
            try? data.write(to: fileCacheURL)
            
            let thumbnailRequest = QLThumbnailGenerator.Request(fileAt: fileCacheURL, size: CGSize(width: 300, height: 300), scale: UIScreen.main.scale, representationTypes: .all)
            
            if let thumbnail = try? await QLThumbnailGenerator.shared.generateBestRepresentation(for: thumbnailRequest),
               let jpgData = thumbnail.uiImage.jpegData(compressionQuality: 0.5) {
                
                loadingState = .uploading(.thumbnail)
                let thumbnailRef = storageRef.child("\(id)_thumbnail.jpg")
                
                // 썸네일 Firebase Storage에 업로드
                _ = try await thumbnailRef.putDataAsync(jpgData, metadata: .init(dictionary: ["contentType": "image/jpeg"])) { [weak self] progress in
                    guard let self = self, let progress = progress else { return }
                    self.uploadProgress = .init(fractionCompleted: progress.fractionCompleted, totalUnitCount: progress.totalUnitCount, completedUnitCount: progress.completedUnitCount)
                }
                
                // 썸네일 다운로드 URL 획득
                let thumbnailURL = try await thumbnailRef.downloadURL()
                self.thumbnailURL = thumbnailURL
            }
            
        } catch {
            
            self.error = "업로드 실패: \(error.localizedDescription)"
            print("업로드 중 에러 발생: \(error)")
        }
        
        loadingState = .none
    }


    
}

enum FormType : Identifiable {
    
    case add
    case edit(Items)
    
    var id: String {
        switch self {
        case .add:
            return "add"
            
        case .edit(let items):
            return "edit-\(String(describing: items.id))"
        }
    }
    
}

enum LoadingType: Equatable {
    
    case none
    case savingItem
    case uploading(UploadType)
    case deleting(DeleteType)
    
}

enum USDZSourceType {
    case fileImporter, objectCapture
}

enum UploadType: Equatable {
    case usdz, thumbnail
}

enum DeleteType {
    case usdzWithThumbnail, item
}

struct UploadProgress {
    var fractionCompleted: Double
    var totalUnitCount: Int64
    var completedUnitCount: Int64
} 
