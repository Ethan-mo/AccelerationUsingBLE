//
//  UserInfo_DeviceList.swift
//  Monit
//
//  Created by 맥 on 2017. 11. 6..
//  Copyright © 2017년 맥. All rights reserved.
//

import Foundation

enum DEVICE_LIST_TYPE {
    case none
    case myDevice
    case otherDevice
}

class DataContoller_Device {
    
    var m_sensor = DataController_Sensor()
    var m_hub = DataController_Hub()
    var m_lamp = DataController_Lamp()
    
    var getTotalCount: Int {
        get{
            return DataManager.instance.m_userInfo.shareDevice.deviceTotalCount
        }
    }
    
    var isDataVaildCheck: Bool {
        get {
            var _userInfo = [Int]()
            var _statusInfo = [Int]()
            if let _allInfo = DataManager.instance.m_userInfo.shareDevice.allInfo {
                for item in _allInfo{
                    _userInfo.append(item.did)
                }
            }
            
            if let _sensroStatusInfo = DataManager.instance.m_userInfo.deviceStatus.m_sensorStatus.m_sensor {
                for item in _sensroStatusInfo{
                    _statusInfo.append(item.m_did)
                }
            }
            
            if let _hubStatusInfo = DataManager.instance.m_userInfo.deviceStatus.m_hubStatus.m_hubTypes {
                for item in _hubStatusInfo{
                    _statusInfo.append(item.m_did)
                }
            }
            
            if let _lampStatusInfo = DataManager.instance.m_userInfo.deviceStatus.m_lampStatus.m_hubTypes {
                for item in _lampStatusInfo{
                    _statusInfo.append(item.m_did)
                }
            }
            
            for itemUserInfo in _userInfo {
                var _isFound = false
                for itemStatus in _statusInfo {
                    if (itemUserInfo == itemStatus) {
                        _isFound = true
                        break
                    }
                }
                if (!_isFound) {
                    return false
                }
            }
            
            for itemStatus in _statusInfo {
                var _isFound = false
                for itemUserInfo in _userInfo {
                    if (itemStatus == itemUserInfo) {
                        _isFound = true
                        break
                    }
                }
                if (!_isFound) {
                    return false
                }
            }

            return true
        }
    }
    
    var getTotalUserInfoList: Array<UserInfoDevice>? {
        get {
            var _arr = Array<UserInfoDevice>()
            if let _myGroup = DataManager.instance.m_userInfo.shareDevice.myGroup {
                for item in _myGroup {
                    _arr.append(item)
                }
            }
            
            if let _otherGroup = DataManager.instance.m_userInfo.shareDevice.otherGroup {
                for (_, values) in _otherGroup {
                    for item in values {
                        _arr.append(item)
                    }
                }
            }
            return _arr
        }
    }

    func getStatusByIndex(index: Int) -> DEVICE_LIST_TYPE {
        var _arr = Array<DEVICE_LIST_TYPE>()
        for _ in DataManager.instance.m_userInfo.shareDevice.myGroup! {
            _arr.append(.myDevice)
        }
        for (_, values) in DataManager.instance.m_userInfo.shareDevice.otherGroup! {
            for _ in values {
                _arr.append(.otherDevice)
            }
        }
        return _arr[index]
    }

    func getUserInfoByDid(did: Int, type: Int) -> UserInfoDevice? {
        if let _getTotalUserInfoList = getTotalUserInfoList {
            for item in _getTotalUserInfoList {
                if (item.did == did && item.type == type) {
                    return item
                }
            }
        }
        return nil
    }
    
    func getUserInfoByIndex(index: Int) -> UserInfoDevice? {
        if let _getTotalUserInfoList = getTotalUserInfoList {
            return _getTotalUserInfoList[index]
        }
        return nil
    }
    
    func removeAllDeviceData() {
        DataManager.instance.m_userInfo.shareDevice.myGroup?.removeAll()
        DataManager.instance.m_userInfo.shareDevice.otherGroup?.removeAll()
        DataManager.instance.m_userInfo.deviceStatus.m_sensorStatus.m_sensor?.removeAll()
        DataManager.instance.m_userInfo.deviceStatus.m_hubStatus.m_hubTypes?.removeAll()
        DataManager.instance.m_userInfo.deviceStatus.m_lampStatus.m_hubTypes?.removeAll()
        DataManager.instance.m_userInfo.storeConnectedSensor.m_storeConnectedSensor?.removeAll()
        DataManager.instance.m_userInfo.storeConnectedLamp.m_storeConnectedLamp?.removeAll()
    }
}
