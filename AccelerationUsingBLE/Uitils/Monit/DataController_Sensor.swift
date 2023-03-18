//
//  SensorTotalList.swift
//  Monit
//
//  Created by 맥 on 2017. 11. 7..
//  Copyright © 2017년 맥. All rights reserved.
//

import Foundation

class DataController_Sensor {

    var isFoundDisconnectSensor: Bool {
        get {
            if let _myGroup = DataManager.instance.m_userInfo.shareDevice.myGroup {
                for item in _myGroup {
                    if (DEVICE_TYPE(rawValue: item.type)! == .Sensor) {
                        if (!(isSensorConnect(type: .myDevice, did: item.did))) {
                            return true
                        }
                    }
                }
            }
            if let _dicOtherGroup = DataManager.instance.m_userInfo.shareDevice.otherGroup {
                for (_, v) in _dicOtherGroup {
                    for item in v {
                        if (DEVICE_TYPE(rawValue: item.type)! == .Sensor) {
                            if (!(isSensorConnect(type: .myDevice, did: item.did))) {
                                return true
                            }
                        }
                    }
                }
            }
            return false
        }
    }

    func isSensorConnect(type: DEVICE_LIST_TYPE, did: Int) -> Bool {
        switch type {
        case .myDevice, .otherDevice:
            let _bleInfo = DataManager.instance.m_userInfo.connectSensor.getSensorByDeviceId(deviceId: did)
            if (_bleInfo != nil) {
                return true
            } else {
                if (Utility.currentReachabilityStatus != .notReachable) {
                    if let _status = DataManager.instance.m_userInfo.deviceStatus.m_sensorStatus.getInfoByDeviceId(did: did) {
                        if (_status.con == 1) {
                            return true
                        }
                    }
                }
            }
        default: break
        }
        return false
    }
    
    func isAvailableAutoPollingNotiFirmware(did: Int) -> Bool {
        if let _userInfo =  DataManager.instance.m_dataController.device.getUserInfoByDid(did: did, type: DEVICE_TYPE.Sensor.rawValue) {
            return Utility.isAvailableVersion(availableVersion: Config.SENSOR_FIRMWARE_LIMIT_AUTO_POLLING_VERSION, currentVersion: _userInfo.fwv)
        }
        return false
    }
    
    func updateFirmware(did: Int, value: String) {
        if let _userInfo =  DataManager.instance.m_dataController.device.getUserInfoByDid(did: did, type: DEVICE_TYPE.Sensor.rawValue) {
            _userInfo.fwv = value
        }
    }
    
    func updateStatusAll(did: Int, value: SensorStatusInfo?) {
        if (value == nil) {
            return
        }
        
        if let _status = DataManager.instance.m_userInfo.deviceStatus.m_sensorStatus.getInfoByDeviceId(did: did) {
            _status.m_operation = value!.m_operation
            _status.m_battery = value!.m_battery
            _status.m_temp = value!.m_temp
            _status.m_hum = value!.m_hum
            _status.m_movement = value!.m_movement
            _status.m_voc = value!.m_voc
        }
    }
    
    func updateBattery(did: Int, value: Int) {
        var _isSend = false
        
        if let _status = DataManager.instance.m_userInfo.deviceStatus.m_sensorStatus.getInfoByDeviceId(did: did) {
            if (_status.m_battery != value) {
                _status.m_battery = value
                _isSend = true
            }
        }
        
        if (_isSend) {
            UIManager.instance.currentUIReload()
            if let _userInfo = DataManager.instance.m_dataController.device.getUserInfoByDid(did: did, type: DEVICE_TYPE.Sensor.rawValue) {
                Debug.print("Request Sensor battery Packet")
                let send = Send_SetDeviceStatusForSensor()
                send.aid = DataManager.instance.m_userInfo.account_id
                send.token = DataManager.instance.m_userInfo.token
                send.isIndicator = false
                let _info = SendSensorStatusInfo(type: DEVICE_TYPE.Sensor.rawValue, did: did, enc: _userInfo.enc, bat: value, mov: nil, dps: nil, opr: nil, tem: nil, hum: nil, voc: nil, fwv: nil, con: nil)
                send.data.append(_info)
                NetworkManager.instance.Request(send) { (json) -> () in
                    let receive = Receive_SetDeviceStatusForSensor(json)
                    switch receive.ecd {
                    case .success:
                        break
                    default:
                        Debug.print("[ERROR] invaild errcod", event: .error)
                    }
                }
            }
        }
    }
    
