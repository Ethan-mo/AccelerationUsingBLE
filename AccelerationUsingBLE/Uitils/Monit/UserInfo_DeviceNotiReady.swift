//
//  UserInfo_DeviceNotiReady.swift
//  Monit
//
//  Created by john.lee on 2019. 1. 2..
//  Copyright © 2019년 맥. All rights reserved.
//

import Foundation

class DeviceNotiReadyInfo {
    var m_id: Int = 0
    var m_type: Int = 0
    var m_did: Int = 0
    var m_noti: Int = 0
    var m_time: String = "" // timestamp

    init(id: Int, type: Int, did: Int, noti: Int, time: String) {
        self.m_id = id
        self.m_type = type
        self.m_did = did
        self.m_noti = noti
        self.m_time = time
    }
    
    var notiType: DEVICE_NOTI_TYPE? {
        get{
            return DEVICE_NOTI_TYPE(rawValue: m_noti)
        }
    }
}

class UserInfo_DeviceNotiReady {
    var m_deviceNotiReady = [DeviceNotiReadyInfo]()
    
    var isSending: Bool {
        get {
            return m_deviceNotiReady.count > 0
        }
    }
    
    func isExist(item: DeviceNotiReadyInfo) -> Bool {
        for _item in m_deviceNotiReady {
            if (_item.m_time == item.m_time
                && _item.m_did == item.m_did
                && _item.m_type == item.m_type
                && _item.m_noti == item.m_noti) {
                return true
            }
        }
        return false
    }
    
    func addNoti(arr: [DeviceNotiReadyInfo]?) {
        if (arr == nil) {
            return
        }
        
        for item in arr! {
            if (!(isExist(item: item))) {
                m_deviceNotiReady.append(item)
            }
        }
    }
    
    func deleteItemById(id: Int) {
        var _delList = Array<DeviceNotiReadyInfo>()
        for item in m_deviceNotiReady {
            if (item.m_id == id) {
                _delList.append(item)
            }
        }
        
        for item in _delList {
            if let index = m_deviceNotiReady.index(where: { $0 === item }) {
                m_deviceNotiReady.remove(at: index)
            }
        }
    }
}
