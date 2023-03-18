//
//  DeviceSetupLampFirmwareViewController.swift
//  Monit
//
//  Created by john.lee on 2018. 6. 7..
//  Copyright © 2018년 맥. All rights reserved.
//

import UIKit

class LampFirmwareUpdateInfo {
    var m_did: Int = 0
    var m_lampFirmwareState: HUB_TYPES_FIRMWARE_STATE = .none
    var m_lampFirmwareTime: Float = 0
    
    init (did: Int) {
        self.m_did = did
    }
}

class DeviceSetupLampFirmwareViewController: BaseViewController {
    @IBOutlet weak var lblNaviTitle: UILabel!
    @IBOutlet weak var lblCurrentVersion: UILabel!
    @IBOutlet weak var lblLatestVersion: UILabel!
    @IBOutlet weak var imgLampLatestVersionNewAlarm: UIImageView!
    @IBOutlet weak var lblSummary: UILabel!
    @IBOutlet weak var lblWarnning: UILabel!
    @IBOutlet weak var btnUpdate: UIButton!
    @IBOutlet weak var btnLastestVersion: UIButton!
    
    @IBOutlet weak var activityIndicatorUpdate: UIActivityIndicatorView!
    
    @IBOutlet weak var lblUpdateNoti: UILabel!
    @IBOutlet weak var progressUpdate: UIProgressView!
    @IBOutlet weak var lblPercent: UILabel!
    
    @IBOutlet weak var imgLogoDefault: UIImageView!
    @IBOutlet weak var imgLogoKC: UIImageView!
    
    @IBOutlet weak var btnBefore: UIButton!
    @IBOutlet weak var btnProduct: UIButton!
    @IBOutlet weak var btnTest: UIButton!
    @IBOutlet weak var btnKc: UIButton!

    let m_readyTime: Float = 10.0
    let m_updatingTime: Float = 300.0
    let m_timeInterval: Float = 0.1
    let m_getServerTime: Float = 10.0
    var m_detailInfo: DeviceDetailInfo?
    var m_sensorDetailInfo: DeviceDetailInfo?
    var m_updateTimer: Timer?
    var m_serverTime: Float = 0
    var m_isForceInit: Bool = false
    var m_isPackageUpdate: Bool = false
    var m_tmpSrl: String = "" // 기기 연결시에 userInfo가 null이다.
    var m_tmpFwv: String = "" // 기기 연결시에 userInfo가 null이다.

    var lampStatusInfo: LampStatusInfo? {
        get {
            return DataManager.instance.m_userInfo.deviceStatus.m_lampStatus.getInfoByDeviceId(did: m_detailInfo!.m_did)
        }
    }
    
    var isConnect: Bool {
        get {
            return DataManager.instance.m_dataController.device.m_lamp.isConnect(type: m_detailInfo!.m_deviceType, did: m_detailInfo!.m_did)
        }
    }
    
    var isWifiConnect: Bool {
        get {
            return DataManager.instance.m_dataController.device.m_lamp.isWifiConnect(type: m_detailInfo!.m_deviceType, did: m_detailInfo!.m_did)
        }
    }
    
    var userInfo: UserInfoDevice {
        get {
            if let _userInfo = DataManager.instance.m_dataController.device.getUserInfoByDid(did: m_detailInfo!.m_did, type: DEVICE_TYPE.Lamp.rawValue) {
                return _userInfo
            } else {
                return UserInfoDevice(cid: 0, did: m_detailInfo!.m_did, type: DEVICE_TYPE.Lamp.rawValue, name: "", srl: m_tmpSrl, fwv: m_tmpFwv, mac: "", alm: "", adv: "")
            }
        }
    }
    
    var isNeedUpdate: Bool {
        get {
            let _latestVersion = DataManager.instance.m_configData.m_latestLampVersion
            let _currentVersion = userInfo.fwv
            
            if Utility.isUpdateVersion(latestVersion: _latestVersion, currentVersion: _currentVersion) {
                return true
            }
            return false
        }
    }
    
