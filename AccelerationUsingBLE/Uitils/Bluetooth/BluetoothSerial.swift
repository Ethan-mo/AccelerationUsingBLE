//
//  BluetoothSerial.swift
//  AccelerationUsingBLE
//
//  Created by 모상현 on 2023/02/07.
//

import UIKit
import CoreBluetooth

var serial: BluetoothSerial!

// 블루투스를 연결하는 과정에서의 시리얼과 뷰의 소통을 위해 필요한 프로토콜입니다.
protocol BluetoothSerialDelegate : AnyObject {
    func serialDidDiscoverPeripheral(peripheral : CBPeripheral, RSSI : NSNumber?)
    func serialDidConnectPeripheral(peripheral : CBPeripheral)
}
// 프로토콜에 포함되어 있는 일부 함수를 옵셔널로 설정합니다.
extension BluetoothSerialDelegate {
    func serialDidDiscoverPeripheral(peripheral : CBPeripheral, RSSI : NSNumber?) {}
    func serialDidConnectPeripheral(peripheral : CBPeripheral) {}
}

/// 블루투스 통신을 담당할 시리얼을 클래스로 선언합니다. CoreBluetooth를 사용하기 위한 프로토콜을 추가해야합니다.
class BluetoothSerial: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    // MARK: - Properties
    // BluetoothSerialDelegate 프로토콜에 등록된 메서드를 수행하는 delegate입니다.
    var delegate : BluetoothSerialDelegate?
    
    /// centralManager은 블루투스 주변기기를 검색하고 연결하는 역할을 수행합니다.
    var centralManager : CBCentralManager!
    
    /// pendingPeripheral은 현재 연결을 시도하고 있는 블루투스 주변기기를 의미합니다.
    var pendingPeripheral : CBPeripheral?
    
    /// connectedPeripheral은 연결에 성공된 기기를 의미합니다. 기기와 통신을 시작하게되면 이 객체를 이용하게됩니다.
    var connectedPeripheral : CBPeripheral?
    
    /// 데이터를 주변기기에 보내기 위한 characteristic을 저장하는 변수입니다.
    weak var writeCharacteristic: CBCharacteristic?
    
    /// 데이터를 주변기기에 보내는 type을 설정합니다. withResponse는 데이터를 보내면 이에 대한 답장이 오는 경우입니다. withoutResponse는 반대로 데이터를 보내도 답장이 오지 않는 경우입니다.
    private var writeType: CBCharacteristicWriteType = .withoutResponse
    
    /// serviceUUID는 Peripheral이 가지고 있는 서비스의 UUID를 뜻합니다.
    var serviceUUID = CBUUID(string: "20c10001-71bd-11e7-8cf7-a6006ad3dba0") // 이건 뭔지 모르겠음
    var legacyDfuServiceUUID  = CBUUID(string: "00001530-1212-EFDE-1523-785FEABCD123")
    let ExperimentalButtonlessDfuUUID = CBUUID(string: "8E400001-F315-4F60-9FB8-838830DAEA50")
    var secureDfuServiceUUID  = CBUUID(string: "FE59")
    var deviceInfoServiceUUID = CBUUID(string: "180A")
    let EX_RX_SERVICE_UUID       = CBUUID(string: "6e400001-b5a3-f393-e0a9-e50e24dcca9e")
    let EX_NOTIFICATION_DESCRIPTION_UUID = CBUUID(string: "00002902-0000-1000-8000-00805f9b34fb")
    let EX_RX_CHAR_UUID          = CBUUID(string: "6e400002-b5a3-f393-e0a9-e50e24dcca9e")
    let EX_TX_CHAR_UUID          = CBUUID(string: "6e400003-b5a3-f393-e0a9-e50e24dcca9e")
    
    let RX_SERVICE_UUID          = CBUUID(string: "20c10001-71bd-11e7-8cf7-a6006ad3dba0") // 모닛 센서들의 UUID
    let RX_CHAR_UUID             = CBUUID(string: "20c10002-71bd-11e7-8cf7-a6006ad3dba0")
    let TX_CHAR_UUID             = CBUUID(string: "20c10003-71bd-11e7-8cf7-a6006ad3dba0")
    let NOTIFICATION_DESCRIPTION_UUID = CBUUID(string: "00002902-0000-1000-8000-00805f9b34fb")
    
    /// characteristicUUID는 serviceUUID에 포함되어있습니다. 이를 이용하여 데이터를 송수신합니다. 
    var characteristicUUID = CBUUID(string : "20c10002-71bd-11e7-8cf7-a6006ad3dba0")
    
    // MARK: - Lifecycle
    override init() {
        super.init()
        self.centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    // MARK: - Helpers
    
    /// 기기 검색을 시작합니다. 연결이 가능한 모든 주변기기를 serviceUUID를 통해 찾아냅니다.
    func startScan() {
        print("DEBUG: centralManager.state 확인중")
        if centralManager.state == .poweredOff {
            print("DEBUG: 불루투스가 꺼져있음")
        }
        print(centralManager.state.rawValue)
        guard centralManager.state == .poweredOn else { return }
        print("DEBUG: 기기검색중")
        // CBCentralManager의 메서드인 scanForPeripherals를 호출하여 연결가능한 기기들을 검색합니다. 이 떄 withService 파라미터에 nil을 입력하면 모든 종류의 기기가 검색되고, 지금과 같이
        // serviceUUID를 입력하면 특정 serviceUUID를 가진 기기만을 검색합니다.
        centralManager.scanForPeripherals(withServices: [RX_SERVICE_UUID], options: nil)
        let peripherals = centralManager.retrieveConnectedPeripherals(withServices: [RX_SERVICE_UUID])
        for peripheral in peripherals {
            // TODO : 검색된 기기들에 대한 처리를 여기에 작성합니다.(잠시 후 작성할 예정입니다)
            delegate?.serialDidDiscoverPeripheral(peripheral: peripheral, RSSI: nil)
            
        }
    }
    
    /// 기기 검색을 중단합니다.
    func stopScan() {
        centralManager.stopScan()
    }
    
    /// 파라미터로 넘어온 주변 기기를 CentralManager에 연결하도록 시도합니다.
    func connectToPeripheral(_ peripheral : CBPeripheral)
    {
        // 연결 실패를 대비하여 현재 연결 중인 주변 기기를 저장합니다.
        pendingPeripheral = peripheral
        centralManager.connect(peripheral, options: nil)
    }
    
    // 기기가 검색될 때마다 호출되는 메서드입니다.
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        // RSSI는 기기의 신호 강도를 의미합니다.
        print("DEBUG: 찾았다!")
        // TODO : 기기가 검색될 때마다 필요한 코드를 여기에 작성합니다.(잠시 후 작성할 예정입니다)
        delegate?.serialDidDiscoverPeripheral(peripheral: peripheral, RSSI: RSSI)
    }
    
    
    // 기기 연결가 연결되면 호출되는 메서드입니다.
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("DEBUG: 찾았다!")
        peripheral.delegate = self
        pendingPeripheral = nil
        connectedPeripheral = peripheral
        
        // peripheral의 Service들을 검색합니다.파라미터를 nil으로 설정하면 peripheral의 모든 service를 검색합니다.
        peripheral.discoverServices([serviceUUID])
    }
    
    
    // service 검색에 성공 시 호출되는 메서드입니다.
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        for service in peripheral.services! {
            // 검색된 모든 service에 대해서 characteristic을 검색합니다. 파라미터를 nil로 설정하면 해당 service의 모든 characteristic을 검색합니다.
            peripheral.discoverCharacteristics([characteristicUUID], for: service)
        }
    }
    
    
    // characteristic 검색에 성공 시 호출되는 메서드입니다.
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        for characteristic in service.characteristics! {
            // 검색된 모든 characteristic에 대해 characteristicUUID를 한번 더 체크하고, 일치한다면 peripheral을 구독하고 통신을 위한 설정을 완료합니다.
            if characteristic.uuid == characteristicUUID {
                // 해당 기기의 데이터를 구독합니다.
                peripheral.setNotifyValue(true, for: characteristic)
                // 데이터를 보내기 위한 characteristic을 저장합니다.
                writeCharacteristic = characteristic
                // 데이터를 보내는 타입을 설정합니다. 이는 주변기기가 어떤 type으로 설정되어 있는지에 따라 변경됩니다.
                writeType = characteristic.properties.contains(.write) ? .withResponse :  .withoutResponse
                // TODO : 주변 기기와 연결 완료 시 동작하는 코드를 여기에 작성합니다.(잠시 후 작성할 예정입니다)
                delegate?.serialDidConnectPeripheral(peripheral: peripheral)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        // writeType이 .withResponse일 때, 블루투스 기기로부터의 응답이 왔을 때 호출되는 함수입니다.
        // 제가 테스트한 주변 기기는 .withoutResponse이기 때문에 호출되지 않습니다.
        // writeType이 .withResponse인 블루투스 기기로부터 응답이 왔을 때 필요한 코드를 작성합니다.(필요하다면 작성해주세요.)
        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        // 블루투스 기기의 신호 강도를 요청하는 peripheral.readRSSI()가 호출하는 함수입니다.
        // 신호 강도와 관련된 코드를 작성합니다.(필요하다면 작성해주세요.)
    }
}

// CBCentralManagerDelegate에 포함되어 있는 메서드입니다.
// central 기기의 블루투스가 켜져있는지, 꺼져있는지 확인합니다. 확인하여 centralManager.state의 값을 .powerOn 또는 .powerOff로 변경합니다.
extension BluetoothSerial {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("DEBUG: 현재 블루투스 상태 확인중")
        print(centralManager.state.rawValue)
        
        pendingPeripheral = nil
        connectedPeripheral = nil
    }
}
