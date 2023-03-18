//
//  DeviceSensorDetailSensingViewController.swift
//  Monit
//
//  Created by 맥 on 2017. 9. 22..
//  Copyright © 2017년 맥. All rights reserved.
//

import UIKit

class DeviceHubDetailSensingForKcViewController: DeviceHubDetailSensingBaseViewController {

    @IBOutlet weak var imgHub: UIImageView!
    @IBOutlet weak var imgHubBack: UIImageView!
    
    @IBOutlet weak var imgRound: UIImageView!
    @IBOutlet weak var viewRoundFill: UIView!
    @IBOutlet weak var lblScore: UILabel!
    @IBOutlet weak var lblScoreStatus: UILabel!
    
    @IBOutlet weak var imgTempForMonit: UIImageView!
    @IBOutlet weak var lblTempTitleForMonit: UILabel!
    @IBOutlet weak var lblTempForMonit: UILabel!
    @IBOutlet weak var lblTempSymbolForMonit: UILabel!
    
    @IBOutlet weak var imgHumForMonit: UIImageView!
    @IBOutlet weak var lblHumTitleForMonit: UILabel!
    @IBOutlet weak var lblHumForMonit: UILabel!
    @IBOutlet weak var lblHumSymbolForMonit: UILabel!
    
    @IBOutlet weak var imgVocForMonit: UIImageView!
    @IBOutlet weak var lblVocTitleForMonit: UILabel!
    @IBOutlet weak var lblVocForMonit: UILabel!
    
    @IBOutlet weak var imgTempForKc: UIImageView!
    @IBOutlet weak var lblTempTitleForKc: UILabel!
    @IBOutlet weak var lblTempForKc: UILabel!
    @IBOutlet weak var lblTempSymbolForKc: UILabel!
    
    @IBOutlet weak var imgHumForKc: UIImageView!
    @IBOutlet weak var lblHumTitleForKc: UILabel!
    @IBOutlet weak var lblHumForKc: UILabel!
    @IBOutlet weak var lblHumSymbolForKc: UILabel!
    
    @IBOutlet weak var lblSummaryTitle: UILabel!
    @IBOutlet weak var lblSummaryContents: UILabel!
    
    @IBOutlet weak var viewBrightController: UIView!
    @IBOutlet weak var btnBrightOpen: UIButton!
    @IBOutlet weak var brightIndicator: UIActivityIndicatorView!
    @IBOutlet weak var lblRestTime: UILabel!
    @IBOutlet weak var lblRestTime2: UILabel!
    @IBOutlet weak var lblRestTimeCenter: UILabel!
    
    @IBOutlet weak var viewStatus: UIView!
    @IBOutlet weak var viewStatusForKc: UIView!
    @IBOutlet weak var viewHubControl: DeviceHubDetailSensingForKcView_HubControl!
    @IBOutlet weak var viewPosHubControl: UIView!
    @IBOutlet weak var viewPosHelpMessageHubControl: UIView!
    @IBOutlet weak var viewPosHelpMessageBrightLevel: UIView!
    @IBOutlet weak var viewPosHelpMessageBrightTime: UIView!
    
    var imgTemp: UIImageView!
    var lblTempTitle: UILabel!
    var lblTemp: UILabel!
    var lblTempSymbol: UILabel!
    
    var imgHum: UIImageView!
    var lblHumTitle: UILabel!
    var lblHum: UILabel!
    var lblHumSymbol: UILabel!
    
    var imgVoc: UIImageView?
    var lblVocTitle: UILabel?
    var lblVoc: UILabel?

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
        viewStatus.isHidden = true
        viewStatusForKc.isHidden = true
        switch Config.channel {
        case .goodmonit, .monitXHuggies, .kao:
            imgTemp = imgTempForMonit
            lblTempTitle = lblTempTitleForMonit
            lblTemp = lblTempForMonit
            lblTempSymbol = lblTempSymbolForMonit
            imgHum = imgHumForMonit
            lblHumTitle = lblHumTitleForMonit
            lblHum = lblHumForMonit
            lblHumSymbol = lblHumSymbolForMonit
            imgVoc = imgVocForMonit
            lblVocTitle = lblVocTitleForMonit
            lblVoc = lblVocForMonit
            viewStatus.isHidden = false
        case .kc:
            imgTemp = imgTempForKc
            lblTempTitle = lblTempTitleForKc
            lblTemp = lblTempForKc
            lblTempSymbol = lblTempSymbolForKc
            imgHum = imgHumForKc
            lblHumTitle = lblHumTitleForKc
            lblHum = lblHumForKc
            lblHumSymbol = lblHumSymbolForKc
           viewStatusForKc.isHidden = false
        }
        
