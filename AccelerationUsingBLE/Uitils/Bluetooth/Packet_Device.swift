//
//  Packet_Device.swift
//  Monit
//
//  Created by 맥 on 2017. 10. 26..
//  Copyright © 2017년 맥. All rights reserved.
//

import Foundation
import SwiftyJSON

// GetDevice ID
class Send_GetDeviceId : SendBase {
    var aid: Int = 0
    var did: Int = 0
    var token: String = ""
    var type: Int = 0
    var srl: String = ""
    var mac: String = ""
    var fwv: String = ""
    var name: String = ""
    var adv: String = ""
    var iosreg: Int = 0
    
    override init() {
        super.init()
        pkt = .GetDeviceId
    }
    
    override func convert() -> [String: Any] {
        return [
            "pkt" : pkt.rawValue,
            "aid" : aid,
            "did" : did,
            "token" : token,
            "type": type,
            "srl": srl,
            "mac": mac,
            "fwv": fwv,
            "name": name,
            "adv": adv,
            "iosreg": iosreg,
        ]
    }
}

class Receive_GetDeviceId : ReceiveBase {
    var did : Int?
    var heat: Int?
    var srl: String?
  
    override init(_ json: JSON) {
        super.init(json)
        self.did = json["did"].intValue
        self.heat = json["heat"].intValue
        self.srl = json["srl"].stringValue
    }
}

// SetCloudId
class Send_SetCloudId : SendBase {
    var aid: Int = 0
    var token: String = ""
    var type: Int = 0
    var did: Int = 0
    var enc: String = ""
    
    override init() {
        super.init()
        pkt = .SetCloudId
    }
    
    override func convert() -> [String: Any] {
        return [
            "pkt" : pkt.rawValue,
            "aid" : aid,
            "token" : token,
            "type": type,
            "did": did,
            "enc": enc,
        ]
    }
}

class Receive_SetCloudId : ReceiveBase {
    override init(_ json: JSON) {
        super.init(json)
    }
}

// GetCloudId
class Send_GetCloudId : SendBase {
    var aid: Int = 0
    var token: String = ""
    var type: Int = 0
    var did: Int = 0
    var enc: String = ""
    
    override init() {
        super.init()
        pkt = .GetCloudId
    }
    
    override func convert() -> [String: Any] {
        return [
            "pkt" : pkt.rawValue,
            "aid" : aid,
            "token" : token,
            "type": type,
            "did": did,
            "enc": enc,
        ]
    }
}

class Receive_GetCloudId : ReceiveBase {
    var cid : Int?
    var sid : String?
    var nick : String?
    
    override init(_ json: JSON) {
        super.init(json)
        self.cid = json["cid"].intValue
        self.sid = json["sid"].stringValue
        self.nick = json["nick"].stringValue
    }
}

class SendSensorStatusInfo {
    var type: Int = 0
    var did: Int = 0
    var enc: String = ""
    var bat: Int?
    var mov: Int?
    var dps: Int?
    var opr: Int?
    var tem: Int?
    var hum: Int?
    var voc: Int?
    var fwv: String?
    var con: Int?
    var err : String?
    var time: Int64?
    var dtime: Int64?
    
    init(type: Int, did: Int, enc: String, bat: Int?, mov: Int?, dps: Int?, opr: Int?, tem: Int?, hum: Int?, voc: Int?, fwv: String?, con: Int?) {
        self.type = type
        self.did = did
        self.enc = enc
        self.bat = bat
        self.mov = mov
        self.dps = dps
        self.opr = opr
        self.tem = tem
        self.hum = hum
        self.voc = voc
        self.fwv = fwv
        self.con = con
    }
    
    var convertData: [String: Any] {
        get {
            var _dicData = [String: Any]()
            _dicData.updateValue(type, forKey: "type")
            _dicData.updateValue(did, forKey: "did")
            _dicData.updateValue(enc, forKey: "enc")
            
            if let _bat = bat {
                _dicData.updateValue(_bat, forKey: "bat")
            }
            if let _mov = mov {
                _dicData.updateValue(_mov, forKey: "mov")
            }
            if let _dps = dps {
                _dicData.updateValue(_dps, forKey: "dps")
            }
            if let _opr = opr {
                _dicData.updateValue(_opr, forKey: "opr")
            }
            if let _tem = tem {
                _dicData.updateValue(_tem, forKey: "tem")
            }
            if let _hum = hum {
                _dicData.updateValue(_hum, forKey: "hum")
            }
            if let _voc = voc {
                _dicData.updateValue(_voc, forKey: "voc")
            }
            if let _fwv = fwv {
                _dicData.updateValue(_fwv, forKey: "fwv")
            }
            if let _con = con {
                _dicData.updateValue(_con, forKey: "con")
            }
            if let _err = err {
                _dicData.updateValue(_err, forKey: "err")
            }
            if let _time = time {
                _dicData.updateValue(_time, forKey: "time")
            }
            if let _time = dtime {
                _dicData.updateValue(_time, forKey: "dtime")
            }
            return _dicData
        }
    }
}

// StartConnection
class Send_StartConnection : SendBase {
    var aid : Int = 0
    var token : String = ""
    var data : Array<SendSensorStatusInfo> = Array()
    
