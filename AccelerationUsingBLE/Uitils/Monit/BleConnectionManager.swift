//
//  BleConnectionManager.swift
//  Monit
//
//  Created by 맥 on 2017. 9. 12..
//  Copyright © 2017년 맥. All rights reserved.
//

import Foundation
import CoreBluetooth
import UIKit

class BleConnectionManager: NSObject, CBCentralManagerDelegate {
    static var m_instance: BleConnectionManager!
    static var instance: BleConnectionManager {
        get {
            if (m_instance == nil) {
                m_instance = BleConnectionManager()
            }
            
            return m_instance
        }
    }
    
    class ScanDevice {
        var ssi : Int?
        var peripheral : CBPeripheral?
        var adv : String = ""
        var uuid: String = ""
        
        init (ssi : Int, peripheral : CBPeripheral, adv : String, uuid: String) {
            self.ssi = ssi
            self.peripheral = peripheral
            self.adv = adv
            self.uuid = uuid
        }
    }
    
    var manager : CBCentralManager!
    var backgroundTaskIdentifier: UIBackgroundTaskIdentifier?
    var m_arrScanDevice = [ScanDevice]()
    var m_arrReconnectPeripheral = [CBPeripheral]()
    var m_arrPeripheralStatus = [CBPeripheral : Peripheral_Controller.CONNECT_STATUS]()
    var m_timeScaner: Timer?
    var m_isStartManager = false
    var m_arrForceDisconnect = [CBPeripheral]()
    var m_reScanList = [String]()
    var m_gensorConnectionLogInfo : SensorConnectionLogInfo_Manager?
    var m_managerStatus: String = ""

    var isStartManager : Bool {
        if (Utility.isSimulator) {
            return true
        }
        return m_isStartManager
    }
    
    func isFindDevice(selectAdvName: String? = nil) -> Bool {
        if (m_arrScanDevice.count > 0) {
            if let _selectAdvName = selectAdvName {
                for item in m_arrScanDevice {
                    if (item.adv.contains(_selectAdvName)) {
                        return true
                    }
                }
                return false
            }
            return true
        }
        return false
    }

    override init() {
        super.init()
    }
    
    func getBleInfo(peripheral: CBPeripheral?) -> BleInfo? {
        return DataManager.instance.m_userInfo.connectSensor.getSensorByPeripheral(peripheral: peripheral)
    }
    
    func breakManager() {
        Debug.print("[BLE] break Manager", event: .warning)
        if (manager == nil || !(m_isStartManager)) {
            return
        }
        
        m_timeScaner?.invalidate() // repeat stop
        manager?.stopScan() // stop scanning
        for item in DataManager.instance.m_userInfo.connectSensor.m_connectSensor {
            disconnectDevice(peripheral: item.peripheral) // disconnect peripheral
        }

        for item in m_arrReconnectPeripheral {
            disconnectDevice(peripheral: item) // retry connection cancle
        }
    }

    func initManager() {
        if (manager != nil) {
            manager!.stopScan()
        } else {
//            manager = CBCentralManager(delegate: self, queue: nil) // init
            manager = CBCentralManager(delegate: self, queue: nil, options:[CBCentralManagerOptionRestoreIdentifierKey: "com.monit.restoreManager"])
        }
        retrieveDevice()
    }
    
    func startScan() {
        m_gensorConnectionLogInfo = SensorConnectionLogInfo_Manager()
        m_arrScanDevice.removeAll()
//        manager.scanForPeripherals(withServices: nil, options: nil)
        manager?.scanForPeripherals(withServices: [DeviceDefine.RX_SERVICE_UUID], options: [CBCentralManagerScanOptionAllowDuplicatesKey: false])
        Debug.print("[BLE][2][Start Scan] >>>>>")
    }
    
    func stopScan() {
        manager?.stopScan()
//        Debug.print("[BLE][2][Scan Count]: \(m_arrScanDevice.count)")
        Debug.print("[BLE][2][Stop Scan] <<<<<")
    }
    
