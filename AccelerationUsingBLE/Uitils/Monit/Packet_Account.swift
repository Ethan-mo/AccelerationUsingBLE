//
//  Packet_Account.swift
//  Monit
//
//  Created by 맥 on 2017. 8. 29..
//  Copyright © 2017년 맥. All rights reserved.
//

import Foundation
import SwiftyJSON

// init
class Send_Init : SendBase {
    var aid : Int = 0
    var token : String = ""
    var lang : String = ""
    var ltime : String = ""
    var device : String = ""
    var os : Int = 0
    var ver: String = ""
    var atype: Int = 0
    
    override init() {
        super.init()
        pkt = .Init
    }
    
    override func convert() -> [String: Any] {
        return [
            "pkt" : pkt.rawValue,
            "aid" : aid,
            "token" : token,
            "lang" : lang,
            "ltime" : ltime,
            "device" : device,
            "os" : os,
            "ver" : ver,
            "atype" : atype,
        ]
    }
}

class Receive_Init : ReceiveBase {
    var step : Int?
    var rmode : Int?
    var temunit: String?
    
    override init(_ json: JSON) {
        super.init(json)
        self.step = json["step"].intValue
        self.rmode = json["rmode"].intValue
        self.temunit = json["temunit"].stringValue
    }
}

class Send_GetAppData : SendBase {
    var os : Int = 0
    var atype: Int = 0
    
    override init() {
        super.init()
        pkt = .GetAppData
        isEncrypt = false
        isIndicator = false
        url = Config.APP_DATA_WEB_URL
    }
    
    override func convert() -> [String: Any] {
        return [
            "pkt" : pkt.rawValue,
            "os" : os,
            "atype" : atype,
        ]
    }
}

class Receive_GetAppData : ReceiveBase {
    var appdata : String?
    var appdata2 : String?

    override init(_ json: JSON) {
        super.init(json)
        self.appdata = json["appdata"].stringValue
        self.appdata2 = json["appdata2"].stringValue
    }
}

class Send_GetLocalAppData : SendBase {
    var os : Int = 0
    var atype: Int = 0
    
    override init() {
        super.init()
        pkt = .GetLocalAppData
        isEncrypt = false
        isIndicator = false
        url = Config.APP_DATA_WEB_URL
    }
    
    override func convert() -> [String: Any] {
        return [
            "pkt" : pkt.rawValue,
            "os" : os,
            "atype" : atype,
        ]
    }
}

class Receive_GetLocalAppData : ReceiveBase {
    var appdata : String?

    override init(_ json: JSON) {
        super.init(json)
        self.appdata = json["appdata"].stringValue
    }
}

// Sign in
class Send_Signin : SendBase {
    var email : String = ""
    var pw : String = ""
    
    override init() {
        super.init()
        pkt = .Signin
    }
        
    override func convert() -> [String: Any] {
        return [
            "pkt" : pkt.rawValue,
            "email" : email,
            "pw" : pw,
        ]
    }
}

class Receive_Signin : ReceiveBase {
    var aid : Int?
    var token : String?
    var step : Int?
    
    override init(_ json: JSON) {
        super.init(json)
        self.aid = json["aid"].intValue
        self.token = json["token"].stringValue
        self.step = json["step"].intValue
    }
}

// Join 1
class Send_Join1 : SendBase {
    var email : String = ""
    var pw : String = ""
    var lang: String = ""
    var atype: Int = 0
    
    override init() {
        super.init()
        pkt = .Join1
    }
    
    override func convert() -> [String: Any] {
        return [
            "pkt" : pkt.rawValue,
            "email" : email,
            "pw" : pw,
            "lang": lang,
            "atype": atype,
        ]
    }
}

class Receive_Join1 : ReceiveBase {
    var aid : Int?
    var token : String?
    var sid : String?
    
