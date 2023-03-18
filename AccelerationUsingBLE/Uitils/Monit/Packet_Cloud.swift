//
//  Packet_Cloud.swift
//  Monit
//
//  Created by 맥 on 2017. 9. 19..
//  Copyright © 2017년 맥. All rights reserved.
//

import Foundation
import SwiftyJSON

// InviteCloudMember
class Send_InviteCloudMember: SendBase {
    var aid : Int = 0
    var token : String = ""
    var sid: String = ""
    var ftype: Int = 0
    
    override init() {
        super.init()
        pkt = .InviteCloudMember
    }
    
    override func convert() -> [String: Any] {
        return [
            "pkt" : pkt.rawValue,
            "aid" : aid,
            "token" : token,
            "sid" : sid,
            "ftype" : ftype,
        ]
    }
}

class Receive_InviteCloudMember: ReceiveBase {
    var aid : Int?
    var nick : String?
    
    override init(_ json: JSON) {
        super.init(json)
        self.aid = json["aid"].intValue
        self.nick = json["nick"].stringValue
    }
}

// DeleteCloudMember
class Send_DeleteCloudMember: SendBase {
    var aid : Int = 0
    var token : String = ""
    var tid: Int = 0
    
    override init() {
        super.init()
        pkt = .DeleteCloudMember
    }
    
    override func convert() -> [String: Any] {
        return [
            "pkt" : pkt.rawValue,
            "aid" : aid,
            "token" : token,
            "tid" : tid,
        ]
    }
}

class Receive_DeleteCloudMember: ReceiveBase {
    override init(_ json: JSON) {
        super.init(json)
    }
}

// LeaveCloud
class Send_LeaveCloud: SendBase {
    var aid : Int = 0
    var token : String = ""
    var tid: Int = 0
    
    override init() {
        super.init()
        pkt = .LeaveCloud
    }
    
    override func convert() -> [String: Any] {
        return [
            "pkt" : pkt.rawValue,
            "aid" : aid,
            "token" : token,
            "tid" : tid,
        ]
    }
}

class Receive_LeaveCloud: ReceiveBase {
    override init(_ json: JSON) {
        super.init(json)
    }
}

class Send_GetCloudNotification: SendBase {
    var token : String = ""
    var time: String = ""
    var aid : Int?
    
    override init() {
        super.init()
        pkt = .GetCloudNotification
    }
    
    override func convert() -> [String: Any] {
        var _dic = [String: Any]()
        _dic.updateValue(pkt.rawValue, forKey: "pkt")
        _dic.updateValue(aid!, forKey: "aid")
        _dic.updateValue(token, forKey: "token")
        _dic.updateValue(time, forKey: "time")
        return _dic
    }
}

class Receive_GetCloudNotification: ReceiveBase {
    var notification: Array<ShareMemberNotiInfo> = Array()
    
    override init(_ json: JSON) {
        super.init(json)
        
        let _arrData: Array<JSON> = json["notification"].arrayValue
        for item in _arrData {
            let _info = ShareMemberNotiInfo(id: 0, noti: item["noti"].intValue, time: item["time"].stringValue, extra: item["extra"].stringValue)
            notification.append(_info)
        }
    }
}
