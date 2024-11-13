//
//  PushViewModel.swift
//  SellAR
//
//  Created by 박범규 on 11/12/24.
//

import Foundation
import FirebaseMessaging

class FCMNotificationService {
    static let shared = FCMNotificationService()
    private let baseURL = "https://fcm.googleapis.com/v1/projects/sellar-4fc83/messages:send"
    
    private var accessToken: String?
    private var tokenExpirationDate: Date?
    
    private func refreshAccessToken() async throws -> String {
        // Firebase Admin SDK의 서비스 계정 인증 정보를 사용하여
        // Google OAuth2 토큰을 얻는 로직 구현
        // https://developers.google.com/identity/protocols/oauth2/service-account
        return "116344996691347980864"
    }
    
    private func getValidAccessToken() async throws -> String {
        if let token = accessToken,
           let expirationDate = tokenExpirationDate,
           expirationDate > Date() {
            return token
        }
        
        let newToken = try await refreshAccessToken()
        accessToken = newToken
        tokenExpirationDate = Date().addingTimeInterval(3600) // 1시간
        return newToken
    }
    
    func sendNotification(to fcmToken: String, title: String, body: String, data: [String: String]) async throws {
        let token = try await getValidAccessToken()
        
        var request = URLRequest(url: URL(string: baseURL)!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let message: [String: Any] = [
            "message": [
                "token": fcmToken,
                "notification": [
                    "title": title,
                    "body": body
                ],
                "data": data
            ]
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: message)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "FCM API 요청 실패"])
        }
        
        print("알림 전송 성공: \(String(data: data, encoding: .utf8) ?? "")")
    }
}
