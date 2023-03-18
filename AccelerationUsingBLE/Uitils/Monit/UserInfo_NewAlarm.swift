//
//  UserInfo_DeviceNoti.swift
//  Monit
//
//  Created by 맥 on 2017. 9. 26..
//  Copyright © 2017년 맥. All rights reserved.
//

import Foundation

class NewAlarmInfo {
    var m_id: Int = 0
    var m_aid: Int = 0
    var m_did: Int = 0
    var m_deviceType: Int = 0
    var m_finalItemType: Int = 0
    var m_itemType: Int = 0
    var m_extra: String = ""
    var m_parentItemType: Int = 0
    var m_time: String = ""
    var m_castTimeInfo: CastDateFormat!

    init(id: Int?, aid: Int?, did: Int?, deviceType: Int?, finalItemType: Int, itemType: Int, extra: String? = nil, parentItemType: Int? = nil, time: String? = nil) {
        self.m_id = id ?? 0
        self.m_aid = aid ?? -1
        self.m_did = did ?? -1
        self.m_deviceType = deviceType ?? -1
        self.m_finalItemType = finalItemType
        self.m_itemType = itemType
        self.m_extra = extra ?? ""
        self.m_parentItemType = parentItemType ?? -1
        self.m_time = time ?? Config.DATE_INIT
        self.m_castTimeInfo = CastDateFormat(time: m_time)
    }
}

class UserInfo_NewAlarm {
    var m_lst = [NewAlarmInfo]()
    
    var m_lastTime: Date {
        get {
            var _maxDate: Date?
            
            for item in m_lst {
                //                Debug.print("\(item.m_time) \(item.timeCastDate)")
                if (_maxDate == nil) {
                    _maxDate = item.m_castTimeInfo.m_timeCast
                } else {
                    if (_maxDate! < item.m_castTimeInfo.m_timeCast) {
                        _maxDate = item.m_castTimeInfo.m_timeCast
                    }
                }
            }
            
            if (_maxDate != nil) {
                return _maxDate!
            }
            
            return Config.oldDate7
        }
    }
    
    func addItem(arr: [NewAlarmInfo]?) {
        if (arr == nil) {
            return
        }
        
        for item in arr! {
            m_lst.append(item)
        }
    }
    
    func isEqual(one: NewAlarmInfo, two: NewAlarmInfo) -> Bool {
        if (one.m_aid == two.m_aid && one.m_did == two.m_did && one.m_deviceType == two.m_deviceType && one.m_itemType == two.m_itemType && one.m_finalItemType == two.m_finalItemType) {
            return true
        }
        return false
    }

    func isExist(info: NewAlarmInfo) -> Bool {
        for item in m_lst {
            if (isEqual(one: info, two: item)) {
                return true
            }
        }
        return false
    }
    
    func getExtraByInfo(info: NewAlarmInfo) -> String {
        for item in m_lst {
            if (isEqual(one: info, two: item)) {
                return item.m_extra
            }
        }
        return ""
    }
    
    func updateItem(info: NewAlarmInfo) {
        for item in m_lst {
            if (isEqual(one: info, two: item)) {
                item.m_extra = info.m_extra
                item.m_time = info.m_time
                return
            }
        }
    }
}


