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

    func save() throws {
        loadingState = .savingItem
        
        defer { loadingState = .none }
        
        var item: Items
        switch formType {
        case .add:
            item = .init(userId: id, itemName: itemName, description: description, price: price, location: location)
        case .edit(let items):
            item = items
            item.itemName = itemName
            item.description = description
            item.price = price
            item.location = location
            
        }
        item.usdzLink = usdzURL?.absoluteString
        item.thumbnailLink = thumbnailURL?.absoluteString
        
        do {
            try db.document("items/\(String(describing: item.id))")
                .setData(from: item, merge: false)
        } catch {
            self.error = error.localizedDescription
            throw error
        }
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
}
