//
//  SellARApp.swift
//  SellAR
//
//  Created by Juno Lee on 10/30/24.
//

import SwiftUI

struct MainView: View {
    @StateObject var vm = ItemListVM()
    @State private var showAddItemView = false
    @ObservedObject var loginViewModel: LoginViewModel
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 4) {
                    logoView
                    
                    searchField
                        .padding(.horizontal, 10)
                }
                
                VStack(spacing: 8) {
                    ForEach(vm.filteredItems) { item in
                        NavigationLink(destination: DetailItemView(item: item, currentUserID: loginViewModel.user.id)) {
                            ListItemView(item: item, status: item.isSold)
                                .contentShape(Rectangle())
                                .padding(.horizontal, 10)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.top, 8)
            }
            .background(
                Color(UIColor { traitCollection in
                    traitCollection.userInterfaceStyle == .dark
                    ? UIColor.black
                    : UIColor.white
                }).ignoresSafeArea()
            )
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    addButton
                }
            }
            .onAppear {
                vm.listenToItems()
            }
            .fullScreenCover(isPresented: $showAddItemView) {
                if loginViewModel.user.id.isEmpty {
                    NavigationView {
                        LoginView()
                    }
                } else {
                    NavigationView {
                        ItemFormView(vm: .init(formType: .add))
                    }
                    .interactiveDismissDisabled()
                }
            }
            .dismissKeyboardOnTap(insideScrollViewOnly: true) 
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var logoView: some View {
        HStack {
            Image(uiImage: UIImage(named: UITraitCollection.current.userInterfaceStyle == .dark ? "LogoBlack" : "Logo") ?? UIImage())
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
                .padding(.leading, 5)
            Spacer()
        }
        .padding(.top, -70)
    }
    
    private var searchField: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
                .padding(.leading, 8)
            
            TextField("검색어를 입력하세요", text: $vm.searchText)
                .textFieldStyle(PlainTextFieldStyle())
                .padding(.leading, 4)
            
            if !vm.searchText.isEmpty {
                Button(action: {
                    vm.searchText = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
                .padding(.trailing, 8)
            }
        }
        .padding(8)
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .shadow(radius: 1)
        .padding(.top, -16)
        .padding(.horizontal, 10)
    }
    
    private var addButton: some View {
        Button(action: {
            showAddItemView = true
        }) {
            Text("판매")
                .font(.headline)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color(red: 0.30, green: 0.50, blue: 0.78))
                .foregroundColor(.white)
                .cornerRadius(8)
        }
    }
}

extension View {
    func dismissKeyboardOnTap(insideScrollViewOnly: Bool = false) -> some View {
        self.background(
            Group {
                if insideScrollViewOnly {
                    TapGestureView(isLimitedToScrollView: true)
                } else {
                    TapGestureView(isLimitedToScrollView: false)
                }
            }
        )
    }
}

struct TapGestureView: UIViewRepresentable {
    let isLimitedToScrollView: Bool
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        let gesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.dismissKeyboard))
        gesture.cancelsTouchesInView = false
        view.addGestureRecognizer(gesture)
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator {
        @objc func dismissKeyboard() {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
}

struct ListItemView: View {
    let item: Items
    let status: Bool
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            HStack(alignment: .top, spacing: 2) {
                thumbnailView
                    .frame(width: 120, height: 120)
                    .cornerRadius(8)
                    .shadow(radius: 2)
                    .padding()
                
                VStack(alignment: .leading, spacing: 4) {
                    Spacer()
                    
                    HStack {
                        Text(item.itemName)
                            .font(.headline)
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        Spacer()
                        
                        Text(item.isSold ? "판매 완료" : (item.isReserved ? "예약 중" : "판매 중"))
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(item.isSold ? Color.gray : (item.isReserved ? Color.orange : Color(red: 0.0, green: 0.6, blue: 0.2)))
                            )
                            .foregroundColor(.white)
                            .padding(6)
                    }
                    
                    Text("\(formattedPriceInTenThousandWon)")
                        .font(.subheadline)
                        .padding(.top, 0)
                    
                    Divider()
                        .frame(height: 1)
                        .background(Color.gray)
                        .padding(.vertical, 4)
                        .padding(.trailing, 16)
                    
                    HStack(spacing: 4) {
                        Text("\(item.formattedCreatedAt)")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                        
                        Divider()
                            .frame(width: 1, height: 14)
                            .background(Color.gray)
                        
                        Text("\(item.location)")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                .padding(.top, -50)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.vertical, 10)
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .padding(.horizontal, 10)
            .shadow(radius: 1)
            
            if item.usdzLink != nil {
                arIcon
                    .padding(15)
            }
        }
    }
    
    private var formattedPriceInTenThousandWon: String {
        let priceNumber = Int(item.price) ?? 0
        let tenThousandUnit = priceNumber / 10000
        let remaining = priceNumber % 10000
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        
        if tenThousandUnit > 0 {
            if remaining == 0 {
                return "\(tenThousandUnit)만원"
            } else {
                let remainingStr = formatter.string(from: NSNumber(value: remaining)) ?? "0"
                return "\(tenThousandUnit)만 \(remainingStr)원"
            }
        } else {
            return formatter.string(from: NSNumber(value: remaining)) ?? "0원"
        }
    }
    
    private var thumbnailView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .foregroundStyle(Color.gray.opacity(0.3))
            
            if let thumbnailURL = item.thumbnailURL {
                AsyncImage(url: thumbnailURL) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable()
                            .aspectRatio(contentMode: .fill)
                    default:
                        ProgressView()
                    }
                }
            } else if let firstImageURL = item.images.first, let url = URL(string: firstImageURL) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable()
                            .aspectRatio(contentMode: .fill)
                    default:
                        ProgressView()
                    }
                }
            }
        }
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3), lineWidth: 1))
    }
    
    private var arIcon: some View {
        Text("AR")
            .font(.caption)
            .fontWeight(.bold)
            .foregroundColor(.blue)
            .padding(6)
            .background(Color.white.opacity(0.8))
            .clipShape(Circle())
            .shadow(radius: 2)
    }
}
