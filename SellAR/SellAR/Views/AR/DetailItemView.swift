import SwiftUI
import SafariServices

struct DetailItemView: View {
    let item: Items
    @StateObject private var userVM = UserViewModel()
    @State private var showAlert = false
    @State private var showUserItems = false
    @State private var showReportConfirmation = false  // 신고 완료 메시지 표시 여부
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                
                // 썸네일 및 이미지 섹션
                if let thumbnailURL = item.thumbnailURL ?? (item.images.first.flatMap { URL(string: $0) }) {
                    VStack(alignment: .leading, spacing: 8) {
                        if let thumbnailURL = item.thumbnailURL, item.images.isEmpty {
                            VStack {
                                AsyncImage(url: thumbnailURL) { phase in
                                    switch phase {
                                    case .empty:
                                        ProgressView()
                                    case .success(let image):
                                        image.resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(maxWidth: .infinity, maxHeight: UIScreen.main.bounds.width) // 화면 비율 맞춤
                                    case .failure:
                                        Text("썸네일을 불러올 수 없습니다")
                                    @unknown default:
                                        EmptyView()
                                    }
                                }
                                .cornerRadius(8)
                            }
                            .frame(maxWidth: .infinity, alignment: .center)
                        } else if item.thumbnailURL == nil && item.images.count == 1 {
                            VStack {
                                if let singleImageURL = URL(string: item.images.first!) {
                                    AsyncImage(url: singleImageURL) { phase in
                                        switch phase {
                                        case .empty:
                                            ProgressView()
                                        case .success(let image):
                                            image.resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(maxWidth: .infinity, maxHeight: UIScreen.main.bounds.width) // 화면 비율 맞춤
                                        case .failure:
                                            Text("이미지를 불러올 수 없습니다")
                                        @unknown default:
                                            EmptyView()
                                        }
                                    }
                                    .cornerRadius(8)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .center)
                        } else {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 10) {
                                    if let thumbnailURL = item.thumbnailURL {
                                        AsyncImage(url: thumbnailURL) { phase in
                                            switch phase {
                                            case .empty:
                                                ProgressView()
                                            case .success(let image):
                                                image.resizable()
                                                    .aspectRatio(contentMode: .fit)
                                                    .frame(maxWidth: UIScreen.main.bounds.width * 0.8, maxHeight: UIScreen.main.bounds.width * 0.8) // 비율 맞춤
                                            case .failure:
                                                Text("썸네일을 불러올 수 없습니다")
                                            @unknown default:
                                                EmptyView()
                                            }
                                        }
                                        .cornerRadius(8)
                                    }
                                    
                                    ForEach(item.images, id: \.self) { imageURL in
                                        if let url = URL(string: imageURL) {
                                            AsyncImage(url: url) { phase in
                                                switch phase {
                                                case .empty:
                                                    ProgressView()
                                                case .success(let image):
                                                    image.resizable()
                                                        .aspectRatio(contentMode: .fit)
                                                        .frame(maxWidth: UIScreen.main.bounds.width * 0.8, maxHeight: UIScreen.main.bounds.width * 0.8) // 비율 맞춤
                                                case .failure:
                                                    Text("이미지를 불러올 수 없습니다")
                                                @unknown default:
                                                    EmptyView()
                                                }
                                            }
                                            .cornerRadius(8)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding(.vertical)
                }

                
                // 흰색 배경 안에 들어갈 전체 내용
                VStack(alignment: .leading, spacing: 16) {
                    // 판매자 및 상품 정보 섹션
                    HStack {
                        NavigationLink(destination: UserItemsView(userId: item.userId)) {
                            if let profileImageUrl = userVM.user?.profileImageUrl, let url = URL(string: profileImageUrl) {
                                AsyncImage(url: url) { phase in
                                    switch phase {
                                    case .empty:
                                        ProgressView()
                                    case .success(let image):
                                        image.resizable()
                                            .frame(width: 40, height: 40)
                                            .clipShape(Circle())
                                    case .failure:
                                        Image(systemName: "person.circle.fill")
                                            .resizable()
                                            .frame(width: 40, height: 40)
                                    @unknown default:
                                        EmptyView()
                                    }
                                }
                            } else {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .frame(width: 40, height: 40)
                            }
                        }
                        
                        VStack(alignment: .leading) {
                            NavigationLink(destination: UserItemsView(userId: item.userId)) {
                                Text("\(userVM.user?.username ?? "알 수 없음")")
                                    .font(.subheadline)
                                    .foregroundColor(.primary)
                            }
                            Text(item.location)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Text(item.formattedCreatedAt)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Text(item.itemName)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(item.description)
                        .font(.body)
                        .foregroundColor(.black)
                        .fontWeight(.light)
                    
//                    Text(item.isSold ? "판매 완료" : (item.isReserved ? "예약 중" : "판매 중"))
//                        .font(.subheadline)
//                        .foregroundColor(item.isSold ? .gray : (item.isReserved ? .gray : .red))
//                    
                    // 가격 및 버튼 섹션
                    HStack {
                        Text("\(formattedPriceInTenThousandWon)")
                            .font(.headline)  // 폰트 크기를 headline으로 줄임
                            .fontWeight(.bold)
                        Spacer()
                        
                        // AR로 보기 버튼 (usdz 파일이 있는 경우에만 표시)
                        if item.usdzURL != nil {
                            Button(action: {
                                if let usdzURL = item.usdzURL {
                                    viewAR(url: usdzURL)
                                }
                            }) {
                                HStack {
                                    Image(systemName: "arkit")
                                    Text("AR 보기")
                                        .font(.footnote)
                                }
                                .padding(.vertical, 6)
                                .padding(.horizontal, 12)
                                .background(Color.blue.opacity(0.2))
                                .cornerRadius(20)
                            }
                        }
                        
                        // 채팅하기 버튼
                        Button(action: {
                                startChat()
                            }) {
                                HStack {
                                    Image(systemName: "message")
                                    Text("채팅하기")
                                        .font(.footnote)
                                }
                                .padding(.vertical, 6)
                                .padding(.horizontal, 12)
                                .background(Color.green.opacity(0.2))
                                .cornerRadius(20)
                            }
                        }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
            .padding(.top, 16)
        }
        .background(
            Color(UIColor {
                $0.userInterfaceStyle == .dark ? UIColor(red: 23 / 255, green: 34 / 255, blue: 67 / 255, alpha: 1) :
                                                 UIColor(red: 203 / 255, green: 217 / 255, blue: 238 / 255, alpha: 1)
            }).ignoresSafeArea()
        )
        .onAppear {
            userVM.setUserId(item.userId)
        }
        .navigationTitle("상품 상세 정보")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showAlert = true
                }) {
                    Image(systemName: "exclamationmark.triangle")
                        .imageScale(.large)
                        .foregroundColor(.red)
                }
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("신고하기"),
                message: Text("이 상품을 신고하시겠습니까?"),
                primaryButton: .destructive(Text("신고하기")) {
                    reportItem()
                },
                secondaryButton: .cancel(Text("취소"))
            )
        }
        .overlay(
            VStack {
                if showReportConfirmation {
                    Text("신고가 완료되었습니다.")
                        .padding()
                        .background(Color(red: 0.30, green: 0.50, blue: 0.78))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .zIndex(1)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                withAnimation {
                                    showReportConfirmation = false
                                }
                            }
                        }
                }
                Spacer()
            }
        )
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
            return "\(formatter.string(from: NSNumber(value: remaining)) ?? "0")원"
        }
    }
    
    // AR 보기 기능
    func viewAR(url: URL) {
        let safariVC = SFSafariViewController(url: url)
        let vc = UIApplication.shared.firstKeyWindow?.rootViewController?.presentedViewController ?? UIApplication.shared.firstKeyWindow?.rootViewController
        vc?.present(safariVC, animated: true)
    }
    
    // 채팅 시작 기능
    func startChat() {
        // 채팅 화면으로 이동하는 로직을 여기에 추가
    }
    
    // 신고하기 기능
    func reportItem() {
        withAnimation {
            showReportConfirmation = true
        }
        print("신고가 완료되었습니다.")
    }
}