    // 직접 연결하기
    func selectDevice(selectAdvName: String? = nil) -> CBPeripheral? {
        Debug.print("[BLE] Select Device", event: .warning)
        
        var _maxSsi: Int?
        var _peripheral: CBPeripheral?
        
        if let _logInfo = m_gensorConnectionLogInfo {
            _logInfo.m_scannedDeviceCount = m_arrScanDevice.count
        }

        for item in m_arrScanDevice {
            if let _selectAdvName = selectAdvName {
                if (!item.adv.contains(_selectAdvName)) {
                    continue
                }
            }
            
            if (_maxSsi == nil) {
                _maxSsi = item.ssi
                _peripheral = item.peripheral
            } else {
                if (_maxSsi! < item.ssi!) {
                    _maxSsi = item.ssi
                    _peripheral = item.peripheral
                }
            }
        }
        
        if (_peripheral != nil) {
            m_arrPeripheralStatus.updateValue(.register, forKey: _peripheral!)
            self.connectForScanning(peripheral: _peripheral)
            return _peripheral
        }
        return nil
    }
    
    func connectForScanning(peripheral: CBPeripheral?) {
        if (peripheral != nil) {
            manager?.connect(peripheral!, options: nil)
        }
    }
    
    func connectForReconnect(peripheral: CBPeripheral?) {
        let _connectSensor = DataManager.instance.m_userInfo.connectSensor.m_connectSensor
        for item in _connectSensor {
            if (item.peripheral == peripheral) {
                Debug.print("[BLE][1][Already connect]: \(peripheral!.name!)", event: .warning)
                return
            }
        }

        if (!(m_arrReconnectPeripheral.contains(peripheral!))) {
            m_arrReconnectPeripheral.append(peripheral!)
            Debug.print("[BLE][1][Reconnect Name]: \(peripheral!.name!)", event: .warning)
        } else {
            Debug.print("[BLE][1][Already reconnect]: \(peripheral!.name!)")
            // return
        }

        if (peripheral != nil) {
            //            let options = [CBConnectPeripheralOptionNotifyOnConnectionKey: true as AnyObject,
            //                           CBConnectPeripheralOptionNotifyOnDisconnectionKey: true as AnyObject,
            //                           CBConnectPeripheralOptionNotifyOnNotificationKey: true as AnyObject,
            //                           CBCentralManagerRestoredStatePeripheralsKey: true as AnyObject,
            //                           CBCentralManagerRestoredStateScanServicesKey : true as AnyObject, CBCentralManagerRestoredStateScanOptionsKey : true as AnyObject]
            //            manager?.connect(peripheral!, options: options)
            manager?.connect(peripheral!, options: nil)
        }
    }
    
    // 이미 연결되어있는 sensor, 연결 시도 걸어둔 sensor (연결이 끊어져 있는 센서도 disconnect callback 호출되며, total목록에 있으면 다시 연결시도 한다.)
    func disconnectDevice(peripheral: CBPeripheral?) {
        if let _peripheral = peripheral {
            Debug.print("[BLE] disconnectDevice: \(String(describing: _peripheral.name))", event: .warning)
            manager.cancelPeripheralConnection(_peripheral)
            m_arrForceDisconnect.append(_peripheral)
        }
    }
    
    func disconnectReconnect(adv: String) {
        Debug.print("[BLE] disconnectReconnect: \(adv)", event: .warning)
        for item in m_arrReconnectPeripheral {
            if (item.name == adv) {
                disconnectDevice(peripheral: item) // retry connection cancle
                return
            }
        }
    }
    
    func removeReconnect(peripheral: CBPeripheral) {
        // remove reconnect item
        if let index = m_arrReconnectPeripheral.index(where: { $0 === peripheral }) {
            m_arrReconnectPeripheral.remove(at: index)
        }
    }
    
    // 보유 리스트에 있는지 확인 (연결된 센서는 확인안함)
    func isReconnectNeedByPeripheral(peripheral: CBPeripheral) -> Bool {
        Debug.print("[BLE]: is search advName: \(peripheral.name!)", event: .warning)
        if let _arrUserInfo = DataManager.instance.m_dataController.device.getTotalUserInfoList {
            for itemUserInfo in _arrUserInfo {
                Debug.print("[BLE]: TotalList - advName: \(itemUserInfo.adv)", event: .warning)
                if (itemUserInfo.adv == peripheral.name!) {
                    return true
                }
            }
        }
        return false
    }
    
