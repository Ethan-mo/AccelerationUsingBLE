//
//  AppDelegate.swift
//  Monit
//
//  Created by 맥 on 2017. 8. 14..
//  Copyright © 2017년 맥. All rights reserved.
//

import UIKit
import Foundation
import CoreData
import UserNotifications
import Firebase
import FirebaseCrashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let gcmMessageIDKey = "gcm.message_id"

    var m_enterActive = Flow()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        Debug.print("[🔵][Center] application didFinishLaunchingWithOptions", event: .warning)

        if let options = launchOptions {
            if let localNotification: UILocalNotification = options[UIApplicationLaunchOptionsKey.localNotification] as? UILocalNotification {
                Debug.print("[🔵][Center] didFinishLaunchingWithOptions \(localNotification.alertBody!)", event: .warning)
            }
            if let remoteNotification: NSDictionary = options[UIApplicationLaunchOptionsKey.remoteNotification] as? NSDictionary {
                Debug.print("[🔵][Center] Awake from remote notification \(remoteNotification)", event: .warning)
            }
        }
        
        // badge count 0
        UIApplication.shared.applicationIconBadgeNumber = 0
    
        // fire base
//        switch Config.channel {
//        case .goodmonit:
//            let filePath = Bundle.main.path(forResource: "GoogleService-Info-goodmonit", ofType: "plist")!
//            let options = FirebaseOptions(contentsOfFile: filePath)
//            FirebaseApp.configure(options: options!)
//        case .monitXHuggies:
//            let filePath = Bundle.main.path(forResource: "GoogleService-Info-monitxhuggies", ofType: "plist")!
//            let options = FirebaseOptions(contentsOfFile: filePath)
//            FirebaseApp.configure(options: options!)
//        case .kc:
//            let filePath = Bundle.main.path(forResource: "GoogleService-Info-kc", ofType: "plist")!
//            let options = FirebaseOptions(contentsOfFile: filePath)
//            FirebaseApp.configure(options: options!)
//        }
         FirebaseApp.configure()
        
        // theme light
        if #available(iOS 13.0, *) { self.window?.overrideUserInterfaceStyle = .light }
        
        #if FCM
        // [START set_messaging_delegate]
        Messaging.messaging().delegate = self
        // [END set_messaging_delegate]
        // Register for remote notifications. This shows a permission dialog on first run, to
        // show the dialog at a more appropriate time move this registration accordingly.
        // [START register_for_notifications]
        if #available(iOS 10.0, *) {
          // For iOS 10 display notification (sent via APNS)
          UNUserNotificationCenter.current().delegate = self

          let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
          UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: {_, _ in })
        } else {
          let settings: UIUserNotificationSettings =
          UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
          application.registerUserNotificationSettings(settings)
        }

        application.registerForRemoteNotifications()
        // [END register_for_notifications]
        #endif
        
