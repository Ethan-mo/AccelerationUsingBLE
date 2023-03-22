//
//  Peripheral_Controller.swift
//  AccelerationUsingBLE
//
//  Created by 모상현 on 2023/02/08.
//
import Foundation
import CoreBluetooth
import SwiftyJSON

class Peripheral_Controller {

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
        case startConnection = 7
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

    var m_delegate: PeripheralCallback?
    var m_packetController: BlePacket_Controller!
    var m_packetRequest: BlePacket_Request?
    var m_packetCommend: BlePacket_Commend?
    var m_packetSensorToLocal: BlePacket_SensorToLocal?
    //var m_hubConnectionController: HubConnectionController?
    var m_gensorConnectionLogInfo = SensorConnectionLogInfo_Peripheral()
    var m_isLogSend = false
    var m_disConType: DISCONNECT_TYPE = .none
    var m_disConErrorMsg: String = ""
    var m_isStartConnection: Bool = false
    var m_isBatteryMsg: Bool = false
    var m_monitorPacket: AutoPollingInfo?
    var m_isForceDisconnect: Bool = false
    var m_autoPollingNotiController: AutoPollingNotiController?

    var bleInfo: BleInfo? 

    var availableCheckType: Bool {
        get {
            if (m_isForceDisconnect) {
                Debug.print("[BLE][ERROR] availableCheckType force disconnect object", event: .error)
                return false
            }
            return true
        }
    }

    init() {
        m_delegate = PeripheralCallback()
        m_delegate?.m_parent = self
        m_packetController = BlePacket_Controller(parent: self)
        m_packetRequest = BlePacket_Request(parent: self)
        m_packetCommend = BlePacket_Commend(parent: self)
        m_packetSensorToLocal = BlePacket_SensorToLocal(parent: self)
    }

