//
//  BlePacket_Response_Hub.swift
//  Monit
//
//  Created by 맥 on 2017. 11. 15..
//  Copyright © 2017년 맥. All rights reserved.
//

import Foundation

class BleLampPacket_Commend {
    var m_parent: PeripheralLamp_Controller?
    
    init (parent: PeripheralLamp_Controller) {
        self.m_parent = parent
    }
    
    var bleInfo: BleLampInfo? {
        get {
            return m_parent!.bleInfo
        }
    }
    
    func writeCmd(communicationType: BLE_COMMUNICATION_TYPE, packetType: BlePacketType, packet: [UInt8], completion: ActionResultBlePacketInfo?) {
        m_parent!.m_packetController.writeCmd(communicationType: communicationType, packetType: packetType, packet: packet, completion: completion)
    }
    
    func setDeviceId(deviceId: Int) {
        if (m_parent?.bleInfo?.m_did != nil) {
            m_parent?.bleInfo?.m_did = deviceId
            writeCmd(communicationType: .cmd, packetType: .DEVICE_ID, packet: BlePacket_Utility.makePacketFor3ByteValues(.DEVICE_ID, value: deviceId), completion: { (blePacketInfo) in
                if let _blePacketInfo = blePacketInfo {
                    if (_blePacketInfo.m_status == .success) {
                    } else {
                        self.connectFail()
                        return
                    }
                } else {
                    self.connectFail()
                    return
                }
            })
        } else {
            self.connectFail()
            return
        }
    }
    
    func setCloudId(cloudId: Int) {
        if (m_parent?.bleInfo?.m_cid != nil) {
            m_parent!.bleInfo!.m_cid = cloudId
            writeCmd(communicationType: .cmd, packetType: .CLOUD_ID, packet: BlePacket_Utility.makePacketFor3ByteValues(.CLOUD_ID, value: cloudId), completion: { (blePacketInfo) in
                if let _blePacketInfo = blePacketInfo {
                    if (_blePacketInfo.m_status == .success) {
                    } else {
                        self.connectFail()
                        return
                    }
                } else {
                    self.connectFail()
                    return
                }
            })
        } else {
            self.connectFail()
            return
        }
    }
    
    func setInit(completion: ActionResultBool?) {
        let _pkts:[UInt8] = [BlePacketType.INITIALIZE.rawValue, 0x55, 0xAA, 0xFF]
        writeCmd(communicationType: .cmd, packetType: .INITIALIZE, packet: _pkts, completion: { (blePacketInfo) in
            if let _blePacketInfo = blePacketInfo {
                if (_blePacketInfo.m_status == .success) {
                    completion?(true)
                } else {
                    completion?(false)
                }
            } else {
                completion?(false)
            }
        })
    }
    
    func setSerialInfo(serial: String, completion: ActionResultBool?) {
        setFactoryMode(completion: { (isSuccess) in
            if (isSuccess) {
                self.setSerial(serial: serial, completion: { (isSuccess) in
                    if (isSuccess) {
                        self.setDeviceReset(completion: { (isSuccess) in
                            if (isSuccess) {
                                completion?(true)
                            } else {
                                completion?(false)
                            }
                        })
                    } else {
                        completion?(false)
                    }
                })
            } else {
                completion?(false)
            }
        })
    }
    
    func setFactoryMode(completion: ActionResultBool?) {
        let _pkts:[UInt8] = [BlePacketType.FACTORY_MODE.rawValue, 0x55, 0xAA, 0xFF]
        writeCmd(communicationType: .cmd, packetType: .FACTORY_MODE, packet: _pkts, completion: { (blePacketInfo) in
            if let _blePacketInfo = blePacketInfo {
                if (_blePacketInfo.m_status == .success) {
                    completion?(true)
                } else {
                    completion?(false)
                }
            } else {
                completion?(false)
            }
        })
    }
    
    func setSerial(serial: String, completion: ActionResultBool?) {
        var _pkts: [UInt8] = BlePacket_Utility.makePacketForLongStringValues(.SERIAL_NUMBER, value: serial)
        _pkts.append(0x00)
        writeCmd(communicationType: .cmd, packetType: .SERIAL_NUMBER, packet: _pkts, completion: { (blePacketInfo) in
            if let _blePacketInfo = blePacketInfo {
                if (_blePacketInfo.m_status == .success) {
                    completion?(true)
                } else {
                    completion?(false)
                }
            } else {
                completion?(false)
            }
        })
    }
    
