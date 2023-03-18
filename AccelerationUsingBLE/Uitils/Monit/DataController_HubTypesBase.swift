//
//  DataController_HubTypesBase.swift
//  Monit
//
//  Created by john.lee on 07/01/2020.
//  Copyright © 2020 맥. All rights reserved.
//

import Foundation

class BrightInfo {
    var did: Int = 0
    var timeController = TimerController()
}

class BrightController {
    let BRIGHT_CHECK_TIME = 25.0
    let OPEN_UI_TIME = 3.0
    var arrBrightInfo: [BrightInfo] = []
    var deviceType: DEVICE_TYPE = .Hub
    
    init(deviceType: DEVICE_TYPE) {
        self.deviceType = deviceType
    }

    func isRunningTimer(did: Int) -> Bool {
        for item in arrBrightInfo {
            if (item.did == did) {
                if (item.timeController.m_updateTimer != nil) {
                    return true
                }
            }
        }
        return false
    }
    
    func isUseBright(did: Int) -> Bool {
        guard (isRunningTimer(did: did)) else { return false }
        
        for item in arrBrightInfo {
            if (item.did == did) {
                if (item.timeController.m_during > BRIGHT_CHECK_TIME) {
                    return false
                } else {
                    return true
                }
            }
        }
        return false
    }
    
    func resetTimer(did: Int, finishedCallback: Action? = nil) {
        for item in arrBrightInfo {
            if (item.did == did) {
                item.timeController.reset()
                return
            }
        }
        let _info = BrightInfo()
        _info.did = did
        _info.timeController.start(interval: 0.1, finishTime: BRIGHT_CHECK_TIME, updateCallback: nil, finishCallback: finishedCallback)
        arrBrightInfo.append(_info)
    }
    
    func openUI(did: Int, callback: Action?, finishedCallback: Action?) {
        if (isUseBright(did: did)) {
            callback?()
        } else {
            TimerController().start(finishTime: OPEN_UI_TIME, finishCallback: { () -> () in callback?() })
        }
        
        resetTimer(did: did, finishedCallback: finishedCallback)
        sendBrightPacket(did: did, brightType: -1)
    }
    
    func setBrightPow(did: Int, pow: Bool) {
        resetTimer(did: did)
        sendBrightPowPacket(did: did, isPow: pow)
    }
    
    func setBrightLevel(did: Int, level: Int) {
        resetTimer(did: did)
        sendBrightPacket(did: did, brightType: level)
    }
    
    func sendBrightPacket(did: Int, brightType: Int) {
        let _brt: Int? = (brightType == -1 ? nil : brightType)
        let _enc = DataManager.instance.m_dataController.device.getUserInfoByDid(did: did, type: self.deviceType.rawValue)?.enc ?? ""
        
        let _send = Send_SetHubBrightControl()
        _send.aid = DataManager.instance.m_userInfo.account_id
        _send.token = DataManager.instance.m_userInfo.token
        _send.isIndicator = true
        _send.type = deviceType.rawValue
        _send.did = did
        _send.enc = _enc
        _send.brt = _brt
        _send.clr = 200
        NetworkManager.instance.Request(_send) { (json) -> () in
            let receive = Receive_SetHubBrightControl(json)
            switch receive.ecd {
            case .success:
                break
            default:
                Debug.print("[ERROR] invaild errcod", event: .error)
            }
        }
    }
    
    func sendBrightPowPacket(did: Int, isPow: Bool) {
        let _enc = DataManager.instance.m_dataController.device.getUserInfoByDid(did: did, type: self.deviceType.rawValue)?.enc ?? ""

        let _send = Send_SetHubBrightControl()
        _send.aid = DataManager.instance.m_userInfo.account_id
        _send.token = DataManager.instance.m_userInfo.token
        _send.isIndicator = true
        _send.type = deviceType.rawValue
        _send.did = did
        _send.enc = _enc
        _send.clr = 200
        _send.pow = isPow ? 1 : 0
        NetworkManager.instance.Request(_send) { (json) -> () in
            let receive = Receive_SetHubBrightControl(json)
            switch receive.ecd {
            case .success:
                break
            default:
                Debug.print("[ERROR] invaild errcod", event: .error)
            }
        }
    }
    
