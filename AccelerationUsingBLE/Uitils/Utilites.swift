//
//  Utilites.swift
//  AccelerationUsingBLE
//
//  Created by 모상현 on 2023/02/08.
//

import UIKit
import CryptoSwift
import SystemConfiguration

class Utility {
    static var isTopNotch: Bool {
        get {
            if UIDevice().userInterfaceIdiom == .phone {
                switch UIScreen.main.nativeBounds.height {
                case 1792, // .iPhone_XR
                     2436,
                     2688, // X, XS, 11Pro, 11, Xr
                     2340, //iPhone 12 mini "downsampled screen"
                     2532, // 12, 12 pro
                     2778: // 12 pro max
                    return true
                default: break
                }
            }

            return false
        }
    }
    
    static var isSimulator: Bool {
        get {
            var _isSim = false
            #if (arch(i386) || arch(x86_64))
                _isSim = true
            #endif
            return _isSim
        }
    }
    
    #if GOODMONIT || HUGGIES || KC
    static func md5(_ string: String) -> String? {
        let length = Int(CC_MD5_DIGEST_LENGTH)
        var digest = [UInt8](repeating: 0, count: length)
        
        if let d = string.data(using: String.Encoding.utf8) {
            _ = d.withUnsafeBytes { (body: UnsafePointer<UInt8>) in
                CC_MD5(body, CC_LONG(d.count), &digest)
            }
        }
        
        return (0..<length).reduce("") {
            $0 + String(format: "%02x", digest[$1])
        }
    }
    #endif

    static func getLocalString(name : String) -> String {
        if (UserDefaults.standard.string(forKey: name) == nil) {
            UserDefaults.standard.set("", forKey: name)
        }
        return UserDefaults.standard.string(forKey: name)!
    }
    
    static func getLocalInt(name : String) -> Int {
        return UserDefaults.standard.integer(forKey: name)
    }
    
    static func getLocalBool(name : String) -> Bool {
        return UserDefaults.standard.bool(forKey: name)
    }
    
//    static func getLocalStringAes256(name: String) -> String {
//        return Utility.aes256Decrypt(string: Utility.getLocalString(name: name))
//    }
//
//    static func getLocalIntAes256(name: String) -> Int {
//        return Int(Utility.aes256Decrypt(string: Utility.getLocalString(name: name))) ?? 0
//    }
//
//    static func getLocalBoolAes256(name: String) -> Bool {
//        return Bool(Utility.aes256Decrypt(string: Utility.getLocalString(name: name))) ?? false
//    }
    
    static func setLocal(name: String, value: String) {
        UserDefaults.standard.set(value, forKey: name)
    }
    
    static func setLocalBool(name: String, value: Bool) {
        UserDefaults.standard.set(value, forKey: name)
    }
    
//    static func setLocalAes256(name: String, value: String) {
//        UserDefaults.standard.set(Utility.aes256Encrypt(string: value), forKey: name)
//    }
    
    static func waiting(milliSecond: Int) {
        var _timeCount: Int = 0
        repeat {
            usleep(1000) // Sleep for 0.001s
            _timeCount += 1
        }
        while _timeCount < milliSecond
    }
    
    static func pad(string : String, toSize: Int) -> String {
        var padded = string
        for _ in 0..<(toSize - string.count) {
            padded = "0" + padded
        }
        return padded
    }
    
    static func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    static func urlEncode(_ text: String?) -> String {
        return (text?.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed))!
    }
    
//    static func urlDecode(_ text: String?) -> String {
//        return (text?.decod)
//    }

    #if GOODMONIT || HUGGIES || KC
    static func urlOpen(_ url: String) -> Bool {
        if let _url = URL(string: url), UIApplication.shared.canOpenURL(_url) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(_url, options: [:], completionHandler: {
                    (success) in
                    Debug.print("Open \(url): \(success)", event: .warning)
                })
            } else {
                let success = UIApplication.shared.openURL(_url)
                Debug.print("Open \(url): \(success)", event: .warning)
            }
            return true
        }
        return false
    }
    #endif
    
    enum ReachabilityStatus {
        case notReachable
        case reachableViaWWAN
        case reachableViaWiFi
    }

    static var currentReachabilityStatus: ReachabilityStatus {
        get {
            var zeroAddress = sockaddr_in()
            zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
            zeroAddress.sin_family = sa_family_t(AF_INET)
            
            guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
                $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                    SCNetworkReachabilityCreateWithAddress(nil, $0)
                }
            }) else {
                return .notReachable
            }
            
            var flags: SCNetworkReachabilityFlags = []
            if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
                return .notReachable
            }
            
            if flags.contains(.reachable) == false {
                // The target host is not reachable.
                return .notReachable
            }
            else if flags.contains(.isWWAN) == true {
                // WWAN connections are OK if the calling application is using the CFNetwork APIs.
                return .reachableViaWWAN
            }
            else if flags.contains(.connectionRequired) == false {
                // If the target host is reachable and no connection is required then we'll assume that you're on Wi-Fi...
                return .reachableViaWiFi
            }
            else if (flags.contains(.connectionOnDemand) == true || flags.contains(.connectionOnTraffic) == true) && flags.contains(.interventionRequired) == false {
                // The connection is on-demand (or on-traffic) if the calling application is using the CFSocketStream or higher APIs and no [user] intervention is needed
                return .reachableViaWiFi
            }
            else {
                return .notReachable
            }
        }
    }
    
    static func isUpdateVersion(latestVersion: String, currentVersion: String) -> Bool {
        if latestVersion.compare(currentVersion, options: .numeric) == .orderedDescending {
            return true
        }
        return false
    }
    
    static func isAvailableVersion(availableVersion: String, currentVersion: String) -> Bool {
        if currentVersion.compare(availableVersion, options: .numeric) == .orderedSame {
            return true
        }
        if currentVersion.compare(availableVersion, options: .numeric) == .orderedDescending {
            return true
        }
        return false
    }
    
    static var timeStamp: Double {
        get {
            return NSDate().timeIntervalSince1970
        }
    }
}

func customAlert(view:UIViewController, mainTitle:String, mainMessage:String, completion:@escaping(UIAlertAction) -> Void) {
    let alert = UIAlertController(title: mainTitle, message: mainMessage, preferredStyle: .alert)
    let action = UIAlertAction(title: "확인", style: .cancel, handler: completion)
    alert.addAction(action)
    view.present(alert, animated: true)
}
