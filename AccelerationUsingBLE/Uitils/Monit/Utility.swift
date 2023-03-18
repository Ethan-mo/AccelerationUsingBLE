//
//  Utility.swift
//  Monit
//
//  Created by 맥 on 2017. 8. 30..
//  Copyright © 2017년 맥. All rights reserved.
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

class Flow {
    var isOne = false
    func one(one: () -> ()) {
        if !isOne {
            one()
            isOne = true
        }
    }
    
    var isReset = false
    func reset(reset: () -> ()) {
        if isReset {
            reset()
        } else {
            isReset = true
        }
    }
}

extension Double {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

extension String {
    func stringTrim() -> String {
        return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
}

extension Date {
    var millisecondsSince1970:Int {
        return Int((self.timeIntervalSince1970).rounded())
    }
    
    func adding(minutes: Int) -> Date {
        return Calendar.current.date(byAdding: .minute, value: minutes, to: self)!
    }
    
    func adding(second: Int) -> Date {
        return Calendar.current.date(byAdding: .second, value: second, to: self)!
    }
}

extension NSObject {
    static func classNameToString() -> String {
        return String(reflecting: type(of: self)).components(separatedBy: ".").last!
    }
    
    func classNameToString() -> String {
        return String(reflecting: type(of: self)).components(separatedBy: ".").last!
    }
}

public extension UIDevice {
    
    var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        switch identifier {
        case "iPod5,1":                                 return "iPod Touch 5"
        case "iPod7,1":                                 return "iPod Touch 6"
        case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
        case "iPhone4,1":                               return "iPhone 4s"
        case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
        case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
        case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
        case "iPhone7,2":                               return "iPhone 6"
        case "iPhone7,1":                               return "iPhone 6 Plus"
        case "iPhone8,1":                               return "iPhone 6s"
        case "iPhone8,2":                               return "iPhone 6s Plus"
        case "iPhone9,1", "iPhone9,3":                  return "iPhone 7"
        case "iPhone9,2", "iPhone9,4":                  return "iPhone 7 Plus"
        case "iPhone8,4":                               return "iPhone SE"
        case "iPhone10,1", "iPhone10,4":                return "iPhone 8"
        case "iPhone10,2", "iPhone10,5":                return "iPhone 8 Plus"
        case "iPhone10,3", "iPhone10,6":                return "iPhone X"
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
        case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
        case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
        case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
        case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
        case "iPad6,11", "iPad6,12":                    return "iPad 5"
        case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
        case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
        case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
        case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
        case "iPad6,3", "iPad6,4":                      return "iPad Pro 9.7 Inch"
        case "iPad6,7", "iPad6,8":                      return "iPad Pro 12.9 Inch"
        case "iPad7,1", "iPad7,2":                      return "iPad Pro 12.9 Inch 2. Generation"
        case "iPad7,3", "iPad7,4":                      return "iPad Pro 10.5 Inch"
        case "AppleTV5,3":                              return "Apple TV"
        case "AppleTV6,2":                              return "Apple TV 4K"
        case "AudioAccessory1,1":                       return "HomePod"
        case "i386", "x86_64":                          return "Simulator"
        default:                                        return identifier
        }
    }
    
}
