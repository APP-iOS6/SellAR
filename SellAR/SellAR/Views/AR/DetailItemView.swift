//
//  SellARApp.swift
//  SellAR
//
//  Created by Juno Lee on 10/30/24.
//

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
                
                if let thumbnailURL = item.thumbnailURL {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            
                            AsyncImage(url: thumbnailURL) { phase in
                                switch phase {
                                case .empty:
                                    ProgressView()
                                case .success(let image):
                                    image.resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(maxWidth: UIScreen.main.bounds.width * 0.9, maxHeight: UIScreen.main.bounds.width * 0.9)
                                        .cornerRadius(8)
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

                            
                            ForEach(item.images, id: \.self) { imageURL in
                                if let url = URL(string: imageURL) {
                                    AsyncImage(url: url) { phase in
                                        switch phase {
                                        case .empty:
                                            ProgressView()
                                        case .success(let image):
                                            image.resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(maxWidth: UIScreen.main.bounds.width * 0.9, maxHeight: UIScreen.main.bounds.width * 0.9)
                                                .cornerRadius(8)
                                        case .failure:
                                            Text("이미지를 불러올 수 없습니다")
                                        @unknown default:
                                            EmptyView()
                                        }
                                    }
                                }
                            }
                        }
                    }
                } else {
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(item.images, id: \.self) { imageURL in
                                if let url = URL(string: imageURL) {
                                    AsyncImage(url: url) { phase in
                                        switch phase {
                                        case .empty:
                                            ProgressView()
                                        case .success(let image):
                                            image.resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(maxWidth: UIScreen.main.bounds.width * 0.9, maxHeight: UIScreen.main.bounds.width * 0.9)
                                                .cornerRadius(8)
                                        case .failure:
                                            Text("이미지를 불러올 수 없습니다")
                                        @unknown default:
                                            EmptyView()
                                        }
                                    }
                                }
                            }
                        }
                    }
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
                                        .foregroundColor(
                                            Color(UIColor { traitCollection in
                                                return traitCollection.userInterfaceStyle == .dark ? .black : .white
                                            })
                                        )
                                    Text("AR 보기")
                                        .font(.footnote)
                                        .foregroundColor(
                                            Color(UIColor { traitCollection in
                                                return traitCollection.userInterfaceStyle == .dark ? .black : .white
                                            })
                                        )
                                }
                                .padding(.vertical, 6)
                                .padding(.horizontal, 12)
                                .background(
                                    Color(UIColor { traitCollection in
                                        return traitCollection.userInterfaceStyle == .dark ? UIColor(red: 0.5, green: 0.7, blue: 1.0, alpha: 1.0) : UIColor(red: 0.3, green: 0.5, blue: 0.9, alpha: 1.0)
                                    })
                                )
                                .cornerRadius(20)
                            }
                        }
                        
                        Button(action: {
                            startChat()
                        }) {
                            HStack {
                                Image(systemName: "message")
                                    .foregroundColor(
                                        Color(UIColor { traitCollection in
                                            return traitCollection.userInterfaceStyle == .dark ? .black : .white
                                        })
                                    )
                                Text("채팅하기")
                                    .font(.footnote)
                                    .foregroundColor(
                                        Color(UIColor { traitCollection in
                                            return traitCollection.userInterfaceStyle == .dark ? .black : .white
                                        })
                                    )
                            }
                            .padding(.vertical, 6)
                            .padding(.horizontal, 12)
                            .background(
                                Color(UIColor { traitCollection in
                                    return traitCollection.userInterfaceStyle == .dark ? UIColor(red: 0.5, green: 0.9, blue: 0.5, alpha: 1.0) : UIColor(red: 0.3, green: 0.7, blue: 0.3, alpha: 1.0)
                                })
                            )
                            .cornerRadius(20)
                        }
                    }
                }
                .padding()
                .background(
                    Color(UIColor { traitCollection in
                        return traitCollection.userInterfaceStyle == .dark ? .gray : .white
                    })
                )
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
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            showAlert = true
                        }) {
                            Text("신고하기")
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
                                
                                .background(Color.blue.opacity(0.7))
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
                    }
                )
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
    
    // 신고하기 기능
        func reportItem() {
            // 신고 기능 로직을 여기에 추가
            withAnimation {
                showReportConfirmation = true
            }
            print("신고가 완료되었습니다.")
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

