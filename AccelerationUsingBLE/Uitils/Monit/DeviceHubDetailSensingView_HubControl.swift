//
//  DeviceHubDetailSensingView_HubControl.swift
//  Monit
//
//  Created by john.lee on 2019. 3. 13..
//  Copyright © 2019년 맥. All rights reserved.
//

import UIKit

class HubBrightLevelControl {
    var progressBar: UIView
    var level: HUB_TYPES_BRIGHT_V2_TYPE
    
    init (view: UIView, level: HUB_TYPES_BRIGHT_V2_TYPE) {
        self.progressBar = view
        self.level = level
    }
    
    var setLevel: HUB_TYPES_BRIGHT_V2_TYPE {
        get {
            return level
        }
        set {
            level = newValue
            setUI()
        }
    }
    
    func setUI() {
        switch level {
        case .level_1:
            progressBar.frame.size.width = 32.0
        case .level_2:
            progressBar.frame.size.width = 64.0
        case .level_3:
            progressBar.frame.size.width = 96.0
        case .level_4:
            progressBar.frame.size.width = 128.0
        case .level_5:
            progressBar.frame.size.width = 165.0
        }
    }
    
    func increaseLevel() -> Bool {
        switch level {
        case .level_1:
            self.setLevel = .level_2
        case .level_2:
            self.setLevel = .level_3
        case .level_3:
            self.setLevel = .level_4
        case .level_4:
            self.setLevel = .level_5
        case .level_5:
            return false
        }
        return true
    }
    
    func decreaseLevel() -> Bool {
        switch level {
        case .level_1:
            return false
        case .level_2:
            self.setLevel = .level_1
        case .level_3:
            self.setLevel = .level_2
        case .level_4:
            self.setLevel = .level_3
        case .level_5:
            self.setLevel = .level_4
        }
        return true
    }
}

class DeviceHubDetailSensingView_HubControl: UIView, UIPickerViewDelegate, UIPickerViewDataSource {
    var parent: DeviceHubDetailSensingViewController!
    var flow = Flow()
    var hours: [String] = []
    var minutes: [String] = []
    var expireTime: Date?
    var timeController = TimerController()
    var hubTimerType: TIMER_TYPE = .none
    var selectHourIdx: Int = 0
    var selectMinuteIdx: Int = 0
    var isBlankStatus: Bool = true
    var levelControl: HubBrightLevelControl?
    
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
    
    var isConnect: Bool {
        var _isConnect = false
        if let _hubStatusInfo = hubStatusInfo {
            _isConnect = _hubStatusInfo.isConnect
        }
        return _isConnect
    }
    
    func setInit(parent :DeviceHubDetailSensingViewController) {
        self.parent = parent
        setInitUI()
        setUI()
    }
    
    func reloadInfoChild() {
        setUI()
    }
    
    func setInitUI() {
        levelControl = HubBrightLevelControl(view: parent.viewTimerProgress, level: self.hubStatusInfo?.brightLevelV2 ?? .level_1)
        levelControl?.setUI()
        parent.imgClock.image = UIImage(named: "imgHubTimerClock2")
        initPickerInfo()
        parent.indicator.isHidden = true
    }
    
    @objc func brightReadyCallback() {
        self.parent.indicator.stopAnimating()
        self.parent.indicator.isHidden = true
    }
    
    func setUI() {
        setBrightButtonUI()
        setConnect()
        setTimer()
    }

    func initTimer() {
        self.expireTime = nil
        self.timeController.stop()
    }
    
    func setBrightButtonUI() {
        parent.btnBrightSwitch.isEnabled = true
        parent.btnBrightSwitch.setImage(self.hubStatusInfo?.isPower ?? false ? UIImage(named: "imgLampSwitchOn") : UIImage(named: "imgLampSwitchOff"), for: .normal)
        
        if (hubStatusInfo?.isPower ?? false) {
            parent.btnBrightDecrease.isEnabled = true
            parent.btnBrightIncrease.isEnabled = true
        } else {
            parent.btnBrightDecrease.isEnabled = false
            parent.btnBrightIncrease.isEnabled = false
        }
    }
    
