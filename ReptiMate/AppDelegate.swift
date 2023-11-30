//
//  AppDelegate.swift
//  ReptiMate
//
//  Created by 김기용 on 2023/04/11.
//

import UIKit
import KakaoSDKCommon
import GoogleSignIn
import FirebaseAnalytics
import FirebaseCore
import FirebaseMessaging
import Alamofire

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // for kakao login
        KakaoSDK.initSDK(appKey: "acc5f5264d4bd2693ff7e975dd2e4dac")
        
        // for fcm
        FirebaseApp.configure()
        setupFCM(application)
        
//        Messaging.messaging().delegate = self
//        Messaging.messaging().isAutoInitEnabled = true
//        UNUserNotificationCenter.current().delegate = self
//        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
//        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { granted, error in
//            if granted {
//                let a = Messaging.messaging().fcmToken
//                UserDefaults.standard.set(a, forKey: "fcmToken")
//                print("알림 등록이 완료되었습니다.   :   \(String(describing: a))")
//            }
//        }
        return true
    }
    
    private func setupFCM(_ application: UIApplication) {
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.sound, .alert, .badge]) { isAgree, error in
            if isAgree {
                let a = Messaging.messaging().fcmToken
                
                print("알림 등록이 완료되었습니다.  :  \(String(describing: a))")
            }
        }
        application.registerForRemoteNotifications()
    }
    
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
      return GIDSignIn.sharedInstance.handle(url)
    }
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

extension AppDelegate: UNUserNotificationCenterDelegate, MessagingDelegate {
    
    /// error발생시
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("🟢", error)
    }
    /// 스위즐링 NO시, APNs등록, 토큰값가져옴
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
        let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        print("🟢", #function, deviceTokenString)
    }
    public func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        let firebaseToken = fcmToken ?? ""
        print("firebase token: \(firebaseToken)")
        
        UserDefaults.standard.set(firebaseToken, forKey: "fcmToken")
//        if  (UserDefaults.standard.string(forKey: "accessToken") != nil){
//            let url = "https://api.reptimate.store/users"
//            var request = URLRequest(url: URL(string: url)!)
//            request.httpMethod = "PATCH"
//            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//            request.addValue("Bearer "+UserDefaults.standard.string(forKey: "accessToken")! , forHTTPHeaderField: "Authorization")
//
//            // POST 로 보낼 정보
//            let params = ["fbToken": firebaseToken] as Dictionary
//
//            // httpBody 에 parameters 추가
//            do {
//                try request.httpBody = JSONSerialization.data(withJSONObject: params, options: [])
//            } catch {
//                print("http Body Error")
//            }
//            AF.request(request)
//                .responseDecodable(of: messageResponse.self) { response in
//                    switch response.result {
//                    case .success:
//                        print(response)
//                        var statusCode = (response.response?.statusCode)!
//                        print(statusCode)
//                        if response.value?.status == 201 {
//                        } else if response.value?.status == 422 {
//
//                        } else {
//
//                        }
//                    break
//                case .failure(let error):
//                    print("Request Error\nCode:\(error._code), Message: \(error.errorDescription!)")
//    //                self.showToast(message: "서버와의 통신에 오류가 발생하였습니다.", wid: 180)
//                }
//            }
//        }
        

        
        
        
        
    }
    // 앱이 화면에 켜지고 있는 중에도 알림을 받고 싶을 경우 활성화
    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge, .sound])
    }
    //푸시 클릭시
    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("fcm 알림 수신.  :   \(response.notification.request.content)")
        if let title = response.notification.request.content.title as? String {
                // description을 사용하여 푸시 알림의 내용 설정
                let content = UNMutableNotificationContent()
                // type을 기반으로 화면 이동
                if title == "스케줄링" {
                    // 반복알림 - 스케줄링
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let window = windowScene.windows.first,
                       let rootViewController = window.rootViewController {
                    if let navigationController = rootViewController as? UINavigationController {
                            if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "scheduleTabmanViewController") as? scheduleTabmanViewController {
                                navigationController.pushViewController(viewController, animated: true)
                            }
                        }
                    }
                } else if title == "경매" {
                    // 경매 - 마감, 마감전, 입찰가 갱신
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let window = windowScene.windows.first,
                       let rootViewController = window.rootViewController {
                    if let navigationController = rootViewController as? UINavigationController {
                            if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "auctionHomeViewController") as? auctionHomeViewController {
                                viewController.delegateData = ""
                                navigationController.pushViewController(viewController, animated: true)
                            }
                        }
                    }
                } else {
                    // 채팅
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let window = windowScene.windows.first,
                       let rootViewController = window.rootViewController {
                    if let navigationController = rootViewController as? UINavigationController {
                            if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TabBarController") as? Main_TabBarController {
                                viewController.fromNoti = "chat"
                                navigationController.pushViewController(viewController, animated: true)
                            }
                        }
                    }
                    
                }
            }

        completionHandler()
    }
}
