/*
 * Copyright (c) 2016, Nordic Semiconductor
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the
 * documentation and/or other materials provided with the distribution.
 *
 * 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this
 * software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 * HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
 * ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE
 * USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

import UIKit
import CoreBluetooth
import iOSDFULibrary

class DeviceSetupSensorFirmwareUpdateViewController: BaseViewController, CBCentralManagerDelegate, CBPeripheralDelegate, DFUServiceDelegate, DFUProgressDelegate, LoggerDelegate {
    /// The UUID of the experimental Buttonless DFU Service from SDK 12.
    /// This service is not advertised so the app needs to connect to check if it's on the device's attribute list.
    static let ExperimentalButtonlessDfuUUID = CBUUID(string: "8E400001-F315-4F60-9FB8-838830DAEA50")
    
    //MARK: - Class Properties
    fileprivate var dfuPeripheral    : CBPeripheral?
    fileprivate var dfuController    : DFUServiceController?
    fileprivate var centralManager   : CBCentralManager?
    fileprivate var selectedFirmware : DFUFirmware?
    fileprivate var selectedFileURL  : URL?
    fileprivate var secureDFU        : Bool?
    
    //MARK: - View Outlets
    @IBOutlet weak var lblNaviTitle: UILabel!
    @IBOutlet weak var lblWarningSummary: UILabel!
    @IBOutlet weak var dfuActivityIndicator  : UIActivityIndicatorView!
    @IBOutlet weak var dfuStatusLabel        : UILabel!
    @IBOutlet weak var dfuUploadProgressView : UIProgressView!
    @IBOutlet weak var lblPercent: UILabel!
    //    @IBOutlet weak var dfuUploadStatus       : UILabel!
    @IBOutlet weak var stopProcessButton     : UIButton!
    
    @IBOutlet weak var imgLogoDefault: UIImageView!
    @IBOutlet weak var imgLogoKC: UIImageView!
    
    override var screenType: SCREEN_TYPE { get { return .SENSOR_SETUP_FIRMWARE } }
    var m_detailInfo: DeviceDetailInfo?
    var m_arrScanDevice: [FiwmareScanDevice]?
    var m_connectingPeripheral: CBPeripheral?
    var m_fileName: String = ""
    var m_fwv: String?
    var m_bleName: String = "" // after bootloader updating
    var m_updateTimer: Timer?
    var m_updateTime: Double = 0
    var m_isPackageUpdate: Bool = false
    var m_mode: SENSOR_FIRMWARE_MODE_TYPE = .mode0
    
    func setInit(detailInfo: DeviceDetailInfo?) {
        m_detailInfo = detailInfo
    }
    
    var sensorStatusInfo: SensorStatusInfo? {
        get {
            return DataManager.instance.m_userInfo.deviceStatus.m_sensorStatus.getInfoByDeviceId(did: m_detailInfo!.m_did)
        }
    }
    
    // 주의 dfu 들어가면 끊김
    var connectSensor: BleInfo? {
        get {
            return DataManager.instance.m_userInfo.connectSensor.getSensorByDeviceId(deviceId: m_detailInfo!.m_did)
        }
    }
    
    var userInfo: UserInfoDevice? {
        get {
            return DataManager.instance.m_dataController.device.getUserInfoByDid(did: m_detailInfo!.m_did, type: DEVICE_TYPE.Sensor.rawValue)
        }
    }
    
    var isForceUpdate: Bool {
        get {
            guard (Config.channel == .kc) else { return false }
            
            let _latestForceVersion = DataManager.instance.m_configData.m_latestSensorForceVersion
            let _currentVersion = userInfo?.fwv ?? "0.0.0"
            
            if (_currentVersion == "0.0.0") {
                return false
            }
            
            if Utility.isUpdateVersion(latestVersion: _latestForceVersion, currentVersion: _currentVersion) {
                return true
            }
            return false
        }
    }
    
    //MARK: - View Actions
    @IBAction func stopProcessButtonTapped(_ sender: AnyObject) {
        guard dfuController != nil else {
            Debug.print("[FIRMWARE] No DFU peripheral was set", event: .warning)
            return
        }
        guard !dfuController!.aborted else {
            stopProcessButton.setTitle("btn_cancel".localized, for: .normal)
            dfuController!.restart()
            return
        }
        
        Debug.print("[FIRMWARE] Action: DFU paused", event: .warning)
        dfuController!.pause()
        let alertView = UIAlertController(title: nil, message: "dfu_update_stop_process".localized, preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: "btn_yes".localized, style: .destructive) {
            (action) in
            Debug.print("[FIRMWARE] Action: DFU aborted", event: .warning)
            _ = self.dfuController?.abort()
        })
        alertView.addAction(UIAlertAction(title: "btn_cancel".localized, style: .cancel) {
            (action) in
            Debug.print("[FIRMWARE] Action: DFU resumed", event: .warning)
            self.dfuController?.resume()
        })
        present(alertView, animated: true)
    }
    
    //MARK: - Class Implementation
    func secureDFUMode(_ secureDFU: Bool?) {
        self.secureDFU = secureDFU
    }
    
    func setCentralManager(_ centralManager: CBCentralManager) {
        self.centralManager = centralManager
    }
    
    func setTargetPeripheral(_ targetPeripheral: CBPeripheral?) {
        self.dfuPeripheral = targetPeripheral
    }
    
    // file in local
    //    func getBundledFirmwareURLHelper() -> URL? {
    //        if let secureDFU = secureDFU {
    //            if secureDFU {
    //                if let _arr = Bundle.main.urls(forResourcesWithExtension: "zip", subdirectory: "SensorFirmware") {
    //                    for item in _arr {
    //                        if (item.lastPathComponent == DataManager.instance.m_configData.getSensorLatestVersionName) {
    //                            return item
    //                        }
    //                    }
    //                }
    //            } else {
    //                if let _arr = Bundle.main.urls(forResourcesWithExtension: "zip", subdirectory: "SensorFirmware") {
    //                    for item in _arr {
    //                        if (item.lastPathComponent == DataManager.instance.m_configData.getSensorLatestVersionName) {
    //                            return item
    //                        }
    //                    }
    //                }
    //            }
    //        } else {
    //            // We need to connect and discover services. The device does not have to advertise with the service UUID.
    //            return nil
    //        }
    //        return nil
    //    }
    
    func getBundledFirmwareURLHelper() -> URL? {
        if let secureDFU = secureDFU {
            if secureDFU {
                let file = m_fileName
                if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                    let fileURL = dir.appendingPathComponent(file)
                    return fileURL
                }
            } else {
                let file = m_fileName
                if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                    let fileURL = dir.appendingPathComponent(file)
                    return fileURL
                }
            }
        } else {
            // We need to connect and discover services. The device does not have to advertise with the service UUID.
            return nil
        }
        return nil
    }
    
    
    func startDFUProcess() {
        guard dfuPeripheral != nil else {
            Debug.print("[FIRMWARE] No DFU peripheral was set", event: .warning)
            return
        }
        
        let dfuInitiator = DFUServiceInitiator(centralManager: centralManager!, target: dfuPeripheral!)
        dfuInitiator.delegate = self
        dfuInitiator.progressDelegate = self
        dfuInitiator.logger = self
        
        // This enables the experimental Buttonless DFU feature from SDK 12.
        // Please, read the field documentation before use.
        dfuInitiator.enableUnsafeExperimentalButtonlessServiceInSecureDfu = true
        
        if let _selFwv = selectedFirmware {
            dfuController = dfuInitiator.with(firmware: _selFwv).start()
        } else {
            Debug.print("[ERROR] Download Fail.. selectedFirmware is null", event: .error)
            self.dfuStatusLabel.text = "File Download Failed."
            _ = PopupManager.instance.onlyContents(contentsKey: "dfu_update_failed", confirmType: .ok, okHandler: { () -> () in
                self.sceneMoveToBack()
            })
        }
    }
    
    override func viewDidLoad() {
        isUpdateView = false
        super.viewDidLoad()
        Debug.print("[UI][\(self.classNameToString()).viewDidLoad()]")
        setLogoUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let _name = dfuPeripheral?.name ?? ""
        Debug.print("[FIRMWARE] Flashing \(_name)...", event: .warning)
        //        peripheralNameLabel.text = ""
        dfuActivityIndicator.startAnimating()
//        dfuUploadProgressView.progress = 0.0
        lblPercent.text = "(0%)"
        //        dfuUploadStatus.text = ""
        dfuStatusLabel.text  = ""
        lblNaviTitle.text = "title_firmware_update".localized
        lblWarningSummary.text = "dfu_update_available_caution".localized
        
        stopProcessButton.isEnabled = false
        if (isForceUpdate) {
            self.stopProcessButton.setTitle("dfu_status_uploading".localized, for: .normal)
            self.stopProcessButton.backgroundColor = COLOR_TYPE.lblWhiteGray.color
            UI_Utility.customButtonBorder(button: self.stopProcessButton, radius: 20, width: 1, color: UIColor.clear.cgColor)
            UI_Utility.customButtonShadow(button: self.stopProcessButton, radius: 1, offsetWidth: 1, offsetHeight: 1, color: UIColor.black.cgColor, opacity: 0.5)
        } else {
            self.stopProcessButton.setTitle("btn_cancel".localized, for: .normal)
            UI_Utility.customButtonBorder(button: stopProcessButton, radius: 20, width: 1, color: UIColor.clear.cgColor)
            UI_Utility.customButtonShadow(button: stopProcessButton, radius: 1, offsetWidth: 1, offsetHeight: 1, color: UIColor.black.cgColor, opacity: 0.5)
        }
        
        // delete default data
        //        deleteSensor(did: m_detailInfo?.m_did ?? 0)
    }
    
    func deleteSensor(did: Int) {
        if let _bleInfo = DataManager.instance.m_userInfo.connectSensor.getSensorByDeviceId(deviceId: did) {
            BleConnectionManager.instance.removeReconnect(peripheral: _bleInfo.peripheral!)
        }
        DataManager.instance.m_userInfo.connectSensor.removeSensorById(deviceId: did)
        DataManager.instance.m_userInfo.storeConnectedSensor.deleteItemByDid(did: did)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        getDownloadURL()
        getDownloadURL_V2()
    }
    
    func setLogoUI() {
        imgLogoDefault.isHidden = true
        imgLogoKC.isHidden = true
        switch Config.channel {
        case .kc: imgLogoKC.isHidden = false
        default: imgLogoDefault.isHidden = false
        }
    }
    
    func getDownloadURL() {
        dfuStatusLabel.text = "Downloading"
        
        let send = Send_GetSensorFW()
        send.aid = DataManager.instance.m_userInfo.account_id
        send.token = DataManager.instance.m_userInfo.token
        send.did = m_detailInfo!.m_did
        send.enc = connectSensor?.m_enc ?? ""
        send.mode = m_mode.rawValue
        NetworkManager.instance.Request(send) { (json) -> () in
            let receive = Receive_GetSensorFW(json)
            switch receive.ecd {
            case .success:
                self.m_fileName = receive.file ?? ""
                self.downloadFile(url: receive.url ?? "", file: receive.file ?? "")
                
                //                self.m_fileName = "fw_diaper_sensor_1.0.1(7)_debug.zip"
                //                self.downloadFile(url: "https://goodmonit.blob.core.windows.net/otaupdate/sensor/fw_diaper_sensor_1.0.1(7)_debug.zip", file: "fw_diaper_sensor_1.0.1(7)_debug.zip")
                
            default:
                Debug.print("[ERROR] Receive_GetSensorFW invaild errcod", event: .error)
                self.dfuStatusLabel.text = "File Download Failed."
                _ = PopupManager.instance.onlyContents(contentsKey: "dfu_update_failed", confirmType: .ok, okHandler: { () -> () in
                    self.sceneMoveToBack()
                })
            }
        }
    }
    
    func downloadFile(url: String, file: String) {
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = dir.appendingPathComponent(file)
            Debug.print("[FIRMWARE] downloadURL: \(url)", event: .warning)
            Debug.print("[FIRMWARE] fileURL: \(fileURL)", event: .warning)
            if let URL = NSURL(string: url) {
                DownloadManager.instance.load(url: URL as URL, to: fileURL, completion: {
                    (isSuccess) in
                    if (isSuccess) {
                        self.startProcess()
                    } else {
                        Debug.print("[ERROR] Download Fail..", event: .error)
                        self.dfuStatusLabel.text = "File Download Failed."
                        _ = PopupManager.instance.onlyContents(contentsKey: "dfu_update_failed", confirmType: .ok, okHandler: { () -> () in
                            self.sceneMoveToBack()
                        })
                        return
                    }
                })
            }
        }
    }
    
    func getDownloadURL_V2() {
        dfuStatusLabel.text = "Downloading"
        
        let send = Send_GetSensorFWV2()
        send.aid = DataManager.instance.m_userInfo.account_id
        send.token = DataManager.instance.m_userInfo.token
        send.did = m_detailInfo!.m_did
        send.enc = connectSensor?.m_enc ?? ""
        send.mode = m_mode.rawValue
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = dir.appendingPathComponent("fw_diaper_sensor.zip")
            DownloadManager.instance.packetLoad(send, to: fileURL, completion: {
                (isSuccess) in
                if (isSuccess) {
                    self.m_fileName = "fw_diaper_sensor.zip"
                    self.startProcess()
                } else {
                    Debug.print("[ERROR] Download Fail..", event: .error)
                    self.dfuStatusLabel.text = "File Download Failed."
                    _ = PopupManager.instance.onlyContents(contentsKey: "dfu_update_failed", confirmType: .ok, okHandler: { () -> () in
                        self.sceneMoveToBack()
                    })
                    return
                }
            })
        }
    }
    
    func startProcess() {
//        selectedFileURL  = getBundledFirmwareURLHelper()
//        if selectedFileURL != nil {
//            selectedFirmware = DFUFirmware(urlToZipFile: selectedFileURL!)
//            startDFUProcess()
//        } else {
//            centralManager!.delegate = self
//            centralManager!.connect(dfuPeripheral!)
//        }
        connectForScanList()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        _ = dfuController?.abort()
        dfuController = nil
    }
    
    func connectForScanList() {
        if (dfuPeripheral != nil) {
            centralManager!.delegate = self
            centralManager!.connect(dfuPeripheral!)
        } else {
            if let _arrScanDevice = m_arrScanDevice {
                //            for item in _arrScanDevice {
                //                Debug.print(String(format: "[FIRMWARE] list: name: %@, ssi: %d, isTry: %@", item.peripheral?.name ?? "", item.ssi ?? 0, item.m_isFind.description), event: .warning)
                //            }
                
                var _isFound = false
                for item in _arrScanDevice {
                    if (!(item.m_isFind)) {
                        m_updateTime = 0
                        m_updateTimer?.invalidate()
                        
                        DispatchQueue.main.async {
                            self.m_updateTimer = Timer.scheduledTimer(timeInterval: Config.SENSOR_FIRMWARE_SCAN_INTERVAL, target: self, selector: #selector(self.updateConnecting), userInfo: nil, repeats: true)
                        }
                        Debug.print(String(format: "[FIRMWARE] try Connect: name: %@, ssi: %d", item.peripheral?.name ?? "Unknown", item.ssi ?? 0), event: .warning)
                        _isFound = true
                        item.m_isFind = true
                        centralManager!.delegate = self
                        centralManager!.connect(item.peripheral!)
                        m_connectingPeripheral = item.peripheral!
                        
                        return
                    }
                }
                if (!_isFound) {
                    _ = PopupManager.instance.onlyContents(contentsKey: "dfu_update_failed", confirmType: .ok, okHandler: { () -> () in
                        self.sceneMoveToBack()
                    })
                }
            } else {
                _ = PopupManager.instance.onlyContents(contentsKey: "dfu_update_failed", confirmType: .ok, okHandler: { () -> () in
                    self.sceneMoveToBack()
                })
            }
        }
    }
    
    @objc func updateConnecting() {
        Debug.print("[FIRMWARE] connecting..", event: .warning)
        if (UIManager.instance.rootCurrentView as? DeviceSetupSensorFirmwareUpdateViewController == nil) {
            initValues()
            return
        }
        
        m_updateTime += Config.SENSOR_FIRMWARE_SCAN_INTERVAL
        if (3 <= m_updateTime && m_updateTime <= 5) {
            centralManager?.cancelPeripheralConnection(m_connectingPeripheral!)
        } else if (m_updateTime > 5) {
            initValues()
            connectForScanList()
        }
    }
    
    func initValues() {
        Debug.print("[FIRMWARE] initValues", event: .warning)
        m_updateTimer?.invalidate()
    }
    
    //MARK: - CBCentralManagerDelegate
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        Debug.print("[FIRMWARE] CM did update state: \(central.state.rawValue)", event: .warning)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        let name = peripheral.name ?? "Unknown"
        Debug.print("[FIRMWARE] Connected to peripheral: \(name)", event: .warning)
        if (!(name.uppercased().contains("MONIT_BL"))) {
            Debug.print("[FIRMWARE] fail, return peripheral: \(name)", event: .warning)
            return
        }
        
        initValues()
        dfuPeripheral = peripheral
        peripheral.delegate = self
        peripheral.discoverServices(nil)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        let name = peripheral.name ?? "Unknown"
        Debug.print("[FIRMWARE] Disconnected from peripheral: \(name)", event: .warning)
        
        if (name.uppercased().contains("MONIT_BL")) {
            Debug.print("[FIRMWARE] found peripheral name: \(name)", event: .warning)
            dfuPeripheral = peripheral
            return
        }
    }
    
    //MARK: - CBPeripheralDelegate
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        // Find DFU Service
        let services = peripheral.services!
        for service in services {
            if service.uuid.isEqual(DeviceSetupSensorFirmwareViewController.legacyDfuServiceUUID) {
                secureDFU = false
                break
            } else if service.uuid.isEqual(DeviceSetupSensorFirmwareViewController.secureDfuServiceUUID) {
                secureDFU = true
                break
            } else if service.uuid.isEqual(DeviceSetupSensorFirmwareViewController.ExperimentalButtonlessDfuUUID) {
                secureDFU = true
                break
            }
        }
        if secureDFU != nil {
            selectedFileURL  = getBundledFirmwareURLHelper()
            selectedFirmware = DFUFirmware(urlToZipFile: selectedFileURL!)
            startDFUProcess()
        } else {
            Debug.print("[FIRMWARE] Disconnecting...", event: .warning)
            centralManager?.cancelPeripheralConnection(peripheral)
            dfuError(DFUError.deviceNotSupported, didOccurWithMessage: "Device not supported")
        }
    }
    
    //MARK: - DFUServiceDelegate
    
    func dfuStateDidChange(to state: DFUState) {
        switch state {
        case .completed:
            self.dfuActivityIndicator.stopAnimating()
//            self.dfuUploadProgressView.setProgress(0, animated: true)
            self.lblPercent.text = "(0%)"
            self.stopProcessButton.isEnabled = false
            _ = PopupManager.instance.onlyContents(contentsKey: "dfu_update_completed", confirmType: .ok, okHandler: { () -> () in
                Debug.print("[FIRMWARE] completed firmware update", event: .warning)
                _ = UIManager.instance.sceneMove(scene: .initView, animation: .coverVertical, isAnimation: false)
            })
        case .disconnecting:
            self.dfuActivityIndicator.stopAnimating()
//            self.dfuUploadProgressView.setProgress(0, animated: true)
            self.lblPercent.text = "(0%)"
            self.stopProcessButton.isEnabled = false
        case .aborted:
            self.dfuActivityIndicator.stopAnimating()
//            self.dfuUploadProgressView.setProgress(0, animated: true)
            self.lblPercent.text = "(0%)"
            
            if (isForceUpdate) {
                self.stopProcessButton.setTitle("dfu_status_uploading".localized, for: .normal)
                self.stopProcessButton.isEnabled = false
            } else {
                self.stopProcessButton.setTitle("btn_try_again".localized, for: .normal)
                self.stopProcessButton.isEnabled = true
            }
        default:
            if (isForceUpdate) {
                self.stopProcessButton.setTitle("dfu_status_uploading".localized, for: .normal)
                self.stopProcessButton.isEnabled = false
            } else {
                self.stopProcessButton.isEnabled = true
            }
        }
        
        dfuController?.setBleName(bleName: self.dfuPeripheral?.name ?? "")
        Debug.print("[FIRMWARE] Changed state to: \(state.description)", event: .warning)
        
        dfuStatusLabel.text = m_isPackageUpdate ? "Sensor \(state.description)" : state.description
        
        // Forget the controller when DFU is done
        if state == .completed {
            dfuController = nil
        }
    }
    
    func dfuError(_ error: DFUError, didOccurWithMessage message: String) {
        dfuStatusLabel.text = "Error \(error.rawValue): \(message)"
        dfuActivityIndicator.stopAnimating()
//        dfuUploadProgressView.setProgress(0, animated: true)
        lblPercent.text = "(0%)"
        Debug.print("[Error] \(error.rawValue): \(message)", event: .error)
        
        // Forget the controller when DFU finished with an error
        dfuController = nil
        
        _ = PopupManager.instance.onlyContents(contentsKey: "dfu_update_failed", confirmType: .ok, okHandler: { () -> () in
            self.sceneMoveToBack()
        })
        return
    }
    
    //MARK: - DFUProgressDelegate
    
    func dfuProgressDidChange(for part: Int, outOf totalParts: Int, to progress: Int, currentSpeedBytesPerSecond: Double, avgSpeedBytesPerSecond: Double) {
//        dfuUploadProgressView.setProgress(Float(progress)/100.0, animated: true)
            lblPercent.text = "(\(Int((Float(progress)/100.0) * 100))%)"
        //        dfuUploadStatus.text = String(format: "Part: %d/%d\nSpeed: %.1f KB/s\nAverage Speed: %.1f KB/s", part, totalParts, currentSpeedBytesPerSecond/1024, avgSpeedBytesPerSecond/1024)
    }
    
    //MARK: - LoggerDelegate
    
    func logWith(_ level: LogLevel, message: String) {
        Debug.print("[FIRMWARE] \(level.name()): \(message)", event: .warning)
    }
    
    @IBAction func onClick_back(_ sender: UIButton) {
        _ = PopupManager.instance.onlyContents(contentsKey: "dialog_dfu_stay_this_screen", confirmType: .cancleOK, okHandler: { () -> () in
            Debug.print("[FIRMWARE] button action back", event: .warning)
            _ = self.dfuController?.abort()
            self.sceneMoveToBack()
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