    override init() {
        super.init()
        pkt = .StartConnection
    }
    
    override func convert() -> [String: Any] {
        var _dic = [String: Any]()
        _dic.updateValue(pkt.rawValue, forKey: "pkt")
        _dic.updateValue(aid, forKey: "aid")
        _dic.updateValue(token, forKey: "token")

        var _array = [Any]()
        for item in data {
            _array.append(item.convertData)
        }
        _dic.updateValue(_array, forKey: "data")
        return _dic
    }
}

class Receive_StartConnection : ReceiveBase {
    override init(_ json: JSON) {
        super.init(json)
    }
}

class Send_SetBabyInfo : SendBase {
    var aid : Int = 0
    var token : String = ""
    var type : Int = 0
    var did : Int = 0
    var enc : String = ""
    var name : String = ""
    var bday : String = ""
    var sex : Int = 0
    var eat : Int = 0
    
    override init() {
        super.init()
        pkt = .SetBabyInfo
    }
    
    override func convert() -> [String: Any] {
        return [
            "pkt" : pkt.rawValue,
            "aid" : aid,
            "token" : token,
            "type": type,
            "did": did,
            "enc": enc,
            "name": name,
            "bday": bday,
            "sex": sex,
            "eat": eat,
        ]
    }
}

class Receive_SetBabyInfo : ReceiveBase {
    override init(_ json: JSON) {
        super.init(json)
    }
}

class Send_SetDeviceStatusForSensor: SendBase {
    var aid : Int = 0
    var token : String = ""
    var data : Array<SendSensorStatusInfo> = Array()
    
    override init() {
        super.init()
        pkt = .SetDeviceStatus
    }
    
    override func convert() -> [String: Any] {
        var _dic = [String: Any]()
        _dic.updateValue(pkt.rawValue, forKey: "pkt")
        _dic.updateValue(aid, forKey: "aid")
        _dic.updateValue(token, forKey: "token")

        var _array = [Any]()
        for item in data {
            _array.append(item.convertData)
        }
        _dic.updateValue(_array, forKey: "data")
        return _dic
    }
}

class Receive_SetDeviceStatusForSensor : ReceiveBase {
    override init(_ json: JSON) {
        super.init(json)
    }
}

class SendHubTypesStatusInfo {
    var type: Int = 0
    var did: Int = 0
    var enc: String = ""
    var brt: Int?
    var clr: Int?
    var pow: Int?
    var onptime: String?
    var offptime: String?
    var err : String?
    var tem: Int?
    var hum: Int?
    
    init(type: Int, did: Int, enc: String, brt: Int?, clr: Int?, pow: Int?, onptime: String?, offptime: String?) {
        self.type = type
        self.did = did
        self.enc = enc
        self.brt = brt
        self.clr = clr
        self.pow = pow
        self.onptime = onptime
        self.offptime = offptime
    }
    
    var convertData: [String: Any] {
        get {
            var _dicData = [String: Any]()
            _dicData.updateValue(type, forKey: "type")
            _dicData.updateValue(did, forKey: "did")
            _dicData.updateValue(enc, forKey: "enc")
            
            if let _bat = brt {
                _dicData.updateValue(_bat, forKey: "brt")
            }
            if let _mov = clr {
                _dicData.updateValue(_mov, forKey: "clr")
            }
            if let _pow = pow {
                _dicData.updateValue(_pow, forKey: "pow")
            }
            if let _onptime = onptime {
                _dicData.updateValue(_onptime, forKey: "onptime")
            }
            if let _offptime = offptime {
                _dicData.updateValue(_offptime, forKey: "offptime")
            }
            if let _err = err {
                _dicData.updateValue(_err, forKey: "err")
            }
            if let _tem = tem {
                _dicData.updateValue(_tem, forKey: "tem")
            }
            if let _hum = hum {
                _dicData.updateValue(_hum, forKey: "hum")
            }
            return _dicData
        }
    }
}

class Send_SetDeviceStatusForHubTypes: SendBase {
    var aid : Int = 0
    var token : String = ""
    var data : Array<SendHubTypesStatusInfo> = Array()
    
    override init() {
        super.init()
        pkt = .SetDeviceStatus
    }
    
    override func convert() -> [String: Any] {
        var _dic = [String: Any]()
        _dic.updateValue(pkt.rawValue, forKey: "pkt")
        _dic.updateValue(aid, forKey: "aid")
        _dic.updateValue(token, forKey: "token")
        
        var _array = [Any]()
        for item in data {
            _array.append(item.convertData)
        }
        _dic.updateValue(_array, forKey: "data")
        return _dic
    }
}

class Receive_SetDeviceStatusForHubTypes : ReceiveBase {
    override init(_ json: JSON) {
        super.init(json)
    }
}

class Send_InitDevice: SendBase {
    var aid : Int = 0
    var token : String = ""
    var type : Int = 0
    var did : Int = 0
    var enc : String = ""
    
    override init() {
        super.init()
        pkt = .InitDevice
    }
    
    override func convert() -> [String: Any] {
        return [
            "pkt" : pkt.rawValue,
            "aid" : aid,
            "token" : token,
            "type": type,
            "did": did,
            "enc": enc,
        ]
    }
}