    override init(_ json: JSON) {
        super.init(json)
        self.aid = json["aid"].intValue
        self.token = json["token"].stringValue
        self.sid = json["sid"].stringValue
    }
}

// Join 2
class Send_Join2 : SendBase {
    var aid : Int = 0
    var token : String = ""
    
    override init() {
        super.init()
        pkt = .Join2
    }
    
    override func convert() -> [String: Any] {
        return [
            "pkt" : pkt.rawValue,
            "aid" : aid,
            "token" : token,
        ]
    }
}

class Receive_Join2 : ReceiveBase {
    override init(_ json: JSON) {
        super.init(json)
    }
}

// Join 3
class Send_Join3 : SendBase {
    var aid : Int = 0
    var token : String = ""
    var nick : String = ""
    var bday : String = ""
    var sex : Int = 0
    
    override init() {
        super.init()
        pkt = .Join3
    }
    
    override func convert() -> [String: Any] {
        return [
            "pkt" : pkt.rawValue,
            "aid" : aid,
            "token" : token,
            "nick" : nick,
            "bday" : bday,
            "sex" : sex,
        ]
    }
}

class Receive_Join3 : ReceiveBase {
    override init(_ json: JSON) {
        super.init(json)
    }
}

// Join ResendAuth
class Send_ResendAuth : SendBase {
    var aid : Int = 0
    var token : String = ""
    var lang: String = ""
    var atype: Int = 0
    
    override init() {
        super.init()
        pkt = .ResendAuth
    }
    
    override func convert() -> [String: Any] {
        return [
            "pkt" : pkt.rawValue,
            "aid" : aid,
            "token" : token,
            "lang": lang,
            "atype": atype,
        ]
    }
}

class Receive_ResendAuth : ReceiveBase {
    override init(_ json: JSON) {
        super.init(json)
    }
}

// signout
class Send_Signout : SendBase {
    var aid : Int = 0
    var token : String = ""
    
    override init() {
        super.init()
        pkt = .Signout
    }
    
    override func convert() -> [String: Any] {
        return [
            "pkt" : pkt.rawValue,
            "aid" : aid,
            "token" : token,
        ]
    }
}

class Receive_Signout : ReceiveBase {
    override init(_ json: JSON) {
        super.init(json)
    }
}

class Send_SetAppInfo: SendBase {
    var aid : Int = 0
    var token : String = ""
    var temunit : String = ""
    
    override init() {
        super.init()
        pkt = .SetAppInfo
    }
    
    override func convert() -> [String: Any] {
        return [
            "pkt" : pkt.rawValue,
            "aid" : aid,
            "token" : token,
            "temunit": temunit,
        ]
    }
}

class Receive_SetAppInfo: ReceiveBase {
    override init(_ json: JSON) {
        super.init(json)
    }
}

// change nickname
class Send_ChangeNickname : SendBase {
    var aid : Int = 0
    var token : String = ""
    var nick : String = ""
    
    override init() {
        super.init()
        pkt = .ChangeNickname
    }
    
    override func convert() -> [String: Any] {
        return [
            "pkt" : pkt.rawValue,
            "aid" : aid,
            "token" : token,
            "nick" : nick,
        ]
    }
}

class Receive_ChangeNickname : ReceiveBase {
    override init(_ json: JSON) {
        super.init(json)
    }
}

// change password
class Send_ChangePassword : SendBase {
    var aid : Int = 0
    var token : String = ""
    var pw : String = ""
    
    override init() {
        super.init()
        pkt = .ChangePassword
    }
    
    override func convert() -> [String: Any] {
        return [
            "pkt" : pkt.rawValue,
            "aid" : aid,
            "token" : token,
            "pw" : pw,
        ]
    }
}

class Receive_ChangePassword : ReceiveBase {
    override init(_ json: JSON) {
        super.init(json)
    }
}

// change password V2
class Send_ChangePasswordV2 : SendBase {
    var aid : Int = 0
    var token : String = ""
    var current_pw: String = ""
    var pw : String = ""
    
