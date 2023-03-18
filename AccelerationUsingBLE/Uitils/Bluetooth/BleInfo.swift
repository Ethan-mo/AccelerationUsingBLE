//
//  BleInfo.swift
//  AccelerationUsingBLE
//
//  Created by 모상현 on 2023/02/08.
//

import Foundation
import CoreBluetooth

// 센서 정보
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
    
    var state: STATUS = .none
    var m_isForceDisconnect: Bool = false
    
    init() {
        super.init(did: 0, battery: 0, operation: 0, movement: 0, diaperstatus: 0, temp: 0, hum: 0, voc: 0, name: "", bday: "", sex: 0, eat: 0, sens: 0, con: 0, whereConn: 0, voc_avg: 0, dscore: 0, sleep: 0)
    }
}

// 유저에게 연결
class UserInfo_ConnectSensor {
    
    // 유저에게 연결되어있는 센서들
    var m_connectSensor = [BleInfo]()
    
    // 연결에 성공한 센서들
    var successConnectSensor: [BleInfo] {
        get {
            var _arrInfo = [BleInfo]()
            // 현재 유저에게 연결되어 있는 센서들을 하나식 검색한다.
            for item in m_connectSensor {
                // 해당 센서가 성공적으로 연결상태이면서, 강제연결해제상태가 아닌 애들을 임시 배열에 추가.
                if (item.state == .connectSuccess && item.m_isForceDisconnect == false) {
                    _arrInfo.append(item)
                }
            }
            return _arrInfo
        }
    }
    /// 센서 추가
    /// - Parameter bleInfo: 특정 BleInfo를 가진 센서를 [나의 연결중인 센서]목록에 추가한다.
    func addSensor(bleInfo: BleInfo) {
        // 추가하는 과정이지만, 기존에 나의 연결목록에 있었다면, 지운다.
        removeSensorByPeripheral(peripheral: bleInfo.peripheral)
        
        //
        m_connectSensor.append(bleInfo)
    }
    /// 센서의 BleInfo 조회하기
    /// - Parameters:
    ///   - peripheral: 어떤센서?
    ///   - isSuccessCheck: 해당 센서 연결여부
    /// - Returns: 어떤 센서를 선택하고, 해당 센서의 BleInfo값을 가져온다.
    func getSensorByPeripheral(peripheral: CBPeripheral?, isSuccessCheck:Bool = false) -> BleInfo? {
        guard let peripheral = peripheral else { return nil }

        for item in m_connectSensor {
            // 내가 선택한 그 센서가 맞는지, 그리고 강제 연결해제상태가 아닌지
            if (item.peripheral == peripheral && item.m_isForceDisconnect == false) {
                return isSuccessCheck ? item.state == .connectSuccess ? item : nil : item
            }
        }
        return nil
    }
    
    func getSensorByDeviceId(deviceId: Int, isSuccessCheck:Bool = false) -> BleInfo? {
        for item in m_connectSensor {
            if (item.m_did == deviceId && item.m_isForceDisconnect == false) {
                if (isSuccessCheck) {
                    if (item.state == .connectSuccess) {
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
    
//    func removeSensorById(deviceId: Int) {
//        var _arrList = [BleInfo]()
//        for item in m_connectSensor {
//            if (item.controller!.bleInfo!.m_did == deviceId) {
//                Debug.print("[BLE] remove \(deviceId) peripheral object", event: .warning)
//                item.controller?.setDisconnect()
//                _arrList.append(item)
//                continue
//            }
//        }
//
//        Debug.print("[BLE] removeSensor Count: \(_arrList.count)", event: .warning)
//        for item in _arrList {
//            if let index = m_connectSensor.index(where: { $0 === item }) {
//                item.controller?.setDisconnect()
//                m_connectSensor.remove(at: index)
//            }
//        }
//        Debug.print("[BLE] connectSensor Count: \(m_connectSensor.count)", event: .warning)
//    }
    
    /// 센서목록에서 센서 연결취소
    /// - Parameter peripheral: 삭제하고자하는 모닛센서
    func removeSensorByPeripheral(peripheral: CBPeripheral?) {
        // 만약 삭제하고자하는 모닛센서가 nil값이면 return
        guard let peripheral = peripheral else { return }
        
        // 임시 [BleInfo]배열 생성
        var _arrList = [BleInfo]()
        
        // 현재 유저에게 연결되어 있는 센서들을 하나씩 검색한다.
        for item in m_connectSensor {
            // 삭제하고자 하는 센서를 찾으면
            if (item.peripheral == peripheral) {
                // 특정 모닛 센서를 제거합니다.
                print("DEBUG:\(#function)")
                print("DEBUG: 첫번째 if")
                print("DEBUG: 선택한 특정 모닛센서: \(peripheral.name)를 제거합니다.")
                print("[BLE] remove equal peripheral object")
                
                // 연결되어있는 센서의 peripheral Controller에서 setDisconnect를 실행
                ///item.controller?.setDisconnect()
                
                // 임시 배열에 삭제한 항목을 추가
                _arrList.append(item)
            }
            
            // 삭제하고자 하는 센서는 아니였지만,
            // 이름이 같다면 제거
            /// 이 코드는 상황을보고 지워도 될 것같다.
            if (item.m_adv == peripheral.name) {
                print("DEBUG:\(#function)")
                print("DEBUG: 두번째 if")
                print("DEBUG: 선택한 특정 모닛센서: \(peripheral.name)를 제거합니다.")
                print("[BLE] remove equal peripheral name")
                ///item.controller?.setDisconnect()
                _arrList.append(item)
                continue
            }
            
        }
        // 삭제한 센서의 수는
        print("[BLE] removeSensor Count: \(_arrList.count)")
        for item in _arrList {
            if let index = m_connectSensor.index(where: { $0 === item }) {
                // 왜 또 나와서 Disconnect하는지 의문
                ///item.controller?.setDisconnect()
                // 내 목록에서 삭제항목들을 제거한다.
                m_connectSensor.remove(at: index)
            }
        }
        // 현재 연결된 센서들의 수
        print("[BLE] connectSensor Count: \(m_connectSensor.count)")
    }
}
enum STATUS: Int {
    case none = 0
    case connecting = 1
    case setInit = 2
    case getInitInfo = 4
    case checkDeviceId = 5
    case checkCloudId = 6
    case startConnection = 7
    case connectSuccess = 8
    case connectFail = 9
}
