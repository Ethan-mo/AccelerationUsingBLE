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
    func 블루투스기기가검색이된후(peripheral : CBPeripheral, RSSI : NSNumber?)
    func 블루투스기기가연결이된후(peripheral : CBPeripheral)
    func 블루투스기기에게메세지를받은후(message: String)
}
// 프로토콜에 포함되어 있는 일부 함수를 옵셔널로 설정합니다.
extension BluetoothSerialDelegate {
    func 블루투스기기가검색이된후(peripheral : CBPeripheral, RSSI : NSNumber?) {}
    func 블루투스기기가연결이된후(peripheral : CBPeripheral) {}
    func 블루투스기기에게메세지를받은후(message: String) {}
}

/// 블루투스 통신을 담당할 시리얼을 클래스로 선언합니다. CoreBluetooth를 사용하기 위한 프로토콜을 추가해야합니다.
class BluetoothSerial: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    // MARK: - Properties
    // BluetoothSerialDelegate 프로토콜에 등록된 메서드를 수행하는 delegate입니다.
    var m_parent: Peripheral_Controller?
    
    var delegate : BluetoothSerialDelegate?
    /// centralManager은 블루투스 주변기기를 검색하고 연결하는 역할을 수행합니다.
    var centralManager : CBCentralManager!
    /// pendingPeripheral은 현재 연결을 시도하고 있는 블루투스 주변기기를 의미합니다.
    var 연결시도중인블루투스기기 : CBPeripheral?
    /// connectedPeripheral은 연결에 성공된 기기를 의미합니다. 기기와 통신을 시작하게되면 이 객체를 이용하게됩니다.
    var 연결성공한블루투스기기 : CBPeripheral?
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
    let RX_CHAR_UUID             = CBUUID(string: "20c10002-71bd-11e7-8cf7-a6006ad3dba0") // 센서에서 보내온 characterstic 1
    let TX_CHAR_UUID             = CBUUID(string: "20c10003-71bd-11e7-8cf7-a6006ad3dba0") // 센서에서 보내온 characterstic 2
    let NOTIFICATION_DESCRIPTION_UUID = CBUUID(string: "00002902-0000-1000-8000-00805f9b34fb")
    /// characteristicUUID는 serviceUUID에 포함되어있습니다. 이를 이용하여 데이터를 송수신합니다. 
    lazy var characteristicUUID = TX_CHAR_UUID
    
    var m_connectSensor = [BleInfo]()
    
    var bleInfo: BleInfo? {
        get {
            return getSensorByPeripheral(peripheral: 연결성공한블루투스기기)
        }
    }
    
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
        /// 모닛의 UUID를 갖는 기기만 검색중
        centralManager.scanForPeripherals(withServices: [RX_SERVICE_UUID], options: nil)
        
        let peripherals = centralManager.retrieveConnectedPeripherals(withServices: [RX_SERVICE_UUID])
        for peripheral in peripherals {
            // TODO : 검색된 기기들에 대한 처리를 여기에 작성합니다.(잠시 후 작성할 예정입니다)
            /// 연결된 센서들에게 각각 delegate(serialDidDiscoverPeripheral)를 실행시킨다.
            /// 실행될 때 마다 ScanSensorController에 있는 TableView에 추가가된다.
            delegate?.블루투스기기가검색이된후(peripheral: peripheral, RSSI: nil)
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
        연결시도중인블루투스기기 = peripheral
        centralManager.connect(peripheral, options: nil)
        delegate?.블루투스기기가연결이된후(peripheral: peripheral)
    }
    
    // 기기가 검색될 때마다 호출
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("DEBUG: \(peripheral.name ?? "알 수 없는")기기를 찾았습니다!")
        delegate?.블루투스기기가검색이된후(peripheral: peripheral, RSSI: RSSI)
    }
    
    
    // 기기 연결가 연결되면 호출
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("DEBUG: \(peripheral.name ?? "알 수 없는")기기와 연결했습니다!")
        let _peripheralController = Peripheral_Controller()
        _peripheralController.m_peripheral = peripheral
        peripheral.delegate = _peripheralController.m_delegate
        let _bleInfo = BleInfo()
        _bleInfo.peripheral = peripheral
        _bleInfo.controller = _peripheralController
        _peripheralController.bleInfo = _bleInfo
        //peripheral.delegate = self
        연결시도중인블루투스기기 = nil
        연결성공한블루투스기기 = peripheral
        
        // peripheral의 Service들을 검색합니다.파라미터를 nil으로 설정하면 peripheral의 모든 service를 검색합니다.
        peripheral.discoverServices([serviceUUID])
    }
    
    
