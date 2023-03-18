//
//  SensorSetupInfo.swift
//  Monit
//
//  Created by 맥 on 2017. 9. 29..
//  Copyright © 2017년 맥. All rights reserved.
//

import Foundation

class SensorSetupInfo {
    var m_cid: Int = 0
    var m_did: Int = 0
    var m_alarm_master: Bool = true
    var m_alarm_connect: Bool = true
    var m_alarm_poo: Bool = true
    
    init(cid: Int, did: Int, alarm_master: Bool, alarm_connect: Bool, alarm_poo: Bool) {
        self.m_cid = cid
        self.m_did = did
        self.m_alarm_master = alarm_master
        self.m_alarm_connect = alarm_connect
        self.m_alarm_poo = alarm_poo
    }
}

class UserInfo_SensorSetup {
    var m_sensorSetup: Array<SensorSetupInfo>?
    
    func updateItem(info: SensorSetupInfo?) {
        if (info == nil) {
            return
        } else {
            Debug.print("UserInfo_SensorSetup > updateItem > info is null")
        }
        
        var _i = -1
        for (i, item) in m_sensorSetup!.enumerated() {
            if (item.m_cid == info!.m_cid && item.m_cid == info!.m_did) {
                _i = i
            }
        }
        if (_i != -1) {
            m_sensorSetup?[_i] = info!
        } else {
            Debug.print("UserInfo_SensorSetup > updateItem > not found")
        }
        
        DataManager.instance.m_coreDataInfo.sensorSetup.updateItem(SensorSetupInfo: info!)
    }
    
    func getInfo(cid: Int, did: Int) -> SensorSetupInfo? {
        for item in m_sensorSetup! {
            if (item.m_cid == cid && item.m_did == did) {
                return item
            }
        }
        return nil
    }
    
    func noneInputData() {
        // my group
        let _arrMyGroup = DataManager.instance.m_userInfo.shareDevice.myGroup!
        let _arrSensorMyGroup = _arrMyGroup.filter({ (v: UserInfoDevice) -> (Bool) in
            if (DEVICE_TYPE(rawValue: v.type) == .Sensor)  { return true }
            return false
        })
        
        for itemDevice in _arrSensorMyGroup {
            var _isFound = false
            for itemSetup in m_sensorSetup! {
                if (itemDevice.cid == itemSetup.m_cid && itemDevice.did == itemSetup.m_did) {
                    _isFound = true
                }
            }
            if (!_isFound) {
                let _addItem = SensorSetupInfo(cid: itemDevice.cid, did: itemDevice.did, alarm_master: true, alarm_connect: true, alarm_poo: true)
                m_sensorSetup?.append(_addItem)
            }
        }
        
        // other group
        let _otherGroup = DataManager.instance.m_userInfo.shareDevice.otherGroup
        for (_, values) in _otherGroup! {
            
            let _arrOtherGroup = values
            let _arrSensorOtherGroup = _arrOtherGroup.filter({ (v: UserInfoDevice) -> (Bool) in
                if (DEVICE_TYPE(rawValue: v.type) == .Sensor)  { return true }
                return false
            })
            
            for itemDevice in _arrSensorOtherGroup {
                var _isFound = false
                for itemSetup in m_sensorSetup! {
                    if (itemDevice.cid == itemSetup.m_cid && itemDevice.did == itemSetup.m_did) {
                        _isFound = true
                    }
                }
                if (!_isFound) {
                    let _addItem = SensorSetupInfo(cid: itemDevice.cid, did: itemDevice.did, alarm_master: true, alarm_connect: true, alarm_poo: true)
                    m_sensorSetup?.append(_addItem)
                }
            }
        }
    }
}
