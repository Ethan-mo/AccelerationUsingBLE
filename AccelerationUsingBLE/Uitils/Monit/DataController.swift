//
//  DataController.swift
//  Monit
//
//  Created by 맥 on 2017. 9. 21..
//  Copyright © 2017년 맥. All rights reserved.
//

import Foundation

class DataController {
    var userInfo = DataController_UserInfo()
    var deviceNoti = DataController_DeviceNoti()
    var deviceNotiReady = DataController_DeviceNotiReady()
    var storeConnectedSensor = DataController_StoreConnectedSensor()
    var storeConnectedLamp = DataController_StoreConnectedLamp()
    var deviceStatus = DataController_DeviceStatus()
    var shareMemberNoti = DataController_ShareMemberNoti()
    var hubGraph = DataController_HubGraph()
    var lampGraph = DataController_LampGraph()
    var newAlarm = DataController_NewAlarm()
    var device = DataContoller_Device()
    var widget = DataController_Widget()
    var sensorMovGraph = DataController_SensorMovGraph()
    var sensorVocGraph = DataController_SensorVocGraph()
    var diaperSensingLog = DataController_DiaperSensingLog()
    
    var m_heartbeat = [Int]()
    func heartbeatSensor(did: Int) {
        if (m_heartbeat.contains(did)) {
            sendHeartbeat()
            m_heartbeat.removeAll()
            return
        }
        
        m_heartbeat.append(did)
        
        var _removeItem = [Int]()
        for itemHeartbeat in m_heartbeat {
            var _isFound = false
            for itemConnect in DataManager.instance.m_userInfo.connectSensor.successConnectSensor {
                if (itemHeartbeat == itemConnect.m_did) {
                    _isFound = true
                    break
                }
            }
            if (!_isFound) {
                _removeItem.append(itemHeartbeat)
            }
        }
        for item in _removeItem {
            if let index = m_heartbeat.index(where: { $0 == item }) {
                m_heartbeat.remove(at: index)
            }
        }
        
        if (m_heartbeat.count == DataManager.instance.m_userInfo.connectSensor.successConnectSensor.count) {
            sendHeartbeat()
            m_heartbeat.removeAll()
            return
        }
    }
    
    func sendHeartbeat() {
        let send = Send_SetDeviceStatusForSensor()
        send.isErrorPopupOn = false
        send.aid = DataManager.instance.m_userInfo.account_id
        send.token = DataManager.instance.m_userInfo.token
        send.isIndicator = false
        send.logPrintLevel = .dev
        for item in m_heartbeat {
            if let _deviceInfo = DataManager.instance.m_dataController.device.getUserInfoByDid(did: item, type: DEVICE_TYPE.Sensor.rawValue) {
                let _infoData = SendSensorStatusInfo(type: DEVICE_TYPE.Sensor.rawValue, did: _deviceInfo.did, enc: _deviceInfo.enc, bat: nil, mov: nil, dps: nil, opr: nil, tem: nil, hum: nil, voc: nil, fwv: nil, con: nil)
                send.data.append(_infoData)
            }
        }
        NetworkManager.instance.Request(send) { (json) -> () in
            let receive = Receive_SetDeviceStatusForSensor(json)
            switch receive.ecd {
            case .success: break
            default: Debug.print("[ERROR] invaild errcod", event: .error)
            }
        }
    }
}
