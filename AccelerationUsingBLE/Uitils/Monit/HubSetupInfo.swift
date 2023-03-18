//
//  HubSetupInfo.swift
//  Monit
//
//  Created by 맥 on 2017. 10. 2..
//  Copyright © 2017년 맥. All rights reserved.
//

class HubSetupInfo {
    var m_cid: Int = 0
    var m_did: Int = 0
    var m_alarm_master: Bool = true
    var m_alarm_temp: Bool = true
    var m_alarm_hum: Bool = true
    var m_alarm_poo: Bool = true
    
    init(cid: Int, did: Int, alarm_master: Bool, alarm_temp: Bool, alarm_hum: Bool, alarm_poo: Bool) {
        self.m_cid = cid
        self.m_did = did
        self.m_alarm_master = alarm_master
        self.m_alarm_temp = alarm_temp
        self.m_alarm_hum = alarm_hum
        self.m_alarm_poo = alarm_poo
    }
}

class UserInfo_HubSetup {
    var m_hubSetup: Array<HubSetupInfo>?
    
    func updateItem(info: HubSetupInfo?) {
        if (info == nil) {
            return
        } else {
            Debug.print("UserInfo_SensorSetup > updateItem > info is null")
        }
        
        var _i = -1
        for (i, item) in m_hubSetup!.enumerated() {
            if (item.m_cid == info!.m_cid && item.m_cid == info!.m_did) {
                _i = i
            }
        }
        if (_i != -1) {
            m_hubSetup?[_i] = info!
        } else {
            Debug.print("UserInfo_HubSetup > updateItem > not found")
        }
        
        DataManager.instance.m_coreDataInfo.hubSetup.updateItem(HubSetupInfo: info!)
    }
    
    func getInfo(cid: Int, did: Int) -> HubSetupInfo? {
        for item in m_hubSetup! {
            if (item.m_cid == cid && item.m_did == did) {
                return item
            }
        }
        return nil
    }
    
    func noneInputData() {
        // my group
        let _arrMyGroup = DataManager.instance.m_userInfo.shareDevice.myGroup!
        let _arrHubMyGroup = _arrMyGroup.filter({ (v: UserInfoDevice) -> (Bool) in
            if (DEVICE_TYPE(rawValue: v.type) == .Hub)  { return true }
            return false
        })
        
        for itemDevice in _arrHubMyGroup {
            var _isFound = false
            for itemSetup in m_hubSetup! {
                if (itemDevice.cid == itemSetup.m_cid && itemDevice.did == itemSetup.m_did) {
                    _isFound = true
                }
            }
            if (!_isFound) {
                let _addItem = HubSetupInfo(cid: itemDevice.cid, did: itemDevice.did, alarm_master: true, alarm_temp: true, alarm_hum: true, alarm_poo: true)
                m_hubSetup?.append(_addItem)
            }
        }
        
        // other group
        let _otherGroup = DataManager.instance.m_userInfo.shareDevice.otherGroup
        for (_, values) in _otherGroup! {
            
            let _arrOtherGroup = values
            let _arrHubOtherGroup = _arrOtherGroup.filter({ (v: UserInfoDevice) -> (Bool) in
                if (DEVICE_TYPE(rawValue: v.type) == .Hub)  { return true }
                return false
            })
            
            for itemDevice in _arrHubOtherGroup {
                var _isFound = false
                for itemSetup in m_hubSetup! {
                    if (itemDevice.cid == itemSetup.m_cid && itemDevice.did == itemSetup.m_did) {
                        _isFound = true
                    }
                }
                if (!_isFound) {
                    let _addItem = HubSetupInfo(cid: itemDevice.cid, did: itemDevice.did, alarm_master: true, alarm_temp: true, alarm_hum: true, alarm_poo: true)
                    m_hubSetup?.append(_addItem)
                }
            }
        }
    }
    
}
