//
//  BlePacket_Controller.swift
//  Monit
//
//  Created by 맥 on 2017. 10. 26..
//  Copyright © 2017년 맥. All rights reserved.
//

import Foundation
import CoreBluetooth
import SwiftyJSON

class PeripheralLamp_Controller {

    enum CONNECT_STATUS: Int {
        case retrieve = 0
        case register = 1
        case scan = 2
    }
    
    enum STATUS: Int {
        case none = 0
        case connecting = 1
        case setInit = 2
        case getInitInfo = 4
        case checkDeviceId = 5
        case checkCloudId = 6
        case connectSuccess = 8
        case connectFail = 9
    }
    
    enum DISCONNECT_TYPE: Int {
        case none = 0
        case ble_did = 101
        case ble_name = 102
        case ble_mac = 103
        case ble_serial = 104
        case ble_etc = 105
        case getDeviceId = 201
        case getDeviceIdEtc = 202
        case getCloudId = 203
        case getCloudIdEtc = 204
        case setCloudId = 205
        case setCloudIdEtc = 206
        case startConnection = 207
        case startConnectionEtc = 208
        case successPheripheralNull = 209
        // case successBleNull = 210
        case packetCheck = 301
        case bleDisable = 302
        case battery = 303
        case networkDisconnect = 401
    }
    
    var m_peripheral : CBPeripheral?
    var m_write: CBCharacteristic?

    var m_connectStatus: CONNECT_STATUS = .retrieve
    var m_status: STATUS = .none

    var m_delegate: PeripheralLampCallback?
    var m_packetController: BleLampPacket_Controller!
    var m_packetRequest: BleLampPacket_Request?
    var m_packetCommend: BleLampPacket_Commend?
    var m_packetLampToLocal: BleLampPacket_LampToLocal?
    var m_lampConnectionController: LampConnectionController?
    var m_gensorConnectionLogInfo = SensorConnectionLogInfo_Peripheral()
    var m_isLogSend = false
    var m_disConType: DISCONNECT_TYPE = .none
    var m_disConErrorMsg: String = ""
    var m_isStartConnection: Bool = false
    var m_isBatteryMsg: Bool = false
    var m_isForceDisconnect: Bool = false
    
    var bleInfo: BleLampInfo? {
        get {
            return DataManager.instance.m_userInfo.connectLamp.getLampByPeripheral(peripheral: m_peripheral)
        }
    }
    
    var availableCheckType: Bool {
        get {
            if (m_isForceDisconnect) {
                Debug.print("[BLE_LAMP][ERROR] availableCheckType force disconnect object", event: .error)
                return false
            }
            if (DataManager.instance.m_userInfo.connectLamp.getLampByPeripheral(peripheral: m_peripheral) == nil) {
                Debug.print("[BLE_LAMP][ERROR] availableCheckType null peripheral object", event: .error)
                return false
            }
            return true
        }
    }
    
    init() {
        m_delegate = PeripheralLampCallback()
        m_delegate?.m_parent = self
        m_packetController = BleLampPacket_Controller(parent: self)
        m_packetRequest = BleLampPacket_Request(parent: self)
        m_packetCommend = BleLampPacket_Commend(parent: self)
        m_packetLampToLocal = BleLampPacket_LampToLocal(parent: self)
        m_lampConnectionController = LampConnectionController(parent: self)
    }

    func changeState(status: STATUS) {
        if (!availableCheckType) {
            return
        }
        
        if (status == m_status) {
            return
        }
        m_status = status
        switch status {
        case .connecting: break
        case .setInit: setInit()
        case .getInitInfo: getInitInfo()
        case .checkDeviceId: checkDeviceId()
        case .checkCloudId: checkCloudId()
        case .connectSuccess: connectSuccess()
        case .connectFail: connectFail()
        default: break
        }
    }

//    func checkLowBattery() {
//        if (bleInfo!.m_battery == 0) {
//            _ = PopupManager.instance.onlyContents(contentsKey: "notification_low_battery_detail", confirmType: .ok, okHandler: { () -> () in
//                _ = UIManager.instance.sceneMove(scene: .initView, animation: .coverVertical, isAnimation: false)
//            })
//            m_disConType = .battery
//            changeState(status: .connectFail)
//        } else {
//            changeState(status: .checkDeviceId)
//        }
//    }
    
    func setInit() {
        changeState(status: .getInitInfo)
    }
    
