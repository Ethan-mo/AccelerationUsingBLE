//
//  DeviceSensorDetailSensingViewController.swift
//  Monit
//
//  Created by 맥 on 2017. 9. 22..
//  Copyright © 2017년 맥. All rights reserved.
//

import UIKit

class DeviceSensorDetailSensingForKcViewController: DeviceSensorDetailSensingBaseViewController {
    @IBOutlet weak var imgDiaper: UIImageView!
    @IBOutlet weak var btnSensorRefresh: UIButton!
    
    @IBOutlet weak var imgBattery: UIImageView!
    @IBOutlet weak var imgOperation: UIImageView!
    @IBOutlet weak var imgMov: UIImageView!
    
    @IBOutlet weak var lblConnectingInfo: UILabel!
    @IBOutlet weak var lblBatteryTitle: UILabel!
    @IBOutlet weak var lblBattery: UILabel!
    @IBOutlet weak var lblBatteryPercent: UILabel!
    @IBOutlet weak var lblOperationTitle: UILabel!
    @IBOutlet weak var lblOperation: UILabel!
    @IBOutlet weak var lblMovTitle: UILabel!
    @IBOutlet weak var lblMov: UILabel!
    
    @IBOutlet weak var lblStatusTitle: UILabel!
    @IBOutlet weak var lblStatusContents: UILabel!
    @IBOutlet weak var lblStatusSub: UILabel!
    
    @IBOutlet weak var viewDiaperError: UIView!
    @IBOutlet weak var imgDiaperError: UIImageView!
    @IBOutlet weak var lblDectectNoti: UILabel!
    
    @IBOutlet weak var viewChagneDiaper: UIView!
    @IBOutlet weak var lblChangeDiaperSummary: UILabel!
    
    @IBOutlet weak var btnChangeDiaper: UIButton!
    @IBOutlet weak var lblSpeedSecond: UILabel!

    var speedSecond: Double = 3.0
    
    enum SUMMARY {
        case disconnect
        case nice
        case pee
        case fart
        case poo
        case warning
        case charging
        case analyzing
        case initialized
    }
    
