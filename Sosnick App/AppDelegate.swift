//
//  AppDelegate.swift
//  Sosnick App
//
//  Created by Daniel Ydens on 6/18/19.
//  Copyright © 2019 Daniel Ydens. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore
import UserNotifications
import FirebaseInstanceID
import FirebaseMessaging
import OAuth2



@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?
    
 let oauth2 = OAuth2CodeGrantNoTokenType(settings: [
    "client_id": "603532347144383",
    "client_secret": "209394f22ff416eff13446598a0df753",
    "app_id": "603532347144383",
    "app_secret": "209394f22ff416eff13446598a0df753",
    "scope" : "user_profile,user_media",
    "authorize_uri": "https://api.instagram.com/oauth/authorize",
    "token_uri": "https://api.instagram.com/oauth/access_token",
    "response_type": "code",
    "redirect_uris": ["https://acrobat.adobe.com/us/en"],
    "keychain": false,
    "title": "InstagramViewer",
    "secret_in_body" : true
    ] as OAuth2JSON)
    
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
           // you should probably first check if this is the callback being opened
           if (true) {
               // if your oauth2 instance lives somewhere else, adapt accordingly
               oauth2.handleRedirectURL(url)
           }
        return true
       }
    
    struct MyVariables {
        static var fcmToken = ""
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        //window!.overrideUserInterfaceStyle = .light
        FirebaseApp.configure() //configure firebase
        Messaging.messaging().delegate = self as? MessagingDelegate
        FirebaseApp.configure(name: "CreatingUsersApp", options: FirebaseApp.app()!.options)
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
    
        let initialViewController: ViewController = mainStoryboard.instantiateViewController(withIdentifier: "Login") as! ViewController //setting up login screen as initial VC
        let navigationController = UINavigationController(rootViewController: initialViewController)
        self.window?.rootViewController = navigationController
        
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization( //setting up notifications
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()


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
    
    
    
    
    // start of additional code for push notifications
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        
        
        print("Firebase registration token: \(fcmToken)") //token for push notifications
        
        let dataDict:[String: String] = ["token": fcmToken]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever a new token is generated.
    }
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        InstanceID.instanceID().instanceID { (result, error) in
            if let error = error {
                print("Error fetching remote instance ID: \(error)")
            } else if let result = result {
                print("Remote instance ID token: \(result.token)")
                MyVariables.fcmToken = result.token
                
                
                
            }
        }
    }
    
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        print("Received data message: \(remoteMessage.appData)")
    }
    


}

