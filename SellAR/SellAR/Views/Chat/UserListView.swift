//
//  UserListView.swift
//  SellAR
//
//  Created by 박범규 on 11/5/24.
//
import SwiftUI
import Firebase
// UserListView 추가 (새로운 채팅 시작을 위한 사용자 목록)
struct UserListView: View {
    @ObservedObject var chatViewModel: ChatViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var users: [User] = []
    
    var body: some View {
        NavigationView {
            List(users, id: \.id) { user in
                Button(action: {
                    chatViewModel.createNewChatRoom(with: user)
                    dismiss()
                }) {
                    HStack {
                        AsyncImage(url: URL(string: user.profileImageUrl ?? "")) { image in
                            image.resizable()
                        } placeholder: {
                            Circle().fill(Color.gray)
                        }
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                        
                        VStack(alignment: .leading) {
                            Text(user.username)
                                .font(.headline)
                            Text(user.email)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .navigationTitle("새로운 채팅")
            .onAppear {
                fetchUsers()
            }
        }
    }
    
    private func fetchUsers() {
        let db = Firestore.firestore()
        db.collection("users")
            .whereField("id", isNotEqualTo: chatViewModel.senderID)
            .getDocuments { snapshot, error in
                if let documents = snapshot?.documents {
                    self.users = documents.compactMap { doc -> User? in
                        let data = doc.data()
                        return User(
                            id: doc.documentID,
                            email: data["email"] as? String ?? "",
                            username: data["username"] as? String ?? "",
                            profileImageUrl: data["profileImageUrl"] as? String
                        )
                    }
                }
            }
    }
}
