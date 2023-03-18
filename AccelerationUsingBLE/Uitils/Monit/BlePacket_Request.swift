//
//  BlePacket_Request_Sensor.swift
//  Monit
//
//  Created by 맥 on 2017. 11. 15..
//  Copyright © 2017년 맥. All rights reserved.
//

import UIKit

class PacketSensorStatusInfo {
    var m_movement: Int?
    var m_diaperstatus: Int?
    var m_operation: Int?
    
    init(movement: Int, diaperstatus: Int, operation: Int) {
        self.m_movement = movement
        self.m_diaperstatus = diaperstatus
        self.m_operation = operation
    }
}

class BlePacket_Request {
    var m_parent: Peripheral_Controller?
    
    init (parent: Peripheral_Controller) {
        self.m_parent = parent
    }
    
    var bleInfo: BleInfo? {
        get {
            return m_parent!.bleInfo
        }
    }
    
    var hubInfo: HubConnectionController? {
        get {
            return m_parent!.m_hubConnectionController
        }
    }
    
    func writeRequest(communicationType: BLE_COMMUNICATION_TYPE, packetType: [BlePacketType], completion: ActionResultBlePacketInfo?) {
        m_parent!.m_packetController!.writeRequest(communicationType: communicationType, packetType: packetType, completion: completion)
    }

    func getDeviceDefaultInfoForInit() {
        writeRequest(communicationType: .request, packetType: [.DEVICE_ID, .CLOUD_ID, .FIRMWARE_VERSION, .BABY_INFO], completion: { (blePacketInfo) in
            if let _blePacketInfo = blePacketInfo {
                if (_blePacketInfo.m_status == .success) {
                    self.m_parent!.m_gensorConnectionLogInfo.m_bleStep = 1
                    self.receiveAnalyze(blePacketInfo: blePacketInfo)
                    self.getDeviceNameForInit()
                } else {
                    let _param = UIManager.instance.getBoardParam(board: BOARD_TYPE.connect_device_sensor, boardId: 29)
                    _ = PopupManager.instance.withErrorCode(codeString: "[Code105]", linkURL: "\(Config.BOARD_DEFAULT_URL)\(_param)", contentsKey: "dialog_contents_sensor_need_reseting_description", confirmType: Config.IS_AVOBE_OS13 ? .ok : .cancleSetup, okHandler: { () -> () in
                        self.m_parent!.m_disConType = .ble_did
                        self.connectFail()
                        if (!Config.IS_AVOBE_OS13) {
                            _ = Utility.urlOpen(UIManager.instance.getMoveBluetoothSetting())
                        }
                    }, cancleHandler: { () -> () in
                        self.m_parent!.m_disConType = .ble_did
                        self.connectFail()
                    })
                    return
                }
            }  else {
                _ = PopupManager.instance.onlyContents(contentsKey: "dialog_contents_sensor_need_reseting_description", confirmType: Config.IS_AVOBE_OS13 ? .ok : .cancleSetup, okHandler: { () -> () in
                    self.m_parent!.m_disConType = .ble_did
                    self.connectFail()
                    if (!Config.IS_AVOBE_OS13) {
                        _ = Utility.urlOpen(UIManager.instance.getMoveBluetoothSetting())
                    }
                }, cancleHandler: { () -> () in
                    self.m_parent!.m_disConType = .ble_did
                    self.connectFail()
                })
                return
            }
        })
    }
    
    func getDeviceNameForInit() {
        writeRequest(communicationType: .request, packetType: [.DEVICE_NAME], completion: { (blePacketInfo) in
            if let _blePacketInfo = blePacketInfo {
                if (_blePacketInfo.m_status == .success) {
                    self.m_parent!.m_gensorConnectionLogInfo.m_bleStep = 2
                    let _deviceName = BlePacket_Utility.getString(_blePacketInfo.m_receivePacket)
                    self.bleInfo!.m_name = _deviceName.count != 0 ? _deviceName : "Monit"
                    self.getMacAddressForInit()
                } else {
                    self.m_parent!.m_disConType = .ble_name
                    self.connectFail()
                    return
                }
            } else {
                self.m_parent!.m_disConType = .ble_name
                self.connectFail()
                return
            }
        })
    }
    
