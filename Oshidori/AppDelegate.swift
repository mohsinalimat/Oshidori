//
//  AppDelegate.swift
//  Oshidori
//
//  Created by 山本竜也 on 2019/3/29.
//  Copyright © 2019 山本竜也. All rights reserved.
//

import UIKit
import CoreData
import Firebase
import UserNotifications
import PKHUD

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let gcmMessageIDKey = "gcm.message_id"
    
    static var badgeCount = 0
        
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        changeTabBarUI()
        
        // Google Mobile Ads SDK を初期化。
        GADMobileAds.sharedInstance().start()
        
        // アプリを開いたらバッジを0にする
        UIApplication.shared.applicationIconBadgeNumber = AppDelegate.badgeCount
        // messaging を使う時に必要
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            Messaging.messaging().shouldEstablishDirectChannel = true
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(options: authOptions,completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        
        // FCM をもう一度有効にするには、ランタイム コールを実行します。
        Messaging.messaging().isAutoInitEnabled = true
        
        
        return true
    }
    
    // 全てのNavigation Barの色を変更する
    func changeTabBarUI() {
        // Navigation Bar の背景色の変更
        UINavigationBar.appearance().barTintColor = OshidoriColor.primary
        // Navigation Bar の背景色が薄いのを修正
        UINavigationBar.appearance().isTranslucent = false
        // Navigation Bar の文字色の変更
        UINavigationBar.appearance().tintColor = UIColor.white
        // Navigation Bar のタイトルの文字色の変更
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
    }
    
    private func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        Messaging.messaging().apnsToken = deviceToken as Data
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        
        // Print full message.
        debugPrint("🌞user")
        print(userInfo)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        HUD.hide()
        debugPrint("🌞user")
        guard let partnerId = userInfo["userId"] as? String else {
            return
        }
        if partnerId == "error" {
            // 一番上のViewControllerを探す処理
            if let topController = UIApplication.topViewController() {
                topController.alert("エラー", "ユーザが存在しませんでした。", nil)
            }
            return
        } else {
            if let topController = UIApplication.topViewController() as? SendEmailViewController {
                topController.settingPartner(partnerId: partnerId)
            }
        }
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // アプリを閉じそうになったらbadgeCountを反映させておく
        UIApplication.shared.applicationIconBadgeNumber = AppDelegate.badgeCount
    }

}

// MARK: - MessagingDelegate
extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        UserDefaults.standard.set(fcmToken, forKey: "FCMToken")
        UserDefaults.standard.synchronize()
        let userInfo = UserInfoService.shared
        userInfo.update()
    }
    
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        debugPrint("Received data message: \(remoteMessage.appData)")
    }
    
    // [START refresh_token]
    func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
        
        let userInfo = UserInfoService.shared
        userInfo.update()
        
    }
   
}

extension UIApplication {
    class func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
}

// MARK: - UNUserNotificationCenterDelegate
extension AppDelegate : UNUserNotificationCenterDelegate {
    
    // 通知を受け取った時に(開く前に)呼ばれるメソッド
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        
        // for analytics
        Messaging.messaging().appDidReceiveMessage(userInfo)
        DispatchQueue.main.async {
            // バッジの数をインクリメントする
            UIApplication.shared.applicationIconBadgeNumber += 1
        }
//        if let messageID = userInfo[gcmMessageIDKey] {
//        }
        completionHandler([.alert])
    }
    
    // 通知を開いた時に呼ばれるメソッド
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        
        // for analytics
        Messaging.messaging().appDidReceiveMessage(userInfo)
        
        completionHandler()
    }
}

