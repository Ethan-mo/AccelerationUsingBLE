//
//  BlePacket_Controller.swift
//  AccelerationUsingBLE
//
//  Created by 모상현 on 2023/03/07.
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
                print("[BLE] Request Ble Packet: TYPE(\(item.m_communicationType!)), ID(\(item.m_packetType!)), PACKET(\(item.m_packet!.description)))")
                reqeustPacket(communicationType: item.m_communicationType!, packet: item.m_packet!)
                if (item.m_communicationType == .noti) {
                    m_arrRequestPacket.removeFirst()
                }
            case .sending:
                item.m_sendingTime += m_timeInterval
                if (!item.isWaiting) {
                    item.m_status = .fail
                    print("[ERROR][BLE] packet timeout: \(item.m_packetType!)")
                }
            case .fail:
                if (item.isRetry) {
                    item.m_retryCount += 1
                    item.m_status = .none
                    print("[ERROR][BLE] packet fail resend: \(item.m_packetType!)")
                } else {
                    print("[ERROR][BLE] packet fail retry over: \(item.m_packetType!)")
                    if (item.m_completion != nil) {
                        item.m_completion?(item)
                    }
                    m_arrRequestPacket.removeFirst()
                }
            case .success:
                print("[BLE] success: \(item.m_packetType!)")
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
                        print("[BLE] Response Ble Packet: TYPE(\(item.m_communicationType!)), ID(\(item.m_packetType!)), PACKET(\(data.description)))")
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
                            Debug.print("[BLE] 😝센서가 cmd Type으로 Data를 보내왔습니다.")
                            Debug.print("[BLE] 😝Response Ble Packet: TYPE(\(item.m_communicationType!)), ID(\(item.m_packetType!)), PACKET(\(data.description)))")
                            _isFound = true
                            item.m_status = .success
                            item.m_receivePacket.removeAll()
                            item.m_receivePacket.append(data)
                            Debug.print("[BLE] 😝 m_receivePacket Array에 data가 추가되었습니다. ")
                            Debug.print("[BLE] 😝 현재 m_receivePacket Array의 값:\(item.m_receivePacket)")
                            
                            if (item.m_completion != nil) {
                                item.m_completion?(item)
                            }
                        } else {
                            print("[ERROR][BLE] packet receive nack error")
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
                    print("[BLE] Sensor Noti Ble Packet: PACKET(\(data.description)))")
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
        print("writeCmd(communicationType:\(communicationType) ,packetType:\(packetType) ,packet: \(packet),)가 실행되었습니다.")
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
            print("짧은 크기의 writeCmd가실행됨")
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
