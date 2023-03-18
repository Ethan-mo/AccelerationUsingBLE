//
//  HubStatusInfo.swift
//  Monit
//
//  Created by john.lee on 2019. 3. 20..
//  Copyright © 2019년 맥. All rights reserved.
//

import Foundation

class LampStatusInfo: HubTypesStatusInfoBase
{
    var isWifiConnect: Bool {
        get {
            return m_con == 2 ? true : false
        }
    }
}
