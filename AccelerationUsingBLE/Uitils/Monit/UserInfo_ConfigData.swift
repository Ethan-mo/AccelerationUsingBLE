//
//  UserInfo_ConfigData.swift
//  Monit
//
//  Created by 맥 on 2018. 2. 26..
//  Copyright © 2018년 맥. All rights reserved.
//

import Foundation

class UserInfo_ConfigData {
    class DemoInfo {
        var m_threshold = 30
        var m_count_time = 3
        var m_alarm_delay: Double = 2.0
        var m_ignore_delay: Double = 3.0
    }
    
    var m_demoInfo: DemoInfo = DemoInfo()
    
    var m_rmode: Int = 0
    var rmode: String {
        get {
            let _str = String(m_rmode, radix: 2)
            return Utility.pad(string: _str, toSize: 9)
        }
    }
    var isMaster: Bool {
        get {
            if (DataManager.instance.m_userInfo.isSignin) {
                if (m_rmode & 1 > 0) {
                    return true
                }
            }
            return false
        }
    }
    var isBeta: Bool {
        get {
            if (DataManager.instance.m_userInfo.isSignin) {
                if (m_rmode & 2 > 0) {
                    return true
                }
            }
            return false
        }
    }
    var isBetaMining: Bool {
        get {
            if (DataManager.instance.m_userInfo.isSignin) {
                if (m_rmode & 4 > 0) {
                    return true
                }
            }
            return false
        }
    }
    var isDemo: Bool {
        get {
            if (DataManager.instance.m_userInfo.isSignin) {
                if (isCustomDemo) {
                    return true
                }
                
                if (m_rmode & 8 > 0) {
                    return true
                }
            }
            return false
        }
    }
    var isMonitoring: Bool {
        get {
            if (DataManager.instance.m_userInfo.isSignin) {
                if (m_rmode & 16 > 0) {
                    return true
                }
            }
            return false
        }
    }
    var isDevelop: Bool {
        get {
            if (DataManager.instance.m_userInfo.isSignin) {
                if (m_rmode & 32 > 0) {
                    return true
                }
            }
            return false
        }
    }
    var isNewProduct: Bool {
        get {
            if (DataManager.instance.m_userInfo.isSignin) {
                if (m_rmode & 64 > 0) {
                    return true
                }
            }
            return false
        }
    }
    var isExternalDeveloper: Bool {
        get {
            if (DataManager.instance.m_userInfo.isSignin) {
                if (m_rmode & 128 > 0) {
                    return true
                }
            }
            return false
        }
    }
    var isHuggiesV1Alarm: Bool {
        get {
            if (DataManager.instance.m_userInfo.isSignin) {
                if (m_rmode & 256 > 0) {
                    return true
                }
            }
            return false // 원래는 False
        }
    }
    
    var isNotiNidUpdate: Bool {
        get { return Utility.getLocalBool(name: "isNotiNidUpdate") }
        set {
            if (newValue) {
                Debug.print("Set isNotiNidUpdate: TRUE", event: .warning)
            }
            Utility.setLocalBool(name: "isNotiNidUpdate", value: newValue)
        }
    }
    
    var notificationEditTime: String {
        get { return UserDefaults.standard.string(forKey: "notificationEditTime") ?? "700101-000000" }
        set { UserDefaults.standard.set(newValue, forKey: "notificationEditTime") }
    }
    
    var OAuthToken: String {
        get { return Utility.getLocalString(name: "OAuthToken") }
        set { UserDefaults.standard.set(newValue, forKey: "OAuthToken") }
    }
    
    var isCustomDemo: Bool = false
    
    var m_tempUnit: String = "C"
    var getReverseTempUnit: String {
        get {
            if (m_tempUnit == "C") {
                return "F"
            } else {
                return "C"
            }
        }
    }
}