    func sendLog() {
        if let _info = m_gensorConnectionLogInfo {
            let _send = Send_SetSensorConnectionLog()
            _send.aid = DataManager.instance.m_userInfo.account_id
            _send.token = DataManager.instance.m_userInfo.token
            _send.data_manager = _info
            NetworkManager.instance.Request(_send) { (json) -> () in
                let receive = Receive_SetSensorConnectionLog(json)
                switch receive.ecd {
                case .success: break
                default: Debug.print("SetSensorConnectionLog invaild errcod: \(receive.ecd.rawValue)")
                }
            }
            m_gensorConnectionLogInfo = nil
        }
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOff:
            Debug.print("[BLE] CBCentral Manager STATE: Bluetooth is Off", event: .warning)
            m_isStartManager = false
            m_managerStatus = "poweredOff"
        case .poweredOn:
            Debug.print("[BLE] CBCentral Manager STATE: Bluetooth is On", event: .warning)
            m_isStartManager = true
            update() // force
            m_managerStatus = "poweredOn"
        case .unsupported:
            Debug.print("[ERROR][BLE] CBCentral Manager STATE: Bluetooth Not Supported", event: .error)
            m_isStartManager = false
            m_managerStatus = "unsupported"
        default:
            Debug.print("[ERROR][BLE] CBCentral Manager STATE: Bluetooth \(central.state.rawValue)", event: .error)
            m_isStartManager = false
            m_managerStatus = "\(central.state.rawValue)"
        }
        
