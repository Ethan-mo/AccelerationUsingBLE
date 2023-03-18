//
//  BlePacket_Utility.swift
//  AccelerationUsingBLE
//
//  Created by 모상현 on 2023/03/07.
//
import Foundation

class BlePacket_Utility {
    static let MAX_BYTE_LENGTH_IN_A_PACKET = 20
    
    static func getRequestPacket(_ packetType: [BlePacketType]) -> [UInt8] {
        var _pkt = [UInt8]()
        _pkt.append(BlePacketType.REQUEST.rawValue)
        _pkt.append(UInt8(0))
        _pkt.append(UInt8(0))
        _pkt.append(UInt8(0))
        
        for item in packetType {
            _pkt.append(item.rawValue)
        }
        return _pkt
    }
    
    static func isLongPacket(_ packets: [UInt8]) -> Bool {
        return (packets[0] & 0xFF) >= 128
    }
    
    static func trimBytes(_ data: [UInt8]) -> [UInt8]? {
        if (data.count == 0) { return nil }
        
        var trimIdx = -1
        for i in (0...(data.count - 1)).reversed() {
            if (data[i] != 0) {
                trimIdx = i
                break
            }
        }
        
        if (trimIdx == -1) { return nil }
        
        var trimmedBytes:[UInt8] = Array(repeating:0, count: trimIdx + 1)
        for i in 0..<(trimIdx + 1) {
            trimmedBytes[i] = data[i]
        }
        
        return trimmedBytes
    }
    
    static func _getUnsignedValue(_ packets: [UInt8]) -> UInt32 {
        let _array : [UInt8] = [0, packets[3], packets[2], packets[1]]
        let _data = Data(bytes: _array)
        let _value = UInt32(bigEndian: _data.withUnsafeBytes { $0.pointee })
        return _value
    }
    
    static func _getUnsignedValueBy24Bit(_ packets: [UInt8]) -> UInt32 {
        guard (packets.count == 2) else {
            Debug.print("[BLE] _getUnsignedValueBy24Bit is null", event: .error)
            return 0
        }
        
        let _array : [UInt8] = [0, 0, packets[1], packets[0]]
        let _data = Data(bytes: _array)
        let _value = UInt32(bigEndian: _data.withUnsafeBytes { $0.pointee })
        return _value
    }
    
    //    func makePacketFor3ByteValue(_ packetType: BlePacketType, value: Int) -> [UInt8] {
    //        var packet:[UInt8] = Array(repeating:0, count: 4)
    //        packet[0] = packetType.rawValue
    //        packet[1] = UInt8(value)
    //        packet[2] = UInt8(value >> 8)
    //        packet[3] = UInt8(value >> 16)
    //        return packet
    //    }
    //
    static func makePacketFor3ByteValues(_ packetType: BlePacketType, value: Int) -> [UInt8] {
        var packet:[UInt8] = Array(repeating:0, count: 4)
        packet[0] = packetType.rawValue
        packet[1] = UInt8(value % 256)
        packet[2] = UInt8((value >> 8) % 256)
        packet[3] = UInt8((value >> 16) % 256)
        return packet
    }
    
    static func makePacketForLongStringValues(_ packetType: BlePacketType, value: String) -> [UInt8] {
        let byteData = [UInt8](value.utf8)
        
        if (byteData.count <= 16) {
            var pkts:[UInt8] = Array(repeating:0, count: byteData.count + 4)
            pkts[0] = packetType.rawValue
            pkts[1] = 0x01
            pkts[2] = 0x01
            pkts[3] = 0x00
            for (i, _) in byteData.enumerated() {
                pkts[4+i] = byteData[i]
            }
            return pkts
        } else {
            var idx = 0
            let pktTotal = Int(ceil(Double(byteData.count) / 16.0))
            var pkts:[UInt8] = Array(repeating:0, count: byteData.count + 4 * pktTotal)
            for i in 0..<pktTotal {
                pkts[i * MAX_BYTE_LENGTH_IN_A_PACKET] = packetType.rawValue
                pkts[i * MAX_BYTE_LENGTH_IN_A_PACKET + 1] = UInt8(pktTotal)
                pkts[i * MAX_BYTE_LENGTH_IN_A_PACKET + 2] = UInt8(i + 1)
                pkts[i * MAX_BYTE_LENGTH_IN_A_PACKET + 3] = 0
                
                for j in 0..<16 {
                    if (idx >= byteData.count) {
                        break
                    }
                    pkts[i * MAX_BYTE_LENGTH_IN_A_PACKET + 4 + j] = byteData[idx]
                    idx += 1
                }
            }
            Debug.print("[BLE] long packets : \(idx), \(pktTotal), \(pkts.count)", event: .warning)
            return pkts
        }
    }
    
    static func getString(_ data: [[UInt8]]) -> String {
        var _compareData = [UInt8]()
        for item in data {
            if (item.count < 4) {
                continue
            }
            for (i, itemChild) in item.enumerated() {
                if (i >= 4) {
                    _compareData.append(itemChild)
                }
            }
        }
        let trimmedBytes = trimBytes(_compareData)
        if (trimmedBytes == nil || trimmedBytes!.count == 0) {
            Debug.print("[BLE] getString is null", event: .warning)
            return ""
        }
        
        var _str = ""
        let _data = NSData(bytes: trimmedBytes, length: (trimmedBytes?.count)!)
        if let string = String(data: _data as Data, encoding: .utf8) {
            _str = string
        }
        Debug.print("[BLE] getString: \(_str)", event: .warning)
        return _str
    }
}
