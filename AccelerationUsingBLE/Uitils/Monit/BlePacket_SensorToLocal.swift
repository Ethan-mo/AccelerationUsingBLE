//
//  BlePacket_SensorToLocal.swift
//  Monit
//
//  Created by 맥 on 2017. 11. 16..
//  Copyright © 2017년 맥. All rights reserved.
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
    
    func setNoti(_ data: [UInt8]) {
        let _pee = UInt32(bigEndian: Data(bytes: [0, 0, 0, data[1] & 0x0f]).withUnsafeBytes { $0.pointee })
        let _poo = UInt32(bigEndian: Data(bytes: [0, 0, 0, (data[1] >> 4) & 0x0f]).withUnsafeBytes { $0.pointee })
        let _abnormal = UInt32(bigEndian: Data(bytes: [0, 0, 0, data[2] & 0x0f]).withUnsafeBytes { $0.pointee })
        let _fart = UInt32(bigEndian: Data(bytes: [0, 0, 0, (data[2] >> 4) & 0x0f]).withUnsafeBytes { $0.pointee })
        let _detachment = UInt32(bigEndian: Data(bytes: [0, 0, 0, data[3] & 0x0f]).withUnsafeBytes { $0.pointee })
        let _attachment = UInt32(bigEndian: Data(bytes: [0, 0, 0, (data[3] >> 4) & 0x0f]).withUnsafeBytes { $0.pointee })
        
        setCount(pee: Int(_pee), poo: Int(_poo), abnormal: Int(_abnormal), fart: Int(_fart), detachment: Int(_detachment), attachment: Int(_attachment))
    }
    
    func setCount(pee: Int, poo: Int, abnormal: Int, fart: Int, detachment: Int, attachment: Int) {
//        Debug.print("AutoPollingNotiController pee:\(pee), poo:\(poo), abnormal:\(abnormal), fart:\(fart), detachment:\(detachment), attachment:\(attachment)", event: .normal)
        var _isSend = false
        setPee(value: pee, handler: { (value) in if (value) { _isSend = true; }
            self.setPoo(value: poo, handler: { (value) in if (value) { _isSend = true }
                self.setAbnormal(value: abnormal, handler: { (value) in if (value) { _isSend = true }
                    self.setFart(value: fart, handler: { (value) in if (value) { _isSend = true }
                        self.setDetachment(value: detachment, handler: { (value) in if (value) { _isSend = true }
                            self.setAttachment(value: attachment, handler: { (value) in if (value) { _isSend = true }
                                if (_isSend || !self.isInit) {
                                    self.sendPacket()
                                }
                            })
                        })
                    })
                })
            })
        })
    }
    
    func setPee(value: Int, handler: @escaping ActionResultBool) {
        if (m_autoPollingNoti.setPee(value)) {
            getTime(type: BlePacketType.LATEST_PEE_DETECTION_TIME, dps: SENSOR_DIAPER_STATUS.pee, handler: { (value) in
                self.m_autoPollingNoti.m_time_pee = value
                handler(true)
            })
        } else {
            handler(false)
        }
    }
    
    func setPoo(value: Int, handler: @escaping ActionResultBool) {
        if (m_autoPollingNoti.setPoo(value)) {
            getTime(type: BlePacketType.LATEST_POO_DETECTION_TIME, dps: SENSOR_DIAPER_STATUS.poo, handler: { (value) in
                self.m_autoPollingNoti.m_time_poo = value
                handler(true)
            })
        } else {
            handler(false)
        }
    }
    
    func setAbnormal(value: Int, handler: @escaping ActionResultBool) {
        if (m_autoPollingNoti.setAbnormal(value)) {
            getTime(type: BlePacketType.LATEST_ABNORMAL_DETECTION_TIME, dps: SENSOR_DIAPER_STATUS.maxvoc, handler: { (value) in
                self.m_autoPollingNoti.m_time_abnormal = value
                handler(true)
            })
        } else {
            handler(false)
        }
    }
    
    func setFart(value: Int, handler: @escaping ActionResultBool) {
        if (m_autoPollingNoti.setFart(value)) {
            getTime(type: BlePacketType.LATEST_FART_DETECTION_TIME, dps: SENSOR_DIAPER_STATUS.fart, handler: { (value) in
                self.m_autoPollingNoti.m_time_fart = value
                handler(true)
            })
        } else {
            handler(false)
        }
    }
    
    func setDetachment(value: Int, handler: @escaping ActionResultBool) {
        if (m_autoPollingNoti.setDetachment(value)) {
            getTime(type: BlePacketType.LATEST_DETACHMENT_DETECTION_TIME, dps: SENSOR_DIAPER_STATUS.detectDiaperChanged, handler: { (value) in
                self.m_autoPollingNoti.m_time_detachment = value
                handler(true)
            })
        } else {
            handler(false)
        }
    }
    
    func setAttachment(value: Int, handler: @escaping ActionResultBool) {
        if (m_autoPollingNoti.setAttachment(value)) {
            getTime(type: BlePacketType.LATEST_ATTACHMENT_DETECTION_TIME, dps: SENSOR_DIAPER_STATUS.attachSensor, handler: { (value) in
                self.m_autoPollingNoti.m_time_attachment = value
                handler(true)
            })
        } else {
            handler(false)
        }
    }
    
    func getTime(type: BlePacketType, dps: SENSOR_DIAPER_STATUS, handler: ActionResultInt64?) {
        m_peripheral_Controller?.m_packetRequest?.getLatestDetectionTime(type: type, completion: { (value) in
            Debug.print("[Time!!!!!!] \(value)", event: .dev)
            self.sendLocalNoti(dps: dps, timeStamp: value)
            handler?(value)
        });
    }

    func sendLocalNoti(dps: SENSOR_DIAPER_STATUS, timeStamp: Int64) {
        if (isInit) {
            DataManager.instance.m_dataController.device.m_sensor.updateStatusForAutoPolling(did: m_peripheral_Controller?.bleInfo?.m_did ?? 0, dps: dps.rawValue, mov: 0, opr: 0, timeStamp: timeStamp)
        }
    }
    
    func sendPacket() {
        UIManager.instance.currentUIReload()
        let _did = m_peripheral_Controller?.bleInfo?.m_did ?? 0
        if let _userInfo = DataManager.instance.m_dataController.device.getUserInfoByDid(did: _did, type: DEVICE_TYPE.Sensor.rawValue) {
            let send = Send_SetDeviceStatusForAutoPollingNoti()
            send.aid = DataManager.instance.m_userInfo.account_id
            send.token = DataManager.instance.m_userInfo.token
            send.isIndicator = false
            send.isResending = true
            let _info = SendSensorStatusForAutoPollingNotiInfo(type: DEVICE_TYPE.Sensor.rawValue, did: _did, enc: _userInfo.enc, cpee: m_autoPollingNoti.m_count_pee, cpoo: m_autoPollingNoti.m_count_poo, cabn: m_autoPollingNoti.m_count_abnormal, cfart: m_autoPollingNoti.m_count_fart, cdet: m_autoPollingNoti.m_count_detachment, catt: m_autoPollingNoti.m_count_attachment, lpeet: m_autoPollingNoti.m_time_pee, lpoot: m_autoPollingNoti.m_time_poo, labnt: m_autoPollingNoti.m_time_abnormal, lfart: m_autoPollingNoti.m_time_fart, ldett: m_autoPollingNoti.m_time_detachment, lattt: m_autoPollingNoti.m_time_attachment)
            send.data.append(_info)
            NetworkManager.instance.Request(send) { (json) -> () in
                let receive = Receive_SetDeviceStatusForAutoPollingNoti(json)
                switch receive.ecd {
                case .success:
                    self.isInit = true
                    DataManager.instance.m_dataController.deviceNoti.updateForDetailView()
                default:
                    Debug.print("[ERROR] invaild errcod", event: .error)
                }
            }
        }
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
            case .SENSOR_STATUS: sensorStatus(data)
            case .PENDING: pending(data)
            case .BATTERY: battery(data)
            case .HUB_TYPES_AP_CONNECTION_STATUS: apConnectionStatus(data)
            case .HUB_TYPES_WIFI_SCAN: getScanList(data)
            case .KEEP_ALIVE: heartBeat(data)
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
    
    func sensorStatus(_ data: [UInt8]) {
        if (data.count < 4) {
            Debug.print("[ERROR][BLE] Noti SensorStatus Packet is null", event: .error)
            return
        }
        let _sensorStatus = "MOV:\(0xFF & data[1])\\DPS:\(0xFF & data[2])\\OPR:\(0xFF & data[3])"
        Debug.print("[BLE] Noti SensorStatus: \(_sensorStatus)", event: .warning)
        bleInfo!.m_movement = Int(0xFF & data[1])
        bleInfo!.m_diaperstatus = DataManager.instance.m_userInfo.configData.isDemo ? 0 : Int(0xFF & data[2])
        bleInfo!.m_operation = Int(0xFF & data[3])
        
        if (m_parent!.m_status == .connectSuccess) {
            DataManager.instance.m_dataController.device.m_sensor.updateStatus(did: bleInfo!.m_did, dps: bleInfo!.m_diaperstatus, mov: bleInfo!.m_movement, opr: bleInfo!.m_operation, timeStamp: Int64(Utility.timeStamp), isAvailableAutoPollingNotiFirmware: isAvailableAutoPollingNotiFirmware)
        }
    }
    
    func pending(_ data: [UInt8]) {
        if (data.count < 4) {
            Debug.print("[ERROR][BLE] Noti Pending Packet is null", event: .error)
            return
        }
        let _dps = Int(0xFF & data[1])
        let _time = BlePacket_Utility._getUnsignedValueBy24Bit([data[2], data[3]])
        Debug.print("[BLE] Noti Pending: dps \(_dps), time \(_time)", event: .warning)
        bleInfo!.m_diaperstatus = DataManager.instance.m_userInfo.configData.isDemo ? 0 : _dps

        if (m_parent!.m_status == .connectSuccess) {
            Debug.print("[BLE] Noti Pending: timeStamp \(Int64(NSDate().timeIntervalSince1970)), resultTime \(Int64(Utility.timeStamp) - Int64(_time))", event: .warning)
            DataManager.instance.m_dataController.device.m_sensor.updateStatus(did: bleInfo!.m_did, dps: bleInfo!.m_diaperstatus, mov: bleInfo!.m_movement, opr: bleInfo!.m_operation, timeStamp: Int64(Utility.timeStamp), dTimeStamp: Int64(_time))
        }
    }
    
    func getTime(_ packets: [UInt8]) -> String {
        if (packets.count < 4) {
            Debug.print("[BLE] getTime is null", event: .warning)
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
    
    func battery(_ data: [UInt8]) {
        if (data.count < 4) {
            Debug.print("[ERROR][BLE] Noti Battery Packet is null", event: .error)
            return
        }
        let _value: UInt32 = BlePacket_Utility._getUnsignedValue(data)
        Debug.print("[BLE] Noti Battery: \(_value)", event: .warning)
        bleInfo!.m_battery = Int(_value)
        let _battery: Int = bleInfo!.m_battery / 100
        if (_battery > 10) {
            m_parent!.m_isBatteryMsg = false
        }
        if (m_parent!.m_status == .connectSuccess) {
            DataManager.instance.m_dataController.device.m_sensor.updateBattery(did: bleInfo!.m_did, value: bleInfo!.m_battery)
        }
    }
    
    func apConnectionStatus(_ data: [UInt8]) {
        if (data.count < 4) {
            Debug.print("[ERROR][BLE] Noti apConnectionStatus Packet is null", event: .error)
            return
        }
        let _value: UInt32 = BlePacket_Utility._getUnsignedValue(data)
        Debug.print("[BLE] Noti apConnectionStatus: \(_value)", event: .warning)
        m_parent!.m_hubConnectionController!.m_isConnectionStatus = Int(_value)
        if (Int(_value) == 1) {
            m_parent!.m_hubConnectionController!.m_isFinishWifi = true
        }
    }
    
    func heartBeat(_ data: [UInt8]) {
        if (data.count < 4) {
            Debug.print("[ERROR][BLE] Noti heartBeat Packet is null", event: .error)
            return
        }
        return
//        Debug.print("[BLE] Noti HeartBeat")
//        DataManager.instance.m_dataController.heartbeatSensor(did: m_parent!.bleInfo!.m_did)
    }
    
    // -1 -> 255로 처리 하고 있음.
    func getScanList(_ data: [UInt8]) {
        if (data.count < 4) {
            Debug.print("[ERROR][BLE] Noti Wifi scan is null", event: .error)
            return
        }
        m_parent!.m_hubConnectionController!.m_scanList.append(ScanListInfo(idx: Int(data[1]), secuType: Int(data[2]), rssi: Int(data[3]), apName: BlePacket_Utility.getString([data])))
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
                case .DIAPER_STATUS_COUNT: autoPollingNoti(item)
                default: break
                }
            }
        }
        
        // set이 2개로 나눠져서 들어옴.
        if (_tem != 0) {
            if (DataManager.instance.m_userInfo.configData.isMaster) {
                _ = m_parent?.m_monitorPacket?.addValue(time: Date(), tem: _tem, hum: _hum, voc: _voc, cap: _cap, act: _act, sen: m_parent?.bleInfo?.m_operation ?? -1, mlv: m_parent?.bleInfo?.m_movement ?? -1)
            }
            
            // V2
            let _dataSet = DiaperSensingLogSet(tem: _tem.description, hum: _hum.description, voc: _voc.description, cap: _cap.description, act: _act.description, sen: String(m_parent?.bleInfo?.m_operation ?? -1), mlv: String(m_parent?.bleInfo?.m_movement ?? -1), eth: "", co2: "", pres: "", comp: "")
            let _info = DiaperSensingLogInfo(id: 0, did: m_parent!.bleInfo!.m_did, time: UI_Utility.nowUTCDate(type: .yyMMdd_HHmmss), cnt: 1, cnt_second: 0, dataSet: _dataSet)
            DataManager.instance.m_dataController.diaperSensingLog.saveData(info: _info)
            
            // V1
//            if (m_autoPollingInfo!.addValue(time: Date(), tem: _tem, hum: _hum, voc: _voc, cap: _cap, act: _act, sen: m_parent?.bleInfo?.m_operation ?? -1, mlv: m_parent?.bleInfo?.m_movement ?? -1)) {
//                let _send = Send_SetDiaperSensingLog()
//                _send.aid = DataManager.instance.m_userInfo.account_id
//                _send.token = DataManager.instance.m_userInfo.token
//                _send.did = m_parent!.bleInfo!.m_did
//                _send.tem = m_autoPollingInfo!.tem
//                _send.hum = m_autoPollingInfo!.hum
//                _send.voc = m_autoPollingInfo!.voc
//                _send.cap = m_autoPollingInfo!.cap
//                _send.act = m_autoPollingInfo!.act
//                _send.sen = m_autoPollingInfo!.sen
//                _send.mlv = m_autoPollingInfo!.mlv
//                _send.eth = m_autoPollingInfo!.eth
//                _send.co2 = m_autoPollingInfo!.co2
//                _send.pres = m_autoPollingInfo!.pres
//                _send.comp = m_autoPollingInfo!.comp
//                _send.time = UI_Utility.nowUTCDate(type: .yyMMdd_HHmmss)
//                _send.isIndicator = false
//                _send.isErrorPopupOn = false
//                _send.logPrintLevel = .dev
//                m_autoPollingInfo = nil
//                NetworkManager.instance.Request(_send) { (json) -> () in
//                    let receive = Receive_SetDiaperSensingLog(json)
//                    switch receive.ecd {
//                    case .success: break
//                    default: Debug.print("[ERROR] invaild errcod", event: .error)
//                    }
//                }
//            }
            
            if (DataManager.instance.m_userInfo.configData.isDemo) {
                demo(hum: _hum)
            }
        }
        if (_tem == 0) {
            if (DataManager.instance.m_userInfo.configData.isMaster) {
                _ = m_parent?.m_monitorPacket?.addSecondValue(eth: _eth, co2: _co2, pres: _pres, rawGas: _rawGas, comp: _comp)
            }
            
            // V2
            let _dataSet = DiaperSensingLogSet(tem: "", hum: "", voc: "", cap: "", act: "", sen: "", mlv: "", eth: _eth.description, co2: _co2.description, pres: _pres.description, comp: _comp.description) // 생략 _rawGas
            let _info = DiaperSensingLogInfo(id: 0, did: m_parent!.bleInfo!.m_did, time: UI_Utility.nowUTCDate(type: .yyMMdd_HHmmss), cnt: 0, cnt_second: 1, dataSet: _dataSet)
            DataManager.instance.m_dataController.diaperSensingLog.saveData(info: _info)
            
            // V1
//            m_autoPollingInfo!.addSecondValue(eth: _eth, co2: _co2, pres: _pres, rawGas: _rawGas, comp: _comp)
        }

//        timeHeartBeat(did: bleInfo!.m_did)
    }
    
    func autoPollingNoti(_ data: [UInt8]) {
        m_parent?.m_autoPollingNotiController?.setNoti(data)
    }
    
    var demoCurrentTimeSec: Int64 = 0
    var demoLastPeeDetectedTimeSec: Int64 = 0
    var totalHumidityNum: Int = 0
    var humidDiff: Int = 0
    var beforeHumi: Int = 0
    func demo(hum: Int) {
        guard (beforeHumi != 0) else {
            initDemo(hum: hum)
            return
        }
        
        Debug.print("[DEMO] now hum: \(hum), diff Hum: \(humidDiff), totalCount: \(totalHumidityNum), \(!isDemoTime() ? "/ IgnoreTime" : "")", event: .dev)
        demoCurrentTimeSec = Int64(Utility.timeStamp)
        humidDiff = hum - beforeHumi
        beforeHumi = hum
        
        guard (isDemoTime()) else { return }
        
        if (humidDiff > DataManager.instance.m_userInfo.configData.m_demoInfo.m_threshold) {
            totalHumidityNum += 1
            if (totalHumidityNum > DataManager.instance.m_userInfo.configData.m_demoInfo.m_count_time) {
                demoLastPeeDetectedTimeSec = demoCurrentTimeSec;
                Debug.print("[DEMO] Dectected!", event: .dev)
                DispatchQueue.main.async {
                    _ = Timer.scheduledTimer(timeInterval: DataManager.instance.m_userInfo.configData.m_demoInfo.m_alarm_delay, target: self, selector: #selector(self.demoPee), userInfo: nil, repeats: false)
                }
                resetDemo()
            }
        } else if (humidDiff < 0) {
            resetDemo()
        }
    }
    
    @objc func demoPee() {
        Debug.print("[DEMO] Alarm!", event: .dev)
        DataManager.instance.m_dataController.device.m_sensor.updateStatus(did: bleInfo!.m_did, dps: SENSOR_DIAPER_STATUS.pee.rawValue, mov: 0, opr: 0, timeStamp: Int64(Utility.timeStamp))
    }
    
    func initDemo(hum: Int) {
        beforeHumi = hum
        totalHumidityNum = 0
    }
    
    func resetDemo() {
        totalHumidityNum = 0;
    }
    
    func isDemoTime() -> Bool {
        if (demoLastPeeDetectedTimeSec == 0 || demoCurrentTimeSec - demoLastPeeDetectedTimeSec > Int64(DataManager.instance.m_userInfo.configData.m_demoInfo.m_ignore_delay + DataManager.instance.m_userInfo.configData.m_demoInfo.m_alarm_delay)) {
            return true
        }
        return false
    }

    func getAutoPolling(data: [UInt8]) -> (BlePacketType?, Int) {
        if let _type: BlePacketType = BlePacketType(rawValue:data[0]) {
            switch _type {
            case .TEMPERATURE: return (.TEMPERATURE, getUnsignedValue(data))
            case .HUMIDITY: return (.HUMIDITY, getUnsignedValue(data))
            case .VOC: return (.VOC, getUnsignedValue(data))
            case .TOUCH: return (.TOUCH, getUnsignedValue(data))
            case .ACCELERATION: return (.ACCELERATION, getUnsignedValue(data))
            case .ETHANOL: return (.ETHANOL, getUnsignedValue(data))
            case .CO2: return (.CO2, getUnsignedValue(data))
            case .PRESSURE: return (.PRESSURE, getUnsignedValue(data))
            case .RAW_GAS: return (.RAW_GAS, getUnsignedValue(data))
            case .COMPENSATED_GAS: return (.COMPENSATED_GAS, getUnsignedValue(data))
            default: break
            }
        }
        return (nil, 0)
    }
    
    var m_timeStamp: Int64? = nil
    func timeHeartBeat(did: Int) {
        if (m_timeStamp == nil) {
            m_timeStamp = Int64(Utility.timeStamp)
        }
        if (Int64(Utility.timeStamp) - m_timeStamp! >= 30) {
            DataManager.instance.m_dataController.heartbeatSensor(did: did)
            m_timeStamp = nil
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
