import SwiftUI
import SafariServices


extension Color {
    static var dynamicTextColor: Color {
        return Color(UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? .black : .label
        })
    }
}

struct DetailItemView: View {
    let item: Items
    @StateObject private var userVM = UserViewModel()
    @StateObject private var chatViewModel: ChatViewModel
    @State private var navigateToChatRoom = false
    @State private var chatRoomID: String?
    @State private var showAlert = false
    @State private var showUserItems = false
    @State private var showReportConfirmation = false
    @State private var showSelfChatAlert = false
    
    init(item: Items, currentUserID: String) {
        self.item = item
        _chatViewModel = StateObject(wrappedValue: ChatViewModel(senderID: currentUserID))
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                
                if let thumbnailURL = item.thumbnailURL ?? (item.images.first.flatMap { URL(string: $0) }) {
                    VStack(alignment: .center, spacing: 8) {
                        if item.images.count <= 1 {
                            Spacer()
                            HStack {
                                Spacer()
                                AsyncImage(url: thumbnailURL) { phase in
                                    switch phase {
                                    case .empty:
                                        ProgressView()
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .scaledToFit()
                                            .frame(maxWidth: UIScreen.main.bounds.width * 0.9, maxHeight: UIScreen.main.bounds.width * 0.9)
                                            .cornerRadius(8)
                                            .onTapGesture {
                                                if let usdzURL = item.usdzURL {
                                                    viewAR(url: usdzURL)
                                                }
                                            }
                                    case .failure:
                                        Text("이미지를 불러올 수 없습니다.")
                                            .frame(width: UIScreen.main.bounds.width * 0.9, height: UIScreen.main.bounds.width * 0.9)
                                            .background(Color.gray)
                                            .cornerRadius(8)
                                    @unknown default:
                                        EmptyView()
                                    }
                                }
                                Spacer().frame(width: 20)
                            }
                            Spacer()
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
                                                    .frame(maxWidth: UIScreen.main.bounds.width * 0.9, maxHeight: UIScreen.main.bounds.width * 0.9)
                                                    .onTapGesture {
                                                        if let usdzURL = item.usdzURL {
                                                            viewAR(url: usdzURL)
                                                        }
                                                    }
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
                                                        .frame(maxWidth: UIScreen.main.bounds.width * 0.9, maxHeight: UIScreen.main.bounds.width * 0.9) // 더 크게 조정
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
                    .padding(.vertical, -8)
                }
                
                VStack(alignment: .leading, spacing: 16) {
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
                                    .foregroundColor(.dynamicTextColor)
                            }
                            Text(item.location)
                                .font(.caption)
                                .foregroundColor(.dynamicTextColor)
                        }
                        Spacer()
                        Text(item.formattedCreatedAt)
                            .font(.caption)
                            .foregroundColor(.dynamicTextColor)
                    }
                    
                    Divider()
                    
                    Text(item.itemName)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.dynamicTextColor)
                    
                    Text(item.description)
                        .font(.body)
                        .fontWeight(.light)
                        .foregroundColor(.dynamicTextColor)
                    
                    Divider()
                    
                    HStack {
                        Text("\(formattedPriceInTenThousandWon)")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.dynamicTextColor)
                        Spacer()
                        
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
            Color(UIColor { traitCollection in
                traitCollection.userInterfaceStyle == .dark ? .black : .white
            }).ignoresSafeArea()
        )
        .alert("알림", isPresented: $showSelfChatAlert) {
            Button("확인", role: .cancel) { }
        } message: {
            Text("자기 자신에게는 채팅을 보낼 수 없습니다.")
        }
        .onAppear {
            userVM.setUserId(item.userId)
        }
        .navigationTitle("상품 상세 정보")
        .navigationBarTitleDisplayMode(.inline)
        .background(
            NavigationLink(
                destination: Group {
                    if let chatRoomID = chatRoomID {
                        ChatContentView(
                            chatViewModel: chatViewModel,
                            chatRoomID: chatRoomID,
                            currentUserID: chatViewModel.senderID,
                            otherUserID: item.userId
                        )
                    }
                },
                isActive: $navigateToChatRoom
            ) {
                EmptyView()
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
    
    func viewAR(url: URL) {
        let safariVC = SFSafariViewController(url: url)
        let vc = UIApplication.shared.firstKeyWindow?.rootViewController?.presentedViewController ?? UIApplication.shared.firstKeyWindow?.rootViewController
        vc?.present(safariVC, animated: true)
    }
    
    func startChat() {
        // 본인 상품인 경우 채팅 방지
        if item.userId == chatViewModel.senderID {
            withAnimation {
                showSelfChatAlert = true
            }
            return
        }
        
        // 판매자 정보로 User 객체 생성
        let seller = User(
            id: item.userId,
            email: "",
            username: userVM.user?.username ?? "알 수 없음",
            profileImageUrl: userVM.user?.profileImageUrl
        )
        
        // 기존 채팅방 확인
        if let existingChatRoom = chatViewModel.chatRooms.first(where: { room in
            room.participants.contains(item.userId) && room.participants.contains(chatViewModel.senderID)
        }) {
            self.chatRoomID = existingChatRoom.id
            self.navigateToChatRoom = true
        } else {
            chatViewModel.createNewChatRoom(with: seller)
            // 채팅방 목록을 다시 불러온 후 새로 생성된 채팅방으로 이동
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if let newChatRoom = chatViewModel.chatRooms.first(where: { room in
                    room.participants.contains(item.userId) && room.participants.contains(chatViewModel.senderID)
                }) {
                    self.chatRoomID = newChatRoom.id
                    self.navigateToChatRoom = true
                }
            }
        }
    }
}
