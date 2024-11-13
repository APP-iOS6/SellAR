import SwiftUI

struct MainView: View {
    @StateObject var vm = ItemListVM()
    @State private var showAddItemView = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                                        HStack {
                        TextField("검색어를 입력하세요", text: $vm.searchText)
                            .textFieldStyle(RoundedBorderTextFieldStyle())

                        if !vm.searchText.isEmpty {
                            Button(action: {
                                vm.searchText = ""
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding([.top, .horizontal])
                    
                    LazyVStack {
                        ForEach(vm.filteredItems) { item in
                            NavigationLink(destination: DetailItemView(item: item)) {
                                ListItemView(item: item)
                                    .contentShape(Rectangle())
                                    .padding(.horizontal)
                                    .padding(.top, 5)
                            }
                            .buttonStyle(.plain) 
                        }
                    }
                }
            }
            .navigationTitle("SellAR")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("팔기") {
                        showAddItemView = true
                    }
                }
            }
            .onAppear {
                vm.listenToItems()
            }
            .sheet(isPresented: $showAddItemView) {
                NavigationStack {
                    ItemFormView(vm: .init(formType: .add))
                }
                .interactiveDismissDisabled()
            }
        }
    }
}

struct ListItemView: View {
    let item: Items
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .foregroundStyle(Color.gray.opacity(0.3))
                
                // USDZ 썸네일 또는 첫 번째 이미지 표시
                if let thumbnailURL = item.thumbnailURL {
                    AsyncImage(url: thumbnailURL) { phase in
                        switch phase {
                        case .success(let image):
                            image.resizable()
                                .aspectRatio(contentMode: .fit)
                        default:
                            ProgressView()
                        }
                    }
                } else if let firstImageURL = item.images.first, let url = URL(string: firstImageURL) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image.resizable()
                                .aspectRatio(contentMode: .fit)
                        default:
                            ProgressView()
                        }
                    }
                }
            }
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3), lineWidth: 1))
            .frame(width: 150, height: 150)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.itemName)
                    .font(.headline)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                Text("가격: \(item.price) 원")
                    .font(.subheadline)
                    .fixedSize(horizontal: false, vertical: true)

                Text("지역: \(item.location)")
                    .font(.subheadline)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 8)
    }
}

