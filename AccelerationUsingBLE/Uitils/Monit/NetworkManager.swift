//
//  NetworkManager.swift
//  Monit
//
//  Created by 맥 on 2017. 8. 29..
//  Copyright © 2017년 맥. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

// none singletone
class NetworkManager {
//    static var m_instance: NetworkManager!
    static var instance: NetworkManager {
        get {
//            if (m_instance == nil) {
//                m_instance = NetworkManager()
//            }
            
            return NetworkManager()
        }
    }
    
    func Request(_ send: SendBase, completion:@escaping (JSON) -> ()) {
        switch send.logPrintLevel {
        case .dev: Debug.print("[🔜][Network] \(send.pkt.rawValue) Request: \(JSON(send.convert()))", event: .dev)
        case .normal: Debug.print("[🔜][Network] \(send.pkt.rawValue) Request: \(JSON(send.convert()))")
        case .warning: Debug.print("[🔜][Network] \(send.pkt.rawValue) Request: \(JSON(send.convert()))", event: .warning)
        default: break
        }
        
        if (Utility.currentReachabilityStatus == .notReachable) {
            Debug.print("[🔜][Network] Network offline", event: .warning)
            _ = PopupManager.instance.onlyContents(contentsKey: "internet_disconnected_detail", confirmType: .ok, existKey: "offline")
            completion(JSON())
            return
        }
        
        if (send.pkt != .GetAppData && DataManager.instance.m_configData.appData == "") {
            Debug.print("[🔜][Network] appData setting error", event: .warning)
            _ = PopupManager.instance.onlyContents(contentsKey: "toast_invalid_user_session", confirmType: .ok, okHandler: { () -> () in
                _ = UIManager.instance.sceneMove(scene: .initView, animation: .coverVertical, isAnimation: false)
                completion(JSON())
            }, cancleHandler: nil, existKey: send.existPopupType)
            return
        }
        
        if (send.isIndicator) {
            UIManager.instance.indicator(true)
        }
        
        if (send.url != "") {
            Debug.print("[🔜][Network] \(send.url)")
        }
        
        let _manager = Alamofire.SessionManager.default
        _manager.session.configuration.timeoutIntervalForRequest = Config.NETWORK_MANAGER_REQUEST_TIMEOUT

        if (send.isEncrypt) {
            var request = URLRequest(url: URL(string: send.url == "" ? Config.WEB_URL : send.url)!)
            request.httpMethod = HTTPMethod.post.rawValue
            request.setValue("application/text", forHTTPHeaderField: "Content-Type")
            if let theJSONData = try? JSONSerialization.data(
                withJSONObject: send.convert(),
                options: []) {
                let theJSONText = String(data: theJSONData,
                                         encoding: .ascii)
//                print("JSON string = \(theJSONText!)")
                request.httpBody = Data(DataManager.instance.m_configData.encryptData(string: theJSONText!) .utf8)
            }
            _manager.request(request)
                .responseString { response in
                    self.responseString(send: send, response: response, completion: completion)
                }
        } else {
            _manager.request(send.url == "" ? Config.WEB_URL : send.url, method: .post, parameters: send.convert(), encoding: JSONEncoding.default)
                .responseJSON { response in
                    self.responseJson(send: send, response: response, completion: completion)
                }
        }
        
    }
    
    func responseJson(send: SendBase, response: DataResponse<Any>, completion:@escaping (JSON) -> ()) {
        UIManager.instance.indicator(false)
        switch response.result {
        case .success:
            if let value = response.result.value {
                switch send.logPrintLevel {
                case .dev: Debug.print("[🔙][Network] \(send.pkt.rawValue) Receive: \(JSON(value))")
                case .normal: Debug.print("[🔙][Network] \(send.pkt.rawValue) Receive: \(JSON(value))")
                case .warning: Debug.print("[🔙][Network] \(send.pkt.rawValue) Receive: \(JSON(value))", event: .warning)
                default: break
                }
                self.success(send: send, json: JSON(value), completion: completion)
            }
        case .failure(let error): self.failure(error, send: send, completion: completion)
        }
    }
    
    func responseString(send: SendBase, response: DataResponse<String>, completion:@escaping (JSON) -> ()) {
        UIManager.instance.indicator(false)
        switch response.result {
        case .success:
            if let value = response.result.value {
                let _decrypt = DataManager.instance.m_configData.decryptData(string: value)
                do {
                    let _json = try JSONSerialization.jsonObject(with: _decrypt.data(using: .utf8)!, options: []) as! [String : Any]
                    
                    switch send.logPrintLevel {
                    case .dev: Debug.print("[🔙][Network] \(send.pkt.rawValue) Receive: \(JSON(_json))", event: .dev)
                    case .normal: Debug.print("[🔙][Network] \(send.pkt.rawValue) Receive: \(JSON(_json))")
                    case .warning: Debug.print("[🔙][Network] \(send.pkt.rawValue) Receive: \(JSON(_json))", event: .warning)
                    default: break
                    }
                    self.success(send: send, json: JSON(_json), completion: completion)
                } catch {
                    self.success(send: send, json: JSON(), completion: completion)
                }
            }
        case .failure(let error): self.failure(error, send: send, completion: completion)
        }
    }
    
