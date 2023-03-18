//
//  DeviceHubDetailSensingView_HubControl.swift
//  Monit
//
//  Created by john.lee on 2019. 3. 13..
//  Copyright © 2019년 맥. All rights reserved.
//

import UIKit

class DeviceHubDetailSensingForKcView_HubControl: UIView, UIPickerViewDelegate, UIPickerViewDataSource {
    @IBOutlet weak var btnBrightOn_off: UIButton!
    @IBOutlet weak var btnBrightOn_1: UIButton!
    @IBOutlet weak var btnBrightOn_2: UIButton!
    @IBOutlet weak var btnBrightOn_3: UIButton!
    
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var btnTimer: UIButton!
    @IBOutlet weak var lblTimer: UILabel!
    @IBOutlet weak var imgClock: UIImageView!
    @IBOutlet weak var lblRestTime: UILabel!
    @IBOutlet weak var lblRestTime2: UILabel!
    @IBOutlet weak var lblRestTimeCenter: UILabel!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    var parent: DeviceHubDetailSensingForKcViewController?
    var hours: [String] = []
    var minutes: [String] = []
    var expireTime: Date?
    var timeController = TimerController()
    var hubBrightType: HUB_TYPES_BRIGHT_TYPE = .start
    var hubTimerType: TIMER_TYPE = .none
    var selectHourIdx: Int = 0
    var selectMinuteIdx: Int = 0
    var isBlankStatus: Bool = true
    
    enum TIMER_TYPE: Int {
        case none = -1
        case disable = 0
        case ready = 1
    }
    
    var hubStatusInfo: HubStatusInfo? {
        get {
            if let _statusInfo = self.parent?.m_parent!.m_parent!.hubStatusInfo {
                return _statusInfo
            }
            return nil
        }
    }
    
    func setInit(parent :DeviceHubDetailSensingForKcViewController) {
        self.parent = parent
        pickerView.delegate = self
        pickerView.dataSource = self
        imgClock.image = UIImage(named: Config.channel == .kc ? "imgKcHubTimerClock" : "imgHubTimerClock") 
        initPickerInfo()
        setBrightLevelUI(value: self.hubStatusInfo?.brightLevel ?? .start)
        setTimer()
        UI_Utility.customViewBorder(view: self, radius: 20, width: 1, color: Config.channel == .kc ? COLOR_TYPE.green.color.cgColor : COLOR_TYPE.blue.color.cgColor)
        indicator.isHidden = true
    }

    func initTimer() {
        self.parent?.initTimer()
        self.expireTime = nil
        self.timeController.stop()
    }
    
    func reloadInfoChild() {
        setBrightLevelUI(value: self.hubStatusInfo?.brightLevel ?? .start)
    }
    
    func setTimer() {
        isBlankStatus = true
        DataManager.instance.m_dataController.device.m_hub.m_brightController.getTimerTime(did: hubStatusInfo?.m_did ?? 0
            ,handler: { (time) -> () in
                guard (time != Config.DATE_INIT) else {
                    self.initTimer()
                    self.setTimerUI(timerType: (self.hubStatusInfo?.brightLevel ?? .off == .off) ? .disable : .ready)
                    return
                }
                self.expireTime = time.ToPacketTime()
                let _second = UIManager.instance.getTimeDiffSecond(time: time.ToPacketTime())
                self.timeController.start(interval: 1, finishTime: Double(_second), updateCallback: {() -> () in
                    self.setTimerUI(timerType: .ready)
                }, finishCallback: {() -> () in
                    self.expireTime = nil
                })
        })
    }
    
