//
//  DeviceHubDetailViewController.swift
//  Monit
//
//  Created by 맥 on 2017. 9. 22..
//  Copyright © 2017년 맥. All rights reserved.
//

import UIKit

class DeviceHubDetailViewController: BaseViewController {
    
    @IBOutlet weak var lblHubName: UILabel!
    
    @IBOutlet weak var btnSensing: UIButton!
    @IBOutlet weak var imgDotSensing: UIImageView!
    @IBOutlet weak var viewSensingLine: UIView!
    
    @IBOutlet weak var btnGraph: UIButton!
    @IBOutlet weak var imgDotGraph: UIImageView!
    @IBOutlet weak var viewGraphLine: UIView!
    @IBOutlet weak var imgNewAlarmGraph: UIImageView!
    
    @IBOutlet weak var btnNoti: UIButton!
    @IBOutlet weak var imgDotNoti: UIImageView!
    @IBOutlet weak var viewNotiLine: UIView!
    @IBOutlet weak var imgNewAlarmNoti: UIImageView!

    @IBOutlet weak var btnSnooze: UIButton!
    @IBOutlet weak var imgNewAlarmSetup: UIImageView!
    
    
    enum CATEGORY: Int {
        case Sensing = 0
        case Graph = 1
        case Noti = 2
    }
    
    var initReloadFlow = Flow()
    var getNotiFlow = Flow()
    
    var m_container: DeviceHubDetailPageViewController?
    var m_detailInfo: DeviceDetailInfo?
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
    
    var userInfo: UserInfoDevice? {
        get {
            return DataManager.instance.m_dataController.device.getUserInfoByDid(did: m_detailInfo!.m_did, type: DEVICE_TYPE.Hub.rawValue)
        }
    }
    