class Receive_InitDevice : ReceiveBase {
    override init(_ json: JSON) {
        super.init(json)
    }
}

class Send_SetDiaperChanged: SendBase {
    var aid : Int = 0
    var token : String = ""
    var type : Int = 0
    var did : Int = 0
    var enc : String = ""
    var time: String = ""
    var extra: String = "-"
    var nid: Int?
    var edit_type: Int?
    var memo: String?
    
    override init() {
        super.init()
        pkt = .SetDiaperChanged
    }
    
    override func convert() -> [String: Any] {
        var _dicData = [String: Any]()
        _dicData.updateValue(pkt.rawValue, forKey: "pkt")
        _dicData.updateValue(aid, forKey: "aid")
        _dicData.updateValue(token, forKey: "token")
        _dicData.updateValue(type, forKey: "type")
        _dicData.updateValue(did, forKey: "did")
        _dicData.updateValue(enc, forKey: "enc")
        _dicData.updateValue(time, forKey: "time")
        _dicData.updateValue(extra, forKey: "extra")
        
        if let _nid = nid {
            _dicData.updateValue(_nid, forKey: "nid")
        }
        if let _edit_type = edit_type {
            _dicData.updateValue(_edit_type, forKey: "edit_type")
        }
        if let _memo = memo {
            _dicData.updateValue(_memo, forKey: "memo")
        }
        
        return _dicData
    }
}

class Receive_SetDiaperChanged : ReceiveBase {
    override init(_ json: JSON) {
        super.init(json)
    }
}

class Send_SetFeeding: SendBase {
    var aid : Int = 0
    var token : String = ""
    var type : Int = 0
    var did : Int = 0
    var enc : String = ""
    var time: String?
    var feeding_type: Int?
    var nid: Int?
    var edit_type: Int?
    var total: Int?
    var left_time: Int?
    var right_time: Int?
    var memo: String?
        
    override init() {
        super.init()
        pkt = .SetFeeding
    }
    
    override func convert() -> [String: Any] {
        var _dicData = [String: Any]()
        _dicData.updateValue(pkt.rawValue, forKey: "pkt")
        _dicData.updateValue(aid, forKey: "aid")
        _dicData.updateValue(token, forKey: "token")
        _dicData.updateValue(type, forKey: "type")
        _dicData.updateValue(did, forKey: "did")
        _dicData.updateValue(enc, forKey: "enc")
        
        if let _time = time {
            _dicData.updateValue(_time, forKey: "time")
        }
        if let _feeding_type = feeding_type {
            _dicData.updateValue(_feeding_type, forKey: "feeding_type")
        }
        if let _nid = nid {
            _dicData.updateValue(_nid, forKey: "nid")
        }
        if let _edit_type = edit_type {
            _dicData.updateValue(_edit_type, forKey: "edit_type")
        }
        if let _total = total {
            _dicData.updateValue(_total, forKey: "total")
        }
        if let _left_time = left_time {
            _dicData.updateValue(_left_time, forKey: "left_time")
        }
        if let _right_time = right_time {
            _dicData.updateValue(_right_time, forKey: "right_time")
        }
        if let _memo = memo {
            _dicData.updateValue(_memo, forKey: "memo")
        }
        
        return _dicData
    }
}

class Receive_SetFeeding : ReceiveBase {
    override init(_ json: JSON) {
        super.init(json)
    }
}

class Send_InitDiaperStatus: SendBase {
    var aid : Int = 0
    var token : String = ""
    var type : Int = 0
    var did : Int = 0
    var enc : String = ""
    
    override init() {
        super.init()
        pkt = .InitDiaperStatus
    }
    
    override func convert() -> [String: Any] {
        return [
            "pkt" : pkt.rawValue,
            "aid" : aid,
            "token" : token,
            "type": type,
            "did": did,
            "enc": enc,
        ]
    }
}

class Receive_InitDiaperStatus : ReceiveBase {
    override init(_ json: JSON) {
        super.init(json)
    }
}

class Send_SetDeviceName: SendBase {
    var aid : Int = 0
    var token : String = ""
    var type : Int = 0
    var did : Int = 0
    var enc : String = ""
    var name : String = ""
    
    override init() {
        super.init()
        pkt = .SetDeviceName
    }
    
    override func convert() -> [String: Any] {
        return [
            "pkt" : pkt.rawValue,
            "aid" : aid,
            "token" : token,
            "type": type,
            "did": did,
            "enc": enc,
            "name": name,
        ]
    }
}

class Receive_SetDeviceName : ReceiveBase {
    override init(_ json: JSON) {
        super.init(json)
    }
}

class Send_SetAlarmThreshold: SendBase {
    var aid : Int = 0
    var token : String = ""
    var type : Int = 0
    var did : Int = 0
    var enc : String = ""
    var tmax: Int?
    var tmin: Int?
    var hmax: Int?
    var hmin: Int?
    
    override init() {
        super.init()
        pkt = .SetAlarmThreshold
    }
    
