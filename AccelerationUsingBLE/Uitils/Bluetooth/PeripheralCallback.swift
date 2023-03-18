//
//  PeripheralCallback.swift
//  AccelerationUsingBLE
//
//  Created by 모상현 on 2023/03/07.
//
import Foundation
import CoreBluetooth

class PeripheralCallback: NSObject, CBPeripheralDelegate {

    var m_parent: Peripheral_Controller?
    // service 검색에 성공 시 호출
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print("DEBUG: 3단계, Peripheral이 연결되고, service에 대해서 검색 실행")
        print("[BLE] didDiscoverServices()")
//        if (!(m_parent?.availableCheckType ?? false)) {
//            return
//        }
        // error가 있을경우
        if let _error = error {
            Debug.print("[BLE][ERROR] Error: \(_error)", event: .error)
        }
        
        /// error가 없는 경우
        // m_parent peripheral의 m_state의 값을 .connecting으로 변경한다.
        //m_parent!.changeState(status: .connecting)
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
        Debug.print("DEBUG: 3단계 Characteristic을 찾는 것까지 성공[BLE] didDiscoverCharacteristicsFor()", event: .warning)
        // availableCheckType이 뭘까?
        if (!(m_parent?.availableCheckType ?? false)) {
            return
        }
        // 오류 관련 처리
        if let _error = error {
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
            Debug.print("[BLE][ERROR] Error: \(_error)", event: .error)
        }
        // 만약 chracteristic의 값이 nil이 아니라면 나의 periphearlController에 있는 packetController의 responseCheck값에 넣는다.
        if let _readValue = characteristic.value {
            m_parent!.m_packetController!.responseCheck(Array(_readValue))
            print("DEBUG:😝📕🎨❤️💄🪛✨\(_readValue)😝📕🎨❤️💄🪛✨")
        }
    }
}