    func setTimerUI(timerType: TIMER_TYPE) {
        pickerView.isHidden = true
        imgClock.isHidden = true
        lblRestTime.isHidden = true
        lblRestTime2.isHidden = true
        lblRestTimeCenter.isHidden = true
        btnTimer.isUserInteractionEnabled = timerType != .disable
        pickerView.isUserInteractionEnabled = timerType != .disable
        if (timerType == .disable) {
            pickerView.isHidden = false
            pickerView.selectRow(0, inComponent: 0, animated: true)
            pickerView.selectRow(0, inComponent: 1, animated: true)
            lblTimer.text = "btn_start".localized
            lblTimer.textColor = COLOR_TYPE.lblWhiteGray.color
            btnTimer.setImage(UIImage(named: "imgHubTimerBtnReadyDisable"), for: .normal)
        } else {
            if (!timeController.isPlaying) {
                if (self.hubTimerType == .disable || self.hubTimerType == .none) {
                    pickerView.isHidden = false
                    selectHourIdx = 2
                    selectMinuteIdx = 3
                    pickerView.selectRow(2, inComponent: 0, animated: true)
                    pickerView.selectRow(3, inComponent: 1, animated: true)
                    lblTimer.text = "btn_start".localized
                    lblTimer.textColor = Config.channel == .kc ? COLOR_TYPE.green.color : COLOR_TYPE.blue.color
                    btnTimer.setImage(UIImage(named: Config.channel == .kc ? "imgKcHubTimerBtnReady" : "imgHubTimerBtnReady"), for: .normal)
                } else {
                    pickerView.isHidden = false
                    lblTimer.text = "btn_start".localized
                    lblTimer.textColor = Config.channel == .kc ? COLOR_TYPE.green.color : COLOR_TYPE.blue.color
                    btnTimer.setImage(UIImage(named: Config.channel == .kc ? "imgKcHubTimerBtnReady" : "imgHubTimerBtnReady"), for: .normal)
                }
            } else {
                var _hour = 0
                var _min = 0
                var _second = 0
                (_hour, _min, _second) = UIManager.instance.getTimeDiffHourAndMinuteAndSecond(time: expireTime ?? Date())
                if (_hour + _min + _second > 0) {
                    self.imgClock.isHidden = false
                    self.lblRestTime.isHidden = false
                    self.lblRestTime2.isHidden = false
                    self.lblRestTimeCenter.isHidden = false
                    let _blank = isBlankStatus ? ":" : ""
                    isBlankStatus = !isBlankStatus
                    self.lblRestTime.text = "\(String(format: "%02d", _hour))"
                    self.lblRestTime2.text = "\(String(format: "%02d", _min))"
                    self.lblRestTimeCenter.text = "\(_blank)"
                    lblTimer.text = "btn_cancel".localized
                    lblTimer.textColor = COLOR_TYPE.lblGray.color
                    self.btnTimer.setImage(UIImage(named: "imgHubTimerBtnStop"), for: .normal)
                } else {
                    pickerView.isHidden = false
                }
            }
        }

        self.hubTimerType = timerType
    }
    
    func setBrightLevelUI(value: HUB_TYPES_BRIGHT_TYPE) {
        self.parent?.setBrightLevelUI(value: value)
        btnBrightOn_off.setImage(UIImage(named: "imgHubBrightBtn0Disable"), for: .normal)
        btnBrightOn_1.setImage(UIImage(named: "imgHubBrightBtn1Disable"), for: .normal)
        btnBrightOn_2.setImage(UIImage(named: "imgHubBrightBtn2Disable"), for: .normal)
        btnBrightOn_3.setImage(UIImage(named: "imgHubBrightBtn3Disable"), for: .normal)
        
        if (Config.channel == .kc) {
            switch value {
            case .off: btnBrightOn_off.setImage(UIImage(named: "imgHubBrightBtn0"), for: .normal)
                break
            case .level_1: btnBrightOn_1.setImage(UIImage(named: "imgKcHubBrightBtn1"), for: .normal)
                break
            case .level_2: btnBrightOn_2.setImage(UIImage(named: "imgKcHubBrightBtn2"), for: .normal)
                break
            case .level_3: btnBrightOn_3.setImage(UIImage(named: "imgKcHubBrightBtn3"), for: .normal)
                break
            case .start: break;
            }
        } else {
            switch value {
            case .off: btnBrightOn_off.setImage(UIImage(named: "imgHubBrightBtn0"), for: .normal)
                break
            case .level_1: btnBrightOn_1.setImage(UIImage(named: "imgHubBrightBtn1"), for: .normal)
                break
            case .level_2: btnBrightOn_2.setImage(UIImage(named: "imgHubBrightBtn2"), for: .normal)
                break
            case .level_3: btnBrightOn_3.setImage(UIImage(named: "imgHubBrightBtn3"), for: .normal)
                break
            case .start: break;
            }
        }
        
        self.hubBrightType = value
    }
    