    override func convert() -> [String: Any] {
        var _dicData = [String: Any]()
        _dicData.updateValue(pkt.rawValue, forKey: "pkt")
        _dicData.updateValue(aid, forKey: "aid")
        _dicData.updateValue(token, forKey: "token")
        _dicData.updateValue(type, forKey: "type")
        _dicData.updateValue(did, forKey: "did")
        _dicData.updateValue(enc, forKey: "enc")
        
        if let _tmax = tmax {
            _dicData.updateValue(_tmax, forKey: "tmax")
        }
        if let _tmin = tmin {
            _dicData.updateValue(_tmin, forKey: "tmin")
        }
        if let _hmax = hmax {
            _dicData.updateValue(_hmax, forKey: "hmax")
        }
        if let _hmin = hmin {
            _dicData.updateValue(_hmin, forKey: "hmin")
        }
        
        return _dicData
    }
}

class Receive_SetAlarmThreshold : ReceiveBase {
    override init(_ json: JSON) {
        super.init(json)
    }
}

class Send_GetNotification: SendBase {
    var token : String = ""
    var time: String = ""
    var aid : Int?
    var did: Int?
    var type: Int?
    var is_full: Int?
    
    override init() {
        super.init()
        pkt = .GetNotification
    }
    
    override func convert() -> [String: Any] {
        var _dic = [String: Any]()
        _dic.updateValue(pkt.rawValue, forKey: "pkt")
        _dic.updateValue(token, forKey: "token")
        _dic.updateValue(time, forKey: "time")
        if (aid != nil) { _dic.updateValue(aid!, forKey: "aid") }
        if (did != nil) { _dic.updateValue(did!, forKey: "did") }
        if (type != nil) { _dic.updateValue(type!, forKey: "type") }
        if (is_full != nil) { _dic.updateValue(is_full!, forKey: "is_full") }
        return _dic
    }
}

class Receive_GetNotification: ReceiveBase {
    var notification: Array<DeviceNotiInfo> = Array()
    
    override init(_ json: JSON) {
        super.init(json)
        
        let _arrData: Array<JSON> = json["notification"].arrayValue
        for item in _arrData {
            let _info = DeviceNotiInfo(
                id: 0,
                nid: item["nid"].intValue,
                type: item["type"].intValue,
                did: item["did"].intValue,
                noti: item["noti"].intValue,
                extra: item["extra"].stringValue,
                extra2: item["extra2"].stringValue,
                extra3: item["extra3"].stringValue,
                extra4: item["extra4"].stringValue,
                extra5: item["extra5"].stringValue,
                memo: item["memo"].stringValue,
                time: item["time"].stringValue,
                finishTime: item["finish_time"].stringValue
            )
//            let _info = DeviceNotiInfo(id: 0, nid: 0, type: item["type"].intValue, did: item["did"].intValue, noti: item["noti"].intValue, time: item["time"].stringValue, extra: item["extra"].stringValue)
            notification.append(_info)
        }
    }
}
//
//// removeNotification
//class Send_RemoveNotification: SendBase {
//    var token : String = ""
//    var time: String = ""
//    var aid : Int?
//    var did: Int?
//    var type: Int?
//    var noti: Int?
//
//    override init() {
//        super.init()
//        pkt = .RemoveNotification
//    }
//
//    override func convert() -> [String: Any] {
//        var _dic = [String: Any]()
//        _dic.updateValue(pkt.rawValue, forKey: "pkt")
//        _dic.updateValue(token, forKey: "token")
//        _dic.updateValue(time, forKey: "time")
//        _dic.updateValue(aid!, forKey: "aid")
//        _dic.updateValue(did!, forKey: "did")
//        _dic.updateValue(type!, forKey: "type")
//        _dic.updateValue(noti!, forKey: "noti")
//        return _dic
//    }
//}
//
//class Receive_RemoveNotification: ReceiveBase {
//    override init(_ json: JSON) {
//        super.init(json)
//    }
//}

class DeviceNotiEditInfo {
    var m_nid: Int = 0
    var m_edit_type: Int = 0
    var m_noti: Int = 0
    var m_extra: String = ""
    var m_extra2: String = ""
    var m_extra3: String = ""
    var m_extra4: String = ""
    var m_extra5: String = ""
    var m_memo: String = ""
    var m_time: String = ""
    var m_finish_time: String = ""
    var m_created: String = ""
    var m_castTimeInfo: CastDateFormatDeviceNoti!
    var m_castCreatedInfo: CastDateFormatDeviceNoti!
    
    init(nid: Int, edit_type: Int, noti: Int, extra: String, extra2: String, extra3: String, extra4: String, extra5: String, memo: String, time: String, finishTime: String, created: String) {
        self.m_nid = nid
        self.m_edit_type = edit_type
        self.m_noti = noti
        self.m_extra = extra
        self.m_extra2 = extra2
        self.m_extra3 = extra3
        self.m_extra4 = extra4
        self.m_extra5 = extra5
        self.m_memo = memo
        self.m_time = time
        self.m_finish_time = finishTime
        self.m_created = created
        self.m_castTimeInfo = CastDateFormatDeviceNoti(time: time)
        self.m_castCreatedInfo = CastDateFormatDeviceNoti(time: created)
    }
}

class Send_GetNotificationEdit: SendBase {
    var token : String = ""
    var time: String = ""
    var aid : Int?
    var did: Int?
    var type: Int?
    
