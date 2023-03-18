//
//  Peripheral_Packet.swift
//  Monit
//
//  Created by 맥 on 2017. 10. 10..
//  Copyright © 2017년 맥. All rights reserved.
//

import Foundation
import CoreBluetooth

typealias ActionResultBlePacketInfo = (BlePacketInfo?) -> ()

/// Ble의 패킷정보를 담고있는 객체
/// m_completion: (BlePacketInfo?) -> Void 와 같은 형태의 값을 가지고 있는 속성
/// m_communicationType: request, cmd, noti와 같은 3가지 형태의 값을 갖는 속성
/// m_status: 패킷의 상태를 의미한다. 총 4가지로 구성되어있다. [일반, 전송, 실패, 성공]
/// m_packet: UInt8형태의 값을 배열로 갖는 속성
/// m_receivePacket: UInt8형태의 값을 배열로갖는 값을 배열로 갖는다.
/// m_packetType: Packet의 타입을 갖는다. 총 58개의 타입이 존재한다.
/// m_retryCount: 재전송한 횟수를 카운트한다.
/// m_sendingTime: 재전송한 시간의 총 합을 의미한다.
///
/// init(communicationType, packet, packetType) 세가지 파라미터를 받아 초기화를 진행한다. 이 패킷이 어떤 타입이고 어떤 방식의 소통이고 어떤 Data를 가지고 있는지 묻는다.
/// isRetry: 재전송한 횟수가 2보다 작으면 True, 2 이상이면 false를 return
/// isWaitinh: 재전송에 걸린 시간이 2.5보다 작으면 True 2.5 이상이면 false를 return
class BlePacketInfo {
    
    enum STATUS {
        case none
        case sending
        case fail
        case success
    }
    
    var m_completion: ActionResultBlePacketInfo?
    var m_communicationType: BLE_COMMUNICATION_TYPE?
    var m_status = STATUS.none
    var m_packet: Array<UInt8>?
    var m_receivePacket = [[UInt8]]()
    var m_packetType: BlePacketType?
    var m_retryCount = 0
    var m_sendingTime: Double = 0
    
    init (communicationType: BLE_COMMUNICATION_TYPE, packet: Array<UInt8>, packetType: BlePacketType) {
        self.m_communicationType = communicationType
        self.m_packet = packet
        self.m_packetType = packetType
    }
    
    var isRetry: Bool {
        get {
            if (m_retryCount < 2) {
                return true
            }
            return false
        }
    }
    
    var isWaiting: Bool {
        get {
            if (m_sendingTime <= 2.5) {
                return true
            }
            return false
        }
    }
}

/// Ble 패킷을 관리하는 객체
/// m_parent: Periphearl을 관리하는 객체
/// m_arrRequestPacket: BlePacketInfo들을 담고있는 배열
/// m_updateTimer: 특정 작업을 수행하는 타이머
/// m_timeInertval = ??
/// init(parent: peripheral_conetroller): 자신의 m_parent값을 초기화한다.  + m_updateTimer을 세팅한다.
/// func setInit(): 특정 시간마다 특정 작업을 수행하는 타이머를 만든다. 여기서 만든 타이머는 아래 @objc func update를 0.05초 마다 수행된다.

