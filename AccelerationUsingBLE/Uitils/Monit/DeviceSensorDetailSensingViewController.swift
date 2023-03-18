//
//  DeviceSensorDetailSensingViewController.swift
//  Monit
//
//  Created by 맥 on 2017. 9. 22..
//  Copyright © 2017년 맥. All rights reserved.
//

import UIKit

class DeviceSensorDetailSensingViewController: DeviceSensorDetailSensingBaseViewController {
    @IBOutlet weak var lblConnectingInfo: UILabel!
    
    @IBOutlet weak var imgDiaperStatus: UIImageView!
    @IBOutlet weak var lblDiaperStatus: UILabel?
    
    /// Monitoring
    @IBOutlet weak var lblMonitoringTitle: UILabel!
    @IBOutlet weak var viewMonitoring: UIView!
    // Sleep
    @IBOutlet weak var viewSleepMode: UIView!
    @IBOutlet weak var btnSleepMode: UIButton!
    @IBOutlet weak var lblSleepModeContents: UILabel!
    @IBOutlet weak var swSleepMode: UISwitch!
    // DiaperStatus
    @IBOutlet weak var btnDiaperScore: UIButton!
    @IBOutlet weak var lblDiaperScoreTitle: UILabel!
    @IBOutlet weak var lblDiaperScoreContents: UILabel!
    @IBOutlet weak var btnVocAvg: UIButton!
    @IBOutlet weak var lblVocAvgTitle: UILabel!
    @IBOutlet weak var lblVocAvgContents: UILabel!
    @IBOutlet weak var btnMov: UIButton!
    @IBOutlet weak var lblMovTitle: UILabel!
    @IBOutlet weak var lblMovContents: UILabel!
    @IBOutlet weak var btnChangeDiaper: UIButton!
    @IBOutlet weak var btnChangeDiaperContents: UIButton!
    @IBOutlet weak var viewDiaperStatusLine1: UIView!
    @IBOutlet weak var viewDiaperStatusLine2: UIView!
    @IBOutlet weak var btnRefresh: UIButton!
    
    /// Status
    @IBOutlet weak var viewConnectStatus: UIView!
    @IBOutlet weak var lblStatusTitle: UILabel!
    @IBOutlet weak var btnOperation: UIButton!
    @IBOutlet weak var lblOperationStatus: UILabel!
    @IBOutlet weak var btnBattery: UIButton!
    @IBOutlet weak var lblBattery: UILabel!
    
    @IBOutlet var popupSleepMode: DeviceSensorDetailSensingView_SleepMode!
    @IBOutlet weak var popupSleepModePos: UIView!
    
    // V1
    var SleepMode: DeviceNotiInfo? {
        get {
            return DataManager.instance.m_userInfo.deviceNoti.getLastNotiByType(type: DEVICE_TYPE.Sensor.rawValue, did: m_parent!.m_parent!.m_detailInfo!.m_did, notiType: .sleep_mode, isOrderbyId: true)
        }
    }
    