    override init() {
        super.init()
        pkt = .GetNotificationEdit
    }
    
    override func convert() -> [String: Any] {
        var _dic = [String: Any]()
        _dic.updateValue(pkt.rawValue, forKey: "pkt")
        _dic.updateValue(token, forKey: "token")
        _dic.updateValue(time, forKey: "time")
        if (aid != nil) { _dic.updateValue(aid!, forKey: "aid") }
        if (did != nil) { _dic.updateValue(did!, forKey: "did") }
        if (type != nil) { _dic.updateValue(type!, forKey: "type") }
        return _dic
    }
}

class Receive_GetNotificationEdit: ReceiveBase {
    var notification: Array<DeviceNotiEditInfo> = Array()
    
    override init(_ json: JSON) {
        super.init(json)
        
        let _arrData: Array<JSON> = json["notification"].arrayValue
        for item in _arrData {
            let _info = DeviceNotiEditInfo(
                nid: item["nid"].intValue,
                edit_type: item["edit_type"].intValue,
                noti: item["noti"].intValue,
                extra: item["extra"].stringValue,
                extra2: item["extra2"].stringValue,
                extra3: item["extra3"].stringValue,
                extra4: item["extra4"].stringValue,
                extra5: item["extra5"].stringValue,
                memo: item["memo"].stringValue,
                time: item["time"].stringValue,
                finishTime: item["finish_time"].stringValue,
                created: item["created"].stringValue
            )
            notification.append(_info)
        }
    }
}

class Send_SetNotificationEdit: SendBase {
    var token : String = ""
    var aid : Int = 0
    var did: Int = 0
    var type: Int = 0
    var enc : String = ""
    var nid : Int = 0
    var edit_type: Int = 0
    var noti: Int?
    var extra: String?
    var extra2: String?
    var extra3: String?
    var extra4: String?
    var extra5: String?
    var memo: String?
    var time: String?
    var finish_time: String?

    override init() {
        super.init()
        pkt = .SetNotificationEdit
    }
    
    override func convert() -> [String: Any] {
        var _dic = [String: Any]()
        _dic.updateValue(pkt.rawValue, forKey: "pkt")
        _dic.updateValue(aid, forKey: "aid")
        _dic.updateValue(token, forKey: "token")
        _dic.updateValue(did, forKey: "did")
        _dic.updateValue(type, forKey: "type")
        _dic.updateValue(enc, forKey: "enc")
        _dic.updateValue(nid, forKey: "nid")
        _dic.updateValue(edit_type, forKey: "edit_type")
        if (noti != nil) { _dic.updateValue(noti!, forKey: "noti") }
        if (extra != nil) { _dic.updateValue(extra!, forKey: "extra") }
        if (extra2 != nil) { _dic.updateValue(extra2!, forKey: "extra2") }
        if (extra3 != nil) { _dic.updateValue(extra3!, forKey: "extra3") }
        if (extra4 != nil) { _dic.updateValue(extra4!, forKey: "extra4") }
        if (extra5 != nil) { _dic.updateValue(extra5!, forKey: "extra5") }
        if (memo != nil) { _dic.updateValue(memo!, forKey: "memo") }
        if (time != nil) { _dic.updateValue(time!, forKey: "time") }
        if (finish_time != nil) { _dic.updateValue(finish_time!, forKey: "finish_time") }
        return _dic
    }
}

class Receive_SetNotificationEdit: ReceiveBase {
    override init(_ json: JSON) {
        super.init(json)
    }
}

class Send_SetLedOnOffTime: SendBase {
    var aid : Int = 0
    var token : String = ""
    var type : Int = 0
    var did : Int = 0
    var enc : String = ""
    var onnt : String = ""
    var offt : String = ""
    
    override init() {
        super.init()
        pkt = .SetLedOnOffTime
    }
    
    override func convert() -> [String: Any] {
        return [
            "pkt" : pkt.rawValue,
            "aid" : aid,
            "token" : token,
            "type": type,
            "did": did,
            "enc": enc,
            "onnt": onnt,
            "offt": offt,
        ]
    }
}

class Receive_SetLedOnOffTime: ReceiveBase {
    override init(_ json: JSON) {
        super.init(json)
    }
}

class Send_OTAUpdateDevice: SendBase {
    var aid : Int = 0
    var token : String = ""
    var type : Int = 0
    var did : Int = 0
    var mode : Int = 0
    var enc : String = ""
    
    override init() {
        super.init()
        pkt = .OTAUpdateDevice
    }
    
    override func convert() -> [String: Any] {
        return [
            "pkt" : pkt.rawValue,
            "aid" : aid,
            "token" : token,
            "type": type,
            "did": did,
            "mode": mode,
            "enc": enc,
        ]
    }
}

class Receive_OTAUpdateDevice: ReceiveBase {
    override init(_ json: JSON) {
        super.init(json)
    }
}

class SensorConnectionLogInfo_Manager {
    var m_scannedDeviceName: String = ""
    var m_scannedDeviceCount: Int = -1
    var m_connected: Int = -1
}

