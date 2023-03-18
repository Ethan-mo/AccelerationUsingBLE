//
//  NotificationManager.swift
//  Monit
//
//  Created by 맥 on 2017. 10. 18..
//  Copyright © 2017년 맥. All rights reserved.
//

import Foundation
import UIKit
import UserNotifications
import Pushy
import SwiftyJSON
import AudioToolbox

class NotificationManager: NSObject {
    static var m_instance: NotificationManager!
    static var instance: NotificationManager {
        get {
            if (m_instance == nil) {
                m_instance = NotificationManager()
            }
            
            return m_instance
        }
    }

    var isAuthorized = false
    var pushyToken: String {
        get { return Utility.getLocalString(name: "pushyToken") }
        set { UserDefaults.standard.set(newValue, forKey: "pushyToken") }
    }
    
    var fcmToken: String {
        get { return Utility.getLocalString(name: "fcmToken") }
        set { UserDefaults.standard.set(newValue, forKey: "fcmToken") }
    }

    func setPushy() {
        // Initialize Pushy SDK
        let pushy = Pushy(UIApplication.shared)
        
        // Register the device for push notifications
        pushy.register({ (error, deviceToken) in
            // Handle registration errors
            if error != nil {
                return Debug.print("[PUSHY][NotiManager][ERROR] Registration failed: \(error!)", event: .error)
            }
            
            // Print device token to console
            Debug.print("[PUSHY][NotiManager] Pushy device token: \(deviceToken)", event: .warning)
            self.pushyToken = deviceToken
            self.isAuthorized = true
            DispatchQueue.main.async {
                self.setUpdatePush(token: NotificationManager.instance.pushyToken, pushType: PUSH_TYPE.pushy)
            }
        })
        
        pushy.setNotificationHandler({ (data, completionHandler) in
            self.setNotification(data: data)
            completionHandler(UIBackgroundFetchResult.newData)
        })
    }
    
    func setFcm() {
        self.setUpdatePush(token: fcmToken, pushType: PUSH_TYPE.fcm)
    }
    
