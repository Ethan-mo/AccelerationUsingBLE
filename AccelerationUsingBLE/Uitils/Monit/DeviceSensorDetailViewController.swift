//
//  DeviceSensorDetailViewController.swift
//  Monit
//
//  Created by 맥 on 2017. 9. 22..
//  Copyright © 2017년 맥. All rights reserved.
//

import UIKit

class DeviceSensorDetailViewController: BaseViewController {
    
    @IBOutlet weak var lblSensorName: UILabel!
    
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
    @IBOutlet weak var viewPosHelpMsgStatus: UIView!
    @IBOutlet weak var viewPosHelpMsgGraph: UIView!
    @IBOutlet weak var viewPosHelpMsgAlarm: UIView!
    @IBOutlet weak var viewPosHelpMsgSetup: UIView!
    
    enum CATEGORY: Int {
        case Sensing = 0
        case Graph = 1
        case Noti = 2
    }

    var initReloadFlow = Flow()
    var getNotiFlow = Flow()
    var m_hiddenModeCount: Int = 0
    
    var helpMsgStatusTab: HelpMessageView?
    var helpMsgGraphTab: HelpMessageView?
    var helpMsgAlarmTab: HelpMessageView?
    var helpMsgSetup: HelpMessageView?
    
    var m_container: DeviceSensorDetailPageViewController?
    var m_detailInfo: DeviceDetailInfo?
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
    
