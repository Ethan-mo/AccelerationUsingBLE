//
//  BlePacket_SensorToLocal.swift
//  Monit
//
//  Created by 맥 on 2017. 11. 16..
//  Copyright © 2017년 맥. All rights reserved.
//

import Foundation

class BleLampPacket_LampToLocal {
    var m_parent: PeripheralLamp_Controller?
    
    init (parent: PeripheralLamp_Controller) {
        self.m_parent = parent
    }
    
    var bleInfo: BleLampInfo? {
        get {
            return m_parent!.bleInfo
        }
    }
    
    func receiveNotiType(data: [UInt8]) {
        if let _type: BlePacketType = BlePacketType(rawValue:data[0]) {
            switch _type {
            case .HUB_TYPES_AP_CONNECTION_STATUS: apConnectionStatus(data)
            case .HUB_TYPES_WIFI_SCAN: getScanList(data)
            case .TEMPERATURE: setTemperature(data)
            default: Debug.print("[ERROR][BLE_LAMP] Not Found Type Noti \(_type)", event: .error)
            }
        }
    }
    
    func apConnectionStatus(_ data: [UInt8]) {
        if (data.count < 4) {
            Debug.print("[ERROR][BLE_LAMP] Noti apConnectionStatus Packet is null", event: .error)
            return
        }
        let _value: UInt32 = BlePacket_Utility._getUnsignedValue(data)
        Debug.print("[BLE_LAMP] Noti apConnectionStatus: \(_value)", event: .warning)
        m_parent!.m_lampConnectionController!.m_isConnectionStatus = Int(_value)
        if (Int(_value) == 1) {
            m_parent!.m_lampConnectionController!.m_isFinishWifi = true
        }
    }
    
    // -1 -> 255로 처리 하고 있음.
    func getScanList(_ data: [UInt8]) {
        if (data.count < 4) {
            Debug.print("[ERROR][BLE_LAMP] Noti Wifi scan is null", event: .error)
            return
        }
        m_parent!.m_lampConnectionController!.m_scanList.append(ScanListInfo(idx: Int(data[1]), secuType: Int(data[2]), rssi: Int(data[3]), apName: BlePacket_Utility.getString([data])))
    }
    
    func setTemperature(_ data: [UInt8]) {
        guard (data.count >= 8) else {
            Debug.print("[ERROR][BLE_LAMP] setTemperature is short", event: .error)
            return
        }
        
        var _length: Int = 0;
        var _chunkedTemp = [UInt8]()
        _chunkedTemp.append(data[_length])
        _chunkedTemp.append(data[_length + 1])
        _chunkedTemp.append(data[_length + 2])
        _chunkedTemp.append(data[_length + 3])
        
        _length += 4;
        var _chunkedHum = [UInt8]()
        _chunkedHum.append(data[_length])
        _chunkedHum.append(data[_length + 1])
        _chunkedHum.append(data[_length + 2])
        _chunkedHum.append(data[_length + 3])
        
        var _multiple = 100
        if (Utility.isAvailableVersion(availableVersion: "1.1.0", currentVersion: bleInfo?.m_firmware ?? "0.0.0")) {
            _multiple = 1
        }

        let _temp = getUnsignedValue(_chunkedTemp) / _multiple
        m_parent!.m_lampConnectionController?.bleInfo?.m_temp = _temp
        
        let _hum = getUnsignedValue(_chunkedHum) / _multiple
        m_parent!.m_lampConnectionController?.bleInfo?.m_hum = _hum
        
        let _info = LampStatusInfo(did: m_parent!.m_lampConnectionController?.bleInfo?.m_did ?? 0, name: "", power: 0, bright: 0, color: 0, attached: 0, temp: _temp, hum: _hum, voc: 0, ap: "", apse: "", tempmax: 0, tempmin: 0, hummax: 0, hummin: 0, offt: "", onnt: "", con: 0, offptime: "", onptime: "")
        DataManager.instance.m_userInfo.deviceStatus.m_lampStatus.setDeviceStatus(arrStatus: [_info])
    }
    
    func getUnsignedValue(_ data: [UInt8]) -> Int {
        if (data.count < 4) {
            Debug.print("[ERROR][BLE_LAMP] Packet is short", event: .error)
            return -1
        }
        let _getInt: UInt32 = BlePacket_Utility._getUnsignedValue(data)
        return Int(_getInt)
    }
}
