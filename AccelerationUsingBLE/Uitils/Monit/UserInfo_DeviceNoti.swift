//
//  UserInfo_DeviceNoti.swift
//  Monit
//
//  Created by 맥 on 2017. 9. 26..
//  Copyright © 2017년 맥. All rights reserved.
//

import Foundation

class CastDateFormatDeviceNoti: CastDateFormat {
    var m_lNotiTime: String! // "a h:mm"
    
    override init (time: String) {
        super.init(time: time)
        m_dateFormatter.dateFormat = "a h:mm"
        self.m_lNotiTime = m_dateFormatter.string(from: m_lTimeCast)
        
//        Debug.print("time: \(time), m_lDate: \(m_lDate), m_lTime: \(m_lNotiTime)")
    }
}

class DeviceNotiInfo {
    var m_id: Int = 0
    var m_nid: Int = 0
    var m_type: Int = 0
    var m_did: Int = 0
    var m_noti: Int = 0
    private var m_extra: String = ""
    var Extra: String {
        get {
            return m_extra
        }
        set {
            m_extra = newValue
            if (m_extra.count == 13) {
                let _tmpDate = DateFormatter()
                _tmpDate.dateFormat = DATE_TYPE.yyMMdd_HHmmss.rawValue
                if (_tmpDate.date(from: m_extra) != nil) {
                    m_castExtraTimeInfo = CastDateFormatDeviceNoti(time: m_extra)
                }
            }
        }
    }
    var m_castExtraTimeInfo: CastDateFormatDeviceNoti? // filter extra date type
    
    var m_extra2: String = ""
    var m_extra3: String = ""
    var m_extra4: String = ""
    var m_extra5: String = ""
    var m_memo: String = ""
    
    private var m_time: String = ""
    var Time: String {
        get {
            return m_time
        }
        set {
            m_time = newValue
            m_castTimeInfo = CastDateFormatDeviceNoti(time: newValue)
        }
    }
    var m_castTimeInfo: CastDateFormatDeviceNoti!
    
    private var m_finishTime: String = ""
    var FinishTime: String {
        get {
            return m_finishTime
        }
        set {
            m_finishTime = newValue
            m_castFinishTimeInfo = CastDateFormatDeviceNoti(time: newValue)
        }
    }
    var m_castFinishTimeInfo: CastDateFormatDeviceNoti!

    var notiType: DEVICE_NOTI_TYPE? {
        get{
            return DEVICE_NOTI_TYPE(rawValue: m_noti)
        }
    }

    init(id: Int, nid: Int, type: Int, did: Int, noti: Int, extra: String, extra2: String, extra3: String, extra4: String, extra5: String, memo: String, time: String, finishTime: String) {
        self.m_id = id
        self.m_nid = nid
        self.m_type = type
        self.m_did = did
        self.m_noti = noti
        self.Extra = extra
        self.m_extra2 = extra2
        self.m_extra3 = extra3
        self.m_extra4 = extra4
        self.m_extra5 = extra5
        self.m_memo = memo
        self.Time = time
        self.FinishTime = finishTime
    }
}

class UserInfo_DeviceNoti {
    var m_deviceNoti = [DeviceNotiInfo]()
    
    var m_firstTime: Date? {
        get {
            guard m_deviceNoti.count != 0 else {
                return nil
            }
            
            var _minDate: Date?
            
            for item in m_deviceNoti {
                //                Debug.print("\(item.m_time) \(item.timeCastDate)")
                if (_minDate == nil) {
                    _minDate = item.m_castTimeInfo.m_timeCast
                } else {
                    if (_minDate! > item.m_castTimeInfo.m_timeCast) {
                        _minDate = item.m_castTimeInfo.m_timeCast
                    }
                }
            }
            
            return _minDate!
        }
    }
    
    var m_lastTime: Date {
        get {
            var _maxDate: Date?
            
            for item in m_deviceNoti {
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
                if (_maxDate! < Date()) {
                    return _maxDate!
                } else {
                    return Calendar.current.date(byAdding: .hour, value: -1, to: Date()) ?? Date()
                }
            }
            
            return Config.oldDate3
        }
    }
    
    var isNidUpdate: Bool {
        get {
            for item in m_deviceNoti {
                if (item.m_nid == 0) {
                    return true
                }
            }
            return false
        }
    }
    
    func isExist(item: DeviceNotiInfo) -> Bool {
        for _item in m_deviceNoti {
            if (_item.m_nid == item.m_nid) {
                return true
            }
        }
        return false
    }
    
    func getLastTimeByDid(type: Int, did: Int) -> Date {
        var _maxDate: Date?
        
        for item in m_deviceNoti {
            if (item.m_did == did && item.m_type == type) {
                if (_maxDate == nil) {
                    _maxDate = item.m_castTimeInfo.m_timeCast
                } else {
                    if (_maxDate! < item.m_castTimeInfo.m_timeCast) {
                        _maxDate = item.m_castTimeInfo.m_timeCast
                    }
                }
            }
        }
        
        if (_maxDate != nil) {
            return _maxDate!
        }
        
        return Config.oldDate3
    }
    
    func getLastIdByDid(type: Int, did: Int) -> Int {
        var _maxId: Int?
        
        for item in m_deviceNoti {
            if (item.m_did == did && item.m_type == type) {
                if (_maxId == nil) {
                    _maxId = item.m_id
                } else {
                    if (_maxId! < item.m_id) {
                        _maxId = item.m_id
                    }
                }
            }
        }
        
        if (_maxId != nil) {
            return _maxId!
        }
        
        return -1
    }
    
