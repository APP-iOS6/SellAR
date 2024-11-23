//
//  NavigationVM.swift
//  SellARVision
//
//  Created by Juno Lee on 11/23/24.
//

import Foundation
import SwiftUI

class NavigationViewModel: ObservableObject {
    @Published var selectedItem: Items?
    
    init(selectedItem: Items? = nil) {
        self.selectedItem = selectedItem
    }
}


