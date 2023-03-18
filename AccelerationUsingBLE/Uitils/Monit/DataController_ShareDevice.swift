//
//  DataController_ShareDevice.swift
//  Monit
//
//  Created by 맥 on 2017. 9. 21..
//  Copyright © 2017년 맥. All rights reserved.
//

import Foundation

class DataController_ShareDevice {
    
    func setInit(device: Array<UserInfoDevice>?) {
        saveLocal(arrData: device)
        DataManager.instance.m_userInfo.shareDevice.sort()
        initNewAlarm()
    }
    
    func saveLocal(arrData: Array<UserInfoDevice>?) {
        let _arrData = arrData
        
        // myGroup
        var _myGroup = [UserInfoDevice]()
        var _testCount = 1
        for item in _arrData! {
            if (item.cid == DataManager.instance.m_userInfo.account_id)
            {
                let _member = UserInfoDevice(cid: item.cid, did: item.did, type: item.type, name: item.name, srl: item.srl, fwv: item.fwv, mac: item.mac, alm: item.alm, adv: item.adv)
                _testCount += 1
                _myGroup.append(_member)
            }
        }
        DataManager.instance.m_userInfo.shareDevice.myGroup = _myGroup
        
        // otherGroup
        var _otherGroup = Dictionary<Int, Array<UserInfoDevice>>()
        var _groupList = [Int]()
        for item in _arrData! {
            if (item.cid != DataManager.instance.m_userInfo.account_id) {
                if (!_groupList.contains(item.cid)) {
                    _groupList.append(item.cid)
                    _otherGroup.updateValue(Array<UserInfoDevice>(), forKey: item.cid)
                }
            }
        }
        
        for item in _arrData! {
            if (item.cid != DataManager.instance.m_userInfo.account_id)
            {
                let _member = UserInfoDevice(cid: item.cid, did: item.did, type: item.type, name: item.name, srl: item.srl, fwv: item.fwv, mac: item.mac, alm: item.alm, adv: item.adv)
                _otherGroup[item.cid]?.append(_member)
            }
        }
        DataManager.instance.m_userInfo.shareDevice.otherGroup = _otherGroup
    }
    
    func loadLocal() -> Array<UserInfoDevice>? {
        var _arrData = [UserInfoDevice]()
        
        // my group
        for item in DataManager.instance.m_userInfo.shareDevice.myGroup! {
            _arrData.append(item)
        }
        // other group
        for (_, values) in DataManager.instance.m_userInfo.shareDevice.otherGroup! {
            for item in values {
                _arrData.append(item)
            }
        }
        return _arrData
    }
    
    func changeAlarm(did: Int, type: Int, almType: ALRAM_TYPE, isOn: Bool) {
        DataManager.instance.m_userInfo.shareDevice.changeAlarm(did: did, type: type, almType: almType, isOn: isOn)
        let send = Send_SetDeviceAlarmStatus()
        send.aid = DataManager.instance.m_userInfo.account_id
        send.token = DataManager.instance.m_userInfo.token
        send.type = type
        send.did = did
        send.alm = "\(almType.rawValue),\(isOn ? 1 : 0)"
        NetworkManager.instance.Request(send) { (json) -> () in
            let receive = Receive_SetDeviceAlarmStatus(json)
            switch receive.ecd {
            case .success: break
            default: Debug.print("[ERROR] invaild errcod", event: .error)
            }
        }
    }
    
    func changeAlarmCommon(did: Int, type: Int, almType: ALRAM_TYPE, isOn: Bool) {
        DataManager.instance.m_userInfo.shareDevice.changeAlarm(did: did, type: type, almType: almType, isOn: isOn)
        let send = Send_SetDeviceAlarmStatusCommon()
        send.aid = DataManager.instance.m_userInfo.account_id
        send.token = DataManager.instance.m_userInfo.token
        send.type = type
        send.did = did
        send.alm = "\(almType.rawValue),\(isOn ? 1 : 0)"
        NetworkManager.instance.Request(send) { (json) -> () in
            let receive = Receive_SetDeviceAlarmStatusCommon(json)
            switch receive.ecd {
            case .success: break
            default: Debug.print("[ERROR] invaild errcod", event: .error)
            }
        }
    }
    
    func initNewAlarm() {
        DataManager.instance.m_dataController.newAlarm.hubFirmware.initInfo()
        DataManager.instance.m_dataController.newAlarm.lampFirmware.initInfo()
    }
}
