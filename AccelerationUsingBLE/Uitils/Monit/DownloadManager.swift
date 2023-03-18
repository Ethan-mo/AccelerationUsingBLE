//
//  DownloadManager.swift
//  Monit
//
//  Created by 맥 on 2018. 3. 23..
//  Copyright © 2018년 맥. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class DownloadManager {
    static var m_instance: DownloadManager!
    static var instance: DownloadManager {
        get {
            if (m_instance == nil) {
                m_instance = DownloadManager()
            }
            
            return m_instance
        }
    }
    
    func packetLoad(_ send: SendBase, to localUrl: URL, completion: ActionResultBool?) {
        switch send.logPrintLevel {
        case .dev: Debug.print("[🔜][Network] \(send.pkt.rawValue) Request: \(JSON(send.convert()))", event: .dev)
        case .normal: Debug.print("[🔜][Network] \(send.pkt.rawValue) Request: \(JSON(send.convert()))")
        case .warning: Debug.print("[🔜][Network] \(send.pkt.rawValue) Request: \(JSON(send.convert()))", event: .warning)
        default: break
        }

        if (Utility.currentReachabilityStatus == .notReachable) {
            Debug.print("[🔜][Network] Network offline", event: .warning)
            completion?(false)
            return
        }

        if (send.pkt != .GetAppData && DataManager.instance.m_configData.appData == "") {
            Debug.print("[🔜][Network] appData setting error", event: .warning)
            return
        }

        if (send.url != "") {
            Debug.print("[🔜][Network] \(send.url)")
        }
        
        if (send.isEncrypt) {
            var request = URLRequest(url: URL(string: send.url == "" ? Config.WEB_URL : send.url)!)
            request.httpMethod = HTTPMethod.post.rawValue
//            request.setValue("application/text", forHTTPHeaderField: "Content-Type")
            if let theJSONData = try? JSONSerialization.data(
                withJSONObject: send.convert(),
                options: []) {
                let theJSONText = String(data: theJSONData,
                                         encoding: .ascii)
                //                print("JSON string = \(theJSONText!)")
                request.httpBody = Data(DataManager.instance.m_configData.encryptData(string: theJSONText!) .utf8)
            }
            let sessionConfig = URLSessionConfiguration.default
            let session = URLSession(configuration: sessionConfig)
            
            let task = session.downloadTask(with: request) { (tempLocalUrl, response, error) in
                if let tempLocalUrl = tempLocalUrl, error == nil {
                    // Success
                    if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                        Debug.print("Success: \(statusCode)")
                    }
                   
                    do {
                        if (FileManager.default.fileExists(atPath: localUrl.path)) { // 파일 있으면 삭제하고 진행 (기존 파일을 써도 되긴하지만 서버에서 파일만 교체할수 있으므로)
                            try FileManager.default.removeItem(atPath: localUrl.path)
                        }
                        
                        try FileManager.default.copyItem(at: tempLocalUrl, to: localUrl)
                        completion?(true)
                    } catch (let writeError) {
                        Debug.print("[ERROR] error writing file \(localUrl) : \(writeError)", event: .error)
                        completion?(false)
                    }
                } else {
                    Debug.print(String(format: "[ERROR] Failure: %@", error?.localizedDescription ?? ""), event: .error)
                    completion?(false)
                }
            }
            task.resume()
        } else {
            completion?(false)
        }
    }
    
    func load(url: URL, to localUrl: URL, completion: ActionResultBool?) {
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        let request = try! URLRequest(url: url, method: .get)
        
        let task = session.downloadTask(with: request) { (tempLocalUrl, response, error) in
            if let tempLocalUrl = tempLocalUrl, error == nil {
                // Success
                if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                    Debug.print("Success: \(statusCode)")
                }
               
                do {
                    if (FileManager.default.fileExists(atPath: localUrl.path)) { // 파일 있으면 삭제하고 진행 (기존 파일을 써도 되긴하지만 서버에서 파일만 교체할수 있으므로)
                        try FileManager.default.removeItem(atPath: localUrl.path)
                    }
                    
                    try FileManager.default.copyItem(at: tempLocalUrl, to: localUrl)
                    completion?(true)
                } catch (let writeError) {
                    Debug.print("[ERROR] error writing file \(localUrl) : \(writeError)", event: .error)
                    completion?(false)
                }
            } else {
                Debug.print(String(format: "[ERROR] Failure: %@", error?.localizedDescription ?? ""), event: .error)
                completion?(false)
            }
        }
        task.resume()
    }
}