    func getInitInfo() {
        setIndicator(isVisiable: true) // todo. lamp

        if (Utility.currentReachabilityStatus == .notReachable) {
            self.m_disConType = .networkDisconnect
            Debug.print("[BLE_LAMP] >> Network offline", event: .warning)
            _ = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(disconnectNetwork), userInfo: nil, repeats: false)
            _ = PopupManager.instance.onlyContents(contentsKey: "dialog_contents_need_internet_connection", confirmType: .ok, existKey: "offline")
            return
        }
        
        if (m_connectStatus != .register) {
            UIManager.instance.indicatorNoneBlock(isVisiable: true)
        }
        
        if let _bleInfo = bleInfo, let _peripheral = m_peripheral {
            _bleInfo.m_adv = _peripheral.name!
        } else {
            changeState(status: .connectFail)
            return
        }

        // get default info
        m_packetRequest!.getDeviceDefaultInfoForInit()
    }
    
    func setIndicator(isVisiable: Bool) {
//        if let _view = UIManager.instance.rootCurrentView as? DeviceRegisterLampLightViewController {
//            _view.setIndicator(isVisiable: isVisiable)
//        }
    }
    
    @objc func disconnectNetwork() {
        changeState(status: .connectFail)
    }
    
    func checkDeviceId() {
        if let _bleInfo = bleInfo {
            let send = Send_GetDeviceId()
            send.isIndicator = false
            send.logPrintLevel = .warning
            send.aid = DataManager.instance.m_userInfo.account_id
            send.did = _bleInfo.m_did
            send.token = DataManager.instance.m_userInfo.token
            send.type = DEVICE_TYPE.Lamp.rawValue
            send.srl = _bleInfo.m_srl
            send.adv = _bleInfo.m_adv
            send.fwv = _bleInfo.m_firmware
            send.iosreg = m_connectStatus == .register ? 1 : 0
            NetworkManager.instance.Request(send) { (json) -> () in
                self.receiveGetDeviceId(json)
            }
        } else {
            changeState(status: .connectFail)
        }
    }
    
    func receiveGetDeviceId(_ json: JSON) {
        let receive = Receive_GetDeviceId(json)
        m_gensorConnectionLogInfo.m_getDeviceEcd = receive.m_ecd
        m_gensorConnectionLogInfo.m_deviceId = receive.did != nil ? receive.did! : -1
        switch receive.ecd {
        case .success:
            if (receive.did! != 0) {
                m_packetCommend!.setDeviceId(deviceId: receive.did!)
                changeState(status: .checkCloudId)
            } else {
                self.m_disConType = .getDeviceIdEtc
                msgLampDeviceNotFound()
                changeState(status: .connectFail)
                Debug.print("[BLE_LAMP] server did is 0", event: .warning)
            }
        case .sensor_already_register: // 주의!! device는 0인데 db에는 serial이 등록되어있음, db에서 다시 값 가져와서 정상처리
            m_packetCommend!.setDeviceId(deviceId: receive.did!)
            
            // lamp가 시리얼이 깨졌을 경우 서버에서 srl에 값이 들어온다. 들어온 값을 램프에 쓰도록 한다.
            if let _srl = receive.srl, receive.srl != "" {
                m_packetCommend!.setSerialInfo(serial: _srl, completion: { (isSuccess) in
                    self.changeState(status: .connectFail)
                })
            } else {
                changeState(status: .checkCloudId)
            }
        default:
            self.m_disConType = .getDeviceIdEtc
            msgLampDeviceNotFound()
            changeState(status: .connectFail)
            Debug.print("[ERROR] invaild errcod", event: .error)
        }
    }

    // 센서 cid가 0이면 센서 초기화했는데 서버가 안됐을경우나 선서를 강제 초기화 했을경우, 또는 서버도 0일경우(초기화된 센서 연결시) 로컬 정보로 적용
    // 센서 cid가 0이 아니고 서버가 0이면 서버에서 초기화가 됐는데 센서가 초기화 안됐거나 어드민 서버에서 초기화 한것, 서버에서 aid를 바꿔버리면 해당 경로가 된다 로컬 정보로 적용 (어드민에서 초기화) 기타 추가로 정보 입력하는 곳까지 와야 setCloudId를 실행하도록 했기 때문에 그 중간에 이탈이 된다면, 센서 값은 0이 아니고 서버는 0이게 된다.
    // 센서 cid가 0이 아니고 서버가 0이 아니면 서버랑 센서랑 같아야 하므로 서버값으로 덮어 씌운다. 그다음에 내 센서 cid와 내 aid를 비교 하여 내 센서인지 확인한다. (평소 본인소유의 센서 연결 경로), 만약에 어드민에서 서버 aid를 바꿔버리면 주인을 바꾸게 되며 이부분을 타게 된다.
    func checkCloudId() {
        if let _bleInfo = bleInfo {
            if (_bleInfo.m_cid != 0) { // 블루투스 cid가 0이 아니면
                let send = Send_GetCloudId()
                send.isIndicator = false
                send.logPrintLevel = .warning
                send.aid = DataManager.instance.m_userInfo.account_id
                send.token = DataManager.instance.m_userInfo.token
                send.type = DEVICE_TYPE.Lamp.rawValue
                send.did = _bleInfo.m_did
                send.enc = _bleInfo.m_enc
                NetworkManager.instance.Request(send) { (json) -> () in
                    let receive = Receive_GetCloudId(json)
                    self.m_gensorConnectionLogInfo.m_getCloudEcd = receive.m_ecd
                    switch receive.ecd {
                    case .success:
                        if (receive.cid == 0) { // 서버에 있는 값이 0이면 내 aid로 설정
                            self.m_packetCommend!.setCloudId(cloudId: DataManager.instance.m_userInfo.account_id)
                        } else {
                            _bleInfo.m_sid = receive.sid ?? ""
                            _bleInfo.m_name = receive.nick ?? ""
                            self.m_packetCommend!.setCloudId(cloudId: receive.cid!) // 서버에 있는 값으로 처리함. (cloudid가 내것이 아닐경우에도 연결 되어야함.)
                        }
                        self.changeState(status: .connectSuccess)
                    case .sensor_not_found_deviceid, // 위험!! 패킷 응답이 왔으나, 기기에 deviceId가 있으나 서버에 로우가 없다., 또는 시리얼 번호가 일치하지 않는다. (거의 발생하지 않음)
                    .sensor_not_found_row:
                        self.m_disConType = .getCloudId
                        self.deviceIdNotFound()
                    default:
                        self.m_disConType = .getCloudIdEtc
                        self.msgLampDeviceNotFound()
                        self.changeState(status: .connectFail)
                        Debug.print("[ERROR] invaild errcod", event: .error)
                    }
                }
            } else { // 블루투스 cid가 0 이면, 서버에서 값 확인하지 않고 내 aid로 적용한다.
                m_packetCommend!.setCloudId(cloudId: DataManager.instance.m_userInfo.account_id)
                self.changeState(status: .connectSuccess)
            }
        } else {
            self.changeState(status: .connectFail)
        }
    }

    // 내 aid로 서버 설정, 센서 설정한다.
    func setCloudId() {
        if let _bleInfo = bleInfo {
            // 아기 정보 입력에서 실행
            if (_bleInfo.m_cid == DataManager.instance.m_userInfo.account_id) {
                let send = Send_SetCloudId()
                send.isIndicator = false
                send.logPrintLevel = .warning
                send.aid = DataManager.instance.m_userInfo.account_id
                send.token = DataManager.instance.m_userInfo.token
                send.type = DEVICE_TYPE.Lamp.rawValue
                send.did = _bleInfo.m_did
                send.enc = _bleInfo.m_enc
                NetworkManager.instance.Request(send) { (json) -> () in
                    self.receiveSetCloudId(json)
                }
            }
        } else {
            self.changeState(status: .connectFail)
        }
    }
    
    func receiveSetCloudId(_ json: JSON) {
        let receive = Receive_SetCloudId(json)
        m_gensorConnectionLogInfo.m_setCloudEcd = receive.m_ecd
        switch receive.ecd {
        case .success: break
        case .sensor_not_found_deviceid, // 위험!! 패킷 응답이 왔으나, 기기에 deviceId가 있으나 서버에 로우가 없다., 또는 시리얼 번호가 일치하지 않는다. (거의 발생하지 않음)
             .sensor_not_found_row:
            self.m_disConType = .setCloudId
            deviceIdNotFound()
        default:
            self.m_disConType = .setCloudIdEtc
            msgLampDeviceNotFound()
            changeState(status: .connectFail)
            Debug.print("[ERROR] invaild errcod", event: .error)
        }
    }
    
    func deviceIdNotFound() {
        msgLampDeviceNotFound()
        changeState(status: .connectFail)
    }
    
    func connectSuccess() {
        Debug.print("[BLE_LAMP] connectSuccess!!", event: .warning)
        setIndicator(isVisiable: false)
        m_isStartConnection = true
//        BleConnectionLampManager.instance.removeRescanItem(name: m_peripheral!.name!)
        
        if (m_peripheral == nil) {
            Debug.print("[BLE_LAMP][ERROR] peripheral is null", event: .error)
            self.m_disConType = .successPheripheralNull
            msgLampDeviceNotFound()
            changeState(status: .connectFail)
            return
        }

        // add store info
        if let _bleInfo = bleInfo {
            var _storeInfo: StoreConnectedLampInfo?
            if DataManager.instance.m_userInfo.deviceStatus.m_lampStatus.getInfoByDeviceId(did: _bleInfo.m_did) != nil {
                _storeInfo = StoreConnectedLampInfo(adv: m_peripheral!.name!, uuid: m_peripheral!.identifier.uuidString, type: DEVICE_TYPE.Lamp.rawValue, did: _bleInfo.m_did, srl: _bleInfo.m_srl, enc: _bleInfo.m_enc, login_aid: DataManager.instance.m_userInfo.account_id, cid: _bleInfo.m_cid)
            } else {
                _storeInfo = StoreConnectedLampInfo(adv: m_peripheral!.name!, uuid: m_peripheral!.identifier.uuidString, type: DEVICE_TYPE.Lamp.rawValue, did: _bleInfo.m_did, srl: _bleInfo.m_srl, enc: _bleInfo.m_enc, login_aid: DataManager.instance.m_userInfo.account_id, cid: _bleInfo.m_cid)
            }
            DataManager.instance.m_userInfo.storeConnectedLamp.insertOrUpdate(info: _storeInfo!)
        } else {
            self.changeState(status: .connectFail)
            return
        }
        
        UIManager.instance.currentUIReload()
        
        m_gensorConnectionLogInfo.m_bleStep = 6
        sendLog()
        
        if (m_connectStatus != .register) {
            UIManager.instance.indicatorNoneBlock(isVisiable: false)
        }
        
        if let _bleInfo = bleInfo {
//            DataManager.instance.m_dataController.newAlarm.sensorFirmware.initInfo(did: _bleInfo.m_did) // todo. lamp
        } else {
            self.changeState(status: .connectFail)
            return
        }
        
        Debug.print("[BLE_LAMP] connectSuccess!! Finished", event: .warning)
    }
    
    func connectFail() {
        Debug.print("[BLE_LAMP][ERROR] connectFail...", event: .error)
        setIndicator(isVisiable: false)
        
        if (m_connectStatus != .register) {
            UIManager.instance.indicatorNoneBlock(isVisiable: false)
        }
        sendLog()
        if let _peripheral = m_peripheral {
            BleConnectionLampManager.instance.disconnectDevice(peripheral: _peripheral)
        }
        m_packetController?.m_updateTimer?.invalidate()
    }
    
    func msgLampDeviceNotFound() {
        if (m_connectStatus == .register) {
            _ = PopupManager.instance.onlyContents(contentsKey: "device_sensor_disconnected", confirmType: .ok, okHandler: { () -> () in
                UIManager.instance.currentUIReload()
//                _ = UIManager.instance.sceneMove(scene: .initView, animation: .coverVertical, isAnimation: false)
            })
        } else {
            UIManager.instance.currentUIReload()
//            _ = UIManager.instance.sceneMove(scene: .initView, animation: .coverVertical, isAnimation: false)
        }
    }
    
    func startLampConnection() {
        if (m_lampConnectionController!.isChangeReadyStatus) {
            m_lampConnectionController!.changeState(status: .connectSuccess)
        }
    }
    
    func setDisconnect() {
        m_isForceDisconnect = true
        UIManager.instance.indicatorNoneBlock(isVisiable: false)
        m_packetController?.m_updateTimer?.invalidate()
        m_lampConnectionController?.setDisconnect()
    }
    
    func sendLog() {
        return
        
//        if (m_connectStatus == .register && !m_isLogSend) {
//            let _send = Send_SetSensorConnectionLog()
//            _send.aid = DataManager.instance.m_userInfo.account_id
//            _send.token = DataManager.instance.m_userInfo.token
//            _send.data_manager = BleConnectionLampManager.instance.m_gensorConnectionLogInfo!
//            _send.data_peripheral = m_gensorConnectionLogInfo
//            NetworkManager.instance.Request(_send) { (json) -> () in
//                let receive = Receive_SetSensorConnectionLog(json)
//                switch receive.ecd {
//                case .success: self.m_isLogSend = true
//                default: Debug.print("[ERROR] Send_SetSensorConnectionLog invaild errcod: \(receive.ecd.rawValue)", event: .error)
//                }
//            }
//        }
    }
}
