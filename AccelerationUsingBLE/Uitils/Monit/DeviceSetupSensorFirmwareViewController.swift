//
//  DeviceSetupSensorFirmwareViewController.swift
//  Monit
//
//  Created by 맥 on 2018. 2. 26..
//  Copyright © 2018년 맥. All rights reserved.
//

import UIKit
import CoreBluetooth

class FiwmareScanDevice: BleConnectionManager.ScanDevice {
    var m_isFind: Bool = false
}

class DeviceSetupSensorFirmwareViewController: BaseViewController, CBCentralManagerDelegate {
    @IBOutlet weak var lblNaviTitle: UILabel!
    @IBOutlet weak var lblSensorVersion: UILabel!
    @IBOutlet weak var lblSensorLatestVersion: UILabel!
    @IBOutlet weak var imgSensorLatestVersionNewAlarm: UIImageView!
    @IBOutlet weak var lblSummary: UILabel!
    @IBOutlet weak var lblWarnning: UILabel!
    @IBOutlet weak var btnUpdate: UIButton!
    @IBOutlet weak var btnLastestVersion: UIButton!
    @IBOutlet weak var imgLogoDefault: UIImageView!
    @IBOutlet weak var imgLogoKc: UIImageView!
    @IBOutlet weak var btnBefore: UIButton!
    @IBOutlet weak var btnProduct: UIButton!
    @IBOutlet weak var btnTest: UIButton!
    @IBOutlet weak var btnKc: UIButton!
    
    override var screenType: SCREEN_TYPE { get { return .SENSOR_SETUP_FIRMWARE } }
    static var legacyDfuServiceUUID  = CBUUID(string: "00001530-1212-EFDE-1523-785FEABCD123")
    static let ExperimentalButtonlessDfuUUID = CBUUID(string: "8E400001-F315-4F60-9FB8-838830DAEA50")
    static var secureDfuServiceUUID  = CBUUID(string: "FE59")
    static var deviceInfoServiceUUID = CBUUID(string: "180A")
    
    //MARK: - Class properties
    var centralManager              : CBCentralManager?
    var discoveredPeripherals       : [CBPeripheral]
    var securePeripheralMarkers     : [Bool?]

    var m_arrScanDevice = [FiwmareScanDevice]()
    var isStartFirmware             : Bool = false
    var scanningStarted             : Bool = false
    var isPowered                   : Bool = false
    
    var m_updateTimer: Timer?
    var m_detailInfo: DeviceDetailInfo?
    var m_updateTime: Double = 0
    var m_waitPopupView: PopupView?
    var m_fwv: String? // 진행전 최신으로 업데이트
    var m_isForceInit: Bool = false
    var m_isPackageUpdate: Bool = false
    var m_isSpecificFound: Bool = false
    
    var sensorStatusInfo: SensorStatusInfo? {
        get {
            return DataManager.instance.m_userInfo.deviceStatus.m_sensorStatus.getInfoByDeviceId(did: m_detailInfo!.m_did)
        }
    }
    
    var isConnect: Bool {
        get {
            return DataManager.instance.m_dataController.device.m_sensor.isSensorConnect(type: m_detailInfo!.m_deviceType, did: m_detailInfo!.m_did)
        }
    }
    
    var connectSensor: BleInfo? {
        get {
            return DataManager.instance.m_userInfo.connectSensor.getSensorByDeviceId(deviceId: m_detailInfo!.m_did)
        }
    }
    
    var isNeedUpdate: Bool {
        get {
//            let _latestVersion = DataManager.instance.m_configData.getSensorLatestVersion
            let _latestVersion = DataManager.instance.m_configData.m_latestSensorVersion
            let _currentVersion = connectSensor?.m_firmware ?? "0.0.0"
            
            if (_currentVersion == "0.0.0") {
                return false
            }
            
            if Utility.isUpdateVersion(latestVersion: _latestVersion, currentVersion: _currentVersion) {
                return true
            }
            return false
        }
    }
    