    override init() {
        super.init()
        pkt = .ChangePasswordV2
    }
    
    override func convert() -> [String: Any] {
        return [
            "pkt" : pkt.rawValue,
            "aid" : aid,
            "token" : token,
            "current_pw" : current_pw,
            "pw" : pw,
        ]
    }
}

class Receive_ChangePasswordV2 : ReceiveBase {
    override init(_ json: JSON) {
        super.init(json)
    }
}

// find password
class Send_FindPassword : SendBase {
    var email : String = ""
    var bday : String = ""
    var sex : Int = 0
    var lang: String = ""
    
    override init() {
        super.init()
        pkt = .FindPasswd
    }
    
    override func convert() -> [String: Any] {
        return [
            "pkt" : pkt.rawValue,
            "email" : email,
            "bday" : bday,
            "sex" : sex,
            "lang": lang,
        ]
    }
}

class Receive_FindPassword : ReceiveBase {
    override init(_ json: JSON) {
        super.init(json)
    }
}

// leave
class Send_Leave: SendBase {
    var aid : Int = 0
    var token : String = ""
    
    override init() {
        super.init()
        pkt = .Leave
    }
    
    override func convert() -> [String: Any] {
        return [
            "pkt" : pkt.rawValue,
            "aid" : aid,
            "token" : token,
        ]
    }
}

class Receive_Leave: ReceiveBase {
    override init(_ json: JSON) {
        super.init(json)
    }
}

// push
class Send_UpdatePush : SendBase {
    var aid: Int = 0
    var token: String = ""
    var push: String = ""
    var ptype: Int = 0
    
    override init() {
        super.init()
        pkt = .UpdatePush
    }
    
    override func convert() -> [String: Any] {
        return [
            "pkt" : pkt.rawValue,
            "aid" : aid,
            "token" : token,
            "push" : push,
            "ptype" : ptype,
        ]
    }
}

class Receive_UpdatePush: ReceiveBase {
    override init(_ json: JSON) {
        super.init(json)
    }
}

// alarm
class Send_SetDeviceAlarmStatus: SendBase {
    var aid : Int = 0
    var token : String = ""
    var type : Int = 0
    var did : Int = 0
    var alm : String = ""
    
    override init() {
        super.init()
        pkt = .SetDeviceAlarmStatus
    }
    
    override func convert() -> [String: Any] {
        return [
            "pkt" : pkt.rawValue,
            "aid" : aid,
            "token" : token,
            "type" : type,
            "did" : did,
            "alm" : alm,
        ]
    }
}

class Receive_SetDeviceAlarmStatus: ReceiveBase {
    override init(_ json: JSON) {
        super.init(json)
    }
}

// alarm common
class Send_SetDeviceAlarmStatusCommon: SendBase {
    var aid : Int = 0
    var token : String = ""
    var type : Int = 0
    var did : Int = 0
    var alm : String = ""
    
    override init() {
        super.init()
        pkt = .SetDeviceAlarmStatusCommon
    }
    
    override func convert() -> [String: Any] {
        return [
            "pkt" : pkt.rawValue,
            "aid" : aid,
            "token" : token,
            "type" : type,
            "did" : did,
            "alm" : alm,
        ]
    }
}

class Receive_SetDeviceAlarmStatusCommon: ReceiveBase {
    override init(_ json: JSON) {
        super.init(json)
    }
}

// get notice
class Send_GetNoticeV2: SendBase {
    var os : Int = Config.OS
    var atype : Int = Config.channelOsNum
    var ver : String = Config.bundleVersion
    var lang : String = Config.lang
    
    override init() {
        super.init()
        pkt = .GetNoticeV2
    }
    
    override func convert() -> [String: Any] {
        return [
            "pkt" : pkt.rawValue,
            "os" : os,
            "atype" : atype,
            "ver" : ver,
            "lang" : lang,
        ]
    }
}