//    // service 검색에 성공 시 호출
//    /// 기존 모닛 코드에서는 현재 periperal의 m_state라는 속성의 값을 connecting으로 변경해주는 작업만이 추가되어있다.
//    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
//
//        for service in peripheral.services! {
//            // 서비스가 무엇이 있는지 좀 보자
//            print("DEBUG: 검색된 서비스는: \(service)")
//            print("DEBUG: servic검색 성공")
//            // 검색된 모든 service에 대해서 characteristic을 검색합니다. 파라미터를 nil로 설정하면 해당 service의 모든 characteristic을 검색합니다.
//            peripheral.discoverCharacteristics(nil, for: service)
//        }
//    }
    
    
    // characteristic 검색에 성공 시 호출되는 메서드입니다.
//    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
//        print("DEBUG: 연결된 기기의 characteristic을 검색하고 있습니다.")
//
//        if let error = error {
//            print("DEBUG: Chacteristic을 검색하는 중에 오류가 발생하였습니다. \nerror:[\(error.localizedDescription)]")
//            return
//        }
//            for cc in service.characteristics! { // write, read
//
//                print("[BLE] Characteristic의 uuid: \(cc.uuid)")
//                print("[BLE] Characteristic의 속성: \(cc.properties)")
//
//                if (cc.uuid == RX_CHAR_UUID) { // write (12)
//                    print("[BLE] set write")
//                    writeCharacteristic = cc // 여기까지는 오케이
//                    m_parent?.changeState(status: .setInit)
//
//
//                    /// 여기에다가 블루투스 기기에 보낼 데이터를 정리한다.
////                    if let _bleInfo = bleInfo {
////                        let tempData:[UInt8] = [130, 1, 1, 0, 32, 33, 34, 16, 21]
////                        let data = Data(bytes: tempData)
////                        peripheral.writeValue(data, for: cc, type: .withResponse)
////                        print("DEBUG: 1차 데이터(Auto_Polling)를 보냈다.")
//
//
//                    }
//                else if (cc.uuid == TX_CHAR_UUID) { // read (16)
//                    print("[BLE] set read")
//                    /// 여기에다가 블루투스 기기에서 보낸 데이터를 정리한다.
//                    peripheral.setNotifyValue(true, for: cc)
//                    //peripheral.readValue(for: cc) // once
//                }
//            }
//    }
    // peripheral으로부터 데이터를 전송받으면 호출되는 메서드입니다.
//       func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
//           print("DEBUG: 모닛 센서가 Data를 전송했습니다.")
//           // 전송받은 데이터가 존재하는지 확인합니다.
//           if let _readValue = characteristic.value {
//               printData(data: Array(_readValue))
//               print(_readValue)
//               // 데이터를 String으로 변환하고, 변환된 값을 파라미터로 한 delegate함수를 호출합니다.
//               if let str = String(data: _readValue, encoding: .utf8) {
//                   print(str)
//                   delegate?.블루투스기기에게메세지를받은후(message : str)
//               } else {
//                   return
//               }
//           }
//       }
    func printData(data: [UInt8]) {
        
    }
    
//    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
//        // writeType이 .withResponse일 때, 블루투스 기기로부터의 응답이 왔을 때 호출되는 함수입니다.
//        // 제가 테스트한 주변 기기는 .withoutResponse이기 때문에 호출되지 않습니다.
//        // writeType이 .withResponse인 블루투스 기기로부터 응답이 왔을 때 필요한 코드를 작성합니다.(필요하다면 작성해주세요.)
//
//    }
//
//    func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
//        // 블루투스 기기의 신호 강도를 요청하는 peripheral.readRSSI()가 호출하는 함수입니다.
//        // 신호 강도와 관련된 코드를 작성합니다.(필요하다면 작성해주세요.)
//    }
    //
    func getSensorByPeripheral(peripheral: CBPeripheral?, isSuccessCheck:Bool = false) -> BleInfo? {
        guard let peripheral = peripheral else { return nil }
        // m_connectSensor값들 중에
        for item in m_connectSensor {
            // 매개변수로 가져온 peripheral과 같은 peripheral을 갖고있는 m_connectSensor값 대상으로 해당 값을 return해준다.
            if (item.peripheral == peripheral) {
                return item
            }
        }
        return nil
    }
}

// CBCentralManagerDelegate에 포함되어 있는 메서드입니다.
// central 기기의 블루투스가 켜져있는지, 꺼져있는지 확인합니다. 확인하여 centralManager.state의 값을 .powerOn 또는 .powerOff로 변경합니다.
extension BluetoothSerial {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("DEBUG:1️⃣ 현재 블루투스 상태 확인중")
        var printMsg:String = {
            switch centralManager.state{
            case .unknown:
                return "unknown"
            case .poweredOn:
                return "블루투스On"
            case .poweredOff:
                return "블루투스Off"
            case .resetting:
                return "다시시작"
            case .unsupported:
                return "연결불가"
            case .unauthorized:
                return "연동불가"
            @unknown default:
                return "알 수 없음"
            }
        }()
        print(printMsg)
        
        연결시도중인블루투스기기 = nil
        연결성공한블루투스기기 = nil
    }
}