    func getMacAddressForInit() {
        writeRequest(communicationType: .request, packetType: [.MAC_ADDRESS], completion: { (blePacketInfo) in
            if let _blePacketInfo = blePacketInfo {
                if (_blePacketInfo.m_status == .success) {
                    self.m_parent!.m_gensorConnectionLogInfo.m_bleStep = 3
                    self.receiveAnalyze(blePacketInfo: blePacketInfo)
                    
                    if (self.bleInfo!.m_macAddress.count != 17) {
                        self.m_parent!.m_disConType = .ble_mac
                        self.connectFail()
                        return
                    }
                    self.getSerialNumberForInit()
                } else {
                    self.m_parent!.m_disConType = .ble_mac
                    self.connectFail()
                    return
                }
            } else {
                self.m_parent!.m_disConType = .ble_mac
                self.connectFail()
                return
            }
        })
    }
    
    func getSerialNumberForInit() {
        writeRequest(communicationType: .request, packetType: [.SERIAL_NUMBER], completion: { (blePacketInfo) in
            if let _blePacketInfo = blePacketInfo {
                if (_blePacketInfo.m_status == .success) {
                    self.m_parent!.m_gensorConnectionLogInfo.m_bleStep = 4
                    self.receiveAnalyze(blePacketInfo: blePacketInfo)
                    
                    if (self.bleInfo!.m_srl.count <= 4) {
                        self.m_parent!.m_disConType = .ble_serial
                        self.connectFail()
                        return
                    }
                    self.getEtcForInit()
                } else {
                    self.m_parent!.m_disConType = .ble_serial
                    self.connectFail()
                    return
                }
            } else {
                self.m_parent!.m_disConType = .ble_serial
                self.connectFail()
                return
            }
        })
    }
    
    func getEtcForInit() {
        writeRequest(communicationType: .request, packetType: [.SENSOR_STATUS, .BATTERY, .TEMPERATURE, .HUMIDITY, .VOC], completion: { (blePacketInfo) in
            self.m_parent!.m_gensorConnectionLogInfo.m_bleStep = 5
            self.receiveAnalyze(blePacketInfo: blePacketInfo)
            self.m_parent!.m_packetCommend!.setCurrentUtcForInit()
        })
    }
    
    func receiveAnalyze(blePacketInfo: BlePacketInfo?) {
        if (blePacketInfo != nil) {
            if (blePacketInfo!.m_status != .success) {
                self.connectFail()
                return
            }
        } else {
            self.connectFail()
            return
        }
        
        let _arrData:[[UInt8]] = blePacketInfo!.m_receivePacket
        if (_arrData.count == 1) {
            let _data = _arrData[0]
            if (BlePacket_Utility.isLongPacket(_data)) { // Long Packet
                Debug.print("[BLE] longPacket", event: .warning)
                receiveRequestType(data: _data)
            } else { // Short Packet
                if (_data.count > 4) { // chunk byte[] every 4 bytes
                    Debug.print("[BLE] chunkpacket", event: .warning)
                    var _length: Int = 0;
                    while(_length < _data.count) {
                        var _chunkedData = [UInt8]()
                        _chunkedData.append(_data[_length])
                        _chunkedData.append(_data[_length + 1])
                        _chunkedData.append(_data[_length + 2])
                        _chunkedData.append(_data[_length + 3])
                        _length += 4;
                        receiveRequestType(data: _chunkedData)
                    }
                } else {
                    Debug.print("[BLE] shortPacket", event: .warning)
                    receiveRequestType(data: _data)
                }
            }
        } else {
            Debug.print("[BLE][ERROR] packet length error..", event: .error)
        }
    }
    
    func receiveRequestType(data: [UInt8]) {
        if let _type: BlePacketType = BlePacketType(rawValue:data[0]) {
            switch _type {
            case .DEVICE_ID: bleInfo!.m_did = deviceId(data)
            case .CLOUD_ID: bleInfo!.m_cid = cloudId(data)
            case .FIRMWARE_VERSION: bleInfo!.m_firmware = firmwareVersion(data)
            case .BABY_INFO:
                bleInfo!.m_bday = getBabyBirthday(data)
                bleInfo!.m_sex = getBabySex(data)
            case .MAC_ADDRESS: bleInfo!.m_macAddress = macAddress(data)
            case .SERIAL_NUMBER: sensorSerial(data)
            case .SENSOR_STATUS: sensorStatus(data)
            case .BATTERY: battery(data)
            case .TEMPERATURE: bleInfo!.m_temp = temperature(data)
            case .HUMIDITY: bleInfo!.m_hum = humidity(data)
            case .VOC: bleInfo!.m_voc = voc(data)
            default: break
            }
        }
    }
    