//        // tag manager
//        let GTM = TAGManager.instance()
//        GTM.logger.setLogLevel(kTAGLoggerLogLevelVerbose)
//        TAGContainerOpener.openContainerWithId("GTM-PNJ224Q",  // change the container ID "GTM-PT3L9Z" to yours
//            tagManager: GTM, openType: kTAGOpenTypePreferFresh,
//            timeout: nil,
//            notifier: self)
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        Debug.print("[🔵][Center] applicationWillResignActive", event: .warning)
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        Debug.print("[🔵][Center] applicationDidEnterBackground", event: .warning)
//        ScreenAnalyticsManager.instance.goBackgroundSession()
        
        if (Config.channel == .kc) {
            avoidScreenshot()
            SystemManager.instance.clearCache()
        }
    }
    
    func avoidScreenshot() {
        let imageView = UIImageView(frame: self.window!.bounds)
        imageView.tag = 101
        imageView.backgroundColor = UIColor.white
        imageView.contentMode = .center
        imageView.image = UIImage(named: "imgLogo3")
        UIApplication.shared.keyWindow?.subviews.last?.addSubview(imageView)
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        Debug.print("[🔵][Center] applicationWillEnterForeground", event: .warning)
        // 이때 네트워크 전송하면, 아직 네트워크 전송준비가 되지 않아서 오류 발생할 수 있음
        
        if (Config.channel == .kc) {
            // remove avoid screenshot
            if let imageView : UIImageView = UIApplication.shared.keyWindow?.subviews.last?.viewWithTag(101) as? UIImageView {
                imageView.removeFromSuperview()
            }
        }
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        Debug.print("[🔵][Center] applicationDidBecomeActive", event: .warning)
        
        // reset전에 전송하면 앱 처음시작시 appdata(암호화키)가 준비 되지 않아 오류 발생함.
        m_enterActive.reset {
//            ScreenAnalyticsManager.instance.goForegroundSession()
            SystemManager.instance.accountActiveUserLog()
            SystemManager.instance.checkMaintenance(handler: { () in
                SystemManager.instance.refrashData(handler: { () -> () in })
                //            _ = UIManager.instance.isBluetoothPopup()
                UIApplication.shared.applicationIconBadgeNumber = 0
            })
        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        Debug.print("[🔵][Center] applicationWillTerminate", event: .warning)
        
//        if (DataManager.instance.m_userInfo.connectSensor.successConnectSensor.count > 0) {
            DataManager.instance.m_configData.isTerminateApp = true
//        }
        DataManager.instance.m_coreDataInfo.saveData()
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
//        if (url.host == "oauth-callback") {
//            OAuthSwift.handle(url: url)
//        }
        
        let _url = url.description.replacingOccurrences(of: "#", with: "&")
        Debug.print("[🔵][Center] _url: \(_url)", event: .warning)
        
        Debug.print("[🔵][Center] url: \(String(describing: url))", event: .warning)
        Debug.print("[🔵][Center] Scheme: \(String(describing: url.scheme))", event: .warning)
        Debug.print("[🔵][Center] Host:\(String(describing: url.host))", event: .warning)
//        let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true)
        
        guard (URL(string: _url) != nil) else { return true }
        let urlComponents = URLComponents(url: URL(string: _url)!, resolvingAgainstBaseURL: true)
        let items = (urlComponents?.queryItems) as [NSURLQueryItem]?
        
        guard (items != nil) else { return true }
        
        let _info = SchemeInfo()
        for item in items! {
            if (.from == SCHEME_KEY(rawValue: item.name)) {
                if let _value = item.value {
                    _info.m_from = SCHEME_FROM_TYPE(rawValue: _value)
                }
            }
            if (.sitecode == SCHEME_KEY(rawValue: item.name)) {
                if let _value = item.value {
                    _info.m_sitecode = _value
                }
            }
            if (.value == SCHEME_KEY(rawValue: item.name)) {
                if let _value = item.value {
                    _info.m_value = _value
                }
            }
            if (.id_token == SCHEME_KEY(rawValue: item.name)) {
                if let _value = item.value {
                    _info.m_id_token = _value
                }
            }
            if (.access_token == SCHEME_KEY(rawValue: item.name)) {
                if let _value = item.value {
                    _info.m_access_token = _value
                }
            }
            Debug.print(item.name, event: .warning)
            Debug.print(item.value ?? "", event: .warning)
        }
        if let _key = _info.m_from {
            switch _key {
            case .yk:
                schemeYK(info: _info)
                break
            case .playground:
                schemePlayground(info: _info)
                break
            case .widget:
                widget(info: _info)
                break
            }
        }
//        schemeYK(info: _info)
        
//        /1. 앱실행 Scheme
//        [안드로이드용]
//            - 패키지: monitxhuggies.monit.com.monit
//        - 스키마: monitxhuggies
//        - 호스트: external
//        - 파라미터: from=yk&sitecode=회원가입사이트코드
//        - 예제: <a href="monitxhuggies://external?from=yk&sitecode=MOMQ">모닛앱실행</a>
//
//        [iOS용]
//        - 스키마: monitxhuggies
//        - 파라미터: from=yk&sitecode=회원가입사이트코드
//        - 예제: <a href="monitxhuggies://?from=yk&sitecode=MOMQ">모닛앱실행</a>
        return true
    }

    func schemeYK(info: SchemeInfo) {
        if (info.m_id_token != "" && info.m_access_token != "") {
            DataManager.instance.m_userInfo.configData.OAuthToken = info.m_id_token
            oAuth2Signin(info: info)
        } else {
            _ = UIManager.instance.sceneMove(scene: .initView, animation: .coverVertical, isAnimation: false)
        }
    }
    
    func schemePlayground(info: SchemeInfo) {
        let _send = Send_ChannelEvent()
        _send.isIndicator = false
        _send.isErrorPopupOn = false
        _send.aid = DataManager.instance.m_userInfo.account_id
        _send.chtype = ETC_CHANNEL_TYPE.playground.rawValue
        _send.evttype = ETC_CHANNEL_EVENT_TYPE.default_link.rawValue
        NetworkManager.instance.Request(_send) { (json) -> () in
            let receive = Receive_ChannelEvent(json)
            switch receive.ecd {
            case .success: break
            default: Debug.print("[⚪️][Init][ERROR] invaild errcod", event: .error)
            }
        }
    }
    
    func oAuth2Signin(info: SchemeInfo) {
        let send = Send_YKSigninOAuth2()
        send.url = Config.WEB_URL_YK_SIGNIN
        send.id_token = info.m_id_token
        send.access_token = info.m_access_token
        if (Config.IS_DEBUG) {
            send.ver = 2 // qa주소 12
        } else {
            send.ver = 2
        }
//        send.ver = 1
        
        NetworkManager.instance.Request(send) { (json) -> () in
            let receive = Receive_YKSigninOAuth2(json)
            switch receive.ecd {
            case .success:
                let _step = receive.step!
                switch _step {
                case 1, 2, 3: self.policyAgreeCheck(aid: receive.aid ?? 0, token: receive.token ?? "", email: receive.email ?? "")
                default: Debug.print("[ERROR] invaild errcod", event: .error)
                }
            case .signin_invaildEmail:
                NativePopupManager.instance.onlyContents(message: "toast_invalid_user_info".localized) { () -> () in }
            case .signin_invaildPw:
                NativePopupManager.instance.onlyContents(message: "toast_invalid_user_info".localized) { () -> () in }
            default: Debug.print("[ERROR] invaild errcod", event: .error)
            }
        }
    }
    
    func policyAgreeCheck(aid: Int, token: String, email: String)
    {
        let send = Send_GetPolicy()
        send.aid = aid
        send.token = token
        NetworkManager.instance.Request(send) { (json) -> () in
            let receive = Receive_GetPolicy(json)
            switch receive.ecd {
            case .success:
                var _isEssential = false
                for item in receive.data {
                    if (item.ptype ?? -1 == POLICY_AGREE_TYPE.huggies_service.rawValue) {
                        if (item.agree ?? -1 == 1) {
                            _isEssential = true
                            break
                        }
                    }
                }
                
                if (_isEssential) {
                    DataManager.instance.m_userInfo.account_id = aid
                    DataManager.instance.m_userInfo.token = token
                    DataManager.instance.m_userInfo.email = email
                    _ = UIManager.instance.sceneMove(scene: .initView, animation: .coverVertical, isAnimation: false)
                } else {
                    let _scene = UIManager.instance.sceneMove(scene: .policyMonitXHuggies, animation: .coverVertical, isAnimation: false) as! SigninPolicyMonitXHuggiesViewController
                    _scene.setInit(account_id: aid, token: token, email: email, isEssential: false)
                }
            default: Debug.print("[ERROR] invaild errcod", event: .error)
            }
        }
    }
    
    func widget(info: SchemeInfo) {
        Debug.print("Open Widget :\(info.m_value)")
        _ = UIManager.instance.sceneMoveNaviPush(scene: .deviceSetupWidget, isAniamtion: false) as! DeviceSetupWidget
    }
    
//    // tag manager
//    func containerAvailable(container: TAGContainer!) {
//      container.refresh()
//    }
    
    #if FCM
    // [START receive_message]
//    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
//      // If you are receiving a notification message while your app is in the background,
//      // this callback will not be fired till the user taps on the notification launching the application.
//      // TODO: Handle data of notification
//      // With swizzling disabled you must let Messaging know about the message, for Analytics
//      // Messaging.messaging().appDidReceiveMessage(userInfo)
//      // Print message ID.
//      if let messageID = userInfo[gcmMessageIDKey] {
//        print("Message ID: \(messageID)")
//      }
//
//      // Print full message.
//      print(userInfo)
//    }

    // 자꾸 들어옴.. pushy인데 이리로 들어옴
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
      // If you are receiving a notification message while your app is in the background,
      // this callback will not be fired till the user taps on the notification launching the application.
      // TODO: Handle data of notification
      // With swizzling disabled you must let Messaging know about the message, for Analytics
      // Messaging.messaging().appDidReceiveMessage(userInfo)
      // Print message ID.
//      if let messageID = userInfo[gcmMessageIDKey] {
//        print("Message ID: \(messageID)")
//      }
//
//      // Print full message.
//      print(userInfo)

        NotificationManager.instance.setNotification(data: userInfo)
        completionHandler(UIBackgroundFetchResult.newData)
    }
    // [END receive_message]

    // ios 9.0, 13.1 simulator 에서 호출 되는 것 확인, 에러가 있을경우 실행
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        Debug.print("[FCM][ERROR] Unable to register for remote notifications: \(error.localizedDescription)", event: .error)
    }

    // FCM 토큰 값을 못 가져왔을 경우 디바이스의 토큰 값으로 설정할 수 있습니다.
    // This function is added here only for debugging purposes, and can be removed if swizzling is enabled.
    // If swizzling is disabled then this function must be implemented so that the APNs token can be paired to
    // the FCM registration token.
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Debug.print("[FCM] APNs token retrieved: \(deviceToken)", event: .normal)

      // With swizzling disabled you must set the APNs token here.
      // Messaging.messaging().apnsToken = deviceToken
    }
    #endif
}