class SensorConnectionLogInfo_Peripheral {
    var m_bleStep: Int = -1
    var m_getDeviceEcd: Int = -1
    var m_deviceId: Int = -1
    var m_getCloudEcd: Int = -1
    var m_setCloudEcd: Int = -1
    var m_startConnEcd: Int = -1
}

class Send_SetSensorConnectionLog: SendBase {
    var aid : Int = 0
    var token : String = ""
    var data_manager = SensorConnectionLogInfo_Manager()
    var data_peripheral = SensorConnectionLogInfo_Peripheral()
    
    override init() {
        super.init()
        pkt = .SetSensorConnectionLog
    }
    
    override func convert() -> [String: Any] {
        var _dic = [String: Any]()
        _dic.updateValue(pkt.rawValue, forKey: "pkt")
        _dic.updateValue(aid, forKey: "aid")
        _dic.updateValue(token, forKey: "token")
        let _data = "\(data_manager.m_scannedDeviceName),\(data_manager.m_scannedDeviceCount),\(data_manager.m_connected),\(data_peripheral.m_bleStep),\(data_peripheral.m_getDeviceEcd),\(data_peripheral.m_deviceId),\(data_peripheral.m_getCloudEcd),\(data_peripheral.m_setCloudEcd),\(data_peripheral.m_startConnEcd)"
        _dic.updateValue(_data, forKey: "data")
        return _dic
    }
}

class Receive_SetSensorConnectionLog: ReceiveBase {
    override init(_ json: JSON) {
        super.init(json)
    }
}

class Send_NotificationFeedback: SendBase {
    var aid : Int = 0
    var token : String = ""
    var noti : Int = 0
    var type : Int = 0
    var did : Int = 0
    var extra : String = ""
    var time : String = ""
    
    override init() {
        super.init()
        pkt = .SetNotificationFeedback
    }
    
    override func convert() -> [String: Any] {
        return [
            "pkt": pkt.rawValue,
            "aid": aid,
            "token": token,
            "noti": noti,
            "type": type,
            "did": did,
            "extra": extra,
            "time": time,
        ]
    }
}

class Receive_NotificationFeedback: ReceiveBase {
    override init(_ json: JSON) {
        super.init(json)
    }
}

class Send_SetDiaperSensingLog: SendBase {
    var aid : Int = 0
    var token : String = ""
    var did : Int = 0
    var tem: String = ""
    var hum: String = ""
    var voc: String = ""
    var cap: String = ""
    var act: String = ""
    var sen: String = ""
    var mlv: String = ""
    var eth: String = ""
    var co2: String = ""
    var pres: String = ""
    var comp: String = ""
    var time: String = ""
    
    override init() {
        super.init()
        pkt = .SetDiaperSensingLog
    }
    
    override func convert() -> [String: Any] {
        var _dic = [String: Any]()
        _dic.updateValue(pkt.rawValue, forKey: "pkt")
        _dic.updateValue(aid, forKey: "aid")
        _dic.updateValue(token, forKey: "token")
        _dic.updateValue(did, forKey: "did")
        _dic.updateValue(tem, forKey: "tem")
        _dic.updateValue(hum, forKey: "hum")
        _dic.updateValue(voc, forKey: "voc")
        _dic.updateValue(cap, forKey: "cap")
        _dic.updateValue(act, forKey: "act")
        _dic.updateValue(sen, forKey: "sen")
        _dic.updateValue(mlv, forKey: "mlv")
        _dic.updateValue(time, forKey: "time")
        if (eth != "") { _dic.updateValue(eth, forKey: "eth") }
        if (co2 != "") { _dic.updateValue(co2, forKey: "co2") }
        if (pres != "") { _dic.updateValue(pres, forKey: "pres") }
        if (comp != "") { _dic.updateValue(comp, forKey: "comp") }
        return _dic
    }
}

class Receive_SetDiaperSensingLog: ReceiveBase {
    override init(_ json: JSON) {
        super.init(json)
    }
}

class Send_SetSensorSensitivity: SendBase {
    var aid : Int = 0
    var token : String = ""
    var did : Int = 0
    var enc : String = ""
    var sens : Int = 0

    override init() {
        super.init()
        pkt = .SetSensorSensitivity
    }
    
    override func convert() -> [String: Any] {
        return [
            "pkt" : pkt.rawValue,
            "aid" : aid,
            "token" : token,
            "did": did,
            "enc": enc,
            "sens": sens,
        ]
    }
}

class Receive_SetSensorSensitivity: ReceiveBase {
    override init(_ json: JSON) {
        super.init(json)
    }
}

class Send_GetSensorFW: SendBase {
    var aid : Int = 0
    var token : String = ""
    var did : Int = 0
    var enc : String = ""
    var mode : Int = 0
    
    override init() {
        super.init()
        pkt = .GetSensorFW
    }
    
    override func convert() -> [String: Any] {
        return [
            "pkt" : pkt.rawValue,
            "aid" : aid,
            "token" : token,
            "did": did,
            "enc": enc,
            "mode": mode,
        ]
    }
}

class Receive_GetSensorFW: ReceiveBase {
    var url : String?
    var file: String?
    
    override init(_ json: JSON) {
        super.init(json)
        self.url = json["url"].stringValue
        self.file = json["file"].stringValue
    }
}