    func connectCheck() {
        writeRequest(communicationType: .request, packetType: [.DEVICE_ID], completion: { (blePacketInfo) in
            if let _info = blePacketInfo {
                if (_info.m_status == .success) {
                    return
                }
            }
            
            self.m_parent!.m_disConType = .packetCheck
            self.connectFail()
        })
    }
    
    func deviceId(_ data: [UInt8]) -> Int {
        if (data.count < 4) {
            Debug.print("[BLE] DeviceId Packet is null", event: .warning)
            return -1
        }
        let _getDevice: UInt32 = BlePacket_Utility._getUnsignedValue(data)
        Debug.print("[BLE] DeviceId: \(_getDevice)", event: .warning)
        return Int(_getDevice)
    }
    
    func cloudId(_ data: [UInt8]) -> Int {
        if (data.count < 4) {
            Debug.print("[BLE] CloudId Packet is null", event: .warning)
            return -1
        }
        let _getCloudId: UInt32 = BlePacket_Utility._getUnsignedValue(data)
        Debug.print("[BLE] CloudId: \(_getCloudId)", event: .warning)
        return Int(_getCloudId)
    }
    
    func firmwareVersion(_ data: [UInt8]) -> String {
        if (data.count < 4) {
            Debug.print("[BLE] Firmware Packet is null", event: .warning)
            return ""
        }
        let _getFirmware = "\(0xFF & data[1]).\(0xFF & data[2]).\(0xFF & data[3])"
        Debug.print("[BLE] Firmware: \(_getFirmware)", event: .warning)
        return _getFirmware
    }
    
    func getBabyBirthday(_ packets: [UInt8]) -> String {
        if (packets.count < 4) {
            Debug.print("[BLE] BabyBirthday Packet is null", event: .warning)
            return "000000"
        }
        let _value = BlePacket_Utility._getUnsignedValue(packets) / 10; // Separate birthday from sex
        var _birthday = _value.description
        for _ in 0..<(6 - _birthday.count) {
            _birthday = "0" + _birthday
        }
        Debug.print("[BLE] Birthday: \(_birthday)", event: .warning)
        return _birthday
    }
    
    func getBabySex(_ packets: [UInt8]) -> Int {
        if (packets.count < 4) {
            Debug.print("[BLE] BabySex Packet is null", event: .warning)
            return -1
        }
        let _sex = Int(BlePacket_Utility._getUnsignedValue(packets) % 10) // Separate birthday from sex
        Debug.print("[BLE] Sex: \(_sex)", event: .warning)
        return _sex;
    }

    func macAddress(_ data: [UInt8]) -> String {
        if (data.count < 9) {
            Debug.print("[BLE] MacAddress Packet is null", event: .warning)
            return ""
        }
        var macAddress = ""
        // var byteString = String(data[4], radix: 16)
        var byteString = String(format: "%02X", data[4])
        if (byteString.count > 2) {
            byteString = String(byteString[byteString.index(byteString.endIndex, offsetBy: -2)...])
        }
        macAddress = byteString.uppercased()
        for i in 5..<(data.count) {
            // byteString = String(data[i], radix: 16)
            byteString = String(format: "%02X", data[i])
            if (byteString.count > 2) {
                byteString = String(byteString[byteString.index(byteString.endIndex, offsetBy: -2)...])
            }
            macAddress = byteString.uppercased() + ":" + macAddress
        }
        Debug.print("[BLE] MacAddress: \(macAddress)", event: .warning)
        return macAddress
    }
    
    func serialNumber(_ data: [UInt8]) -> String {
        if (data.count < 13) {
            Debug.print("[BLE] SerialNumber Packet is null", event: .warning)
            return ""
        }
        var sb = [Character]()
        
        for i in 4..<(data.count) {
            if (data[i] == 0x00) { continue }
            sb.append(Character(UnicodeScalar(data[i])))
        }
        Debug.print("[BLE] SerialNumber: \(String(sb))", event: .warning)
        return String(sb)
    }
    
    func sensorStatus(_ data: [UInt8]) {
        if (data.count < 4) {
            Debug.print("[BLE] SensorStatus Packet is null", event: .warning)
            return
        }
        let _sensorStatus = "\(0xFF & data[1])\\\(0xFF & data[2])\\\(0xFF & data[3])"
        Debug.print("[BLE] SensorStatus: \(_sensorStatus)", event: .warning)
        bleInfo!.m_movement = Int(0xFF & data[1])
        bleInfo!.m_diaperstatus = Int(0xFF & data[2])
        bleInfo!.m_operation = Int(0xFF & data[3])
    }
    
