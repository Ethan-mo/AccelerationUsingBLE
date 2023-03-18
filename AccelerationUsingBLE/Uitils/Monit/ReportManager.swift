//
//  ReportController.swift
//  Monit
//
//  Created by 맥 on 2018. 1. 30..
//  Copyright © 2018년 맥. All rights reserved.
//

import Foundation

public class ReportManager {
    static var m_instance: ReportManager!
    static var instance: ReportManager {
        get {
            if (m_instance == nil) {
                m_instance = ReportManager()
            }
            
            return m_instance
        }
    }
    
    public typealias CompletionHandler = (_ isSuccess: Bool) -> Void
    
    var fileURL: URL? {
        get {
            if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                return dir.appendingPathComponent("debug_\(UI_Utility.nowYYMMD).txt")
            }
            return nil
        }
    }

    func read(intervalDay: Int) -> String {
        if let _dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let _fileURL = _dir.appendingPathComponent(getDebugName(intervalDay: intervalDay))
            if FileManager.default.fileExists(atPath: _fileURL.path) {
                var readString = "" // Used to store the file contents
                do {
                    // Read the file contents
                    readString = try String(contentsOf: _fileURL)
                } catch let error as NSError {
                    Debug.print("[ReportManager][ERROR] Failed reading from URL: \(_fileURL), Error: " + error.localizedDescription, event: .error)
                }
                return readString
            }
        }
        return ""
    }
    
    func write(_ items: Any...) {
        if let _fileURL = fileURL {
            let _text:String = "\(UI_Utility.nowTime):\(items)\n"
            let data = _text.data(using: String.Encoding.utf8, allowLossyConversion: false)!

//            if FileManager.default.fileExists(atPath: _fileURL.path) {
                if let fileHandle = FileHandle(forWritingAtPath: _fileURL.path) {
                    defer {
                        fileHandle.closeFile()
                    }
                    fileHandle.seekToEndOfFile()
                    fileHandle.write(data)
                }
                else {
                    do {
                        try data.write(to: _fileURL, options: .atomic)
                    } catch {}
                }
//            } else {
//                Debug.print("Can't write")
//            }
        }
    }
    
    func newData() {
        if let _fileURL = fileURL {
            let _text = ""
            
            //writing
            do {
                try _text.write(to: _fileURL, atomically: false, encoding: .utf8)
            }
            catch {/* error handling here */}
        }
    }
    
//    func fileSend(isMonitoring: Bool) {
//        let _intervalSt = isMonitoring ? 1 : 0
//        let _intervalEd = isMonitoring ? 3 : 3
//        for i in _intervalSt..._intervalEd {
//            let _name = getDebugName(intervalDay: i)
//            if let _dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
//                let _fileURL = _dir.appendingPathComponent(_name)
//                if FileManager.default.fileExists(atPath: _fileURL.path) {
//                    uploadForBlob(isReport: !isMonitoring, data: read(intervalDay: i), date: getDate(intervalDay: i), aHandler: { (isSuccess) in
////                        if (i != 0) {
//                            self.deleteSpecific(interval: i)
////                        }
//                    })
////                    upload(data: read(intervalDay: i), date: getDate(intervalDay: i), aHandler: { (isSuccess) in
//////                        if (i != 0) {
////                            self.deleteSpecific(interval: i)
//////                        }
////                    })
//                }
//            }
//        }
//        if (!isMonitoring) {
//            let _popupInfo = PopupDetailInfo()
//            _popupInfo.title = "Thank you!"
//            _popupInfo.contents = "Tahnk you!"
//            _popupInfo.buttonType = .center
//            _popupInfo.center = "btn_ok".localized
//            _popupInfo.centerColor = COLOR_TYPE.mint.color
//            _ = PopupManager.instance.setDetail(popupDetailInfo: _popupInfo)
//        }
//    }
    
    func deleteSpecific(interval: Int) {
        if let _dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let _fileURL = _dir.appendingPathComponent(getDebugName(intervalDay: interval))
            if FileManager.default.fileExists(atPath: _fileURL.path) {
                do {
                    Debug.print("[ReportManager] delete file: \(getDebugName(intervalDay: interval))", event: .warning)
                    try FileManager.default.removeItem(atPath: _fileURL.path)
                } catch {}
            }
        }
    }
    
    func delete(exceptInterval: Int) {
        let fileManager = FileManager.default
        let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first! as NSURL
        let documentsPath = documentsUrl.path
        
        do {
            if let documentPath = documentsPath
            {
                let fileNames = try fileManager.contentsOfDirectory(atPath: "\(documentPath)")
                for fileName in fileNames {
                    Debug.print("[ReportManager] all file name: \(fileName)", event: .warning)
                    var _isFound = false
                    for i in 0...exceptInterval {
                        if (fileName == getDebugName(intervalDay: i)) {
                            _isFound = true
                            break
                        }
                    }
                    if (!_isFound) {
                        if (fileName.contains("debug_")) {
                            let filePathName = "\(documentPath)/\(fileName)"
                            Debug.print("[ReportManager] delete file name: \(filePathName)", event: .warning)
                            try fileManager.removeItem(atPath: filePathName)
                        }
                    }
                }
            }
        } catch {
            Debug.print("[ReportManager][ERROR] Could not clear temp folder: \(error)", event: .error)
        }
    }
    
    func getDate(intervalDay: Int) -> String {
        let _date = NSDate(timeIntervalSinceNow: TimeInterval(-86400 * intervalDay)) as Date
        return UI_Utility.convertDateToString(_date, type: .yyMMdd)
    }
    
    func getDebugName(intervalDay: Int) -> String {
        return "debug_\(getDate(intervalDay: intervalDay)).txt"
    }

