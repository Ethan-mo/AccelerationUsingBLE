//
//  UserInfo.swift
//  Monit
//
//  Created by 맥 on 2017. 8. 30..
//  Copyright © 2017년 맥. All rights reserved.
//

import Foundation

enum LOCAL_DATA_TYPE {
    case account_id
    case email
    case token
    case short_id
    case nick
    case bday
    case sex
}

class UserInfo {
    var configData = UserInfo_ConfigData()
    var shareMember = UserInfo_ShareMember()
    var shareDevice = UserInfo_ShareDevice()
    var connectSensor = UserInfo_ConnectSensor()
    var connectLamp = UserInfo_ConnectLamp()
    var deviceStatus = UserInfo_DeviceStatus()
    var deviceNoti = UserInfo_DeviceNoti()
    var deviceNotiReady = UserInfo_DeviceNotiReady()
    var shareMemberNoti = UserInfo_ShareMemberNoti()
    var storeConnectedSensor = UserInfo_StoreConnectedSensor()
    var storeConnectedLamp = UserInfo_StoreConnectedLamp()
    var hubGraph = UserInfo_HubGraph()
    var lampGraph = UserInfo_LampGraph()
    var newAlarm = UserInfo_NewAlarm()
    var sensorMovGraph = UserInfo_SensorMovGraph()
    var sensorVocGraph = UserInfo_SensorVocGraph()

    var account_id: Int {
        get { return DataManager.instance.m_configData.getLocalIntAes256(name: "account_id") }
        set { DataManager.instance.m_configData.setLocalAes256(name: "account_id", value: newValue.description) }
    }

    // 로그인, 가입시 저장, userinfo받아온 정보로 덮어씌움
    var email: String {
        get { return DataManager.instance.m_configData.getLocalStringAes256(name: "email") }
        set { DataManager.instance.m_configData.setLocalAes256(name: "email", value: newValue) }
    }
    
    var token: String {
        get { return DataManager.instance.m_configData.getLocalStringAes256(name: "token") }
        set { DataManager.instance.m_configData.setLocalAes256(name: "token", value: newValue) }
    }
    
    // userinfo에 있는 것 사용 (중복되므로)
    var short_id: String {
        get { return DataManager.instance.m_configData.getLocalStringAes256(name: "short_id") }
        set { DataManager.instance.m_configData.setLocalAes256(name: "short_id", value: newValue) }
    }
    
    // userinfo에 있는 것 사용 (중복되므로)
    var nick: String {
        get { return DataManager.instance.m_configData.getLocalStringAes256(name: "nick") }
        set { DataManager.instance.m_configData.setLocalAes256(name: "nick", value: newValue) }
    }
    
    var bday: String {
        get { return DataManager.instance.m_configData.getLocalStringAes256(name: "bday") }
        set { DataManager.instance.m_configData.setLocalAes256(name: "bday", value: newValue) }
    }
    
    var sex: Int {
        get { return DataManager.instance.m_configData.getLocalIntAes256(name: "sex") }
        set { DataManager.instance.m_configData.setLocalAes256(name: "sex", value: newValue.description) }
    }

    var sexString : String {
        get {
            switch SEX(rawValue: self.sex) ?? .man {
            case .man: return "gender_male".localized
            case .women: return "gender_female".localized
            }
        }
    }

    func initInfo() {
        account_id = 0
        email = ""
        token = ""
        short_id = ""
        nick = ""
        bday = ""
        sex = 0
    }

    var isSignin: Bool {
        get {
            if (account_id == 0 || token == "") {
                return false
            }
            return true
        }
    }
    
    var arrPolicy : Array<GetPolicyInfo> = []
}