class Send_GetSensorFWV2: SendBase {
    var aid : Int = 0
    var token : String = ""
    var did : Int = 0
    var enc : String = ""
    var mode : Int = 0
    
    override init() {
        super.init()
        pkt = .GetSensorFWV2
    }
    
    override func convert() -> [String: Any] {
        return [
            "pkt" : pkt.rawValue,
            "aid" : aid,
            "token" : token,
            "did": did,
            "enc": enc,
            "mode": mode,
        ]
    }
}

class Send_GetHubGraphList: SendBase {
    var aid : Int = 0
    var token : String = ""
    var did : Int = 0
    var time : String = ""
    
    override init() {
        super.init()
        pkt = .GetHubGraphList
    }
    
    override func convert() -> [String: Any] {
        return [
            "pkt" : pkt.rawValue,
            "aid" : aid,
            "token" : token,
            "did": did,
            "time": time,
        ]
    }
}


class Send_GetLampGraphList: SendBase {
    var aid : Int = 0
    var token : String = ""
    var did : Int = 0
    var time : String = ""
    
    override init() {
        super.init()
        pkt = .GetLampGraphList
    }
    
    override func convert() -> [String: Any] {
        return [
            "pkt" : pkt.rawValue,
            "aid" : aid,
            "token" : token,
            "did": did,
            "time": time,
        ]
    }
}


class Send_GetSensorMovGraphList: SendBase {
    var aid : Int = 0
    var token : String = ""
    var did : Int = 0
    var time : String = ""
    
    override init() {
        super.init()
        pkt = .GetSensorMovGraphList
    }
    
    override func convert() -> [String: Any] {
        return [
            "pkt" : pkt.rawValue,
            "aid" : aid,
            "token" : token,
            "did": did,
            "time": time,
        ]
    }
}

class Receive_GetSensorMovGraphList: ReceiveBase {
    var time : String?
    var mov: String?
    var cnt: Int?
    
    override init(_ json: JSON) {
        super.init(json)
        self.time = json["time"].stringValue
        self.mov = json["mov"].stringValue
        self.cnt = json["cnt"].intValue
    }
}

class Send_GetSensorVocGraphList: SendBase {
    var aid : Int = 0
    var token : String = ""
    var did : Int = 0
    var time : String = ""
    
    override init() {
        super.init()
        pkt = .GetSensorVocGraphList
    }
    
    override func convert() -> [String: Any] {
        return [
            "pkt" : pkt.rawValue,
            "aid" : aid,
            "token" : token,
            "did": did,
            "time": time,
        ]
    }
}

class Receive_GetSensorVocGraphList: ReceiveBase {
    var time : String?
    var voc: String?
    var cnt: Int?
    
    override init(_ json: JSON) {
        super.init(json)
        self.time = json["time"].stringValue
        self.voc = json["voc"].stringValue
        self.cnt = json["cnt"].intValue
    }
}

// GetDemoInfo
class Send_GetDemoInfo : SendBase {
    var os: Int = 0

    override init() {
        super.init()
        pkt = .GetDemoInfo
    }
    
    override func convert() -> [String: Any] {
        return [
            "pkt" : pkt.rawValue,
            "os" : os,
        ]
    }
}

class Receive_GetDemoInfo : ReceiveBase {
    var threshold : Int?
    var count_time: Int?
    var alarm_delay: Double?
    var ignore_delay: Double?
    
    override init(_ json: JSON) {
        super.init(json)
        self.threshold = json["threshold"].intValue
        self.count_time = json["count_time"].intValue
        self.alarm_delay = json["alarm_delay"].doubleValue
        self.ignore_delay = json["ignore_delay"].doubleValue
    }
}

class Send_GetHubTimerInfo: SendBase {
    var aid : Int = 0
    var token : String = ""
    var type : Int = 2
    var did : Int = 0
    var enc : String = ""
    
    override init() {
        super.init()
        pkt = .GetHubTimerInfo
    }
    
    override func convert() -> [String: Any] {
        return [
            "pkt" : pkt.rawValue,
            "aid" : aid,
            "token" : token,
            "type": type,
            "did": did,
            "enc": enc,
        ]
    }
}

class Receive_GetHubTimerInfo: ReceiveBase {
    var onptime : String?
    var offptime: String?
    
    override init(_ json: JSON) {
        super.init(json)
        self.onptime = json["onptime"].stringValue
        self.offptime = json["offptime"].stringValue
    }
}

class SendSensorStatusForAutoPollingNotiInfo {
    var type: Int = 0
    var did: Int = 0
    var enc: String = ""
    var cpee: Int?
    var cpoo: Int?
    var cabn: Int?
    var cfart: Int?
    var cdet: Int?
    var catt: Int?
    var lpeet: Int64?
    var lpoot: Int64?
    var labnt: Int64?
    var lfart: Int64?
    var ldett: Int64?
    var lattt: Int64?
    