    func setTimer() {
        isBlankStatus = true
        DataManager.instance.m_dataController.device.m_hub.m_brightController.getTimerTime(did: hubStatusInfo?.m_did ?? 0
            ,handler: { (time) -> () in
                guard (time != Config.DATE_INIT) else {
                    self.initTimer()
                    self.setTimerUI(timerType: (self.isConnect && self.hubStatusInfo?.isPower ?? false) ? .ready : .disable)
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
        parent.pickerView.isHidden = true
        parent.imgClock.isHidden = true
        parent.lblRestTime.isHidden = true
        parent.lblRestTime2.isHidden = true
        parent.lblRestTimeCenter.isHidden = true
        parent.btnTimer.isUserInteractionEnabled = timerType != .disable
        parent.pickerView.isUserInteractionEnabled = timerType != .disable
        
        if (timerType == .disable) {
            parent.pickerView.isHidden = false
            parent.pickerView.selectRow(0, inComponent: 0, animated: true)
            parent.pickerView.selectRow(0, inComponent: 1, animated: true)
            parent.lblTimer.text = "btn_start".localized
            parent.lblTimer.textColor = COLOR_TYPE.lblWhiteGray.color
            parent.btnTimer.setImage(UIImage(named: "imgHubTimerBtnReadyDisable"), for: .normal)
        } else {
            if (!timeController.isPlaying) {
                if (self.hubTimerType == .disable || self.hubTimerType == .none) {
                    parent.pickerView.isHidden = false
                    selectHourIdx = 2
                    selectMinuteIdx = 3
                    parent.pickerView.selectRow(2, inComponent: 0, animated: true)
                    parent.pickerView.selectRow(3, inComponent: 1, animated: true)
                    parent.lblTimer.text = "btn_start".localized
                    parent.lblTimer.textColor = COLOR_TYPE.blue.color
                    parent?.btnTimer.setImage(UIImage(named: "imgHubTimerBtnReady"), for: .normal)
                } else {
                    parent.pickerView.isHidden = false
                    parent.lblTimer.text = "btn_start".localized
                    parent.lblTimer.textColor = COLOR_TYPE.blue.color
                    parent?.btnTimer.setImage(UIImage(named: "imgHubTimerBtnReady"), for: .normal)
                }
            } else {
                var _hour = 0
                var _min = 0
                var _second = 0
                (_hour, _min, _second) = UIManager.instance.getTimeDiffHourAndMinuteAndSecond(time: expireTime ?? Date())
                if (_hour + _min + _second > 0) {
                    self.parent.imgClock.isHidden = false
                    self.parent.lblRestTime.isHidden = false
                    self.parent.lblRestTime2.isHidden = false
                    self.parent.lblRestTimeCenter.isHidden = false
                    let _blank = isBlankStatus ? ":" : ""
                    isBlankStatus = !isBlankStatus
                    self.parent.lblRestTime.text = "\(String(format: "%02d", _hour))"
                    self.parent.lblRestTime2.text = "\(String(format: "%02d", _min))"
                    self.parent.lblRestTimeCenter.text = "\(_blank)"
                    parent.lblTimer.text = "btn_cancel".localized
                    parent.lblTimer.textColor = COLOR_TYPE.lblGray.color
                    self.parent.btnTimer.setImage(UIImage(named: "imgHubTimerBtnStop"), for: .normal)
                } else {
                    parent.pickerView.isHidden = false
                }
            }
        }

        self.hubTimerType = timerType
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
        parent.pickerView.selectRow(2, inComponent: 0, animated: false)
        parent.pickerView.selectRow(3, inComponent: 1, animated: false)
    }
    
    func setConnect() {
        if (isConnect) {
            parent.viewTimerProgress.isHidden = false
        } else {
            parent.btnBrightSwitch.isEnabled = false
            parent.btnBrightDecrease.isEnabled = false
            parent.btnBrightIncrease.isEnabled = false
            parent.viewTimerProgress.isHidden = true
        }
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
    
    func firstClick() {
        flow.one {
            self.parent.indicator.startAnimating()
            self.parent.indicator.isHidden = false
            Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(brightReadyCallback), userInfo: nil, repeats: false)
        }
    }
    
    func setTimePacket(type: Int, hour: Int, min: Int, handler: Action? = nil) {
        DataManager.instance.m_dataController.device.m_hub.m_brightController.sendOffTimerPacket(did: parent?.m_parent?.m_parent?.hubStatusInfo?.m_did ?? 0, brightType: type, hour: hour, min: min, handler: handler)
    }

    func onClick_Bright_switch(_ sender: UIButton) {
        firstClick()
        DataManager.instance.m_dataController.device.m_hub.m_brightController.setBrightPow(did: parent?.m_parent?.m_parent?.hubStatusInfo?.m_did ?? 0, pow: !(hubStatusInfo?.isPower ?? false))
        
        hubStatusInfo?.m_power = (hubStatusInfo?.m_power ?? 0 == 0) ? 1 : 0
        setBrightButtonUI()
        
        setTimerUI(timerType: (hubStatusInfo?.isPower ?? false) ? .ready : .disable)
        setTimePacket(type: -1, hour: 0, min: 0)
        initTimer()
    }
    
    func onClick_Bright_decrease(_ sender: UIButton) {
        let _isSuccess = levelControl?.decreaseLevel() ?? false
        if (_isSuccess) {
            firstClick()
            
            let _level: HUB_TYPES_BRIGHT_V2_TYPE = levelControl?.level ?? .level_1
            
            DataManager.instance.m_dataController.device.m_hub.m_brightController.setBrightLevel(did: parent?.m_parent?.m_parent?.hubStatusInfo?.m_did ?? 0, level: _level.rawValue)
            
            setTimerUI(timerType: (hubStatusInfo?.isPower ?? false) ? .ready : .disable)
            
            hubStatusInfo?.brightLevelV2 = _level
        }
    }
    
    func onClick_Bright_increase(_ sender: UIButton) {
        let _isSuccess = levelControl?.increaseLevel() ?? false
        if (_isSuccess) {
            firstClick()
            
            let _level: HUB_TYPES_BRIGHT_V2_TYPE = levelControl?.level ?? .level_1
            
            DataManager.instance.m_dataController.device.m_hub.m_brightController.setBrightLevel(did: parent?.m_parent?.m_parent?.hubStatusInfo?.m_did ?? 0, level: _level.rawValue)
            
            setTimerUI(timerType: (hubStatusInfo?.isPower ?? false) ? .ready : .disable)
            
            hubStatusInfo?.brightLevelV2 = _level
        }
    }
    
    func onClick_btnTimer(_ sender: UIButton) {
        // timer start
        firstClick()
        
        if (!timeController.isPlaying) {
            if (self.selectHourIdx == 0 && self.selectMinuteIdx == 0) {
                return
            }
            
            self.parent.indicator.startAnimating()
            self.parent.indicator.isHidden = false
            self.setTimePacket(type: self.levelControl?.level.rawValue ?? -1, hour: self.selectHourIdx, min: self.selectMinuteIdx * 10, handler: { () -> () in
                self.setTimer()
                self.setTimerUI(timerType: .ready)
                self.parent.indicator.stopAnimating()
                self.parent.indicator.isHidden = true
            })
        // timer cancel
        } else {
            initTimer()
            setTimerUI(timerType: .ready)
            setTimePacket(type: self.levelControl?.level.rawValue ?? -1, hour: 0, min: 0)
        }
    }
}
