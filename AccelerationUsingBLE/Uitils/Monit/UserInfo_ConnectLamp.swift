//
//  UserInfo_ConnectLamp.swift
//  Monit
//
//  Created by 맥 on 2017. 9. 15..
//  Copyright © 2017년 맥. All rights reserved.
//

import Foundation
import CoreBluetooth
import CoreData

class BleLampInfo : LampStatusInfo {
    var controller: PeripheralLamp_Controller?
    var peripheral : CBPeripheral?
    
    var m_cid: Int = 0
    var m_srl: String = ""
    var m_firmware: String = ""
    var m_macAddress: String = ""
    var m_enc: String = ""
    var m_adv: String = ""
    var m_sid: String = ""
    
    init() {
        super.init(did: 0, name: "", power: 0, bright: 0, color: 0, attached: 0, temp: 0, hum: 0, voc: 0, ap: "", apse: "", tempmax: 3000, tempmin: 1800, hummax: 6000, hummin: 4000, offt: "0000", onnt: "0000", con: 0, offptime: "", onptime: "")
    }
}

class UserInfo_ConnectLamp {
    
    var m_connectLamp = [BleLampInfo]()
    
    var successConnectLamp: [BleLampInfo] {
        get {
            var _arrInfo = [BleLampInfo]()
            for item in m_connectLamp {
                if (item.controller!.m_status == .connectSuccess && item.controller!.m_isForceDisconnect == false) {
                    _arrInfo.append(item)
                }
            }
            return _arrInfo
        }
    }

    func addLamp(bleInfo: BleLampInfo) {
        removeLampByPeripheral(peripheral: bleInfo.peripheral)
        m_connectLamp.append(bleInfo)
    }
    
    func getLampByPeripheral(peripheral: CBPeripheral?, isSuccessCheck:Bool = false) -> BleLampInfo? {
        if (peripheral == nil) {
            return nil
        }
        
        for item in m_connectLamp {
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
    
    func getLampByDeviceId(deviceId: Int, isSuccessCheck:Bool = false) -> BleLampInfo? {
        for item in m_connectLamp {
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
    
    func removeLampById(deviceId: Int) {
        var _arrList = [BleLampInfo]()
        for item in m_connectLamp {
            if (item.controller!.bleInfo!.m_did == deviceId) {
                Debug.print("[BLE] remove \(deviceId) peripheral object", event: .warning)
                item.controller?.setDisconnect()
                _arrList.append(item)
                continue
            }
        }
        
        Debug.print("[BLE] removeLamp Count: \(_arrList.count)", event: .warning)
        for item in _arrList {
            if let index = m_connectLamp.index(where: { $0 === item }) {
                item.controller?.setDisconnect()
                m_connectLamp.remove(at: index)
            }
        }
        Debug.print("[BLE] connectLamp Count: \(m_connectLamp.count)", event: .warning)
    }

    func removeLampByPeripheral(peripheral: CBPeripheral?) {
        if (peripheral == nil) {
            return
        }
        
        var _arrList = [BleLampInfo]()
        for item in m_connectLamp {
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

        Debug.print("[BLE] removeLamp Count: \(_arrList.count)", event: .warning)
        for item in _arrList {
            if let index = m_connectLamp.index(where: { $0 === item }) {
                item.controller?.setDisconnect()
                m_connectLamp.remove(at: index)
            }
        }
        Debug.print("[BLE] connectLamp Count: \(m_connectLamp.count)", event: .warning)
    }
}
