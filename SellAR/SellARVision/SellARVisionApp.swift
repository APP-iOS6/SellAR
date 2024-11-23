//
//  SellARVisionApp.swift
//  SellARVision
//
//  Created by Juno Lee on 11/23/24.
//

import SwiftUI
import Firebase

@main
struct SellARVisionApp: App {
    
    init() {
            FirebaseApp.configure()
        }
    
   // @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var navVM = NavigationViewModel()
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                InventoryListView()
                    .environmentObject(navVM)
            }
        }
        
        WindowGroup(id: "item") {
            InventoryItemView().environmentObject(navVM)
        }
        .windowStyle(.volumetric)
        .defaultSize(width: 1, height: 1, depth: 1, in: .meters)
    }
}