    func success(send: SendBase, json: JSON, completion: @escaping (JSON) -> ()) {
        let ecd : ERR_COD? = ERR_COD(rawValue: json["ecd"].intValue)
        // 있는 에러 코드
        if (ecd != nil) {
            if (ecd! != .success) {
                let _isResending = resendingCheck(send: send, completion: completion)
                if (_isResending) {
                    Debug.print("[🔙][Network][ERROR] \(ecd!.rawValue)", event: .error)
                    return
                }
            }
            
            switch ecd! {
            // 캐치 에러 코드
            case .invaildTokenExpire,
                 .invaildToken:
                Debug.print("[🔙][Network] invaildToken", event: .warning)
                if (DataManager.instance.m_userInfo.isSignin) {
                    SystemManager.instance.sessionDisconnect()
                    _ = PopupManager.instance.onlyContents(contentsKey: "toast_invalid_user_session".localized, confirmType: .ok, okHandler: { () -> () in
                        _ = UIManager.instance.sceneMove(scene: .initView, animation: .coverVertical, isAnimation: false)
                    }, cancleHandler: nil, existKey: send.existPopupType)
                }
            case .need_essential_value:
                Debug.print("[🔙][Network][ERROR] Need essential value", event: .error)
                completion(json)
            case .etc_err_162:
                Debug.print("[🔙][Network][ERROR] Etc Error : 162", event: .error)
                _ = PopupManager.instance.onlyContentsCustom(contents: String(format: "dialog_contents_err_communication_with_server".localized, "162"), confirmType: .ok, existKey: send.existPopupType)
                completion(json)
            case .etc_err_170:
                Debug.print("[🔙][Network][ERROR] Etc Error : 170", event: .error)
                _ = PopupManager.instance.onlyContentsCustom(contents: String(format: "dialog_contents_err_communication_with_server".localized, "170"), confirmType: .ok, existKey: send.existPopupType)
                completion(json)
            default: completion(json)
            }
        // 없는 에러 코드
        } else {
            Debug.print("[🔙][Network][ERROR] \(json["ecd"].intValue)", event: .error)
            let _isResending = resendingCheck(send: send, completion: completion)
            if (_isResending) { return }
            
            var _isDebug = false
            if (Config.IS_DEBUG) {
                _isDebug = true
            } else {
                if (DataManager.instance.m_userInfo.configData.isMaster) {
                    _isDebug = true
                }
            }
            
            if (_isDebug) {
                let _info = PopupDetailInfo()
                _info.title = "dialog_unknown_error_description".localized
                _info.contents = String(json["ecd"].intValue)
                _info.buttonType = PopupView.CUSTOM_BUTTON_TYPE.center
                _info.center = "btn_ok".localized
                _info.centerColor = COLOR_TYPE.mint.color
                _ = PopupManager.instance.setDetail(popupDetailInfo: _info, okHandler: { () -> () in
                    completion(json)
                }, cancleHandler: nil, existKey: send.existPopupType)
            } else {
                completion(json)
            }
        }
    }
    
    func failure(_ error: Error, send: SendBase, completion:@escaping (JSON) -> ()) {
        Debug.print("[🔙][Network][ERROR] \(error.localizedDescription)", event: .error)
        let _isResending = resendingCheck(send: send, completion: completion)
        if (_isResending) { return }
        
        let _errTitle = String(format: "dialog_contents_err_communication_with_server".localized, APP_ERR_COD.networkFailure.rawValue)
        if (send.isErrorPopupOn) {
            let _info = PopupDetailInfo()
            _info.title = _errTitle
            _info.contents = error.localizedDescription
            _info.buttonType = PopupView.CUSTOM_BUTTON_TYPE.center
            _info.center = "btn_ok".localized
            _info.centerColor = COLOR_TYPE.mint.color
            _ = PopupManager.instance.setDetail(popupDetailInfo: _info, okHandler: { () -> () in
                completion(JSON())
            }, cancleHandler: nil, existKey: send.existPopupType)
        } else {
            completion(JSON())
        }
    }
    
    func resendingCheck(send: SendBase, completion: @escaping (JSON) -> ()) -> Bool {
        if (send.isResending) {
            if (send.resendingCount < Config.NETWORK_MANAGER_RESEDNING_COUNT) {
                Request(send, completion: completion)
                send.resendingCount += 1
                return true
            }
        }
        return false
    }
}

