//
//  BlePacket_SensorToLocal.swift
//  AccelerationUsingBLE
//
//  Created by 모상현 on 2023/03/07.
//

import Foundation

class AutoPollingInfo {
    var m_startTime: Date?
    var m_tem = [Int]()
    var m_hum = [Int]()
    var m_voc = [Int]()
    var m_cap = [Int]()
    var m_act = [Int]()
    var m_sen = [Int]()
    var m_mlv = [Int]()
    var m_eth = [Int]()
    var m_co2 = [Int]()
    var m_pres = [Int]()
    var m_rawGas = [Int]()
    var m_comp = [Int]()

    var tem: String {
        get {
            return m_tem.map({"\($0)"}).joined(separator: ",")
        }
    }
    
    var hum: String {
        get {
            return m_hum.map({"\($0)"}).joined(separator: ",")
        }
    }
    
    var voc: String {
        get {
            return m_voc.map({"\($0)"}).joined(separator: ",")
        }
    }
    
    var cap: String {
        get {
            return m_cap.map({"\($0)"}).joined(separator: ",")
        }
    }
    
    var act: String {
        get {
            return m_act.map({"\($0)"}).joined(separator: ",")
        }
    }
    
    var sen: String {
        get {
            return m_sen.map({"\($0)"}).joined(separator: ",")
        }
    }
    
    var mlv: String {
        get {
            return m_mlv.map({"\($0)"}).joined(separator: ",")
        }
    }
    
    var eth: String {
        get {
            return m_eth.map({"\($0)"}).joined(separator: ",")
        }
    }
    
    var co2: String {
        get {
            return m_co2.map({"\($0)"}).joined(separator: ",")
        }
    }
    
    var pres: String {
        get {
            return m_pres.map({"\($0)"}).joined(separator: ",")
        }
    }
    
    var rawGas: String {
        get {
            return m_rawGas.map({"\($0)"}).joined(separator: ",")
        }
    }
    
    var comp: String {
        get {
            return m_comp.map({"\($0)"}).joined(separator: ",")
        }
    }
    
    func addValue(time: Date, tem: Int, hum: Int, voc: Int, cap: Int, act: Int, sen: Int, mlv: Int) -> Bool {
        if (m_startTime == nil) {
            m_startTime = time
        }
        m_tem.insert(tem, at: 0)
        m_hum.insert(hum, at: 0)
        m_voc.insert(voc, at: 0)
        m_cap.insert(cap, at: 0)
        m_act.insert(act, at: 0)
        m_sen.insert(sen, at: 0)
        m_mlv.insert(mlv, at: 0)
        
        let requestedComponent: Set<Calendar.Component> = [.second] //  .month, .day, .hour, .minute, .second
        let timeDifference = Calendar.current.dateComponents(requestedComponent, from: m_startTime!, to: time)
        return timeDifference.second ?? 0 > Config.SENSOR_AUTO_POLLING_SENDING_TIME
    }
    
    func addSecondValue(eth: Int, co2: Int, pres: Int, rawGas: Int, comp: Int) {
        m_eth.insert(eth, at: 0)
        m_co2.insert(co2, at: 0)
        m_pres.insert(pres, at: 0)
        m_rawGas.insert(rawGas, at: 0)
        m_comp.insert(comp, at: 0)
    }
}

class AutoPollingNoti {
    var m_count_pee: Int = 0
    var m_count_poo: Int = 0
    var m_count_abnormal: Int = 0
    var m_count_fart: Int = 0
    var m_count_detachment: Int = 0
    var m_count_attachment: Int = 0
    
    var m_time_pee: Int64 = 0
    var m_time_poo: Int64 = 0
    var m_time_abnormal: Int64 = 0
    var m_time_fart: Int64 = 0
    var m_time_detachment: Int64 = 0
    var m_time_attachment: Int64 = 0
    
    func setPee(_ value: Int) -> Bool {
        var _returnValue = false
        if (m_count_pee != value) {
            _returnValue = true
            m_count_pee = value
        }
        return _returnValue;
    }
    
    func setPoo(_ value: Int) -> Bool {
        var _returnValue = false
        if (m_count_poo != value) {
            _returnValue = true
            m_count_poo = value
        }
        return _returnValue;
    }
    
    func setAbnormal(_ value: Int) -> Bool {
        var _returnValue = false
        if (m_count_abnormal != value) {
            _returnValue = true
            m_count_abnormal = value
        }
        return _returnValue;
    }
    