#if FCM
// [START ios_10_message_handling]
@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {

//  // Receive displayed notifications for iOS 10 devices.
//  func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
//    let userInfo = notification.request.content.userInfo
//
//    // With swizzling disabled you must let Messaging know about the message, for Analytics
//    // Messaging.messaging().appDidReceiveMessage(userInfo)
//    // Print message ID.
////    if let messageID = userInfo[gcmMessageIDKey] {
////      print("Message ID: \(messageID)") // push test 중단점 Message ID: 1575963414452526
////    }
//
//    // Print full message.
////    print(userInfo)
//    // Change this to your preferred presentation option
//    NotificationManager.instance.setNotification(data: userInfo)
//    completionHandler([])
//  }
//
//  func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
//    let userInfo = response.notification.request.content.userInfo
//    // Print message ID.
//    if let messageID = userInfo[gcmMessageIDKey] {
//        Debug.print("[FCM] Message ID: \(messageID)", event: .normal)
//    }
//
//    // Print full message.
//    Debug.print("[FCM] \(userInfo)", event: .normal)
//
//    completionHandler()
//  }
}
// [END ios_10_message_handling]

extension AppDelegate : MessagingDelegate {
  // [START refresh_token]
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
    Debug.print("[FCM] Firebase registration token: \(fcmToken)", event: .dev) // firebase registration token: eN1vH_DiLv0:APA91..
        NotificationManager.instance.fcmToken = fcmToken ?? ""

    let dataDict:[String: String] = ["token": fcmToken!]
    NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
    // TODO: If necessary send token to application server.
    // Note: This callback is fired at each app startup and whenever a new token is generated.
  }
  // [END refresh_token]

  // [START ios_10_data_message]
  // Receive data messages on iOS 10+ directly from FCM (bypassing APNs) when the app is in the foreground.
  // To enable direct data messages, you can set Messaging.messaging().shouldEstablishDirectChannel to true.
//  func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
//    Debug.print("[FCM] Received data message: \(remoteMessage.appData)", event: .normal)
//  }
  // [END ios_10_data_message]
}
#endif
