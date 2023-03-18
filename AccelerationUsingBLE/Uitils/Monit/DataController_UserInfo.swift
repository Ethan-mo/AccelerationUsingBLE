//
//  DataController_UserInfo.swift
//  Monit
//
//  Created by 맥 on 2017. 11. 22..
//  Copyright © 2017년 맥. All rights reserved.
//

import Foundation
import SwiftyJSON

class DataController_UserInfo {
    
    var shareMember = DataController_ShareMember()
    var shareDevice = DataController_ShareDevice()
    
    private var m_updateUserInfoHandler: ((Bool) -> Void)?
    
    func updateUserInfo(handler: @escaping (Bool) -> Void) {
        m_updateUserInfoHandler = handler
        
        let send = Send_GetUserInfo()
        send.isErrorPopupOn = false
        send.aid = DataManager.instance.m_userInfo.account_id
        send.token = DataManager.instance.m_userInfo.token
        send.isIndicator = false
        send.isResending = true
        NetworkManager.instance.Request(send) { (json) -> () in
            self.receiveGetUserInfo(json)
        }
    }
    
    func receiveGetUserInfo(_ json: JSON) {
        let receive = Receive_GetUserInfo(json)
        
        switch receive.ecd {
        case .success:
            DataManager.instance.m_userInfo.email = receive.email
            DataManager.instance.m_userInfo.nick = receive.nick
            DataManager.instance.m_userInfo.bday = receive.bday
            DataManager.instance.m_userInfo.sex = receive.sex
            shareMember.setInit(member: receive.member)
            shareDevice.setInit(device: receive.device)
            m_updateUserInfoHandler?(true)
        default:
            Debug.print("[ERROR] invaild errcod", event: .error)
            m_updateUserInfoHandler?(false)
        }
    }
}
