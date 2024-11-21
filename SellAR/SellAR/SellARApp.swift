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
    
    // 방향 제한 설정 (세로 모드 고정)
        func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
            return .portrait // 세로 모드만 허용
        }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    // 백그라운드에서 푸시 알림을 탭했을 때 실행
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("APNS token: \(deviceToken)")
        Messaging.messaging().apnsToken = deviceToken
        
        Messaging.messaging().token { token, error in
            if let error = error {
                print("Error fetching FCM token: \(error)")
                return
            }
            
            if let token = token, let userID = Auth.auth().currentUser?.uid {
                PushNotificationManager.shared.updateFCMToken(for: userID, token: token)
            }
        }
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

extension AppDelegate {
    // 푸시 알림 탭 처리
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        
        // FCM 메시지 처리
        if let messageID = userInfo["gcm.message_id"] {
            print("Message ID: \(messageID)")
        }
        
        // 채팅 관련 데이터 처리
        if let type = userInfo["type"] as? String,
           type == "chat",
           let senderID = userInfo["senderID"] as? String {
            // 채팅방으로 이동하는 로직
            NotificationCenter.default.post(
                name: NSNotification.Name("OpenChatRoom"),
                object: nil,
                userInfo: ["senderID": senderID]
            )
        }
        
        completionHandler()
    }
    
    // 푸시 알림 에러 처리
    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        print("Failed to register for remote notifications: \(error)")
    }
    
    // 알림 설정 상태 확인
    func checkNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            guard settings.authorizationStatus == .authorized else {
                // 알림 권한이 없는 경우 처리
                print("Notifications not authorized")
                return
            }
            
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
}


@main
struct SellARApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var chatViewModel = ChatViewModel(senderID: Auth.auth().currentUser?.uid ?? "")
        
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                ContentView(viewModel: LoginViewModel())
                    .environmentObject(LoginViewModel())
                    .environmentObject(chatViewModel)
            }
        }
    }
}
