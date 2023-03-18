//
//  UserInfo_DeviceNoti.swift
//  Monit
//
//  Created by 맥 on 2017. 9. 26..
//  Copyright © 2017년 맥. All rights reserved.
//

import Foundation

class CastDateFormatHubGraph: CastDateFormat {
    var m_lNotiTime: String! // "h:mm a"
    
    override init (time: String) {
        super.init()
        super.setInit(time: time)
        
        setDefaultTime()
    }
    
    init (originTime: String, addIndex: Int) {
        super.init()
        m_dateFormatter.dateFormat = DATE_TYPE.yyMMdd_HHmmss.rawValue
        let _originTime = m_dateFormatter.date(from: originTime)!
        let _addTime = _originTime.adding(minutes: addIndex * 10)

        m_dateFormatter.dateFormat = DATE_TYPE.yyMMdd_HHmmss.rawValue
        let _time = m_dateFormatter.string(from: _addTime)
        super.setInit(time: _time)
        
        setDefaultTime()
    }
    
    func setDefaultTime() {
        m_dateFormatter.dateFormat = "h:mm a"
        self.m_lNotiTime = m_dateFormatter.string(from: m_lTimeCast)
        
//        Debug.print("time: \(time), m_lDate: \(m_lDate), m_lTime: \(m_lNotiTime)")
    }
}

class HubGraphInfo {
    var m_id: Int = 0
    var m_did: Int = 0
    var m_time: String = ""
    var m_tem: Int = 0
    var m_hum: Int = 0
    var m_voc: Int = 0
    var m_castTimeInfo: CastDateFormatHubGraph!
    var m_statusInfo: HubStatusInfo?
    var m_xAxisValue: Double!

    init(id: Int, did: Int, time: String?, tem: Int, hum: Int, voc: Int, originTime: String? = nil, addIndex: Int? = nil) {
        self.m_id = id
        self.m_did = did
        
        self.m_tem = tem
        self.m_hum = hum
        self.m_voc = voc

        if (time != nil) {
            self.m_castTimeInfo = CastDateFormatHubGraph(time: time!)
        } else {
            self.m_castTimeInfo = CastDateFormatHubGraph(originTime: originTime!, addIndex: addIndex!)
        }
        self.m_time = self.m_castTimeInfo.m_time

        self.m_xAxisValue = setXAxisValue()
        
        if let _status = DataManager.instance.m_userInfo.deviceStatus.m_hubStatus.getInfoByDeviceId(did: m_did) {
            self.m_statusInfo = HubStatusInfo(did: m_did, name: "", power: 0, bright: 0, color: 0, attached: 1, temp: m_tem, hum: m_hum, voc: m_voc, ap: "", apse: "", tempmax: _status.m_tempmax, tempmin: _status.m_tempmin, hummax: _status.m_hummax, hummin: _status.m_hummin, offt: "", onnt: "", con: 0, offptime: "", onptime: "")
        }
    }
    
    func setXAxisValue() -> Double {
        let date = self.m_castTimeInfo.m_lTimeCast
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(identifier: "UTC")!
        let hour = calendar.component(.hour, from: date!)
        let minutes = calendar.component(.minute, from: date!)
//        Debug.print("\(self.m_lTimeCast) \(hour), \(minutes)")
        return Double(hour * 60 + minutes)
    }
}

class UserInfo_HubGraph {
    var m_lst = [HubGraphInfo]()
    
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
    
    func isExist(item: HubGraphInfo) -> Bool {
        for _item in m_lst {
            if (_item.m_time == item.m_time
                && _item.m_did == item.m_did) {
                return true
            }
        }
        return false
    }
    
    func getLastTimeByDid(did: Int) -> Date {
        var _maxDate: Date?
        
        for item in m_lst {
            if (item.m_did == did) {
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
        
        return Config.oldDate7
    }

    func addItem(arr: [HubGraphInfo]?) {
        if (arr == nil) {
            return
        }
        
        for item in arr! {
            if (!(isExist(item: item))) {
                m_lst.append(item)
            }
        }
    }
    
    func deleteItemByDid(did: Int) {
        var _delList = Array<HubGraphInfo>()
        for item in m_lst {
            if (item.m_did == did) {
                _delList.append(item)
            }
        }
        
        for item in _delList {
            if let index = m_lst.index(where: { $0 === item }) {
                m_lst.remove(at: index)
            }
        }
        
        DataManager.instance.m_coreDataInfo.storeHubGraph.deleteItemsByDid(did: did)
    }
    
    func deleteItemById(id: Int) {
        var _delList = Array<HubGraphInfo>()
        for item in m_lst {
            if (item.m_id == id) {
                _delList.append(item)
            }
        }
        
        for item in _delList {
            if let index = m_lst.index(where: { $0 === item }) {
                m_lst.remove(at: index)
            }
        }
        
        DataManager.instance.m_coreDataInfo.storeHubGraph.deleteItemsById(id: id)
    }
}