    func battery(_ data: [UInt8]) {
        if (data.count < 4) {
            Debug.print("[BLE] Battery Packet is null", event: .warning)
            return
        }
        let _value: UInt32 = BlePacket_Utility._getUnsignedValue(data)
        Debug.print("[BLE] Battery: \(_value)", event: .warning)
        bleInfo!.m_battery = Int(_value)
    }
    
    func sensorSerial(_ data: [UInt8]) {
        let _srl = serialNumber(data)
        if (_srl.count > 0) {
            bleInfo!.m_srl = _srl
            bleInfo!.m_enc = String(_srl[_srl.index(_srl.endIndex, offsetBy: -4)...])
        }
        else {
            Debug.print("[BLE][ERROR] SensorSerial Packet length error", event: .error)
            return
        }
    }
    
    func hubSerial(_ data: [UInt8]) {
        let _srl = serialNumber(data)
        if (_srl.count > 0) {
            hubInfo!.m_serialNumber = _srl
            hubInfo!.m_enc = String(_srl[_srl.index(_srl.endIndex, offsetBy: -4)...])
        }
        else {
            Debug.print("[BLE][ERROR] HubSerial Packet length error", event: .error)
            return
        }
    }
    
    func temperature(_ data: [UInt8]) -> Int {
        if (data.count < 4) {
            Debug.print("[BLE][ERROR] Temperature Packet is null", event: .error)
            return 0
        }
        let _value: UInt32 = BlePacket_Utility._getUnsignedValue(data)
        Debug.print("[BLE] Temperature: \(_value)", event: .warning)
        return Int(_value)
    }
    
    func humidity(_ data: [UInt8]) -> Int {
        if (data.count < 4) {
            Debug.print("[BLE][ERROR] Humidity Packet is null", event: .error)
            return 0
        }
        let _value: UInt32 = BlePacket_Utility._getUnsignedValue(data)
        Debug.print("[BLE] Humidity: \(_value)", event: .warning)
        return Int(_value)
    }
    
    func voc(_ data: [UInt8]) -> Int {
        if (data.count < 4) {
            Debug.print("[BLE][ERROR] Voc Packet is null", event: .error)
            return 0
        }
        let _value: UInt32 = BlePacket_Utility._getUnsignedValue(data)
        Debug.print("[BLE] Voc: \(_value)", event: .warning)
        return Int(_value)
    }
    
    func getSensitive(completion: @escaping ActionResultAny) {
        writeRequest(communicationType: .request, packetType: [.SENSITIVE], completion: { (blePacketInfo) in
            if let _blePacketInfo = blePacketInfo {
                if (_blePacketInfo.m_status == .success) {
                    let _arrData:[[UInt8]] = blePacketInfo!.m_receivePacket
                    if (_arrData.count == 1) {
                        let _value = Int(_arrData[0][1])
                        completion(_value)
                    } else {
                        completion(-1)
                    }
                } else {
                    completion(-1)
                }
            } else {
                completion(-1)
            }
        })
    }
    
    func getVoc(completion: @escaping ActionResultAny) {
        writeRequest(communicationType: .request, packetType: [.VOC], completion: { (blePacketInfo) in
            if let _blePacketInfo = blePacketInfo {
                if (_blePacketInfo.m_status == .success) {
                    let _arrData:[[UInt8]] = blePacketInfo!.m_receivePacket
                    if (_arrData.count == 1) {
                        let _value = Int(_arrData[0][1])
                        completion(_value)
                    } else {
                        completion(-1)
                    }
                } else {
                    completion(-1)
                }
            } else {
                completion(-1)
            }
        })
    }
    
    func updateFirmwareVersion(completion: ActionResultBool?) {
        writeRequest(communicationType: .request, packetType: [.FIRMWARE_VERSION], completion: { (blePacketInfo) in
            if let _blePacketInfo = blePacketInfo {
                if (_blePacketInfo.m_status == .success) {
                    self.receiveAnalyze(blePacketInfo: blePacketInfo)
                    completion?(true)
                    return
                }
            }
            completion?(false)
            return
        })

    }
    
