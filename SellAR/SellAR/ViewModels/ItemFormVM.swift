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
    @Published var description = ""
    @Published var location = ""
    @Published var selectedImages: [UIImage] = []
    @Published var imageURLs: [URL] = []
    
    let byteCountFormatter: ByteCountFormatter = {
        let f = ByteCountFormatter()
        f.countStyle = .file
        return f
    }()
    
    var navigationTitle: String {
        switch formType {
        case .add:
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
            usdzURL = item.usdzURL
            thumbnailURL = item.thumbnailURL
        }
    }
    
    func save(fileURL: URL?) async throws {
        DispatchQueue.main.async {
            self.loadingState = .savingItem
        }
        
        defer {
            DispatchQueue.main.async {
                self.loadingState = .none
            }
        }
        
        if let fileURL = fileURL {
            await uploadUSDZ(fileURL: fileURL)
        }
        
        // Firebase Storage에 이미지 업로드 및 URL 리스트 생성
        print("선택된 이미지 개수: \(selectedImages.count)")
        DispatchQueue.main.async {
            self.imageURLs = []
        }
        
        for (index, image) in selectedImages.enumerated() {
            if let imageURL = await uploadImage(image: image, index: index) {
                DispatchQueue.main.async {
                    self.imageURLs.append(imageURL)
                }
                print("이미지 \(index) 업로드 성공: \(imageURL)")
            } else {
                print("이미지 \(index) 업로드 실패")
            }
        }
        
        // Firestore에 저장 전에 URL 배열 확인
        print("저장할 imageURLs: \(imageURLs)")
        
        // URL 업로드가 완료된 후 Firestore에 저장
        var item: Items
        switch formType {
        case .add:
            item = .init(
                id: id,
                userId: Auth.auth().currentUser?.uid ?? "",
                itemName: itemName,
                usdzLink: usdzURL?.absoluteString,
                thumbnailLink: thumbnailURL?.absoluteString,
                description: description,
                price: price,
                images: imageURLs.map { $0.absoluteString },  // URL 문자열 배열로 변환
                location: location
            )
        case .edit(let existingItem):
            item = existingItem
            item.itemName = itemName
            item.description = description
            item.price = price
            item.location = location
            item.images = imageURLs.map { $0.absoluteString }
        }
        
        do {
            // Firestore에 아이템 저장
            try await db.collection("items").document(item.id)
                .setData(from: item)
            print("Firestore 저장 성공")
            
        } catch {
            DispatchQueue.main.async {
                self.error = error.localizedDescription
            }
            print("Firestore 저장 실패: \(error)")
            throw error
        }
    }






    // 이미지 업로드 함수
    func uploadImage(image: UIImage, index: Int) async -> URL? {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            print("이미지 데이터를 생성할 수 없습니다.")
            return nil
        }
        
        let storageRef = Storage.storage().reference().child("\(id)_image_\(index).jpg")
        
        // 메인 스레드에서 초기화
        DispatchQueue.main.async {
            self.uploadProgress = .init(fractionCompleted: 0, totalUnitCount: 0, completedUnitCount: 0)
            self.loadingState = .uploading(.thumbnail)
        }
        
        do {
            _ = try await storageRef.putDataAsync(imageData, metadata: .init(dictionary: ["contentType": "image/jpeg"])) { [weak self] progress in
                guard let self = self, let progress = progress else { return }
                
                // 메인 스레드에서 업데이트
                DispatchQueue.main.async {
                    self.uploadProgress = .init(fractionCompleted: progress.fractionCompleted, totalUnitCount: progress.totalUnitCount, completedUnitCount: progress.completedUnitCount)
                }
            }
            
            let downloadURL = try await storageRef.downloadURL()
            print("Firebase Storage 업로드 성공 - 다운로드 URL: \(downloadURL)")
            return downloadURL
        } catch {
            DispatchQueue.main.async {
                self.error = "이미지 업로드 실패: \(error.localizedDescription)"
            }
            print("Firebase Storage 업로드 실패: \(error)")
            return nil
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
        guard let data = try? Data(contentsOf: fileURL) else { return }
        if isSecurityScopedResource {
            fileURL.stopAccessingSecurityScopedResource()
        }
        
        uploadProgress = .init(fractionCompleted: 0, totalUnitCount: 0, completedUnitCount: 0)
        loadingState = .uploading(.usdz)
        
        do {
            let storageRef = Storage.storage().reference()
            let usdzRef = storageRef.child("\(id).usdz")
            
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
                
                _ = try await thumbnailRef.putDataAsync(jpgData, metadata: .init(dictionary: ["contentType": "image/jpeg"])) { [weak self] progress in
                    guard let self = self, let progress = progress else { return }
                    self.uploadProgress = .init(fractionCompleted: progress.fractionCompleted, totalUnitCount: progress.totalUnitCount, completedUnitCount: progress.completedUnitCount)
                }
                
                let thumbnailURL = try await thumbnailRef.downloadURL()
                self.thumbnailURL = thumbnailURL
            }
            
        } catch {
            self.error = "업로드 실패: \(error.localizedDescription)"
        }
        
        loadingState = .none
    }
}

enum FormType: Identifiable {
    case add
    case edit(Items)
    
    var id: String {
        switch self {
        case .add: return "add"
        case .edit(let item): return "edit-\(item.id)"
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
