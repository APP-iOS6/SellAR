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

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        // 앱 실행 시 사용자에게 알림 허용 권한을 받음
          UNUserNotificationCenter.current().delegate = self
          
          let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound] // 필요한 알림 권한을 설정
          UNUserNotificationCenter.current().requestAuthorization(
              options: authOptions,
              completionHandler: { _, _ in }
          )
          
          // UNUserNotificationCenterDelegate를 구현한 메서드를 실행시킴
          application.registerForRemoteNotifications()
          
          // 파이어베이스 Meesaging 설정
          Messaging.messaging().delegate = self
        return true
    }
    
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    // 백그라운드에서 푸시 알림을 탭했을 때 실행
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("APNS token: \(deviceToken)")
        Messaging.messaging().apnsToken = deviceToken
    }
    
    // Foreground(앱 켜진 상태)에서도 알림 오는 설정
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.list, .banner])
    }
}

extension AppDelegate: MessagingDelegate {
    
    // 파이어베이스 MessagingDelegate 설정
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
      print("Firebase registration token: \(String(describing: fcmToken))")

      let dataDict: [String: String] = ["token": fcmToken ?? ""]
      NotificationCenter.default.post(
        name: Notification.Name("FCMToken"),
        object: nil,
        userInfo: dataDict
      )
      // TODO: If necessary send token to application server.
      // Note: This callback is fired at each app startup and whenever a new token is generated.
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
