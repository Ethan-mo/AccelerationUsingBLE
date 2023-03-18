//
//  UserInfo_ShareInfo.swift
//  Monit
//
//  Created by 맥 on 2017. 9. 8..
//  Copyright © 2017년 맥. All rights reserved.
//

import UIKit
import CoreData

class UserInfoDevice {
    var cid : Int = 0
    var did : Int = 0
    var type : Int = 0
    var name : String = ""
    var srl : String = ""
    var enc : String = ""
    var fwv : String = ""
    var mac : String = ""
    var adv : String = ""
    var alm : String = ""
    var arrAlm = Dictionary<ALRAM_TYPE, Bool>()
    
    init(cid: Int, did: Int, type: Int, name: String, srl : String, fwv: String, mac: String, alm: String, adv: String) {
        self.cid = cid
        self.did = did
        self.type = type
        self.name = name
        self.srl = srl
        if (srl.count > 4) {
            self.enc = String(srl[srl.index(srl.endIndex, offsetBy: -4)...])
        }
        self.fwv = fwv
        self.mac = mac
        if (type == DEVICE_TYPE.Lamp.rawValue) {
            self.adv = adv
        } else {
            setAdvName(mac: mac)
        }
        
        self.alm = alm
        setAlarm(alm: alm)
    }

    func setAdvName(mac: String) {
        if (type == DEVICE_TYPE.Sensor.rawValue) {
            if (mac.count == 17) {
                var start = mac.index(mac.startIndex, offsetBy: 15)
                var end = mac.index(mac.endIndex, offsetBy: 0)
                var range = start..<end
                let _1 = String(mac[range])
                
                start = mac.index(mac.startIndex, offsetBy: 12)
                end = mac.index(mac.endIndex, offsetBy: -3)
                range = start..<end
                let _2 = String(mac[range])
                
                start = mac.index(mac.startIndex, offsetBy: 9)
                end = mac.index(mac.endIndex, offsetBy: -6)
                range = start..<end
                let _3 = String(mac[range])
                
                if (type == DEVICE_TYPE.Sensor.rawValue) {
                    self.adv = "\(Config.SENSOR_ADV_NAME)(\(_1)\(_2)\(_3))"
                }
                //            Debug.print(self.adv)
            }
        }
    }
    
    func setAlarm(alm: String) {
        let _arr = alm.split{$0 == "/"}.map(String.init)
        for item in _arr {
            let _arrDetail = item.split{$0 == ","}.map(String.init)
            if (_arrDetail.count == 2) {
                if ALRAM_TYPE(rawValue: Int(_arrDetail[0])!) != nil {
                    arrAlm.updateValue(Int(_arrDetail[1])! == 1, forKey: ALRAM_TYPE(rawValue: Int(_arrDetail[0])!) ?? ALRAM_TYPE.none)
                }
            }
        }
    }
    
    // .all의 영향을 받는다.
    func isAlarmStatus(almType: ALRAM_TYPE) -> Bool {
        if let _allAlm = arrAlm[.all] {
            if (!_allAlm) {
                return false
            }
        }
        
        if let _alm = arrAlm[almType] {
            return _alm
        }

        return true
    }
    
    func isAlarmStatusSpecific(almType: ALRAM_TYPE) -> Bool {
        if let _alm = arrAlm[almType] {
            return _alm
        }
        
        return true
    }
    
    func changeAlarm(almType: ALRAM_TYPE, isOn: Bool) {
        if (arrAlm[almType] != nil) {
            arrAlm[almType] = isOn
        } else {
            arrAlm.updateValue(isOn, forKey: almType)
        }
        var _newVal = ""
        var _isFirst = true
        for (key, value) in arrAlm {
            let _value = value == true ? 1 : 0
            if (_isFirst) {
                _isFirst = false
                _newVal += "\(key.rawValue),\(_value)"
            } else {
                _newVal += "/" + "\(key.rawValue),\(_value)"
            }
        }
        alm = _newVal
    }
}

class UserInfo_ShareDevice {
    
    var myGroup: Array<UserInfoDevice>?
    var otherGroup : Dictionary<Int, Array<UserInfoDevice>>?
    
