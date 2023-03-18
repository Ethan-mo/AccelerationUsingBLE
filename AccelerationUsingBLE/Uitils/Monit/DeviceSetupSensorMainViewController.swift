//
//  DeviceSetupSensorMainViewController.swift
//  Monit
//
//  Created by 맥 on 2017. 9. 28..
//  Copyright © 2017년 맥. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class DeviceSetupSensorMainViewController: BaseViewController {
    @IBOutlet weak var lblNaviTitle: UILabel!

    @IBOutlet weak var lblBabyName: UILabel!
    @IBOutlet weak var imgBabyRightArrow: UIImageView!
    @IBOutlet weak var btnName: UIButton!
    @IBOutlet weak var lblBabyDescription: UILabel!
    
    /// notification not used
    @IBOutlet weak var viewAlarmOffInfo: UIView!
    @IBOutlet weak var btnAlarmOffInfo: UIButton!
    @IBOutlet weak var lblAlarmOffStatus: UILabel!
    @IBOutlet weak var lblAlarmOffSummary: UILabel!
    
    @IBOutlet weak var viewAlarmInfo: UIView!
    // all alarm
    @IBOutlet weak var lblAlarmMaster: UILabel!
    @IBOutlet weak var swAlarmMaster: UISwitch!
    // peePoo alarm
    @IBOutlet weak var viewAlarmPeePoo: UIView!
    @IBOutlet weak var lblAlarmPeePoo: UILabel!
    @IBOutlet weak var swAlarmPeePoo: UISwitch!
    @IBOutlet weak var lblAlarmPeePooDescription: UILabel!
    // disconn alarm
    @IBOutlet weak var viewAlarmDisconn: UIView!
    @IBOutlet weak var lblAlarmDisconn: UILabel!
    @IBOutlet weak var swAlarmDisconn: UISwitch!
    @IBOutlet weak var lblAlarmDisconnDescription: UILabel!
    // fart alarm
    @IBOutlet weak var viewAlarmFart: UIView!
    @IBOutlet weak var lblAlarmFart: UILabel!
    @IBOutlet weak var swAlarmFart: UISwitch!
    // diaper score alarm
    @IBOutlet weak var viewAlarmDiaperScore: UIView!
    @IBOutlet weak var lblAlarmDiaperScore: UILabel!
    @IBOutlet weak var swAlarmDiaperSore: UISwitch!
    @IBOutlet weak var lblAlarmDiaperScoreDescription: UILabel!
    // move detected alarm
    @IBOutlet weak var viewAlarmMoveDetected: UIView!
    @IBOutlet weak var lblAlarmMoveDetected: UILabel!
    @IBOutlet weak var swAlarmMoveDetected: UISwitch!
    @IBOutlet weak var lblAlarmMovDetectedDescription: UILabel!
    // auto move detected alarm
    @IBOutlet weak var viewAlarmAutoMoveDetected: UIView!
    @IBOutlet weak var lblAlarmAutoMoveDetected: UILabel!
    @IBOutlet weak var swAlarmAutoMoveDetected: UISwitch!
    
    @IBOutlet weak var constAlarm: NSLayoutConstraint!
    @IBOutlet weak var viewSubAlarm: UIView!
    
    @IBOutlet weak var viewAlarmLine: UIView!
    @IBOutlet var conAlarmOff: NSLayoutConstraint!
    @IBOutlet var conAlarmInfo: NSLayoutConstraint!

    @IBOutlet weak var viewDemoBottomLine: UIView!
    @IBOutlet weak var viewFakePee: UIView!
    @IBOutlet weak var btnFakePee: UIButton!
    @IBOutlet weak var imgFakePee: UIImageView!
    @IBOutlet weak var viewFakePoo: UIView!
    @IBOutlet weak var btnFakePoo: UIButton!
    @IBOutlet weak var imgFakePoo: UIImageView!
    
    @IBOutlet weak var lblFirmware: UILabel!
    @IBOutlet weak var imgFirmwareRightArrow: UIImageView!
    @IBOutlet weak var btnFirmware: UIButton!
    @IBOutlet weak var imgFirmwareNewAlarm: UIImageView!
    @IBOutlet weak var lblFirmwareDescription: UILabel!
    
    @IBOutlet weak var viewDeviceLeave: UIView!
    @IBOutlet weak var viewDeviceLeaveLine: UIView!
    @IBOutlet weak var btnDeviceLeave: UIButton!
    
    @IBOutlet weak var viewDeviceInit: UIView!
    @IBOutlet weak var viewDeviceInitLine: UIView!
    @IBOutlet weak var btnDeviceInit: UIButton!
   
    @IBOutlet weak var viewSensitive: UIView!
    @IBOutlet weak var btnSensitive: UIButton!
    @IBOutlet weak var lblSensitiveValue: UILabel!
    @IBOutlet weak var imgSensitiveRightArrow: UIImageView!
    
    @IBOutlet weak var imgFindDeviceArrow: UIImageView!
    @IBOutlet weak var btnFindDevice: UIButton!
    
    @IBOutlet weak var viewDemo: UIView!
    @IBOutlet weak var btnDemo: UIButton!
    @IBOutlet weak var imgDemoRightArrow: UIImageView!

    @IBOutlet weak var viewTesterFileSend: UIView!
    
    @IBOutlet weak var btnSerialTitle: UIButton!
    @IBOutlet weak var lblSeiral: UILabel!

    enum FIRMWARE_UPDATE_TYPE {
        case firmwarePage
        case needConnectingPage
    }
    
    override var screenType: SCREEN_TYPE { get { return .SENSOR_SETUP_INFO } }
    var m_detailInfo: DeviceDetailInfo?
    var m_originFirmwareXPos: CGFloat = 0
    let m_arrSensitivity: [Int] = [11, 55, 99]
    var m_updateTimer: Timer?

    var isBeta: Bool {
        get {
             if (DataManager.instance.m_userInfo.configData.isBeta) {
                return true
            }
            return false
        }
    }
    
    var isHuggiesV1Alarm: Bool {
        get {
             if (DataManager.instance.m_userInfo.configData.isHuggiesV1Alarm) {
                return true
            }
            return false
        }
    }
    
    var sensorStatusInfo: SensorStatusInfo? {
        get {
            return DataManager.instance.m_userInfo.deviceStatus.m_sensorStatus.getInfoByDeviceId(did: m_detailInfo!.m_did)            
        }
    }
    
    // wifi and ble
    var isConnect: Bool {
        get {
            return DataManager.instance.m_dataController.device.m_sensor.isSensorConnect(type: m_detailInfo!.m_deviceType, did: m_detailInfo!.m_did)
        }
    }
    
    var userInfo: UserInfoDevice? {
        get {
            return DataManager.instance.m_dataController.device.getUserInfoByDid(did: m_detailInfo!.m_did, type: DEVICE_TYPE.Sensor.rawValue)
        }
    }
    
    var connectSensor: BleInfo? {
        get {
            return DataManager.instance.m_userInfo.connectSensor.getSensorByDeviceId(deviceId: m_detailInfo!.m_did)
        }
    }
    
    var isAvailableFirmware: Bool {
        get {
            return Utility.isAvailableVersion(availableVersion: Config.SENSOR_FIRMWARE_LIMIT_UPDATE_VERSION, currentVersion: firmwareVer)
        }
    }
    
    var isAvailableSensitiveFirmware: Bool {
        get {
            // return Utility.isAvailableVersion(availableVersion: Config.SENSOR_FIRMWARE_LIMIT_SENSITIVE_VERSION, currentVersion: firmwareVer)
            return DataManager.instance.m_userInfo.configData.isMaster
        }
    }
    
    var firmwareVer: String {
        get {
            return userInfo?.fwv ?? "0.0.0"
        }
    }
    
    var isNeedUpdate: Bool {
        get {
            let _latestVersion = DataManager.instance.m_configData.m_latestSensorVersion
            let _currentVersion = firmwareVer
            
            if Utility.isUpdateVersion(latestVersion: _latestVersion, currentVersion: _currentVersion) {
                return true
            }
            return false
        }
    }
    
    var nextSensitivity: Int {
        get {
            if let _sens = sensorStatusInfo?.m_sens {
                for (i, item) in m_arrSensitivity.enumerated() {
                    if (item == _sens) {
                        if (m_arrSensitivity.count - 1 > i) {
                            return m_arrSensitivity[i + 1]
                        }
                    }
                }
                return m_arrSensitivity[0]
            } else {
                return -1
            }
        }
    }
   
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUI()
    }
    
    override func reloadInfo() {
        super.reloadInfo()
        Debug.print("[UI][\(self.classNameToString()).reloadInfo()]")
        setUI()
    }
    
    func setUI() {
        setNotiUI()

        // set enable ui
//        let _isMaster = m_detailInfo!.m_deviceType == .myDevice
        let _txtAvailableFirmware = "\(String(format: "%@", userInfo?.fwv ?? "")) / \(DataManager.instance.m_configData.m_latestSensorVersion)"
        lblFirmware.text = isAvailableFirmware ? _txtAvailableFirmware : String(format: "%@", userInfo?.fwv ?? "")
        if (m_originFirmwareXPos == 0) {
            m_originFirmwareXPos = lblFirmware.bounds.origin.x
        }

        let _isDebug = DataManager.instance.m_userInfo.configData.isMaster
        
        UIManager.instance.setContensEnable(isOn: isConnect, orginPosX: 0, btnTitle: btnName, lblValue: lblBabyName, imgArrow: imgBabyRightArrow, lblDescription: lblBabyDescription)
        UIManager.instance.setContensEnable(isOn: isConnect, orginPosX: 0, btnTitle: btnSensitive, lblValue: lblSensitiveValue, imgArrow: imgSensitiveRightArrow)
        UIManager.instance.setContentEnableSw(isOn: isConnect, lblTitle: lblAlarmMaster, sw: swAlarmMaster)
        UIManager.instance.setContentEnableSw(isOn: isConnect, lblTitle: lblAlarmPeePoo, sw: swAlarmPeePoo, lblDescription: lblAlarmPeePooDescription)
        UIManager.instance.setContentEnableSw(isOn: isConnect, lblTitle: lblAlarmFart, sw: swAlarmFart)
        UIManager.instance.setContentEnableSw(isOn: isConnect, lblTitle: lblAlarmDisconn, sw: swAlarmDisconn, lblDescription: lblAlarmDisconnDescription)
        UIManager.instance.setContentEnableSw(isOn: isConnect, lblTitle: lblAlarmDiaperScore, sw: swAlarmDiaperSore, lblDescription: lblAlarmDiaperScoreDescription)
        UIManager.instance.setContentEnableSw(isOn: isConnect, lblTitle: lblAlarmMoveDetected, sw: swAlarmMoveDetected, lblDescription: lblAlarmMovDetectedDescription)
        UIManager.instance.setContentEnableSw(isOn: isConnect, lblTitle: lblAlarmAutoMoveDetected, sw: swAlarmAutoMoveDetected)
        UIManager.instance.setContensEnable(isOn: isConnect, orginPosX: 0, btnTitle: btnFindDevice, lblValue: nil, imgArrow: imgFindDeviceArrow) // find device
        UIManager.instance.setContensEnable(isOn: isConnect, orginPosX: 0, btnTitle: btnDemo, lblValue: nil, imgArrow: imgDemoRightArrow) // demo
        UIManager.instance.setContensEnable(isOn: isConnect, orginPosX: 0, btnTitle: btnSerialTitle, lblValue: lblSeiral, imgArrow: nil) // serialNumber
        UIManager.instance.setContentEnableForConnect(isOn: (isConnect && isAvailableFirmware) || (isConnect && _isDebug), isMaster: true, orginPosX: m_originFirmwareXPos, btnTitle: btnFirmware, lblValue: lblFirmware, imgArrow: imgFirmwareRightArrow, lblDescription: lblFirmwareDescription)
        if (!isAvailableSensitiveFirmware) {
            viewSensitive.isHidden = true
        }
//        if (!(DataManager.instance.m_userInfo.configData.isDebug)) {
//            viewSensitive.isHidden = true
//        }
        if (!isAvailableFirmware) {
            imgFirmwareRightArrow.isHidden = true
        }
        
        setMasterPage(deviceType: m_detailInfo!.m_deviceType)

        lblBabyName.text = sensorStatusInfo?.m_name ?? ""
        
        btnSensitive.setTitle("sensitivity_title".localized, for: .normal)
        btnFindDevice.setTitle("setting_device_find".localized, for: .normal)
        btnDemo.setTitle("setting_device_detection_test_mode_title".localized, for: .normal)
        lblNaviTitle.text = "title_setting".localized
        btnName.setTitle("setting_device_babyinfo".localized, for: .normal)
        btnAlarmOffInfo.setTitle("setting_device_enable_alarm".localized, for: .normal)
        lblAlarmOffSummary.text = "deviceSetupAlarmOffSummary".localized
        lblAlarmMaster.text = "setting_device_enable_alarm".localized
        lblAlarmPeePoo.text = "setting_device_enable_diaper_soiled_alarm".localized
        lblAlarmFart.text = "device_sensor_diaper_status_fart".localized
        lblAlarmDiaperScore.text = "setting_device_enable_diaper_check_alarm".localized
        lblAlarmDisconn.text = "setting_device_enable_connection_alarm".localized
        lblAlarmMoveDetected.text = "device_sensor_movement_during_sleep".localized
        lblAlarmAutoMoveDetected.text = "setting_device_enable_auto_sleep_monitoring".localized
        btnFirmware.setTitle("setting_device_firmware_version".localized, for: .normal)
        
        lblBabyDescription.text = "connection_monit_sensor_babyinfo_detail".localized
        lblAlarmPeePooDescription.text = "setting_device_enable_diaper_soiled_alarm_description".localized
        lblAlarmDiaperScoreDescription.text = "setting_device_enable_diaper_check_alarm_description".localized
        lblAlarmDisconnDescription.text = "setting_device_enable_connection_alarm_description".localized
        lblAlarmMovDetectedDescription.text = "setting_device_sensor_movement_during_sleep_description".localized
        lblFirmwareDescription.text = "setting_device_firmware_version_description".localized
        
        btnSerialTitle.setTitleWithOutAnimation(title: "setting_device_serial_number".localized)
        lblSeiral.text = userInfo?.srl ?? ""
        
        // for tester
//        viewTesterFileSend.isHidden = !isBeta
        
        viewDemoBottomLine.isHidden = false
        viewFakePee.isHidden = true
        viewFakePoo.isHidden = true
        
        if (DataManager.instance.m_userInfo.configData.isDevelop || DataManager.instance.m_userInfo.configData.isExternalDeveloper) {
            viewDemoBottomLine.isHidden = true
            viewFakePee.isHidden = false
            viewFakePoo.isHidden = false
            UIManager.instance.setContensEnable(isOn: isConnect, orginPosX: 0, btnTitle: btnFakePee, lblValue: nil, imgArrow: imgFakePee)
            UIManager.instance.setContensEnable(isOn: isConnect, orginPosX: 0, btnTitle: btnFakePoo, lblValue: nil, imgArrow: imgFakePoo)
        }

        imgFirmwareNewAlarm.isHidden = true
        if (DataManager.instance.m_dataController.newAlarm.sensorFirmware.isNewAlarmDetailSetupFirmware(did: m_detailInfo!.m_did)) {
            imgFirmwareNewAlarm.isHidden = false
        }
        
        if (isAvailableSensitiveFirmware && connectSensor != nil) {
            connectSensor?.controller?.m_packetRequest?.getSensitive(completion: {
                (value) in
                var _isFlash = false
                if var _value = value as? Int {
                    switch (_value) {
                    case 1: _value = 11
                        _isFlash = true
                        break
                    case 5: _value = 55
                        _isFlash = true
                        break
                    case 9: _value = 99
                        _isFlash = true
                        break
                    case 11: break
                    case 55: break
                    case 99: break
                    default:
                        _value = 55
                        _isFlash = true
                        break
                    }
                    
                    if (_isFlash) {
                        self.connectSensor?.controller?.m_packetCommend?.setSensitivity(value: _value)
                    }

                    self.setSensitivity(value: _value)
                    self.sendSensitive(nextSensitivity: _value, handler: nil)
                }
            })
        } else {
            self.setSensitivity(value: sensorStatusInfo?.m_sens ?? -1)
        }
        
        if (Config.channel != .kc) {
            viewAlarmPeePoo.isHidden = false
            viewAlarmFart.isHidden = true
            viewAlarmDisconn.isHidden = false
            viewAlarmDiaperScore.isHidden = false
            viewAlarmMoveDetected.isHidden = false
        } else {
            viewAlarmPeePoo.isHidden = false
            viewAlarmFart.isHidden = false
            viewAlarmDisconn.isHidden = false
            viewAlarmDiaperScore.isHidden = true
        }
        
        if (isBeta) {
            viewAlarmFart.isHidden = false
            viewAlarmDisconn.isHidden = false
            viewAlarmDiaperScore.isHidden = false
            viewAlarmMoveDetected.isHidden = false
        }
        
        self.m_updateTimer?.invalidate()
        self.m_updateTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
        
        self.view.layoutIfNeeded()
        
        gotoScene()
    }
    
    func gotoScene() {
        if (UIManager.instance.m_finishScenePush == .deviceSetupSensorFirmware) {
            UIManager.instance.m_finishScenePush = nil
            moveFirmware(isForceInit: true)
        }
    }
    
    func setSensitivity(value: Int) {
        sensorStatusInfo?.m_sens = value
        
        switch value {
        case 11: self.lblSensitiveValue.text = "sensitivity_low".localized
        case 55: self.lblSensitiveValue.text = "sensitivity_normal".localized
        case 99: self.lblSensitiveValue.text = "sensitivity_high".localized
        default: self.lblSensitiveValue.text = "sensitivity_normal".localized
        }
    }

    func setNotiUI() {
        if (UIManager.instance.isNotificationAuth) {
            if let _almStatus = isAlarmStatus(almType: .all) {
                setSwAlarmMasterOn(isOn: _almStatus, isAnimation: false)
            }
            if let _almStatus = isAlarmStatus(almType: .pee) {
                setSwAlarmPeePooOn(isOn: _almStatus)
            }
            if let _almStatus = isAlarmStatus(almType: .fart) {
                setSwAlarmFartOn(isOn: _almStatus)
            }
            if let _almStatus = isAlarmStatus(almType: .sensor_long_disconnected) {
                setSwAlarmDisconn(isOn: _almStatus)
            }
            if let _almStatus = isAlarmStatus(almType: .diaper_score) {
                setSwAlarmDiaperScore(isOn: _almStatus)
            }
            if let _almStatus = isAlarmStatus(almType: .move_detected) {
                setSwAlarmMoveDetected(isOn: _almStatus)
            }
            if let _almStatus = isAlarmStatus(almType: .auto_move_detected) {
                setSwAlarmAutoMoveDetected(isOn: _almStatus)
            }
            viewAlarmOffInfo.isHidden = true
            viewAlarmInfo.isHidden = false
            conAlarmOff.isActive = false
            conAlarmInfo.isActive = true
        } else {
            viewAlarmOffInfo.isHidden = false
            viewAlarmInfo.isHidden = true
            conAlarmOff.isActive = true
            conAlarmInfo.isActive = false
        }
    }
    
    func setMasterPage(deviceType: DEVICE_LIST_TYPE) {
        btnDeviceLeave.setTitle("setting_device_remove".localized, for: .normal)
        btnDeviceInit.setTitle("setting_device_initialize".localized, for: .normal)
        
        viewDeviceLeaveLine.isHidden = true
        viewDeviceLeave.isHidden = true
        viewDeviceInitLine.isHidden = true
        viewDeviceInit.isHidden = true
        
        switch deviceType {
        case .myDevice:
            viewDeviceInitLine.isHidden = false
            viewDeviceInit.isHidden = false
        case .otherDevice:
            if (connectSensor != nil) {
                viewDeviceLeaveLine.isHidden = false
                viewDeviceLeave.isHidden = false
                viewDeviceInitLine.isHidden = false
                viewDeviceInit.isHidden = false
            } else {
                viewDeviceLeaveLine.isHidden = false
                viewDeviceLeave.isHidden = false
            }
        default: break
        }
    }

    func setSwAlarmMasterOn(isOn: Bool, isAnimation: Bool) {
        let _height: CGFloat = (Config.channel != .kc) ? 372 : 420

        if (isAnimation) {
            UIView.animate(withDuration: 0.2, animations: {
                self.constAlarm?.constant = (isOn ? _height : 48)
                self.view!.layoutIfNeeded()
            })
        } else {
            self.constAlarm?.constant = (isOn ? _height : 48)
            self.view!.layoutIfNeeded()
        }
        viewSubAlarm.isHidden = !isOn
        swAlarmMaster.setOn(isOn, animated: false)
    }
    
    func setSwAlarmPeePooOn(isOn: Bool) {
        swAlarmPeePoo.setOn(isOn, animated: false)
    }
    
    func setSwAlarmFartOn(isOn: Bool) {
        swAlarmFart.setOn(isOn, animated: false)
    }
    
    func setSwAlarmDisconn(isOn: Bool) {
        swAlarmDisconn.setOn(isOn, animated: false)
    }
    
    func setSwAlarmDiaperScore(isOn: Bool) {
        swAlarmDiaperSore.setOn(isOn, animated: false)
    }
    
    func setSwAlarmMoveDetected(isOn: Bool) {
        swAlarmMoveDetected.setOn(isOn, animated: false)
    }
    
    func setSwAlarmAutoMoveDetected(isOn: Bool) {
        swAlarmAutoMoveDetected.setOn(isOn, animated: false)
    }
    
    func isAlarmStatus(almType: ALRAM_TYPE) -> Bool? {
        return DataManager.instance.m_userInfo.shareDevice.isAlarmStatusSpecific(did: m_detailInfo!.m_did, type: DEVICE_TYPE.Sensor.rawValue, almType: almType)
    }
    
    func setSwAlarmInfoChange(isOn: Bool, almType: ALRAM_TYPE) {
        DataManager.instance.m_dataController.userInfo.shareDevice.changeAlarm(did: m_detailInfo!.m_did, type: DEVICE_TYPE.Sensor.rawValue, almType: almType, isOn: isOn)
    }
    
    func setSwAlarmInfoChangeCommon(isOn: Bool, almType: ALRAM_TYPE) {
        DataManager.instance.m_dataController.userInfo.shareDevice.changeAlarmCommon(did: m_detailInfo!.m_did, type: DEVICE_TYPE.Sensor.rawValue, almType: almType, isOn: isOn)
    }
    
    @IBAction func editingChange_alram(_ sender: UISwitch) {
        setSwAlarmMasterOn(isOn: sender.isOn, isAnimation: true)
        setSwAlarmInfoChange(isOn: sender.isOn, almType: .all)

        ScreenAnalyticsManager.instance.googleTagManagerCustom(type: .sensor_setting_alarm_enabled, items: ["sensorid_\(m_detailInfo!.m_did)" : "\(sender.isOn ? "true" : "false")"])
    }

    @IBAction func editingChange_alarm_peePoo(_ sender: UISwitch) {
        setSwAlarmPeePooOn(isOn: sender.isOn)
        setSwAlarmInfoChange(isOn: sender.isOn, almType: .pee)
        setSwAlarmInfoChange(isOn: sender.isOn, almType: .poo)
        
        ScreenAnalyticsManager.instance.googleTagManagerCustom(type: .sensor_setting_pee_alarm_enabled, items: ["sensorid_\(m_detailInfo!.m_did)" : "\(sender.isOn ? "true" : "false")"])
        ScreenAnalyticsManager.instance.googleTagManagerCustom(type: .sensor_setting_poo_alarm_enabled, items: ["sensorid_\(m_detailInfo!.m_did)" : "\(sender.isOn ? "true" : "false")"])
    }
    
    @IBAction func editingChange_alarm_fart(_ sender: UISwitch) {
        setSwAlarmFartOn(isOn: sender.isOn)
        setSwAlarmInfoChange(isOn: sender.isOn, almType: .fart)
        
        ScreenAnalyticsManager.instance.googleTagManagerCustom(type: .sensor_setting_fart_alarm_enabled, items: ["sensorid_\(m_detailInfo!.m_did)" : "\(sender.isOn ? "true" : "false")"])
    }
    
    @IBAction func editingChange_alarm_disconn(_ sender: UISwitch) {
        setSwAlarmDisconn(isOn: sender.isOn)
        setSwAlarmInfoChange(isOn: sender.isOn, almType: .sensor_long_disconnected)
        
        ScreenAnalyticsManager.instance.googleTagManagerCustom(type: .sensor_setting_connection_alarm_enabled, items: ["sensorid_\(m_detailInfo!.m_did)" : "\(sender.isOn ? "true" : "false")"])
    }
    
    @IBAction func editingChange_alarm_diaperScore(_ sender: UISwitch) {
        setSwAlarmDiaperScore(isOn: sender.isOn)
        setSwAlarmInfoChange(isOn: sender.isOn, almType: .diaper_score)
    }
    
    @IBAction func editingChange_alarm_moveDetected(_ sender: UISwitch) {
        setSwAlarmMoveDetected(isOn: sender.isOn)
        setSwAlarmInfoChange(isOn: sender.isOn, almType: .move_detected)
    }
    
    @IBAction func editingChange_alarm_autoMoveDetected(_ sender: UISwitch) {
        setSwAlarmAutoMoveDetected(isOn: sender.isOn)
        setSwAlarmInfoChangeCommon(isOn: sender.isOn, almType: .auto_move_detected)
    }
    
    @IBAction func onClick_babyInfo(_ sender: UIButton) {
//        if (m_detailInfo!.m_deviceType == .myDevice) {
            if let _scene = UIManager.instance.sceneMoveNaviPush(scene: .deviceSetupBabyInfoMaster) as? DeviceSetupBabyMasterInfo {
                _scene.m_detailInfo = m_detailInfo
            }
//        } else {
//            if let _scene = UIManager.instance.sceneMoveNaviPush(scene: .deviceSetupBabyInfo) as? DeviceSetupBabyInfoViewController {
//                _scene.m_detailInfo = m_detailInfo
//            }
//        }
    }
    
    @IBAction func onClick_firmware(_ sender: UIButton) {
        Debug.print("[SensorSetup] onClick_firmware()", event: .warning)
        moveFirmware()
    }
    
    func moveFirmware(isForceInit: Bool = false) {
        if (!isConnect) {
            return
        }
        
        if Utility.isAvailableVersion(availableVersion: Config.SENSOR_FIRMWARE_LIMIT_UPDATE_VERSION, currentVersion: firmwareVer) {
            if (connectSensor == nil) {
                setFirmwarePage(type: .needConnectingPage, isForceInit: isForceInit)
            } else {
                setFirmwarePage(type: .firmwarePage, isForceInit: isForceInit)
            }
        } else {
            Debug.print("[SensorSetup] not available sensor version", event: .warning)
        }
    }
    
    func setFirmwarePage(type: FIRMWARE_UPDATE_TYPE, isForceInit: Bool = false) {
        switch type {
        case .firmwarePage:
            let _scene = UIManager.instance.sceneMoveNaviPush(scene: .deviceSetupSensorFirmware) as? DeviceSetupSensorFirmwareViewController
            _scene?.m_isForceInit = isForceInit
            _scene?.setInit(detailInfo: m_detailInfo)
        case .needConnectingPage:
            let _scene = UIManager.instance.sceneMoveNaviPush(scene: .deviceSetupSensorConnecting) as? DeviceSetupSensorConnectingViewController
            _scene?.m_isForceInit = isForceInit
            _scene?.setInit(detailInfo: m_detailInfo, connectType: .firmware)
        }
    }
    
    @IBAction func onClick_deviceLeave(_ sender: UIButton) {
        Debug.print("[SensorSetup] onClick_deviceLeave()")
        _ = PopupManager.instance.onlyContents(contentsKey: "dialog_contents_remove_device", confirmType: .cancleOK, okHandler: { () -> () in
            self.confirmDeviceLeave()
        })
    }
    
    @IBAction func onClick_deviceInit(_ sender: UIButton) {
         Debug.print("[SensorSetup] onClick_deviceInit()")
        _ = PopupManager.instance.onlyContents(contentsKey: "dialog_contents_initialize_device", confirmType: .cancleOK, okHandler: { () -> () in
            self.confirmDeviceInit()
        })
    }
    
    func confirmDeviceLeave() {
        DataManager.instance.m_dataController.deviceStatus.sensorLeave(cid: m_detailInfo!.m_cid, did: m_detailInfo!.m_did, adv: userInfo!.adv)
    }
    
    func confirmDeviceInit() {
        DataManager.instance.m_dataController.deviceStatus.sensorInit(did: m_detailInfo!.m_did, enc: userInfo!.enc, adv: userInfo!.adv)
    }
    
    @IBAction func onClick_back(_ sender: UIButton) {
        UIManager.instance.sceneMoveNaviPop()
    }
    
    @IBAction func onClick_setting(_ sender: UIButton) {
        _ = Utility.urlOpen(UIApplicationOpenSettingsURLString)
    }
    
    @IBAction func onClick_sensitive(_ sender: Any) {
        Debug.print("[SensorSetup] onClick_sensitive()")
        if (nextSensitivity == -1) {
            return
        }
        
        if (isAvailableSensitiveFirmware && connectSensor != nil) {
            sendSensitive(nextSensitivity: self.nextSensitivity, handler: { () -> () in
                self.connectSensor?.controller?.m_packetCommend?.setSensitivity(value: self.nextSensitivity)
                self.setSensitivity(value: self.nextSensitivity)
            })
        } else {
            let _scene = UIManager.instance.sceneMoveNaviPush(scene: .deviceSetupSensorConnecting) as? DeviceSetupSensorConnectingViewController
            _scene?.setInit(detailInfo: nil, connectType: .normal)
        }
    }
    
    func sendSensitive(nextSensitivity: Int, handler: Action?) {
        if (nextSensitivity == -1) {
            return
        }
        
        let send = Send_SetSensorSensitivity()
        send.aid = DataManager.instance.m_userInfo.account_id
        send.token = DataManager.instance.m_userInfo.token
        send.did = m_detailInfo!.m_did
        send.enc = userInfo!.enc
        send.sens = nextSensitivity
        NetworkManager.instance.Request(send) { (json) -> () in
            let receive = Receive_SetSensorSensitivity(json)
            switch receive.ecd {
            case .success:
                handler?()
            default:
                Debug.print("[ERROR] Receive_SetSensorSensitivity invaild errcod", event: .error)
            }
        }
    }

    var m_findDevicePopupView: PopupView?
    @IBAction func onClick_findDevice(_ sender: UIButton) {
        if (connectSensor == nil) {
            let _scene = UIManager.instance.sceneMoveNaviPush(scene: .deviceSetupSensorConnecting) as? DeviceSetupSensorConnectingViewController
            _scene?.setInit(detailInfo: nil, connectType: .normal)
            return
        }
        
        connectSensor?.controller?.m_packetCommend?.setLed()
        
        m_findDevicePopupView = PopupManager.instance.withLoading(contentsKey: "dialog_contents_finding_device", confirmType: .cancle)
        
        _ = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(closeFindDevicePopup), userInfo: nil, repeats: false)
    }
    
    @objc func closeFindDevicePopup() {
        m_findDevicePopupView?.removeFromSuperview()
    }
    
    var m_demoPopupView: PopupView?
    @IBAction func onClick_demo(_ sender: UIButton) {
        if (connectSensor == nil) {
            let _scene = UIManager.instance.sceneMoveNaviPush(scene: .deviceSetupSensorConnecting) as? DeviceSetupSensorConnectingViewController
            _scene?.setInit(detailInfo: nil, connectType: .normal)
            return
        }
        
        DataManager.instance.m_userInfo.configData.isCustomDemo = true
        
        m_demoPopupView = PopupManager.instance.withLoading(contentsKey: "setting_device_detection_test_mode_description", confirmType: .cancle, okHandler: { () -> () in
            self.closeDemoPopup()
        })
        
        _ = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(closeDemoPopup), userInfo: nil, repeats: false)
    }
    
    @objc func closeDemoPopup() {
        Debug.print("[SensorSetup] closeDemoPopup", event: .warning)
        DataManager.instance.m_userInfo.configData.isCustomDemo = false
        m_demoPopupView?.removeFromSuperview()
    }
    
    @objc func update() {
        if (UIManager.instance.rootCurrentView as? DeviceSetupSensorMainViewController == nil) {
            self.m_updateTimer?.invalidate()
            DataManager.instance.m_userInfo.configData.isCustomDemo = false
        }
    }
    
    @IBAction func onClick_fakePee(_ sender: UIButton) {
        DataManager.instance.m_dataController.device.m_sensor.updateStatus(did: m_detailInfo?.m_did ?? 0, dps: SENSOR_DIAPER_STATUS.pee.rawValue, mov: 0, opr: 0, timeStamp: Int64(Utility.timeStamp))
    }
    
    @IBAction func onClick_fakePoo(_ sender: UIButton) {
        DataManager.instance.m_dataController.device.m_sensor.updateStatus(did: m_detailInfo?.m_did ?? 0, dps: SENSOR_DIAPER_STATUS.poo.rawValue, mov: 0, opr: 0, timeStamp: Int64(Utility.timeStamp))
    }
}
