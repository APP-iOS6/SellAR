//
//  File.swift
//  SellAR
//
//  Created by 박범규 on 11/5/24.
//


import SwiftUI
import Firebase



// 채팅방 리스트 View
struct StartMessageView: View {
    @ObservedObject var loginViewModel: LoginViewModel
    @ObservedObject private var viewModel: ChatViewModel
    @Environment(\.colorScheme) var colorScheme
    @State private var editMode = EditMode.inactive
    @State private var selectedChatRooms: Set<String> = []

    private var backgroundColor: Color {
        colorScheme == .dark ?
            Color(red: 23/255, green: 34/255, blue: 67/255) :
            Color(red: 203/255, green: 217/255, blue: 238/255)
    }
    private var buttonColor: Color {
        Color(red: 76/255, green: 127/255, blue: 200/255)
    }
   
    
    init(loginViewModel: LoginViewModel) {
        self.loginViewModel = loginViewModel
        // loginViewModel.user.id가 비어있지 않을 때만 ChatViewModel 초기화
        _viewModel = ObservedObject(wrappedValue: ChatViewModel(senderID: loginViewModel.user.id))
    }
    
    var body: some View {
        Group {
            if loginViewModel.user.id.isEmpty {
                // 로그인하지 않은 상태
                VStack {
                    Image("SellarLogoWhite")
                        .resizable()
                        .frame(width: 150, height: 150)
                        .padding(.bottom, 15)
                    Text("로그인이 필요합니다.")
                        .foregroundStyle(Color.primary)
                        .bold()
                        .padding(.bottom, 30)
                    NavigationLink(destination: LoginView()) {
                        Text("로그인하기")
                            .font(.body)
                            .foregroundColor(.white)
                            .bold()
                            .padding()
                            .background(buttonColor)
                            .cornerRadius(25)
                            .shadow(color: Color.black.opacity(0.16), radius: 3, x: 0, y: 2)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(backgroundColor.ignoresSafeArea())
            } else {
                // 로그인한 상태
                NavigationView {
                    ZStack {
                        Color(UIColor.systemBackground).edgesIgnoringSafeArea(.all)
                        
                        if viewModel.chatRooms.isEmpty {
                            // 채팅방이 없는 경우
                            VStack {
                                Text("아직 채팅방이 없습니다")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                Text("새로운 채팅을 시작해보세요!")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                    .padding(.top, 8)
                                
                                Button(action: {
                                    // 새 채팅 시작 버튼 액션
                                    createNewChat()
                                }) {
                                    Text("새 채팅 시작하기")
                                        .font(.body)
                                        .foregroundColor(.white)
                                        .padding()
                                        .background(buttonColor)
                                        .cornerRadius(10)
                                }
                                .padding(.top, 20)
                            }
                        } else {
                            // 채팅방 목록 표시
                            List(selection: $selectedChatRooms) {
                                ForEach(viewModel.chatRooms) { chatRoom in
                                    if let otherUserID = chatRoom.participants.first(where: { $0 != loginViewModel.user.id }) {
                                        ZStack {
                                            NavigationLink(destination: ChatContentView(
                                                chatViewModel: viewModel,
                                                chatRoomID: chatRoom.id,
                                                currentUserID: loginViewModel.user.id,
                                                otherUserID: otherUserID
                                            )) {
                                                EmptyView()
                                            }
                                            .opacity(0)
                                            
                                            ChatRoomRow(
                                                chatRoom: chatRoom,
                                                currentUserID: viewModel.senderID,
                                                chatViewModel: viewModel,
                                                hasLeftChat: !chatRoom.participants.contains(otherUserID)
                                            )
                                        }
                                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                            Button(role: .destructive) {
                                                viewModel.leaveChatRoom(chatRoomID: chatRoom.id)
                                            } label: {
                                                Text("나가기")
                                            }
                                        }
                                        .tag(chatRoom.id) // Selection을 위한 태그 추가
                                    }
                                }
                            }
                            .listStyle(PlainListStyle())
                            .environment(\.editMode, $editMode)
                            
                            if editMode.isEditing && !selectedChatRooms.isEmpty {
                                VStack {
                                    Spacer()
                                    Button(action: {
                                        for chatRoomId in selectedChatRooms {
                                            viewModel.leaveChatRoom(chatRoomID: chatRoomId)
                                        }
                                        selectedChatRooms.removeAll()
                                        editMode = .inactive
                                    }) {
                                        Text("선택한 채팅방 나가기 (\(selectedChatRooms.count))")
                                            .font(.body)
                                            .foregroundColor(.white)
                                            .padding()
                                            .frame(maxWidth: .infinity)
                                            .background(buttonColor)
                                            .cornerRadius(10)
                                    }
                                    .padding()
                                }
                            }
                        }
                    }
                    .background(backgroundColor.ignoresSafeArea())
                    .navigationTitle("채팅")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button(action: {
                                withAnimation {
                                    editMode = editMode.isEditing ? .inactive : .active
                                    if !editMode.isEditing {
                                        selectedChatRooms.removeAll()
                                    }
                                }
                            }) {
                                Text(editMode.isEditing ? "완료" : "편집")
                            }
                        }
                    }
                }
            }
        }
        .onChange(of: loginViewModel.user.id) { newID in
            if !newID.isEmpty {
                viewModel.senderID = newID
                viewModel.fetchChatRooms()
            }
        }
    }
    private func createNewChat() {
        // 테스트용 채팅방 생성
        let db = Firestore.firestore()
        let newChatRoom: [String: Any] = [
            "name": "테스트 채팅방",
            "profileImageURL": "",
            "latestMessage": "환영합니다!",
            "latestTimestamp": Timestamp(date: Date()),
            "unreadCount": [loginViewModel.user.id: 0],
            "participants": [loginViewModel.user.id]
        ]
        
        db.collection("chatRooms").addDocument(data: newChatRoom) { error in
            if let error = error {
                print("채팅방 생성 실패: \(error.localizedDescription)")
            } else {
                print("새 채팅방이 생성되었습니다")
                viewModel.fetchChatRooms()
            }
        }
    }
}
