//
//  BlePacket_Request_Sensor.swift
//  Monit
//
//  Created by 맥 on 2017. 11. 15..
//  Copyright © 2017년 맥. All rights reserved.
//

import UIKit

class BleLampPacket_Request {
    var m_parent: PeripheralLamp_Controller?
    
    init (parent: PeripheralLamp_Controller) {
        self.m_parent = parent
    }
    
    var bleInfo: BleLampInfo? {
        get {
            return m_parent!.bleInfo
        }
    }
    
    func writeRequest(communicationType: BLE_COMMUNICATION_TYPE, packetType: [BlePacketType], completion: ActionResultBlePacketInfo?) {
        m_parent!.m_packetController!.writeRequest(communicationType: communicationType, packetType: packetType, completion: completion)
    }

    func getDeviceDefaultInfoForInit() {
        writeRequest(communicationType: .request, packetType: [.DEVICE_ID, .CLOUD_ID, .FIRMWARE_VERSION], completion: { (blePacketInfo) in
            if let _blePacketInfo = blePacketInfo {
                if (_blePacketInfo.m_status == .success) {
                    self.m_parent!.m_gensorConnectionLogInfo.m_bleStep = 1
                    self.receiveAnalyze(blePacketInfo: blePacketInfo)
//                    self.getMacAddressForInit() // 작동안함
                    self.getSerialNumberForInit()
                } else {
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
    
    func getMacAddressForInit() {
        writeRequest(communicationType: .request, packetType: [.MAC_ADDRESS], completion: { (blePacketInfo) in
            if let _blePacketInfo = blePacketInfo {
                if (_blePacketInfo.m_status == .success) {
                    self.m_parent!.m_gensorConnectionLogInfo.m_bleStep = 3
                    self.receiveAnalyze(blePacketInfo: blePacketInfo)
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
                    self.m_parent!.changeState(status: .checkDeviceId)
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
                Debug.print("[BLE_LAMP] longPacket", event: .warning)
                receiveRequestType(data: _data)
            } else { // Short Packet
                if (_data.count > 4) { // chunk byte[] every 4 bytes
                    Debug.print("[BLE_LAMP] chunkpacket", event: .warning)
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
                    Debug.print("[BLE_LAMP] shortPacket", event: .warning)
                    receiveRequestType(data: _data)
                }
            }
        } else {
            Debug.print("[BLE_LAMP][ERROR] packet length error..", event: .error)
        }
    }
    
    func receiveRequestType(data: [UInt8]) {
        if let _type: BlePacketType = BlePacketType(rawValue:data[0]) {
            switch _type {
            case .DEVICE_ID: bleInfo!.m_did = deviceId(data)
            case .CLOUD_ID: bleInfo!.m_cid = cloudId(data)
            case .FIRMWARE_VERSION: bleInfo!.m_firmware = firmwareVersion(data)
            case .MAC_ADDRESS: bleInfo!.m_macAddress = macAddress(data)
            case .SERIAL_NUMBER: sensorSerial(data)
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
            Debug.print("[BLE_LAMP] DeviceId Packet is null", event: .warning)
            return -1
        }
        let _getDevice: UInt32 = BlePacket_Utility._getUnsignedValue(data)
        Debug.print("[BLE_LAMP] DeviceId: \(_getDevice)", event: .warning)
        return Int(_getDevice)
    }
    
    func cloudId(_ data: [UInt8]) -> Int {
        if (data.count < 4) {
            Debug.print("[BLE_LAMP] CloudId Packet is null", event: .warning)
            return -1
        }
        let _getCloudId: UInt32 = BlePacket_Utility._getUnsignedValue(data)
        Debug.print("[BLE_LAMP] CloudId: \(_getCloudId)", event: .warning)
        return Int(_getCloudId)
    }
    
    func firmwareVersion(_ data: [UInt8]) -> String {
        if (data.count < 4) {
            Debug.print("[BLE_LAMP] Firmware Packet is null", event: .warning)
            return ""
        }
        let _getFirmware = "\(0xFF & data[1]).\(0xFF & data[2]).\(0xFF & data[3])"
        Debug.print("[BLE_LAMP] Firmware: \(_getFirmware)", event: .warning)
        return _getFirmware
    }
    
    func macAddress(_ data: [UInt8]) -> String {
        if (data.count < 9) {
            Debug.print("[BLE_LAMP] MacAddress Packet is null", event: .warning)
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
        Debug.print("[BLE_LAMP] MacAddress: \(macAddress)", event: .warning)
        return macAddress
    }
    
    func serialNumber(_ data: [UInt8]) -> String {
        if (data.count < 13) {
            Debug.print("[BLE_LAMP] SerialNumber Packet is null", event: .warning)
            return ""
        }
        var sb = [Character]()
        
        for i in 4..<(data.count) {
            if (data[i] == 0x00) { continue }
            sb.append(Character(UnicodeScalar(data[i])))
        }
        Debug.print("[BLE_LAMP] SerialNumber: \(String(sb))", event: .warning)
        return String(sb)
    }
    
    func sensorSerial(_ data: [UInt8]) {
        let _srl = serialNumber(data)
        if (_srl.count > 0) {
            bleInfo!.m_srl = _srl
            bleInfo!.m_enc = String(_srl[_srl.index(_srl.endIndex, offsetBy: -4)...])
        }
        else {
            Debug.print("[BLE_LAMP][ERROR] SensorSerial Packet length error", event: .error)
            return
        }
    }
    
    func connectFail() {
        m_parent!.msgLampDeviceNotFound()
        m_parent!.changeState(status: .connectFail)
    }
    
    func finishInitialize(isSuccess:Bool, completion: ActionResultAny?) {
        if (completion != nil) {
            completion?(isSuccess)
        }
    }
}