    var todayNotiCount: Int {
        get {
            if let _info = m_parent?.m_parent?.m_detailInfo {
                return DataManager.instance.m_userInfo.deviceNoti.getTodayNotiCount(type: DEVICE_TYPE.Sensor.rawValue, did: _info.m_did)
            }
            return 0
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initPopupDiaperChange()
    }
    
    override func setUI() {
        if let _statusInfo = m_parent!.m_parent!.sensorStatusInfo {
            if (_statusInfo.diaperStatus == .normal) {
                btnSensorRefresh.isHidden = true
            } else {
                btnSensorRefresh.isHidden = false
            }
            
            setConnectingInfo()
            setDiaperStatus(diaperStatus: _statusInfo.diaperStatus)
            
            if (DataManager.instance.m_userInfo.configData.isMaster) {
                setMov(mov: _statusInfo.movement)
            } else {
                setNotiCount(notiCount: todayNotiCount)
            }
            
            setOperation(operation: _statusInfo.operation)
            setBattery(battery: _statusInfo.battery)
            setChargingOn(operation: _statusInfo.operation)
            //            animate()
            setConnect(isConnect: m_parent!.m_parent!.isConnect)
            setSummaryOn(diaperStatus: _statusInfo.diaperStatus, operation: _statusInfo.operation, isConnect: m_parent!.m_parent!.isConnect)
        }
        
        if (Config.channel == .kc) {
            setBtnChangeDiaperForKc(isEnable: m_parent!.m_parent!.isConnect, diaperStatus: m_parent!.m_parent!.sensorStatusInfo?.diaperStatus ?? .normal)
        } else {
            setBtnChangeDiaper(isEnable: m_parent!.m_parent!.isConnect)
        }
        
        lblBatteryTitle.text = "device_sensor_battery_power".localized
        lblOperationTitle.text = "device_sensor_operation".localized
        if (DataManager.instance.m_userInfo.configData.isMaster) {
            lblMovTitle.text = "device_sensor_movement".localized
        } else {
            lblMovTitle.text = "device_sensor_alarm_count".localized
        }
    }
    
    func animate()
    {
        var images = [UIImage]()
        //        let _animSeq: [String] = ["0", "5", "10", "15", "20", "15", "10", "5", "0", "-5", "-10", "-15", "-20", "-15", "-10", "-5"]
        
        let _animSeq: [String] = ["0", "5", "10", "5", "0", "-5", "-10", "-5"]
        //        let _animSeq: [String] = ["0", "15", "0","-15"]
        //        let _animSeq: [String] = ["15", "-15"]
        for item in _animSeq {
            images.append(UIImage(named: "imgDiaperMov_\(item)")!)
        }
        
        imgDiaper.animationImages = images
        imgDiaper.animationDuration = speedSecond
        imgDiaper.animationRepeatCount = 0
        imgDiaper.startAnimating()
        
        lblSpeedSecond.text = "\(speedSecond)"
    }
    
    func setConnectingInfo() {
        var _isContinue = false
        if (Config.IS_DEBUG) {
            _isContinue = true
        } else {
            if (DataManager.instance.m_userInfo.configData.isMaster) {
                _isContinue = true
            }
        }
        
        guard (_isContinue) else { return }
        
        if let _statusInfo = m_parent!.m_parent!.sensorStatusInfo {
            let _whereStr = _statusInfo.m_whereConn.description
            var _whereConn = ""
            if (_whereStr.count > 1) {
                let _id = String(_whereStr.prefix(_whereStr.count - 1))
                switch (String(_statusInfo.m_whereConn.description.suffix(1))) {
                case "0" :
                    if let _info = DataManager.instance.m_userInfo.shareMember.getAllGroupByCid(cid: Int(_id) ?? 0) {
                        _whereConn = "Phone(\(_id)) \(_info.nick)"
                    } else {
                        _whereConn = "Phone(\(_id))"
                    }
                case "2" :
                    if let _info = DataManager.instance.m_userInfo.shareDevice.getAllDeviceByDeviceIdAndType(did: Int(_id) ?? 0, type: DEVICE_TYPE.Hub.rawValue) {
                        _whereConn = "Hub(\(_id)) \(_info.name)"
                    } else {
                        _whereConn = "Hub(\(_id))"
                    }
                case "3" :
                    if let _info = DataManager.instance.m_userInfo.shareDevice.getAllDeviceByDeviceIdAndType(did: Int(_id) ?? 0, type: DEVICE_TYPE.Hub.rawValue) {
                        _whereConn = "UART(\(_id)) \(_info.name)"
                    } else {
                        _whereConn = "UART(\(_id))"
                    }
                default: break
                }
                lblConnectingInfo.text = "\(_whereConn)"
            }
        }
    }
    
    func setBtnChangeDiaper(isEnable: Bool)
    {
        btnChangeDiaper.layer.cornerRadius = 20.0
        btnChangeDiaper.layer.borderWidth = 1
        btnChangeDiaper.layer.borderColor = UIColor.clear.cgColor
        
        UI_Utility.customButtonShadow(button: btnChangeDiaper, radius: 1, offsetWidth: 1, offsetHeight: 1, color: UIColor.gray.cgColor, opacity: 0.5)
        
        btnChangeDiaper.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        btnChangeDiaper.setTitle("device_sensor_diaper_status_change_button".localized, for: .normal)
        
        if (isEnable) {
            btnChangeDiaper.isEnabled = true
            btnChangeDiaper.setTitleColor(COLOR_TYPE.purple.color, for: .normal)
        } else {
            btnChangeDiaper.isEnabled = true //false
            btnChangeDiaper.setTitleColor(COLOR_TYPE.lblWhiteGray.color, for: .normal)
        }
    }
    
    func setBtnChangeDiaperForKc(isEnable: Bool, diaperStatus: SENSOR_DIAPER_STATUS)
    {
        btnChangeDiaper.layer.cornerRadius = 20.0
        btnChangeDiaper.layer.borderWidth = 1
        btnChangeDiaper.layer.borderColor = UIColor.clear.cgColor
        
        UI_Utility.customButtonShadow(button: btnChangeDiaper, radius: 1, offsetWidth: 1, offsetHeight: 1, color: UIColor.gray.cgColor, opacity: 0.5)
        
        btnChangeDiaper.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        btnChangeDiaper.setTitleWithOutAnimation(title: "btn_diaper_sensor_dry_diaper".localized)
        
        if (isEnable) {
            btnChangeDiaper.isEnabled = true
            btnChangeDiaper.setTitleColor(COLOR_TYPE.lblWhiteGray.color, for: .normal)
            
            switch (diaperStatus) {
            case .normal:
                btnChangeDiaper.setTitleWithOutAnimation(title: "btn_diaper_sensor_dry_diaper".localized)
                btnChangeDiaper.setTitleColor(COLOR_TYPE.lblWhiteGray.color, for: .normal)
                break;
            case .pee:
                btnChangeDiaper.setTitleWithOutAnimation(title: "btn_diaper_sensor_change_diaper".localized)
                btnChangeDiaper.setTitleColor(COLOR_TYPE.red.color, for: .normal)
                break;
            case .poo:
                btnChangeDiaper.setTitleWithOutAnimation(title: "btn_diaper_sensor_change_diaper".localized)
                btnChangeDiaper.setTitleColor(COLOR_TYPE.red.color, for: .normal)
                break;
            case .hold: break
            case .maxvoc: break
            case .fart: break
            case .detectDiaperChanged,
                 .attachSensor:
                break
            }
        } else {
            btnChangeDiaper.isEnabled = true //false
            btnChangeDiaper.setTitleColor(COLOR_TYPE.lblWhiteGray.color, for: .normal)
        }
    }
    
    func setDiaperStatus(diaperStatus: SENSOR_DIAPER_STATUS) {
        viewDiaperError.isHidden = true
        btnChangeDiaper.isHidden = false
        var _pastTime = -1
        
        switch diaperStatus {
        case .normal:
            imgDiaper.image = UIImage(named: "imgDiaperLargeNormal")
        //            viewChagneDiaper.isHidden = true
        case .pee:
            imgDiaper.image = UIImage(named: "imgDiaperLargeError")
            viewDiaperError.isHidden = false
            imgDiaperError.image = UIImage(named: "imgPeeLarge")
            //            viewChagneDiaper.isHidden = false
            //            lblChangeDiaperSummary.text = "pee".localized
            _pastTime = getPastTime(type: .pee_detected)
        case .poo:
            imgDiaper.image = UIImage(named: "imgDiaperLargeError")
            viewDiaperError.isHidden = false
            imgDiaperError.image = UIImage(named: "imgPooLarge")
            //            viewChagneDiaper.isHidden = false
            //            lblChangeDiaperSummary.text = "poo".localized
            _pastTime = getPastTime(type: .poo_detected)
        case .hold:
            imgDiaper.image = UIImage(named: "imgDiaperLargeError")
            viewDiaperError.isHidden = false
            imgDiaperError.image = UIImage(named: "imgWarningLarge")
            _pastTime = getPastTime(type: .abnormal_detected)
        case .maxvoc:
            imgDiaper.image = UIImage(named: "imgDiaperLargeError")
            viewDiaperError.isHidden = false
            imgDiaperError.image = UIImage(named: "imgWarningLarge")
            _pastTime = getPastTime(type: .voc_warning)
        case .fart:
            imgDiaper.image = UIImage(named: "imgDiaperLargeError")
            viewDiaperError.isHidden = false
            imgDiaperError.image = UIImage(named: "imgFartLarge")
            _pastTime = getPastTime(type: .fart_detected)
        case .detectDiaperChanged,
             .attachSensor:
            break
        }
        
        if (_pastTime != -1) {
            lblDectectNoti.isHidden = false
            lblDectectNoti.text = String(format: "device_sensor_detect_passed_time".localized, _pastTime.description)
        } else {
            lblDectectNoti.isHidden = true
        }
    }
    
    func initPopupDiaperChange() {
        let _tmpPosY = popupChangeDiaperPos.frame.minY
        popupChangeDiaperPos.bounds = popupChangeDiaper.frame
        popupChangeDiaperPos.addSubview(popupChangeDiaper)
        popupChangeDiaperPos.frame.origin.y = _tmpPosY
        popupChangeDiaper.setInit(parent: self)
        popupChangeDiaperPos.isHidden = true
    }
    
    func getPastTime(type: DEVICE_NOTI_TYPE) -> Int {
        if let _info = DataManager.instance.m_userInfo.deviceNoti.getLastNotiByType(type: DEVICE_TYPE.Sensor.rawValue, did: m_parent!.m_parent!.m_detailInfo!.m_did, notiType: type) {
            let _nowLTime = UI_Utility.nowLocalDate(type: .full)
            let _nowUTCTime = UI_Utility.localToUTC(date: _nowLTime)
            let _nowUTCTimeDate = UI_Utility.convertStringToDate(_nowUTCTime, type: .full)
            let _infoTimeDate = UI_Utility.convertStringToDate(_info.Time, type: .yyMMdd_HHmmss)
            let userCalendar = Calendar.current
            let requestedComponent: Set<Calendar.Component> = [.minute] //  .month, .day, .hour, .minute, .second
            let timeDifference = userCalendar.dateComponents(requestedComponent, from: _infoTimeDate!, to: _nowUTCTimeDate!)
            return timeDifference.minute ?? 0
        }
        return -1
    }
    
    func setNotiCount(notiCount: Int) {
        lblMov.isHidden = false
        lblMov.text = notiCount.description
        imgMov.image = UIImage(named: "imgNotiDetail")
        lblMovTitle.textColor = COLOR_TYPE.lblGray.color
    }
    
    func setMov(mov: SENSOR_MOVEMENT) {
        lblMov.isHidden = false
        var _movText = ""
        switch mov {
        case .level_1:
            _movText = "device_sensor_movement_sleeping".localized
        case .level_2:
            _movText = "device_sensor_movement_crawling".localized
        case .level_3:
            _movText = "device_sensor_movement_running".localized
        default:
            break
        }
        
        lblMov.text = _movText
        imgMov.image = UIImage(named: "imgMoveNormalDetail")
        lblMovTitle.textColor = COLOR_TYPE.lblGray.color
    }
    
    func setOperation(operation: SENSOR_OPERATION) {
        lblOperation.isHidden = false
        lblOperationTitle.textColor = COLOR_TYPE.lblGray.color
        imgOperation.image = UIImage(named: "imgConnectReadyDetail")
        lblOperation.text = "device_sensor_operation_idle".localized
        
        switch operation {
        case .none,
             .cableNoCharge,
             .hubNoCharge:
            imgOperation.image = UIImage(named: "imgConnectSensingDetail")
            lblOperation.text = "device_sensor_operation_sensing".localized
        case .idle:
            imgOperation.image = UIImage(named: "imgConnectReadyDetail")
            lblOperation.text = "device_sensor_operation_idle".localized
        case .sensing:
            imgOperation.image = UIImage(named: "imgConnectSensingDetail")
            lblOperation.text = "device_sensor_operation_sensing".localized
        case .diaperChanged:
            imgOperation.image = UIImage(named: "imgConnectAnalyzingDetail")
            lblOperation.text = "\("device_sensor_operation_analyzing".localized)"
        case .avoidSensing:
            imgOperation.image = UIImage(named: "imgConnectAnalyzingDetail")
            lblOperation.text = "\("device_sensor_operation_analyzing".localized)!"
        case .cableCharging,
             .cableFinishedCharge,
             .cableChargeError,
             .hubCharging,
             .hubFinishedCharge,
             .hubChargeError:
            imgOperation.image = UIImage(named: "imgConnectSensingDetail")
            lblOperation.text = "device_sensor_operation_charging".localized
        default: break
        }
    }
    
    func setBattery(battery: SENSOR_BATTERY_STATUS) {
        lblBattery.isHidden = false
        lblBatteryPercent.isHidden = false
        lblBatteryTitle.textColor = COLOR_TYPE.lblGray.color
        lblBattery.textColor = COLOR_TYPE.lblDarkGray.color
        
        switch battery {
        case ._0: imgBattery.image = UIImage(named: "imgBattery0")
        case ._10: imgBattery.image = UIImage(named: "imgBattery10")
        case ._20: imgBattery.image = UIImage(named: "imgBattery20")
        case ._30: imgBattery.image = UIImage(named: "imgBattery30")
        case ._40: imgBattery.image = UIImage(named: "imgBattery40")
        case ._50: imgBattery.image = UIImage(named: "imgBattery50")
        case ._60: imgBattery.image = UIImage(named: "imgBattery60")
        case ._70: imgBattery.image = UIImage(named: "imgBattery70")
        case ._80: imgBattery.image = UIImage(named: "imgBattery80")
        case ._90: imgBattery.image = UIImage(named: "imgBattery90")
        case ._100: imgBattery.image = UIImage(named: "imgBattery100")
        case .charging: imgBattery.image = UIImage(named: "imgBatteryCharging")
        case .full: imgBattery.image = UIImage(named: "imgBatteryFull")
        }
        
        if let _battery = m_parent!.m_parent!.sensorStatusInfo?.m_battery {
            lblBattery.text = (Int(_battery / 100)).description
            
            if (_battery < 20) {
                lblBattery.textColor = COLOR_TYPE.red.color
                lblBatteryTitle.textColor = COLOR_TYPE.red.color
            }
        }
    }
    
    func setSummary(summary: SUMMARY) {
        var _isViewBattery = false
        
        switch summary {
        case .disconnect:
            lblStatusTitle.text = "device_sensor_disconnected_title".localized
            lblStatusContents.text = "device_sensor_disconnected_detail".localized
            lblStatusSub.text = ""
            lblStatusTitle.textColor = COLOR_TYPE.lblDarkGray.color
        case .nice:
            lblStatusTitle.text = Config.channel == .kc ? "device_sensor_diaper_status_no_pee_or_poo".localized : "device_sensor_diaper_status_normal_detail".localized
            lblStatusContents.text = ""
            lblStatusSub.text = ""
            lblStatusTitle.textColor = COLOR_TYPE.purple.color
            _isViewBattery = true
        case .pee:
            lblStatusTitle.text = "device_sensor_diaper_status_pee_detail".localized
            lblStatusContents.text = "device_sensor_diaper_status_change".localized
            lblStatusSub.text = "device_sensor_diaper_status_change_detail".localized
            lblStatusTitle.textColor = COLOR_TYPE.red.color
        case .fart:
            lblStatusTitle.text = "device_sensor_diaper_status_fart_detail".localized
            lblStatusContents.text = ""
            lblStatusSub.text = ""
            lblStatusTitle.textColor = COLOR_TYPE.red.color
        case .poo:
            lblStatusTitle.text = "device_sensor_diaper_status_poo_detail".localized
            lblStatusContents.text = "device_sensor_diaper_status_change".localized
            lblStatusSub.text = "device_sensor_diaper_status_change_detail".localized
            lblStatusTitle.textColor = COLOR_TYPE.red.color
        case .warning:
            lblStatusTitle.text = "device_sensor_diaper_status_abnormal_detail".localized
            lblStatusContents.text = "device_sensor_diaper_status_change".localized
            lblStatusSub.text = ""
            lblStatusTitle.textColor = COLOR_TYPE.red.color
            _isViewBattery = true
        case .charging:
            lblStatusTitle.text = ""
            lblStatusContents.text = ""
            lblStatusSub.text = ""
        case .analyzing:
            lblStatusContents.text = "device_sensor_diaper_status_analyzing".localized
        case .initialized:
            lblStatusTitle.text = ""
            lblStatusContents.text = "toast_diaper_status_initialized".localized
            lblStatusSub.text = ""
        }
        
        if (_isViewBattery) {
            lblStatusSub.text = ""
            
            if let _statusInfo = m_parent!.m_parent!.sensorStatusInfo {
                if (_statusInfo.battery == .charging) {
                    lblStatusSub.text = ""
                } else if (_statusInfo.battery == .full) {
                    lblStatusSub.text = ""
                } else {
                    if (_statusInfo.m_battery <= 10) {
                        lblStatusSub.text = ""
                    }
                }
            }
        }
    }
    
    func setSummaryOn( diaperStatus: SENSOR_DIAPER_STATUS, operation: SENSOR_OPERATION, isConnect: Bool) {
        switch diaperStatus {
        case .normal:
            setSummary(summary: .nice)
        case .pee:
            setSummary(summary: .pee)
        case .poo:
            setSummary(summary: .poo)
        case .hold:
            setSummary(summary: .warning)
        case .maxvoc:
            setSummary(summary: .warning)
        case .fart:
            setSummary(summary: .fart)
        case .detectDiaperChanged,
             .attachSensor:
            break
        }
        
        switch operation {
        case .cableCharging,
             .cableFinishedCharge,
             .hubCharging,
             .hubFinishedCharge:
            setSummary(summary: .charging)
        case .diaperChanged,
             .avoidSensing:
            setSummary(summary: .analyzing)
        default: break
        }
        
        if (!isConnect) {
            setSummary(summary: .disconnect)
        }
    }
    
    func setChargingOn(operation: SENSOR_OPERATION) {
        switch operation {
        case .cableCharging,
             .cableFinishedCharge,
             .cableChargeError,
             .hubCharging,
             .hubFinishedCharge,
             .hubChargeError:
            // diaper info
            imgDiaper.image = UIImage(named: "imgDiaperLargeDisable")
            viewDiaperError.isHidden = true
        default: break
        }
    }
    
    func setConnect(isConnect: Bool) {
        if (!isConnect) {
            lblBattery.isHidden = true
            lblBatteryPercent.isHidden = true
            lblOperation.isHidden = true
            lblMov.isHidden = true
            btnSensorRefresh.isHidden = true
            
            lblBatteryTitle.textColor = COLOR_TYPE.lblWhiteGray.color
            lblOperationTitle.textColor = COLOR_TYPE.lblWhiteGray.color
            lblMovTitle.textColor = COLOR_TYPE.lblWhiteGray.color
            
            imgDiaper.image = UIImage(named: "imgDiaperLargeDisable")
            viewDiaperError.isHidden = true
            imgOperation.image = UIImage(named: "imgConnectDisableDetail")
            if (DataManager.instance.m_userInfo.configData.isMaster) {
                imgMov.image = UIImage(named: "imgMoveDisableDetail")
            } else {
                imgMov.image = UIImage(named: "imgNotiDisableDetail")
            }
            imgBattery.image = UIImage(named: "imgBatteryDisconnect")
            
            //            btnChangeDiaper.isHidden = true
            lblDectectNoti.isHidden = true
        }
    }
    
    @IBAction func onClick_chagneDiaper(_ sender: UIButton) {
        Debug.print("chagneDiaper")
        popupChangeDiaper.setInit(parent: self)
        self.m_parent?.m_parent?.view.addSubview(popupChangeDiaper)
        
        //        let send = Send_SetDiaperChanged()
        //        send.aid = DataManager.instance.m_userInfo.account_id
        //        send.token = DataManager.instance.m_userInfo.token
        //        send.type = DEVICE_TYPE.Sensor.rawValue
        //        send.did = m_parent!.m_parent!.m_detailInfo!.m_did
        //        send.enc = m_parent!.m_parent!.userInfo!.enc
        //        NetworkManager.instance.Request(send) { (json) -> () in
        //            let receive = Receive_SetDiaperChanged(json)
        //            switch receive.ecd {
        //            case .success:
        //                DataManager.instance.m_dataController.device.m_sensor.initDiaper(did: self.m_parent!.m_parent!.m_detailInfo!.m_did)
        //                self.m_parent!.m_parent!.reloadInfo()
        //                _ = PopupManager.instance.onlyContents(contentsKey: "notification_diaper_status_diaper_changed_detail", confirmType: .ok)
        //                // after noti item
        //                DataManager.instance.m_dataController.deviceNoti.updateForDetailView()
        //                NotificationManager.instance.playSound()
        //                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        //                break
        //            default:
        //                Debug.print("[ERROR] invaild errcod", event: .error)
        //            }
        //        }
    }
    
    override func btnChangeDiaperAnimation() {
        isUpdateView = false
        setDiaperStatus(diaperStatus: .normal)
        setSummaryOn(diaperStatus: .normal, operation: .none, isConnect: m_parent!.m_parent!.isConnect)
        
        btnChangeDiaper.setTitleWithOutAnimation(title: "btn_diaper_sensor_diaper_changed".localized)
        btnChangeDiaper.setTitleColor(COLOR_TYPE.green.color, for: .normal)
        imgDiaper.image = UIImage(named: "imgDiaperLargeNormal")
        
        Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(btnChangeDiaperAnimationFinished), userInfo: nil, repeats: false)
    }
    
