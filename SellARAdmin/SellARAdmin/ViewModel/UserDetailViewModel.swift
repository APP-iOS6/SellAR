//
//  Untitled.swift
//  SellARAdmin
//
//  Created by 박범규 on 11/20/24.
//

import SwiftUI

class UserDetailViewModel: ObservableObject {
    @Published var userStats = UserStats()
    
    func fetchUserStats(for user: User) {
        // Firestore에서 사용자 통계 데이터 가져오기
        // 실제 구현에서는 이 부분을 구현해야 합니다
    }
    
    func toggleUserStatus(_ user: User) {
        // 사용자 상태 토글 (차단/활성화)
        // 실제 구현에서는 이 부분을 구현해야 합니다
    }
    
    func sendWarning(to user: User) {
        // 경고 메시지 발송
        // 실제 구현에서는 이 부분을 구현해야 합니다
    }
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: date)
    }
}
