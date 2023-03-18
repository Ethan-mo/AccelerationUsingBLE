//
//  UserInfo_DeviceNoti.swift
//  Monit
//
//  Created by 맥 on 2017. 9. 26..
//  Copyright © 2017년 맥. All rights reserved.
//

import Foundation

class CastDateFormatSensorVocGraph: CastDateFormat {
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
class StoreSensorVocGraphInfo {
    var m_id: Int = 0
    var m_did: Int = 0
    var m_time: String = ""
    var m_voc: String = ""
    var m_cnt: Int = 0
    var m_castTimeInfo: CastDateFormatSensorVocGraph!
    var m_edTimeInfo: CastDateFormatSensorVocGraph!
    var m_descryptVoc: String = ""
    
    init (id: Int, did: Int, time: String, voc: String, cnt: Int) {
        self.m_id = id
        self.m_did = did
        self.m_voc = voc
        self.m_cnt = cnt
        self.m_castTimeInfo = CastDateFormatSensorVocGraph(time: time)
        let _edTime = UI_Utility.convertDateToString(m_castTimeInfo.m_timeCast.adding(second: cnt * 300), type: .yyMMdd_HHmmss)
        self.m_edTimeInfo = CastDateFormatSensorVocGraph(time: _edTime)
        self.m_time = self.m_castTimeInfo.m_time
        self.m_descryptVoc = descryptVoc(voc: voc)
    }
    
    func descryptVoc(voc: String) -> String {
        var _sb = ""
        if (m_voc.count > 0) {
            var _beforeChar = ""
            var _isDescrypt = false
            var _loopCount = ""
            for item in m_voc {
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

class SensorVocGraphInfo {
    var m_did: Int = 0
    var m_voc: Int = 0
    var m_xAxisValue: Double = 0.0
    var m_timestamp: Int = 0
    var voc: SENSOR_VOC_AVG = .none
    
    init(did: Int, voc: Int, xAxisValue: Double, timestamp: Int) {
        self.m_did = did
        self.m_voc = voc / 100
        self.m_xAxisValue = xAxisValue
        self.m_timestamp = timestamp
        self.voc = SensorStatusInfo.GetVocAvg(vocAvg: voc)
    }
    
    var lTimeSelectString: String {
        get {
            let _time = Date(timeIntervalSince1970: TimeInterval(m_timestamp))
            let m_dateFormatter = DateFormatter()
            m_dateFormatter.dateFormat = "h:mm a"
            return m_dateFormatter.string(from: _time)
        }
    }
}

class UserInfo_SensorVocGraph {
    var m_lst = [StoreSensorVocGraphInfo]()
    
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
    
    func isExist(item: StoreSensorVocGraphInfo) -> Bool {
        for _item in m_lst {
            if (_item.m_time == item.m_time
                && _item.m_did == item.m_did) {
                return true
            }
        }
        return false
    }
    
    func getLastTimeByDid(did: Int) -> Date {
        var _info: StoreSensorVocGraphInfo?
        
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
    
    func addItem(arr: [StoreSensorVocGraphInfo]?) {
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
        var _delList = Array<StoreSensorVocGraphInfo>()
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
        var _delList = Array<StoreSensorVocGraphInfo>()
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