    func changeState(status: STATUS) {
        print(#function)
        m_status = .getInitInfo
        switch m_status {
        case .connecting: break
        case .setInit: setInit()
        case .getInitInfo: getInitInfo()
        case .checkDeviceId: checkDeviceId()
        case .startConnection: startConnection()
        case .connectSuccess: connectSuccess()
        case .connectFail: connectFail()
        default: break
        }
    }


    func setInit() {
        print(#function)
        changeState(status: .getInitInfo)
    }

    func getInitInfo() {
        if let _bleInfo = bleInfo, let _peripheral = m_peripheral {
            _bleInfo.m_adv = _peripheral.name!
        } else {
            changeState(status: .connectFail)
            return
        }
        // autopolling off
        m_packetCommend?.setAutoPollingFirst(isAutoPolling: false)
        m_packetCommend?.setAutoPollingSecond(isAutoPolling: false)

        // get default info
        m_packetRequest!.getDeviceDefaultInfoForInit()
    }


    @objc func disconnectNetwork() {
        changeState(status: .connectFail)
    }

    func checkDeviceId() {
        print(#function)
        print("기본 정보를 모두 불러왔습니다.")
        if let _bleInfo = bleInfo {
            let send = Send_GetDeviceId()
            send.aid = 1004
            send.did = _bleInfo.m_did
            send.token = "token"
            send.type = DEVICE_TYPE.Sensor.rawValue
            send.srl = _bleInfo.m_srl
            send.mac = _bleInfo.m_macAddress
            send.fwv = _bleInfo.m_firmware
            send.iosreg = m_connectStatus == .register ? 1 : 0
            var _deviceName = "Monit"
            if (_bleInfo.m_name.count > 0) {
                _deviceName = _bleInfo.m_name
            }
            send.name = _deviceName

        } else {
            changeState(status: .connectFail)
        }
    }

    func startConnection() {
        print("실행됨⭐️⭐️⭐️⭐️⭐️⭐️⭐️")
        if let _bleInfo = bleInfo {
            let send = Send_StartConnection()

            send.aid = 1004
            send.token = "token"
            // dps 보내지 않음 (서버에서 dps 값은 들어가지 않으므로 받아오면 -1로 온다.)
            let _member = SendSensorStatusInfo(type: DEVICE_TYPE.Sensor.rawValue, did: _bleInfo.m_did, enc: _bleInfo.m_enc, bat: _bleInfo.m_battery, mov: _bleInfo.m_movement, dps: nil, opr: _bleInfo.m_operation, tem: _bleInfo.m_temp, hum: _bleInfo.m_hum, voc: _bleInfo.m_voc, fwv: _bleInfo.m_firmware, con: nil)
            send.data.append(_member)
            print("실행됨⭐️⭐️")
            self.receiveStartConnection()
        } else {
            self.changeState(status: .connectFail)
        }
    }

    func receiveStartConnection() {
        let receive = ReceiveBase()
        m_gensorConnectionLogInfo.m_startConnEcd = receive.m_ecd
        print("💄receive한 ecd의 값은?\(receive.m_ecd)")
        switch receive.ecd {
        case .success:
            print("receiveStartConnection 정상적으로 실행됨")
            changeState(status: .connectSuccess)
        case .sensor_not_found_deviceid, // 위험!! 패킷 응답이 왔으나, 기기에 deviceId가 있으나 서버에 로우가 없다., 또는 시리얼 번호가 일치하지 않는다. (거의 발생하지 않음)
             .sensor_not_found_row:
            self.m_disConType = .startConnection
            deviceIdNotFound()
        default:
            self.m_disConType = .startConnectionEtc
            print("센서연결오류3")
            changeState(status: .connectFail)
            Debug.print("[ERROR] invaild errcod", event: .error)
        }
    }

    func deviceIdNotFound() {
        changeState(status: .connectFail)
    }

    func connectSuccess() {
        Debug.print("[BLE] connectSuccess!!", event: .warning)
        m_isStartConnection = true
//        BleConnectionManager.instance.removeRescanItem(name: m_peripheral!.name!)

        if (m_peripheral == nil) {
            Debug.print("[BLE][ERROR] peripheral is null", event: .error)
            self.m_disConType = .successPheripheralNull
            changeState(status: .connectFail)
            return
        }

        // add store info
        if let _bleInfo = bleInfo {

            // 현재 sensorStatusInfo는 startConnect 보내기전 정보.
            let _value = SensorStatusInfo(did: _bleInfo.m_did, battery: _bleInfo.m_battery, operation: _bleInfo.m_operation, movement: _bleInfo.m_movement, diaperstatus: 0, temp: _bleInfo.m_temp, hum: _bleInfo.m_hum, voc: _bleInfo.m_voc, name: "", bday: "", sex: 0, eat: 0, sens: 0, con: 0, whereConn: 0, voc_avg: 0, dscore: 0, sleep: 0)
        } else {
            self.changeState(status: .connectFail)
            return
        }

//        m_packetCommend?.setKeepAlive(isKeepAlive: true)

        m_autoPollingNotiController = AutoPollingNotiController(ctrl: self);
        m_packetCommend?.setUtcTimeInfo(value: Int64(Utility.timeStamp))

        m_packetCommend?.setAutoPollingFirst(isAutoPolling: true)
        m_packetCommend?.setAutoPollingSecond(isAutoPolling: true)

        m_gensorConnectionLogInfo.m_bleStep = 6
        
        m_monitorPacket = AutoPollingInfo()

        Debug.print("[BLE] connectSuccess!! Finished", event: .warning)
    }

    func connectFail() {
        Debug.print("[BLE][ERROR] connectFail...", event: .error)
        m_packetController?.m_updateTimer?.invalidate()
    }

//    func msgSensorDeviceNotFound() {
//        if (m_connectStatus == .register) {
//            _ = PopupManager.instance.onlyContents(contentsKey: "device_sensor_disconnected", confirmType: .ok, okHandler: { () -> () in
//                UIManager.instance.currentUIReload()
//            })
//        } else {
//            UIManager.instance.currentUIReload()
//        }
//    }

//    func startHubConnection() {
//        if (m_hubConnectionController!.isChangeReadyStatus) {
//            m_hubConnectionController!.changeState(status: .connectReady)
//        }
//    }

    func setDisconnect() {
        m_isForceDisconnect = true
        m_packetController?.m_updateTimer?.invalidate()
    }

//    func sendLog() {
//        if (m_connectStatus == .register && !m_isLogSend) {
//            let _send = Send_SetSensorConnectionLog()
//            _send.aid = DataManager.instance.m_userInfo.account_id
//            _send.token = DataManager.instance.m_userInfo.token
//            _send.data_manager = BleConnectionManager.instance.m_gensorConnectionLogInfo!
//            _send.data_peripheral = m_gensorConnectionLogInfo
//            NetworkManager.instance.Request(_send) { (json) -> () in
//                let receive = Receive_SetSensorConnectionLog(json)
//                switch receive.ecd {
//                case .success: self.m_isLogSend = true
//                default: Debug.print("[ERROR] SetSensorConnectionLog invaild errcod: \(receive.ecd.rawValue)", event: .error)
//                }
//            }
//        }
//    }
}
