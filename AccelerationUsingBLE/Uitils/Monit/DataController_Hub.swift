//
//  HubTotalList.swift
//  Monit
//
//  Created by 맥 on 2017. 11. 7..
//  Copyright © 2017년 맥. All rights reserved.
//

import Foundation

class DataController_Hub: DataController_HubTypesBase {
    override var m_brightController: BrightController {
        get {
            return BrightController(deviceType: .Hub)
        }
    }
    
    override func isConnect(type: DEVICE_LIST_TYPE, did: Int) -> Bool {
        if (Utility.currentReachabilityStatus == .notReachable) {
            return false
        }
        
        if let _status = DataManager.instance.m_userInfo.deviceStatus.m_hubStatus.getInfoByDeviceId(did: did) {
            if (_status.isConnect) {
                return true
            }
        }
        return false
    }
}