    func getLatestDetectionTime(type: BlePacketType, completion: @escaping ActionResultInt64) {
        writeRequest(communicationType: .request, packetType: [type], completion: { (blePacketInfo) in
            if let _blePacketInfo = blePacketInfo {
                if (_blePacketInfo.m_status == .success) {
                    let _arrData:[[UInt8]] = blePacketInfo!.m_receivePacket
                    Debug.print("[getLatestDetectionTime!!!]: \(_arrData)", event: .dev)
                    if (_arrData.count == 1) {
                        // 예외처리해야함
                        let _array : [UInt8] = [_arrData[0][7], _arrData[0][6], _arrData[0][5], _arrData[0][4]]
                        let _data = Data(bytes: _array)
                        let _value = UInt32(bigEndian: _data.withUnsafeBytes { $0.pointee })
                        completion(Int64(_value))
                    } else {
                        completion(-1)
                    }
                } else {
                    completion(-1)
                }
            } else {
                completion(-1)
            }
        })
    }
    
    func connectFail() {
        m_parent!.msgSensorDeviceNotFound()
        m_parent!.changeState(status: .connectFail)
    }
    
    func finishInitialize(isSuccess:Bool, completion: ActionResultAny?) {
        if (completion != nil) {
            completion?(isSuccess)
        }
    }
    
    /// for hub
    func getDeviceDefaultInfoForHubInit() {
        writeRequest(communicationType: .request, packetType: [.HUB_TYPES_DEVICE_ID, .HUB_TYPES_CLOUD_ID, .HUB_TYPES_FIRMWARE_VERSION], completion: { (blePacketInfo) in
            if (self.m_parent!.bleInfo!.m_did == 0) {
                self.connectFailForHub()
                return
            } else {
                self.receiveAnalyzeForHub(blePacketInfo: blePacketInfo)
                self.getMacAddressForHubInit()
            }
        })
    }
    
    func getMacAddressForHubInit() {
        writeRequest(communicationType: .request, packetType: [.HUB_TYPES_MAC_ADDRESS], completion: { (blePacketInfo) in
            self.receiveAnalyzeForHub(blePacketInfo: blePacketInfo)
            self.getSerialNumberForHubInit()
        })
    }
    
    func getSerialNumberForHubInit() {
        writeRequest(communicationType: .request, packetType: [.HUB_TYPES_SERIAL_NUMBER], completion: { (blePacketInfo) in
            self.receiveAnalyzeForHub(blePacketInfo: blePacketInfo)
            self.m_parent!.m_hubConnectionController!.changeState(status: .checkDeviceId)
        })
    }
    
    func receiveAnalyzeForHub(blePacketInfo: BlePacketInfo?) {
        if (blePacketInfo != nil) {
            if (blePacketInfo!.m_status != .success) {
                self.connectFailForHub()
                return
            }
        } else {
            self.connectFailForHub()
            return
        }
        
        let _arrData:[[UInt8]] = blePacketInfo!.m_receivePacket
        if (_arrData.count == 1) {
            let _data = _arrData[0]
            if (BlePacket_Utility.isLongPacket(_data)) { // Long Packet
                Debug.print("[BLE] longPacket", event: .warning)
                receiveRequestTypeForHub(data: _data)
            } else { // Short Packet
                if (_data.count > 4) { // chunk byte[] every 4 bytes
                    Debug.print("[BLE] chunkpacket", event: .warning)
                    var _length: Int = 0;
                    while(_length < _data.count) {
                        var _chunkedData = [UInt8]()
                        _chunkedData.append(_data[_length])
                        _chunkedData.append(_data[_length + 1])
                        _chunkedData.append(_data[_length + 2])
                        _chunkedData.append(_data[_length + 3])
                        _length += 4;
                        receiveRequestTypeForHub(data: _chunkedData)
                    }
                } else {
                    Debug.print("[BLE] shortPacket", event: .warning)
                    receiveRequestTypeForHub(data: _data)
                }
            }
        } else {
            Debug.print("[BLE][ERROR] packet length error..", event: .error)
        }
    }
    
    func receiveRequestTypeForHub(data: [UInt8]) {
        if let _type: BlePacketType = BlePacketType(rawValue:data[0]) {
            switch _type {
            case .HUB_TYPES_DEVICE_ID: hubInfo!.m_device_id = deviceId(data)
            case .HUB_TYPES_CLOUD_ID: hubInfo!.m_cloud_id = cloudId(data)
            case .HUB_TYPES_FIRMWARE_VERSION: hubInfo!.m_firmware = firmwareVersion(data)
            case .HUB_TYPES_MAC_ADDRESS: hubInfo!.m_macAddress = macAddress(data)
            case .HUB_TYPES_SERIAL_NUMBER: hubSerial(data)
            default: break
            }
        }
    }
    
    func connectFailForHub() {
        m_parent!.m_hubConnectionController!.msgSensorDeviceNotFound()
        m_parent!.m_hubConnectionController!.changeState(status: .connectFail)
    }
}