    var userInfo: UserInfoDevice? {
        get {
            return DataManager.instance.m_dataController.device.getUserInfoByDid(did: m_detailInfo!.m_did, type: DEVICE_TYPE.Sensor.rawValue)
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
        isKeyboardFrameUp = true
        super.viewDidLoad()
        Debug.print("[UI][\(self.classNameToString()).viewDidLoad()]")
        if (Utility.isTopNotch || isNotiArea) {
            UIManager.instance.setNaviHeight(identifier: "naviHeight", view: self.view, height: 65.0 + Config.NOTCH_HEIGHT_PADDING)
        }
        if (Config.channel == .kc) {
            helpMessageStatusTab()
        }

        if (Utility.isUpdateVersion(latestVersion: DataManager.instance.m_configData.m_latestSensorForceVersion, currentVersion: userInfo?.fwv ?? "9.9.9")) {
            _ = PopupManager.instance.onlyContents(contentsKey: "contents_need_firmware_update_force", confirmType: .noYes,
                                                   okHandler: { () -> () in
                                                    UIManager.instance.m_finishScenePush = .deviceSetupSensorFirmware
                                                    self.gotoScene()
            })
            //_vc = UIManager.instance.sceneMoveNaviPush(scene: .hubDetail, isAniamtion: isAnimation) as! DeviceHubDetailViewController
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
        if (segue.identifier == "deviceSensorDetailContainer")
        {
            m_container = segue.destination as? DeviceSensorDetailPageViewController
            m_container?.m_parent = self
            m_container?.setInit()
        }
    }
    
    func setUI() {
        if (sensorStatusInfo != nil) {
            lblSensorName.text = "\(sensorStatusInfo!.m_name)"
        } else {
            lblSensorName.text = "MONIT"
        }
        
        btnSensing.setTitle("tab_status".localized.uppercased(), for: .normal)
        btnGraph.setTitle("tab_graph".localized.uppercased(), for: .normal)
        btnNoti.setTitle("tab_notification".localized.uppercased(), for: .normal)
        
        imgNewAlarmSetup.isHidden = true
        if (DataManager.instance.m_dataController.newAlarm.sensorFirmware.isNewAlarmDetailSetup(did: m_detailInfo!.m_did)) {
            imgNewAlarmSetup.isHidden = false
        }
//        DataManager.instance.m_dataController.newAlarm.sensorFirmware.deleteNewAlarmMain(did: m_detailInfo!.m_did)
        
        imgNewAlarmNoti.isHidden = true
        if (Config.channel == .kc) {
            if (isNewAlarm(type: .pee_detected)
                || isNewAlarm(type: .poo_detected)
                || isNewAlarm(type: .abnormal_detected)
                || isNewAlarm(type: .diaper_changed)
                || isNewAlarm(type: .fart_detected)) {
                imgNewAlarmNoti.isHidden = false
            }
        } else {
            if (isNewAlarm(type: .diaper_changed)
                || isNewAlarm(type: .diaper_score)) {
                imgNewAlarmNoti.isHidden = false
            }
        }
        
        if (DataManager.instance.m_userInfo.configData.isBeta) {
            if (isNewAlarm(type: .pee_detected)
                || isNewAlarm(type: .poo_detected)
                || isNewAlarm(type: .abnormal_detected)
                || isNewAlarm(type: .diaper_changed)
                || isNewAlarm(type: .fart_detected)
                || isNewAlarm(type: .diaper_score)) {
                imgNewAlarmNoti.isHidden = false
            }
        }

        setSnoozeUI(isOn: (isSnoozeAlarmStatus(almType: .all) ?? true))
        
        if (!(gotoScene())) {
        }
    }
    
    func gotoScene() -> Bool {
        if (UIManager.instance.m_finishScenePush == .deviceSetupSensorFirmware) {
            let _scene = UIManager.instance.sceneMoveNaviPush(scene: .deviceSetupSensorMain, isAniamtion: false) as! DeviceSetupSensorMainViewController
            _scene.m_detailInfo = m_detailInfo
            return true
        }
        
        return false
    }
    
    func isNewAlarm(type: DEVICE_NOTI_TYPE) -> Bool {
        if (DataManager.instance.m_dataController.newAlarm.noti.isNotiNewAlarm(did: m_detailInfo!.m_did, type: DEVICE_TYPE.Sensor.rawValue, noti: type.rawValue)) {
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
    
    func isSnoozeAlarmStatus(almType: ALRAM_TYPE) -> Bool? {
        return DataManager.instance.m_userInfo.shareDevice.isAlarmStatus(did: m_detailInfo?.m_did ?? 0, type: DEVICE_TYPE.Sensor.rawValue, almType: almType)
    }

    func setSnoozeAlarmChange(isOn: Bool) {
        DataManager.instance.m_dataController.userInfo.shareDevice.changeAlarm(did: m_detailInfo?.m_did ?? 0, type: DEVICE_TYPE.Sensor.rawValue, almType: .all, isOn: isOn)
    }
    
    func reloadNoti() {
        if let _detailInfo = m_detailInfo {
            DataManager.instance.m_dataController.deviceNoti.updateByDid(did: _detailInfo.m_did, type: DEVICE_TYPE.Sensor.rawValue)
        }
    }
 
    func helpMessageStatusTab() {
        self.helpMsgStatusTab = .fromNib()
        self.helpMsgStatusTab?.setInit(helpMessageId: "sensor_status_tab", helpMessageType: .bottom_left, title: "", contents: "tooltip_sensor_status_tab".localized, isOnceCheck: true, nextHandler: helpMessageGraphTab)
        self.helpMsgStatusTab?.setInitUI(parent: viewPosHelpMsgStatus)
    }
    
    func helpMessageGraphTab() {
        self.helpMsgGraphTab = .fromNib()
        self.helpMsgGraphTab?.setInit(helpMessageId: "sensor_graph_tab", helpMessageType: .bottom_center, title: "", contents: "tooltip_sensor_graph_tab".localized, isOnceCheck: true, nextHandler: helpMessageAlarmTab)
        self.helpMsgGraphTab?.setInitUI(parent: viewPosHelpMsgGraph)
    }
    
    func helpMessageAlarmTab() {
        self.helpMsgAlarmTab = .fromNib()
        self.helpMsgAlarmTab?.setInit(helpMessageId: "sensor_alarm_tab", helpMessageType: .bottom_right, title: "", contents: "tooltip_sensor_alarm_tab".localized, isOnceCheck: true, nextHandler: helpMessageSetup)
        self.helpMsgAlarmTab?.setInitUI(parent: viewPosHelpMsgAlarm)
    }
    
    func helpMessageSetup() {
        self.helpMsgSetup = .fromNib()
        self.helpMsgSetup?.setInit(helpMessageId: "sensor_setup", helpMessageType: .bottom_right, title: "", contents: "tooltip_sensor_setup".localized, isOnceCheck: true)
        self.helpMsgSetup?.setInitUI(parent: viewPosHelpMsgSetup)
    }
    
    @IBAction func onClick_back(_ sender: UIButton) {
        UIManager.instance.sceneMoveNaviPop()
    }
    
    @IBAction func onClick_setup(_ sender: UIButton) {
        let _scene = UIManager.instance.sceneMoveNaviPush(scene: .deviceSetupSensorMain) as! DeviceSetupSensorMainViewController
        _scene.m_detailInfo = m_detailInfo
    }
    
    @IBAction func onClick_sensing(_ sender: UIButton) {
        sensing()
    }
    
    func sensing() {
        setCategory(category: .Sensing)
        m_container?.setLoadView(category: .Sensing, isSlide: true)
    }
    
    @IBAction func onClick_graph(_ sender: UIButton) {
        graph()
    }
    
    func graph() {
        setCategory(category: .Graph)
        m_container?.setLoadView(category: .Graph, isSlide: true)
    }
    
    @IBAction func onClick_noti(_ sender: UIButton) {
        noti()
    }
    
    func noti() {
        setCategory(category: .Noti)
        m_container?.setLoadView(category: .Noti, isSlide: true)
    }
    
    func debugMode() {
        let popup: SensorDebugView = .fromNib()
        let _view = UIManager.instance.rootCurrentView?.view
        popup.frame = (_view?.frame)!
        _view?.addSubview(popup)
        popup.setInfo(detailInfo: m_detailInfo)
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
    
    @IBAction func onClick_hiddenMode(_ sender: UIButton) {
        if (DataManager.instance.m_userInfo.configData.isMaster) {
            if (m_hiddenModeCount >= 5) {
                m_hiddenModeCount = 0
                debugMode()
            }
        }
        m_hiddenModeCount += 1
    }
    
    @IBAction func onClick_Snooze(_ sender: UIButton) {
        if let _almStatus = isSnoozeAlarmStatus(almType: .all) {
            setSnoozeAlarmChange(isOn: !_almStatus)
            setSnoozeUI(isOn: !_almStatus)
            setSnoozeLargeUI(isOn: !_almStatus)
        }
    }
}
