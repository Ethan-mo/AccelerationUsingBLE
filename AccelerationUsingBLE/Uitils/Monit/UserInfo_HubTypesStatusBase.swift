//
//  HubStatusInfo.swift
//  Monit
//
//  Created by 맥 on 2017. 9. 25..
//  Copyright © 2017년 맥. All rights reserved.
//

import Foundation

class UserInfo_HubTypesStatusBase {
    var m_hubTypes: Array<HubTypesStatusInfoBase>?
    
    func getInfoByDeviceId(did: Int) -> HubTypesStatusInfoBase? {
        return nil
    }
    
    func setUpdateInfo(info: HubTypesStatusInfoBase) {
        if let _hub = m_hubTypes {
            var setIndex = -1
            for (i, item) in _hub.enumerated() {
                if (item.m_did == info.m_did) {
                    setIndex = i
                }
            }
            if (setIndex != -1) {
                m_hubTypes![setIndex] = info
            }
        }
    }
    
    func updateFullStatusInfo(arrStatus: Array<HubTypesStatusInfoBase>) {
        m_hubTypes = arrStatus
        
//        for item in arrStatus {
//            var _status = getInfoByDeviceId(did: item.m_did)
//            if (_status != nil) {
//                _status = item
//            } else {
//                Debug.print("UserInfo_HubStatus >  getInfoByDeviceId > Not Found Item ")
//            }
//        }
    }
    
    func updateStatusInfo(arrStatus: Array<HubTypesStatusInfoBase>) {
        for item in arrStatus {
            let _status = getInfoByDeviceId(did: item.m_did)
            if (_status != nil) {
                _status?.m_power = item.m_power
                _status?.m_bright = item.m_bright
                _status?.m_color = item.m_color
                _status?.m_attached = item.m_attached
                _status?.m_temp = item.m_temp
                _status?.m_hum = item.m_hum
                _status?.m_voc = item.m_voc
                _status?.m_con = item.m_con
            } else {
                Debug.print("UserInfo_HubTypesStatusBase >  getInfoByDeviceId > Not Found Item ", event: .warning)
            }
        }
    }
    
    func isEqualInfo(newStatusInfo: Array<HubTypesStatusInfoBase>?) -> Bool {
        if let _beforeInfo = m_hubTypes {
            if let _newInfo = newStatusInfo {
                for beforeItem in _beforeInfo {
                    var _isFound = false
                    for newItem in _newInfo {
                        if (beforeItem.m_did == newItem.m_did) {
                            _isFound = true
                        }
                    }
                    if (!_isFound) {
                        return false
                    }
                }
                
                for newItem in _newInfo {
                    var _isFound = false
                    for beforeItem in _beforeInfo {
                        if (beforeItem.m_did == newItem.m_did) {
                            _isFound = true
                        }
                    }
                    if (!_isFound) {
                        return false
                    }
                }
            }
        }
        
        return true
    }
}
