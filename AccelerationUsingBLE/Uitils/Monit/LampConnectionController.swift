//
//  HubConnectionController.swift
//  Monit
//
//  Created by 맥 on 2017. 11. 16..
//  Copyright © 2017년 맥. All rights reserved.
//

import Foundation
import SwiftyJSON

class LampConnectionController {
    
    enum STATUS {
        case none
        case connectSuccess
        case connectFail
    }
    
    var m_parent: PeripheralLamp_Controller?
    var m_status: STATUS = .none
    
    var m_updateTimer: Timer?
    var m_timeInterval:Double = 0.1

    var m_apName: String = ""
    var m_apSecurityType: Int = 0
    var m_apIndex: Int = 0
    var m_apPw: String = ""
    var m_isFinishWifi = false
    var m_isConnectionStatus = 0
    var m_scanList = [ScanListInfo]()

    var bleInfo: BleLampInfo? {
        get {
            return m_parent!.bleInfo
        }
    }
    
    var isChangeReadyStatus: Bool {
        get {
            if (m_status == .none || m_status == .connectSuccess) {
                return true
            }
            return false
        }
    }
    
    init (parent: PeripheralLamp_Controller) {
        self.m_parent = parent
    }
    
    func changeState(status: STATUS) {
        if (status != .none) {
            if (!(m_parent?.availableCheckType ?? false)) {
                return
            }
        }

        if (status == m_status) {
            return
        }
        m_status = status
        switch status {
        case .connectSuccess: connectSuccess()
        case .connectFail: connectFail()
        default: break
        }
    }
    
    func setIndicator(isVisiable: Bool) {
        if let _view = UIManager.instance.rootCurrentView as? DeviceRegisterLampLightViewController {
            _view.setIndicator(isVisiable: isVisiable)
        }
    }

    func deviceIdNotFound() {
        msgSensorDeviceNotFound()
        changeState(status: .connectFail)
    }
    
    func connectSuccess() {
        Debug.print("connectSuccess!!", event: .warning)
        setIndicator(isVisiable: false)
    }
    
    func connectFail() {
        Debug.print("[ERROR] connectFail...", event: .error)
        setIndicator(isVisiable: false)
        changeState(status: .none)
    }
    
    func msgSensorDeviceNotFound() {
        _ = PopupManager.instance.onlyContents(contentsKey: "dialog_contents_failed_hub_connection", confirmType: .ok, okHandler: { () -> () in
        })
    }
    
    func setDisconnect() {
        m_updateTimer?.invalidate()
        changeState(status: .none)
    }
}
