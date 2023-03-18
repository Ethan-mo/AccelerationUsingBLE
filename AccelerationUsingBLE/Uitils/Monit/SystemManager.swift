//
//  SystemManager.swift
//  Monit
//
//  Created by 맥 on 2017. 10. 23..
//  Copyright © 2017년 맥. All rights reserved.
//

import UIKit

class SystemManager {
    static var m_instance: SystemManager!
    static var instance: SystemManager {
        get {
            if (m_instance == nil) {
                m_instance = SystemManager()
            }
            
            return m_instance
        }
    }
    
    func isEqualVersion(checkVersion: String) -> Bool {
        var _localVersion = [Int]()
        if (Config.bundleVersion.count > 0) {
            let _arr = Config.bundleVersion.split{$0 == "."}.map(String.init)
            if (_arr.count == 3) {
                _localVersion.append(Int(_arr[0])!)
                _localVersion.append(Int(_arr[1])!)
                _localVersion.append(Int(_arr[2])!)
            }
        }
        var _checkVersion = [Int]()
        if (checkVersion.count > 0) {
            let _arr = checkVersion.split{$0 == "."}.map(String.init)
            if (_arr.count == 3) {
                _checkVersion.append(Int(_arr[0])!)
                _checkVersion.append(Int(_arr[1])!)
                _checkVersion.append(Int(_arr[2])!)
            }
        }
        if (_localVersion.count == 3 && _checkVersion.count == 3) {
            if (_localVersion[0] < _checkVersion[0]) {
                return false
            } else if (_localVersion[0] > _checkVersion[0]) {
                return true
            } else if (_localVersion[0] == _checkVersion[0]) {
                if (_localVersion[1] < _checkVersion[1]) {
                    return false
                } else if (_localVersion[1] > _checkVersion[1]) {
                    return true
                } else if (_localVersion[1] == _checkVersion[1]) {
                    if (_localVersion[2] < _checkVersion[2]) {
                        return false
                    } else if (_localVersion[2] > _checkVersion[2]) {
                        return true
                    } else if (_localVersion[2] == _checkVersion[2]) {
                        return true
                    }
                }
            }
        }
        
        Debug.print("[ERROR] invaild version", event: .error)
        return true
    }
    
    
    func GetStoryBoardName(_ scene: SCENE_MOVE) -> String {
        switch scene {
        case .initView:
            return "Main"
        case .mainSignin,
//             .mainSigninGoodmonit,
//             .mainSigninGoodmonitXHuggies,
             .policyMonitXHuggies,
             .joinEmailNavi,
             .joinEmailAuthNavi,
             .joinUserInfoNavi,
             .findPassword:
            return "Account"
        case .mainDeviceNavi,
             .deviceRegisterNavi,
             .deviceRegisterSensorBaby:
            return "Device"
        case .shareMemberMainNavi:
            return "ShareMember"
        case .userSetupMainNavi:
            return "UserSetup"
        case .sensorDetailNavi:
            return "Sensor"
        case .hubDetailNavi:
            return "Hub"
        case .lampDetailNavi:
            return "Lamp"
        }
    }
    
    func GetStoryBoardNameForContainer(_ scene: SCENE_CONTAINER) -> String {
        switch scene {
        case .mainSigninGoodmonitContainer,
             .mainSigninMonitXHuggiesContainer,
             .mainSigninKcContainer:
            return "Account"
        case .mainDeviceTableContainer,
             .mainDeviceNoneTableContainer:
            return "Device"
        case .deviceSensorDetailSensingContainer,
             .deviceSensorDetailSensingForKcContainer,
             .deviceSensorDetailGraphContainer,
             .deviceSensorDetailGraphForKcContainer,
             .deviceSensorDetailNotiContainer,
             .deviceSensorDetailNotiForHuggiesContainer:
            return "Sensor"
        case .deviceHubDetailSensingContainer,
             .deviceHubDetailSensingForKcContainer,
             .deviceHubDetailGraphContainer,
             .deviceHubDetailGraphForKcContainer,
             .deviceHubDetailNotiContainer:
            return "Hub"
        case .deviceLampDetailSensingContainer,
             .deviceLampDetailGraphContainer,
             .deviceLampDetailNotiContainer:
            return "Lamp"
        case .shareMemberShareContainer,
             .shareMemberGetSharedContainer,
             .shareMemberNotiContainer:
            return "ShareMember"
        }
    }
    