        initBrightControl()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setBrightControlDisplay(isHidden: true)
        setOnceUI()
        setUI()
    }
 
    override func reloadInfoChild() {
//        ScreenAnalyticsManager.instance.setScreen(screenType: screenType)
        setUI()
        viewHubControl.reloadInfoChild()
    }
    
    func setOnceUI() {
        setTimerCtrl()
    }

    func setUI() {
        imgHub.image = UIImage(named: Config.channel == .kc ? "imgKcHubLarge_BrightOn" : "imgHubLarge_BrightOn")
        if let _statusInfo = m_parent!.m_parent!.hubStatusInfo {
            let _temp = Double(_statusInfo.m_temp) / 100.0
            let _tempValue = UIManager.instance.getTemperatureProcessing(value: _temp)
            
            setHum(hum: _statusInfo.hum, value: _statusInfo.humValue)
            setTemp(temp: _statusInfo.temp, value: _tempValue)
            setVoc(voc: _statusInfo.voc)
            setScore(score: _statusInfo.score, value: _statusInfo.scoreValue)
            //            if (!DataManager.instance.m_dataController.device.m_hub.m_brightController.isRunningTimer(did: m_parent?.m_parent?.hubStatusInfo?.m_did ?? 0)) {
            //                setBrightLevel(value: _statusInfo.m_bright)
            //            }
            btnBrightOpen.isUserInteractionEnabled = true
            btnBrightOpen.setImage(UIImage(named: Config.channel == .kc ? "imgKcHubControlOpen" : "imgHubControlOpen"), for: .normal)
            setBrightLevelUI(value: _statusInfo.brightLevel)
            
            if (!DataManager.instance.m_dataController.device.m_hub.m_brightController.isRunningTimer(did: m_parent?.m_parent?.hubStatusInfo?.m_did ?? 0)) {
            }
            setConnect(isConnect: m_parent!.m_parent!.isConnect)
            setSummaryOn(score: _statusInfo.score, hum: _statusInfo.hum, temp: _statusInfo.temp, voc: _statusInfo.voc, isConnect: m_parent!.m_parent!.isConnect)
        }
        
        lblTempSymbol.text = UIManager.instance.temperatureUnitStr
        lblTempTitle.text = "device_environment_temperature".localized
        lblHumTitle.text = "device_environment_humidity".localized
        lblVocTitle?.text = "device_environment_voc".localized
    }
    
    func setSlider(amount: Int, color: UIColor) { // amount: 1~100
        lblScore.text = amount.description
        lblScore.textColor = color
        if currentCircleSlider != nil { currentCircleSlider.removeFromSuperview() }
        currentCircleSlider = UIManager.instance.makeCircleSlider(amount: Float(amount) * 0.01, width: 9, diameter: 162, color: color)
        viewRoundFill.addSubview(currentCircleSlider)
    }
    
    func setTemp(temp: HUB_TYPES_TEMP, value: Double) {
        lblTemp.isHidden = false
        lblTempSymbol.isHidden = false
        lblTempTitle.textColor = COLOR_TYPE.lblGray.color
        lblTemp.textColor = COLOR_TYPE.lblDarkGray.color
        
        if (Config.channel == .kc) {
            switch temp {
            case .normal:
                imgTemp.image = UIImage(named: "imgKcTempNormalDetail")
            case .low:
                imgTemp.image = UIImage(named: "imgKcTempErrorDetail_glow_blue")
                lblTempTitle.textColor = COLOR_TYPE.blue.color
                lblTemp.textColor = COLOR_TYPE.blue.color
                
                imgHub.image = UIImage(named: "imgKcHubLarge_BrightWarning_blue")
            case .high:
                imgTemp.image = UIImage(named: "imgKcTempErrorDetail_glow_red")
                lblTempTitle.textColor = COLOR_TYPE.red.color
                lblTemp.textColor = COLOR_TYPE.red.color
                
                imgHub.image = UIImage(named: "imgKcHubLarge_BrightWarning_red")
            }
        } else {
            switch temp {
            case .normal:
                imgTemp.image = UIImage(named: "imgTempNormalDetail")
            case .low:
                imgTemp.image = UIImage(named: "imgTempErrorDetail")
                lblTempTitle.textColor = COLOR_TYPE.red.color
                lblTemp.textColor = COLOR_TYPE.red.color
                
                imgHub.image = UIImage(named: "imgHubLarge_BrightWarning")
            case .high:
                imgTemp.image = UIImage(named: "imgTempErrorDetail")
                lblTempTitle.textColor = COLOR_TYPE.red.color
                lblTemp.textColor = COLOR_TYPE.red.color
                
                imgHub.image = UIImage(named: "imgHubLarge_BrightWarning")
            }
        }
        
        let _value = Double(floor(10 * value) / 10)
        lblTemp.text = "\(_value)"
    }
    
    func setHum(hum: HUB_TYPES_HUM, value: Double) {
        lblHum.isHidden = false
        lblHumSymbol.isHidden = false
        lblHumTitle.textColor = COLOR_TYPE.lblGray.color
        lblHum.textColor = COLOR_TYPE.lblDarkGray.color
        
        if (Config.channel == .kc) {
            switch hum {
            case .normal:
                imgHum.image = UIImage(named: "imgKcHumNormalDetail")
            case .low,
                 .high:
                imgHum.image = UIImage(named: "imgKcHumErrorDetail_glow")
                lblHumTitle.textColor = COLOR_TYPE.orange.color
                lblHum.textColor = COLOR_TYPE.orange.color
                
                imgHub.image = UIImage(named: "imgKcHubLarge_BrightWarning_orange")
            }
        } else {
            switch hum {
            case .normal:
                imgHum.image = UIImage(named: "imgHumNormalDetail")
            case .low,
                 .high:
                imgHum.image = UIImage(named: "imgHumErrorDetail")
                lblHumTitle.textColor = COLOR_TYPE.orange.color
                lblHum.textColor = COLOR_TYPE.orange.color
                
                imgHub.image = UIImage(named: "imgHubLarge_BrightWarning")
            }
        }
        
        let _value = Double(floor(10 * value) / 10)
        lblHum.text = "\(_value)"
    }
    
    func setVoc(voc: HUB_TYPES_VOC) {
        guard (Config.channel != .kc) else { return }
        
        lblVoc?.isHidden = false
        lblVocTitle?.textColor = COLOR_TYPE.lblGray.color
        lblVoc?.textColor = COLOR_TYPE.lblDarkGray.color
        
        switch voc {
        case .none:
            imgVoc?.image = UIImage(named: "imgVocDisableDetail")
            lblVoc?.isHidden = true
            lblVocTitle?.textColor = COLOR_TYPE.lblWhiteGray.color
        case .good:
            imgVoc?.image = UIImage(named: "imgVocNormalDetail")
            lblVoc?.text = "device_environment_voc_good".localized
        case .normal:
            imgVoc?.image = UIImage(named: "imgVocNormalDetail")
            lblVoc?.text = "device_environment_voc_normal".localized
        case .bad:
            imgVoc?.image = UIImage(named: "imgVocErrorDetail")
            lblVoc?.text = "device_environment_voc_not_good".localized
            lblVocTitle?.textColor = COLOR_TYPE.red.color
            lblVoc?.textColor = COLOR_TYPE.red.color
            
            imgHub.image = UIImage(named: "imgHubLarge_BrightWarning")
        case .veryBad:
            imgVoc?.image = UIImage(named: "imgVocErrorDetail")
            lblVoc?.text = "device_environment_voc_very_bad".localized
            lblVocTitle?.textColor = COLOR_TYPE.red.color
            lblVoc?.textColor = COLOR_TYPE.red.color
            
            imgHub.image = UIImage(named: "imgHubLarge_BrightWarning")
        }
    }
    
    func setScore(score: HUB_TYPES_SCORE, value: Int) {
        lblScore.isHidden = false
        lblScoreStatus.isHidden = false
        viewRoundFill.isHidden = false
        
        switch score {
        case .good:
            setSlider(amount: value, color: COLOR_TYPE.gaugeBlue.color)
            lblScoreStatus.textColor = COLOR_TYPE.gaugeBlue.color
            lblScoreStatus.text = "device_environment_voc_good".localized
        case .normal:
            setSlider(amount: value, color: COLOR_TYPE.gaugeGreen.color)
            lblScoreStatus.textColor = COLOR_TYPE.gaugeGreen.color
            lblScoreStatus.text = "device_environment_voc_normal".localized
        case .bad:
            setSlider(amount: value, color: COLOR_TYPE.gaugeYellow.color)
            lblScoreStatus.textColor = COLOR_TYPE.gaugeYellow.color
            lblScoreStatus.text = "device_environment_voc_not_good".localized
        case .veryBad:
            setSlider(amount: value, color: COLOR_TYPE.gaugeRed.color)
            lblScoreStatus.textColor = COLOR_TYPE.gaugeRed.color
            lblScoreStatus.text = "device_environment_voc_very_bad".localized
        }
    }
    
    func setSummaryOn(score: HUB_TYPES_SCORE, hum: HUB_TYPES_HUM, temp: HUB_TYPES_TEMP, voc: HUB_TYPES_VOC, isConnect: Bool) {
        var _isSet = false
        if (score == .good || score == .normal) {
            _isSet = true
            setSummary(summary: .nice)
        }
        
        if (hum == .low) {
            _isSet = true
            setSummary(summary: .humLow)
        }
        
        if (hum == .high) {
            _isSet = true
            setSummary(summary: .humHigh)
        }
        
        if (temp == .low) {
            _isSet = true
            setSummary(summary: .tempLow)
        }
        
        if (temp == .high) {
            _isSet = true
            setSummary(summary: .tempHigh)
        }
        
        if (voc == .bad || voc == .veryBad) {
            _isSet = true
            setSummary(summary: .voc)
        }
        
        if (!isConnect) {
            _isSet = true
            setSummary(summary: .disconnect)
        }
        
        if (!_isSet) {
            lblSummaryTitle.text = ""
            lblSummaryContents.text = ""
        }
    }
    
    func setSummary(summary: SUMMARY) {
        switch summary {
        case .disconnect:
            lblSummaryTitle.text = "device_hub_disconnected_title".localized
            lblSummaryContents.text = "device_hub_disconnected_detail".localized
            lblSummaryTitle.textColor = COLOR_TYPE.lblDarkGray.color
        case .nice:
            lblSummaryTitle.text = "device_environment_status_normal_detail".localized
            lblSummaryContents.text = ""
            lblSummaryTitle.textColor = Config.channel == .kc ? COLOR_TYPE.green.color : COLOR_TYPE.blue.color
        case .tempLow:
            lblSummaryTitle.text = "device_environment_temperature_low\(getSummaryIndex())".localized
            lblSummaryContents.text = "device_environment_temperature_low_action\(getSummaryIndex())".localized
            lblSummaryTitle.textColor = Config.channel == .kc ? COLOR_TYPE.blue.color : COLOR_TYPE.red.color
        case .tempHigh:
            lblSummaryTitle.text = "device_environment_temperature_high\(getSummaryIndex())".localized
            lblSummaryContents.text = "device_environment_temperature_high_action\(getSummaryIndex())".localized
            lblSummaryTitle.textColor = Config.channel == .kc ? COLOR_TYPE.red.color : COLOR_TYPE.red.color
        case .humLow:
            lblSummaryTitle.text = "device_environment_humidity_low\(getSummaryIndex())".localized
            lblSummaryContents.text = "device_environment_humidity_low_action\(getSummaryIndex())".localized
            lblSummaryTitle.textColor = Config.channel == .kc ? COLOR_TYPE.orange.color : COLOR_TYPE.red.color
        case .humHigh:
            lblSummaryTitle.text = "device_environment_humidity_high\(getSummaryIndex())".localized
            lblSummaryContents.text = "device_environment_humidity_high_action\(getSummaryIndex())".localized
            lblSummaryTitle.textColor = Config.channel == .kc ? COLOR_TYPE.orange.color : COLOR_TYPE.red.color
        case .voc:
            guard (Config.channel != .kc) else { return }
            lblSummaryTitle.text = "device_environment_voc_bad_detected\(getSummaryIndex())".localized
            lblSummaryContents.text = "device_environment_voc_bad_action\(getSummaryIndex())".localized
            lblSummaryTitle.textColor = COLOR_TYPE.red.color
        }
    }
    
    func getSummaryIndex() -> String {
        return getRandomString(["", "2", "3", "4", "5"])
    }
    
    func getRandomString(_ arrStr: [String]) -> String {
        let _randomIndex = Int(arc4random_uniform(UInt32(arrStr.count)))
        return arrStr[_randomIndex]
    }
    
    func setConnect(isConnect: Bool) {
        if (isConnect) {
        } else {
            imgTemp.image = UIImage(named: "imgTempDisableDetail")
            lblTemp.isHidden = true
            lblTempSymbol.isHidden = true
            lblTempTitle.textColor = COLOR_TYPE.lblWhiteGray.color
            
            imgHum.image = UIImage(named: "imgHumDisableDetail")
            lblHum.isHidden = true
            lblHumSymbol.isHidden = true
            lblHumTitle.textColor = COLOR_TYPE.lblWhiteGray.color
            
            imgVoc?.image = UIImage(named: "imgVocDisableDetail")
            lblVoc?.isHidden = true
            lblVocTitle?.textColor = COLOR_TYPE.lblWhiteGray.color
            
            lblScore.isHidden = true
            lblScoreStatus.isHidden = true
            viewRoundFill.isHidden = true

            btnBrightOpen.isUserInteractionEnabled = false
            btnBrightOpen.setImage(UIImage(named: "imgHubControlOpenDisable"), for: .normal)
            setBrightControlDisplay(isHidden: true, isReloadUI: false)
            setTimerDisplay(isHidden: true)
        }
    }
    
    func initBrightControl() {
        lblRestTime.isUserInteractionEnabled = false
        lblRestTime2.isUserInteractionEnabled = false
        lblRestTimeCenter.isUserInteractionEnabled = false
        let _tmpPosY = viewPosHubControl.frame.minY
        viewPosHubControl.bounds = viewHubControl.frame
        viewPosHubControl.addSubview(viewHubControl)
        viewPosHubControl.frame.origin.y = _tmpPosY
        viewHubControl.setInit(parent: self)
        
        setAvailableBright()
    }
    
    func initTimer() {
        self.expireTime = nil
        self.timeController.stop()
    }
    
    func setTimerCtrl() {
        let time = m_parent?.m_parent?.hubStatusInfo?.m_offptime ?? Config.DATE_INIT
        guard (time != Config.DATE_INIT) else {
            self.initTimer()
            self.setTimerUI(expireTime: self.expireTime)
            return
        }
        
        self.isBlankStatus = true
        self.expireTime = time.ToPacketTime()
        let _second = UIManager.instance.getTimeDiffSecond(time: time.ToPacketTime())
        self.timeController.start(interval: 1, finishTime: Double(_second), updateCallback: {() -> () in
            self.setTimerUI(expireTime: self.expireTime)
        }, finishCallback: {() -> () in
            self.setTimerUI(expireTime: self.expireTime)
            self.expireTime = nil
        })
    }
    
    func setTimerDisplay(isHidden: Bool) {
        lblRestTime.isHidden = isHidden
        lblRestTime2.isHidden = isHidden
        lblRestTimeCenter.isHidden = isHidden
        if (!m_parent!.m_parent!.isConnect) {
            lblRestTime.isHidden = true
            lblRestTime2.isHidden = true
            lblRestTimeCenter.isHidden = true
        }
        if (!isBrightDisplayHidden) {
            lblRestTime.isHidden = true
            lblRestTime2.isHidden = true
            lblRestTimeCenter.isHidden = true
        }
    }
    
    func setTimerUI(expireTime: Date?) {
        guard (Config.DATE_INIT != expireTime?.ToPacketTime() ?? Config.DATE_INIT) else {
            setTimerDisplay(isHidden: true)
            return
        }
        
        var _hour = 0
        var _min = 0
        (_hour, _min) = UIManager.instance.getTimeDiffHourAndMinute(time: expireTime ?? Date())
        if (_hour + _min > 0) {
            setTimerDisplay(isHidden: false)
            let _blank = isBlankStatus ? ":" : ""
            isBlankStatus = !isBlankStatus
            self.lblRestTime.text = "\(String(format: "%02d", _hour))"
            self.lblRestTime2.text = "\(String(format: "%02d", _min))"
            self.lblRestTimeCenter.text = "\(_blank)"
            self.lblRestTime.textColor = Config.channel == .kc ? COLOR_TYPE.green.color : COLOR_TYPE.blue.color
        } else {
            setTimerDisplay(isHidden: true)
        }
    }
    
    func setAvailableBright() {
        guard (isAvailableBright) else {
            brightAvailableUI(isHidden: true)
            return
        }
        
        guard (Config.channel != .kc) else {
            brightAvailableUI(isHidden: true)
            return
        }
        
//        let _srl = m_parent?.m_parent?.userInfo?.srl ?? ""
//        Debug.print("Hub Seiral : \(_srl)")
//
//        guard (!_srl.contains("HKU851")) else {
//            brightAvailableUI(isHidden: true)
//            return
//        }
//
//        var _isFound = false
//        for item in Config.HUB_BRIGHT_CONTROLLER_AVAILABLE_SERIAL {
//            if (_srl.contains(item)) {
//                _isFound = true
//            }
//        }
//
//        if (_isFound) {
            brightAvailableUI(isHidden: false)
//        } else {
//            brightAvailableUI(isHidden: true)
//        }
    }
    
    func setBrightControlDisplay(isHidden: Bool, isReloadUI: Bool = true) {
        brightIndicator.stopAnimating()
        brightIndicator.isHidden = true
        isBrightDisplayHidden = isHidden
        viewPosHubControl.isHidden = isHidden

        if (isHidden) {
            Debug.print("Device Hub Detail Bright Close")
            viewHubControl.initTimer()
            
            helpMessageBrightControlBtn()
            helpMsgCtrlTime?.windowClose()
            helpMsgCtrlLevel?.windowClose()
            if (isReloadUI) {
                setUI()
            }
        } else {
            Debug.print("Device Hub Detail Bright Open")
            lblRestTime.isHidden = true
            lblRestTime2.isHidden = true
            lblRestTimeCenter.isHidden = true
            viewHubControl.setInit(parent: self)
            
            helpMessageBrightLevel()
            helpMsgBtnCtrl?.windowClose()
        }
    }
    
    func brightAvailableUI(isHidden: Bool) {
        isBrightAvailable = !isHidden
        viewBrightController.isHidden = isHidden
        setBrightControlDisplay(isHidden: isHidden)
        
        if (isHidden) {
            setTimerDisplay(isHidden: true)
        }
    }
    
    func setBrightLevelUI(value: HUB_TYPES_BRIGHT_TYPE) {
        imgHubBack?.isHidden = false
        switch value {
        case .off: imgHubBack?.isHidden = true; break;
        case .level_1: imgHubBack?.image = UIImage(named: "imgHubBrightBack1"); break;
        case .level_2: imgHubBack?.image = UIImage(named: "imgHubBrightBack2"); break;
        case .level_3: imgHubBack?.image = UIImage(named: "imgHubBrightBack3"); break;
        case .start: break;
        }
        
        if (!m_parent!.m_parent!.isConnect) {
            imgHub.image = UIImage(named: "imgHubLarge_BrightOff")
            imgHubBack.isHidden = true
        }
    }
    
    func helpMessageBrightControlBtn() {
        guard (isBrightAvailable) else { return }
        
        self.helpMsgBtnCtrl = .fromNib()
        self.helpMsgBtnCtrl?.setInit(helpMessageId: "btnBrightControlBtn", helpMessageType: .bottom_right, title: "tooltip_lamp_section_enable_button_title".localized, contents: "tooltip_lamp_section_enable_button_contents".localized, isOnceCheck: true)
        self.helpMsgBtnCtrl?.setInitUI(parent: viewPosHelpMessageHubControl)
    }
    
    func helpMessageBrightLevel() {
        self.helpMsgCtrlLevel = .fromNib()
        self.helpMsgCtrlLevel?.setInit(helpMessageId: "brightControlLevel", helpMessageType: .top_left, title: "", contents: "tooltip_lamp_section_brightness_adjustment_contents".localized, isOnceCheck: true, nextHandler: helpMessageBrightTime)
        self.helpMsgCtrlLevel?.setInitUI(parent: viewPosHelpMessageBrightLevel)
    }
    
    func helpMessageBrightTime() {
        self.helpMsgCtrlTime = .fromNib()
        self.helpMsgCtrlTime?.setInit(helpMessageId: "brightControlTime", helpMessageType: .bottom_left, title: "", contents: "tooltip_lamp_section_turning_off_timer_contents".localized, isOnceCheck: true)
        self.helpMsgCtrlTime?.setInitUI(parent: viewPosHelpMessageBrightTime)
    }
    
    @IBAction func onClick_BrightOpen(_ sender: UIButton) {
        if (isBrightDisplayHidden) {
            self.btnBrightOpen.isHidden = true
            self.brightIndicator.isHidden = false
            self.brightIndicator.startAnimating()
            DataManager.instance.m_dataController.device.m_hub.m_brightController.openUI(did: m_parent?.m_parent?.hubStatusInfo?.m_did ?? 0, callback: { () -> () in
                self.btnBrightOpen.isHidden = false
                self.setBrightControlDisplay(isHidden: false)
            }, finishedCallback: { () -> () in
                Debug.print("Device Hub Detail Bright Timer Finisehd")
                self.setBrightControlDisplay(isHidden: true)
            })
        } else {
            self.setBrightControlDisplay(isHidden: true)
        }
        
        self.setTimerCtrl()
    }
}
