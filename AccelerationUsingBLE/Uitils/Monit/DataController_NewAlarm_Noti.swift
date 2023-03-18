//
//  DataController_NewAlarm_Noti.swift
//  Monit
//
//  Created by 맥 on 2018. 4. 13..
//  Copyright © 2018년 맥. All rights reserved.
//

import Foundation

class DataController_NewAlarm_Noti {
    func initNotiNewAlarm(did: Int, type: Int) {
        let _finalItemType: NEW_ALARM_ITEM_TYPE = DEVICE_TYPE(rawValue: type) == .Sensor ? .sensorNoti : .hubNoti
        let _itemType: NEW_ALARM_ITEM_TYPE = DEVICE_TYPE(rawValue: type) == .Sensor ? .sensorDetail_notiList : .hubDetail_notiList
        let _extra = DataManager.instance.m_userInfo.newAlarm.getExtraByInfo(info: NewAlarmInfo(id: nil, aid: DataManager.instance.m_userInfo.account_id, did: did, deviceType: type, finalItemType: _finalItemType.rawValue, itemType: _itemType.rawValue))
        
        if (_extra == "") {
            let _lastID = DataManager.instance.m_userInfo.deviceNoti.getLastIdByDid(type: type, did: did)
            Debug.print("[NewAlarm] initNotiNewAlarm: did-\(did), type-\(type), lastID-\(_lastID)")
            DataManager.instance.m_dataController.newAlarm.insertOrUpdateItem(aid: DataManager.instance.m_userInfo.account_id, finalItemType: _finalItemType, itemType: [_itemType], did: did, deviceType: DEVICE_TYPE(rawValue: type), extra: _lastID.description, time: UI_Utility.nowUTCDate(type: .yyMMdd_HHmmss))
        }
    }
    
    func isNotiNewAlarm(did: Int, type: Int, noti: Int? = nil) -> Bool {
        let _finalItemType: NEW_ALARM_ITEM_TYPE = DEVICE_TYPE(rawValue: type) == .Sensor ? .sensorNoti : .hubNoti
        let _itemType: NEW_ALARM_ITEM_TYPE = DEVICE_TYPE(rawValue: type) == .Sensor ? .sensorDetail_notiList : .hubDetail_notiList
        let _extra = DataManager.instance.m_userInfo.newAlarm.getExtraByInfo(info: NewAlarmInfo(id: nil, aid: DataManager.instance.m_userInfo.account_id, did: did, deviceType: type, finalItemType: _finalItemType.rawValue, itemType: _itemType.rawValue))
        
//        Debug.print("[NewAlarm] isNewNotiAlarm: did-\(did), type-\(type), extra-\(_extra)")
        
        if (noti != nil) {
            if (Int(_extra) ?? -1 < DataManager.instance.m_userInfo.deviceNoti.getLastIdByDidAndNoti(type: type, did: did, noti: noti!)) {
                return true
            }
        } else {
            if (Int(_extra) ?? -1 < DataManager.instance.m_userInfo.deviceNoti.getLastIdByDid(type: type, did: did)) {
                return true
            }
        }
        return false
    }
    
    func leavedNotiNewAlarmUpdate(type: Int, did: Int) {
        let _finalItemType: NEW_ALARM_ITEM_TYPE = DEVICE_TYPE(rawValue: type) == .Sensor ? .sensorNoti : .hubNoti
        let _itemType: NEW_ALARM_ITEM_TYPE = DEVICE_TYPE(rawValue: type) == .Sensor ? .sensorDetail_notiList : .hubDetail_notiList
        let _lastNumUpdate = DataManager.instance.m_userInfo.deviceNoti.getLastIdByDid(type: type, did: did)
        if (_lastNumUpdate != -1) {
            DataManager.instance.m_dataController.newAlarm.insertOrUpdateItem(aid: DataManager.instance.m_userInfo.account_id, finalItemType: _finalItemType, itemType: [_itemType], did: did, deviceType: DEVICE_TYPE(rawValue: type), extra: _lastNumUpdate.description, time: UI_Utility.nowUTCDate(type: .yyMMdd_HHmmss))
        }
    }
}