    func sendOffTimerPacket(did: Int, brightType: Int, hour: Int, min: Int, handler: Action? = nil) {
        let calendar = Calendar.current
        var _addTime = hour != 0 ? calendar.date(byAdding: .hour, value: hour, to: Date()) : Date()
        _addTime = min != 0 ? calendar.date(byAdding: .minute, value: min, to: _addTime ?? Date()) : _addTime
        if (hour == 0 && min == 0 || brightType == -1) {
            _addTime = Config.DATE_INIT.ToPacketTime()
        }
        
        let _enc = DataManager.instance.m_dataController.device.getUserInfoByDid(did: did, type: self.deviceType.rawValue)?.enc ?? ""

        let _send = Send_SetHubBrightControl()
        _send.aid = DataManager.instance.m_userInfo.account_id
        _send.token = DataManager.instance.m_userInfo.token
        _send.isIndicator = true
        _send.type = deviceType.rawValue
        _send.did = did
        _send.enc = _enc
        _send.offptime = _addTime?.ToPacketTime()
        NetworkManager.instance.Request(_send) { (json) -> () in
            let receive = Receive_SetHubBrightControl(json)
            switch receive.ecd {
            case .success:
                handler?()
                break
            default:
                Debug.print("[ERROR] invaild errcod", event: .error)
            }
        }
    }
    
//    func sendBrightPacket(did: Int, brightType: Int) {
//        let _brt: Int? = (brightType == -1 ? nil : brightType)
//        let _enc = DataManager.instance.m_dataController.device.getUserInfoByDid(did: did, type: self.deviceType.rawValue)?.enc ?? ""
//        let _send = Send_SetDeviceStatusForHubTypes()
//        _send.aid = DataManager.instance.m_userInfo.account_id
//        _send.token = DataManager.instance.m_userInfo.token
//        _send.isIndicator = true
//        let _info = SendHubTypesStatusInfo(type: self.deviceType.rawValue, did: did, enc: _enc, brt: _brt, clr: 200, pow: nil, onptime: nil, offptime: nil)
//        _send.data.append(_info)
//        NetworkManager.instance.Request(_send) { (json) -> () in
//            let receive = Receive_SetDeviceStatusForHubTypes(json)
//            switch receive.ecd {
//            case .success:
//                break
//            default:
//                Debug.print("[ERROR] invaild errcod", event: .error)
//            }
//        }
//    }
//
//    func sendBrightPowPacket(did: Int, isPow: Bool) {
//        let _enc = DataManager.instance.m_dataController.device.getUserInfoByDid(did: did, type: self.deviceType.rawValue)?.enc ?? ""
//        let _send = Send_SetDeviceStatusForHubTypes()
//        _send.aid = DataManager.instance.m_userInfo.account_id
//        _send.token = DataManager.instance.m_userInfo.token
//        _send.isIndicator = true
//        let _info = SendHubTypesStatusInfo(type: self.deviceType.rawValue, did: did, enc: _enc, brt: nil, clr: 200, pow: isPow ? 1 : 0, onptime: nil, offptime: nil)
//        _send.data.append(_info)
//        NetworkManager.instance.Request(_send) { (json) -> () in
//            let receive = Receive_SetDeviceStatusForHubTypes(json)
//            switch receive.ecd {
//            case .success:
//                break
//            default:
//                Debug.print("[ERROR] invaild errcod", event: .error)
//            }
//        }
//    }
//
//    func sendOffTimerPacket(did: Int, brightType: Int, hour: Int, min: Int, handler: Action? = nil) {
//        let calendar = Calendar.current
//        var _addTime = hour != 0 ? calendar.date(byAdding: .hour, value: hour, to: Date()) : Date()
//        _addTime = min != 0 ? calendar.date(byAdding: .minute, value: min, to: _addTime ?? Date()) : _addTime
//        if (hour == 0 && min == 0 || brightType == -1) {
//            _addTime = Config.DATE_INIT.ToPacketTime()
//        }
//
//        let _enc = DataManager.instance.m_dataController.device.getUserInfoByDid(did: did, type: self.deviceType.rawValue)?.enc ?? ""
//        let _send = Send_SetDeviceStatusForHubTypes()
//        _send.aid = DataManager.instance.m_userInfo.account_id
//        _send.token = DataManager.instance.m_userInfo.token
//        _send.isIndicator = true
//        let _info = SendHubTypesStatusInfo(type: self.deviceType.rawValue, did: did, enc: _enc, brt: nil, clr: nil, pow: nil, onptime: nil, offptime: _addTime?.ToPacketTime())
//        _send.data.append(_info)
//        NetworkManager.instance.Request(_send) { (json) -> () in
//            let receive = Receive_SetDeviceStatusForHubTypes(json)
//            switch receive.ecd {
//            case .success:
//                handler?()
//                break
//            default:
//                Debug.print("[ERROR] invaild errcod", event: .error)
//            }
//        }
//    }
    
    func getTimerTime(did: Int, handler: ActionResultString? = nil) {
        let _enc = DataManager.instance.m_dataController.device.getUserInfoByDid(did: did, type: self.deviceType.rawValue)?.enc ?? ""
        let send = Send_GetHubTimerInfo()
        send.aid = DataManager.instance.m_userInfo.account_id
        send.token = DataManager.instance.m_userInfo.token
        send.isIndicator = false
        send.type = deviceType.rawValue
        send.did = did
        send.enc = _enc
        NetworkManager.instance.Request(send) { (json) -> () in
            let receive = Receive_GetHubTimerInfo(json)
            switch receive.ecd {
            case .success:
                handler?(receive.offptime ?? Config.DATE_INIT)
            default:
                Debug.print("[ERROR] getHubTimer invaild errcod", event: .error)
            }
        }
    }
}

class DataController_HubTypesBase {
    var m_brightController: BrightController { get { return BrightController(deviceType: .Hub) } }
    
    func isConnect(type: DEVICE_LIST_TYPE, did: Int) -> Bool {
        return false
    }
}