    var deviceTotalCount: Int {
        var _returnValue = 0
        _returnValue += myGroup?.count ?? 0
        if let _otherGroup = otherGroup {
            for (_, values) in _otherGroup {
                _returnValue += values.count
            }
        }
        return _returnValue
    }
    
    func sort() {
        myGroup = myGroup?.sorted (by: {$0.type < $1.type})
        var _dic = Dictionary<Int, Array<UserInfoDevice>>()
        for (key, values) in otherGroup! {
            _dic.updateValue(values.sorted (by: {$0.type < $1.type}), forKey: key)
        }
        otherGroup = _dic
    }
    
    var allInfo: Array<UserInfoDevice>? {
        get {
            var _allUserInfo = Array<UserInfoDevice>()
            if myGroup != nil {
                for item in myGroup! {
                    _allUserInfo.append(item)
                }
            }
            if otherGroup != nil {
                for (_, items) in otherGroup! {
                    for item in items {
                        _allUserInfo.append(item)
                    }
                }
            }
            return _allUserInfo
        }
    }

    func leaveGroup(cloudId: Int) {
        otherGroup?.removeValue(forKey: cloudId)
    }
    
    func getMyDeviceByDeviceIdAndType(did: Int, type: Int) -> UserInfoDevice? {
        for item in myGroup! {
            if (item.did == did && item.type == type) {
                return item
            }
        }
        return nil
    }
    
    func getOtherDeviceByDeviceIdAndType(did: Int, type: Int) -> UserInfoDevice? {
        for (_, values) in otherGroup! {
            for item in values {
                if (item.did == did && item.type == type) {
                    return item
                }
            }
        }
        return nil
    }
    
    func getAllDeviceByDeviceIdAndType(did: Int, type: Int) -> UserInfoDevice? {
        if let _myDevice = getMyDeviceByDeviceIdAndType(did: did, type: type) {
            return _myDevice
        }
        if let _otherDevice = getOtherDeviceByDeviceIdAndType(did: did, type: type) {
            return _otherDevice
        }
        return nil
    }
    
    func getMySensorCount() -> Int {
        var _cnt = 0
        for item in myGroup! {
            if (DEVICE_TYPE(rawValue: item.type) == .Sensor) {
                _cnt += 1
            }
        }
        return _cnt
    }
    
    func getMySensorInfo() -> [UserInfoDevice] {
        var _returnItem = Array<UserInfoDevice>()
        for item in myGroup! {
            if (DEVICE_TYPE(rawValue: item.type) == .Sensor) {
                _returnItem.append(item)
            }
        }
        return _returnItem
    }
    
    func isAlarmStatus(did: Int, type: Int, almType: ALRAM_TYPE) -> Bool? {
        if let _myDevice = getMyDeviceByDeviceIdAndType(did: did, type: type) {
            return _myDevice.isAlarmStatus(almType: almType)
        }
        if let _otherDevice = getOtherDeviceByDeviceIdAndType(did: did, type: type) {
            return _otherDevice.isAlarmStatus(almType: almType)
        }
        return nil
    }
    
    func isAlarmStatusSpecific(did: Int, type: Int, almType: ALRAM_TYPE) -> Bool? {
        if let _myDevice = getMyDeviceByDeviceIdAndType(did: did, type: type) {
            return _myDevice.isAlarmStatusSpecific(almType: almType)
        }
        if let _otherDevice = getOtherDeviceByDeviceIdAndType(did: did, type: type) {
            return _otherDevice.isAlarmStatusSpecific(almType: almType)
        }
        return nil
    }
    
    func changeAlarm(did: Int, type: Int, almType: ALRAM_TYPE, isOn: Bool) {
        if let _myDevice = getMyDeviceByDeviceIdAndType(did: did, type: type) {
            _myDevice.changeAlarm(almType: almType, isOn: isOn)
        }
        if let _otherDevice = getOtherDeviceByDeviceIdAndType(did: did, type: type) {
            _otherDevice.changeAlarm(almType: almType, isOn: isOn)
        }
    }
}
