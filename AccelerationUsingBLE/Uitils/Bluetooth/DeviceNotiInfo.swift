//
//  DeviceNotiInfo.swift
//  AccelerationUsingBLE
//
//  Created by 모상현 on 2023/03/17.
//
import Foundation
class CastDateFormat {
    var m_dateFormatter = DateFormatter()
    var m_date: String = "" // yyyy-MM-dd
    var m_lDate: String = "" // yyyy-MM-dd
    var m_time: String = "" // yyMMdd-HHmmss
    var m_lTime: String = "" // yyMMdd-HHmmss
    var m_dateCast: Date!
    var m_lDateCast: Date!
    var m_timeCast: Date!
    var m_lTimeCast: Date!
    
    init () {
    }
    
    init (time: String) {
        setInit(time: time)
    }

    func setInit(time: String) {
        self.m_time = time
        
        // timeCast
        m_dateFormatter.dateFormat = DATE_TYPE.yyMMdd_HHmmss.rawValue
        m_dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        self.m_timeCast = m_dateFormatter.date(from: time)
        
        // lTime
        m_dateFormatter.dateFormat = DATE_TYPE.yyMMdd_HHmmss.rawValue
        m_dateFormatter.timeZone = TimeZone.current
        self.m_lTime = m_dateFormatter.string(from: m_timeCast)
        
        // lTimeCast
        m_dateFormatter.dateFormat = DATE_TYPE.yyMMdd_HHmmss.rawValue
        m_dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        self.m_lTimeCast = m_dateFormatter.date(from: self.m_lTime)
        
        // date
        m_dateFormatter.dateFormat = DATE_TYPE.yyyy_MM_dd.rawValue
        self.m_date = m_dateFormatter.string(from: m_timeCast)
        
        // dateCast
        m_dateFormatter.dateFormat = DATE_TYPE.yyyy_MM_dd.rawValue
        m_dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        self.m_dateCast = m_dateFormatter.date(from: self.m_date)
        
        // lDate
        m_dateFormatter.dateFormat = DATE_TYPE.yyyy_MM_dd.rawValue
        self.m_lDate = m_dateFormatter.string(from: m_lTimeCast)
        
        // lDateCast
        m_dateFormatter.dateFormat = DATE_TYPE.yyyy_MM_dd.rawValue
        m_dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        self.m_lDateCast = m_dateFormatter.date(from: self.m_lDate)
        
//        Debug.print("m_time:\(time), m_lTime:\(m_lTime), m_timeCast:\(m_timeCast), m_lTime:\(m_lTimeCast), m_date:\(m_date), m_dateCast:\(m_dateCast), m_lDate:\(m_lDate), m_lDateCast:\(m_lDateCast)")
    }
}

class CastDateFormatDeviceNoti: CastDateFormat {
    var m_lNotiTime: String! // "a h:mm"
    
    override init (time: String) {
        super.init(time: time)
        m_dateFormatter.dateFormat = "a h:mm"
        self.m_lNotiTime = m_dateFormatter.string(from: m_lTimeCast)
        
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
