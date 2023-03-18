//
//  HubConnectionController.swift
//  Monit
//
//  Created by 맥 on 2017. 11. 16..
//  Copyright © 2017년 맥. All rights reserved.
//

import Foundation
import SwiftyJSON

class ScanListInfo {
    var m_idx: Int = -1
    var m_secuType: Int = 0
    var m_rssi: Int = 0
    var m_apName: String = ""
    
    init (idx: Int, secuType: Int, rssi: Int, apName: String) {
        self.m_idx = idx
        self.m_secuType = secuType
        self.m_rssi = rssi
        self.m_apName = apName
    }
}

class HubConnectionController {
    
    enum STATUS {
        case none
        case connectReady

        case getInitInfo
        case checkDeviceId
        case checkCloudId
        case connectSuccess
        case connectFail
    }
    
    var m_parent: Peripheral_Controller?
    var m_status: STATUS = .none
    
    var m_updateTimer: Timer?
    var m_timeInterval:Double = 0.1
    
    var m_device_id: Int = 0
    var m_cloud_id: Int = 0
    var m_firmware: String = ""
    var m_macAddress: String = ""
    var m_serialNumber: String = ""
    var m_enc: String = ""
    var m_deviceName: String = ""
    var m_apName: String = ""
    var m_apSecurityType: Int = 0
    var m_apIndex: Int = 0
    var m_apPw: String = ""
    var m_isFinishWifi = false
    var m_isConnectionStatus = 0
    var m_sid: String = ""
    var m_scanList = [ScanListInfo]()
    
    var bleInfo: BleInfo? {
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
    
    var isHubConnectCheck: Bool {
        get {
            if (bleInfo!.isHubConnect) {
                return true
            }
            return false
        }
    }
    
    init (parent: Peripheral_Controller) {
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
        case .connectReady: connectReady()
        case .getInitInfo: getInitInfo()
        case .checkDeviceId: checkDeviceId()
        case .checkCloudId: checkCloudId()
        case .connectSuccess: connectSuccess()
        case .connectFail: connectFail()
        default: break
        }
    }
    
    func connectReady() {
        Debug.print("Hub Connect Ready", event: .warning)
        m_updateTimer?.invalidate()
        m_updateTimer = Timer.scheduledTimer(timeInterval: m_timeInterval, target: self, selector: #selector(update), userInfo: nil, repeats: true)
    }
    
    @objc func update() {
        if (isHubConnectCheck) {
            setIndicator(isVisiable: true)
            
            m_updateTimer!.invalidate()
            _ = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(changeGetInitInfo), userInfo: nil, repeats: false)
        }
        
        if (UIManager.instance.rootCurrentView as? DeviceRegisterHubConnectingViewController) == nil {
            m_updateTimer!.invalidate()
            changeState(status: .none)
        }
    }
    
    @objc func changeGetInitInfo() {
        changeState(status: .getInitInfo)
    }

    func setIndicator(isVisiable: Bool) {
        if let _view = UIManager.instance.rootCurrentView as? DeviceRegisterHubConnectingViewController {
            _view.setIndicator(isVisiable: isVisiable)
        }
    }

    func getInitInfo() {
        m_parent!.m_packetRequest!.getDeviceDefaultInfoForHubInit()
    }
    
    func checkDeviceId() {
        let send = Send_GetDeviceId()
        send.isIndicator = false
        send.logPrintLevel = .warning
        send.aid = DataManager.instance.m_userInfo.account_id
        send.did = m_device_id
        send.token = DataManager.instance.m_userInfo.token
        send.type = DEVICE_TYPE.Hub.rawValue
        send.srl = m_serialNumber
        send.mac = m_macAddress
        send.fwv = m_firmware
        var _deviceName = "Monit"
        if (m_deviceName.count > 0) {
            _deviceName = m_deviceName
        }
        send.name = _deviceName
        NetworkManager.instance.Request(send) { (json) -> () in
            self.receiveGetDeviceId(json)
        }
    }
    
