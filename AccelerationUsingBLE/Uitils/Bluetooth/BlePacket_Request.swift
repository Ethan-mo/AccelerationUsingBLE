//
//  BlePacket_Request.swift
//  AccelerationUsingBLE
//
//  Created by 모상현 on 2023/03/07.
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
                }
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
                print("[BLE] longPacket")
                receiveRequestType(data: _data)
            } else { // Short Packet
                if (_data.count > 4) { // chunk byte[] every 4 bytes
                    print("[BLE] chunkpacket")
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
                    print("[BLE] shortPacket")
                    receiveRequestType(data: _data)
                }
            }
        } else {
            print("[BLE][ERROR] packet length error..")
        }
    }
    
    func receiveRequestType(data: [UInt8]) {
        if let _type: BlePacketType = BlePacketType(rawValue:data[0]) {
            switch _type {
            case .DEVICE_ID: bleInfo!.m_did = 2427
            case .CLOUD_ID: bleInfo!.m_cid = 7476
            case .FIRMWARE_VERSION: bleInfo!.m_firmware = "1.5.0"
            case .BABY_INFO:
                bleInfo!.m_bday = "000000"
                bleInfo!.m_sex = 0
            case .MAC_ADDRESS: bleInfo!.m_macAddress = "94:54:93:27:9C:86"
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
    func sensorSerial(_ data: [UInt8]) {
        let _srl = "MKM83100131"
        if (_srl.count > 0) {
            bleInfo!.m_srl = _srl
            bleInfo!.m_enc = String(_srl[_srl.index(_srl.endIndex, offsetBy: -4)...])
        }
        else {
            print("[BLE][ERROR] SensorSerial Packet length error")
            return
        }
    }
    
    func sensorStatus(_ data: [UInt8]) {
        if (data.count < 4) {
            print("[BLE] SensorStatus Packet is null")
            return
        }
        let _sensorStatus = "\(0xFF & data[1])\\\(0xFF & data[2])\\\(0xFF & data[3])"
        print("[BLE] SensorStatus: \(_sensorStatus)")
        bleInfo!.m_movement = Int(0xFF & data[1])
        bleInfo!.m_diaperstatus = Int(0xFF & data[2])
        bleInfo!.m_operation = Int(0xFF & data[3])
    }
    
    func battery(_ data: [UInt8]) {
        if (data.count < 4) {
            print("[BLE] Battery Packet is null")
            return
        }
        let _value: UInt32 = BlePacket_Utility._getUnsignedValue(data)
        print("[BLE] Battery: \(_value)")
        bleInfo!.m_battery = Int(_value)
    }
    
    func temperature(_ data: [UInt8]) -> Int {
        if (data.count < 4) {
            print("[BLE][ERROR] Temperature Packet is null")
            return 0
        }
        let _value: UInt32 = BlePacket_Utility._getUnsignedValue(data)
        print("[BLE] Temperature: \(_value)")
        return Int(_value)
    }
    
    func humidity(_ data: [UInt8]) -> Int {
        if (data.count < 4) {
            print("[BLE][ERROR] Humidity Packet is null")
            return 0
        }
        let _value: UInt32 = BlePacket_Utility._getUnsignedValue(data)
        print("[BLE] Humidity: \(_value)")
        return Int(_value)
    }
    
    func voc(_ data: [UInt8]) -> Int {
        if (data.count < 4) {
            print("[BLE][ERROR] Voc Packet is null")
            return 0
        }
        let _value: UInt32 = BlePacket_Utility._getUnsignedValue(data)
        print("[BLE] Voc: \(_value)")
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
                    print("[getLatestDetectionTime!!!]: \(_arrData)")
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
        print("연결실패")
        m_parent!.changeState(status: .connectFail)
    }
    
    func finishInitialize(isSuccess:Bool, completion: ActionResultAny?) {
        if (completion != nil) {
            completion?(isSuccess)
        }
    }
}

