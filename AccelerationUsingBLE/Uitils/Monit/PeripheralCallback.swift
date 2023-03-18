//
//  PeripheralInfo.swift
//  Monit
//
//  Created by 맥 on 2017. 10. 10..
//  Copyright © 2017년 맥. All rights reserved.
//

import Foundation
import CoreBluetooth

class PeripheralCallback: NSObject, CBPeripheralDelegate {

    var m_parent: Peripheral_Controller?
    // service 검색에 성공 시 호출
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        Debug.print("[BLE] didDiscoverServices()", event: .warning)
        if (!(m_parent?.availableCheckType ?? false)) {
            return
        }
        // error가 있을경우
        if let _error = error {
            // _info(BleInfo)에 데이터를 삽입
            if let _info = DataManager.instance.m_userInfo.connectSensor.getSensorByPeripheral(peripheral: peripheral) {
                // _ctrl에 _info에 저장된 peripheral을 삽입
                if let _ctrl = _info.controller {
                    // _ctrl의 m_disConErrorMsg속성에 값을 추가
                    _ctrl.m_disConErrorMsg += "[didDiscoverServices]:\(_error as? String ?? "")"
                }
            }
            Debug.print("[BLE][ERROR] Error: \(_error)", event: .error)
        }
        
        /// error가 없는 경우
        // m_parent peripheral의 m_state의 값을 .connecting으로 변경한다.
        m_parent!.changeState(status: .connecting)
        // servicePeripheral에 현재 선택된 peripheral의 services들을 저장한다.
        if let servicePeripheral = peripheral.services as [CBService]? {
            // 각각의 서비스마다
            for service in servicePeripheral {
                // 서비스의 UUID를 출력
                Debug.print("[BLE] service.uuid: \(service.uuid)", event: .warning)
                // peripheral의 Characteristic을 검색한다.(옵션을 nil로 해서 모든 characteristic을 받아온다.)
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }
    
    // characteristic 검색에 성공 시 호출되는 메서드입니다.
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        Debug.print("[BLE] didDiscoverCharacteristicsFor()", event: .warning)
        // availableCheckType이 뭘까?
        if (!(m_parent?.availableCheckType ?? false)) {
            return
        }
        // 오류 관련 처리
        if let _error = error {
            if let _info = DataManager.instance.m_userInfo.connectSensor.getSensorByPeripheral(peripheral: peripheral) {
                if let _ctrl = _info.controller {
                    _ctrl.m_disConErrorMsg += "[Characteristics]:\(_error as? String ?? "")"
                }
            }
            Debug.print("[BLE][ERROR] Error: \(_error)", event: .error)
        }

        // characteristic이 담겨있는 배열을 만들고
        if let characterArray = service.characteristics as [CBCharacteristic]? {
            for cc in characterArray { // write, read
                
                Debug.print("[BLE] cc.uuid: \(cc.uuid)", event: .warning)
                Debug.print("[BLE] cc.properties: \(cc.properties)", event: .warning)
                
                // 선택된 특정 cc가 Rx_CHAR_UUID라면
                /// 해당 cc를 m_write값에 저장
                /// 그리고 어떤 값들을 셋업한다.
                if (cc.uuid == DeviceDefine.RX_CHAR_UUID) { // write (12)
                    Debug.print("[BLE] set write", event: .warning)
                    m_parent!.m_write = cc
                    m_parent!.changeState(status: .setInit)
                }
                // 선택된 특정 cc가 TX_CHAR_UUID라면
                /// 해당 cc를 알리기위해 setNotifyValue메서드의 매개변수로 사용한다.
                else if (cc.uuid == DeviceDefine.TX_CHAR_UUID) { // read (16)
                    Debug.print("[BLE] set read", event: .warning)
                    peripheral.setNotifyValue(true, for: cc)
                    //                    peripheral.readValue(for: cc) // once
                }
            }
        }
    }
    // peripheral에게 데이터를 전송받으면 호출되는 메서드
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if (!(m_parent?.availableCheckType ?? false)) {
            return
        }
        // 오류 관련 처리
        if let _error = error {
            if let _info = DataManager.instance.m_userInfo.connectSensor.getSensorByPeripheral(peripheral: peripheral) {
                if let _ctrl = _info.controller {
                    _ctrl.m_disConErrorMsg += "[didUpdateValueFor]:\(_error as? String ?? "")"
                }
            }
            Debug.print("[BLE][ERROR] Error: \(_error)", event: .error)
        }
        // 만약 chracteristic의 값이 nil이 아니라면 나의 periphearlController에 있는 packetController의 responseCheck값에 넣는다.
        if let _readValue = characteristic.value {
            m_parent!.m_packetController!.responseCheck(Array(_readValue))
        }
    }
}
