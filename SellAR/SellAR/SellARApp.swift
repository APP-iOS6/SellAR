//
//  SellARApp.swift
//  SellAR
//
//  Created by Juno Lee on 10/30/24.
//

import SwiftUI
import FirebaseCore
import FirebaseMessaging
import UserNotifications
import GoogleSignIn

class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        
        // Messaging delegate 설정
        Messaging.messaging().delegate = self
        
        // 푸시 알림 권한 요청
        UNUserNotificationCenter.current().delegate = self
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { granted, error in
            print("Permission granted: \(granted)")
            guard granted else { return }
            
            DispatchQueue.main.async {
                application.registerForRemoteNotifications()
            }
        }
        
        return true
    }
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
    
    // 토큰 생성 시 호출되는 메서드
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase registration token: \(String(describing: fcmToken))")
    }
    // 알림 수신 처리
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("Received notification: \(response.notification.request.content.userInfo)")
        completionHandler()
    }

    // 앱이 foreground 상태일 때 알림 수신 처리
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge, .sound])
    }
    // APNS 델리게이트 메서드들 추가
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        PushNotificationDebugger.shared.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        PushNotificationDebugger.shared.application(application, didFailToRegisterForRemoteNotificationsWithError: error)
    }

    
}
class PushNotificationDebugger: NSObject, UNUserNotificationCenterDelegate, MessagingDelegate {
    
    static let shared = PushNotificationDebugger()
    
    func setupDebugMode() {
        UNUserNotificationCenter.current().delegate = self
        Messaging.messaging().delegate = self
        
        // APNS 권한 요청 및 상태 체크
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error = error {
                print("❌ APNS 권한 요청 에러: \(error.localizedDescription)")
                return
            }
            
            print("✅ APNS 권한 상태: \(granted ? "허용됨" : "거부됨")")
            
            // 현재 알림 설정 상태 확인
            UNUserNotificationCenter.current().getNotificationSettings { settings in
                print("📱 알림 설정 상태:")
                print("- 알림 허용: \(settings.authorizationStatus.debugDescription)")
                print("- 알림음: \(settings.soundSetting.debugDescription)")
                print("- 배지: \(settings.badgeSetting.debugDescription)")
                print("- 알림 배너: \(settings.alertSetting.debugDescription)")
            }
        }
        
        // APNS 등록 시도
        DispatchQueue.main.async {
            UIApplication.shared.registerForRemoteNotifications()
        }
    }
    
    // APNS 토큰 받기 성공
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { String(format: "%02.2hhx", $0) }
        let token = tokenParts.joined()
        print("✅ APNS 토큰 발급 성공: \(token)")
        
        // Firebase 토큰도 확인
        Messaging.messaging().apnsToken = deviceToken
    }
    
    // APNS 토큰 받기 실패
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("❌ APNS 토큰 발급 실패: \(error.localizedDescription)")
    }
    
    // Firebase 토큰 업데이트 확인
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        if let token = fcmToken {
            print("✅ Firebase 토큰 발급 성공: \(token)")
        } else {
            print("❌ Firebase 토큰 발급 실패")
        }
    }
    
    // 알림 수신 테스트
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                              didReceive response: UNNotificationResponse,
                              withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        print("📬 알림 수신됨: \(userInfo)")
        completionHandler()
    }
    
    // 앱이 포그라운드일 때 알림 수신 테스트
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                              willPresent notification: UNNotification,
                              withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        print("📬 포그라운드 알림 수신됨: \(userInfo)")
        completionHandler([.banner, .badge, .sound])
    }
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        
        // 디버거 설정
        PushNotificationDebugger.shared.setupDebugMode()
        
        return true
    }


}

// UNAuthorizationStatus 디버그 설명 추가
extension UNAuthorizationStatus {
    var debugDescription: String {
        switch self {
        case .notDetermined: return "결정되지 않음"
        case .denied: return "거부됨"
        case .authorized: return "허용됨"
        case .provisional: return "임시 허용"
        case .ephemeral: return "임시 세션"
        @unknown default: return "알 수 없음"
        }
    }
}

// UNNotificationSetting 디버그 설명 추가
extension UNNotificationSetting {
    var debugDescription: String {
        switch self {
        case .notSupported: return "지원 안됨"
        case .disabled: return "비활성화됨"
        case .enabled: return "활성화됨"
        @unknown default: return "알 수 없음"
        }
    }
}


@main
struct SellARApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
