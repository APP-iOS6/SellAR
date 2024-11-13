//
//  SellARApp.swift
//  SellAR
//
//  Created by Juno Lee on 10/30/24.
//
import SwiftUI
import FirebaseCore
import GoogleSignIn
import FirebaseAuth
import Firebase
import FirebaseMessaging
import UserNotifications

//class AppDelegate: NSObject, UIApplicationDelegate {
//    func application(_ application: UIApplication,
//                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
//        FirebaseApp.configure()
//        
//        // 푸시 알림 권한 요청
//        requestPushNotificationPermission()
//        return true
//    }
//    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
//        return GIDSignIn.sharedInstance.handle(url)
//    }
//    private func requestPushNotificationPermission() {
//        UNUserNotificationCenter.current().delegate = self
//        Messaging.messaging().delegate = self
//        
//        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
//        UNUserNotificationCenter.current().requestAuthorization(
//            options: authOptions,
//            completionHandler: { granted, error in
//                if granted {
//                    print("푸시 알림 권한이 허용됨")
//                    DispatchQueue.main.async {
//                        UIApplication.shared.registerForRemoteNotifications()
//                    }
//                } else {
//                    print("푸시 알림 권한이 거부됨")
//                }
//            })
//    }
//}
//// FCM 델리게이트 구현
//extension AppDelegate: MessagingDelegate {
//    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
//        guard let token = fcmToken else { return }
//        print("FCM 토큰: \(token)")
//        saveFCMTokenToFirestore(token)
//    }
//    
//    private func saveFCMTokenToFirestore(_ token: String) {
//        guard let userID = Auth.auth().currentUser?.uid else { return }
//        
//        let db = Firestore.firestore()
//        db.collection("users").document(userID).updateData([
//            "fcmToken": token
//        ]) { error in
//            if let error = error {
//                print("FCM 토큰 저장 실패: \(error)")
//            } else {
//                print("FCM 토큰 저장 성공")
//            }
//        }
//    }
//}
//
//// 푸시 알림 수신 처리
//extension AppDelegate: UNUserNotificationCenterDelegate {
//    // 앱이 foreground에 있을 때 알림 처리
//    func userNotificationCenter(_ center: UNUserNotificationCenter,
//                              willPresent notification: UNNotification,
//                              withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
//        completionHandler([[.banner, .sound]])
//    }
//    
//    // 알림을 탭했을 때 처리
//    func userNotificationCenter(_ center: UNUserNotificationCenter,
//                              didReceive response: UNNotificationResponse,
//                              withCompletionHandler completionHandler: @escaping () -> Void) {
//        // notification.notification 대신 response.notification.request.content 사용
//        let userInfo = response.notification.request.content.userInfo
//        
//        // 채팅방 ID 추출
//        if let chatRoomID = userInfo["chatRoomID"] as? String {
//            // 해당 채팅방으로 이동하는 로직 구현
//            print("채팅방 ID: \(chatRoomID)")
//        }
//        
//        completionHandler()
//    }
//}
import UIKit
import Firebase
import FirebaseMessaging
import UserNotifications

class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Firebase 초기화
        FirebaseApp.configure()
        
        // 메시징 델리게이트 설정
        Messaging.messaging().delegate = self
        
        // 원격 알림 등록
        UNUserNotificationCenter.current().delegate = self
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { granted, error in
            print("알림 권한 허용 여부: \(granted)")
            if let error = error {
                print("알림 권한 에러: \(error)")
            }
            
            DispatchQueue.main.async {
                self.checkNotificationStatus()
            }
        }
        
        application.registerForRemoteNotifications()
        
        return true
    }
    
    // APNs 토큰 등록 성공
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        print("APNs 토큰: \(token)")
        Messaging.messaging().apnsToken = deviceToken
    }
    
    // APNs 토큰 등록 실패
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("APNs 등록 실패: \(error)")
    }
    
    // 알림 권한 상태 체크
    func checkNotificationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            print("알림 설정 상태:")
            print("권한 상태: \(settings.authorizationStatus.rawValue)")
            print("알림 배너: \(settings.alertSetting)")
            print("사운드: \(settings.soundSetting)")
            print("배지: \(settings.badgeSetting)")
        }
    }
}

// MARK: - MessagingDelegate
extension AppDelegate: MessagingDelegate {
    // FCM 등록 토큰 갱신
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("FCM 토큰: \(String(describing: fcmToken))")
        
        // 토큰을 서버에 전송하거나 저장하는 로직 추가
        let dataDict: [String: String] = ["token": fcmToken ?? ""]
        NotificationCenter.default.post(
            name: Notification.Name("FCMToken"),
            object: nil,
            userInfo: dataDict
        )
    }
}

// MARK: - UNUserNotificationCenterDelegate
extension AppDelegate: UNUserNotificationCenterDelegate {
    // 앱이 foreground 상태일 때 푸시 수신
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        let userInfo = notification.request.content.userInfo
        print("푸시 수신(foreground): \(userInfo)")
        
        completionHandler([[.banner, .badge, .sound]])
    }
    
    // 푸시 알림 탭했을 때
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        print("푸시 클릭: \(userInfo)")
        
        completionHandler()
    }
    
    // 백그라운드 푸시 수신
    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        print("백그라운드 푸시 수신: \(userInfo)")
        
        completionHandler(.newData)
    }
}

class NotificationManager {
    static let shared = NotificationManager()
    
    private init() {}
    
    func getCurrentFCMToken(completion: @escaping (String?) -> Void) {
        Messaging.messaging().token { token, error in
            if let error = error {
                print("FCM 토큰 조회 에러: \(error)")
                completion(nil)
                return
            }
            completion(token)
        }
    }
    
    func subscribeToTopic(_ topic: String) {
        Messaging.messaging().subscribe(toTopic: topic) { error in
            if let error = error {
                print("토픽 구독 실패: \(error)")
                return
            }
            print("\(topic) 토픽 구독 성공")
        }
    }
    
    func unsubscribeFromTopic(_ topic: String) {
        Messaging.messaging().unsubscribe(fromTopic: topic) { error in
            if let error = error {
                print("토픽 구독 해제 실패: \(error)")
                return
            }
            print("\(topic) 토픽 구독 해제 성공")
        }
    }
}


@main
struct SellARApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                ContentView(viewModel: LoginViewModel())
                    .environmentObject(LoginViewModel())
            }
        }
    }
}