    // status변경시 공통적으로 쓰임
    // dps는 1.3.5 이상에서는 autopolling 방식으로 사용, mov, opr은 기존 방식을 상요 한다.
    func updateStatus(did: Int, dps: Int, mov: Int, opr: Int, timeStamp: Int64, dTimeStamp: Int64? = nil, isAvailableAutoPollingNotiFirmware: Bool = false) {
        if (!isAvailableAutoPollingNotiFirmware) {
            SetLocalNoti(did: did, changeOpr: opr, changeDps: dps)
            setLocalDpsChange(did: did, changeDps: dps)
        }
        sendStatusPacket(did: did, dps: dps, mov: mov, opr: opr, timeStamp: timeStamp, dTimeStamp: dTimeStamp, isAvailableAutoPollingNotiFirmware: isAvailableAutoPollingNotiFirmware)
    }
    
    // status변경시 공통적으로 쓰이며, 1.3.5이상의 센서에서는 패킷을 보내는 형식이 다르므로 해당 함수를 사용한다.
    func updateStatusForAutoPolling(did: Int, dps: Int, mov: Int, opr: Int, timeStamp: Int64, dTimeStamp: Int64? = nil) {
        SetLocalNoti(did: did, changeOpr: opr, changeDps: dps)
        setLocalDpsChange(did: did, changeDps: dps)
    }
    
