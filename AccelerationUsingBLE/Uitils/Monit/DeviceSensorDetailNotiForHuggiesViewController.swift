//
//  DeviceSensorDetailNotiViewController.swift
//  Monit
//
//  Created by 맥 on 2018. 1. 3..
//  Copyright © 2018년 맥. All rights reserved.
//

import UIKit

class DeviceSensorDetailNotiForHuggiesViewController: DeviceDetailNotiBaseViewController {
    @IBOutlet weak var lblFeedingLog: UILabel!
    @IBOutlet weak var lblFeedingTitle: UILabel!
    @IBOutlet weak var lblDiaperChangeLog: UILabel!
    @IBOutlet weak var lblDiaperChangeTitle: UILabel!
    @IBOutlet weak var lblSleepModeLog: UILabel!
    @IBOutlet weak var lblSleepModeTitle: UILabel!
    
    @IBOutlet weak var constNotiType: NSLayoutConstraint!
    
    @IBOutlet weak var viewSleepModeTimer: UIView!
    @IBOutlet weak var lblSleepModeType: UILabel!
    @IBOutlet weak var lblSleepModeTime: UILabel!
    @IBOutlet weak var btnSleepModeStop: UIButton!
    @IBOutlet weak var lblSleepModeStop: UILabel!
    
    @IBOutlet weak var viewBreastMilk: UIView!
    @IBOutlet weak var imgBreastMilkLeft: UIImageView!
    @IBOutlet weak var lblBreastMilkLeftTitle: UILabel!
    @IBOutlet weak var lblBreastMilkLeftTime: UILabel!
    @IBOutlet weak var imgBreastMilkLeftPlayType: UIImageView!
    @IBOutlet weak var imgBreastMilkRight: UIImageView!
    @IBOutlet weak var lblBreastMilkRightTitle: UILabel!
    @IBOutlet weak var lblBreastMilkRightTime: UILabel!
    @IBOutlet weak var imgBreastMilkRightPlayType: UIImageView!
    
    @IBOutlet var feeding: DeviceSensorDetailNotiView_Feeding!
    @IBOutlet var diaperChanged: DeviceSensorDetailNotiView_DiaperChange!
    @IBOutlet var sleepMode: DeviceSensorDetailNotiView_SleepMode!

    enum TIMER_TYPE: Int {
        case none = 0
        case sleep_mode = 1
        case breast_milk = 2
    }
    
    var m_timerSleepMode: Timer?
    var m_timerBreastMilk: Timer?
    
    override var screenType: SCREEN_TYPE { get { return .SENSOR_DETAIL_NOTI } }
    var m_parent: DeviceSensorDetailPageViewController?
    var m_arrSensorNotiType = [DEVICE_NOTI_TYPE]()
    var timerType: TIMER_TYPE = .none
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if (Config.channel == .monitXHuggies) {
//            viewFilter.isHidden = true
//            table.frame = view.frame
        }
        
