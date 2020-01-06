//
//  AppDelegate.swift
//  modoohotdeal
//
//  Created by baedy on 2019/12/20.
//  Copyright © 2019 baedy. All rights reserved.
//

import UIKit
import Firebase
import UserNotifications
import GoogleMobileAds

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        
        UNUserNotificationCenter.current().delegate = self
        
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: {_, _ in })
        
        application.registerForRemoteNotifications()
        
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        Messaging.messaging().delegate = self
        Messaging.messaging().isAutoInitEnabled = true
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}


extension AppDelegate : MessagingDelegate {
    // [START refresh_token]
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("didReceiveRegistrationToken : fcmToken = \(fcmToken)")
        _ = NetworkService.User.postUser(token: fcmToken).on(next: {
            UserService.shared().setUser(userData: $0)
        })
//        Preference.fcm.set(fcmToken, forKey: .fcmToken)
    }
    // [END refresh_token]
    
    // [START ios_10_data_message]
    // Receive data messages on iOS 10+ directly from FCM (bypassing APNs) when the app is in the foreground.
    // To enable direct data messages, you can set Messaging.messaging().shouldEstablishDirectChannel to true.
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        print("Received data message: \(remoteMessage.appData)")
    }
    // [END ios_10_data_message]
    
    func application(application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        Messaging.messaging().apnsToken = deviceToken as Data
    }
}

// MAKR: - UserNotificationKit Notification
@available(iOS 10.0, *)
extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
//        Log.trace()
        
        var sound: String?
        
        let userInfo = notification.request.content.userInfo
//        guard let data = NotificationService.default.parse(userInfo) else {
//            completionHandler([.alert, .badge, .sound])
//            return
//        }
        print("willPresent : \(userInfo)")
        
        if let aps = userInfo["aps"] as? [AnyHashable: Any] {
            sound = aps["sound"] as? String
        }
        //        if let action = NotificationService.default.unconditionalAction(of: data) {
        //            action.perform(data, input: nil) {
        //                completionHandler(action.needsNotificationPresent ? [.alert, .badge, .sound] : [])
        //            }
        //        } else if NotificationService.default.canNotify(data) {
        //            completionHandler([])
        //        } else {
        //            completionHandler([.alert, .badge, .sound])
        //        }
        //
//        if NotificationService.default.canNotify(data) {
//            completionHandler([])
//        } else if let action = NotificationService.default.unconditionalAction(of: data) {
//            action.perform(data, input: sound) {
//                completionHandler(action.needsNotificationPresent ? [.alert, .badge, .sound] : [])
//            }
//        } else {
//
//        }
//
        completionHandler([.alert, .badge, .sound])
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print(userInfo)
        completionHandler(.newData)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let userInfo = response.notification.request.content.userInfo
        
        print("didReceive : \(userInfo)")
        
        guard let link = userInfo["link"] as? String, let url = URL(string: link) else { return }
        guard let code = userInfo["code"] as? String else { return }
        guard let title = userInfo["title"] as? String , let body = userInfo["body"] as? String else {
            return
        }
        
        if code == "link_landing"{
            AlertService.shared().alertInit(title: title, message: body, preferredStyle: .alert)
                .addAction(title: "닫기", style: .cancel)
                .addAction(title: "보러 가기", style: .default) {alert in
                    let vc = UIStoryboard(name: "ArticleWeb", bundle: .main).instantiateViewController(withIdentifier: "ArticleWebViewController") as! ArticleWebViewController
                    vc.setURL(url: url)
                    UIApplication.shared.topViewController?.navigationController?.pushViewController(vc, animated: true)
                }.showAlert()
        }
        
        completionHandler()
//        guard let data = NotificationService.default.parse(userInfo) else {
//            completionHandler()
//            return
//        }
//        if let action = NotificationService.default.conditionalAction(of: response.actionIdentifier, data: data) {
//            action.perform(data, input: (response as? UNTextInputNotificationResponse)?.userText, completion: completionHandler)
//            if action.needsNotificationPresent {
//                NotificationService.default.notify(data)
//            }
//        } else {
//            NotificationService.default.notify(data)
//            completionHandler()
//        }
    }
    
}
