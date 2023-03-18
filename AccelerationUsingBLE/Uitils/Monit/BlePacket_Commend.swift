//
//  BlePacket_Response_Hub.swift
//  Monit
//
//  Created by 맥 on 2017. 11. 15..
//  Copyright © 2017년 맥. All rights reserved.
//

import Foundation

class BlePacket_Commend {
    var m_parent: Peripheral_Controller?
    
    init (parent: Peripheral_Controller) {
        self.m_parent = parent
    }
    
    var bleInfo: BleInfo? {
        get {
            return m_parent!.bleInfo
        }
    }
    
    var isAvailableHeatingFirmware: Bool {
        get {
            return Utility.isAvailableVersion(availableVersion: Config.SENSOR_FIRMWARE_LIMIT_HEATING_VERSION, currentVersion: bleInfo?.m_firmware ?? "0.0.0")
        }
    }
    
    var isAvailableAutoPollingNotiFirmware: Bool {
        get {
            return Utility.isAvailableVersion(availableVersion: Config.SENSOR_FIRMWARE_LIMIT_AUTO_POLLING_VERSION, currentVersion: bleInfo?.m_firmware ?? "0.0.0")
        }
    }
    
    func writeCmd(communicationType: BLE_COMMUNICATION_TYPE, packetType: BlePacketType, packet: [UInt8], completion: ActionResultBlePacketInfo?) {
        m_parent!.m_packetController.writeCmd(communicationType: communicationType, packetType: packetType, packet: packet, completion: completion)
    }
    