    init(type: Int, did: Int, enc: String, cpee: Int?, cpoo: Int?, cabn: Int?, cfart: Int?, cdet: Int?, catt: Int?, lpeet: Int64?, lpoot: Int64?, labnt: Int64?, lfart: Int64?, ldett: Int64?, lattt: Int64?) {
        self.type = type
        self.did = did
        self.enc = enc
        self.cpee = cpee
        self.cpoo = cpoo
        self.cabn = cabn
        self.cfart = cfart
        self.cdet = cdet
        self.catt = catt
        self.lpeet = lpeet
        self.lpoot = lpoot
        self.labnt = labnt
        self.lfart = lfart
        self.ldett = ldett
        self.lattt = lattt
    }
    
    var convertData: [String: Any] {
        get {
            var _dicData = [String: Any]()
            _dicData.updateValue(type, forKey: "type")
            _dicData.updateValue(did, forKey: "did")
            _dicData.updateValue(enc, forKey: "enc")
            
            if let _cpee = cpee {
                _dicData.updateValue(_cpee, forKey: "cpee")
            }
            if let _cpoo = cpoo {
                _dicData.updateValue(_cpoo, forKey: "cpoo")
            }
            if let _cabn = cabn {
                _dicData.updateValue(_cabn, forKey: "cabn")
            }
            if let _cfart = cfart {
                _dicData.updateValue(_cfart, forKey: "cfart")
            }
            if let _cdet = cdet {
                _dicData.updateValue(_cdet, forKey: "cdet")
            }
            if let _catt = catt {
                _dicData.updateValue(_catt, forKey: "catt")
            }
            if let _lpeet = lpeet {
                _dicData.updateValue(_lpeet, forKey: "lpeet")
            }
            if let _lpoot = lpoot {
                _dicData.updateValue(_lpoot, forKey: "lpoot")
            }
            if let _labnt = labnt {
                _dicData.updateValue(_labnt, forKey: "labnt")
            }
            if let _lfart = lfart {
                _dicData.updateValue(_lfart, forKey: "lfart")
            }
            if let _ldett = ldett {
                _dicData.updateValue(_ldett, forKey: "ldett")
            }
            if let _lattt = lattt {
                _dicData.updateValue(_lattt, forKey: "lattt")
            }
            return _dicData
        }
    }
}

class Send_SetDeviceStatusForAutoPollingNoti : SendBase {
    var aid : Int = 0
    var token : String = ""
    var data : Array<SendSensorStatusForAutoPollingNotiInfo> = Array()
    
    override init() {
        super.init()
        pkt = .SetDeviceStatus
    }
    
    override func convert() -> [String: Any] {
        var _dic = [String: Any]()
        _dic.updateValue(pkt.rawValue, forKey: "pkt")
        _dic.updateValue(aid, forKey: "aid")
        _dic.updateValue(token, forKey: "token")
        
        var _array = [Any]()
        for item in data {
            _array.append(item.convertData)
        }
        _dic.updateValue(_array, forKey: "data")
        return _dic
    }
}

class Receive_SetDeviceStatusForAutoPollingNoti : ReceiveBase {
    override init(_ json: JSON) {
        super.init(json)
    }
}

class Send_AvailableSerialNumber : SendBase {
    var aid : Int = 0
    var token : String = ""
    var type: Int = 0
    var did: Int = 0
    var srl: String = ""
    
    override init() {
        super.init()
        pkt = .AvailableSerialNumber
    }
    
    override func convert() -> [String: Any] {
        return [
            "pkt" : pkt.rawValue,
            "aid" : aid,
            "token" : token,
            "type" : type,
            "did" : did,
            "srl" : srl,
        ]
    }
}

class Receive_AvailableSerialNumber : ReceiveBase {
    override init(_ json: JSON) {
        super.init(json)
    }
}

class Send_SetSleepMode : SendBase {
    var aid : Int = 0
    var token : String = ""
    var did : Int = 0
    var enc : String = ""
    var is_start: Int?
    var time: String = ""
    var finish_time: String?
    var sleep_type: Int?
    var nid: Int?
    var edit_type: Int?
    var memo: String?
    
    override init() {
        super.init()
        pkt = .SetSleepMode
    }
    
    override func convert() -> [String: Any] {
        var _dicData = [String: Any]()
        _dicData.updateValue(pkt.rawValue, forKey: "pkt")
        _dicData.updateValue(aid, forKey: "aid")
        _dicData.updateValue(token, forKey: "token")
        _dicData.updateValue(did, forKey: "did")
        _dicData.updateValue(enc, forKey: "enc")
        _dicData.updateValue(time, forKey: "time")
        
        if let _is_start = is_start {
            _dicData.updateValue(_is_start, forKey: "is_start")
        }
        if let _sleep_type = sleep_type {
            _dicData.updateValue(_sleep_type, forKey: "sleep_type")
        }
        if let _nid = nid {
            _dicData.updateValue(_nid, forKey: "nid")
        }
        if let _edit_type = edit_type {
            _dicData.updateValue(_edit_type, forKey: "edit_type")
        }
        if let _memo = memo {
            _dicData.updateValue(_memo, forKey: "memo")
        }
        if let _finish_time = finish_time {
            _dicData.updateValue(_finish_time, forKey: "finish_time")
        }
        
        return _dicData
    }
}

class Receive_SetSleepMode : ReceiveBase {
    override init(_ json: JSON) {
        super.init(json)
    }
}

