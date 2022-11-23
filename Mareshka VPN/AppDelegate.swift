//
//  AppDelegate.swift
//  Mareshka VPN (new)
//
//  Created by Alexey Voronov on 19.06.2022.
//

import UIKit
import Firebase
import FirebaseMessaging
import UserNotifications
import SwiftRater
import FirebaseAnalytics

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        setupUI()
        FirebaseApp.configure()
        
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        
        SwiftRater.daysUntilPrompt = 0
        SwiftRater.usesUntilPrompt = 0
        SwiftRater.significantUsesUntilPrompt = 0
        SwiftRater.daysBeforeReminding = 1
        SwiftRater.showLaterButton = true
        SwiftRater.debugMode = false
        SwiftRater.appLaunched()
        
        return true
    }
    
    func setupUI() {
        window?.overrideUserInterfaceStyle = .dark
        
        /* loader item */
        var config : SwiftLoader.Config = SwiftLoader.Config()
        config.size = 120
        config.spinnerColor = .white
        config.backgroundColor = UIColor(named: "LoaderColor")!
        config.spinnerLineWidth = 5
        //config.foregroundColor = .white
        //config.foregroundAlpha = 1.0
        SwiftLoader.setConfig(config)
        
        /* uitabbar item */
        let tabbarAppearance = UITabBar.appearance()
        UITabBarItem.appearance().titlePositionAdjustment = UIOffset(horizontal: 0.0, vertical: 1.0)
        tabbarAppearance.unselectedItemTintColor = UIColor.white.withAlphaComponent(0.5)
        tabbarAppearance.tintColor = UIColor.white
        tabbarAppearance.isTranslucent = true
        tabbarAppearance.backgroundColor = UIColor.clear
        tabbarAppearance.backgroundImage = UIImage()
        
        let tabbarItemAppearance = UITabBarItem.appearance()
        /* uitabbar item normal */
        var attrs = [
            NSAttributedString.Key.foregroundColor: UIColor.white.withAlphaComponent(0.5),
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 11, weight: .semibold)
        ] as [NSAttributedString.Key : Any]
        tabbarItemAppearance.setTitleTextAttributes(attrs, for: .normal)
        
        /* uitabbar item selected */
        attrs = [
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.font: UIFont(name: "SFProRounded-Bold", size: 11)!
        ]
        tabbarItemAppearance.setTitleTextAttributes(attrs, for: .selected)
        
        /* navigation bar */
        let navAppearance = UINavigationBar.appearance()
        navAppearance.tintColor = UIColor.white
        navAppearance.barTintColor = UIColor.white
        navAppearance.shadowImage = UIImage()
        navAppearance.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "SFProRounded-Bold", size: 19)!,
                                             NSAttributedString.Key.foregroundColor: UIColor.white]
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    )
    {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        Messaging.messaging().isAutoInitEnabled = true
        Messaging.messaging().setAPNSToken(deviceToken, type: .prod)
        Messaging.messaging().token { token, error in
            if let error = error {
                print("Error fetching FCM registration token: \(error)")
            } else if let token = token {
                print("FCM registration token: \(token)")
                MatreshkaHelper.shared.sendToken(token: token)
            }
        }
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        FirebaseAnalytics.Analytics.logEvent("app_close", parameters: nil)
    }
}


extension AppDelegate: UNUserNotificationCenterDelegate {
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification) async
    -> UNNotificationPresentationOptions {
        let userInfo = notification.request.content.userInfo
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        
        // ...
        
        // Print full message.
        print(userInfo)
        
        // Change this to your preferred presentation option
        return [[.alert, .sound]]
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse) async {
        let userInfo = response.notification.request.content.userInfo
        
        // ...
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        
        // Print full message.
        print(userInfo)
    }
}

func application(_ application: UIApplication,
                 didReceiveRemoteNotification userInfo: [AnyHashable: Any]) async
-> UIBackgroundFetchResult {
    // If you are receiving a notification message while your app is in the background,
    // this callback will not be fired till the user taps on the notification launching the application.
    // TODO: Handle data of notification
    
    // With swizzling disabled you must let Messaging know about the message, for Analytics
    // Messaging.messaging().appDidReceiveMessage(userInfo)
    
    // Print message ID.
    
    // Print full message.
    print(userInfo)
    
    return UIBackgroundFetchResult.newData
}


extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase registration token: \(String(describing: fcmToken))")
        
        let dataDict: [String: String] = ["token": fcmToken ?? ""]
        NotificationCenter.default.post(
            name: Notification.Name("FCMToken"),
            object: nil,
            userInfo: dataDict
        )
        // TODO: If necessary send token to application server.
        if let fcmToken = fcmToken {
            MatreshkaHelper.shared.sendToken(token: fcmToken)
        }
    }
}