class GetNoticeInfo {
    var _id: Int = 0
    var notice_type: Int = 0
    var title: String = ""
    var contents: String = ""
    var board_type: Int = 0
    var board_id: Int = 0
    
    init (_id: Int?, notice_type: Int?, title: String?, contents: String?, board_type: Int?, board_id: Int?) {
        self._id = _id ?? 0
        self.notice_type = notice_type ?? 0
        self.title = title ?? ""
        self.contents = contents ?? ""
        self.board_type = board_type ?? 0
        self.board_id = board_id ?? 0
    }
}

class Receive_GetNoticeV2: ReceiveBase {
    var data : Array<GetNoticeInfo> = []
    
    override init(_ json: JSON) {
        super.init(json)
        
        let _arrData: Array<JSON> = json["data"].arrayValue
        for item in _arrData {
            let _info = GetNoticeInfo(_id: item["_id"].intValue, notice_type: item["notice_type"].intValue, title: item["title"].stringValue, contents: item["contents"].stringValue, board_type: item["board_type"].intValue, board_id: item["board_id"].intValue)
            data.append(_info)
        }
    }
}

// get latestInfo
class Send_GetLastestInfo: SendBase {
    var os: Int = 0
    var atype: Int = 0
    
    override init() {
        super.init()
        pkt = .GetLatestInfo
    }
    
    override func convert() -> [String: Any] {
        return [
            "pkt" : pkt.rawValue,
            "os" : os,
            "atype" : atype,
        ]
    }
}

class Receive_GetLastestInfo: ReceiveBase {
    var app : String?
    var monit : String?
    var hub : String?
    var lamp: String?
    var monit_force : String?
    var hub_force: String?
    var lamp_force: String?
    
    override init(_ json: JSON) {
        super.init(json)
        self.app = json["app"].stringValue
        self.monit = json["monit"].stringValue
        self.hub = json["hub"].stringValue
        self.lamp = json["lamp"].stringValue
        self.monit_force = json["monit_force"].stringValue
        self.hub_force = json["hub_force"].stringValue
        self.lamp_force = json["lamp_force"].stringValue
    }
}

class Send_YKSignin: SendBase {
    var userid: String = ""
    var token: String = ""
    var time: Int64 = 0
    
    override init() {
        super.init()
        pkt = .YKSignin
    }
    
    override func convert() -> [String: Any] {
        return [
            "pkt" : pkt.rawValue,
            "userid" : userid,
            "token" : token,
            "time" : time,
        ]
    }
}

class Receive_YKSignin: ReceiveBase {
    var aid : Int?
    var token : String?
    var step : Int?
    var sid : String?
    
    override init(_ json: JSON) {
        super.init(json)
        self.aid = json["aid"].intValue
        self.token = json["token"].stringValue
        self.step = json["step"].intValue
        self.sid = json["sid"].stringValue
    }
}

class Send_YKSigninOAuth2: SendBase {
    var id_token: String = ""
    var access_token: String = ""
    var ver: Int = 0
    
    override init() {
        super.init()
        pkt = .YKSigninOAuth2
    }
    
    override func convert() -> [String: Any] {
        return [
            "pkt" : pkt.rawValue,
            "id_token" : id_token,
            "access_token" : access_token,
            "ver" : ver,
        ]
    }
}

class Receive_YKSigninOAuth2: ReceiveBase {
    var aid : Int?
    var token : String?
    var step : Int?
    var sid : String?
    var email: String?
    
    override init(_ json: JSON) {
        super.init(json)
        self.aid = json["aid"].intValue
        self.token = json["token"].stringValue
        self.step = json["step"].intValue
        self.sid = json["sid"].stringValue
        self.email = json["email"].stringValue
    }
}


class Send_RequestBecomeCloudMember: SendBase {
    var aid : Int = 0
    var token : String = ""
    var cid : Int = 0
    
