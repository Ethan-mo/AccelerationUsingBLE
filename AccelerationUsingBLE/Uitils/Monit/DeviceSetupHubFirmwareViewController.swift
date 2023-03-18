//
//  DeviceSetupHubFirmwareViewController.swift
//  Monit
//
//  Created by john.lee on 2018. 6. 7..
//  Copyright © 2018년 맥. All rights reserved.
//

import UIKit

enum HUB_TYPES_FIRMWARE_STATE {
    case none
    case ready
    case update
    case serverComplete
    case finished
}

class HubFirmwareUpdateInfo {
    var m_did: Int = 0
    var m_hubFirmwareState: HUB_TYPES_FIRMWARE_STATE = .none
    var m_hubFirmwareTime: Float = 0
    
    init (did: Int) {
        self.m_did = did
    }
}

class DeviceSetupHubFirmwareViewController: BaseViewController {
    @IBOutlet weak var lblNaviTitle: UILabel!
    @IBOutlet weak var lblCurrentVersion: UILabel!
    @IBOutlet weak var lblLatestVersion: UILabel!
    @IBOutlet weak var imgHubLatestVersionNewAlarm: UIImageView!
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
    
    override var screenType: SCREEN_TYPE { get { return .HUB_SETUP_FIRMWARE } }
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

    var hubStatusInfo: HubStatusInfo? {
        get {
            return DataManager.instance.m_userInfo.deviceStatus.m_hubStatus.getInfoByDeviceId(did: m_detailInfo!.m_did)
        }
    }
    
    var isConnect: Bool {
        get {
            return DataManager.instance.m_dataController.device.m_hub.isConnect(type: m_detailInfo!.m_deviceType, did: m_detailInfo!.m_did)
        }
    }
    
    var userInfo: UserInfoDevice {
        get {
            if let _userInfo = DataManager.instance.m_dataController.device.getUserInfoByDid(did: m_detailInfo!.m_did, type: DEVICE_TYPE.Hub.rawValue) {
                return _userInfo
            } else {
                return UserInfoDevice(cid: 0, did: m_detailInfo!.m_did, type: DEVICE_TYPE.Hub.rawValue, name: "", srl: m_tmpSrl, fwv: m_tmpFwv, mac: "", alm: "", adv: "")
            }
        }
    }
    
    var isNeedUpdate: Bool {
        get {
            let _latestVersion = DataManager.instance.m_configData.m_latestHubVersion
            let _currentVersion = userInfo.fwv
            
            if Utility.isUpdateVersion(latestVersion: _latestVersion, currentVersion: _currentVersion) {
                return true
            }
            return false
        }
    }
    
    var isForceUpdate: Bool {
        get {
            let _latestForceVersion = DataManager.instance.m_configData.m_latestHubForceVersion
            let _currentVersion = userInfo.fwv
            
            if Utility.isUpdateVersion(latestVersion: _latestForceVersion, currentVersion: _currentVersion) {
                return true
            }
            return false
        }
    }
    
