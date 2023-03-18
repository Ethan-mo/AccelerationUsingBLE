//
//  HubStatusInfo.swift
//  Monit
//
//  Created by 맥 on 2017. 9. 25..
//  Copyright © 2017년 맥. All rights reserved.
//

import Foundation

class UserInfo_HubStatus: UserInfo_HubTypesStatusBase {
    override func getInfoByDeviceId(did: Int) -> HubStatusInfo? {
        if (m_hubTypes == nil) {
            return nil
        }
        
        for item in m_hubTypes! {
            if (item.m_did == did) {
                return item as? HubStatusInfo
            }
        }
        return nil
    }
}
