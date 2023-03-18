//
//  Packet_DeviceWithWidget.swift
//  widget
//
//  Created by john.lee on 2019. 3. 20..
//  Copyright © 2019년 맥. All rights reserved.
//

import Foundation
import SwiftyJSON

class Send_GetDeviceStatus : SendBase {
    var aid : Int = 0
    var token : String = ""
    
    override init() {
        super.init()
        pkt = .GetDeviceStatus
    }
    
    override func convert() -> [String: Any] {
        return [
            "pkt" : pkt.rawValue,
            "aid" : aid,
            "token" : token,
        ]
    }
}

class Receive_GetDeviceStatus: ReceiveBase {
    var arrSensorStatusInfo: Array<SensorStatusInfo> = Array()
    var arrHubStatusInfo: Array<HubStatusInfo> = Array()
    var arrLampStatusInfo: Array<LampStatusInfo> = Array()
    
    override init(_ json: JSON) {
        super.init(json)
        
        let _arrData: Array<JSON> = json["data"].arrayValue
        for item in _arrData {
            if (item["type"].intValue == DEVICE_TYPE.Sensor.rawValue) {
                let _sensor = SensorStatusInfo(did: item["did"].intValue, battery: item["bat"].intValue, operation: item["opr"].intValue, movement: item["mov"].intValue, diaperstatus: item["dps"].intValue, temp: 0, hum: 0, voc: 0, name: "", bday: "", sex: 0, eat: 0, sens: 0, con: item["con"].intValue, whereConn: item["where"].intValue, voc_avg: item["voc_avg"].intValue, dscore: item["dscore"].intValue, sleep: item["sleep"].intValue)
                arrSensorStatusInfo.append(_sensor)
            } else if (item["type"].intValue == DEVICE_TYPE.Hub.rawValue) {
                let _hub = HubStatusInfo(did: item["did"].intValue, name: "", power: item["pow"].intValue, bright: item["brt"].intValue, color: item["clr"].intValue, attached: item["att"].intValue, temp: item["ctem"].intValue, hum: item["chum"].intValue, voc: item["cvoc"].intValue, ap: "", apse: "", tempmax: 0, tempmin: 0, hummax: 0, hummin: 0, offt: "", onnt: "", con: item["con"].intValue, offptime: "", onptime: "")
                arrHubStatusInfo.append(_hub)
            } else if (item["type"].intValue == DEVICE_TYPE.Lamp.rawValue) {
                let _lamp = LampStatusInfo(did: item["did"].intValue, name: "", power: item["pow"].intValue, bright: item["brt"].intValue, color: item["clr"].intValue, attached: item["att"].intValue, temp: item["ctem"].intValue, hum: item["chum"].intValue, voc: item["cvoc"].intValue, ap: "", apse: "", tempmax: 0, tempmin: 0, hummax: 0, hummin: 0, offt: "", onnt: "", con: item["con"].intValue, offptime: "", onptime: "")
                arrLampStatusInfo.append(_lamp)
            }
        }
    }
}

class Send_GetDeviceFullStatus : SendBase {
    var aid : Int = 0
    var token : String = ""
    
    override init() {
        super.init()
        pkt = .GetDeviceFullStatus
    }
    
    override func convert() -> [String: Any] {
        return [
            "pkt" : pkt.rawValue,
            "aid" : aid,
            "token" : token,
        ]
    }
}

class Receive_GetDeviceFullStatus: ReceiveBase {
    var arrSensorStatusInfo: Array<SensorStatusInfo> = Array()
    var arrHubStatusInfo: Array<HubStatusInfo> = Array()
    var arrLampStatusInfo: Array<LampStatusInfo> = Array()
    