//    func uploadForBlob(isReport: Bool, data: String, date: String, aHandler: @escaping (Bool) -> Void) {
//        let account = try! AZSCloudStorageAccount(fromConnectionString: Config.AZURE_STORAGE_CONNECTION_STRING) //I stored the property in my header file
//        let blobClient: AZSCloudBlobClient = account.getBlobClient()
//        let blobContainer: AZSCloudBlobContainer = blobClient.containerReference(fromName: "log")
//
//        blobContainer.createContainerIfNotExists(with: AZSContainerPublicAccessType.container, requestOptions: nil, operationContext: nil) { (NSError, Bool) -> Void in
//            if ((NSError) != nil){
//                Debug.print("[ReportManager] blob upload failed", event: .warning)
//            }
//            else {
//                let _reportName = isReport ? UI_Utility.nowUTCDate(type: .yyMMdd_HHmmss) : ""
//                let fileName = "i_\(DataManager.instance.m_userInfo.account_id)_\(date)_debug_\(_reportName).txt"
//                let blob: AZSCloudBlockBlob = blobContainer.blockBlobReference(fromName: fileName as String)
//                blob.upload(fromText: data, completionHandler: {(NSError) -> Void in
//                    aHandler(true)
//                    Debug.print("[ReportManager] blob load success: \(fileName)", event: .warning)
//                })
//            }
//        }
//    }
    
    func upload(data: String, date: String, aHandler: @escaping (Bool) -> Void) {
        let fileName = "\(DataManager.instance.m_userInfo.account_id)_debug_\(date)_.txt"
        let url:URL? = URL(string: "http://13.124.139.44/collectdata/upload_file.php")
        let cachePolicy = URLRequest.CachePolicy.reloadIgnoringLocalCacheData
        let request = NSMutableURLRequest(url: url!, cachePolicy: cachePolicy, timeoutInterval: 2.0)
        request.httpMethod = "POST"
        
        // Set Content-Type in HTTP header.
        let boundaryConstant = "Boundary-7MA4YWxkTLLu0UIW"; // This should be auto-generated.
        let contentType = "multipart/form-data; boundary=" + boundaryConstant
        
        request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        request.setValue(fileName, forHTTPHeaderField: "uploaded_file")
        request.setValue("Keep-Alive", forHTTPHeaderField: "Connection")
        request.setValue("multipart/from-data", forHTTPHeaderField: "ENCTYPE")
        
        // Set data
        var _: NSError?
        var dataString = "--\(boundaryConstant)\r\n"
        dataString += "Content-Disposition: form-data; name=\"uploaded_file\"; filename=\"\(fileName)\"\r\n"
        dataString += "Content-Type: text/plain\r\n\r\n"
        dataString += data
        dataString += "\r\n"
        dataString += "--\(boundaryConstant)--\r\n"
        
//        Debug.print(dataString) // This would allow you to see what the dataString looks like.
        // Set the HTTPBody we'd like to submit
        let requestBodyData = (dataString as String).data(using: String.Encoding.utf8)
        request.httpBody = requestBodyData
        
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error -> Void in
            print("Response: \(String(describing: response))")
            aHandler(true)
        })
        task.resume()
    }
}
