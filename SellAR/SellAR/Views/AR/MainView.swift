import SwiftUI

struct MainView: View {
    @StateObject var vm = ItemListVM()
    @State private var showAddItemView = false
    @ObservedObject var loginViewModel: LoginViewModel

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 12) {
                    searchField
                        .padding(.horizontal)
                        .padding(.top, 8)
                    
                    LazyVStack(spacing: 8) {
                        ForEach(vm.filteredItems) { item in
                            NavigationLink(destination: DetailItemView(item: item)) {
                                ListItemView(item: item, status: item.isSold)
                                    .contentShape(Rectangle())
                                    .padding(.horizontal)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.top, 8)
                }
            }
            .navigationTitle("SellAR")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    addButton
                }
            }
            .onAppear {
                vm.listenToItems()
            }
            .sheet(isPresented: $showAddItemView) {
                if loginViewModel.user.id.isEmpty {
                    // 로그인되지 않은 경우 로그인 화면으로 이동
                    NavigationStack {
                        LoginView()
                    }
                } else {
                    // 로그인된 경우 아이템 추가 화면 표시
                    NavigationStack {
                        ItemFormView(vm: .init(formType: .add))
                    }
                    .interactiveDismissDisabled()
                }
            }
        }
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

struct ListItemView: View {
    let item: Items
    let status: Bool
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            thumbnailView
                .frame(width: 120, height: 120)
                .cornerRadius(8)
                .shadow(radius: 2)

            VStack(alignment: .leading, spacing: 6) {
                Text(item.itemName)
                    .font(.headline)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                Text("가격: \(item.price) 원")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Text("지역: \(item.location)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Text(item.isSold ? "판매 완료" : (item.isReserved ? "예약 중" : "판매 중"))
                    .font(.subheadline)
                    .foregroundColor(item.isSold ? .gray : (item.isReserved ? .gray : .red)) // 상태에 따른 색상 설정
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 10)
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal, 10)
        .shadow(radius: 1)
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
}