    var updateInfo: LampFirmwareUpdateInfo {
        get {
            var _lstDel: [LampFirmwareUpdateInfo] = []
            for item in UIManager.instance.m_lampFirmwareUpdate {
                if (item.m_did == m_detailInfo!.m_did) {
                    if (item.m_lampFirmwareState != .finished) {
                        return item
                    } else {
                        _lstDel.append(item)
                    }
                }
            }
            
            for item in _lstDel {
                if let index = UIManager.instance.m_lampFirmwareUpdate.index(where: { $0 === item }) {
                    UIManager.instance.m_lampFirmwareUpdate.remove(at: index)
                }
            }
       
            let _info = LampFirmwareUpdateInfo(did: m_detailInfo!.m_did)
            UIManager.instance.m_lampFirmwareUpdate.append(_info)
            return _info
        }
    }
    
    override func viewDidLoad() {
        isUpdateView = false
        super.viewDidLoad()
        Debug.print("[UI][\(self.classNameToString()).viewDidLoad()]")
        setLogoUI()
        setUI()
    }
    
    func setInit(detailInfo: DeviceDetailInfo?) {
        Debug.print("[LAMP_FIRMWARE] setInit()", event: .warning)
        m_detailInfo = detailInfo
    }
    
    func setUI() {
        Debug.print("[LAMP_FIRMWARE] setUI()", event: .warning)
        lblNaviTitle.text = "title_firmware_update".localized
        lblCurrentVersion.text = String(format: "%@ %@", "current_version".localized, userInfo.fwv)
        lblLatestVersion.text = String(format: "%@ %@", "latest_version".localized, DataManager.instance.m_configData.m_latestLampVersion)
        
        lblWarnning.text = "dfu_update_available_caution".localized
        lblSummary.text = "dfu_update_available_description".localized
        btnLastestVersion.setTitle("dfu_latest_version".localized, for: .normal)
        UI_Utility.customButtonBorder(button: btnLastestVersion, radius: 20, width: 1, color: COLOR_TYPE.lblWhiteGray.color.cgColor)

        if (DataManager.instance.m_dataController.newAlarm.lampFirmware.isNewAlarmFirmwarePage(did: m_detailInfo!.m_did)) {
            imgLampLatestVersionNewAlarm.isHidden = false
        }
        
        if (m_isPackageUpdate) {
            lblCurrentVersion.isHidden = true
            lblLatestVersion.isHidden = true
            imgLampLatestVersionNewAlarm.isHidden = true
        }

        setVersionUI()
        
        m_updateTimer?.invalidate()
        m_updateTimer = Timer.scheduledTimer(timeInterval: TimeInterval(m_timeInterval), target: self, selector: #selector(update), userInfo: nil, repeats: true)
    }
    
    func setLogoUI() {
        imgLogoDefault.isHidden = true
        imgLogoKC.isHidden = true
        imgLogoDefault.isHidden = false
    }
    
    func setVersionUI() {
        lblSummary.isHidden = true
        lblWarnning.isHidden = true
        btnUpdate.isHidden = true
        btnLastestVersion.isHidden = true
        
        activityIndicatorUpdate.isHidden = true
        lblUpdateNoti.isHidden = true
//        progressUpdate.isHidden = true
        lblPercent.isHidden = true
        
        if (isNeedUpdate || DataManager.instance.m_userInfo.configData.isMaster) {
            lblSummary.isHidden = false
            lblWarnning.isHidden = false
            btnUpdate.isHidden = false
            changeState(state: updateInfo.m_lampFirmwareState)
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
    
    func changeState(state: HUB_TYPES_FIRMWARE_STATE) {
        switch state {
        case .none:
            lblSummary.isHidden = false
            activityIndicatorUpdate.isHidden = true
            lblUpdateNoti.isHidden = true
//            progressUpdate.isHidden = true
            lblPercent.isHidden = true
            
            btnUpdate.setTitle("btn_update".localized, for: .normal)
            enableSubButtons(isEnable: true)
        case .ready:
            lblSummary.isHidden = true
            activityIndicatorUpdate.isHidden = false
            activityIndicatorUpdate.startAnimating()
            lblUpdateNoti.isHidden = false
            lblUpdateNoti.text = "dfu_update_waiting".localized
//            progressUpdate.isHidden = true
            lblPercent.isHidden = true
            
            btnUpdate.setTitle("dfu_status_uploading".localized, for: .normal)
            enableSubButtons(isEnable: false)
        case .update, .serverComplete:
            lblSummary.isHidden = true
            activityIndicatorUpdate.isHidden = false
            activityIndicatorUpdate.startAnimating()
            lblUpdateNoti.isHidden = false
            lblUpdateNoti.text = m_isPackageUpdate ? "Lamp \("dfu_status_uploading".localized)" : "dfu_status_uploading".localized
//            progressUpdate.isHidden = false
            lblPercent.isHidden = false
            
            btnUpdate.setTitle("dfu_status_uploading".localized, for: .normal)
            enableSubButtons(isEnable: false)
        case .finished:
            lblSummary.isHidden = false
            activityIndicatorUpdate.isHidden = true
            lblUpdateNoti.isHidden = true
//            progressUpdate.isHidden = true
            lblPercent.isHidden = true
            
            btnUpdate.setTitle("btn_update".localized, for: .normal)
            enableSubButtons(isEnable: true)
            
            if (m_isPackageUpdate) {
                if let _sensorInfo = m_sensorDetailInfo {
                    let _view = UIManager.instance.sceneMoveNaviPush(scene: .deviceSetupSensorFirmware, isAniamtion: false) as? DeviceSetupSensorFirmwareViewController
                    _view?.m_isForceInit = true
                    _view?.m_isPackageUpdate = true
                    _view?.setInit(detailInfo: _sensorInfo)
                } else {
                    _ = UIManager.instance.sceneMove(scene: .initView, animation: .coverVertical, isAnimation: false)
                }
            } else {
                if (!isNeedUpdate) {
                    _ = PopupManager.instance.onlyContents(contentsKey: "dfu_status_completed_msg", confirmType: .ok, okHandler: { () -> () in
                        Debug.print("[HUB_FIRMWARE] button action back", event: .warning)
                        if (self.m_isForceInit) {
                            _ = UIManager.instance.sceneMove(scene: .initView, animation: .coverVertical, isAnimation: false)
                        } else {
                            UIManager.instance.sceneMoveNaviPop()
                        }
                    })
                } else {
                    _ = PopupManager.instance.onlyContents(contentsKey: "dfu_status_error", confirmType: .ok, okHandler: { () -> () in
                        Debug.print("[HUB_FIRMWARE] button action back", event: .warning)
                        if (self.m_isForceInit) {
                            _ = UIManager.instance.sceneMove(scene: .initView, animation: .coverVertical, isAnimation: false)
                        } else {
                            UIManager.instance.sceneMoveNaviPop()
                        }
                    })
                }
            }
        }
        updateInfo.m_lampFirmwareState = state
    }
    
    func enableSubButtons(isEnable: Bool) {
        enableSubButton(btn: btnUpdate, isEnable: isEnable)
        enableSubButton(btn: btnBefore, isEnable: isEnable)
        enableSubButton(btn: btnProduct, isEnable: isEnable)
        enableSubButton(btn: btnTest, isEnable: isEnable)
        enableSubButton(btn: btnKc, isEnable: isEnable)
    }
    
    func enableSubButton(btn: UIButton, isEnable: Bool) {
        if (isEnable) {
            btn.isEnabled = true
            btn.backgroundColor = COLOR_TYPE.green.color
        } else {
            btn.isEnabled = false
            btn.backgroundColor = COLOR_TYPE.lblWhiteGray.color
        }
        
        UI_Utility.customButtonBorder(button: btn, radius: 20, width: 1, color: UIColor.clear.cgColor)
        UI_Utility.customButtonShadow(button: btn, radius: 1, offsetWidth: 1, offsetHeight: 1, color: UIColor.black.cgColor, opacity: 0.5)
    }
    
    @objc func update() {
        if (UIManager.instance.rootCurrentView as? DeviceSetupLampFirmwareViewController == nil) {
            m_updateTimer?.invalidate()
            return
        }
        
        switch updateInfo.m_lampFirmwareState {
        case .ready:
            if (updateInfo.m_lampFirmwareTime >= m_readyTime) {
                changeState(state: .update)
                return
            }
            updateInfo.m_lampFirmwareTime += m_timeInterval
        case .update:
            if (updateInfo.m_lampFirmwareTime >= m_updatingTime) {
                changeState(state: .finished)
                return
            }
            if (!isNeedUpdate) {
                changeState(state: .serverComplete)
                return
            }
//            progressUpdate.setProgress(updateInfo.m_lampFirmwareTime / m_updatingTime, animated: true)
            lblPercent.text = String(format: "(%@)", Int((updateInfo.m_lampFirmwareTime / m_updatingTime) * 100).description + "%")
            updateInfo.m_lampFirmwareTime += m_timeInterval
            serverCompleteCheck()
        case .serverComplete:
            if (updateInfo.m_lampFirmwareTime >= m_updatingTime) {
                changeState(state: .finished)
                return
            }
//            progressUpdate.setProgress(updateInfo.m_lampFirmwareTime / m_updatingTime, animated: true)
            lblPercent.text = String(format: "(%@)", Int((updateInfo.m_lampFirmwareTime / m_updatingTime) * 100).description + "%")
            updateInfo.m_lampFirmwareTime += 10
        default: break
        }
    }
    
    func serverCompleteCheck() {
        if (m_serverTime >= m_getServerTime) {
            m_serverTime = 0
            DataManager.instance.m_dataController.userInfo.updateUserInfo(handler: { (isSuccess) in
                if (isSuccess) {
                    Debug.print("[LAMP_FIRMWARE] server complete check update..", event: .warning)
                }
            })
        }
        m_serverTime += m_timeInterval
    }
    
    @IBAction func onClick_back(_ sender: UIButton) {
        if (updateInfo.m_lampFirmwareState != .ready && updateInfo.m_lampFirmwareState != .update && updateInfo.m_lampFirmwareState != .serverComplete) {
            if (m_isForceInit) {
                _ = UIManager.instance.sceneMove(scene: .initView, animation: .coverVertical, isAnimation: false)
            } else {
                UIManager.instance.sceneMoveNaviPop()
            }
        } else {
            _ = PopupManager.instance.onlyContents(contentsKey: "dialog_dfu_stay_this_screen", confirmType: .cancleOK, okHandler: { () -> () in
                Debug.print("[LAMP_FIRMWARE] button action back", event: .warning)
                if (self.m_isForceInit) {
                    _ = UIManager.instance.sceneMove(scene: .initView, animation: .coverVertical, isAnimation: false)
                } else {
                    UIManager.instance.sceneMoveNaviPop()
                }
            })
        }
    }
    
    func startUpdate(mode: LAMP_FIRMWARE_MODE_TYPE) {
        if (!isWifiConnect) {
            _ = PopupManager.instance.onlyContents(contentsKey: "dialog_contents_limited_feature_during_lamp_bluetooth_connection", confirmType: .ok)
            return
        }
        
        Debug.print("[LAMP_FIRMWARE] OTA", event: .warning)
        if (updateInfo.m_lampFirmwareState != .none) {
            return
        }
        changeState(state: .ready)
        Debug.print("[LAMP_FIRMWARE] Start OTA", event: .warning)

        let _send = Send_OTAUpdateDevice()
        _send.aid = DataManager.instance.m_userInfo.account_id
        _send.token = DataManager.instance.m_userInfo.token
        _send.type = DEVICE_TYPE.Lamp.rawValue
        _send.did = self.m_detailInfo!.m_did
        _send.mode = mode.rawValue
        _send.enc = self.userInfo.enc
        _send.isIndicator = false
        NetworkManager.instance.Request(_send) { (json) -> () in
            let receive = Receive_OTAUpdateDevice(json)
            switch receive.ecd {
            case .success: break
            default: Debug.print("[ERROR] Receive_OTAUpdateDevice invaild errcod", event: .error)
            }
        }
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
    
    @IBAction func onClick_update(_ sender: UIButton) {
        self.startUpdate(mode: .mode0)
    }
}