    func setLed() {
        writeCmd(communicationType: .cmd, packetType: .LED_CONTROL, packet: [BlePacketType.LED_CONTROL.rawValue, 0x01, 0x00, 0x00], completion: { (blePacketInfo) in
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
    }
    
    func getCurrentUtc() -> [UInt8] {
        var _pkts:[UInt8] = Array(repeating:0, count: 4)
        let componenets = Calendar.current.dateComponents([.year, .month, .day], from: NSDate() as Date)
        if let day = componenets.day, let month = componenets.month, let year = componenets.year {
            _pkts[0] = BlePacketType.CURRENT_UTC.rawValue
            _pkts[1] = UInt8(year.description[year.description.index(year.description.startIndex, offsetBy: 2)...])!
            _pkts[2] = UInt8(month)
            _pkts[3] = UInt8(day)
        }
        return _pkts
    }
    
    func setCurrentUtcForInit() {
        m_parent!.m_packetController.writeCmd(communicationType: .cmd, packetType: .CURRENT_UTC, packet: getCurrentUtc(), completion: { (blePacketInfo) in
            if let _blePacketInfo = blePacketInfo {
                if (_blePacketInfo.m_status == .success) {
                    self.m_parent!.changeState(status: .checkDeviceId)
                } else {
                    self.connectFail()
                    return
                }
            } else {
                self.connectFail()
                return
            }
        })
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
    
    func setHeating(value: Int) {
        guard (isAvailableHeatingFirmware) else { return }
        
        writeCmd(communicationType: .cmd, packetType: .HEATING, packet: BlePacket_Utility.makePacketFor3ByteValues(.HEATING, value: value), completion: { (blePacketInfo) in
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
    
    func setBabyInfo(bday: String, sex: Int) {
        //birthdayYYMMDD + sex
        m_parent!.bleInfo!.m_bday = bday
        m_parent!.bleInfo!.m_sex = sex
        let _babyInfo = bday + sex.description
        writeCmd(communicationType: .cmd, packetType: .BABY_INFO, packet: BlePacket_Utility.makePacketFor3ByteValues(.BABY_INFO, value: Int(_babyInfo)!), completion: { (blePacketInfo) in
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
    }
    
    // 현재 사용 안함 (작동은 됨)
    func setName(name: String) {
        var _name = name
        let _buf = [UInt8](name.utf8)
        if (_buf.count > Config.MAX_BYTE_LENGTH_NAME) {
            _name = "Monit"
        }
        
        m_parent!.bleInfo!.m_name = _name
        writeCmd(communicationType: .cmd, packetType: .DEVICE_NAME, packet: BlePacket_Utility.makePacketForLongStringValues(.DEVICE_NAME, value: _name), completion: { (blePacketInfo) in
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
    }
    
    func setKeepAlive(isKeepAlive: Bool) {
        let _pkts:[UInt8] = [BlePacketType.KEEP_ALIVE.rawValue, UInt8(isKeepAlive ? 1 : 0), 0x00, 0x00]
        writeCmd(communicationType: .cmd, packetType: .KEEP_ALIVE, packet: _pkts, completion: { (blePacketInfo) in
            if let _blePacketInfo = blePacketInfo {
                if (_blePacketInfo.m_status == .success) {
                } else {
                }
            } else {
            }
        })
    }
    
    func setSensitivity(value: Int) {
        let _pkts:[UInt8] = [BlePacketType.SENSITIVE.rawValue, UInt8(value), 0x00, 0x00]
        writeCmd(communicationType: .cmd, packetType: .SENSITIVE, packet: _pkts, completion: { (blePacketInfo) in
        })
    }
    
    func setUtcTimeInfo(value: Int64) {
        guard (isAvailableAutoPollingNotiFirmware) else { return }
        
        var _pkts:[UInt8] = Array(repeating:0, count: 8)
        _pkts[0] = BlePacketType.UTC_TIME_INFO.rawValue
        _pkts[1] = 0x01
        _pkts[2] = 0x01
        _pkts[3] = 0x00
        _pkts[4] = UInt8(value % 256)
        _pkts[5] = UInt8((value >> 8) % 256)
        _pkts[6] = UInt8((value >> 16) % 256)
        _pkts[7] = UInt8((value >> 24) % 256)
        writeCmd(communicationType: .cmd, packetType: .UTC_TIME_INFO, packet: _pkts, completion: { (blePacketInfo) in
        })
    }
    
    func setAutoPollingFirst(isAutoPolling: Bool) {
        let _pkts:[UInt8] = [BlePacketType.AUTO_POLLING.rawValue, 0x01, 0x01, UInt8(isAutoPolling ? 1 : 0),
                             BlePacketType.TEMPERATURE.rawValue,
                             BlePacketType.HUMIDITY.rawValue,
                             BlePacketType.VOC.rawValue,
                             BlePacketType.TOUCH.rawValue,
                             BlePacketType.ACCELERATION.rawValue,]
        writeCmd(communicationType: .cmd, packetType: .AUTO_POLLING, packet: _pkts, completion: { (blePacketInfo) in
            if let _blePacketInfo = blePacketInfo {
                if (_blePacketInfo.m_status == .success) {
                } else {
                }
            } else {
            }
        })
    }
    
    func setAutoPollingSecond(isAutoPolling: Bool) {
        let _pkts:[UInt8] = [BlePacketType.AUTO_POLLING.rawValue, 0x01, 0x01, UInt8(isAutoPolling ? 1 : 0),
                             BlePacketType.ETHANOL.rawValue,
                             BlePacketType.CO2.rawValue,
                             BlePacketType.PRESSURE.rawValue,
                             (isAvailableAutoPollingNotiFirmware) ? BlePacketType.DIAPER_STATUS_COUNT.rawValue : BlePacketType.RAW_GAS.rawValue,
                             BlePacketType.COMPENSATED_GAS.rawValue,]
        writeCmd(communicationType: .cmd, packetType: .AUTO_POLLING, packet: _pkts, completion: { (blePacketInfo) in
            if let _blePacketInfo = blePacketInfo {
                if (_blePacketInfo.m_status == .success) {
                } else {
                }
            } else {
            }
        })
    }
    
    // completed -> disconnect
    func setDFU() {
        let _pkts:[UInt8] = [BlePacketType.DFU.rawValue, UInt8(1), 0x00, 0x00]
        writeCmd(communicationType: .cmd, packetType: .DFU, packet: _pkts, completion: { (blePacketInfo) in
        })
    }
    
    func connectFail() {
        m_parent!.msgSensorDeviceNotFound()
        m_parent!.changeState(status: .connectFail)
    }
    
    func setHubDeviceId(deviceId: Int) {
        m_parent!.m_hubConnectionController!.m_device_id = deviceId
        writeCmd(communicationType: .cmd, packetType: .HUB_TYPES_DEVICE_ID, packet: BlePacket_Utility.makePacketFor3ByteValues(.HUB_TYPES_DEVICE_ID, value: deviceId), completion: { (blePacketInfo) in
            if let _blePacketInfo = blePacketInfo {
                if (_blePacketInfo.m_status == .success) {
                } else {
                    self.connectFailForHub()
                    return
                }
            } else {
                self.connectFailForHub()
                return
            }
        })
    }
    
    func setHubCloudId(cloudId: Int) {
        m_parent!.m_hubConnectionController!.m_cloud_id = cloudId
        writeCmd(communicationType: .cmd, packetType: .HUB_TYPES_CLOUD_ID, packet: BlePacket_Utility.makePacketFor3ByteValues(.HUB_TYPES_CLOUD_ID, value: cloudId), completion: { (blePacketInfo) in
            if let _blePacketInfo = blePacketInfo {
                if (_blePacketInfo.m_status == .success) {
                } else {
                    self.connectFailForHub()
                    return
                }
            } else {
                self.connectFailForHub()
                return
            }
        })
    }

    func setHubAp(apName: String, apPw: String, apSecurity: Int, index: Int) {
        m_parent!.m_hubConnectionController!.m_isFinishWifi = false
        setApName(apName: apName)
        setApPw(apPw: apPw)
        setApSecurity(apSecurity: apSecurity, index: index)
    }
    
    func setApName(apName: String) {
        m_parent!.m_hubConnectionController!.m_apName = apName
        writeCmd(communicationType: .cmd, packetType: .HUB_TYPES_AP_NAME, packet: BlePacket_Utility.makePacketForLongStringValues(.HUB_TYPES_AP_NAME, value: apName), completion: { (blePacketInfo) in
            if let _blePacketInfo = blePacketInfo {
                if (_blePacketInfo.m_status == .success) {
                } else {
                    self.connectFailForHub()
                    return
                }
            } else {
                self.connectFailForHub()
                return
            }
        })
    }
    
    func setApPw(apPw: String) {
        m_parent!.m_hubConnectionController!.m_apPw = apPw
        writeCmd(communicationType: .cmd, packetType: .HUB_TYPES_AP_PASSWORD, packet: BlePacket_Utility.makePacketForLongStringValues(.HUB_TYPES_AP_PASSWORD, value: apPw), completion: { (blePacketInfo) in
            if let _blePacketInfo = blePacketInfo {
                if (_blePacketInfo.m_status == .success) {
                } else {
                    self.connectFailForHub()
                    return
                }
            } else {
                self.connectFailForHub()
                return
            }
        })
    }

    func setApSecurity(apSecurity: Int, index: Int = 99) {
        m_parent!.m_hubConnectionController!.m_apSecurityType = apSecurity
        m_parent!.m_hubConnectionController!.m_apIndex = index
        writeCmd(communicationType: .cmd, packetType: .HUB_TYPES_AP_SECURITY, packet: [BlePacketType.HUB_TYPES_AP_SECURITY.rawValue, UInt8(apSecurity % 256), UInt8(index % 256), 0x00], completion: { (blePacketInfo) in
            if let _blePacketInfo = blePacketInfo {
                if (_blePacketInfo.m_status == .success) {
                } else {
                    self.connectFailForHub()
                    return
                }
            } else {
                self.connectFailForHub()
                return
            }
        })
    }
    
    func setHubWifiScan() {
        m_parent!.m_hubConnectionController!.m_scanList.removeAll()
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
    
    func connectFailForHub() {
        m_parent!.msgSensorDeviceNotFound()
        m_parent!.m_hubConnectionController!.changeState(status: .connectFail)
    }
}