    func setNotification(data: [AnyHashable : Any]) {
        // Print notification payload data
        Debug.print("[NotiManager] Received notification: \(data)", event: .warning)
        
        var _isActive = false
        switch UIApplication.shared.applicationState {
        case .inactive:
            _isActive = true
            Debug.print("[NotiManager] inactive!!!!!!!!!!!!!", event: .warning)
        case .active:
            _isActive = true
            Debug.print("[NotiManager] active!!!!!!!", event: .warning)
        case .background:
            Debug.print("[NotiManager] background!!!!!!!!!", event: .warning)
        }

        // custom popup
        if (_isActive) {
            if let _message = data["message"] as? String {
                if let _json = Utility.convertToDictionary(text: _message) {
                    if let _noti = _json["noti"] as? Int {
                        if let _type = NotificationType(rawValue: _noti) {
                            if (_type == .CUSTOM_MESSAGE) {
                                if let aps = data["aps"] as? [AnyHashable : Any] {
                                    if let _alert = aps["alert"] as? [AnyHashable : Any] {
                                        let _info = PopupDetailInfo()
                                        _info.title = _alert["title"] as? String ?? ""
                                        _info.contents = _alert["body"] as? String ?? ""
                                        _info.buttonType = PopupView.CUSTOM_BUTTON_TYPE.center
                                        _info.center = "btn_ok".localized
                                        _info.centerColor = COLOR_TYPE.mint.color
                                        _ = PopupManager.instance.setDetail(popupDetailInfo: _info, okHandler: { () -> () in
                                        })
                                        return
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
        // Attempt to extract "message" key from APNs payload
        var _isSilent = false
        if let aps = data["aps"] as? [AnyHashable : Any] {
            // popup
            if let payloadMessage = aps["alert"] as? [AnyHashable : Any] {
                if (!_isActive) {
                    return
                }
                
                if let _locKey = payloadMessage["loc-key"] as? String {
                    let _locArgus = payloadMessage["loc-args"] as? [String]
                    self.localPopup(key: _locKey, value: _locArgus)
                    return
                }
            // silent update
            } else {
                _isSilent = true
            }
        } else {
            return
        }
        
        // silent push
        if (_isSilent) {
            if let _message = data["message"] as? String {
                if let _json = Utility.convertToDictionary(text: _message) {
                    if let _noti = _json["noti"] as? Int {
                        if let _type = NotificationType(rawValue: _noti) {
                            self.silentUpdate(type: _type)
                            return
                        }
                    }
                }
            }
        }
    }
    
    func setUpdatePush(token: String, pushType: PUSH_TYPE) {
        let send = Send_UpdatePush()
        send.aid = DataManager.instance.m_userInfo.account_id
        send.token = DataManager.instance.m_userInfo.token
        send.push = token
        send.ptype = pushType.rawValue
        send.isIndicator = false
        NetworkManager.instance.Request(send) { (json) -> () in
            self.getReceiveUpdatePush(json)
        }
    }
    
    func getReceiveUpdatePush(_ json: JSON) {
        let receive = Receive_UpdatePush(json)
        switch receive.ecd {
        case .success: break
        default: break
        }
    }
    
    func localPopup(key: String, value: [String]?) {
        DataManager.instance.m_dataController.deviceNoti.updateForDetailView()
        DataManager.instance.m_dataController.shareMemberNoti.updateForDetailView()
        DataManager.instance.m_dataController.deviceStatus.updateFullStatus(handler: { (isSuccess) in
            if (isSuccess) {
                UIManager.instance.currentUIReload()
            }
        })
        
        var _body = ""
        if (value == nil) {
            _body = key.localized
        } else {
            if (value?.count == 1) {
                _body = String(format: key.localized, value![0])
            } else if (value?.count == 2) {
                _body = String(format: key.localized, value![0], value![1])
            } else if (value?.count == 3) {
                _body = String(format: key.localized, value![0], value![1], value![2])
            }
        }
        
        if (UIManager.instance.isNotificationAuth) {
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
            NotificationManager.instance.playSound()

            let _info = PopupDetailInfo()
            _info.contents = _body
            _info.buttonType = PopupView.CUSTOM_BUTTON_TYPE.center
            _info.center = "btn_ok".localized
            _info.centerColor = COLOR_TYPE.mint.color
            _ = PopupManager.instance.setDetail(popupDetailInfo: _info, okHandler: { () -> () in
            })
        }
    }
    
    func silentUpdate(type: NotificationType) {
        switch type {
        case .UPDATE_FULL_DATA:
            DataManager.instance.m_dataController.deviceStatus.updateFullStatus(handler: { (isSuccess) in
                if (isSuccess) {
                    UIManager.instance.currentUIReload()
                } else {
//                    UIManager.instance.deviceRefrash()
                }
            })
        case .UPDATE_CLOUD_DATA:
            UIManager.instance.deviceRefrash()
        case .UPDATE_NOTI_DATA:
            DataManager.instance.m_dataController.deviceNoti.updateForDetailView()
        case .OAUTH_LOGIN_SUCCSS:
            UIManager.instance.oAuthLoginSuccess()
        case .CLOUD_INIT_DEVICE:
            UIManager.instance.deviceRefrash()
        default: break
        }
    }
    
    func isAlarmForLocal(type: Int, did: Int, dps: Int?) -> Bool { // 로컬전용이며, 다른 유저가 알람을 받을시 끈 센서는 아예 서버에서 쏘지 않는다.
        if (UIManager.instance.isNotificationAuth) {
            if let _almType = ALRAM_TYPE(rawValue: dps ?? 0) {
                if (DataManager.instance.m_userInfo.shareDevice.isAlarmStatus(did: did, type: type, almType: _almType) ?? true ) {
                    return true
                }
            }
        }
        return false
    }
    
    func sensorLocalNoti(did: Int, dps: Int?) {
        DataManager.instance.m_dataController.deviceNoti.updateForDetailView()
        DataManager.instance.m_dataController.shareMemberNoti.updateForDetailView()
        
        if (did != -1) {
            if (!isAlarmForLocal(type: DEVICE_TYPE.Sensor.rawValue, did: did, dps: dps)) {
                return
            }
        }

        var _name = ""
        if let _statusInfo = DataManager.instance.m_userInfo.deviceStatus.m_sensorStatus.getInfoByDeviceId(did: did) {
            _name = _statusInfo.m_name
        }
        
        var _body = ""
        if let _dps = dps {
            switch SENSOR_DIAPER_STATUS(rawValue: _dps) ?? .normal {
            case .pee:
                if (DataManager.instance.m_userInfo.configData.isHuggiesV1Alarm)
                {
                    _body = String(format: "NOTIFICATION_DIAPER_SOILED_PEE".localized, _name)
                } else {
                    _body = String(format: "NOTIFICATION_DIAPER_SOILED".localized, _name)
                }
            case .poo:
                if (DataManager.instance.m_userInfo.configData.isHuggiesV1Alarm)
                {
                    _body = String(format: "NOTIFICATION_DIAPER_SOILED_POO".localized, _name)
                } else {
                    _body = String(format: "NOTIFICATION_DIAPER_SOILED".localized, _name)
                }
            case .fart: _body = String(format: "FART_DETECTED".localized, _name)
            case .hold, .maxvoc: _body = String(format: "ABNORMAL_DETECTED".localized, _name)
            case .detectDiaperChanged: _body = String(format: "DIAPER_CHANGED".localized, _name)
            default: break
            }
            
            if let _noti = DEVICE_NOTI_TYPE(rawValue: _dps) {
                switch _noti {
                case .connected: _body = String(format: "CONNECTED".localized, _name)
                case .disconnected: _body = String(format: "DISCONNECTED".localized, _name)
                case .sensor_long_disconnected: _body = String(format: "SENSOR_LONG_DISCONNECTED".localized, _name)
                default: break
                }
            }
        }
        
        if (UIApplication.shared.applicationState == .active || UIApplication.shared.applicationState == .inactive) {
            NotificationManager.instance.playSound()
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
            
            let _info = PopupDetailInfo()
            _info.contents = _body
            _info.buttonType = PopupView.CUSTOM_BUTTON_TYPE.center
            _info.center = "btn_ok".localized
            _info.centerColor = COLOR_TYPE.mint.color
            _ = PopupManager.instance.setDetail(popupDetailInfo: _info, okHandler: { () -> () in
            })
        } else {
            localNoti(body: _body)
        }
    }
    
    func lampLocalNoti(did: Int, dps: Int?) {
        DataManager.instance.m_dataController.deviceNoti.updateForDetailView()
        DataManager.instance.m_dataController.shareMemberNoti.updateForDetailView()
        
        if (did != -1) {
            if (!isAlarmForLocal(type: DEVICE_TYPE.Lamp.rawValue, did: did, dps: dps)) {
                return
            }
        }

        var _name = ""
        if let _statusInfo = DataManager.instance.m_userInfo.deviceStatus.m_lampStatus.getInfoByDeviceId(did: did) {
            _name = _statusInfo.m_name
        }
        
        var _body = ""
        if let _dps = dps {
            if let _noti = DEVICE_NOTI_TYPE(rawValue: _dps) {
                switch _noti {
                case .connected: _body = String(format: "CONNECTED".localized, _name)
                case .disconnected: _body = String(format: "DISCONNECTED".localized, _name)
                default: break
                }
            }
        }
        
        if (UIApplication.shared.applicationState == .active || UIApplication.shared.applicationState == .inactive) {
            NotificationManager.instance.playSound()
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
            
            let _info = PopupDetailInfo()
            _info.contents = _body
            _info.buttonType = PopupView.CUSTOM_BUTTON_TYPE.center
            _info.center = "btn_ok".localized
            _info.centerColor = COLOR_TYPE.mint.color
            _ = PopupManager.instance.setDetail(popupDetailInfo: _info, okHandler: { () -> () in
            })
        } else {
            localNoti(body: _body)
        }
    }
    
    func localNoti(body: String) {
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            
            //iOS 10 or above version
            let center = UNUserNotificationCenter.current()
            let content = UNMutableNotificationContent()
//            content.title = "Late wake up call"
            content.body = body
            content.categoryIdentifier = "alarm"
//            content.userInfo = ["customData": "fizzbuzz"]

            if (DataManager.instance.m_userInfo.sex == SEX.man.rawValue) {
                content.sound = UNNotificationSound(named: String(format: "%@.wav", COMMON_SOUND_TYPE.noti_daddy.rawValue))
            } else {
                content.sound = UNNotificationSound(named: String(format: "%@.wav", COMMON_SOUND_TYPE.noti_mommy.rawValue))
            }
//            content.sound = UNNotificationSound.default()
   
            let comp = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: Date())
            let trigger = UNCalendarNotificationTrigger(dateMatching: comp, repeats: true)
            
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            center.add(request)
        } else {
            // ios 9
            let notification = UILocalNotification()
            notification.fireDate = NSDate(timeIntervalSinceNow: 0) as Date
            notification.alertBody = body
//            notification.alertAction = "be awesome!"
            notification.soundName = "notification"
//            notification.soundName = UILocalNotificationDefaultSoundName
            UIApplication.shared.scheduleLocalNotification(notification)
        }
    }
    
    func playSound() {
        if (DataManager.instance.m_userInfo.sex == SEX.man.rawValue) {
            SoundManager.instance.playRingtoneSound(name: COMMON_SOUND_TYPE.noti_daddy.rawValue)
        } else {
            SoundManager.instance.playRingtoneSound(name: COMMON_SOUND_TYPE.noti_mommy.rawValue)
        }
    }
}