    func SetLocalNoti(did: Int, changeOpr: Int, changeDps: Int) {
        let _isPollingNoti = isAvailableAutoPollingNotiFirmware(did: did) // 센서 1.3.5이상에서는 로컬 방귀 알림을 사용한다.
        
        if (SENSOR_OPERATION(rawValue: changeOpr) != .hubCharging
            && SENSOR_OPERATION(rawValue: changeOpr) != .hubFinishedCharge
            && SENSOR_OPERATION(rawValue: changeOpr) != .hubNoCharge
            && SENSOR_OPERATION(rawValue: changeOpr) != .hubChargeError) { // 허브 연결 상태가 아님
            
            var _isLocalNoti = false
            if let _status = DataManager.instance.m_userInfo.deviceStatus.m_sensorStatus.getInfoByDeviceId(did: did) {
                if let _localDps = SENSOR_DIAPER_STATUS(rawValue: _status.m_diaperstatus == -1 ? 0 : _status.m_diaperstatus) {
                    if let _changeDps = SENSOR_DIAPER_STATUS(rawValue: changeDps) {
                        switch (_localDps) {
                        case .normal:
                            switch _changeDps {
                            case .normal: break
                            case .pee: _isLocalNoti = true
                            case .poo: _isLocalNoti = true
                            case .maxvoc, .hold: _isLocalNoti = true
                            case .fart:
                                if (_isPollingNoti) { // else server control
                                    _isLocalNoti = true
                                }
                            break
                            case .detectDiaperChanged: break // server control
//                                if (DataManager.instance.m_userInfo.configData.isBeta) {
//                                    _isLocalNoti = true
//                                }
                            case .attachSensor: break
                            }
                            break
                        case .pee:
                            switch _changeDps {
                            case .normal: break
                            case .pee: _isLocalNoti = true
                            case .poo: _isLocalNoti = true
                            case .maxvoc, .hold: _isLocalNoti = true
                            case .fart:
                                if (_isPollingNoti) { // else server control
                                    _isLocalNoti = true
                                }
                            break
                            case .detectDiaperChanged: break // server control
//                                if (DataManager.instance.m_userInfo.configData.isBeta) {
//                                    _isLocalNoti = true
//                                }
                            case .attachSensor: break
                            }
                            break
                        case .poo:
                            switch _changeDps {
                            case .normal: break
                            case .pee: _isLocalNoti = true
                            case .poo: _isLocalNoti = true
                            case .maxvoc, .hold: _isLocalNoti = true
                            case .fart:
                                if (_isPollingNoti) { // else server control
                                    _isLocalNoti = true
                                }
                            break
                            case .detectDiaperChanged: break // server control
//                                if (DataManager.instance.m_userInfo.configData.isBeta) {
//                                    _isLocalNoti = true
//                                }
                            case .attachSensor: break
                            }
                            break
                        case .maxvoc,
                             .hold:
                            switch _changeDps {
                            case .normal: break
                            case .pee: _isLocalNoti = true
                            case .poo: _isLocalNoti = true
                            case .maxvoc, .hold: _isLocalNoti = true
                            case .fart:
                                if (_isPollingNoti) { // else server control
                                    _isLocalNoti = true
                                }
                                break
                            case .detectDiaperChanged: break // server control
                                //                                if (DataManager.instance.m_userInfo.configData.isBeta) {
                                //                                    _isLocalNoti = true
                            //                                }
                            case .attachSensor: break
                            }
                            break
                        case .fart:
                            switch _changeDps {
                            case .normal: break
                            case .pee: _isLocalNoti = true
                            case .poo: _isLocalNoti = true
                            case .maxvoc, .hold: _isLocalNoti = true
                            case .fart:
                                if (_isPollingNoti) { // else server control
                                    _isLocalNoti = true
                                }
                            break
                            case .detectDiaperChanged: break // server control
//                                if (DataManager.instance.m_userInfo.configData.isBeta) {
//                                    _isLocalNoti = true
//                                }
                            case .attachSensor: break
                            }
                            break
                        case .detectDiaperChanged: break // 로컬 상태는 6,7 일 수 없음
                        case .attachSensor: break  // 로컬 상태는 6,7 일 수 없음
                        }
                    }
                }
            }
            
            if (_isLocalNoti) {
                // after noti item
//                let _item = DeviceNotiInfo(id: 0, nid: 0, type: DEVICE_TYPE.Sensor.rawValue, did: did, noti: changeDps == 4 ? 3 : changeDps, time: UIManager.instance.nowUTCDate(type: .yyMMdd_HHmmss), extra: "")
//                DataManager.instance.m_dataController.deviceNoti.addItem(item: _item)
                NotificationManager.instance.sensorLocalNoti(did: did, dps: changeDps)
            }
        }
    }
    