    func setDeviceReset(completion: ActionResultBool?) {
        let _pkts:[UInt8] = [BlePacketType.DEVICE_RESET.rawValue, 0x55, 0xAA, 0xFF]
        writeCmd(communicationType: .cmd, packetType: .DEVICE_RESET, packet: _pkts, completion: { (blePacketInfo) in
            if let _blePacketInfo = blePacketInfo {
                if (_blePacketInfo.m_status == .success) {
                    completion?(true)
                } else {
                    completion?(false)
                }
            } else {
                completion?(false)
            }
        })
    }
    
    func connectFail() {
        m_parent!.msgLampDeviceNotFound()
        m_parent!.changeState(status: .connectFail)
    }
    
    func setAp(apName: String, apPw: String, apSecurity: Int, index: Int) {
        m_parent!.m_lampConnectionController!.m_isFinishWifi = false
        setApName(apName: apName)
        setApPw(apPw: apPw)
        setApSecurity(apSecurity: apSecurity, index: index)
    }
    
    func setApName(apName: String) {
        m_parent!.m_lampConnectionController!.m_apName = apName
        writeCmd(communicationType: .cmd, packetType: .HUB_TYPES_AP_NAME, packet: BlePacket_Utility.makePacketForLongStringValues(.HUB_TYPES_AP_NAME, value: apName), completion: { (blePacketInfo) in
            if let _blePacketInfo = blePacketInfo {
                if (_blePacketInfo.m_status == .success) {
                } else {
                    self.connectFailForLamp()
                    return
                }
            } else {
                self.connectFailForLamp()
                return
            }
        })
    }
    
    func setApPw(apPw: String) {
        m_parent!.m_lampConnectionController!.m_apPw = apPw
        writeCmd(communicationType: .cmd, packetType: .HUB_TYPES_AP_PASSWORD, packet: BlePacket_Utility.makePacketForLongStringValues(.HUB_TYPES_AP_PASSWORD, value: apPw), completion: { (blePacketInfo) in
            if let _blePacketInfo = blePacketInfo {
                if (_blePacketInfo.m_status == .success) {
                } else {
                    self.connectFailForLamp()
                    return
                }
            } else {
                self.connectFailForLamp()
                return
            }
        })
    }

    func setApSecurity(apSecurity: Int, index: Int = 99) {
        m_parent!.m_lampConnectionController!.m_apSecurityType = apSecurity
        m_parent!.m_lampConnectionController!.m_apIndex = index
        writeCmd(communicationType: .cmd, packetType: .HUB_TYPES_AP_SECURITY, packet: [BlePacketType.HUB_TYPES_AP_SECURITY.rawValue, UInt8(apSecurity % 256), UInt8(index % 256), 0x00], completion: { (blePacketInfo) in
            if let _blePacketInfo = blePacketInfo {
                if (_blePacketInfo.m_status == .success) {
                } else {
                    self.connectFailForLamp()
                    return
                }
            } else {
                self.connectFailForLamp()
                return
            }
        })
    }
    
    func setLampWifiScan() {
        m_parent!.m_lampConnectionController!.m_scanList.removeAll()
        let _pkts:[UInt8] = [BlePacketType.HUB_TYPES_WIFI_SCAN.rawValue, 0x00, 0x00, 0x00]
        writeCmd(communicationType: .cmd, packetType: .HUB_TYPES_WIFI_SCAN, packet: _pkts, completion: { (blePacketInfo) in
            if let _blePacketInfo = blePacketInfo {
                if (_blePacketInfo.m_status == .success) {
                } else {
                }
            } else {
            }
        })
    }
    
    func setBrightControl(brightValue: Int) {
        let _pkts:[UInt8] = [BlePacketType.LAMP_BRIGHT_CTRL.rawValue, UInt8(brightValue & 0xFF), UInt8(brightValue >> 8 & 0xFF), 0xFF]
        writeCmd(communicationType: .cmd, packetType: .LAMP_BRIGHT_CTRL, packet: _pkts, completion: { (blePacketInfo) in
            if let _blePacketInfo = blePacketInfo {
                if (_blePacketInfo.m_status == .success) {
                } else {
                }
            } else {
            }
        })
    }
    
    func setBrightPowerControl(isPower: Bool) {
        let _pkts:[UInt8] = [BlePacketType.LAMP_BRIGHT_CTRL.rawValue, 0xFF, 0xFF, UInt8(isPower ? 1 : 0)]
        writeCmd(communicationType: .cmd, packetType: .LAMP_BRIGHT_CTRL, packet: _pkts, completion: { (blePacketInfo) in
            if let _blePacketInfo = blePacketInfo {
                if (_blePacketInfo.m_status == .success) {
                } else {
                }
            } else {
            }
        })
    }
    
    func connectFailForLamp() {
        m_parent!.msgLampDeviceNotFound()
        m_parent!.m_lampConnectionController!.changeState(status: .connectFail)
    }
}
