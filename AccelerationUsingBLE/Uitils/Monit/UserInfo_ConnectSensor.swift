//
//  UserInfo_ConnectSensor.swift
//  Monit
//
//  Created by 맥 on 2017. 9. 15..
//  Copyright © 2017년 맥. All rights reserved.
//

import Foundation
import CoreBluetooth
import CoreData

class BleInfo : SensorStatusInfo {
    var controller: Peripheral_Controller?
    var peripheral : CBPeripheral?
    
    var m_cid: Int = 0
    var m_srl: String = ""
    var m_enc: String = ""
    var m_firmware: String = ""
    var m_macAddress: String = ""
    var m_adv: String = ""
    var m_sid: String = ""
    
    init() {
        super.init(did: 0, battery: 0, operation: 0, movement: 0, diaperstatus: 0, temp: 0, hum: 0, voc: 0, name: "", bday: "", sex: 0, eat: 0, sens: 0, con: 0, whereConn: 0, voc_avg: 0, dscore: 0, sleep: 0)
    }
}

class UserInfo_ConnectSensor {
    
    var m_connectSensor = [BleInfo]()
    
    var successConnectSensor: [BleInfo] {
        get {
            var _arrInfo = [BleInfo]()
            for item in m_connectSensor {
                if (item.controller!.m_status == .connectSuccess && item.controller!.m_isForceDisconnect == false) {
                    _arrInfo.append(item)
                }
            }
            return _arrInfo
        }
    }

    func addSensor(bleInfo: BleInfo) {
        removeSensorByPeripheral(peripheral: bleInfo.peripheral)
        m_connectSensor.append(bleInfo)
    }
    
    func getSensorByPeripheral(peripheral: CBPeripheral?, isSuccessCheck:Bool = false) -> BleInfo? {
        if (peripheral == nil) {
            return nil
        }
        
        for item in m_connectSensor {
            if (item.peripheral == peripheral && item.controller!.m_isForceDisconnect == false) {
                if (isSuccessCheck) {
                    if (item.controller!.m_status == .connectSuccess) {
                        return item
                    } else {
                        return nil
                    }
                } else {
                    return item
                }
            }
        }
        return nil
    }
    
    func getSensorByDeviceId(deviceId: Int, isSuccessCheck:Bool = false) -> BleInfo? {
        for item in m_connectSensor {
            if (item.m_did == deviceId && item.controller!.m_isForceDisconnect == false) {
                if (isSuccessCheck) {
                    if (item.controller!.m_status == .connectSuccess) {
                        return item
                    } else {
                        return nil
                    }
                } else {
                    return item
                }
            }
        }
        return nil
    }
    
    func removeSensorById(deviceId: Int) {
        var _arrList = [BleInfo]()
        for item in m_connectSensor {
            if (item.controller!.bleInfo!.m_did == deviceId) {
                Debug.print("[BLE] remove \(deviceId) peripheral object", event: .warning)
                item.controller?.setDisconnect()
                _arrList.append(item)
                continue
            }
        }
        
        Debug.print("[BLE] removeSensor Count: \(_arrList.count)", event: .warning)
        for item in _arrList {
            if let index = m_connectSensor.index(where: { $0 === item }) {
                item.controller?.setDisconnect()
                m_connectSensor.remove(at: index)
            }
        }
        Debug.print("[BLE] connectSensor Count: \(m_connectSensor.count)", event: .warning)
    }

    func removeSensorByPeripheral(peripheral: CBPeripheral?) {
        if (peripheral == nil) {
            return
        }
        
        var _arrList = [BleInfo]()
        for item in m_connectSensor {
            if (item.peripheral == peripheral) {
                Debug.print("[BLE] remove equal peripheral object", event: .warning)
                item.controller?.setDisconnect()
                _arrList.append(item)
                continue
            }

            if let _peripheral = peripheral {
                if (item.m_adv == _peripheral.name) {
                    Debug.print("[BLE] remove equal peripheral name", event: .warning)
                    item.controller?.setDisconnect()
                    _arrList.append(item)
                    continue
                }
            }
        }

        Debug.print("[BLE] removeSensor Count: \(_arrList.count)", event: .warning)
        for item in _arrList {
            if let index = m_connectSensor.index(where: { $0 === item }) {
                item.controller?.setDisconnect()
                m_connectSensor.remove(at: index)
            }
        }
        Debug.print("[BLE] connectSensor Count: \(m_connectSensor.count)", event: .warning)
    }
}
