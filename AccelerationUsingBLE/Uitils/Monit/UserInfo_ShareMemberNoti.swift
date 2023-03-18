//
//  UserInfo_DeviceNoti.swift
//  Monit
//
//  Created by 맥 on 2017. 9. 26..
//  Copyright © 2017년 맥. All rights reserved.
//

import Foundation

enum SHARE_MEMBER_NOTI_TYPE: Int {
    case MY_CLOUD_INVITE = 60
    case MY_CLOUD_DELETE = 61
    case MY_CLOUD_LEAVE = 62
    case MY_CLOUD_REQUEST = 63
    case OTHER_CLOUD_INVITED = 64
    case OTHER_CLOUD_DELETED = 65
    case OTHER_CLOUD_LEAVE = 66
    case OTHER_CLOUD_REQUEST = 67
    case CLOUD_INIT_DEVICE = 68
}

class CastDateFormatShareMemberNoti: CastDateFormat {
    var m_lNotiTime: String! // "h:mm a"
    
    override init (time: String) {
        super.init(time: time)
        m_dateFormatter.dateFormat = "h:mm a"
        self.m_lNotiTime = m_dateFormatter.string(from: m_lTimeCast)
        
        //        Debug.print("time: \(time), m_lDate: \(m_lDate), m_lTime: \(m_lNotiTime)")
    }
}

class ShareMemberNotiInfo {
    var m_id: Int = 0
    var m_noti: Int = 0
    var m_time: String = ""
    var m_extra: String = ""
    var m_castTimeInfo: CastDateFormatShareMemberNoti!

    init(id: Int, noti: Int, time: String, extra: String) {
        self.m_id = id
        self.m_noti = noti
        self.m_time = time
        self.m_extra = extra
        self.m_castTimeInfo = CastDateFormatShareMemberNoti(time: time)
    }
    
    var notiType: SHARE_MEMBER_NOTI_TYPE? {
        get{
            return SHARE_MEMBER_NOTI_TYPE(rawValue: m_noti)
        }
    }
}

class UserInfo_ShareMemberNoti {
    var m_shareMemberNoti = [ShareMemberNotiInfo]()
    
    var m_lastTime: Date {
        get {
            var _maxDate: Date?
            
            for item in m_shareMemberNoti {
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
            
            return Config.oldDate3
        }
    }
    
    func isExist(item: ShareMemberNotiInfo) -> Bool {
        for _item in m_shareMemberNoti {
            if (_item.m_time == item.m_time && _item.m_noti == item.m_noti) {
                return true
            }
        }
        return false
    }
    
    func getLastTime() -> Date {
        var _maxDate: Date?
        
        for item in m_shareMemberNoti {
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
        
        return Config.oldDate3
    }

    func addNoti(arr: [ShareMemberNotiInfo]?) {
        if (arr == nil) {
            return
        }
        
        for item in arr! {
            if (!(isExist(item: item))) {
                if let _type = SHARE_MEMBER_NOTI_TYPE(rawValue: item.m_noti) {
                    switch _type  {
                    default: m_shareMemberNoti.append(item)
                    }
                }
            }
        }
    }
}

