//
//  DeviceHubDetailSensingHuggiesViewController.swift
//  Monit
//
//  Created by john.lee on 20/05/2020.
//  Copyright © 2020 맥. All rights reserved.
//

import UIKit

class DeviceHubDetailSensingViewController: DeviceHubDetailSensingBaseViewController {
    /// monitoring
    @IBOutlet weak var viewMonitoring: UIView!
    @IBOutlet weak var lblMonitoringTitle: UILabel!
    @IBOutlet weak var imgTemp: UIImageView!
    @IBOutlet weak var lblTempTitle: UILabel!
    @IBOutlet weak var lblTemp: UILabel!
    @IBOutlet weak var lblTempSymbol: UILabel!
    
    @IBOutlet weak var imgHum: UIImageView!
    @IBOutlet weak var lblHumTitle: UILabel!
    @IBOutlet weak var lblHum: UILabel!
    @IBOutlet weak var lblHumSymbol: UILabel!
    
    @IBOutlet weak var imgVoc: UIImageView!
    @IBOutlet weak var lblVocTitle: UILabel!
    @IBOutlet weak var lblVoc: UILabel!
    
    @IBOutlet weak var imgTempWithoutSensor: UIImageView!
    @IBOutlet weak var lblTempTitleWithoutSensor: UILabel!
    @IBOutlet weak var lblTempWithoutSensor: UILabel!
    @IBOutlet weak var lblTempSymbolWithoutSensor: UILabel!
    
    @IBOutlet weak var imgHumWithoutSensor: UIImageView!
    @IBOutlet weak var lblHumTitleWithoutSensor: UILabel!
    @IBOutlet weak var lblHumWithoutSensor: UILabel!
    @IBOutlet weak var lblHumSymbolWithoutSensor: UILabel!
    
    @IBOutlet weak var viewStatus: UIView!
    @IBOutlet weak var viewStatusWithoutSensor: UIView!
    
    /// bright control
    @IBOutlet weak var viewBrightControl: UIView!
    @IBOutlet weak var lblBrightControlTitle: UILabel!
    @IBOutlet weak var lblBrightControlSummary: UILabel!
    @IBOutlet weak var lblBrightSwitchTitle: UILabel!
    @IBOutlet weak var btnBrightSwitch: UIButton!
    @IBOutlet weak var btnBrightDecrease: UIButton!
    @IBOutlet weak var btnBrightIncrease: UIButton!

    @IBOutlet weak var lblTimerTitle: UILabel!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var btnTimer: UIButton!
    @IBOutlet weak var lblTimer: UILabel!
    @IBOutlet weak var imgClock: UIImageView!
    @IBOutlet weak var lblRestTime: UILabel!
    @IBOutlet weak var lblRestTime2: UILabel!
    @IBOutlet weak var lblRestTimeCenter: UILabel!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var viewTimerProgress: UIView!
    
    @IBOutlet weak var viewHubControl: DeviceHubDetailSensingView_HubControl!
    @IBOutlet weak var viewCameraControl: DeviceHubDetailSensingView_Camera!
    @IBOutlet weak var viewPosCameraControl: UIView!
    
    /// Status
    @IBOutlet weak var viewStatusConnect: UIView!
    @IBOutlet weak var lblStatusTitle: UILabel!
    @IBOutlet weak var btnOperation: UIButton!
    @IBOutlet weak var lblOperationStatus: UILabel!
    
    var m_imgTemp: UIImageView!
    var m_lblTempTitle: UILabel!
    var m_lblTemp: UILabel!
    var m_lblTempSymbol: UILabel!
    
    var m_imgHum: UIImageView!
    var m_lblHumTitle: UILabel!
    var m_lblHum: UILabel!
    var m_lblHumSymbol: UILabel!
    
    var m_imgVoc: UIImageView?
    var m_lblVocTitle: UILabel?
    var m_lblVoc: UILabel?
    
    override var screenType: SCREEN_TYPE { get { return .HUB_DETAIL_STATUS } }
    var currentCircleSlider: CircleSlider!
    