    func setLocalDpsChange(did: Int, changeDps: Int) {
        if let _status = DataManager.instance.m_userInfo.deviceStatus.m_sensorStatus.getInfoByDeviceId(did: did) {
            var _isLocalStatus = false
            if let _localDps = SENSOR_DIAPER_STATUS(rawValue: _status.m_diaperstatus == -1 ? 0 : _status.m_diaperstatus) {
                if let _changeDps = SENSOR_DIAPER_STATUS(rawValue: changeDps) {
                    switch (_localDps) {
                    case .normal:
                        switch _changeDps {
                        case .normal: break
                        case .pee: _isLocalStatus = true
                        case .poo: _isLocalStatus = true
                        case .maxvoc, .hold: _isLocalStatus = true
                        case .fart: _isLocalStatus = true
                        case .detectDiaperChanged: break
                        case .attachSensor: break
                        }
                        break
                    case .pee:
                        switch _changeDps {
                        case .normal: break
                        case .pee: break
                        case .poo: _isLocalStatus = true
                        case .maxvoc, .hold: _isLocalStatus = true
                        case .fart: _isLocalStatus = true
                        case .detectDiaperChanged: break
                        case .attachSensor: break
                        }
                        break
                    case .poo:
                        switch _changeDps {
                        case .normal: break
                        case .pee: break
                        case .poo: break
                        case .maxvoc, .hold: _isLocalStatus = true
                        case .fart: break
                        case .detectDiaperChanged: break
                        case .attachSensor: break
                        }
                        break
                    case .maxvoc,
                         .hold:
                        switch _changeDps {
                        case .normal: break
                        case .pee: break
                        case .poo: break
                        case .maxvoc, .hold: break
                        case .fart: break
                        case .detectDiaperChanged: break
                        case .attachSensor: break
                        }
                        break
                    case .fart:
                        switch _changeDps {
                        case .normal: break
                        case .pee: _isLocalStatus = true
                        case .poo: _isLocalStatus = true
                        case .maxvoc, .hold: _isLocalStatus = true
                        case .fart: break
                        case .detectDiaperChanged: break
                        case .attachSensor: break
                        }
                        break
                    case .detectDiaperChanged: break // 로컬 상태는 6,7 일 수 없음
                    case .attachSensor: break  // 로컬 상태는 6,7 일 수 없음
                    }
                }
            }
            if (_isLocalStatus) {
                _status.m_diaperstatus = changeDps
            }
        }
    }
    
    func sendStatusPacket(did: Int, dps: Int, mov: Int, opr: Int, timeStamp: Int64, dTimeStamp: Int64?, isAvailableAutoPollingNotiFirmware: Bool = false) {
        var _isSend = false
        var _isChangeDps = false
        var _isChangeMov = false
        var _isChangeOpr = false
        
        if let _status = DataManager.instance.m_userInfo.deviceStatus.m_sensorStatus.getInfoByDeviceId(did: did) {
            if (SENSOR_OPERATION(rawValue: opr) == .cableChargeError || SENSOR_OPERATION(rawValue: opr) == .hubChargeError) {
                _ = PopupManager.instance.onlyContents(contentsKey: "dialog_contents_sensor_charging_error", confirmType: .ok, existKey: "hubChargeError")
            }
            
            if (!isAvailableAutoPollingNotiFirmware) {
                if (dps != SENSOR_DIAPER_STATUS.normal.rawValue) { // 들어온 값이 0이 아닌경우 전부다 보낸다.
                    _isChangeDps = true
                    _isSend = true
                }
            }

            if (_status.m_movement != mov) {
                _status.m_movement = mov
                _isChangeMov = true
                _isSend = true
            }
            
            if (_status.m_operation != opr) {
                _status.m_operation = opr
                _isChangeOpr = true
                _isSend = true
            }
        }
        
        if (_isSend) {
            if (dps == SENSOR_DIAPER_STATUS.fart.rawValue) {
                if let _sensor = DataManager.instance.m_userInfo.connectSensor.getSensorByDeviceId(deviceId: did) {
                    _sensor.controller?.m_packetRequest?.getVoc(completion: {
                        (value) in
                        if let _value = value as? Int {
                            let _voc = _value
                            self.sendDeviceStatus(did: did, dps: dps, mov: mov, opr: opr, isChangeDps: _isChangeDps, isChangeMov: _isChangeMov, isChangeOpr: _isChangeOpr, timeStamp: timeStamp, dTimeStamp: dTimeStamp, voc: _voc)
                        }
                    })
                }
            } else {
                sendDeviceStatus(did: did, dps: dps, mov: mov, opr: opr, isChangeDps: _isChangeDps, isChangeMov: _isChangeMov, isChangeOpr: _isChangeOpr, timeStamp: timeStamp, dTimeStamp: dTimeStamp)
            }
        }
    }
    
