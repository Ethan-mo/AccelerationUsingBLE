//
//  PeripheralInfo.swift
//  Monit
//
//  Created by 맥 on 2017. 10. 10..
//  Copyright © 2017년 맥. All rights reserved.
//

import Foundation
import CoreBluetooth

class PeripheralLampCallback: NSObject, CBPeripheralDelegate {

    var m_parent: PeripheralLamp_Controller?
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        Debug.print("[BLE_LAMP] didDiscoverServices()", event: .warning)
        if (!(m_parent?.availableCheckType ?? false)) {
            return
        }
        
        if let _error = error {
            if let _info = DataManager.instance.m_userInfo.connectLamp.getLampByPeripheral(peripheral: peripheral) {
                if let _ctrl = _info.controller {
                    _ctrl.m_disConErrorMsg += "[didDiscoverServices]:\(_error as? String ?? "")"
                }
            }
            Debug.print("[BLE_LAMP][ERROR] Error: \(_error)", event: .error)
        }
        
        m_parent!.changeState(status: .connecting)
        
        if let servicePeripheral = peripheral.services as [CBService]? { //get the services of the perifereal
            
            for service in servicePeripheral {
                Debug.print("[BLE_LAMP] service.uuid: \(service.uuid)", event: .warning)
                //Then look for the characteristics of the services
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        Debug.print("[BLE_LAMP] didDiscoverCharacteristicsFor()", event: .warning)
        if (!(m_parent?.availableCheckType ?? false)) {
            return
        }
        
        if let _error = error {
            if let _info = DataManager.instance.m_userInfo.connectLamp.getLampByPeripheral(peripheral: peripheral) {
                if let _ctrl = _info.controller {
                    _ctrl.m_disConErrorMsg += "[Characteristics]:\(_error as? String ?? "")"
                }
            }
            Debug.print("[BLE_LAMP][ERROR] Error: \(_error)", event: .error)
        }
        
        // 0x01 data byte to enable sensor
        //        let enableValue: NSString = "Success"
        
        if let characterArray = service.characteristics as [CBCharacteristic]? {
            for cc in characterArray { // write, read
                
                Debug.print("[BLE_LAMP] cc.uuid: \(cc.uuid)", event: .warning)
                Debug.print("[BLE_LAMP] cc.properties: \(cc.properties)", event: .warning)
                
//                if (cc.properties == CBCharacteristicProperties(rawValue: 12)) {
//                    Debug.print("[BLE_LAMP] set write", event: .warning)
//                    m_parent!.m_write = cc
//
//                    m_parent!.changeState(status: .setInit)
//                } else if (cc.properties == CBCharacteristicProperties(rawValue: 16)) {
//                    Debug.print("[BLE_LAMP] set read", event: .warning)
//                    peripheral.setNotifyValue(true, for: cc)
//                }
                
                if (cc.uuid == DeviceDefine.RX_CHAR_UUID) { // write (12)
                    Debug.print("[BLE_LAMP] set write", event: .warning)
                    m_parent!.m_write = cc

                    m_parent!.changeState(status: .setInit)
                }
                else if (cc.uuid == DeviceDefine.TX_CHAR_UUID) { // read (16)
                    Debug.print("[BLE_LAMP] set read", event: .warning)
                    peripheral.setNotifyValue(true, for: cc)
                    //                    peripheral.readValue(for: cc) // once
                }
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if (!(m_parent?.availableCheckType ?? false)) {
            return
        }
        
        if let _error = error {
            if let _info = DataManager.instance.m_userInfo.connectLamp.getLampByPeripheral(peripheral: peripheral) {
                if let _ctrl = _info.controller {
                    _ctrl.m_disConErrorMsg += "[didUpdateValueFor]:\(_error as? String ?? "")"
                }
            }
            Debug.print("[BLE_LAMP][ERROR] Error: \(_error)", event: .error)
        }
        //        Debug.print("peripheral-update::::::::::::::::")
        //
        //        let dataBytes = characteristic.value
        //        let dataString = String(data: dataBytes!, encoding: String.Encoding.utf8) as String!
        //
        //        Debug.print("[zuo] get : " + dataString!)
        
        if let _readValue = characteristic.value {
//            let value = (_readValue as NSData).bytes.bindMemory(to: Int.self, capacity: _readValue.count).pointee //used to read an Int value
//            Debug.print (value)

            m_parent!.m_packetController!.responseCheck(Array(_readValue))
        }
    }
}
