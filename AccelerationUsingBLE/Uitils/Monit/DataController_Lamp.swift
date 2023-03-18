//
//  SensorTotalList.swift
//  Monit
//
//  Created by 맥 on 2017. 11. 7..
//  Copyright © 2017년 맥. All rights reserved.
//

import Foundation

class DataController_Lamp: DataController_HubTypesBase {
    override var m_brightController: BrightController {
        get {
            return BrightController(deviceType: .Lamp)
        }
    }
    
    override func isConnect(type: DEVICE_LIST_TYPE, did: Int) -> Bool {
        if (Utility.currentReachabilityStatus == .notReachable) {
            return false
        }
        
        if let _status = DataManager.instance.m_userInfo.deviceStatus.m_lampStatus.getInfoByDeviceId(did: did) {
            if (_status.isConnect) {
                return true
            }
        }
        return false
    }
    
    func isWifiConnect(type: DEVICE_LIST_TYPE, did: Int) -> Bool {
        if (Utility.currentReachabilityStatus == .notReachable) {
            return false
        }
        
        if let _status = DataManager.instance.m_userInfo.deviceStatus.m_lampStatus.getInfoByDeviceId(did: did) {
            if (_status.isWifiConnect) {
                return true
            }
        }
        return false
    }
    
    func removeLampByDevice(did: Int) {
        if let _info = DataManager.instance.m_userInfo.deviceStatus.m_lampStatus.m_hubTypes {
            for (i, item) in _info.enumerated() {
                if (item.m_did == did) {
                    DataManager.instance.m_userInfo.deviceStatus.m_lampStatus.m_hubTypes?.remove(at: i)
                    break
                }
            }
        }

        if let _info = DataManager.instance.m_userInfo.shareDevice.myGroup {
            for (i, item) in _info.enumerated() {
                if (item.did == did && item.type == DEVICE_TYPE.Lamp.rawValue) {
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
                    if (item.did == did && item.type == DEVICE_TYPE.Lamp.rawValue) {
                        _otherGroupKey = key
                        _otherGroupValue = values
                        break
                    }
                }
            }
        }
        if let _info = _otherGroupValue {
            for (i, item) in _info.enumerated() {
                if (item.did == did && item.type == DEVICE_TYPE.Lamp.rawValue) {
                    _otherGroupValue?.remove(at: i)
                    break
                }
            }
            DataManager.instance.m_userInfo.shareDevice.otherGroup?.updateValue(_otherGroupValue!, forKey: _otherGroupKey)
        }
    }
}