    var isAutoMoveDetected: Bool {
        get {
            if (DataManager.instance.m_userInfo.shareDevice.isAlarmStatusSpecific(did: m_parent!.m_parent!.m_detailInfo!.m_did, type: DEVICE_TYPE.Sensor.rawValue, almType: .auto_move_detected) ?? false) {
                if let _sensorStatus = DataManager.instance.m_userInfo.deviceStatus.m_sensorStatus.getInfoByDeviceId(did: m_parent!.m_parent!.m_detailInfo!.m_did) {
                    if (_sensorStatus.isSleep) {
                        return true
                    } else {
                        return false
                    }
                }
            }
            
            return false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UI_Utility.customViewBorder(view: viewMonitoring, radius: 20, width: 1, color: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0))
        UI_Utility.customViewBorder(view: viewConnectStatus, radius: 20, width: 1, color: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0))
        UI_Utility.customViewShadow(view: viewMonitoring, radius: 20, offsetWidth: 0.1, offsetHeight: 0.1, color: #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1), opacity: 0.2)
        UI_Utility.customViewShadow(view: viewConnectStatus, radius: 20, offsetWidth: 0.1, offsetHeight: 0.1, color: #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1), opacity: 0.2)
        
        initPopupDiaperChange()
//        initPopupSleepMode()
        initMonitoringInfo()
    }
    
    override func setUI() {
        if let _statusInfo = m_parent!.m_parent!.sensorStatusInfo {
            setConnectingInfo()
            
            /// monitoring
            setMonitoringSet()
            setMonitoringSleep()
            setDiaperScore(diaperScore: _statusInfo.diaperScore)
            setVocAvg(vocAvg: _statusInfo.vocAvg)
            setMov(mov: _statusInfo.movement)
            setDiaperStatusAnimation(mov: _statusInfo.movement)
            setChangeDiaperContetns()

            /// status
            setOperation(operation: _statusInfo.operation)
            setBattery(battery: _statusInfo.battery)

            setConnect(isConnect: m_parent!.m_parent!.isConnect)
        } else {
            setConnect(isConnect: false)
        }
        
        initAutoMoveDetected()
    }
 
    func initMonitoringInfo() {
        lblDiaperStatus?.font = UIFont.boldSystemFont(ofSize: 16)
        lblSleepModeContents.font = UIFont.boldSystemFont(ofSize: 16)
        lblOperationStatus.font = UIFont.boldSystemFont(ofSize: 16)

        lblMonitoringTitle.text = "device_sensor_baby_monitoring_information".localized
        btnDiaperScore.imageView?.contentMode = .scaleAspectFit
        lblDiaperScoreTitle.text = "device_sensor_diaper_status_title".localized
        btnVocAvg.imageView?.contentMode = .scaleAspectFit
        lblVocAvgTitle.text = "device_sensor_voc_status".localized
        btnMov.imageView?.contentMode = .scaleAspectFit
        lblMovTitle.text = "device_sensor_activity_status".localized
        lblStatusTitle.text = "device_sensor_status".localized
        
        setBtnChangeDiaper()
    }
    
    func setDiaperStatusAnimation(mov: SENSOR_MOVEMENT) {
        imgDiaperStatus.isHidden = false
        
        var _isEnabled = false
        (_isEnabled, _) = getSleepModeInfo()
        
        if (isAutoMoveDetected) {
            _isEnabled = true
        }
        
        var images = [UIImage]()
        if (_isEnabled) {
            images.append(UIImage(named: "imgAniSleepMode_1")!)
            images.append(UIImage(named: "imgAniSleepMode_2")!)
            images.append(UIImage(named: "imgAniSleepMode_3")!)
            images.append(UIImage(named: "imgAniSleepMode_4")!)
            imgDiaperStatus.animationDuration = 4
        } else {
           switch mov {
            case .none:
                images.append(UIImage(named: "imgAniMoveLevel_0_1")!)
                images.append(UIImage(named: "imgAniMoveLevel_0_2")!)
            case .level_1:
                images.append(UIImage(named: "imgAniMoveLevel_1_1")!)
                images.append(UIImage(named: "imgAniMoveLevel_1_2")!)
            case .level_2:
                images.append(UIImage(named: "imgAniMoveLevel_2_1")!)
                images.append(UIImage(named: "imgAniMoveLevel_2_2")!)
            case .level_3:
                images.append(UIImage(named: "imgAniMoveLevel_3_1")!)
                images.append(UIImage(named: "imgAniMoveLevel_3_2")!)
            }
            imgDiaperStatus.animationDuration = 2
        }
        
        imgDiaperStatus.animationImages = images
        imgDiaperStatus.animationRepeatCount = 0
        imgDiaperStatus.startAnimating()
    }
    
//    func setDiaperStatus(diaperScore: SENSOR_DIAPER_SCORE) {
//        switch diaperScore {
//        case .good:
//            lblDiaperStatus?.text = "기저귀가 쾌적해요~"
//            lblDiaperStatus?.textColor = COLOR_TYPE.lblDarkGray.color
//        case .bad:
//            lblDiaperStatus?.text = "기저귀가 조금 오염됐어요!"
//            lblDiaperStatus?.textColor = COLOR_TYPE.lblDarkGray.color
//        case .need_changed:
//            lblDiaperStatus?.text = "기저귀를 확인해주세요"
//            lblDiaperStatus?.textColor = COLOR_TYPE.lblDarkGray.color
//        }
//    }
    
    func setMonitoringSet() {
        viewDiaperStatusLine1.backgroundColor = COLOR_TYPE.lblDarkGray.color
        viewDiaperStatusLine2.backgroundColor = COLOR_TYPE.lblDarkGray.color
    }
    
    func setMonitoringSleep() {
        var _isEnabled = false
        var _timeInfo = ""
        (_isEnabled, _timeInfo) = getSleepModeInfo()
        setMonitoringSleepUI(isSleepMode: _isEnabled, timeInfo: _timeInfo)
    }
    
    func setMonitoringSleepUI(isSleepMode: Bool, timeInfo: String) {
        btnSleepMode.setImage(UIImage(named: "imgSleepNormalMain"), for: .normal)
        lblSleepModeContents.isHidden = false
        lblSleepModeContents.text = "device_sensor_activity_sensing_mode".localized
        lblSleepModeContents.textColor = COLOR_TYPE.lblDarkGray.color
        swSleepMode.isEnabled = true

        swSleepMode.isOn = isSleepMode
        if (isSleepMode) {
            lblSleepModeContents.text = "\("device_sensor_sleeping_sensing_mode".localized)\n\(timeInfo)"
        } else {
            lblSleepModeContents.text = "device_sensor_sleeping_sensing_mode".localized
        }
    }
    
    func setChangeDiaperContetns() {
        var _isEnabled = false
        var _timeInfo = ""
        (_isEnabled, _timeInfo) = getDiaperChangedInfo()
        setChangeDiaperContetnsUI(isEnable: _isEnabled, timeInfo: _timeInfo)
    }
    
    func setChangeDiaperContetnsUI(isEnable: Bool, timeInfo: String) {
        if (isEnable) {
            btnChangeDiaperContents.setTitleWithOutAnimation(title: "\(timeInfo)")
        } else {
            btnChangeDiaperContents.setTitleWithOutAnimation(title: "device_sensor_diaper_never_changed".localized)
        }
    }
    
    func setDiaperScore(diaperScore: SENSOR_DIAPER_SCORE) {
        lblDiaperScoreContents.isHidden = false
        
        switch diaperScore {
        case .good:
            btnDiaperScore.setImage(UIImage(named: "imgDiaperNormalDetail_Brown"), for: .normal)
            lblDiaperScoreTitle.textColor = COLOR_TYPE.lblDarkGray.color
            lblDiaperScoreContents.text = "device_sensor_diaper_status_normal".localized
            lblDiaperScoreContents.textColor = COLOR_TYPE.lblDarkGray.color
        case .bad:
            btnDiaperScore.setImage(UIImage(named: "imgDiaperWarningDetail"), for: .normal)
            lblDiaperScoreTitle.textColor = COLOR_TYPE._orange_244_167_119.color
            lblDiaperScoreContents.text = "device_sensor_diaper_status_soiled".localized
            lblDiaperScoreContents.textColor = COLOR_TYPE._orange_244_167_119.color
        case .need_changed:
            btnDiaperScore.setImage(UIImage(named: "imgDiaperErrorDetail"), for: .normal)
            lblDiaperScoreTitle.textColor = COLOR_TYPE.red.color
            lblDiaperScoreContents.text = "device_sensor_diaper_status_check_diaper".localized
            lblDiaperScoreContents.textColor = COLOR_TYPE.red.color
        }
    }
    
    func setVocAvg(vocAvg: SENSOR_VOC_AVG) {
        lblVocAvgContents.isHidden = false
        
        switch vocAvg {
        case .none:
            btnVocAvg.setImage(UIImage(named: "imgFartNormalDetail_Brown"), for: .normal)
            lblVocAvgTitle.textColor = COLOR_TYPE.lblDarkGray.color
            lblVocAvgContents.text = "device_environment_voc_avg_level0".localized
            lblVocAvgContents.textColor = COLOR_TYPE.lblDarkGray.color
        case .level_1:
            btnVocAvg.setImage(UIImage(named: "imgFartWarningDetail"), for: .normal)
            lblVocAvgTitle.textColor = COLOR_TYPE._orange_244_167_119.color
            lblVocAvgContents.text = "device_environment_voc_avg_level1".localized
            lblVocAvgContents.textColor = COLOR_TYPE._orange_244_167_119.color
        case .level_2:
            btnVocAvg.setImage(UIImage(named: "imgFartWarningDetail"), for: .normal)
            lblVocAvgTitle.textColor = COLOR_TYPE._orange_244_167_119.color
            lblVocAvgContents.text = "device_environment_voc_avg_level2".localized
            lblVocAvgContents.textColor = COLOR_TYPE._orange_244_167_119.color
        case .level_3:
            btnVocAvg.setImage(UIImage(named: "imgFartErrorDetail"), for: .normal)
            lblVocAvgTitle.textColor = COLOR_TYPE.red.color
            lblVocAvgContents.text = "device_environment_voc_avg_level3".localized
            lblVocAvgContents.textColor = COLOR_TYPE.red.color
        case .level_4:
            btnVocAvg.setImage(UIImage(named: "imgFartBlackDetail"), for: .normal)
            lblVocAvgTitle.textColor = COLOR_TYPE.lblDarkGray.color
            lblVocAvgContents.text = "device_environment_voc_avg_level4".localized
            lblVocAvgContents.textColor = COLOR_TYPE.lblDarkGray.color
        }
    }
    
    func setMov(mov: SENSOR_MOVEMENT) {
        lblMovContents.isHidden = false
        
        switch mov {
        case .none:
            btnMov.setImage(UIImage(named: "imgMoveNormalDetail"), for: .normal)
            lblMovTitle.textColor = COLOR_TYPE.lblGray.color
            lblMovContents.text = "movement_not_moving".localized
            lblMovContents.textColor = COLOR_TYPE.lblDarkGray.color
        case .level_1:
            btnMov.setImage(UIImage(named: "imgMoveNormalDetail"), for: .normal)
            lblMovTitle.textColor = COLOR_TYPE.lblGray.color
            lblMovContents.text = "device_sensor_movement_sleeping".localized
            lblMovContents.textColor = COLOR_TYPE.lblDarkGray.color
        case .level_2:
            btnMov.setImage(UIImage(named: "imgMoveNormalDetail"), for: .normal)
            lblMovTitle.textColor = COLOR_TYPE.lblGray.color
            lblMovContents.text = "device_sensor_movement_crawling".localized
            lblMovContents.textColor = COLOR_TYPE.lblDarkGray.color
        case .level_3:
            btnMov.setImage(UIImage(named: "imgMoveNormalDetail"), for: .normal)
            lblMovTitle.textColor = COLOR_TYPE.lblGray.color
            lblMovContents.text = "device_sensor_movement_running".localized
            lblMovContents.textColor = COLOR_TYPE.lblDarkGray.color
        }
    }
    
    func setBtnChangeDiaper()
    {
        btnChangeDiaper.layer.cornerRadius = 20.0
        btnChangeDiaper.layer.borderWidth = 1
        btnChangeDiaper.layer.borderColor = UIColor.clear.cgColor
        
        UI_Utility.customButtonShadow(button: btnChangeDiaper, radius: 1, offsetWidth: 1, offsetHeight: 1, color: UIColor.gray.cgColor, opacity: 0.5)
        
        btnChangeDiaper.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        btnChangeDiaper.setTitle("device_sensor_diaper_status_change_button".localized, for: .normal)
        
        btnChangeDiaper.isEnabled = true
        btnChangeDiaper.setTitleColor(COLOR_TYPE._brown_174_140_107.color, for: .normal)
    }
    
    func initPopupDiaperChange() {
        let _tmpPosY = popupChangeDiaperPos.frame.minY
        popupChangeDiaperPos.bounds = popupChangeDiaper.frame
        popupChangeDiaperPos.addSubview(popupChangeDiaper)
        popupChangeDiaperPos.frame.origin.y = _tmpPosY
        popupChangeDiaper.setInit(parent: self)
        popupChangeDiaperPos.isHidden = true
    }
    
    func initAutoMoveDetected()
    {
        viewSleepMode.isHidden = false
        
        if (DataManager.instance.m_userInfo.shareDevice.isAlarmStatusSpecific(did: m_parent!.m_parent!.m_detailInfo!.m_did, type: DEVICE_TYPE.Sensor.rawValue, almType: .auto_move_detected) ?? false) {
            viewSleepMode.isHidden = true
            return
        }
    }
    
    // V1
//    func initPopupSleepMode() {
//        let _tmpPosY = popupSleepModePos.frame.minY
//        popupSleepModePos.bounds = popupSleepMode.frame
//        popupSleepModePos.addSubview(popupSleepMode)
//        popupSleepModePos.frame.origin.y = _tmpPosY
//        popupSleepMode.setInit(parent: self)
//        popupSleepModePos.isHidden = true
//    }

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
    
    // SLEEP MODE CHECK
    func getSleepModeInfo() -> (Bool, String) {
        // V2
        if (SleepModeTimer.isSleepTimer) {
            let _nowLTime = UI_Utility.nowLocalDate(type: .full)
            let _nowUTCTime = UI_Utility.localToUTC(date: _nowLTime)
            let _nowUTCTimeDate = UI_Utility.convertStringToDate(_nowUTCTime, type: .full)
            let _infoTimeDate = UI_Utility.convertStringToDate(SleepModeTimer.recordStartSleepModeTime, type: .yyMMdd_HHmmss)
            let _diff = UI_Utility.getTimeDiff(fromDate: _infoTimeDate!, toDate: _nowUTCTimeDate!)
            var _retValue = ""
            if (_diff.hour ?? 0 > 0) {
                _retValue = "\("notification_sleep_start".localized) (\(_diff.hour ?? 0)\("time_hour_short".localized)\(_diff.minute ?? 0 % 60)\("time_minute_short".localized))"
            } else {
                _retValue = "\("notification_sleep_start".localized) (\(_diff.minute ?? 0)\("time_minute_short".localized))"
            }
            return (true, _retValue)
        } else {
            return (false, "")
        }

        // V1
//        if let _info = SleepMode {
//            if (_info.Extra == "" || _info.Extra == "-") {
//                let _nowLTime = UI_Utility.nowLocalDate(type: .full)
//                let _nowUTCTime = UI_Utility.localToUTC(date: _nowLTime)
//                let _nowUTCTimeDate = UI_Utility.convertStringToDate(_nowUTCTime, type: .full)
//                let _infoTimeDate = UI_Utility.convertStringToDate(_info.Time, type: .yyMMdd_HHmmss)
//                let _diff = UI_Utility.getTimeDiff(fromDate: _infoTimeDate!, toDate: _nowUTCTimeDate!)
//                var _retValue = ""
//                if (_diff.hour ?? 0 > 0) {
//                    _retValue = String(format: "device_sensor_the_latest_time_diaper_changed".localized, "\(_diff.hour ?? 0):\(_diff.minute ?? 0 % 60)")
//                } else {
//                    _retValue = String(format: "device_sensor_the_latest_time_diaper_changed".localized, "\(_diff.minute ?? 0)")
//                }
//                return (true, _retValue)
//            } else {
//                return (false, "")
//            }
//        }
//        return (false, "")
    }
    
    func getDiaperChangedInfo() -> (Bool, String) {
        if let _info = DataManager.instance.m_userInfo.deviceNoti.getLastNotiByType(type: DEVICE_TYPE.Sensor.rawValue, did: m_parent!.m_parent!.m_detailInfo!.m_did, notiType: .diaper_changed) {
            let _nowLTime = UI_Utility.nowLocalDate(type: .full)
            let _nowUTCTime = UI_Utility.localToUTC(date: _nowLTime)
            let _nowUTCTimeDate = UI_Utility.convertStringToDate(_nowUTCTime, type: .full)
            let _infoTimeDate = UI_Utility.convertStringToDate(_info.Time, type: .yyMMdd_HHmmss)
            let _diff = UI_Utility.getTimeDiff(fromDate: _infoTimeDate!, toDate: _nowUTCTimeDate!)
            var _retValue = ""
            if (_diff.hour ?? 0 > 0) {
                _retValue = String(format: "device_sensor_the_latest_time_diaper_changed".localized, "\(_diff.hour ?? 0):\(_diff.minute ?? 0 % 60)")
            } else {
                _retValue = String(format: "device_sensor_the_latest_time_diaper_changed".localized, "\(_diff.minute ?? 0)")
            }
            return (true, _retValue)
        }
        return (false, "")
    }
    
    func setOperation(operation: SENSOR_OPERATION) {
        lblOperationStatus.isHidden = false
        lblOperationStatus.textColor = COLOR_TYPE.lblDarkGray.color
        btnOperation.setImage(UIImage(named: "imgConnectReadyDetail"), for: .normal)
        lblOperationStatus.text = "device_sensor_operation_idle".localized
        
        switch operation {
        case .none,
             .cableNoCharge,
             .hubNoCharge:
            btnOperation.setImage(UIImage(named: "imgConnectSensingDetail"), for: .normal)
            lblOperationStatus.text = "device_sensor_operation_sensing".localized
            lblOperationStatus.textColor = COLOR_TYPE.lblDarkGray.color
        case .idle:
            btnOperation.setImage(UIImage(named: "imgConnectReadyDetail"), for: .normal)
            lblOperationStatus.text = "device_sensor_diaper_status_idle_detail".localized
            lblOperationStatus.textColor = COLOR_TYPE.lblDarkGray.color
        case .sensing:
            btnOperation.setImage(UIImage(named: "imgConnectSensingDetail"), for: .normal)
            lblOperationStatus.text = "device_sensor_operation_sensing".localized
            lblOperationStatus.textColor = COLOR_TYPE.lblDarkGray.color
        case .diaperChanged:
            btnOperation.setImage(UIImage(named: "imgConnectAnalyzingDetail"), for: .normal)
            lblOperationStatus.text = "\("device_sensor_operation_analyzing".localized)"
            lblOperationStatus.textColor = COLOR_TYPE.lblDarkGray.color
        case .avoidSensing:
            btnOperation.setImage(UIImage(named: "imgConnectAnalyzingDetail"), for: .normal)
            lblOperationStatus.text = "\("device_sensor_operation_analyzing".localized)!"
            lblOperationStatus.textColor = COLOR_TYPE.lblDarkGray.color
        case .cableCharging,
             .cableFinishedCharge,
             .cableChargeError,
             .hubCharging,
             .hubFinishedCharge,
             .hubChargeError:
            btnOperation.setImage(UIImage(named: "imgConnectSensingDetail"), for: .normal)
            lblOperationStatus.text = "device_sensor_operation_charging".localized
            lblOperationStatus.textColor = COLOR_TYPE.lblDarkGray.color
        default: break
        }
    }
    
    func setBattery(battery: SENSOR_BATTERY_STATUS) {
        btnBattery.isHidden = false
        lblBattery.isHidden = false
        lblBattery.textColor = COLOR_TYPE.purple.color

        switch battery {
        case ._0: btnBattery.setImage(UIImage(named: "imgBatteryV2_0"), for: .normal)
        case ._10: btnBattery.setImage(UIImage(named: "imgBatteryV2_10"), for: .normal)
        case ._20: btnBattery.setImage(UIImage(named: "imgBatteryV2_20"), for: .normal)
        case ._30: btnBattery.setImage(UIImage(named: "imgBatteryV2_30"), for: .normal)
        case ._40: btnBattery.setImage(UIImage(named: "imgBatteryV2_40"), for: .normal)
        case ._50: btnBattery.setImage(UIImage(named: "imgBatteryV2_50"), for: .normal)
        case ._60: btnBattery.setImage(UIImage(named: "imgBatteryV2_60"), for: .normal)
        case ._70: btnBattery.setImage(UIImage(named: "imgBatteryV2_70"), for: .normal)
        case ._80: btnBattery.setImage(UIImage(named: "imgBatteryV2_80"), for: .normal)
        case ._90: btnBattery.setImage(UIImage(named: "imgBatteryV2_90"), for: .normal)
        case ._100: btnBattery.setImage(UIImage(named: "imgBatteryV2_100"), for: .normal)
        case .charging: btnBattery.setImage(UIImage(named: "imgBatteryV2_Charging"), for: .normal)
        case .full: btnBattery.setImage(UIImage(named: "imgBatteryV2_Full"), for: .normal)
        }
        
        if let _battery = m_parent!.m_parent!.sensorStatusInfo?.m_battery {
            if (Int(_battery / 100) == 100 ) {
                lblBattery.text = "device_sensor_operation_fully_charged".localized
            } else {
                lblBattery.text = "\((Int(_battery / 100)).description)%"
            }
            
            if (_battery < 20) {
                lblBattery.textColor = COLOR_TYPE.red.color
            }
        }
    }
    
    func setConnect(isConnect: Bool) {
        if (!isConnect) {
            lblDiaperStatus?.text = "device_sensor_baby_talk_disconnected".localized
            
//            btnSleepMode.setImage(UIImage(named: "imgSleepDisableMain"), for: .normal)
//            lblSleepModeContents.isHidden = true
//            swSleepMode.isEnabled = false
//            swSleepMode.isOn = false
            
            imgDiaperStatus.isHidden = true
            viewDiaperStatusLine1.backgroundColor = COLOR_TYPE.lblWhiteGray.color
            viewDiaperStatusLine2.backgroundColor = COLOR_TYPE.lblWhiteGray.color
            btnDiaperScore.setImage(UIImage(named: "imgDiaperDisableDetail"), for: .normal)
            lblDiaperScoreTitle.textColor = COLOR_TYPE.lblWhiteGray.color
            lblDiaperScoreContents.isHidden = true
            btnVocAvg.setImage(UIImage(named: "imgFartDisableDetail"), for: .normal)
            lblVocAvgTitle.textColor = COLOR_TYPE.lblWhiteGray.color
            lblVocAvgContents.isHidden = true
            btnMov.setImage(UIImage(named: "imgMoveDisableDetail"), for: .normal)
            lblMovTitle.textColor = COLOR_TYPE.lblWhiteGray.color
            lblMovContents.isHidden = true
            
            btnOperation.setImage(UIImage(named: "imgConnectDisableDetail"), for: .normal)
            lblOperationStatus.text = "device_sensor_baby_talk_disconnected".localized
            lblOperationStatus.textColor = COLOR_TYPE.lblGray.color
            
            btnBattery.isHidden = true
            lblBattery.isHidden = true
        }
    }
    
    // V1
    func popupSleepMode(isHidden: Bool) {
        popupSleepModePos.isHidden = isHidden
    }
    
    @IBAction func onClick_chagneDiaper(_ sender: UIButton) {
        popupChangeDiaper.setInit(parent: self)
        self.m_parent?.m_parent?.view.addSubview(popupChangeDiaper)
    }
    
    @IBAction func onClick_changeDiaperNoti(_ sender: UIButton) {
        m_parent?.m_parent?.noti()
    }
    
    @IBAction func sleepMode_onclick(_ sender: UISwitch) {
        let (_isEnabled, _) = getSleepModeInfo()
        if (_isEnabled) {
            SleepModeTimer.stopSleepMode()
            
            let send = Send_SetSleepMode()
            send.aid = DataManager.instance.m_userInfo.account_id
            send.token = DataManager.instance.m_userInfo.token
            send.did = m_parent!.m_parent!.m_detailInfo!.m_did
            send.enc = m_parent!.m_parent!.userInfo!.enc
            if (SleepModeTimer.sleepModeType != .none) {
                send.sleep_type = SleepModeTimer.sleepModeType.rawValue
            }
            send.time = SleepModeTimer.recordStartSleepModeTime
            send.finish_time = SleepModeTimer.recordStopSleepModeTime
            NetworkManager.instance.Request(send) { (json) -> () in
                let receive = Receive_SetSleepMode(json)
                switch receive.ecd {
                case .success:
                    DataManager.instance.m_dataController.deviceNoti.updateForDetailView()
                    break
                default:
                    Debug.print("[ERROR] invaild errcod", event: .error)
                }
            }
            
            setMonitoringSleepUI(isSleepMode: false, timeInfo: "")
        } else {
            SleepModeTimer.startSleepMode()
            setMonitoringSleepUI(isSleepMode: true, timeInfo: String(format: "device_sensor_detect_passed_time".localized, "0"))
        }
        
        // V1
//        popupSleepMode.setInit(parent: self)
//        popupSleepMode(isHidden: false)
    }
    
    @IBAction func onClick_SleepModeHelp(_ sender: UIButton) {
        _ = PopupManager.instance.withTitleCustom(title: "guide_sensor_sleep_mode_title".localized, contents: "guide_sensor_sleep_mode_contents".localized, confirmType: .ok)
    }
    
    @IBAction func onClick_DiaperScoreHelp(_ sender: UIButton) {
        _ = PopupManager.instance.withTitleCustom(title: "guide_sensor_diaper_status_title".localized, contents: "guide_sensor_diaper_status_contents".localized, confirmType: .ok)
    }
    
    @IBAction func onClick_VocAvgHelp(_ sender: UIButton) {
        _ = PopupManager.instance.withTitleCustom(title: "guide_sensor_voc_avg_title".localized, contents: "guide_sensor_voc_avg_contents".localized, confirmType: .ok)
    }
    
    @IBAction func onClick_MovHelp(_ sender: UIButton) {
        _ = PopupManager.instance.withTitleCustom(title: "guide_sensor_moving_title".localized, contents: "guide_sensor_moving_contents".localized, confirmType: .ok)
    }
    
    @IBAction func onClick_ConnectHelp(_ sender: UIButton) {
        _ = PopupManager.instance.withTitleCustom(title: "guide_sensor_operation_title".localized, contents: "guide_sensor_operation_contents".localized, confirmType: .ok)
    }
    
    @IBAction func onClick_refresh(_ sender: Any) {
        let send = Send_InitDiaperStatus()
        send.aid = DataManager.instance.m_userInfo.account_id
        send.token = DataManager.instance.m_userInfo.token
        send.type = DEVICE_TYPE.Sensor.rawValue
        send.did = m_parent!.m_parent!.m_detailInfo!.m_did
        send.enc = m_parent!.m_parent!.userInfo!.enc

        NetworkManager.instance.Request(send) { (json) -> () in
            let receive = Receive_SetDiaperChanged(json)
            switch receive.ecd {
            case .success:
                NativePopupManager.instance.toast(message: "toast_diaper_status_initialized".localized)
                break
            default:
                Debug.print("[ERROR] invaild errcod", event: .error)
            }
        }
    }
}