    var isForceUpdate: Bool {
            get {
                let _latestForceVersion = DataManager.instance.m_configData.m_latestSensorForceVersion
                let _currentVersion = connectSensor?.m_firmware ?? "0.0.0"
                
                if (_currentVersion == "0.0.0") {
                    return false
                }
                
                if Utility.isUpdateVersion(latestVersion: _latestForceVersion, currentVersion: _currentVersion) {
                    return true
                }
                return false
            }
        }
    
    required init?(coder aDecoder: NSCoder) {
        discoveredPeripherals   = [CBPeripheral]()
        securePeripheralMarkers = [Bool?]()
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        isUpdateView = false
        super.viewDidLoad()
        Debug.print("[UI][\(self.classNameToString()).viewDidLoad()]")
        setLogoUI()
        setUI()
        if (m_isPackageUpdate) {
            startUpdate(mode: .mode0)
        }
    }
    
    func setInit(detailInfo: DeviceDetailInfo?) {
        Debug.print("[FIRMWARE] setInit()", event: .warning)
        m_detailInfo = detailInfo
    }
    
    func setUI() {
        Debug.print("[FIRMWARE] setUI()", event: .warning)
        lblNaviTitle.text = "title_firmware_update".localized
        
        imgSensorLatestVersionNewAlarm.isHidden = true
        // 허브 업데이트도 있으면 통합 업데이트므로 업데이트 버전 제거
        if (m_isPackageUpdate) {
            lblSensorVersion.text = ""
            lblSensorLatestVersion.text = ""
        } else {
            lblSensorVersion.text = String(format: "%@ %@", "current_version".localized, connectSensor?.m_firmware ?? "0.0.0")
            lblSensorLatestVersion.text = String(format: "%@ %@", "latest_version".localized, DataManager.instance.m_configData.m_latestSensorVersion)

                
            
            if (DataManager.instance.m_dataController.newAlarm.sensorFirmware.isNewAlarmFirmwarePage(did: m_detailInfo!.m_did)) {
                imgSensorLatestVersionNewAlarm.isHidden = false
            }
        }

        lblWarnning.text = "dfu_update_available_caution".localized
        btnUpdate.setTitle("btn_update".localized, for: .normal)
        lblSummary.text = isForceUpdate ? "dfu_update_available_description_force".localized : "dfu_update_available_description".localized
        btnLastestVersion.setTitle("dfu_latest_version".localized, for: .normal)
        UI_Utility.customButtonBorder(button: btnLastestVersion, radius: 20, width: 1, color: COLOR_TYPE.lblWhiteGray.color.cgColor)
        UI_Utility.customButtonBorder(button: btnUpdate, radius: 20, width: 1, color: UIColor.clear.cgColor)
        UI_Utility.customButtonShadow(button: btnUpdate, radius: 1, offsetWidth: 1, offsetHeight: 1, color: UIColor.black.cgColor, opacity: 0.5)
        
        setVersionUI()
    }
    
    func setLogoUI() {
        imgLogoDefault.isHidden = true
        imgLogoKc.isHidden = true
        switch Config.channel {
        case .kc: imgLogoKc.isHidden = false
        default: imgLogoDefault.isHidden = false
        }
    }
    
    func setVersionUI() {
        lblSummary.isHidden = true
        lblWarnning.isHidden = true
        btnUpdate.isHidden = true
        btnLastestVersion.isHidden = true

        if (isNeedUpdate || DataManager.instance.m_userInfo.configData.isMaster) {
            lblSummary.isHidden = false
            lblWarnning.isHidden = false
            btnUpdate.isHidden = false
        } else {
            btnLastestVersion.isHidden = false
        }
        
        btnBefore.isHidden = true
        btnProduct.isHidden = true
        btnTest.isHidden = true
        btnKc.isHidden = true
        if (DataManager.instance.m_userInfo.configData.isMaster) {
            btnBefore.isHidden = false
            btnProduct.isHidden = false
            btnTest.isHidden = false
            btnKc.isHidden = false
        }
        if (DataManager.instance.m_userInfo.configData.isDevelop) {
            btnTest.isHidden = false
        }
        if (DataManager.instance.m_userInfo.configData.isExternalDeveloper) {
            btnKc.isHidden = false
        }
    }
    