    func GetStoryBoardNameForPush(_ scene: SCENE_MOVE_PUSH) -> String {
        switch scene {
        case .joinEmail,
             .joinEmailAuth,
             .joinUserInfo,
             .joinFinish,
             .nickMonitXHuggies:
            return "Account"
        case .userSetupMain,
             .setupChangePassword,
             .setupChangeNick,
             .setupNUGU,
             .setupAssistant,
             .customWebView:
            return "UserSetup"
        case .deviceRegister,
             .mainDevice,
             .deviceRegisterSensor,
             .deviceRegisterSensorLight,
             .deviceRegisterSensorBaby,
             .deviceRegisterSensorFinish,
             .deviceRegisterHub,
             .deviceRegisterHubLight,
             .deviceRegisterHubConnecting,
             .deviceRegisterHubWifi,
             .deviceRegisterHubWifiSelect,
             .deviceRegisterHubWifiSelectPassword,
             .deviceRegisterHubFinish,
             .deviceRegisterHubWifiCustom,
             .deviceRegisterHubWifiCustomSecu,
             .deviceRegisterPackageSensorOn,
             .deviceRegisterPackageHubOn,
             .deviceRegisterPackageSensorIntoHub,
             .deviceRegisterPackageSetInfo,
             .deviceRegisterLamp,
             .deviceRegisterLampLight,
             .deviceRegisterLampWifi,
             .deviceRegisterLampWifiSelect,
             .deviceRegisterLampWifiSelectPassword,
             .deviceRegisterLampFinish,
             .deviceRegisterLampWifiCustom,
             .deviceRegisterLampWifiCustomSecu,
             .deviceDiaperAttachGuide:
            return "Device"
        case .shareMemberMain,
             .shareMemberDetail,
             .shareMemberInvite:
            return "ShareMember"
        case .sensorDetail:
            return "Sensor"
        case .hubDetail:
            return "Hub"
        case .lampDetail:
            return "Lamp"
        case .deviceSetupSensorMain,
             .deviceSetupBabyInfoMaster,
             .deviceSetupBabyInfo,
             .deviceSetupSensorFirmware,
             .deviceSetupSensorFirmwareUpdate,
             .deviceSetupSensorConnecting,
             .deviceSetupHubMain,
             .deviceSetupHubDeviceName,
             .deviceSetupHubWifi,
             .deivceSetupHubTemp,
             .deviceSetupHubHum,
             .deivceSetupHubLed,
             .deviceSetupHubFirmware,
             .deviceSetupLampMain,
             .deviceSetupLampDeviceName,
             .deviceSetupLampWifi,
             .deivceSetupLampTemp,
             .deviceSetupLampHum,
             .deivceSetupLampLed,
             .deviceSetupLampFirmware,
             .deviceSetupLampConnecting,
             .deviceSetupWidget:
            return "DeviceSetup"
        }
    }
    
    func resetData() {
        DataManager.instance.m_dataController.device.removeAllDeviceData()
        BleConnectionManager.instance.breakManager()
        BleConnectionLampManager.instance.breakManager()
        TimerManager.instance.breakTimer()
        DataManager.instance.m_userInfo.initInfo()
        DataManager.instance.m_configData.initFlow()
        
        let _currentView = UIManager.instance.rootCurrentView as? InitViewController
        if (_currentView != nil) {
            _currentView?.m_updateTimer?.invalidate()
        }
    }
    
    func refrashData(handler: Action?) {
        BleConnectionManager.instance.update()
        BleConnectionLampManager.instance.update()
        
        if (InitViewController.m_initUserDataFinished) {
            // update userinfo
            DataManager.instance.m_dataController.userInfo.updateUserInfo(handler: { (isSuccess) in
                if (isSuccess) {
                    // update full status
                    DataManager.instance.m_dataController.deviceStatus.updateFullStatus(handler: { (isSuccess) in
                        if (isSuccess) {
                            DataManager.instance.m_dataController.deviceNotiReady.sendReadyInfo()
                            DataManager.instance.m_dataController.deviceNoti.updateForDetailView()
                            DataManager.instance.m_dataController.shareMemberNoti.updateForDetailView()
                        } else {
//                            UIManager.instance.deviceRefrash() // go init
                        }
                        handler?()
                    })
                } else {
//                    UIManager.instance.deviceRefrash() // go init
                    handler?()
                }
            })
        } else {
            handler?()
        }
    }
    