    func initPickerInfo() {
        if (self.minutes.count == 0) {
            var minutes: [String] = []
            for i in 0...50 {
                if (i % 10 == 0) {
                    minutes.append("\(i) \("time_elapsed_minute".localized)")
                }
            }
            self.minutes = minutes
        }

        if (self.hours.count == 0) {
            var hours: [String] = []
            for i in 0...23 {
                hours.append("\(i) \("time_elapsed_hour".localized)")
            }
            self.hours = hours
        }
//
//        pickerView.selectRow(0, inComponent: 0, animated: false)
//        pickerView.selectRow(0, inComponent: 1, animated: false)
//
        selectHourIdx = 2
        selectMinuteIdx = 3
        pickerView.selectRow(2, inComponent: 0, animated: false)
        pickerView.selectRow(3, inComponent: 1, animated: false)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch component {
        case 0:
            return "\(hours[row])"
        case 1:
            return "\(minutes[row])"
        default:
            return nil
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:
            return hours.count
        case 1:
            return minutes.count
        default:
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.selectHourIdx = pickerView.selectedRow(inComponent: 0)
        self.selectMinuteIdx = pickerView.selectedRow(inComponent: 1)
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        var label: UILabel
        if let view = view as? UILabel { label = view }
        else { label = UILabel() }
        
        switch component {
        case 0:
            label.text = "\(hours[row])"
        case 1:
            label.text = "\(minutes[row])"
        default: break
        }
        label.textAlignment = .center
        label.font = UIFont(name: Config.FONT_NotoSans, size: 15.0)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        
        return label
    }
    
    func setTimePacket(type: HUB_TYPES_BRIGHT_TYPE, hour: Int, min: Int, handler: Action? = nil) {
        DataManager.instance.m_dataController.device.m_hub.m_brightController.sendOffTimerPacket(did: parent?.m_parent?.m_parent?.hubStatusInfo?.m_did ?? 0, brightType: type.rawValue, hour: hour, min: min, handler: handler)
    }
    
    @IBAction func onClick_Bright_off(_ sender: UIButton) {
        DataManager.instance.m_dataController.device.m_hub.m_brightController.setBrightLevel(did: parent?.m_parent?.m_parent?.hubStatusInfo?.m_did ?? 0, level: HUB_TYPES_BRIGHT_TYPE.off.rawValue)
        
        setBrightLevelUI(value: .off)
        setTimerUI(timerType: .disable)
        setTimePacket(type: .off, hour: 0, min: 0)
        initTimer()

        hubStatusInfo?.brightLevel = HUB_TYPES_BRIGHT_TYPE.off
    }
    
    @IBAction func onClick_Bright_1(_ sender: UIButton) {
        DataManager.instance.m_dataController.device.m_hub.m_brightController.setBrightLevel(did: parent?.m_parent?.m_parent?.hubStatusInfo?.m_did ?? 0, level: HUB_TYPES_BRIGHT_TYPE.level_1.rawValue)
        
        setBrightLevelUI(value: .level_1)
        setTimerUI(timerType: .ready)
        
        hubStatusInfo?.brightLevel = HUB_TYPES_BRIGHT_TYPE.level_1
    }
    
    @IBAction func onClick_Bright_2(_ sender: UIButton) {
        DataManager.instance.m_dataController.device.m_hub.m_brightController.setBrightLevel(did: parent?.m_parent?.m_parent?.hubStatusInfo?.m_did ?? 0, level: HUB_TYPES_BRIGHT_TYPE.level_2.rawValue)
        
        setBrightLevelUI(value: .level_2)
        setTimerUI(timerType: .ready)
        
        hubStatusInfo?.brightLevel = HUB_TYPES_BRIGHT_TYPE.level_2
    }
    
    @IBAction func onClick_Bright_3(_ sender: UIButton) {
        DataManager.instance.m_dataController.device.m_hub.m_brightController.setBrightLevel(did: parent?.m_parent?.m_parent?.hubStatusInfo?.m_did ?? 0, level: HUB_TYPES_BRIGHT_TYPE.level_3.rawValue)
        
        setBrightLevelUI(value: .level_3)
        setTimerUI(timerType: .ready)
        
        hubStatusInfo?.brightLevel = HUB_TYPES_BRIGHT_TYPE.level_3
    }
    
    @IBAction func onClick_btnTimer(_ sender: UIButton) {
        // timer start
        if (!timeController.isPlaying) {
            if (self.selectHourIdx == 0 && self.selectMinuteIdx == 0) {
                return
            }
            
            self.indicator.startAnimating()
            self.indicator.isHidden = false
            self.setTimePacket(type: hubBrightType, hour: self.selectHourIdx, min: self.selectMinuteIdx * 10, handler: { () -> () in
                self.setTimer()
                self.setTimerUI(timerType: .ready)
                self.indicator.stopAnimating()
                self.indicator.isHidden = true
            })
        // timer cancel
        } else {
            initTimer()
            setTimerUI(timerType: .ready)
            setTimePacket(type: self.hubBrightType, hour: 0, min: 0)
        }
    }
}