    func receiveGetDeviceId(_ json: JSON) {
        let receive = Receive_GetDeviceId(json)
        switch receive.ecd {
        case .success:
            if (receive.did! != 0) {
                m_parent!.m_packetCommend!.setHubDeviceId(deviceId: receive.did!)
                changeState(status: .checkCloudId)
//                setCloudId()
            } else {
                msgSensorDeviceNotFound()
                changeState(status: .connectFail)
                Debug.print("server did is 0", event: .warning)
            }
        case .sensor_already_register: // 주의!! device는 0인데 db에는 serial이 등록되어있음, db에서 다시 값 가져와서 정상처리
            m_parent!.m_packetCommend!.setHubDeviceId(deviceId: receive.did!)
            changeState(status: .checkCloudId)
//            setCloudId()
        default:
            msgSensorDeviceNotFound() // timeout이나, 서버 에러시에는 다른 메시지 출력해 줘야 할 수도 있음.
            changeState(status: .connectFail)
            Debug.print("[ERROR] invaild errcod", event: .error)
        }
    }
    
    func checkCloudId() {
        if (bleInfo!.m_cid != 0) {
            let send = Send_GetCloudId()
            send.isIndicator = false
            send.logPrintLevel = .warning
            send.aid = DataManager.instance.m_userInfo.account_id
            send.token = DataManager.instance.m_userInfo.token
            send.type = DEVICE_TYPE.Hub.rawValue
            send.did = m_device_id
            send.enc = m_enc
            NetworkManager.instance.Request(send) { (json) -> () in
                let receive = Receive_GetCloudId(json)
                switch receive.ecd {
                case .success:
                    if (receive.cid == 0) {
                        self.m_parent!.m_packetCommend!.setHubCloudId(cloudId: DataManager.instance.m_userInfo.account_id)
                    } else {
                        self.m_sid = receive.sid ?? ""
                        self.m_deviceName = receive.nick ?? ""
                        self.m_parent!.m_packetCommend!.setHubCloudId(cloudId: receive.cid!) // 서버에 있는 값으로 처리함. (cloudid가 내것이 아닐경우에도 연결 되어야함.)
                    }
                    self.changeState(status: .connectSuccess)
                case .sensor_not_found_deviceid, // 위험!! 패킷 응답이 왔으나, 기기에 deviceId가 있으나 서버에 로우가 없다., 또는 시리얼 번호가 일치하지 않는다. (거의 발생하지 않음)
                .sensor_not_found_row:
                    self.deviceIdNotFound()
                default:
                    self.msgSensorDeviceNotFound()
                    self.changeState(status: .connectFail)
                    Debug.print("[ERROR] invaild errcod", event: .error)
                }
            }
        } else {
            self.m_parent!.m_packetCommend!.setHubCloudId(cloudId: DataManager.instance.m_userInfo.account_id)
            self.changeState(status: .connectSuccess)
        }
    }
    
    func setCloudId() {
        if (m_cloud_id == DataManager.instance.m_userInfo.account_id) {
            let send = Send_SetCloudId()
            send.isIndicator = false
            send.logPrintLevel = .warning
            send.aid = DataManager.instance.m_userInfo.account_id
            send.token = DataManager.instance.m_userInfo.token
            send.type = DEVICE_TYPE.Hub.rawValue
            send.did = m_device_id
            send.enc = m_enc
            NetworkManager.instance.Request(send) { (json) -> () in
                self.receiveSetCloudId(json)
            }
        }
    }
    
    func receiveSetCloudId(_ json: JSON) {
        let receive = Receive_SetCloudId(json)
        switch receive.ecd {
        case .success: break
        case .sensor_not_found_deviceid, // 위험!! 패킷 응답이 왔으나, 기기에 deviceId가 있으나 서버에 로우가 없다., 또는 시리얼 번호가 일치하지 않는다. (거의 발생하지 않음)
        .sensor_not_found_row:
            deviceIdNotFound()
        default:
            msgSensorDeviceNotFound()
            changeState(status: .connectFail)
            Debug.print("[ERROR] invaild errcod", event: .error)
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
//        _ = PopupManager.instance.onlyContents(contentsKey: "dialog_contents_failed_hub_connection", confirmType: .ok, okHandler: { () -> () in
//        })
        let _param = UIManager.instance.getBoardParamSensorIntoHub()
        _ = PopupManager.instance.withErrorCode(codeString: "[Code200] ", linkURL: "\(Config.BOARD_DEFAULT_URL)\(_param)", contentsKey: "dialog_contents_failed_hub_connection", confirmType: .ok)
    }
    
    func setDisconnect() {
        m_updateTimer?.invalidate()
        changeState(status: .none)
    }
}
