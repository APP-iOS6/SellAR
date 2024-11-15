//
//  DetailItemView.swift
//  SellAR
//
//  Created by Juno Lee on 11/8/24.
//

import SwiftUI
import SafariServices

struct DetailItemView: View {
    let item: Items
    @StateObject private var userVM = UserViewModel()
    @StateObject private var chatViewModel: ChatViewModel
    @State private var navigateToChatRoom = false
    @State private var chatRoomID: String?
    @State private var showAlert = false
    @State private var showUserItems = false
    @State private var showReportConfirmation = false  // 추가: 신고 완료 메시지 표시 여부
    
    init(item: Items, currentUserID: String) {
          self.item = item
          _chatViewModel = StateObject(wrappedValue: ChatViewModel(senderID: currentUserID))
      }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                
                // 상품 썸네일 이미지
                if let thumbnailURL = item.thumbnailURL {
                    AsyncImage(url: thumbnailURL) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                        case .success(let image):
                            image.resizable()
                                .aspectRatio(contentMode: .fit)
                        case .failure:
                            Text("썸네일을 불러올 수 없습니다")
                        @unknown default:
                            EmptyView()
                        }
                    }
                }
                
                // 등록된 이미지들
                if !item.images.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("상품 이미지")
                            .font(.headline)
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
                                            case .failure:
                                                Text("이미지를 불러올 수 없습니다")
                                            @unknown default:
                                                EmptyView()
                                            }
                                        }
                                        .frame(width: 300, height: 300)
                                        .cornerRadius(8)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.vertical)
                }
                
                // 판매자 정보 (클릭 시 이동)
                HStack {
                    if let profileImageUrl = userVM.user?.profileImageUrl, let url = URL(string: profileImageUrl) {
                        Button(action: {
                            showUserItems = true
                        }) {
                            AsyncImage(url: url) { phase in
                                switch phase {
                                case .empty:
                                    ProgressView()
                                case .success(let image):
                                    image.resizable()
                                        .scaledToFill()
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
                        }
                    } else {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 40, height: 40)
                    }
                    
                    Button(action: {
                        showUserItems = true
                    }) {
                        Text("판매자: \(userVM.user?.username ?? "알 수 없음")")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                // 상품 정보
                VStack(alignment: .leading, spacing: 8) {
                    Text(item.itemName)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("가격: \(item.price) 원")
                        .font(.title2)
                        .foregroundColor(.blue)
                    
                    Text(item.isSold ? "판매 완료" : "판매 중")  // 판매 상태 표시
                        .font(.subheadline)
                        .foregroundColor(item.isSold ? .gray : .red)

                    Text("\(item.description)")
                        .font(.body)
                        .padding(.top, 8)
                    
                    Text("지역: \(item.location)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.top, 4)
                }
                
                // AR로 보기 버튼
                if let usdzURL = item.usdzURL {
                    Button(action: {
                        viewAR(url: usdzURL)
                    }) {
                        HStack {
                            Image(systemName: "arkit")
                                .imageScale(.large)
                            Text("AR로 보기")
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(8)
                    }
                    .padding(.top, 16)
                }
                
                // 채팅하기 버튼
                Button(action: {
                    startChat()
                }) {
                    HStack {
                        Image(systemName: "message")
                            .imageScale(.small)
                        Text("채팅하기")
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green.opacity(0.2))
                    .cornerRadius(8)
                }
                .padding(.top, 8)
            }
            .padding()
        }
        .onAppear {
            userVM.setUserId(item.userId)
        }
        .navigationTitle("상품 상세 정보")
        .navigationBarTitleDisplayMode(.inline)
        .background(
            NavigationLink(destination: UserItemsView(userId: item.userId), isActive: $showUserItems) {
                EmptyView()
            }
            .hidden()
        )
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
    
    // AR 보기 기능
    func viewAR(url: URL) {
        let safariVC = SFSafariViewController(url: url)
        let vc = UIApplication.shared.firstKeyWindow?.rootViewController?.presentedViewController ?? UIApplication.shared.firstKeyWindow?.rootViewController
        vc?.present(safariVC, animated: true)
    }
    
    // 채팅 시작 기능
    func startChat() {
        // 판매자 정보로 User 객체 생성
        let seller = User(
            id: item.userId,
            email: "", // 이메일은 필요하지 않으므로 빈 문자열
            username: userVM.user?.username ?? "알 수 없음",
            profileImageUrl: userVM.user?.profileImageUrl
        )
        
        // 기존 채팅방이 있는지 확인
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
    
    
    // 신고하기 기능
    func reportItem() {
        // 신고 기능 로직을 여기에 추가
        withAnimation {
            showReportConfirmation = true
        }
        print("신고가 완료되었습니다.")
    }
}
