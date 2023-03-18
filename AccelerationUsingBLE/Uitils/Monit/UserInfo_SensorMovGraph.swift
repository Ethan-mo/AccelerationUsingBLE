//
//  UserInfo_DeviceNoti.swift
//  Monit
//
//  Created by 맥 on 2017. 9. 26..
//  Copyright © 2017년 맥. All rights reserved.
//

import Foundation

class CastDateFormatSensorMovGraph: CastDateFormat {
    var m_lNotiTime: String! // "h:mm a"
    
    override init (time: String) {
        super.init()
        super.setInit(time: time)
        
        setDefaultTime()
    }

    func setDefaultTime() {
        m_dateFormatter.dateFormat = "h:mm a"
        self.m_lNotiTime = m_dateFormatter.string(from: m_lTimeCast)
        
//        Debug.print("time: \(time), m_lDate: \(m_lDate), m_lTime: \(m_lNotiTime)")
    }
}

// 서버에서 받은 패킷당 정보로 보관한다.
class StoreSensorMovGraphInfo {
    var m_id: Int = 0
    var m_did: Int = 0
    var m_time: String = ""
    var m_mov: String = ""
    var m_cnt: Int = 0
    var m_castTimeInfo: CastDateFormatSensorMovGraph!
    var m_edTimeInfo: CastDateFormatSensorMovGraph!
    var m_descryptMov: String = ""
    
    init (id: Int, did: Int, time: String, mov: String, cnt: Int) {
        self.m_id = id
        self.m_did = did
        self.m_mov = mov
        self.m_cnt = cnt
        self.m_castTimeInfo = CastDateFormatSensorMovGraph(time: time)
        let _edTime = UI_Utility.convertDateToString(m_castTimeInfo.m_timeCast.adding(second: cnt * 10), type: .yyMMdd_HHmmss)
        self.m_edTimeInfo = CastDateFormatSensorMovGraph(time: _edTime)
        self.m_time = self.m_castTimeInfo.m_time
        self.m_descryptMov = descryptMov(mov: mov)
    }
    
    func descryptMov(mov: String) -> String {
        var _sb = ""
        if (m_mov.count > 0) {
            var _beforeChar = ""
            var _isDescrypt = false
            var _loopCount = ""
            for item in m_mov {
                if (item == ")") {
                    _isDescrypt = false
                    _sb += String(repeating: _beforeChar, count: (Int(_loopCount)! - 1))
                    continue
                }
                
                if (_isDescrypt) {
                    _loopCount += String(item)
                    continue
                }
                
                if (item == "(") {
                    _loopCount = ""
                    _isDescrypt = true
                    continue
                }
                
                _beforeChar = String(item)
                _sb += String(item)
            }
        }
        return _sb
    }
}

class SensorMovGraphInfo {
    var m_did: Int = 0
    var m_mov: Int = 0
    var m_xAxisValue: Double = 0.0
    var m_isHorizontal: Bool = false
    var m_timestamp: Int = 0
    
    init(did: Int, mov: Int, xAxisValue: Double, isHorizontal: Bool, timestamp: Int) {
        self.m_did = did
        self.m_mov = mov
        self.m_xAxisValue = xAxisValue
        self.m_isHorizontal = isHorizontal
        self.m_timestamp = timestamp
    }
    
    var lTimeSelectString: String {
        get {
            let _time = Date(timeIntervalSince1970: TimeInterval(m_timestamp))
            let m_dateFormatter = DateFormatter()
            m_dateFormatter.dateFormat = "h:mm a"
            return m_dateFormatter.string(from: _time)
        }
    }
    
    var movLevel: SENSOR_MOVEMENT {
        get {
            return SensorStatusInfo.GetMovementLevel(mov: self.m_mov)
        }
    }
}

class UserInfo_SensorMovGraph {
    var m_lst = [StoreSensorMovGraphInfo]()
    
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
    
    func isExist(item: StoreSensorMovGraphInfo) -> Bool {
        for _item in m_lst {
            if (_item.m_time == item.m_time
                && _item.m_did == item.m_did) {
                return true
            }
        }
        return false
    }
    
    func getLastTimeByDid(did: Int) -> Date {
        var _info: StoreSensorMovGraphInfo?
        
        for item in m_lst {
            if (item.m_did == did) {
                if (_info == nil) {
                    _info = item
                } else {
                    if (_info!.m_castTimeInfo.m_timeCast < item.m_castTimeInfo.m_timeCast) {
                        _info = item
                    }
                }
            }
        }
        
        if let __info = _info {
            return __info.m_edTimeInfo.m_timeCast
        }
        
        return Config.oldDate7
    }
    
    func addItem(arr: [StoreSensorMovGraphInfo]?) {
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
        var _delList = Array<StoreSensorMovGraphInfo>()
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
        
//        DataManager.instance.m_coreDataInfo.storeHubGraph.deleteItemsByDid(did: did)
    }
    
    func deleteItemById(id: Int) {
        var _delList = Array<StoreSensorMovGraphInfo>()
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
        
//        DataManager.instance.m_coreDataInfo.storeHubGraph.deleteItemsById(id: id)
    }
}