    override init(_ json: JSON) {
        super.init(json)
        
        let _arrData: Array<JSON> = json["data"].arrayValue
        for item in _arrData {
            if (item["type"].intValue == DEVICE_TYPE.Sensor.rawValue) {
                let _sensor = SensorStatusInfo(did: item["did"].intValue, battery: item["bat"].intValue, operation: item["opr"].intValue, movement: item["mov"].intValue, diaperstatus: item["dps"].intValue, temp: 0, hum: 0, voc: 0, name: item["name"].stringValue, bday: item["bday"].stringValue, sex: item["sex"].intValue, eat: item["eat"].intValue, sens: item["sens"].intValue, con: item["con"].intValue, whereConn: item["where"].intValue, voc_avg: item["voc_avg"].intValue, dscore: item["dscore"].intValue, sleep: item["sleep"].intValue)
                arrSensorStatusInfo.append(_sensor)
            } else if (item["type"].intValue == DEVICE_TYPE.Hub.rawValue) {
                let _hub = HubStatusInfo(did: item["did"].intValue, name: item["name"].stringValue, power: item["pow"].intValue, bright: item["brt"].intValue, color: item["clr"].intValue, attached: item["att"].intValue, temp: item["ctem"].intValue, hum: item["chum"].intValue, voc: item["cvoc"].intValue, ap: item["apn"].stringValue, apse: item["aps"].stringValue, tempmax: item["tmax"].intValue, tempmin: item["tmin"].intValue, hummax: item["hmax"].intValue, hummin: item["hmin"].intValue, offt: item["offt"].stringValue, onnt: item["onnt"].stringValue, con: item["con"].intValue, offptime: item["offptime"].stringValue, onptime: item["onptime"].stringValue)
                arrHubStatusInfo.append(_hub)
            } else if (item["type"].intValue == DEVICE_TYPE.Lamp.rawValue) {
                let _lamp = LampStatusInfo(did: item["did"].intValue, name: item["name"].stringValue, power: item["pow"].intValue, bright: item["brt"].intValue, color: item["clr"].intValue, attached: item["att"].intValue, temp: item["ctem"].intValue, hum: item["chum"].intValue, voc: item["cvoc"].intValue, ap: item["apn"].stringValue, apse: item["aps"].stringValue, tempmax: item["tmax"].intValue, tempmin: item["tmin"].intValue, hummax: item["hmax"].intValue, hummin: item["hmin"].intValue, offt: item["offt"].stringValue, onnt: item["onnt"].stringValue, con: item["con"].intValue, offptime: item["offptime"].stringValue, onptime: item["onptime"].stringValue)
                arrLampStatusInfo.append(_lamp)
            }
        }
    }
}

// GetUserInfo
class Send_GetUserInfo : SendBase {
    var aid : Int = 0
    var token : String = ""
    
    override init() {
        super.init()
        pkt = .GetUserInfo
    }
    
    override func convert() -> [String: Any] {
        return [
            "pkt" : pkt.rawValue,
            "aid" : aid,
            "token" : token,
        ]
    }
}

class Receive_GetUserInfo : ReceiveBase {
    var email : String = ""
    var nick : String = ""
    var bday : String = ""
    var sex : Int = 0
    var member : Array<UserInfoMember> = Array()
    var device : Array<UserInfoDevice> = Array()
    
    override init(_ json: JSON) {
        super.init(json)
        self.email = json["email"].stringValue
        self.nick = json["nick"].stringValue
        self.bday = json["bday"].stringValue
        self.sex = json["sex"].intValue
        
        let _arrMember: Array<JSON> = json["member"].arrayValue
        for unit in _arrMember {
            let _member = UserInfoMember(cid: unit["cid"].intValue, aid: unit["aid"].intValue, nick: unit["nick"].stringValue, sid: unit["sid"].stringValue, ftype: unit["ftype"].intValue)
            member.append(_member)
        }
        
        let _arrDevice: Array<JSON> = json["device"].arrayValue
        for unit in _arrDevice {
            let _member = UserInfoDevice(cid: unit["cid"].intValue, did: unit["did"].intValue, type: unit["type"].intValue, name: unit["name"].stringValue, srl: unit["srl"].stringValue, fwv: unit["fwv"].stringValue, mac: unit["mac"].stringValue, alm: unit["alm"].stringValue, adv: unit["adv"].stringValue)
            device.append(_member)
        }
    }
}

class Send_SetHubBrightControl : SendBase {
    var aid : Int = 0
    var token : String = ""
    var type : Int = 2
    var did : Int = 0
    var enc : String = ""
    var brt: Int?
    var clr: Int?
    var pow: Int?
    var onptime: String?
    var offptime: String?
    
    override init() {
        super.init()
        pkt = .SetHubBrightControl
    }
    
    override func convert() -> [String: Any] {
        var _dicData = [String: Any]()
        _dicData.updateValue(pkt.rawValue, forKey: "pkt")
        _dicData.updateValue(aid, forKey: "aid")
        _dicData.updateValue(token, forKey: "token")
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
        return _dicData
    }
}

class Receive_SetHubBrightControl : ReceiveBase {
    override init(_ json: JSON) {
        super.init(json)
    }
}