    func setFart(_ value: Int) -> Bool {
        var _returnValue = false
        if (m_count_fart != value) {
            _returnValue = true
            m_count_fart = value
        }
        return _returnValue;
    }
    
    func setDetachment(_ value: Int) -> Bool {
        var _returnValue = false
        if (m_count_detachment != value) {
            _returnValue = true
            m_count_detachment = value
        }
        return _returnValue;
    }
    
    func setAttachment(_ value: Int) -> Bool {
        var _returnValue = false
        if (m_count_attachment != value) {
            _returnValue = true
            m_count_attachment = value
        }
        return _returnValue;
    }
}

class AutoPollingNotiController {
    var isInit: Bool = false
    var m_peripheral_Controller: Peripheral_Controller?
    var m_autoPollingNoti = AutoPollingNoti()
    
    init (ctrl: Peripheral_Controller) {
        m_peripheral_Controller = ctrl
    }

    
}

class BlePacket_SensorToLocal {
    var m_parent: Peripheral_Controller?
    var m_autoPollingInfo: AutoPollingInfo?
    
    init (parent: Peripheral_Controller) {
        self.m_parent = parent
    }
    
    var bleInfo: BleInfo? {
        get {
            return m_parent!.bleInfo
        }
    }
    
    var isAvailableAutoPollingNotiFirmware: Bool {
        get {
            return Utility.isAvailableVersion(availableVersion: Config.SENSOR_FIRMWARE_LIMIT_AUTO_POLLING_VERSION, currentVersion: bleInfo?.m_firmware ?? "0.0.0")
        }
    }
    
    func receiveNotiType(data: [UInt8]) {
        if let _type: BlePacketType = BlePacketType(rawValue:data[0]) {
            switch _type {
            case .SENSOR_STATUS: break
            case .PENDING: break
            case .BATTERY: break
            case .HUB_TYPES_AP_CONNECTION_STATUS: break
            case .HUB_TYPES_WIFI_SCAN: break
            case .KEEP_ALIVE: break
            case .TEMPERATURE,
                    .HUMIDITY,
                    .VOC,
                    .TOUCH,
                    .ACCELERATION,
                    .ETHANOL,
                    .CO2,
                    .PRESSURE,
                    .RAW_GAS,
                    .COMPENSATED_GAS,
                    .DIAPER_STATUS_COUNT:
                autoPolling(data)
            default: Debug.print("[ERROR][BLE] Not Found Type Noti \(_type)", event: .error)
            }
        }
    }
    func autoPolling(_ data: [UInt8]) {
        if (m_autoPollingInfo == nil) {
            m_autoPollingInfo = AutoPollingInfo()
        }
        
        var _length: Int = 0;
        var _arrChunked = [[UInt8]]()
        while(_length < data.count) {
            var _chunkedData = [UInt8]()
            _chunkedData.append(data[_length])
            _chunkedData.append(data[_length + 1])
            _chunkedData.append(data[_length + 2])
            _chunkedData.append(data[_length + 3])
            _length += 4;
            _arrChunked.append(_chunkedData)
        }
        
        var _tem = 0
        var _hum = 0
        var _voc = 0
        var _cap = 0
        var _act = 0
        var _eth = 0
        var _co2 = 0
        var _pres = 0
        var _rawGas = 0
        var _comp = 0
        for item in _arrChunked {
            if let _type: BlePacketType = BlePacketType(rawValue:item[0]) {
                switch _type {
                case .TEMPERATURE: _tem = getUnsignedValue(item)
                case .HUMIDITY: _hum = getUnsignedValue(item)
                case .VOC: _voc = getUnsignedValue(item)
                case .TOUCH: _cap = getUnsignedValue(item)
                case .ACCELERATION: _act = getUnsignedValue(item)
                case .ETHANOL: _eth = getUnsignedValue(item)
                case .CO2: _co2 = getUnsignedValue(item)
                case .PRESSURE: _pres = getUnsignedValue(item)
                case .RAW_GAS: _rawGas = getUnsignedValue(item)
                case .COMPENSATED_GAS: _comp = getUnsignedValue(item)
                case .DIAPER_STATUS_COUNT: break
                default: break
                }
            }
        }
    }

    func getUnsignedValue(_ data: [UInt8]) -> Int {
        if (data.count < 4) {
            Debug.print("[ERROR][BLE] Packet is short", event: .error)
            return -1
        }
        let _getInt: UInt32 = BlePacket_Utility._getUnsignedValue(data)
        return Int(_getInt)
    }
}

