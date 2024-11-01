//
//  ContentView.swift
//  SellAR
//
//  Created by Juno Lee on 10/30/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        
        TabView {
              Text("The First Tab")
                .tabItem {
                  Image(systemName: "1.square.fill")
                  Text("First")
                }
              Text("Another Tab")
                .tabItem {
                  Image(systemName: "2.square.fill")
                  Text("Second")
                }
              Text("The Last Tab")
                .tabItem {
                  Image(systemName: "3.square.fill")
                  Text("Third")
                }
                .font(.headline)
            }
    }
}

#Preview {
    ContentView()
}