    func sendDeviceStatus(did: Int, dps: Int, mov: Int, opr: Int, isChangeDps:Bool, isChangeMov: Bool, isChangeOpr: Bool, timeStamp: Int64, dTimeStamp: Int64?, voc: Int? = nil, handler: ActionResultBool? = nil) {

        UIManager.instance.currentUIReload()
        if let _userInfo = DataManager.instance.m_dataController.device.getUserInfoByDid(did: did, type: DEVICE_TYPE.Sensor.rawValue) {
            Debug.print("Request Sensor Status Packet", event: .warning)
            let send = Send_SetDeviceStatusForSensor()
            send.aid = DataManager.instance.m_userInfo.account_id
            send.token = DataManager.instance.m_userInfo.token
            send.isIndicator = false
            send.isResending = true
            let _info = SendSensorStatusInfo(type: DEVICE_TYPE.Sensor.rawValue, did: did, enc: _userInfo.enc, bat: nil, mov: isChangeMov ? mov : nil, dps: isChangeDps ? dps : nil, opr: isChangeOpr ? opr : nil, tem: nil, hum: nil, voc: voc, fwv: nil, con: nil)
            _info.time = timeStamp
            _info.dtime = dTimeStamp
            send.data.append(_info)
            NetworkManager.instance.Request(send) { (json) -> () in
                let receive = Receive_SetDeviceStatusForSensor(json)
                switch receive.ecd {
                case .success:
                    DataManager.instance.m_dataController.deviceNoti.updateForDetailView()
                    handler?(true)
                default:
                    Debug.print("[ERROR] invaild errcod", event: .error)
                    if (isChangeDps) {
                        DataManager.instance.m_dataController.deviceNotiReady.addItems(items: [DeviceNotiReadyInfo(id: 0, type: DEVICE_TYPE.Sensor.rawValue, did: did, noti: dps, time: (timeStamp - (dTimeStamp ?? 0)).description)])
                    }
                    handler?(false)
                }
            }
        }
    }
    
    func updateBabyInfo(did: Int, name: String, bday: String, sex: Int) {
        if let _status = DataManager.instance.m_userInfo.deviceStatus.m_sensorStatus.getInfoByDeviceId(did: did) {
            _status.m_name = name
            _status.m_bday = bday
            _status.m_sex = sex
        }
    }
    
    func initDiaper(did: Int) {
        if let _status = DataManager.instance.m_userInfo.deviceStatus.m_sensorStatus.getInfoByDeviceId(did: did) {
            _status.m_diaperstatus = SENSOR_DIAPER_STATUS.normal.rawValue
        }
    }
    
    func removeSensorByDevice(did: Int) {
        if let _info = DataManager.instance.m_userInfo.deviceStatus.m_sensorStatus.m_sensor {
            for (i, item) in _info.enumerated() {
                if (item.m_did == did) {
                    DataManager.instance.m_userInfo.deviceStatus.m_sensorStatus.m_sensor?.remove(at: i)
                    break
                }
            }
        }

        if let _info = DataManager.instance.m_userInfo.shareDevice.myGroup {
            for (i, item) in _info.enumerated() {
                if (item.did == did && item.type == DEVICE_TYPE.Sensor.rawValue) {
                    DataManager.instance.m_userInfo.shareDevice.myGroup!.remove(at: i)
                    break
                }
            }
        }

        var _otherGroupKey = 0
        var _otherGroupValue: Array<UserInfoDevice>?
        if let _infoDic = DataManager.instance.m_userInfo.shareDevice.otherGroup {
            for (key, values) in _infoDic {
                for (_, item) in values.enumerated() {
                    if (item.did == did && item.type == DEVICE_TYPE.Sensor.rawValue) {
                        _otherGroupKey = key
                        _otherGroupValue = values
                        break
                    }
                }
            }
        }
        if let _info = _otherGroupValue {
            for (i, item) in _info.enumerated() {
                if (item.did == did && item.type == DEVICE_TYPE.Sensor.rawValue) {
                    _otherGroupValue?.remove(at: i)
                    break
                }
            }
            DataManager.instance.m_userInfo.shareDevice.otherGroup?.updateValue(_otherGroupValue!, forKey: _otherGroupKey)
        }
    }
}