    var updateInfo: HubFirmwareUpdateInfo {
        get {
            var _lstDel: [HubFirmwareUpdateInfo] = []
            for item in UIManager.instance.m_hubFirmwareUpdate {
                if (item.m_did == m_detailInfo!.m_did) {
                    if (item.m_hubFirmwareState != .finished) {
                        return item
                    } else {
                        _lstDel.append(item)
                    }
                }
            }
            
            for item in _lstDel {
                if let index = UIManager.instance.m_hubFirmwareUpdate.index(where: { $0 === item }) {
                    UIManager.instance.m_hubFirmwareUpdate.remove(at: index)
                }
            }
       
            let _info = HubFirmwareUpdateInfo(did: m_detailInfo!.m_did)
            UIManager.instance.m_hubFirmwareUpdate.append(_info)
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
        Debug.print("[HUB_FIRMWARE] setInit()", event: .warning)
        m_detailInfo = detailInfo
    }
    
    func setUI() {
        Debug.print("[HUB_FIRMWARE] setUI()", event: .warning)
        lblNaviTitle.text = "title_firmware_update".localized
        lblCurrentVersion.text = String(format: "%@ %@", "current_version".localized, userInfo.fwv)
        lblLatestVersion.text = String(format: "%@ %@", "latest_version".localized, DataManager.instance.m_configData.m_latestHubVersion)
        
        lblWarnning.text = "dfu_update_available_caution".localized
        lblSummary.text = isForceUpdate ? "dfu_update_available_description_force".localized : "dfu_update_available_description".localized
        btnLastestVersion.setTitle("dfu_latest_version".localized, for: .normal)
        UI_Utility.customButtonBorder(button: btnLastestVersion, radius: 20, width: 1, color: COLOR_TYPE.lblWhiteGray.color.cgColor)

        if (DataManager.instance.m_dataController.newAlarm.hubFirmware.isNewAlarmFirmwarePage(did: m_detailInfo!.m_did)) {
            imgHubLatestVersionNewAlarm.isHidden = false
        }
        
        if (m_isPackageUpdate) {
            lblCurrentVersion.isHidden = true
            lblLatestVersion.isHidden = true
            imgHubLatestVersionNewAlarm.isHidden = true
        }

        setVersionUI()
        
        m_updateTimer?.invalidate()
        m_updateTimer = Timer.scheduledTimer(timeInterval: TimeInterval(m_timeInterval), target: self, selector: #selector(update), userInfo: nil, repeats: true)
    }
    
    func setLogoUI() {
        imgLogoDefault.isHidden = true
        imgLogoKC.isHidden = true
        switch Config.channel {
        case .kc: imgLogoKC.isHidden = false
        default: imgLogoDefault.isHidden = false
        }
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
            changeState(state: updateInfo.m_hubFirmwareState)
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
            lblUpdateNoti.text = m_isPackageUpdate ? "Hub \("dfu_status_uploading".localized)" : "dfu_status_uploading".localized
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
        updateInfo.m_hubFirmwareState = state
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
        if (UIManager.instance.rootCurrentView as? DeviceSetupHubFirmwareViewController == nil) {
            m_updateTimer?.invalidate()
            return
        }
        
        switch updateInfo.m_hubFirmwareState {
        case .ready:
            if (updateInfo.m_hubFirmwareTime >= m_readyTime) {
                changeState(state: .update)
                return
            }
            updateInfo.m_hubFirmwareTime += m_timeInterval
        case .update:
            if (updateInfo.m_hubFirmwareTime >= m_updatingTime) {
                changeState(state: .finished)
                return
            }
            if (!isNeedUpdate) {
                changeState(state: .serverComplete)
                return
            }
//            progressUpdate.setProgress(updateInfo.m_hubFirmwareTime / m_updatingTime, animated: true)
            lblPercent.text = String(format: "(%@)", Int((updateInfo.m_hubFirmwareTime / m_updatingTime) * 100).description + "%")
            updateInfo.m_hubFirmwareTime += m_timeInterval
            serverCompleteCheck()
        case .serverComplete:
            if (updateInfo.m_hubFirmwareTime >= m_updatingTime) {
                changeState(state: .finished)
                return
            }
//            progressUpdate.setProgress(updateInfo.m_hubFirmwareTime / m_updatingTime, animated: true)
            lblPercent.text = String(format: "(%@)", Int((updateInfo.m_hubFirmwareTime / m_updatingTime) * 100).description + "%")
            updateInfo.m_hubFirmwareTime += 10
        default: break
        }
    }
    
    func serverCompleteCheck() {
        if (m_serverTime >= m_getServerTime) {
            m_serverTime = 0
            DataManager.instance.m_dataController.userInfo.updateUserInfo(handler: { (isSuccess) in
                if (isSuccess) {
                    Debug.print("[HUB_FIRMWARE] server complete check update..", event: .warning)
                }
            })
        }
        m_serverTime += m_timeInterval
    }
    
    @IBAction func onClick_back(_ sender: UIButton) {
        if (updateInfo.m_hubFirmwareState != .ready && updateInfo.m_hubFirmwareState != .update && updateInfo.m_hubFirmwareState != .serverComplete) {
            if (m_isForceInit) {
                _ = UIManager.instance.sceneMove(scene: .initView, animation: .coverVertical, isAnimation: false)
            } else {
                UIManager.instance.sceneMoveNaviPop()
            }
        } else {
            _ = PopupManager.instance.onlyContents(contentsKey: "dialog_dfu_stay_this_screen", confirmType: .cancleOK, okHandler: { () -> () in
                Debug.print("[HUB_FIRMWARE] button action back", event: .warning)
                if (self.m_isForceInit) {
                    _ = UIManager.instance.sceneMove(scene: .initView, animation: .coverVertical, isAnimation: false)
                } else {
                    UIManager.instance.sceneMoveNaviPop()
                }
            })
        }
    }
    
    func startUpdate(mode: HUB_FIRMWARE_MODE_TYPE) {
        Debug.print("[HUB_FIRMWARE] OTA", event: .warning)
        if (updateInfo.m_hubFirmwareState != .none) {
            return
        }
        changeState(state: .ready)
        Debug.print("[HUB_FIRMWARE] Start OTA", event: .warning)

        let _send = Send_OTAUpdateDevice()
        _send.aid = DataManager.instance.m_userInfo.account_id
        _send.token = DataManager.instance.m_userInfo.token
        _send.type = DEVICE_TYPE.Hub.rawValue
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