    var expireTime: Date?
    var timeController = TimerController()
    var isBrightDisplayHidden: Bool = true
    var isBrightAvailable: Bool = false
    var helpMsgBtnCtrl: HelpMessageView?
    var helpMsgCtrlLevel: HelpMessageView?
    var helpMsgCtrlTime: HelpMessageView?
    var isBlankStatus: Bool = true
    
    @IBOutlet weak var btnCamera: UIButton!
    
    enum SUMMARY {
        case disconnect
        case nice
        case tempLow
        case tempHigh
        case humLow
        case humHigh
        case voc
    }
    
    var isAvailableBright: Bool {
        get {
            return Utility.isAvailableVersion(availableVersion: Config.HUB_TYPES_BRIGHT_CONTROLLER_AVAILABLE_VER, currentVersion: m_parent?.m_parent?.userInfo?.fwv ?? "0.0.0")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setInitUI()
        setUI()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        viewCameraControl.closeWebView() // camera
    }
    
    override func reloadInfoChild() {
        setUI()
        viewHubControl.reloadInfoChild()
    }
    
    func setInitUI() {
        pickerView.delegate = viewHubControl
        pickerView.dataSource = viewHubControl
        viewHubControl.setInit(parent: self)
        
        UI_Utility.customViewBorder(view: viewMonitoring, radius: 20, width: 1, color: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0))
        UI_Utility.customViewBorder(view: viewBrightControl, radius: 20, width: 1, color: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0))
        UI_Utility.customViewBorder(view: viewStatusConnect, radius: 20, width: 1, color: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0))
        
        UI_Utility.customViewShadow(view: viewMonitoring, radius: 20, offsetWidth: 0.1, offsetHeight: 0.1, color: #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1), opacity: 0.2)
        UI_Utility.customViewShadow(view: viewBrightControl, radius: 20, offsetWidth: 0.1, offsetHeight: 0.1, color: #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1), opacity: 0.2)
        UI_Utility.customViewShadow(view: viewStatusConnect, radius: 20, offsetWidth: 0.1, offsetHeight: 0.1, color: #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1), opacity: 0.2)
        
        lblMonitoringTitle.text = "device_hub_room_monitoring_information".localized
        lblBrightControlTitle.text = "device_hub_brightness_control".localized
        lblBrightSwitchTitle.text = "device_hub_power_brightness".localized
        lblTimerTitle.text = "device_hub_power_timer".localized
        lblBrightControlSummary.text = "device_hub_lamp_delay".localized
        lblStatusTitle.text = "device_hub_connection_status".localized
        
        btnCamera.isHidden = true
        if (DataManager.instance.m_userInfo.configData.isBeta) {
            btnCamera.isHidden = false
        }
    }
    
    func setUI() {
        if let _statusInfo = m_parent!.m_parent!.hubStatusInfo {
            let _temp = Double(_statusInfo.m_temp) / 100.0
            let _tempValue = UIManager.instance.getTemperatureProcessing(value: _temp)
            
            if (_statusInfo.voc != .none) {
                m_imgTemp = imgTemp
                m_lblTempTitle = lblTempTitle
                m_lblTemp = lblTemp
                m_lblTempSymbol = lblTempSymbol
                m_imgHum = imgHum
                m_lblHumTitle = lblHumTitle
                m_lblHum = lblHum
                m_lblHumSymbol = lblHumSymbol
                m_imgVoc = imgVoc
                m_lblVocTitle = lblVocTitle
                m_lblVoc = lblVoc
                viewStatus.isHidden = false
                viewStatusWithoutSensor.isHidden = true
            } else {
                m_imgTemp = imgTempWithoutSensor
                m_lblTempTitle = lblTempTitleWithoutSensor
                m_lblTemp = lblTempWithoutSensor
                m_lblTempSymbol = lblTempSymbolWithoutSensor
                m_imgHum = imgHumWithoutSensor
                m_lblHumTitle = lblHumTitleWithoutSensor
                m_lblHum = lblHumWithoutSensor
                m_lblHumSymbol = lblHumSymbolWithoutSensor
                viewStatus.isHidden = true
                viewStatusWithoutSensor.isHidden = false
            }
            
            setHum(hum: _statusInfo.hum, value: _statusInfo.humValue)
            setTemp(temp: _statusInfo.temp, value: _tempValue)
            setVoc(voc: _statusInfo.voc)
            setOperation()

            if (!DataManager.instance.m_dataController.device.m_hub.m_brightController.isRunningTimer(did: m_parent?.m_parent?.hubStatusInfo?.m_did ?? 0)) {
            }
            setConnect(isConnect: m_parent!.m_parent!.isConnect)
        }
        
        m_lblTempSymbol.text = UIManager.instance.temperatureUnitStr
        m_lblTempTitle.text = "device_environment_temperature".localized
        m_lblHumTitle.text = "device_environment_humidity".localized
        m_lblVocTitle?.text = "device_environment_voc".localized
    }
    
    func setTemp(temp: HUB_TYPES_TEMP, value: Double) {
        m_lblTemp.isHidden = false
        m_lblTempSymbol.isHidden = false
        m_lblTempTitle.textColor = COLOR_TYPE.lblGray.color
        m_lblTemp.textColor = COLOR_TYPE.lblDarkGray.color
        
        switch temp {
        case .normal:
            m_imgTemp.image = UIImage(named: "imgTempNormalDetail")
        case .low:
            m_imgTemp.image = UIImage(named: "imgTempErrorDetail")
            m_lblTempTitle.textColor = COLOR_TYPE.red.color
            m_lblTemp.textColor = COLOR_TYPE.red.color
        case .high:
            m_imgTemp.image = UIImage(named: "imgTempErrorDetail")
            m_lblTempTitle.textColor = COLOR_TYPE.red.color
            m_lblTemp.textColor = COLOR_TYPE.red.color
        }
        
        let _value = Double(floor(10 * value) / 10)
        m_lblTemp.text = "\(_value)"
    }
    
    func setHum(hum: HUB_TYPES_HUM, value: Double) {
        m_lblHum.isHidden = false
        m_lblHumSymbol.isHidden = false
        m_lblHumTitle.textColor = COLOR_TYPE.lblGray.color
        m_lblHum.textColor = COLOR_TYPE.lblDarkGray.color
        
        switch hum {
        case .normal:
            m_imgHum.image = UIImage(named: "imgHumNormalDetail")
        case .low,
             .high:
            m_imgHum.image = UIImage(named: "imgHumErrorDetail")
            m_lblHumTitle.textColor = COLOR_TYPE.orange.color
            m_lblHum.textColor = COLOR_TYPE.orange.color
        }
        
        let _value = Double(floor(10 * value) / 10)
        m_lblHum.text = "\(_value)"
    }
    
    func setVoc(voc: HUB_TYPES_VOC) {
        viewStatus.isHidden = false
        viewStatusWithoutSensor?.isHidden = true
        
        if (voc == .none) {
            viewStatus.isHidden = true
            viewStatusWithoutSensor?.isHidden = false
        }
        
        m_lblVoc?.isHidden = false
        m_lblVocTitle?.textColor = COLOR_TYPE.lblGray.color
        m_lblVoc?.textColor = COLOR_TYPE.lblDarkGray.color
        
        switch voc {
        case .none:
            m_imgVoc?.image = UIImage(named: "imgVocDisableDetail")
            m_lblVoc?.isHidden = true
            m_lblVocTitle?.textColor = COLOR_TYPE.lblWhiteGray.color
        case .good:
            m_imgVoc?.image = UIImage(named: "imgVocNormalDetail")
            m_lblVoc?.text = "device_environment_voc_good".localized
        case .normal:
            m_imgVoc?.image = UIImage(named: "imgVocNormalDetail")
            m_lblVoc?.text = "device_environment_voc_normal".localized
        case .bad:
            m_imgVoc?.image = UIImage(named: "imgVocErrorDetail")
            m_lblVoc?.text = "device_environment_voc_not_good".localized
            m_lblVocTitle?.textColor = COLOR_TYPE.red.color
            m_lblVoc?.textColor = COLOR_TYPE.red.color
        case .veryBad:
            m_imgVoc?.image = UIImage(named: "imgVocErrorDetail")
            m_lblVoc?.text = "device_environment_voc_very_bad".localized
            m_lblVocTitle?.textColor = COLOR_TYPE.red.color
            m_lblVoc?.textColor = COLOR_TYPE.red.color
        }
    }
    
    func setOperation() {
        lblOperationStatus.isHidden = false
        lblOperationStatus.textColor = COLOR_TYPE.lblDarkGray.color
        btnOperation.setImage(UIImage(named: "imgConnectNormalDetail"), for: .normal)
        lblOperationStatus.text = "device_sensor_operation_connected".localized
    }

    func setConnect(isConnect: Bool) {
        if (isConnect) {
        } else {
            m_imgTemp.image = UIImage(named: "imgTempDisableDetail")
            m_lblTemp.isHidden = true
            m_lblTempSymbol.isHidden = true
            m_lblTempTitle.textColor = COLOR_TYPE.lblWhiteGray.color
            
            m_imgHum.image = UIImage(named: "imgHumDisableDetail")
            m_lblHum.isHidden = true
            m_lblHumSymbol.isHidden = true
            m_lblHumTitle.textColor = COLOR_TYPE.lblWhiteGray.color
            
            m_imgVoc?.image = UIImage(named: "imgVocDisableDetail")
            m_lblVoc?.isHidden = true
            m_lblVocTitle?.textColor = COLOR_TYPE.lblWhiteGray.color
            
            btnOperation.setImage(UIImage(named: "imgConnectDisableDetail"), for: .normal)
            lblOperationStatus.text = "device_sensor_operation_disconnected".localized
            lblOperationStatus.textColor = COLOR_TYPE.lblGray.color
        }
    }
    
    @IBAction func onClick_Bright_switch(_ sender: UIButton) {
        viewHubControl.onClick_Bright_switch(sender)
    }
    
    @IBAction func onClick_Bright_decrease(_ sender: UIButton) {
        viewHubControl.onClick_Bright_decrease(sender)
    }
    
    @IBAction func onClick_Bright_increase(_ sender: UIButton) {
        viewHubControl.onClick_Bright_increase(sender)
    }
    
    @IBAction func onClick_btnTimer(_ sender: UIButton) {
       viewHubControl.onClick_btnTimer(sender)
    }
    
    var camera_ip: String {
        get { return DataManager.instance.m_configData.getLocalStringAes256(name: "camera_ip") }
        set { DataManager.instance.m_configData.setLocalAes256(name: "camera_ip", value: newValue.description) }
    }
    
    // camera
    func initBrightControl() {
        viewPosCameraControl.isHidden = false
        let _tmpPosY = viewPosCameraControl.frame.minY
        viewPosCameraControl.bounds = viewCameraControl.frame
        viewPosCameraControl.addSubview(viewCameraControl)
        viewPosCameraControl.frame.origin.y = _tmpPosY
//        viewCameraControl.setInit(url: "http://\(camera_ip):81/stream", naviTitle: "모닛 카메라")
        viewCameraControl.setInit(url: "http://\(camera_ip):5000", naviTitle: "모닛 카메라")
    }
    
    // camera
    @IBAction func onClick_btnCamera(_ sender: UIButton) {
//        let _param = UIManager.instance.getBoardParam(board: BOARD_TYPE.notice)
//        let _scene = UIManager.instance.sceneMoveNaviPush(scene: .customWebView, isAniamtion: false) as! CustomWebViewController
//        _scene.setInit(url: "\("http://10.4.10.175:81/stream")\(_param)", naviTitle: "notice_title".localized)
        
        initBrightControl();
    }
    
    @IBAction func onClick_btnCameraClose(_ sender: UIButton) {
        viewCameraControl.closeWebView()
        viewPosCameraControl.isHidden = true
    }
}
