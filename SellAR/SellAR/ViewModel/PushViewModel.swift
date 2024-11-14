//
//  PushViewModel.swift
//  SellAR
//
//  Created by 박범규 on 11/12/24.
//



import Foundation
import Firebase
import FirebaseMessaging
import GoogleSignIn
import FirebaseAuth

class FCMNotificationService {
    static let shared = FCMNotificationService()
    
    private init() {}
    
    // V1 API 엔드포인트
    private let fcmURL = "https://fcm.googleapis.com/v1/projects/sellar-4fc83/messages:send"
    
    func sendNotification(to token: String, title: String, body: String, data: [String: String]) async throws {
        // 현재 Firebase 앱의 설정에서 프로젝트 ID 가져오기
        guard let projectID = FirebaseApp.app()?.options.projectID else {
            throw NSError(domain: "FCMError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Project ID not found"])
        }
        
        // FCM V1 API 엔드포인트 구성
        let urlString = "https://fcm.googleapis.com/v1/projects/\(projectID)/messages:send"
        guard let url = URL(string: urlString) else {
            throw NSError(domain: "FCMError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
        }
        
        // Firebase 인증 토큰 가져오기
        guard let token = try? await Auth.auth().currentUser?.getIDToken() else {
            throw NSError(domain: "FCMError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to get Firebase token"])
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        // FCM V1 API 메시지 형식
        let message: [String: Any] = [
            "message": [
                "token": token,
                "notification": [
                    "title": title,
                    "body": body
                ],
                "data": data,
                "android": [
                    "priority": "high"
                ],
                "apns": [
                    "payload": [
                        "aps": [
                            "sound": "default",
                            "badge": 1
                        ]
                    ]
                ]
            ]
        ]
        
        let jsonData = try JSONSerialization.data(withJSONObject: message)
        request.httpBody = jsonData
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NSError(domain: "FCMError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to send notification"])
        }
    }
}
