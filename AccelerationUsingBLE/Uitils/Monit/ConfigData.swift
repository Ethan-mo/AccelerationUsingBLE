//
//  ConfigData.swift
//  Monit
//
//  Created by 맥 on 2017. 8. 30..
//  Copyright © 2017년 맥. All rights reserved.
//

import Foundation
import CryptoSwift
import UIKit

class ConfigData {
    var m_appData = ""
    var m_appIndexKey = [String]()
    var m_appKey = ""
    var m_appIV = ""
    var m_localAppData = ""
    var m_localAppIndexKey = [String]()
    var m_localAppKey = ""
    var m_localAppIV = ""
    var m_initInfoFlow = Flow()
    var m_etcInfoFlow = Flow()
    var m_pushFlow = Flow()
    var m_huggiesNickFlow = Flow()
    var m_noticeFlow = Flow()
    var m_commonCommand = Flow()
    var m_latestSensorVersion = ""
    var m_latestHubVersion = ""
    var m_latestLampVersion = ""
    var m_latestSensorForceVersion = ""
    var m_latestHubForceVersion = ""
    var m_latestLampForceVersion = ""

    func initFlow() {
        m_initInfoFlow = Flow()
        m_etcInfoFlow = Flow()
        m_pushFlow = Flow()
        m_huggiesNickFlow = Flow()
        m_noticeFlow = Flow()
        m_commonCommand = Flow()
    }

    var isTerminateApp: Bool {
        get { return Utility.getLocalBool(name: "isTerminateApp") }
        set { UserDefaults.standard.set(newValue, forKey: "isTerminateApp") }
    }
    
    var isTerminateNoti: Bool {
        get { return !Utility.getLocalBool(name: "isTerminateNoti") }
        set { UserDefaults.standard.set(!newValue, forKey: "isTerminateNoti") }
    }
    
    var backgroundScType: Int {
        get { return Utility.getLocalInt(name: "backgroundScType") }
        set { UserDefaults.standard.set(newValue, forKey: "backgroundScType") }
    }
    
    var backgroundScStTime: String {
        get { return Utility.getLocalString(name: "backgroundScStTime") }
        set { UserDefaults.standard.set(newValue, forKey: "backgroundScStTime") }
    }
    
    var backgroundScEdTime: String {
        get { return Utility.getLocalString(name: "backgroundScEdTime") }
        set { UserDefaults.standard.set(newValue, forKey: "backgroundScEdTime") }
    }
    
    func setRepeatNotice(key: String) {
        UserDefaults.standard.set(true, forKey: key)
    }
    
    func getRepeatNotice(key: String) -> Bool {
        return Utility.getLocalBool(name: key) 
    }

    var appData: String {
        get {
            return m_appData
        }
        set {
            m_appData = newValue
            let _arr: [String] = m_appData.map { String($0) }
            m_appIndexKey.removeAll()
            m_appIndexKey.append(_arr[1])
            m_appIndexKey.append(_arr[3])
            Debug.print("indexKey: \(String(describing: m_appIndexKey))", event: .dev)
            
            m_appKey = ""
            for (i, item) in _arr.enumerated() {
                if (i % 2 == 0) {
                    m_appKey += item
                }
            }
            Debug.print("appkey: \(m_appKey)", event: .dev)
            
            m_appIV = ""
            for (i, item) in _arr.enumerated() {
                if (5 <= i && i <= 35) {
                    if (i % 2 == 1) {
                        m_appIV += item
                    }
                }
            }
            Debug.print("appIV: \(m_appIV)", event: .dev)
        }
    }
    
    var localAppData: String {
        get {
            return m_localAppData
        }
        set {
            m_localAppData = newValue
            let _arr: [String] = m_localAppData.map { String($0) }
            m_localAppIndexKey.removeAll()
            m_localAppIndexKey.append(_arr[1])
            m_localAppIndexKey.append(_arr[3])
            Debug.print("localIndexKey: \(String(describing: m_localAppIndexKey))", event: .dev)
            
            m_localAppKey = ""
            for (i, item) in _arr.enumerated() {
                if (i % 2 == 0) {
                    m_localAppKey += item
                }
            }
            Debug.print("localAppkey: \(m_localAppKey)", event: .dev)
            
            m_localAppIV = ""
            for (i, item) in _arr.enumerated() {
                if (5 <= i && i <= 35) {
                    if (i % 2 == 1) {
                        m_localAppIV += item
                    }
                }
            }
            Debug.print("localAppIV: \(m_localAppIV)", event: .dev)
        }
    }
    
