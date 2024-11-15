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
                        .padding(.horizontal, 10)
                    
                    LazyVStack(spacing: 8) {
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
            }
            .background(
                Color(UIColor {
                    $0.userInterfaceStyle == .dark ? UIColor(red: 23 / 255, green: 34 / 255, blue: 67 / 255, alpha: 1) :
                                                     UIColor(red: 203 / 255, green: 217 / 255, blue: 238 / 255, alpha: 1)
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


struct ListItemView: View {
    let item: Items
    let status: Bool
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
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

                    Text("가격: \(formattedPriceInTenThousandWon)") // "원"을 추가하지 않음
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Text("지역: \(item.location)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Text(item.isSold ? "판매 완료" : (item.isReserved ? "예약 중" : "판매 중"))
                        .font(.subheadline)
                        .foregroundColor(item.isSold ? .gray : (item.isReserved ? .gray : .red)) // 상태에 따른 색상 설정
                    
                    Text(" \(item.formattedCreatedAt)")  // 생성 시간 표시
                                                .font(.footnote)
                                                .foregroundColor(.gray)
                    
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.vertical, 10)
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .padding(.horizontal, 10)
            .shadow(radius: 1)

            if item.usdzLink != nil {
                arIcon
                    .padding(10)
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