    @objc func btnChangeDiaperAnimationFinished() {
        isUpdateView = true
        btnChangeDiaper.setTitleWithOutAnimation(title: "btn_diaper_sensor_dry_diaper".localized)
        btnChangeDiaper.setTitleColor(COLOR_TYPE.lblWhiteGray.color, for: .normal)
        DataManager.instance.m_dataController.deviceNoti.updateForDetailView()
    }
    
    @IBAction func onClick_refresh(_ sender: UIButton) {
        Debug.print("sensor refresh")
        let send = Send_InitDiaperStatus()
        send.aid = DataManager.instance.m_userInfo.account_id
        send.token = DataManager.instance.m_userInfo.token
        send.type = DEVICE_TYPE.Sensor.rawValue
        send.did = m_parent!.m_parent!.m_detailInfo!.m_did
        send.enc = m_parent!.m_parent!.userInfo!.enc
        NetworkManager.instance.Request(send) { (json) -> () in
            let receive = Receive_InitDiaperStatus(json)
            switch receive.ecd {
            case .success:
                DataManager.instance.m_dataController.device.m_sensor.initDiaper(did: self.m_parent!.m_parent!.m_detailInfo!.m_did)
                self.setDiaperStatus(diaperStatus: self.m_parent!.m_parent!.sensorStatusInfo?.diaperStatus ?? .normal)
                self.setSummary(summary: .initialized)
                break
            default:
                Debug.print("[ERROR] invaild errcod", event: .error)
            }
        }
    }
    
    @IBAction func onClick_speedUp(_ sender: UIButton) {
        speedSecond -= 0.5
        setUI()
    }
    
    @IBAction func onClick_speedDown(_ sender: UIButton) {
        speedSecond += 0.5
        setUI()
    }
}
