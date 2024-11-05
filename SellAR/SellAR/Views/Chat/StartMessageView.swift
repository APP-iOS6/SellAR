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
                    Text("채팅을 시작하려면 로그인이 필요합니다")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                    
                    NavigationLink(destination: LoginView()) {
                        Text("로그인하기")
                            .font(.body)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.black)
            } else {
                // 로그인한 상태
                NavigationView {
                    ZStack {
                        Color.black.edgesIgnoringSafeArea(.all)
                        
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
                                        .background(Color.blue)
                                        .cornerRadius(10)
                                }
                                .padding(.top, 20)
                            }
                        } else {
                            // 채팅방 목록 표시
                            List(viewModel.chatRooms) { chatRoom in
                                NavigationLink(destination: ChatContentView(chatViewModel: viewModel, chatRoomID: chatRoom.id)) {
                                    ChatRoomRow(chatRoom: chatRoom)
                                }
                            }
                            .listStyle(PlainListStyle())
                        }
                    }
                    .navigationTitle("채팅")
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            NavigationLink(destination: UserListView(chatViewModel: viewModel)) {
                                Image(systemName: "square.and.pencil")
                                    .foregroundColor(.white)
                            }
                        }
                    }
                }
            }
        }
        // loginViewModel.user.id가 변경될 때 ChatViewModel 업데이트
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
            "unreadCount": 0,
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
