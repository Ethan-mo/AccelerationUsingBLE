//
//  HubStatusInfo.swift
//  Monit
//
//  Created by 맥 on 2017. 9. 25..
//  Copyright © 2017년 맥. All rights reserved.
//

import Foundation

class UserInfo_LampStatus: UserInfo_HubTypesStatusBase {
    override func getInfoByDeviceId(did: Int) -> LampStatusInfo? {
        if (m_hubTypes == nil) {
            return nil
        }
        
        for item in m_hubTypes! {
            if (item.m_did == did) {
                return item as? LampStatusInfo
            }
        }
        return nil
    }
    
    func setDeviceStatus(arrStatus: Array<LampStatusInfo>) {
        for item in arrStatus {
            if let _status = getInfoByDeviceId(did: item.m_did) {
                var _isSend = false
                if (item.m_temp > 0) {
                    _isSend = true
                }
                if (item.m_hum > 0) {
                    _isSend = true
                }
                
                if (_isSend) {
                    let send = Send_SetDeviceStatusForHubTypes()
                    send.isErrorPopupOn = false
                    send.aid = DataManager.instance.m_userInfo.account_id
                    send.token = DataManager.instance.m_userInfo.token
                    send.isIndicator = false
                    
                    if let _userInfo = DataManager.instance.m_dataController.device.getUserInfoByDid(did: item.m_did, type: DEVICE_TYPE.Lamp.rawValue) {
                        let _infoData = SendHubTypesStatusInfo(type: DEVICE_TYPE.Lamp.rawValue, did: item.m_did, enc: _userInfo.enc, brt: nil, clr: nil, pow: nil, onptime: nil, offptime: nil)
                        if (item.m_temp > 0) {
                            _status.m_temp = item.m_temp
                            _infoData.tem = item.m_temp
                        }
                        if (item.m_hum > 0) {
                            _status.m_hum = item.m_hum
                            _infoData.hum = item.m_hum
                        }
                        send.data.append(_infoData)
                        NetworkManager.instance.Request(send) { (json) -> () in
                            let receive = Receive_SetDeviceStatusForHubTypes(json)
                            switch receive.ecd {
                            case .success:
                                break
                            default:
                                Debug.print("[BLE][ERROR] invaild errcod", event: .error)
                            }
                        }
                    }
                    
                }
            }
        }
    }
}