    var isNotiArea : Bool {
        get {
            if #available(iOS 11.0, tvOS 11.0, *) {
                return UIApplication.shared.delegate?.window??.safeAreaInsets.top ?? 0 > 20
            }
            return false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Debug.print("[UI][\(self.classNameToString()).viewDidLoad()]")
        if (Utility.isTopNotch || isNotiArea) {
            UIManager.instance.setNaviHeight(identifier: "naviHeight", view: self.view, height: 65.0 + Config.NOTCH_HEIGHT_PADDING)
        }
        
        if (Utility.isUpdateVersion(latestVersion: DataManager.instance.m_configData.m_latestHubForceVersion, currentVersion: userInfo?.fwv ?? "9.9.9")) {
            _ = PopupManager.instance.onlyContents(contentsKey: "contents_need_firmware_update_force", confirmType: .noYes,
                                                   okHandler: { () -> () in
                                                    UIManager.instance.m_finishScenePush = .deviceSetupHubFirmware
                                                    self.goToScene()
            })
        }
        
        setCategory(category: .Sensing)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUI()
        initReloadFlow.reset {
            if let _container = m_container {
                _container.reloadInfoChild()
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getNotiFlow.one {
            reloadNoti()
        }
    }
    
    override func reloadInfo() {
        super.reloadInfo()
        Debug.print("[UI][\(self.classNameToString()).reloadInfo()]")
        setUI()
        if let _container = m_container {
            _container.reloadInfoChild()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "deviceHubDetailContainer")
        {
            m_container = segue.destination as? DeviceHubDetailPageViewController
            m_container?.m_parent = self
            m_container?.setInit()
        }
    }
    
    func setUI() {
        if (hubStatusInfo != nil) {
            lblHubName.text = "\(hubStatusInfo!.m_name)"
        } else {
            lblHubName.text = "MONIT"
        }
        
        btnSensing.setTitle("tab_status".localized.uppercased(), for: .normal)
        btnGraph.setTitle("tab_graph".localized.uppercased(), for: .normal)
        btnNoti.setTitle("tab_notification".localized.uppercased(), for: .normal)
        
        imgNewAlarmSetup.isHidden = true
        if (isConnect) {
            if (DataManager.instance.m_dataController.newAlarm.hubFirmware.isNewAlarmDetailSetup(did: m_detailInfo!.m_did)) {
                imgNewAlarmSetup.isHidden = false
            }
//            DataManager.instance.m_dataController.newAlarm.hubFirmware.deleteNewAlarmMain(did: m_detailInfo!.m_did)
        }

        imgNewAlarmNoti.isHidden = true
        if (isNewAlarm(type: .low_temperature) || isNewAlarm(type: .high_temperature)) {
            imgNewAlarmNoti.isHidden = false
        }
        if (isNewAlarm(type: .low_humidity) || isNewAlarm(type: .high_humidity)) {
            imgNewAlarmNoti.isHidden = false
        }
        if (isNewAlarm(type: .voc_warning)) {
            imgNewAlarmNoti.isHidden = false
        }
        
        setSnoozeUI(isOn: (isSnoozeAlarmStatus(almType: .all) ?? true))
        
        goToScene()
    }
    
    func goToScene() {
        if (UIManager.instance.m_finishScenePush == .deviceSetupHubFirmware) {
            let _scene = UIManager.instance.sceneMoveNaviPush(scene: .deviceSetupHubMain, isAniamtion: false) as! DeviceSetupHubMainViewController
            _scene.m_detailInfo = m_detailInfo
        }
    }
    
    func isNewAlarm(type: DEVICE_NOTI_TYPE) -> Bool {
        if (DataManager.instance.m_dataController.newAlarm.noti.isNotiNewAlarm(did: m_detailInfo!.m_did, type: DEVICE_TYPE.Hub.rawValue, noti: type.rawValue)) {
            return true
        }
        return false
    }
    
    func disableNewAlarmNoti() {
        imgNewAlarmNoti.isHidden = true
    }
    
    func setSnoozeUI(isOn: Bool) {
        if (isOn) {
            btnSnooze.setImage(UIImage(named: "imgSnoozeOn"), for: .normal)
        } else {
            btnSnooze.setImage(UIImage(named: "imgSnoozeOff"), for: .normal)
        }
    }
    
    func isSnoozeAlarmStatus(almType: ALRAM_TYPE) -> Bool? {
        return DataManager.instance.m_userInfo.shareDevice.isAlarmStatus(did: m_detailInfo?.m_did ?? 0, type: DEVICE_TYPE.Hub.rawValue, almType: almType)
    }
    
    func setSnoozeAlarmChange(isOn: Bool) {
        DataManager.instance.m_dataController.userInfo.shareDevice.changeAlarm(did: m_detailInfo?.m_did ?? 0, type: DEVICE_TYPE.Hub.rawValue, almType: .all, isOn: isOn)
    }

    func reloadNoti() {
        if let _detailInfo = m_detailInfo {
            DataManager.instance.m_dataController.deviceNoti.updateByDid(did: _detailInfo.m_did, type: DEVICE_TYPE.Hub.rawValue)
        }
    }

    func setCategory(category: CATEGORY) {
        viewSensingLine.isHidden = true
        viewGraphLine.isHidden = true
        viewNotiLine.isHidden = true
        imgDotSensing.isHidden = true
        imgDotGraph.isHidden = true
        imgDotNoti.isHidden = true
        
        if (Config.channel != .kc) {
            btnSensing.setTitleColor(COLOR_TYPE.lblGray.color, for: .normal)
            btnGraph.setTitleColor(COLOR_TYPE.lblGray.color, for: .normal)
            btnNoti.setTitleColor(COLOR_TYPE.lblGray.color, for: .normal)
            imgDotSensing.image = UIImage(named: "imgDotMintWhite")
            imgDotGraph.image = UIImage(named: "imgDotMintWhite")
            imgDotNoti.image = UIImage(named: "imgDotMintWhite")
            
            switch category {
            case .Sensing:
                btnSensing.setTitleColor(COLOR_TYPE.lblDarkGray.color, for: .normal)
                viewSensingLine.isHidden = false
            case .Graph:
                btnGraph.setTitleColor(COLOR_TYPE.lblDarkGray.color, for: .normal)
                viewGraphLine.isHidden = false
            case .Noti:
                btnNoti.setTitleColor(COLOR_TYPE.lblDarkGray.color, for: .normal)
                viewNotiLine.isHidden = false
            }
        } else {
            imgDotSensing.isHidden = false
            imgDotGraph.isHidden = false
            imgDotNoti.isHidden = false
            btnSensing.setTitleColor(COLOR_TYPE.lblGray.color, for: .normal)
            btnGraph.setTitleColor(COLOR_TYPE.lblGray.color, for: .normal)
            btnNoti.setTitleColor(COLOR_TYPE.lblGray.color, for: .normal)
            imgDotSensing.image = UIImage(named: "imgDotMintWhite")
            imgDotGraph.image = UIImage(named: "imgDotMintWhite")
            imgDotNoti.image = UIImage(named: "imgDotMintWhite")
            
            switch category {
            case .Sensing:
                btnSensing.setTitleColor(COLOR_TYPE.mint.color, for: .normal)
                imgDotSensing.image = UIImage(named: "imgDotMint")
            case .Graph:
                btnGraph.setTitleColor(COLOR_TYPE.mint.color, for: .normal)
                imgDotGraph.image = UIImage(named: "imgDotMint")
            case .Noti:
                btnNoti.setTitleColor(COLOR_TYPE.mint.color, for: .normal)
                imgDotNoti.image = UIImage(named: "imgDotMint")
            }
        }
    }
    
    @IBAction func onClick_back(_ sender: UIButton) {
        UIManager.instance.sceneMoveNaviPop()
    }
    
    @IBAction func onClick_setup(_ sender: UIButton) {
        let _scene = UIManager.instance.sceneMoveNaviPush(scene: .deviceSetupHubMain) as! DeviceSetupHubMainViewController
        _scene.m_detailInfo = m_detailInfo
    }
    
    @IBAction func onClick_sensing(_ sender: UIButton) {
        setCategory(category: .Sensing)
        m_container?.setLoadView(category: .Sensing, isSlide: true)
    }
    
    @IBAction func onClick_graph(_ sender: UIButton) {
        setCategory(category: .Graph)
        m_container?.setLoadView(category: .Graph, isSlide: true)
    }

    @IBAction func onClick_noti(_ sender: UIButton) {
        setCategory(category: .Noti)
        m_container?.setLoadView(category: .Noti, isSlide: true)
    }
    
    @IBAction func onClick_Snooze(_ sender: UIButton) {
        if let _almStatus = isSnoozeAlarmStatus(almType: .all) {
            setSnoozeAlarmChange(isOn: !_almStatus)
            setSnoozeUI(isOn: !_almStatus)
            setSnoozeLargeUI(isOn: !_almStatus)
        }
    }
    
    func setSnoozeLargeUI(isOn: Bool) {
        let _view: SnoozeView = .fromNib()
        _view.setSnooze(isOn: isOn)
        _view.frame = self.view.bounds
        self.view.addSubview(_view)
        
        let _timerController = TimerController()
        _timerController.start(interval: 0.1, finishTime: 1, updateCallback: nil, finishCallback: { () -> () in
            _view.removeFromSuperview()
        })
    }
}
