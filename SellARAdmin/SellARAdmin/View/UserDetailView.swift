//
//  Untitled.swift
//  SellARAdmin
//
//  Created by 박범규 on 11/20/24.
//
import SwiftUI
import Firebase

struct UserDetailView: View {
    let user: User
    @ObservedObject var viewModel: AdminViewModel
    @State private var showingSendWarningAlert = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 프로필 정보
                HStack {
                    AsyncImage(url: URL(string: user.profileImageUrl ?? "")) { image in
                        image.resizable()
                            .scaledToFill()
                    } placeholder: {
                        Circle().fill(Color.gray)
                    }
                    .frame(width: 120, height: 120)
                    .clipShape(Circle())
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text(user.username)
                            .font(.title)
                        Text(user.email)
                            .font(.headline)
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                
                // 사용자 통계
                GroupBox(label: Text("사용자 정보").font(.headline)) {
                    VStack(spacing: 12) {
                        HStack {
                            Text("게시물")
                            Spacer()
                            Text("\(viewModel.userStats.postCount)개")
                                .bold()
                        }
                        
                        HStack {
                            Text("신고 횟수")
                            Spacer()
                            Text("\(viewModel.userStats.reportCount)회")
                                .bold()
                                .foregroundColor(viewModel.userStats.reportCount > 0 ? .red : .primary)
                        }
                    }
                    .padding()
                }
                
                // 관리자 도구
                GroupBox(label: Text("관리자 도구").font(.headline)) {
                    VStack(spacing: 12) {
                        Button(action: {
                            viewModel.toggleUserStatus(user)
                        }) {
                            Text(user.isBlocked ? "계정 활성화" : "계정 정지")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(user.isBlocked ? Color.green : Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        
                        Button(action: {
                            showingSendWarningAlert = true
                        }) {
                            Text("경고 메시지 전송")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.orange)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    }
                    .padding()
                }
            }
            .padding()
        }
        .alert("경고 메시지 전송", isPresented: $showingSendWarningAlert) {
            Button("취소", role: .cancel) { }
            Button("전송", role: .destructive) {
                viewModel.sendWarningMessage(to: user)
            }
        } message: {
            Text("신고가 들어왔습니다. 주의 부탁드립니다.")
        }
    }
}