/// @objc func update() :
///  1) m_arrRequestPacket에 담겨있는 BlePacketInfo의 수가 0이면 return
///  2) m_arrRequestPacket에 담겨있는 첫번쨰 BlePacketInfo의 m_status값이 4경우로 나누어져 일을 수행한다.
///  3-1) m_status값이 .none인 경우
///  3-1-1) item의 값인 m_status값을 .sending으로 설정
///  3-1-2) item의 값인 m_sendingTime값을 0으로 설정
///  3-1-3) 패킷을 요청하는 reqeustPacket(communicationType, packet)메서드 실행
///  3-1-4) 만약, m_communicationType의 값이 .noti일 경우, m_arrRequestPacket의 첫번째 값을 삭제한다.
///
///  3-2) m_status값이 .sending인 경우
///  3-2-1) item의 값인 m_sendingTime의 값에 m_timeInterval을 추가
///  3-2-2) item의 값인 isWaiting이 True가 아닐 떄, 즉, 대기중이지 않을 때, item의 값인 m_status를 .fail로 변경하고 [DEBUG: 시간초과]
///  isWaiting의 값이 true일 때, 즉 계속 대기중일 경우 m_sendingTime에 m_timeInterval을 추가한다.
///
///  3-3) m_status값이 .fail인 경우
///  3-3-1) item의 값인 isRetry가 True일 경우
///  3-3-2) item의 값인 m_retryCount += 1, 그리고 m_status의 값을 .none으로 변경 그리고 [DEBUG: 재전송실패]
///  3-3-3) item의 값인 isRetry가 False일 경우
///  3-3-4 [DEBUG: 패킷전송 실패 재전송 다시시도] 출력 후, 다시 init()을 초기화한다.
///
///  3-4) m_status값이 .success인 경우
///  3-4-1) [DEBUG:성공] 출력 후, m_arrRequestPacket의 첫번째 값(blePacketInfo)을 제거
///
class BlePacket_Controller {
    var m_parent: Peripheral_Controller?
    var m_arrRequestPacket = Array<BlePacketInfo>()
    var m_updateTimer: Timer?
    var m_timeInterval = 0.05
    init (parent: Peripheral_Controller) {
        self.m_parent = parent
        setInit()
    }
    func setInit() {
        m_updateTimer?.invalidate()
        m_updateTimer = Timer.scheduledTimer(timeInterval: m_timeInterval, target: self, selector: #selector(update), userInfo: nil, repeats: true)
    }
    @objc func update() {
        if (m_arrRequestPacket.count <= 0) {
            return
        }
        if let item = m_arrRequestPacket.first {
            switch item.m_status {
            case .none:
                item.m_status = .sending
                item.m_sendingTime = 0
                Debug.print("[BLE] Request Ble Packet: TYPE(\(item.m_communicationType!)), ID(\(item.m_packetType!)), PACKET(\(item.m_packet!.description)))")
                reqeustPacket(communicationType: item.m_communicationType!, packet: item.m_packet!)
                if (item.m_communicationType == .noti) {
                    m_arrRequestPacket.removeFirst()
                }
            case .sending:
                item.m_sendingTime += m_timeInterval
                if (!item.isWaiting) {
                    item.m_status = .fail
                    Debug.print("[ERROR][BLE] packet timeout: \(item.m_packetType!)", event: .error)
                }
            case .fail:
                if (item.isRetry) {
                    item.m_retryCount += 1
                    item.m_status = .none
                    Debug.print("[ERROR][BLE] packet fail resend: \(item.m_packetType!)", event: .error)
                } else {
                    Debug.print("[ERROR][BLE] packet fail retry over: \(item.m_packetType!)", event: .error)
                    if (item.m_completion != nil) {
                        item.m_completion?(item)
                    }
                    m_arrRequestPacket.removeFirst()
                }
            case .success:
                Debug.print("[BLE] success: \(item.m_packetType!)", event: .warning)
                m_arrRequestPacket.removeFirst()
            }
        }
    }
    // responseCheck()
    /// 패킷을 받으면 확인하는 절차
    /// - Parameter data: 들어온 패킷Data를 확인한다.
    /// isFound: 아직 모르겠지만 초기값이 False
    /// m_arrRequestPacket의 첫 번째 값을 item이라는 변수에 저장한다.
    
    /// item이 해당 첫번째 blePacketInfo이 .request 방식으로 통신을 진행한다면, _type값에 파라미터로받은 data의 0번째 값을 삽입
    /// 먼저 item(m_arrRequestPacket의 첫번째 값)의 m_packetType이 _type과 같다면,
    /// [DEBUG: BLE패킷 받음: Type은 ~~~ ID는 ~~~, PACKET은 ~~~~]
    /// 그리고 isFount의 값을 true로 변경
    /// item의 m_receivePacket에 받은 패킷 Data를 저장
    /// 만약, 패킷이 너무 긴 형태라면, 이게 겹쳐 와서 똑같은게 2번온건지, 아니면 진짜 긴 형태인건지를 확인한다.
    /// 진짜로 긴형태로 온거면 item.m_sendingTime의 값을 0으로 초기화한다.
    ///
    /// item이 해당 첫번째 blePacketInfo가 .cmd방식으로 통신을 진행한다면, _type값에 BlePacketType(rawValue:data[2])값을 삽입하고
    /// item의 m_packetType과 _type값을 비교해서 true일 경우, data[1]의 값이 0이라면 ble Packet을 받는것이 성공,
    /// [DEBUG: TYPE:~~~ ID ~~~~ PACKET~~~~]을 출력한다. 그리고 receivepacket을 초기화하고, 그곳에 방금 들어온 Data를 모두 넣는다.
    ///
    /// item이 해당 첫번째 blePacketInfo가 .noti방식으로 통신을 진행한다면, _type값은 파라미터인 data의 0번째 값으로 설정하고,
    /// _type이 특정한 type들중 하나에 속한다면, .... [하지만, 실행될 일이 없음]
    /// _type이 특정한 type들중 하나에 속하지 않는다면. [DEBUG: 센서가 BlePacket을 Noti로 보냈다!]
    /// 그리고 부모 기기의 receiveNotiType에 파라미터로 data를 삽입 ** 중요함 **
    func responseCheck(_ data: [UInt8]) {
        var _isFound = false
        if let item = m_arrRequestPacket.first {
            if (item.m_communicationType == .request) {
                // 정상적인 패킷타입(총 58개)의 한 종류라면
                if let _type: BlePacketType = BlePacketType(rawValue:data[0]) {
                    // 현재 비교할 BlePacketInfo가 파라미터로 가져온 패킷과 같은 패킷타입(packetType)을 가지고 있다면,
                    if (item.m_packetType == _type) {
                        Debug.print("[BLE] Response Ble Packet: TYPE(\(item.m_communicationType!)), ID(\(item.m_packetType!)), PACKET(\(data.description)))")
                        _isFound = true
                        item.m_receivePacket.append(data)
                        if (BlePacket_Utility.isLongPacket(data)) {
                            if (data[1] == data[2]) {
                                item.m_status = .success
                                if (item.m_completion != nil) {
                                    item.m_completion?(item)
                                }
                            } else {
                                item.m_sendingTime = 0
                            }
                        } else {
                            item.m_status = .success
                            if (item.m_completion != nil) {
                                item.m_completion?(item)
                            }
                        }
                    }
                }
            }
            if (item.m_communicationType == .cmd) {
                if let _type: BlePacketType = BlePacketType(rawValue:data[2]) {
                    if (item.m_packetType == _type) {
                        if (0 == data[1]) {
                            Debug.print("[BLE] Response Ble Packet: TYPE(\(item.m_communicationType!)), ID(\(item.m_packetType!)), PACKET(\(data.description)))")
                            _isFound = true
                            item.m_status = .success
                            item.m_receivePacket.removeAll()
                            item.m_receivePacket.append(data)
                            
                            if (item.m_completion != nil) {
                                item.m_completion?(item)
                            }
                        } else {
                            Debug.print("[ERROR][BLE] packet receive nack error", event: .error)
                            item.m_status = .fail
                        }
                    }
                }
            }
        }
        // isFound가 false인 경우는 noti인 경우밖에 없다.
        if (!_isFound) {
            if let _type: BlePacketType = BlePacketType(rawValue:data[0]) {
                if (_type == .KEEP_ALIVE || _type == .TEMPERATURE || _type == .HUMIDITY || _type == .VOC || _type == .TOUCH || _type == .ACCELERATION || _type == .CO2 || _type == .PRESSURE || _type == .RAW_GAS || _type == .COMPENSATED_GAS) {
//                    Debug.print("[BLE] Sensor Noti Ble Packet: PACKET(\(data.description)))", event: .dev)
                } else {
                    Debug.print("[BLE] Sensor Noti Ble Packet: PACKET(\(data.description)))", event: .warning)
                }
            }
            m_parent!.m_packetSensorToLocal?.receiveNotiType(data: data)
            return
        }
    }
    
    func addPacket(_ packet: BlePacketInfo) {
        m_arrRequestPacket.append(packet)
    }
    
    func writeRequest(communicationType: BLE_COMMUNICATION_TYPE, packetType: [BlePacketType], completion: ActionResultBlePacketInfo?) {
        let _packetInfo = BlePacketInfo(communicationType: communicationType, packet: BlePacket_Utility.getRequestPacket(packetType), packetType: packetType.first!)
        _packetInfo.m_completion = completion
        addPacket(_packetInfo)
    }
    
    func writeCmd(communicationType: BLE_COMMUNICATION_TYPE, packetType: BlePacketType, packet: [UInt8], completion: ActionResultBlePacketInfo?) {
        if (packet.count > 20) {
            var chunkedData:[UInt8] = Array(repeating:0, count: 20)
            for i in 0..<packet.count {
                if (i % 20 == 0) {
                    if (i > 0) {
                        let _packetInfo = BlePacketInfo(communicationType: communicationType, packet: chunkedData, packetType: packetType)
                        _packetInfo.m_completion = completion
                        addPacket(_packetInfo)
                    }
                    chunkedData = Array(repeating:0, count: 20)
                }
                chunkedData[i % 20] = packet[i]
            }
            let _packetInfo = BlePacketInfo(communicationType: communicationType, packet: chunkedData, packetType: packetType)
            _packetInfo.m_completion = completion
            addPacket(_packetInfo)
        } else {
            let _packetInfo = BlePacketInfo(communicationType: communicationType, packet: packet, packetType: packetType)
            _packetInfo.m_completion = completion
            addPacket(_packetInfo)
        }
    }
    
    /// 패킷요청
    /// - Parameters:
    ///   - communicationType: request, cmd, noti중 1개
    ///   - packet: 센서에서보낼 패킷지정
    func reqeustPacket(communicationType: BLE_COMMUNICATION_TYPE, packet: [UInt8]) {
        // 센서에 보낼 패킷을 Data형태로 변경한다.
        let _data = Data(bytes: packet)
        // writeValue메서드는 특정 장치에 데이터를 쓸 때 사용된다.
        /// m_parent인 peripheral의 characteristic을 담고있는 m_write에다 _data를 삽입한다.
        m_parent!.m_peripheral?.writeValue(_data, for: m_parent!.m_write!, type: .withResponse)
    }
}