        sensorSetUI()
    }
    
    override func reloadInfoChild() {
        super.reloadInfoChild()
        sensorSetUI()
    }
    
    func setInit(type: Int, did: Int) {
        m_arrSensorNotiType.removeAll()
        
        if (DataManager.instance.m_userInfo.configData.isBeta) {
            if (DataManager.instance.m_userInfo.shareDevice.isAlarmStatus(did: did, type: DEVICE_TYPE.Sensor.rawValue, almType: ALRAM_TYPE.fart) ?? false ) {
                m_arrSensorNotiType.append(DEVICE_NOTI_TYPE.fart_detected)
            }
            m_arrSensorNotiType.append(DEVICE_NOTI_TYPE.abnormal_detected)
            m_arrSensorNotiType.append(DEVICE_NOTI_TYPE.detect_diaper_changed)
            m_arrSensorNotiType.append(DEVICE_NOTI_TYPE.custom_memo)
            m_arrSensorNotiType.append(DEVICE_NOTI_TYPE.custom_status)
        }
        m_arrSensorNotiType.append(DEVICE_NOTI_TYPE.pee_detected)
        m_arrSensorNotiType.append(DEVICE_NOTI_TYPE.poo_detected)
        m_arrSensorNotiType.append(DEVICE_NOTI_TYPE.diaper_changed)
        m_arrSensorNotiType.append(DEVICE_NOTI_TYPE.sleep_mode)
        m_arrSensorNotiType.append(DEVICE_NOTI_TYPE.diaper_score)
        m_arrSensorNotiType.append(DEVICE_NOTI_TYPE.breast_milk)
        m_arrSensorNotiType.append(DEVICE_NOTI_TYPE.breast_feeding)
        m_arrSensorNotiType.append(DEVICE_NOTI_TYPE.feeding_milk)
        m_arrSensorNotiType.append(DEVICE_NOTI_TYPE.feeding_meal)
        super.setInit(notiType: m_arrSensorNotiType, type: type, did: did)
    }
    
    func sensorSetUI() {
        UI_Utility.customViewBorder(view: viewSleepModeTimer, radius: 20, width: 1, color: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0))
        UI_Utility.customViewShadow(view: viewSleepModeTimer, radius: 20, offsetWidth: 0.1, offsetHeight: 0.1, color: #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1), opacity: 0.2)
        
        UI_Utility.customViewBorder(view: viewBreastMilk, radius: 20, width: 1, color: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0))
        UI_Utility.customViewShadow(view: viewBreastMilk, radius: 20, offsetWidth: 0.1, offsetHeight: 0.1, color: #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1), opacity: 0.2)
        
        m_parent?.m_parent?.disableNewAlarmNoti()
        setLogInfo()
        setTimer()
    }
    
    func setLogInfo() {
        getLatestNotiFeeding()
        getLatestDiaperChanged()
        getSleepModeInfo()
    }
    
    func getLatestNotiFeeding() {
        lblFeedingLog.text = "-"
        lblFeedingTitle.text = "-"
        
        var _arr: [DeviceNotiInfo] = []
        
        if let _info = DataManager.instance.m_userInfo.deviceNoti.getLastNotiByType(type: DEVICE_TYPE.Sensor.rawValue, did: m_parent!.m_parent!.m_detailInfo!.m_did, notiType: .breast_milk) {
            _arr.append(_info)
        }
        if let _info = DataManager.instance.m_userInfo.deviceNoti.getLastNotiByType(type: DEVICE_TYPE.Sensor.rawValue, did: m_parent!.m_parent!.m_detailInfo!.m_did, notiType: .breast_feeding) {
            _arr.append(_info)
        }
        if let _info = DataManager.instance.m_userInfo.deviceNoti.getLastNotiByType(type: DEVICE_TYPE.Sensor.rawValue, did: m_parent!.m_parent!.m_detailInfo!.m_did, notiType: .feeding_milk) {
            _arr.append(_info)
        }
        if let _info = DataManager.instance.m_userInfo.deviceNoti.getLastNotiByType(type: DEVICE_TYPE.Sensor.rawValue, did: m_parent!.m_parent!.m_detailInfo!.m_did, notiType: .feeding_meal) {
            _arr.append(_info)
        }
        
        if (_arr.count > 0) {
            _arr = _arr.sorted(by: {$0.m_castTimeInfo.m_timeCast > $1.m_castTimeInfo.m_timeCast})
            
            lblFeedingLog.text = getLatestNotiInfo(info: _arr[0])
            lblFeedingTitle.text = getLatestNotiTitle(info: _arr[0])
        }
    }
    
    func getLatestDiaperChanged() {
        let _info = DataManager.instance.m_userInfo.deviceNoti.getLastNotiByType(type: DEVICE_TYPE.Sensor.rawValue, did: m_parent!.m_parent!.m_detailInfo!.m_did, notiType: .diaper_changed)

        lblDiaperChangeLog.text = getLatestNotiInfo(info: _info)
        lblDiaperChangeTitle.text = _info != nil ? getLatestNotiTitle(info: _info!) : "-"
    }
    
    func getSleepModeInfo() {
        let _info = DataManager.instance.m_userInfo.deviceNoti.getLastNotiByType(type: DEVICE_TYPE.Sensor.rawValue, did: m_parent!.m_parent!.m_detailInfo!.m_did, notiType: .sleep_mode)
        
        lblSleepModeLog.text = getLatestNotiInfo(info: _info)
        lblSleepModeTitle.text = _info != nil ? getLatestNotiTitle(info: _info!) : "-"
    }
    
    func getLatestNotiInfo(info: DeviceNotiInfo?) -> String {
        if let _info = info {
            let _nowLTime = UI_Utility.nowLocalDate(type: .full)
            let _nowUTCTime = UI_Utility.localToUTC(date: _nowLTime)
            let _nowUTCTimeDate = UI_Utility.convertStringToDate(_nowUTCTime, type: .full)
            let _infoTimeDate = UI_Utility.convertStringToDate(_info.Time, type: .yyMMdd_HHmmss)
            let _diff = UI_Utility.getTimeDiff(fromDate: _infoTimeDate!, toDate: _nowUTCTimeDate!)
            var _retValue = ""
            if (_diff.hour ?? 0 > 0) {
                _retValue = String(format: "device_sensor_the_latest_time".localized, "\(_diff.hour ?? 0)\("time_hour_short".localized)\(_diff.minute ?? 0 % 60)\("time_minute_short".localized)")
            } else {
                _retValue = String(format: "device_sensor_the_latest_time".localized, "\(_diff.minute ?? 0)\("time_minute_short".localized)")
            }
            return _retValue
        }
       return "-"
    }
    
    func getLatestNotiTitle(info: DeviceNotiInfo) -> String {
        var _returnValue = ""
        switch info.notiType {
        case .breast_milk:
            _returnValue = "notification_feeding_nursed_breast_milk".localized
        case .breast_feeding:
            _returnValue = "notification_feeding_bottle_breast_milk".localized
        case .feeding_milk:
            _returnValue = "notification_feeding_bottle_formula_milk".localized
        case .feeding_meal:
            _returnValue = "notification_feeding_baby_food".localized
        case .diaper_changed:
            switch info.Extra {
            case "2":
                _returnValue = "device_sensor_diaper_status_pee".localized
            case "3":
                _returnValue = "device_sensor_diaper_status_poo".localized
            case "4":
                _returnValue = "device_sensor_diaper_status_mixed".localized
            default:
                _returnValue = "device_sensor_diaper_status_normal".localized
            }
        case .sleep_mode:
            switch info.m_extra2 {
            case "1":
                _returnValue = "device_sensor_naps".localized
            case "2":
                _returnValue = "device_sensor_night_sleep".localized
            default:
                _returnValue = "-"
            }
        default:
            _returnValue = "-"
        }
        return _returnValue
    }
    
    func setTimer() {
        self.timerType = .none
        
        if (SleepModeTimer.isSleepTimer) {
            self.timerType = .sleep_mode
        } else if (BreastMilkTimer.isUseable) {
            self.timerType = .breast_milk
        }
        
        setVisiableTimer(isOn: false, isAnimation: false)
        
        viewSleepModeTimer.isHidden = true
        lblSleepModeType.text = "-"
        lblSleepModeTime.text = "00:00:00"
        
        viewBreastMilk.isHidden = true
//        lblBreastMilkLeftTime.text = "00:00"
//        lblBreastMilkRightTime.text = "00:00"
        
        switch self.timerType {
        case .sleep_mode:
            viewSleepModeTimer.isHidden = false
            setVisiableTimer(isOn: true, isAnimation: false)
            if (SleepModeTimer.sleepModeType != .none) {
                lblSleepModeType.text = SleepModeTimer.sleepModeType == .naps ? "device_sensor_naps".localized : "device_sensor_night_sleep".localized
            }
            self.m_timerSleepMode = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(setSleepModeTimerInfo), userInfo: nil, repeats: true)
        case .breast_milk:
            viewBreastMilk.isHidden = false
            setVisiableTimer(isOn: true, isAnimation: false)
            self.m_timerBreastMilk = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(setBreastMilkTimerInfo), userInfo: nil, repeats: true)
        default:
            break
        }
    }
    
    @objc func setSleepModeTimerInfo() {
        if (SleepModeTimer.isSleepTimer) {
            let _startDate = UI_Utility.convertStringToDate(SleepModeTimer.recordStartSleepModeTime, type: .yyMMdd_HHmmss)
            let _diff = UI_Utility.getTimeDiff(fromDate: _startDate!, toDate: Date())
            let _hour = String(format: "%02d", _diff.hour ?? 0)
            let _min = String(format: "%02d", _diff.minute ?? 0)
            let _sec = String(format: "%02d", _diff.second ?? 0)
            lblSleepModeTime.text = "\(_hour):\(_min):\(_sec)"
        }
    }
    
    @objc func setBreastMilkTimerInfo() {
        setBreastMilkTimerInfoLeft()
        setBreastMilkTimerInfoRight()
    }
    
    func setBreastMilkTimerInfoLeft() {
        guard (BreastMilkTimer.leftInfo.playType != .ready) else {
            lblBreastMilkLeftTime.text = "00:00"
            imgBreastMilkLeft.image = UIImage(named: "imgDiaryPlayRed")
            return
        }
        
        let _totalSec = BreastMilkTimer.leftInfo.getTotalSec()
        let _min = String(format: "%02d", _totalSec / 60)
        let _sec = String(format: "%02d", _totalSec % 60)
        lblBreastMilkLeftTime.text = "\(_min):\(_sec)"
        
        if (BreastMilkTimer.leftInfo.playType == .start) {
            imgBreastMilkLeft.image = UIImage(named: "imgDiaryStopRed")
        } else {
            imgBreastMilkLeft.image = UIImage(named: "imgDiaryPlayRed")
        }
    }
    
    func setBreastMilkTimerInfoRight() {
        guard (BreastMilkTimer.rightInfo.playType != .ready) else {
            lblBreastMilkRightTime.text = "00:00"
            imgBreastMilkRight.image = UIImage(named: "imgDiaryPlayRed")
            return
        }
        
        let _totalSec = BreastMilkTimer.rightInfo.getTotalSec()
        let _min = String(format: "%02d", _totalSec / 60)
        let _sec = String(format: "%02d", _totalSec % 60)
        lblBreastMilkRightTime.text = "\(_min):\(_sec)"
        
        if (BreastMilkTimer.rightInfo.playType == .start) {
            imgBreastMilkRight.image = UIImage(named: "imgDiaryStopRed")
        } else {
            imgBreastMilkRight.image = UIImage(named: "imgDiaryPlayRed")
        }
    }
    
    func setVisiableTimer(isOn: Bool, isAnimation: Bool) {
        if (isAnimation) {
            UIView.animate(withDuration: 0.2, animations: {
                self.constNotiType?.constant = (isOn ? 215 : 130)
                self.view.layoutIfNeeded()
            })
        } else {
            self.constNotiType?.constant = (isOn ? 215 : 130)
            self.view.layoutIfNeeded()
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let _arrData = getSectionDataByIndex(section: indexPath.section)
        let _cell = Bundle.main.loadNibNamed("DeviceNotiDiaryTableViewCell", owner: self, options: nil)?.first as! DeviceNotiDiaryTableViewCell
        let _info = _arrData[indexPath.row]
        _cell.m_parent = self
        _cell.m_deviceNotiInfo = _info
        _cell.m_sectionIndex = indexPath.section
        _cell.m_index = indexPath.row
        _cell.m_editAction = editAction
        _cell.setInit()
        return _cell
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 75
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let _view: SensorDiaryHeaderView = .fromNib()
        _view.setUI(arr: getSectionInfoByIndex(section: section))
        return _view
    }
    
    func getSectionInfoByIndex(section: Int) -> [DeviceNotiInfo]? {
            var i = 0
            for item in m_pagingData! {
                if (i == section) {
                    return item
                }
                i += 1
            }
            return nil
        }
    
    func editAction(info: Any) {
        if let _info = info as? DeviceNotiInfo {
            switch _info.notiType {
            case .breast_milk,
                 .breast_feeding,
                 .feeding_meal,
                 .feeding_milk:
                feeding.notiViewController = self
                self.m_parent?.m_parent?.view.addSubview(feeding)
                feeding.setEdit(info: _info)
            case .diaper_changed:
                diaperChanged.parent = self
                self.m_parent?.m_parent?.view.addSubview(diaperChanged)
                diaperChanged.setEdit(info: _info)
            case .sleep_mode:
                sleepMode.parent = self
                self.m_parent?.m_parent?.view.addSubview(sleepMode)
                sleepMode.setEdit(info: _info)
            default:
                break
            }
        }
    }
    
    func changeNoti(notiType: DEVICE_NOTI_TYPE) {
        if (m_arrSensorNotiType.contains(notiType)) {
            if let _index = m_arrSensorNotiType.index(where: { $0 == notiType }) {
                m_arrSensorNotiType.remove(at: _index)
            }
        } else {
            m_arrSensorNotiType.append(notiType)
        }
        
        sensorSetUI()
    }
    
    @IBAction func onClick_feeding(_ sender: UIButton) {
        feeding.notiViewController = self
        self.m_parent?.m_parent?.view.addSubview(feeding)
        feeding.setInit(type: .add)
    }
    
    @IBAction func onClick_diaperChanged(_ sender: UIButton) {
        diaperChanged.parent = self
        self.m_parent?.m_parent?.view.addSubview(diaperChanged)
        diaperChanged.setInit(type: .add)
    }
    
    @IBAction func onClick_sleepMode(_ sender: Any) {
        sleepMode.parent = self
        self.m_parent?.m_parent?.view.addSubview(sleepMode)
        sleepMode.setInit(type: .add)
    }
    
    @IBAction func onClick_sleepModeStop(_ sender: Any) {
        sendSleeMode()
    }
    
    @IBAction func onClick_breastMilkLeft(_ sender: Any) {
        BreastMilkTimer.playType(playType: .start, directionType: .left)
    }
    
    @IBAction func onClick_breastMilkRight(_ sender: Any) {
        BreastMilkTimer.playType(playType: .start, directionType: .right)
    }
    
    @IBAction func onClick_breastMilkStop(_ sender: Any) {
        if (BreastMilkTimer.isReadyBoth) {
            BreastMilkTimer.playType(playType: .none, directionType: .none)
            sensorSetUI()
            return
        }
        
        BreastMilkTimer.playType(playType: .stop, directionType: .none)
        sendBreastMilk()
    }
    
    func sendSleeMode() {
        if (SleepModeTimer.isSleepTimer) {
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
        }
    }
    
    func sendBreastMilk() {
        let send = Send_SetFeeding()
        send.aid = DataManager.instance.m_userInfo.account_id
        send.token = DataManager.instance.m_userInfo.token
        send.type = DEVICE_TYPE.Sensor.rawValue
        send.did = m_parent!.m_parent!.m_detailInfo!.m_did
        send.enc = m_parent!.m_parent!.userInfo!.enc
        send.time = UI_Utility.nowUTCDate(type: .yyMMdd_HHmmss)
        send.feeding_type = DEVICE_NOTI_TYPE.breast_milk.rawValue
        send.left_time = BreastMilkTimer.leftInfo.getTotalSec() / 60
        send.right_time = BreastMilkTimer.rightInfo.getTotalSec() / 60
        NetworkManager.instance.Request(send) { (json) -> () in
            let receive = Receive_SetFeeding(json)
            switch receive.ecd {
            case .success:
                DataManager.instance.m_dataController.deviceNoti.updateForDetailView()
                break
            default:
                Debug.print("[ERROR] invaild errcod", event: .error)
            }
        }
    }
}