    var getSensorLatestVersionName: String {
        get {
            let _arrUrls = Bundle.main.urls(forResourcesWithExtension: "zip", subdirectory: "SensorFirmware")
            if let __arrUrls = _arrUrls {
                var _latestVersion = ""
                var _latestVersionName = ""
                for item in __arrUrls {
                    if (_latestVersion.count == 0) {
                        _latestVersion = getSensorFirmwareVersion(name: item.deletingPathExtension().lastPathComponent)
                        _latestVersionName = item.lastPathComponent
                    } else {
                        let _item = getSensorFirmwareVersion(name: item.deletingPathExtension().lastPathComponent)
                        if _item.compare(_latestVersion, options: .numeric) == .orderedDescending {
                            _latestVersion = _item
                            _latestVersionName = item.lastPathComponent
                        }
                    }
                }
                Debug.print("getSensorLatestVersionName: \(_latestVersionName)", event: .warning)
                return _latestVersionName
            }
            return ""
        }
    }
    
    // get local file in app
    var getSensorLatestVersion: String {
        get {
            let _arrUrls = Bundle.main.urls(forResourcesWithExtension: "zip", subdirectory: "SensorFirmware")
            if let __arrUrls = _arrUrls {
                var _latestVersion = ""
                for item in __arrUrls {
                    if (_latestVersion.count == 0) {
                        _latestVersion = getSensorFirmwareVersion(name: item.deletingPathExtension().lastPathComponent)
                    } else {
                        let _item = getSensorFirmwareVersion(name: item.deletingPathExtension().lastPathComponent)
                        if _item.compare(_latestVersion, options: .numeric) == .orderedDescending {
                            _latestVersion = _item
                        }
                    }
                }
                Debug.print("getSensorLatestVersion: \(_latestVersion)", event: .warning)
                return _latestVersion
            }
            return ""
        }
    }
    
    func getSensorFirmwareVersion(name: String) -> String {
        var _retValue = "0.0.0"
        let _arrLastChar = name.split(separator: "_")
        if (_arrLastChar.count == 5) {
            _retValue = "\(_arrLastChar[2]).\(_arrLastChar[3]).\(_arrLastChar[4])"
            Debug.print("getSensorFirmwareVersion: \(_retValue)", event: .warning)
            return _retValue
        }
        return _retValue
    }

    func encryptData(string: String) -> String {
        do {
            let _encryptBase64: String = try string.encryptToBase64(cipher: AES(key: m_appKey, iv: m_appIV)) ?? ""
//            let _aes = try AES(key: m_appKey, iv: m_appIV)
//            let _ciphertext = try _aes.encrypt(Array(string.utf8))
//            let _encryptBase64: String = _ciphertext.toBase64()!
            var _arr: [String] = _encryptBase64.map { String($0) }
            _arr.insert(m_appIndexKey[0], at: 1)
            _arr.insert(m_appIndexKey[1], at: 3)
            return _arr.compactMap({$0}).joined()
        } catch { }
        return ""
    }
    
    func decryptData(string: String) -> String {
        do {
            return try string.decryptBase64ToString(cipher: AES(key: m_appKey, iv: m_appIV))
        } catch { }
        return ""
    }
    
    func localEncryptData(string: String) -> String {
        do {
            if (m_localAppKey == "" || m_localAppIV == "") {
                return ""
            }
            return try string.encryptToBase64(cipher: AES(key: m_localAppKey, iv: m_localAppIV)) ?? ""
        } catch { }
        return ""
    }
    
    func localDecryptData(string: String) -> String {
        do {
            if (m_localAppKey == "" || m_localAppIV == "") {
                return ""
            }
            return try string.decryptBase64ToString(cipher: AES(key: m_localAppKey, iv: m_localAppIV))
        } catch { }
        return ""
    }
    
    func getLocalStringAes256(name: String) -> String {
        if (Utility.getLocalString(name: name) == "") {
            return ""
        }
        
        return localDecryptData(string: Utility.getLocalString(name: name))
    }
        
    func getLocalIntAes256(name: String) -> Int {
        if (Utility.getLocalString(name: name) == "") {
            return 0
        }
        
        return Int(localDecryptData(string: Utility.getLocalString(name: name))) ?? 0
    }
        
    func getLocalBoolAes256(name: String) -> Bool {
        if (Utility.getLocalString(name: name) == "") {
            return false
        }
        
        return Bool(localDecryptData(string: Utility.getLocalString(name: name))) ?? false
    }
    
    func setLocalAes256(name: String, value: String) {
        UserDefaults.standard.set(localEncryptData(string: value), forKey: name)
    }
}
