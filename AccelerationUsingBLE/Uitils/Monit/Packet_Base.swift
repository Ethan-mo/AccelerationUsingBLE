//
//  Packet_Base.swift
//  Monit
//
//  Created by 맥 on 2017. 8. 29..
//  Copyright © 2017년 맥. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class SendBase {
    var isIndicator: Bool = true
    var isErrorPopupOn: Bool = false
    var isResending: Bool = false
    var resendingCount: Int = 0
    var existPopupType: String = ""
    var logPrintLevel: LOG_EVENT = .normal
    var isEncrypt: Bool = true
    var pkt : PACKET_TYPE = .None
    var url: String = ""
    func convert() -> [String: Any] { return ["": ""] }
    
    init() {
    }
}

class ReceiveBase {
    var m_ecd: Int = -1
    var ecd : ERR_COD = .unknown
    
    init(_ json: JSON) {
        if (json.rawString() != "") {
            m_ecd = json["ecd"].intValue
            if let _code = ERR_COD(rawValue: json["ecd"].intValue) {
                self.ecd = _code
            }
        }
    }
}