    override init() {
        super.init()
        pkt = .RequestBecomeCloudMember
    }
    
    override func convert() -> [String: Any] {
        return [
            "pkt" : pkt.rawValue,
            "aid" : aid,
            "token" : token,
            "cid" : cid,
        ]
    }
}

class Receive_RequestBecomeCloudMember: ReceiveBase {
    override init(_ json: JSON) {
        super.init(json)
    }
}

// GetPolicy
class Send_GetPolicy: SendBase {
    var aid : Int = 0
    var token : String = ""
    
    override init() {
        super.init()
        pkt = .GetPolicy
    }
    
    override func convert() -> [String: Any] {
        return [
            "pkt" : pkt.rawValue,
            "aid" : aid,
            "token" : token,
        ]
    }
}

class GetPolicyInfo {
    var ptype: Int?
    var agree: Int?
    var time: String?
    
    init (ptype: Int?, agree: Int?, time: String?) {
        self.ptype = ptype
        self.agree = agree
        self.time = time
    }
}

class Receive_GetPolicy: ReceiveBase {
    var data : Array<GetPolicyInfo> = []
    
    override init(_ json: JSON) {
        super.init(json)
        
        let _arrData: Array<JSON> = json["data"].arrayValue
        for item in _arrData {
            let _info = GetPolicyInfo(ptype: item["ptype"].intValue, agree: item["agree"].intValue, time: item["time"].stringValue)
            data.append(_info)
        }
    }
}

// SetPolicy
class Send_SetPolicy: SendBase {
    class SetPolicyInfo {
        var ptype: Int = -1
        var agree: Int = -1
        
        init (ptype: Int, agree: Int) {
            self.ptype = ptype
            self.agree = agree
        }
        
        var convertData: [String: Any] {
            get {
                var _dicData = [String: Any]()
                _dicData.updateValue(ptype, forKey: "ptype")
                _dicData.updateValue(agree, forKey: "agree")
                return _dicData
            }
        }
    }

    var aid : Int = 0
    var token : String = ""
    var data : Array<SetPolicyInfo> = []
    