        // poweredOff가되면 disconnect 다음에 호출됨 해당 함수가 호출됨, resetting은 아예 disconnect가 호출이 안됨.
        if (central.state != .poweredOn) {
            for item in DataManager.instance.m_userInfo.connectSensor.m_connectSensor {
                if let _peripheral = item.peripheral {
                    disconnect(peripheral: _peripheral, err: "state:\(central.state.rawValue)")
                }
            }
        }
    }
    
    func retrieveDevice() {
        Debug.print("[BLE] start retrieveDevice")
        repeatScan()
    }
    
    func breakRetriveDevice() {
        manager?.stopScan()
        self.m_timeScaner?.invalidate()
    }
    
    func connectByUuid(uuid: String, advName: String) {
        if let _uuid = UUID(uuidString: uuid) {
            let _dataRetrieve = manager.retrievePeripherals(withIdentifiers: [_uuid])
            if (_dataRetrieve.count > 0) {
                for _peripheral in _dataRetrieve {
                    connectForReconnect(peripheral: _peripheral)
                }
            }
        }
    }
    
    func repeatScan() {
        Debug.print("[BLE] repeat update !!!!!!", event: .warning)
        //        self.backgroundTaskIdentifier = UIApplication.shared.beginBackgroundTask(expirationHandler: {
        //                UIApplication.shared.endBackgroundTask(self.backgroundTaskIdentifier!)
        //        })
        self.m_timeScaner?.invalidate()
        self.m_timeScaner = Timer.scheduledTimer(timeInterval: Config.SCAN_INTERVAL_TIME, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
    }
 
    @objc func update() {
        if (!InitViewController.m_initUserDataFinished) {
            return
        }
        
        if (self.manager == nil) {
            return
        }
        
        if (!(m_isStartManager)) {
            return
        }
        
        if (!(DataManager.instance.m_userInfo.isSignin)) {
            return
        }
        
        if (Utility.currentReachabilityStatus == .notReachable) {
            return
        }

        // Debug.print("[BLE] Reconnect Ble ====================")
        let _connectSensorLog = DataManager.instance.m_userInfo.connectSensor.m_connectSensor
        for item in _connectSensorLog {
            Debug.print("[BLE][0][Connect]: \(item.m_adv)")
        }
        
        // add scan item
        m_reScanList.removeAll()
        if let _arrTotalSensor = DataManager.instance.m_dataController.device.getTotalUserInfoList {
            for serverItem in _arrTotalSensor {
                if (!(serverItem.type == DEVICE_TYPE.Sensor.rawValue)) {
                    continue
                }
                
                // scan 목록은 전부다 추가.
                if (!m_reScanList.contains(serverItem.adv)) {
                    m_reScanList.append(serverItem.adv)
                }
                
                // reconnect할 목록중에 이미 연결된센서는 제외
                let _connectSensor = DataManager.instance.m_userInfo.connectSensor.m_connectSensor
                var _isFoundConnectSensor = false
                for item in _connectSensor {
                    if (item.m_adv == serverItem.adv) {
                        _isFoundConnectSensor = true
                        break
                    }
                }
                if (_isFoundConnectSensor) {
                    continue
                }
                // local store item 으로 reconnect 시도
                if let _arrStoreSensor = DataManager.instance.m_userInfo.storeConnectedSensor.m_storeConnectedSensor {
                    for storeItem in _arrStoreSensor {
//                        Debug.print("[BLE][1][StoreItem]: \(storeItem.adv)")
                        if (serverItem.adv == storeItem.adv) {
                            connectByUuid(uuid: storeItem.uuid, advName: storeItem.adv)
                            break
                        }
                    }
                }
            }
        }
        
        // reScan 목록 스캔 검색
        if (UIApplication.shared.applicationState == .active) {
            Debug.print("[BLE][2][Rescan List]: \(m_reScanList)")
//            Debug.print("[BLE][2][Rescan List Count]: \(m_reScanList.count)")
            
            if (m_reScanList.count > 0) {
                if (!(self.manager!.isScanning)) {
                    findDisconnectDevice()
                }
            }
        }
    }
    
    // reScan 목록 스캔 시작 -> 스캔 완료후 연결
    func findDisconnectDevice() {
        self.startScan()
        
        // stop scan
        var _workItem: DispatchWorkItem?
        _workItem = DispatchWorkItem {
            self.stopScan()
            if (self.isFindDevice()) {
                self.selectDeviceByAlreadyConnect()
            }
        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Config.SCANNING_TIME, execute: _workItem!)
    }
    
    // m_reScanList 목록(서버에서 가져온 내 센서)과 스캔된 목록을 비교하여 연결한다.
    func selectDeviceByAlreadyConnect() {
        if let _logInfo = m_gensorConnectionLogInfo {
            _logInfo.m_scannedDeviceCount = m_arrScanDevice.count
        }
        
        for item in m_reScanList {
            for scanDeviceItem in m_arrScanDevice {
                if (item == scanDeviceItem.adv) {
                    if let _peripheral = scanDeviceItem.peripheral {
                        m_arrPeripheralStatus.updateValue(.scan, forKey: _peripheral)
                        self.connectForScanning(peripheral: _peripheral)
                    }
                }
            }
        }
    }
    
    func removeRescanItem(name: String) {
        var _i = -1
        for (i, item) in m_reScanList.enumerated() {
            if (item == name) {
                _i = i
                break
            }
        }
        if (_i != -1) {
            m_reScanList.remove(at: _i)
        }
    }
    
    func disconnectPacket(peripheral: CBPeripheral) {
        Debug.print("[BLE] Request Sensor Disconnect Packet", event: .warning)
        if let _info = DataManager.instance.m_userInfo.connectSensor.getSensorByPeripheral(peripheral: peripheral) {
            // set con type
            var _con = 0
            if let _controller = _info.controller, _controller.m_isStartConnection {
                _con = 0
            } else {
                _con = 3
            }
            
            // empty info modify
            var _did = _info.m_did
            var _enc = _info.m_enc
            if let _arrStoreSensor = DataManager.instance.m_userInfo.storeConnectedSensor.m_storeConnectedSensor {
                for item in _arrStoreSensor {
                    if (item.adv == peripheral.name!) {
                        if (_enc.count != 4) {
                            Debug.print("[BLE] store enc \(item.enc)", event: .warning)
                            _enc = item.enc
                        }
                        if (_did == 0) {
                            Debug.print("[BLE] store did \(item.did)", event: .warning)
                            _did = item.did
                        }
                        break
                    }
                }
            }
            
            if (_did == 0 || _enc == "") {
                Debug.print("[BLE] disconnect store data is null", event: .warning)
                return
            }

            // device..
            let send = Send_SetDeviceStatusForSensor()
            send.isErrorPopupOn = false
            send.aid = DataManager.instance.m_userInfo.account_id
            send.token = DataManager.instance.m_userInfo.token
            send.isIndicator = false
            let _infoData = SendSensorStatusInfo(type: DEVICE_TYPE.Sensor.rawValue, did: _did, enc: _enc, bat: nil, mov: nil, dps: nil, opr: nil, tem: nil, hum: nil, voc: nil, fwv: nil, con: _con)
            
            if let _ctrl = _info.controller {
                if (_ctrl.m_connectStatus != .retrieve) {
                    if (_infoData.err != nil) {
                        _infoData.err = "\(_infoData.err!),C\(_ctrl.m_connectStatus.rawValue)"
                    } else {
                        _infoData.err = "C\(_ctrl.m_connectStatus.rawValue)"
                    }
                }
                
                if (_ctrl.m_status != .connectSuccess) {
                    if (_infoData.err != nil) {
                        _infoData.err = "\(_infoData.err!),S\(_ctrl.m_status.rawValue)"
                    } else {
                        _infoData.err = "S\(_ctrl.m_status.rawValue)"
                    }
                }
                
                if (_ctrl.m_gensorConnectionLogInfo.m_bleStep != 6) {
                    if (_infoData.err != nil) {
                        _infoData.err = "\(_infoData.err!),B\(_ctrl.m_gensorConnectionLogInfo.m_bleStep)"
                    } else {
                        _infoData.err = "B\(_ctrl.m_gensorConnectionLogInfo.m_bleStep)"
                    }
                }

                if (_ctrl.m_disConType != .none) {
                    if (_infoData.err != nil) {
                        _infoData.err = "\(_infoData.err!),E\(_ctrl.m_disConType.rawValue)"
                    } else {
                        _infoData.err = "E\(_ctrl.m_disConType.rawValue)"
                    }
                }

                if _ctrl.m_disConErrorMsg != "" {
                    if (_infoData.err != nil) {
                        _infoData.err = "\(_infoData.err!),M\(_ctrl.m_disConErrorMsg)"
                    } else {
                        _infoData.err = "M\(_ctrl.m_disConErrorMsg)"
                    }
                }
            }

            send.data.append(_infoData)
            NetworkManager.instance.Request(send) { (json) -> () in
                let receive = Receive_SetDeviceStatusForSensor(json)
                switch receive.ecd {
                case .success:
                    break
                default:
                    Debug.print("[BLE][ERROR] invaild errcod", event: .error)
                }
            }
            
            DataManager.instance.m_dataController.diaperSensingLog.sendingData(id: nil, did: _did)
        }
    }
    
    func sendingLog(peripheral: CBPeripheral) {
        if let _info = DataManager.instance.m_userInfo.connectSensor.getSensorByPeripheral(peripheral: peripheral) {
            _info.controller?.sendLog()
        }
    }
    
    func batteryCheck(peripheral: CBPeripheral) {
        if let _info = DataManager.instance.m_userInfo.connectSensor.getSensorByPeripheral(peripheral: peripheral) {
            if (_info.controller?.m_isBatteryMsg == false) {
                if (_info.controller?.m_status == .connectSuccess) {
                    if (_info.m_battery / 100 < 3) {
                        _info.controller?.m_isBatteryMsg = true
                        _ = PopupManager.instance.onlyContents(contentsKey: "notification_low_battery_detail", confirmType: .ok, okHandler: { () -> () in
                        })
                    }
                }
            }
        }
    }
    
    func deleteForceDisconnect(peripheral: CBPeripheral) {
        if m_arrForceDisconnect.contains(peripheral) {
            if let index = m_arrForceDisconnect.index(of: peripheral) {
                m_arrForceDisconnect.remove(at: index)
            }
        }
    }
    
    // after scanning
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if peripheral.name != nil {
            Debug.print("[BLE][2][Scan]: \(peripheral.name!), \(RSSI)")
            if let _logInfo = m_gensorConnectionLogInfo {
                if (_logInfo.m_scannedDeviceName == "") {
                    _logInfo.m_scannedDeviceName = "\(peripheral.name!)"
                } else {
                    _logInfo.m_scannedDeviceName += "/\(peripheral.name!)"
                }
            }

//            if (peripheral.name!.contains(DeviceDefine.MONIT_DEVICE_NAME)) {
//            if (Int(RSSI) > 0 || Int(RSSI) < -100){
//                Debug.print("[BLE] \(peripheral.name!), RSSI: \(RSSI)") //print the names of all peripherals connected.
//            }
            
                var _isFind = false
                for item in m_arrScanDevice {
                    if (item.adv == peripheral.name!) {
                        _isFind = true
                        if (item.ssi! < Int(truncating: RSSI)) {
                            item.ssi = Int(truncating: RSSI)
                        }
                    }
                }
                
                if (!_isFind) {
                    let _sendDevice = ScanDevice(ssi: Int(truncating: RSSI), peripheral: peripheral, adv: peripheral.name!, uuid: peripheral.identifier.uuidString)
                    m_arrScanDevice.append(_sendDevice)
                }
//            }
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        Debug.print("[BLE] Did Connect!!!", event: .warning)
        Debug.print("[BLE] Connect uuid: \(peripheral.identifier.uuidString)", event: .warning)

        if (DataManager.instance.m_userInfo.configData.isMaster) {
            NotificationManager.instance.sensorLocalNoti(did: -1, dps: DEVICE_NOTI_TYPE.connected.rawValue)
        }

        let _peripheralController = Peripheral_Controller()
        _peripheralController.m_peripheral = peripheral
        peripheral.delegate = _peripheralController.m_delegate

        // add Info
        let _bleInfo = BleInfo()
        _bleInfo.peripheral = peripheral
        _bleInfo.controller = _peripheralController
        DataManager.instance.m_userInfo.connectSensor.addSensor(bleInfo: _bleInfo)
        
        // set status
        if let _status = m_arrPeripheralStatus[peripheral] {
            _bleInfo.controller!.m_connectStatus = _status
            m_arrPeripheralStatus.removeValue(forKey: peripheral)
        }

        // remove reconnect item
        if let index = m_arrReconnectPeripheral.index(where: { $0 === peripheral }) {
            m_arrReconnectPeripheral.remove(at: index)
        }
        
        if let _logInfo = m_gensorConnectionLogInfo {
            _logInfo.m_connected = 1
        }
        
        peripheral.discoverServices(nil)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        Debug.print("[BLE] Disconnect... : " + peripheral.name!, event: .warning)

        if let _error = error {
            switch _error._code {
            case 6: break // The connection has timed out unexpectedly.
            default:
                if let _dic = _error._userInfo as? [String : Any] {
                    for (_, value) in _dic.enumerated() {
                        if let _info = DataManager.instance.m_userInfo.connectSensor.getSensorByPeripheral(peripheral: peripheral) {
                            if let _ctrl = _info.controller {
                                _ctrl.m_disConErrorMsg += "[Disconnect]:\(value.value)"
                            }
                        }
                    }
                }
            }
            Debug.print("[BLE][ERROR] Error: \(_error)", event: .error)
        }
        
        if let _info = DataManager.instance.m_userInfo.connectSensor.getSensorByPeripheral(peripheral: peripheral) {
            if (DataManager.instance.m_userInfo.configData.isMaster) {
                NotificationManager.instance.sensorLocalNoti(did: _info.m_did, dps: DEVICE_NOTI_TYPE.disconnected.rawValue)
            }
        }
        
        disconnect(peripheral: peripheral)
    }
    
    func disconnect(peripheral: CBPeripheral, err: String? = nil) {
        if let _err = err {
            if let _info = DataManager.instance.m_userInfo.connectSensor.getSensorByPeripheral(peripheral: peripheral) {
                if let _ctrl = _info.controller {
                    _ctrl.m_disConErrorMsg += "[Disconnect]:\(_err)"
                }
            }
        }
        
        // sendLog for register
        sendingLog(peripheral: peripheral)
        
        // force disconnect Check (지금 사용안함)
        if m_arrForceDisconnect.contains(peripheral) {
            if let index = m_arrForceDisconnect.index(of: peripheral) {
                m_arrForceDisconnect.remove(at: index)
                Debug.print("[BLE] force disconnect sensor", event: .warning)
            }
        } else {
            Debug.print("[BLE] disconnect sensor", event: .warning)
        }
        
        // battery check
//        batteryCheck(peripheral: peripheral)
        
        disconnectPacket(peripheral: peripheral)
        DataManager.instance.m_userInfo.connectSensor.removeSensorByPeripheral(peripheral: peripheral)
        
        // reconnect
        if (isReconnectNeedByPeripheral(peripheral: peripheral)) {
            if (DataManager.instance.m_userInfo.isSignin) {
                Debug.print("[BLE] set reconnect: \(peripheral.name!)", event: .warning)
                connectForReconnect(peripheral: peripheral)
            }
        } else {
            Debug.print("[BLE] remove reconnect - \(peripheral.name!)", event: .warning)
            removeReconnect(peripheral: peripheral)
        }

        UIManager.instance.currentUIReload()
    }

    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        Debug.print("[BLE] Connect failed : " + peripheral.name!, event: .warning)
        if let _error = error {
            if let _info = DataManager.instance.m_userInfo.connectSensor.getSensorByPeripheral(peripheral: peripheral) {
                if let _ctrl = _info.controller {
                    _ctrl.m_disConErrorMsg += "[didFailToConnect]:\(_error as? String ?? "")"
                }
            }
            Debug.print("[BLE][ERROR] Error: \(_error)", event: .error)
        }
        
        if let _logInfo = m_gensorConnectionLogInfo {
            _logInfo.m_connected = 0
        }
        sendLog()
    }
    
    func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]) {
        Debug.print("[BLE] will restore connection!!!!!!!!!!!!!!!!!!!", event: .warning)
    }
}