    func accountActiveUserLog() {
        let _send = Send_AccountActiveUser()
        _send.isIndicator = false
        _send.isErrorPopupOn = false
        _send.aid = DataManager.instance.m_userInfo.account_id
        NetworkManager.instance.Request(_send) { (json) -> () in
            let receive = Receive_AccountActiveUser(json)
            switch receive.ecd {
            case .success: break
            default: Debug.print("[⚪️][Init][ERROR] invaild errcod", event: .error)
            }
        }
    }
    
    func checkMaintenance(handler: Action?) {
        let _send = Send_GetMaintenance()
        _send.isResending = true
        _send.isIndicator = false
        _send.isErrorPopupOn = false
        _send.os = Config.OS
        _send.atype = Config.channelOsNum
        _send.logPrintLevel = .warning
        NetworkManager.instance.Request(_send) { (json) -> () in
            let receive = Receive_GetMaintenance(json)
            switch receive.ecd {
            case .success:
                if let _is_enabled = receive.is_enabled {
                    if (_is_enabled == 0) {
                        self.getMaintenance_Notice(handler: handler)
                    } else {
                        handler?()
                    }
                }
            default:
                Debug.print("[⚪️][Init][ERROR] invaild errcod", event: .error)
                handler?()
            }
        }
    }
    
    func getMaintenance_Notice(handler: Action?) {
        let _send = Send_GetMaintenance_Notice()
        _send.isResending = true
        _send.isIndicator = false
        _send.isErrorPopupOn = false
        _send.os = Config.OS
        _send.atype = Config.channelOsNum
        _send.lang = Config.lang
        _send.logPrintLevel = .warning
        NetworkManager.instance.Request(_send) { (json) -> () in
            let receive = Receive_GetMaintenance_Notice(json)
            switch receive.ecd {
            case .success:
                let _title = receive.title ?? ""
                let _from = (receive.from != nil) ? UI_Utility.UTCToLocal(date: receive.from!, fromType: .yyMMdd_HHmmss, toType: .full) : Config.DATE_INIT
                let _fromSlice = UI_Utility.getDateToSliceDateString(date: _from)
                let _fromModify = String(format: "%@-%@ %@:%@", _fromSlice.1.description, _fromSlice.2.description, _fromSlice.3.description, (_fromSlice.4.description.count == 1) ? "0" + _fromSlice.4.description : _fromSlice.4.description)
                
                let _to = (receive.to != nil) ? UI_Utility.UTCToLocal(date: receive.to!, fromType: .yyMMdd_HHmmss, toType: .full) : Config.DATE_INIT
                let _toSlice = UI_Utility.getDateToSliceDateString(date: _to)
                let _toModify = String(format: "%@-%@ %@:%@", _toSlice.1.description, _toSlice.2.description, _toSlice.3.description, (_toSlice.4.description.count == 1) ? "0" + _toSlice.4.description : _toSlice.4.description)
                
                let _contents = "\(receive.contents ?? "")\n(\(_fromModify) ~ \(_toModify))"
                _ = PopupManager.instance.withTitleCustom(title: _title, contents: _contents, confirmType: .ok, okHandler: { () -> () in
                    SystemManager.instance.exitApp()
                })
            default:
                Debug.print("[⚪️][Init][ERROR] invaild errcod", event: .error)
                handler?()
            }
        }
    }
    
    func sessionDisconnect() {
        resetData()
    }
    
    func logOut() {
        resetData()
        _ = UIManager.instance.sceneMove(scene: .initView, animation: .coverVertical, isAnimation: false)
    }
    
    func leave() {
        logOut()
    }
    
    func forceExitApplicationOfError() {
        DataManager.instance.m_coreDataInfo.initInfo()
        exitApp()
    }
    
    func exitApp() {
        exit(0)
    }
    
    func getApplicationStatus() -> UIApplication.State {
        return UIApplication.shared.applicationState
    }
    
    func clearCache() {
        let fileManager = FileManager.default
        let documentsUrl =  FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first! as NSURL // cachesDirectory
        let documentsPath = documentsUrl.path
        
        do {
            if let documentPath = documentsPath
            {
                let fileNames = try fileManager.contentsOfDirectory(atPath: "\(documentPath)")
                for fileName in fileNames {
                    let filePathName = "\(documentPath)/\(fileName)"
                    if (fileName.lowercased().contains("snapshots") && fileName.lowercased().contains(".png")) {
                        Debug.print("snapshots delete file name: \(filePathName)", event: .warning)
                        try fileManager.removeItem(atPath: filePathName)
                    }
                }
            }
        } catch {
            Debug.print("[ERROR] Could not clear clearCache snapshots folder: \(error)", event: .error)
        }
    }
}