    override init() {
        super.init()
        pkt = .SetPolicy
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

class Receive_SetPolicy: ReceiveBase {
    override init(_ json: JSON) {
        super.init(json)
    }
}

// ResetPassword
class Send_ResetPassword : SendBase {
    var email : String = ""
    var lang: String = ""
    var atype: Int = 0
    
    override init() {
        super.init()
        pkt = .ResetPassword
    }
    
    override func convert() -> [String: Any] {
        return [
            "pkt" : pkt.rawValue,
            "email" : email,
            "lang": lang,
            "atype": atype,
        ]
    }
}

class Receive_ResetPassword : ReceiveBase {
    override init(_ json: JSON) {
        super.init(json)
    }
}

class Send_GetSensorGraphAverage : SendBase {
    var aid : Int = 0
    var token : String = ""
    var dtype: Int = 0
    var didx: Int = 0
    var stime : String = ""
    var etime : String = ""
    var did : Int = 0

    override init() {
        super.init()
        pkt = .GetSensorGraphAverage
    }
    
    override func convert() -> [String: Any] {
        return [
            "pkt" : pkt.rawValue,
            "aid" : aid,
            "token" : token,
            "did" : did,
            "dtype": dtype,
            "didx": didx,
            "stime" : stime,
            "etime" : etime,
        ]
    }
}

class Receive_GetSensorGraphAverage : ReceiveBase {
    var pee : Double?
    var poo : Double?
    var change : Double?
    var fart : Double?
    
    override init(_ json: JSON) {
        super.init(json)
        self.pee = json["pee"].doubleValue
        self.poo = json["poo"].doubleValue
        self.change = json["change"].doubleValue
        self.fart = json["fart"].doubleValue
    }
}

// GetMaintenance
class Send_GetMaintenance : SendBase {
    var os : Int = 0
    var atype: Int = 0
    
    override init() {
        super.init()
        pkt = .GetMaintenance
    }
    
    override func convert() -> [String: Any] {
        return [
            "pkt" : pkt.rawValue,
            "os" : os,
            "atype": atype,
        ]
    }
}

class Receive_GetMaintenance : ReceiveBase {
    var is_enabled : Int?

    override init(_ json: JSON) {
        super.init(json)
        self.is_enabled = json["is_enabled"].intValue
    }
}

// GetMaintenance_Notice
class Send_GetMaintenance_Notice : SendBase {
    var os : Int = 0
    var atype: Int = 0
    var lang: String = ""
    
    override init() {
        super.init()
        pkt = .GetMaintenance_Notice
    }
    
    override func convert() -> [String: Any] {
        return [
            "pkt" : pkt.rawValue,
            "os" : os,
            "atype": atype,
            "lang": lang,
        ]
    }
}

class Receive_GetMaintenance_Notice : ReceiveBase {
    var title : String?
    var contents: String?
    var from: String?
    var to: String?
    
    override init(_ json: JSON) {
        super.init(json)
        self.title = json["title"].stringValue
        self.contents = json["contents"].stringValue
        self.from = json["from"].stringValue
        self.to = json["to"].stringValue
    }
}

// AccountActvieUser
class Send_AccountActiveUser : SendBase {
    var aid : Int = 0
    
    override init() {
        super.init()
        pkt = .AccountActiveUser
    }
    
    override func convert() -> [String: Any] {
        return [
            "pkt" : pkt.rawValue,
            "aid" : aid,
        ]
    }
}

class Receive_AccountActiveUser : ReceiveBase {
    override init(_ json: JSON) {
        super.init(json)
    }
}

// ChannelEvent
class Send_ChannelEvent : SendBase {
    var aid : Int = 0
    var chtype: Int = 0
    var evttype: Int = 0
    
    override init() {
        super.init()
        pkt = .ChannelEvent
    }
    
    override func convert() -> [String: Any] {
        return [
            "pkt" : pkt.rawValue,
            "aid" : aid,
            "chtype" : chtype,
            "evttype" : evttype,
        ]
    }
}

class Receive_ChannelEvent : ReceiveBase {
    override init(_ json: JSON) {
        super.init(json)
    }
}

// ScreenAnalytics
class Send_ScreenAnalytics : SendBase {
    var aid : Int = 0
    var sctype: Int = 0
    var stime: String?
    var etime: String?
    
    override init() {
        super.init()
        pkt = .ScreenAnalytics
    }
    
    override func convert() -> [String: Any] {
        var _dic = [String: Any]()
        _dic.updateValue(pkt.rawValue, forKey: "pkt")
        _dic.updateValue(aid, forKey: "aid")
        _dic.updateValue(sctype, forKey: "sctype")
        if let _stime = stime {
            _dic.updateValue(_stime, forKey: "stime")
        }
        if let _etime = etime {
            _dic.updateValue(_etime, forKey: "etime")
        }
        return _dic
    }
}

class Receive_ScreenAnalytics : ReceiveBase {
    override init(_ json: JSON) {
        super.init(json)
    }
}

// OAuthGetAuth
class Send_OAuthGetAuth : SendBase {
    var aid : Int = 0
    var token : String = ""

    override init() {
        super.init()
        pkt = .OAuthGetAuth
    }
    
    override func convert() -> [String: Any] {
        return [
            "pkt" : pkt.rawValue,
            "aid" : aid,
            "token" : token,
        ]
    }
}

class Receive_OAuthGetAuth : ReceiveBase {
    var auth_key : String?
    var time : String?
    
    override init(_ json: JSON) {
        super.init(json)
        self.auth_key = json["auth_key"].stringValue
        self.time = json["time"].stringValue
    }
}