    func getLastIdByDidAndNoti(type: Int, did: Int, noti: Int) -> Int {
        var _maxId: Int?
        
        for item in m_deviceNoti {
            if (item.m_did == did && item.m_type == type && item.m_noti == noti) {
                if (_maxId == nil) {
                    _maxId = item.m_id
                } else {
                    if (_maxId! < item.m_id) {
                        _maxId = item.m_id
                    }
                }
            }
        }
        
        if (_maxId != nil) {
            return _maxId!
        }
        
        return -1
    }
    
    func getTodayNotiCount(type: Int, did: Int) -> Int {
        var _retValue = 0
        let _nowDateTime = UI_Utility.nowLocalDate(type: .full)
        let _utcDate = UI_Utility.localToUTC(date: _nowDateTime)
        let _nowDate = UI_Utility.convertDateStringToString(_utcDate, fromType: .full, toType: .yyMMdd)
        for item in m_deviceNoti {
            if (item.m_type == type && item.m_did == did) {
                let index = item.Time.index(item.Time.startIndex, offsetBy: 6)
                let _date = item.Time[..<index]
                if (_date == _nowDate) {
                    if (item.notiType != nil) {
                        switch item.notiType! {
                        case .pee_detected,
                             .poo_detected,
                             .fart_detected,
                             .voc_warning,
                             .abnormal_detected,
                             .high_humidity,
                             .low_humidity,
                             .high_temperature,
                             .low_temperature,
                             .low_battery:
                            _retValue += 1
                        default: break
                        }
                    }
                }
            }
        }
        return _retValue
    }
    
    func getLastNotiByType(type: Int, did: Int, notiType: DEVICE_NOTI_TYPE, isOrderbyId: Bool = false) -> DeviceNotiInfo? {
        var _retInfo: DeviceNotiInfo?
        for item in m_deviceNoti {
            if (item.notiType != nil) {
                if (item.m_did == did && item.m_type == type && item.notiType == notiType) {
                    if (_retInfo == nil) {
                        _retInfo = item
                    } else {
                        if (isOrderbyId) {
                            if (_retInfo!.m_nid < item.m_nid) {
                                _retInfo = item
                            }
                        } else {
                            if (_retInfo!.m_castTimeInfo.m_timeCast < item.m_castTimeInfo.m_timeCast) {
                                _retInfo = item
                            }
                        }
                    }
                }
            }
        }
        return _retInfo
    }
    
    func getNotiByNid(nid: Int) -> DeviceNotiInfo? {
        for item in m_deviceNoti {
            if (item.m_nid == nid) {
                return item
            }
        }
        return nil
    }
    
    func setNotiUpdateByNid(nid: Int, noti: Int, extra: String, extra2: String, extra3: String, extra4: String, extra5: String, memo: String, time: String, finishTime: String) {
        if let _info = getNotiByNid(nid: nid) {
            _info.m_noti = noti
            _info.Extra = extra
            _info.m_extra2 = extra2
            _info.m_extra3 = extra3
            _info.m_extra4 = extra4
            _info.m_extra5 = extra5
            _info.m_memo = memo
            _info.Time = time
            _info.FinishTime = finishTime
        }
    }
    
    func addNoti(arr: [DeviceNotiInfo]?) {
        if (arr == nil) {
            return
        }

        for item in arr! {
            if (!(isExist(item: item))) {
                if let _type = DEVICE_NOTI_TYPE(rawValue: item.m_noti) {
                    switch _type  {
                    default: m_deviceNoti.append(item)
                    }
                }
            }
        }

        /*
        // delete item before 3days
        let _filterDate = m_deviceNoti!.filter({ (v: DeviceNotiInfo) -> (Bool) in
            if (v.timeCastDate < Config.oldDate) { return true }
            return false
        })

        for item in _filterDate {
            if let index = m_deviceNoti!.index(where: { $0 === item }) {
                m_deviceNoti!.remove(at: index)
            }
        }
         */
    }
    
    func deleteItemByNid(nid: Int) {
        var _delList = Array<DeviceNotiInfo>()
        for item in m_deviceNoti {
            if (item.m_nid == nid) {
                _delList.append(item)
            }
        }
        
        for item in _delList {
            if let index = m_deviceNoti.index(where: { $0 === item }) {
                m_deviceNoti.remove(at: index)
            }
        }
        
        DataManager.instance.m_coreDataInfo.storeDeviceNoti.deleteItemsByNid(nid: nid)
    }
    
    func deleteItemByDid(type: Int, did: Int) {
        var _delList = Array<DeviceNotiInfo>()
        for item in m_deviceNoti {
            if (item.m_type == type && item.m_did == did) {
                _delList.append(item)
            }
        }
        
        for item in _delList {
            if let index = m_deviceNoti.index(where: { $0 === item }) {
                m_deviceNoti.remove(at: index)
            }
        }

        DataManager.instance.m_coreDataInfo.storeDeviceNoti.deleteItemsByDid(type: type, did: did)
    }
    
    func deleteItemById(id: Int) {
        var _delList = Array<DeviceNotiInfo>()
        for item in m_deviceNoti {
            if (item.m_id == id) {
                _delList.append(item)
            }
        }
        
        for item in _delList {
            if let index = m_deviceNoti.index(where: { $0 === item }) {
                m_deviceNoti.remove(at: index)
            }
        }
        
        DataManager.instance.m_coreDataInfo.storeDeviceNoti.deleteItemsById(id: id)
    }
}
