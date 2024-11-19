    //
    //  PushViewModel.swift
    //  SellAR
    //
    //  Created by 박범규 on 11/12/24.
    //



    //import Foundation
    //import Firebase
    //import FirebaseMessaging
    //import GoogleSignIn
    //import FirebaseAuth
    //
    //class FCMNotificationService {
    //    static let shared = FCMNotificationService()
    //
    //    private init() {}
    //
    //    // V1 API 엔드포인트
    //    private let fcmURL = "https://fcm.googleapis.com/v1/projects/sellar-4fc83/messages:send"
    //
    //    func sendNotification(to token: String, title: String, body: String, data: [String: String]) async throws {
    //        // 현재 Firebase 앱의 설정에서 프로젝트 ID 가져오기
    //        guard let projectID = FirebaseApp.app()?.options.projectID else {
    //            throw NSError(domain: "FCMError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Project ID not found"])
    //        }
    //
    //        // FCM V1 API 엔드포인트 구성
    //        let urlString = "https://fcm.googleapis.com/v1/projects/\(projectID)/messages:send"
    //        guard let url = URL(string: urlString) else {
    //            throw NSError(domain: "FCMError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
    //        }
    //
    //        // Firebase 인증 토큰 가져오기
    //        guard let token = try? await Auth.auth().currentUser?.getIDToken() else {
    //            throw NSError(domain: "FCMError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to get Firebase token"])
    //        }
    //
    //        var request = URLRequest(url: url)
    //        request.httpMethod = "POST"
    //        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    //        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    //
    //        // FCM V1 API 메시지 형식
    //        let message: [String: Any] = [
    //            "message": [
    //                "token": token,
    //                "notification": [
    //                    "title": title,
    //                    "body": body
    //                ],
    //                "data": data,
    //                "android": [
    //                    "priority": "high"
    //                ],
    //                "apns": [
    //                    "payload": [
    //                        "aps": [
    //                            "sound": "default",
    //                            "badge": 1
    //                        ]
    //                    ]
    //                ]
    //            ]
    //        ]
    //
    //        let jsonData = try JSONSerialization.data(withJSONObject: message)
    //        request.httpBody = jsonData
    //
    //        let (_, response) = try await URLSession.shared.data(for: request)
    //
    //        guard let httpResponse = response as? HTTPURLResponse,
    //              (200...299).contains(httpResponse.statusCode) else {
    //            throw NSError(domain: "FCMError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to send notification"])
    //        }
    //    }
    //}

    import Foundation
    import FirebaseMessaging
    import FirebaseFirestore
    import UserNotifications

    final class PushNotificationManager {
        static let shared = PushNotificationManager()
        
        private init() { }
        
        // FCM 토큰 저장
        func updateFCMToken(for userID: String, token: String) {
            let db = Firestore.firestore()
            db.collection("users").document(userID).updateData([
                "fcmToken": token
            ]) { error in
                if let error = error {
                    print("Error updating FCM token: \(error)")
                }
            }
        }
        
        // 채팅 메시지 푸시 알림 전송
        func sendChatPushNotification(to receiverID: String, senderName: String, message: String) {
            let db = Firestore.firestore()
            
            // 수신자의 FCM 토큰 가져오기
            db.collection("users").document(receiverID).getDocument { [weak self] document, error in
                if let document = document, let receiverData = document.data() {
                    if let fcmToken = receiverData["fcmToken"] as? String {
                        self?.sendNotification(
                            toFCMToken: fcmToken,
                            title: "\(senderName)님의 메시지",
                            body: message,
                            data: [
                                "type": "chat",
                                "senderID": receiverID
                            ]
                        )
                    }
                }
            }
        }
        
        // FCM 푸시 알림 전송 기본 함수
        private func sendNotification(toFCMToken token: String, title: String, body: String, data: [String: String] = [:]) {
            let serverKey = Bundle.main.object(forInfoDictionaryKey: "FIREBASE_PUSH_API_KEY") as? String ?? ""
            
            var message: [String: Any] = [
                "to": token,
                "notification": [
                    "title": title,
                    "body": body,
                    "sound": "default"
                ],
                "data": data
            ]
            
            let urlString = "https://fcm.googleapis.com/fcm/send"
            guard let url = URL(string: urlString) else { return }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("key=\(serverKey)", forHTTPHeaderField: "Authorization")
            
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: message, options: .prettyPrinted)
                request.httpBody = jsonData
                
                let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                    if let error = error {
                        print("Error sending FCM message: \(error.localizedDescription)")
                    } else if let data = data {
                        if let responseString = String(data: data, encoding: .utf8) {
                            print("FCM Response: \(responseString)")
                        }
                    }
                }
                task.resume()
            } catch {
                print("Error creating FCM request: \(error.localizedDescription)")
            }
        }
        
        // 채팅방별 알림 설정 관리
        func updateChatRoomNotificationSettings(chatRoomID: String, userID: String, enabled: Bool) {
            let db = Firestore.firestore()
            db.collection("chatRoomSettings").document(chatRoomID).setData([
                "userID": userID,
                "notificationsEnabled": enabled
            ], merge: true)
        }
        
        // 채팅방 알림 설정 확인
        func getChatRoomNotificationSettings(chatRoomID: String, userID: String, completion: @escaping (Bool) -> Void) {
            let db = Firestore.firestore()
            db.collection("chatRoomSettings").document(chatRoomID).getDocument { document, error in
                if let document = document, document.exists,
                   let data = document.data(),
                   let enabled = data["notificationsEnabled"] as? Bool {
                    completion(enabled)
                } else {
                    completion(true) // 기본값은 알림 활성화
                }
            }
        }
    }