    func startDiscovery() {
        if !scanningStarted {
            scanningStarted = true
            Debug.print("[FIRMWARE] Start discovery", event: .warning)
            // the legacy and secure DFU UUIDs are advertised by devices in DFU mode,
            // the device info service is in the adv packet of DFU_HRM sample and the Experimental Buttonless DFU from SDK 12
            centralManager!.delegate = self
//            centralManager!.scanForPeripherals(withServices: [
//                ScannerViewController.legacyDfuServiceUUID,
//                ScannerViewController.secureDfuServiceUUID,
//                ScannerViewController.deviceInfoServiceUUID])
            
            centralManager!.stopScan()
            centralManager!.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: false]) // 중복 허용 안함
        }
    }
    
    func initCentral(mode: SENSOR_FIRMWARE_MODE_TYPE) {
        isStartFirmware = true
        if (isPowered) {
            startDiscovery()
        } else {
            if (centralManager == nil) {
                centralManager          = CBCentralManager(delegate: self, queue: nil) // The delegate must be set in init in order to work on iOS 8
            }
        }
        m_updateTime = 0
        m_updateTimer?.invalidate()
        m_updateTimer = Timer.scheduledTimer(timeInterval: Config.SENSOR_FIRMWARE_SCAN_INTERVAL, target: self, selector: #selector(update(timer:)), userInfo: mode, repeats: true)
    }
    
    func initValues() {
        Debug.print("[FIRMWARE] initValues", event: .warning)
        m_updateTimer?.invalidate()
        scanningStarted = false
        centralManager!.stopScan()
        isStartFirmware = false
        m_isSpecificFound = false
        m_arrScanDevice.removeAll()
        m_waitPopupView?.removeFromSuperview()
        discoveredPeripherals.removeAll()
        securePeripheralMarkers.removeAll()
    }

    @objc func update(timer: Timer) {
        Debug.print("[FIRMWARE] update..", event: .warning)
        if (UIManager.instance.rootCurrentView as? DeviceSetupSensorFirmwareViewController == nil) {
            initValues()
            return
        }
        
        m_updateTime += Config.SENSOR_FIRMWARE_SCAN_INTERVAL
        if (m_updateTime >= Config.SENSOR_FIRMWARE_SCAN_TIMEOUT) {
            if (m_arrScanDevice.count > 0) {
                m_arrScanDevice = m_arrScanDevice.sorted(by: { $0.ssi! > $1.ssi! })
                
                Debug.print("[FIRMWARE] Scanning Found Go update", event: .warning)
                if let _vc = UIManager.instance.sceneMoveNaviPush(scene: .deviceSetupSensorFirmwareUpdate, isAniamtion: !m_isPackageUpdate) as? DeviceSetupSensorFirmwareUpdateViewController {
                    _vc.setInit(detailInfo: m_detailInfo)
                    _vc.m_fwv = self.m_fwv
                    _vc.secureDFUMode(nil)
                    _vc.setTargetPeripheral(nil)
                    _vc.m_arrScanDevice = m_arrScanDevice
                    _vc.setCentralManager(centralManager!)
                    _vc.m_mode = timer.userInfo as? SENSOR_FIRMWARE_MODE_TYPE ?? .mode0
                }
            } else {
                if (isPowered) {
                    _ = PopupManager.instance.onlyContents(contentsKey: "dfu_update_failed", confirmType: .ok, okHandler: { () -> () in
                        self.sceneMoveToBack()
                    })
                } else {
                    _ = PopupManager.instance.onlyContents(contentsKey: "dfu_update_failed", confirmType: .ok, okHandler: { () -> () in
                        _ = PopupManager.instance.onlyContents(contentsKey: "toast_need_to_enable_bluetooth_with_err", confirmType: .cancleSetup, okHandler: { () -> () in
                            _ = Utility.urlOpen(UIManager.instance.getMoveBluetoothSetting())
                            self.sceneMoveToBack()
                        })
                    })
                }
                Debug.print("[FIRMWARE] update timeout", event: .warning)
            }
            initValues()
            return
        }

        if (m_isSpecificFound) {
            Debug.print("[FIRMWARE] Specific Found Go update", event: .warning)
            if let _vc = UIManager.instance.sceneMoveNaviPush(scene: .deviceSetupSensorFirmwareUpdate, isAniamtion: !m_isPackageUpdate) as? DeviceSetupSensorFirmwareUpdateViewController {
                _vc.setInit(detailInfo: m_detailInfo)
                _vc.m_fwv = self.m_fwv
                _vc.secureDFUMode(securePeripheralMarkers[0])
                _vc.setTargetPeripheral(discoveredPeripherals[0])
                _vc.setCentralManager(centralManager!)
                _vc.m_isPackageUpdate = self.m_isPackageUpdate
                _vc.m_mode = timer.userInfo as? SENSOR_FIRMWARE_MODE_TYPE ?? .mode0
            }
            initValues()
            return
        }
    }
    
    //MARK: - CBCentralManagerDelegate API
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            Debug.print("[FIRMWARE] CentralManager is now powered on", event: .warning)
            isPowered = true
            startDiscovery()
        } else {
            isPowered = false
            Debug.print("[FIRMWARE] CentralManager is now powered off", event: .warning)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        if (UIManager.instance.rootCurrentView as? DeviceSetupSensorFirmwareViewController == nil) {
            initValues()
            return
        }
        
        // Ignore dupliactes.
        // They will not be reported in a single scan, as we scan without CBCentralManagerScanOptionAllowDuplicatesKey flag,
        // but after returning from DFU view another scan will be started.
        
        let name = peripheral.name ?? "Unknown"
        Debug.print("[FIRMWARE] Peripheral: \(name), rssi:\(RSSI.int32Value)", event: .warning)

        if (m_isSpecificFound) {
            return
        }

        let _identityName = advertisementData[CBAdvertisementDataLocalNameKey] as? String ?? "Unknown"
        Debug.print("[FIRMWARE] identityName: \(_identityName)", event: .warning)
        if (name.uppercased().contains("MONIT_BL") || _identityName.uppercased().contains("MONIT_BL")) {
            if advertisementData[CBAdvertisementDataServiceUUIDsKey] != nil {
                guard discoveredPeripherals.contains(peripheral) == false else { return }

                let secureUUIDString = DeviceSetupSensorFirmwareViewController.secureDfuServiceUUID.uuidString
                let legacyUUIDString = DeviceSetupSensorFirmwareViewController.legacyDfuServiceUUID.uuidString
                let advertisedUUIDstring = ((advertisementData[CBAdvertisementDataServiceUUIDsKey]!) as AnyObject).firstObject as! CBUUID

                if advertisedUUIDstring.uuidString == secureUUIDString {
                    Debug.print("[FIRMWARE] Found Secure Peripheral: \(name)", event: .warning)
                    discoveredPeripherals.append(peripheral)
                    securePeripheralMarkers.append(true)
                } else if advertisedUUIDstring.uuidString == legacyUUIDString {
                    Debug.print("[FIRMWARE] Found Legacy Peripheral: \(name)", event: .warning)
                    discoveredPeripherals.append(peripheral)
                    securePeripheralMarkers.append(false)
                } else {
                    Debug.print("[FIRMWARE] Found Peripheral: \(name)", event: .warning)
                    discoveredPeripherals.append(peripheral)
                    securePeripheralMarkers.append(nil)
                }
            } else {
                Debug.print("[FIRMWARE] Found CBAdvertisementDataServiceUUIDsKey is null Peripheral: \(name)", event: .warning)
                discoveredPeripherals.append(peripheral)
                securePeripheralMarkers.append(nil)
            }
            Debug.print("[FIRMWARE] SpecificFound!", event: .warning)
            m_isSpecificFound = true
            return
        }

        if (name.uppercased().contains("MONIT") || name == "Unknown" || _identityName.uppercased().contains("MONIT") || _identityName == "Unknown") {
            if (!m_isSpecificFound) {
                //                 if (-65 <= RSSI.int32Value && RSSI.int32Value <= 0) {
                if (RSSI.int32Value <= 0) {
                    var _isFind = false
                    for item in m_arrScanDevice {
                        if (item.peripheral == peripheral) {
                            _isFind = true
                            if (item.ssi! < Int(truncating: RSSI)) {
                                item.ssi = Int(truncating: RSSI)
                            }
                        }
                    }
                    
                    if (!_isFind) {
                        let _sendDevice = FiwmareScanDevice(ssi: Int(truncating: RSSI), peripheral: peripheral, adv: peripheral.name ?? "", uuid: peripheral.identifier.uuidString)
                        m_arrScanDevice.append(_sendDevice)
                    }
                }
            }
        }
    }
    
    @IBAction func onClick_back(_ sender: UIButton) {
        if (m_isForceInit || m_isPackageUpdate) {
            _ = UIManager.instance.sceneMove(scene: .initView, animation: .coverVertical, isAnimation: false)
        } else {
            UIManager.instance.sceneMoveNaviPop(isAnimation: false)
        }
    }
    
    @IBAction func onClick_update(_ sender: UIButton) {
        _ = PopupManager.instance.onlyContents(contentsKey: "dialog_dfu_near_sensor", confirmType: .cancleOK, okHandler: { () -> () in
            self.startUpdate(mode: .mode0)
        })
    }
    
    @IBAction func onClick_before(_ sender: UIButton) {
        self.startUpdate(mode: .mode1)
    }
    
    @IBAction func onClick_product(_ sender: UIButton) {
        self.startUpdate(mode: .mode2)
    }
    
    @IBAction func onClick_test(_ sender: UIButton) {
        self.startUpdate(mode: .mode32)
    }
    
    @IBAction func onClick_kc(_ sender: UIButton) {
        self.startUpdate(mode: .mode128)
    }
    
    func startUpdate(mode: SENSOR_FIRMWARE_MODE_TYPE) {
        if (connectSensor == nil) {
            let _scene = UIManager.instance.sceneMoveNaviPush(scene: .deviceSetupSensorConnecting) as? DeviceSetupSensorConnectingViewController
            _scene?.setInit(detailInfo: m_detailInfo, connectType: .firmware)
            return
        }
        
        
        //            _scene?.setInit(detailInfo: m_detailInfo, connectType: .firmware)
        
        if (!m_isPackageUpdate) {
            m_waitPopupView = PopupManager.instance.withLoading(contentsKey: "dfu_update_waiting".localized, confirmType: .cancle, okHandler: { () -> () in
                self.initValues()
                _ = PopupManager.instance.onlyContents(contentsKey: "dialog_contents_failed_connection_reason_ble", confirmType: .ok, okHandler: { () -> () in
                    self.sceneMoveToBack()
                })
            })
        }
        
        //
        //        if (isStartFirmware) {
        //            _ = PopupManager.instance.onlyContents(contentsKey: "dfu_update_waiting", confirmType: .ok)
        //            return
        //        }
        
//        if !(Utility.isAvailableVersion(availableVersion: Config.SENSOR_FIRMWARE_LIMIT_OS_VERSION, currentVersion: UIDevice.current.systemVersion)) {
//            _ = PopupManager.instance.onlyContents(contentsKey: "dfu_update_need_latestversion", confirmType: .ok)
//            Debug.print("[FIRMWARE] limitVersion not available", event: .warning)
//            return
//        }
        
//        if (connectSensor!.m_battery < Config.SENSOR_FIRMWARE_LIMIT_BATTERY) {
//            Debug.print("[FIRMWARE] battery low error", event: .warning)
//            _ = PopupManager.instance.onlyContents(contentsKey: "dialog_contents_dfu_low_battery", confirmType: .ok, okHandler: { () -> () in
//                self.sceneMoveToBack()
//            })
//            return
//        }
        
        connectSensor!.controller!.m_packetRequest!.updateFirmwareVersion(completion: { (isSuccess) in
            if (isSuccess) {
                self.m_fwv = self.connectSensor!.controller!.bleInfo!.m_firmware
                self.connectSensor!.controller!.m_packetCommend!.setDFU()
                self.initCentral(mode: mode)
            } else {
                _ = PopupManager.instance.onlyContents(contentsKey: "dfu_update_failed", confirmType: .ok, okHandler: { () -> () in
                    self.sceneMoveToBack()
                })
            }
        })
    }
    
    func sceneMoveToBack() {
        if (m_isPackageUpdate) {
            _ = UIManager.instance.sceneMove(scene: .initView, animation: .coverVertical, isAnimation: false)
        } else {
            UIManager.instance.sceneMoveNaviPop()
        }
    }
}
