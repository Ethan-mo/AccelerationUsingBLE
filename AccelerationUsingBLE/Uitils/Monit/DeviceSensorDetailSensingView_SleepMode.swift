//
//  DeviceSensorDetailSensingView_DiaperChange.swift
//  Monit
//
//  Created by john.lee on 16/08/2019.
//  Copyright © 2019 맥. All rights reserved.
//

import UIKit
import AudioToolbox

class DeviceSensorDetailSensingView_SleepMode: UIView {
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnDate: UIButton!
    @IBOutlet weak var lblDateTitle: UILabel!
    @IBOutlet weak var lblDateValue: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var viewDateLineShort: UIView!
    @IBOutlet weak var viewDateLineLong: UIView!
    @IBOutlet weak var imgDateArrow: UIImageView!
    @IBOutlet weak var constDate: NSLayoutConstraint!
    
    @IBOutlet weak var btnTime: UIButton!
    @IBOutlet weak var lblTimeTitle: UILabel!
    @IBOutlet weak var lblTimeValue: UILabel!
    @IBOutlet weak var timePicker: UIDatePicker!
    @IBOutlet weak var viewTimeLineShort: UIView!
    @IBOutlet weak var viewTimeLineLong: UIView!
    @IBOutlet weak var imgTimeArrow: UIImageView!
    @IBOutlet weak var constTime: NSLayoutConstraint!
    
    @IBOutlet weak var btnOk: UIButton!
    @IBOutlet weak var btnCancle: UIButton!
    
    var parent: DeviceSensorDetailSensingViewController?
    var dateValue: String = ""
    var timeValue: String = ""
    
    // only huggies
    var isStatusNone: Bool = false
    var isStatusPee: Bool = false
    var isStatusPoo: Bool = false
    
    override func awakeFromNib() {
        datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        
        timePicker.addTarget(self, action: #selector(timeChanged(_:)), for: .valueChanged)
        
        btnCancle.setTitle("btn_cancel".localized.uppercased(), for: .normal)
        btnOk.setTitle("btn_ok".localized.uppercased(), for: .normal)
    }

    func setInit(parent :DeviceSensorDetailSensingViewController) {
        self.parent = parent
        UI_Utility.customViewBorder(view: self, radius: 20, width: 1, color: COLOR_TYPE.blue.color.cgColor)
        setInitUI()
        setUI()
    }
    
    func setInitUI() {
        if (parent!.swSleepMode.isOn) {
            lblTitle.text = "dialog_sensor_sleep_end_date_time".localized
        } else {
            lblTitle.text = "dialog_sensor_sleep_start_date_time".localized
        }
    }
    
    func setUI() {
        initDateUI()
        initTimeUI()
    }
    
    func initDateUI() {
        let _strUTCDate = UI_Utility.nowUTCDate(type: .full)
        let _strLocalDate = UI_Utility.UTCToLocal(date: _strUTCDate, fromType: .full, toType: .full)
        let _localDate = UI_Utility.convertStringToLocalDate(_strLocalDate, type: .full)
        
        datePicker.setDate(_localDate!, animated: false)
        setVisiableDate(isOn: false, isAnimation: false)
        
        setDateValue(date: _localDate!)
    }
    
    func initTimeUI() {
        let _strUTCDate = UI_Utility.nowUTCDate(type: .full)
        let _strLocalDate = UI_Utility.UTCToLocal(date: _strUTCDate, fromType: .full, toType: .full)
        let _localDate = UI_Utility.convertStringToLocalDate(_strLocalDate, type: .full)

        timePicker.setDate(_localDate!, animated: false)
        setVisiableTime(isOn: true, isAnimation: false)
        
        setTimeValue(date: _localDate!)
    }
    
    @objc func dateChanged(_ sender: UIDatePicker) {
        setDateValue(date: sender.date)
    }
    
    @objc func timeChanged(_ sender: UIDatePicker) {
        setTimeValue(date: sender.date)
    }
    
    func setDateValue(date: Date) {
        let _dateValue = UI_Utility.getDateByLanguageFromDate(date, language: Config.languageType)
        lblDateValue.text = _dateValue
        
        let components = Calendar.current.dateComponents([.year, .month, .day], from: date)
        if let day = components.day, let month = components.month, let year = components.year {
            let _year = String(year)
            let _month = month.description.count == 1 ? "0\(month.description)" : month.description
            let _day = day.description.count == 1 ? "0\(day.description)" : day.description
            let _index = _year.index(_year.startIndex, offsetBy: 2)
            dateValue = _year[_index...] + _month + _day
        }
    }
    
    func setTimeValue(date: Date) {
        let dateFormatter = DateFormatter()
        switch Config.languageType {
        case .ko:
            dateFormatter.dateFormat = "h:mm a"
            break
        case .jp:
            dateFormatter.dateFormat = "h:mm a"
            break
        case .zh:
            dateFormatter.dateFormat = "h:mm a"
            break
        case .en:
            dateFormatter.dateFormat = "h:mm a"
            break
        default:
            dateFormatter.dateFormat = "h:mm a"
            break
        }
        
        let _dateValue = dateFormatter.string(from: date)
        lblTimeValue.text = _dateValue
        
        let components = Calendar.current.dateComponents([.hour, .minute, .second], from: date)
        if let hour = components.hour, let minute = components.minute, let second = components.second {
            let _hour = hour.description.count == 1 ? "0\(hour.description)" : hour.description
            let _minute = minute.description.count == 1 ? "0\(minute.description)" : minute.description
            let _second = second.description.count == 1 ? "0\(second.description)" : second.description
            
            timeValue = _hour + _minute + _second
        }
    }
    
    func setVisiableDate(isOn: Bool, isAnimation: Bool) {
        if (isAnimation) {
            UIView.animate(withDuration: 0.2, animations: {
                self.constDate?.constant = (isOn ? 155 : 48)
                self.layoutIfNeeded()
            })
        } else {
            self.constDate?.constant = (isOn ? 155 : 48)
            self.layoutIfNeeded()
        }
        datePicker.isHidden = !isOn
        viewDateLineShort.isHidden = !isOn
//        viewDateLineLong.isHidden = isOn
        imgDateArrow.image = UIImage(named: isOn ? "imgDownArrow" : "imgUpArrow")
    }
    
    func setVisiableTime(isOn: Bool, isAnimation: Bool) {
        if (isAnimation) {
            UIView.animate(withDuration: 0.2, animations: {
                self.constTime?.constant = (isOn ? 155 : 48)
                self.layoutIfNeeded()
            })
        } else {
            self.constTime?.constant = (isOn ? 155 : 48)
            self.layoutIfNeeded()
        }
        timePicker.isHidden = !isOn
        viewTimeLineShort.isHidden = !isOn
        viewTimeLineLong.isHidden = isOn
        imgTimeArrow.image = UIImage(named: isOn ? "imgDownArrow" : "imgUpArrow")
    }
    
    func getSleepModeInfo() -> (Bool, Date?) {
        if let _info = parent?.SleepMode {
            if (_info.Extra == "" || _info.Extra == "-") {
                return (true, _info.m_castTimeInfo.m_timeCast)
            } else {
                return (false, nil)
            }
        }
        return (false, nil)
    }
    
    @IBAction func onClick_date(_ sender: Any) {
        let _isHidden = datePicker.isHidden
        setVisiableDate(isOn: _isHidden, isAnimation: true)
        setVisiableTime(isOn: !_isHidden, isAnimation: false)
    }
    
    @IBAction func onClick_time(_ sender: Any) {
        let _isHidden = timePicker.isHidden
        setVisiableTime(isOn: _isHidden, isAnimation: true)
        setVisiableDate(isOn: !_isHidden, isAnimation: false)
    }
    
    @IBAction func onClick_cancle(_ sender: Any) {
        parent?.popupSleepMode(isHidden: true)
    }
    
    @IBAction func onClick_ok(_ sender: Any) {
        let _pickerUtcDate = UI_Utility.localToUTC(date: "\(dateValue)-\(timeValue)", fromType: .yyMMdd_HHmmss, toType: .yyMMdd_HHmmss)
        
        var _isEnabled = false
        var _startTimeInfo: Date?
        (_isEnabled, _startTimeInfo) = getSleepModeInfo()
        
        if (_isEnabled) {
            if let _pickerDate = UI_Utility.convertStringToDate(_pickerUtcDate, type: .yyMMdd_HHmmss) {
                if (_pickerDate < _startTimeInfo!) {
                    _ = PopupManager.instance.onlyContents(contentsKey: "toast_sensor_sleep_than_start_time", confirmType: .ok) // 종료시간이 더 작음
                    return
                }
            }
        }

        let send = Send_SetSleepMode()
        send.aid = DataManager.instance.m_userInfo.account_id
        send.token = DataManager.instance.m_userInfo.token
        send.did = parent!.m_parent!.m_parent!.m_detailInfo!.m_did
        send.enc = parent!.m_parent!.m_parent!.userInfo!.enc
        send.time = _pickerUtcDate
        send.is_start = parent!.swSleepMode.isOn ? 0 : 1 // 현재 스위치 버튼이 아직 활성화 전이라 반대로 동작
        parent!.setMonitoringSleepUI(isSleepMode: !parent!.swSleepMode.isOn, timeInfo: "0분 경과")
        self.parent?.popupSleepMode(isHidden: true)
        self.parent?.m_parent?.m_parent?.isUpdateView = false
        NetworkManager.instance.Request(send) { (json) -> () in
            let receive = Receive_SetSleepMode(json)
            switch receive.ecd {
            case .success:
                DataManager.instance.m_dataController.deviceNoti.updateForDetailView(finishHandler: { () ->() in
                    self.parent!.setMonitoringSleep()
                    self.parent?.m_parent?.m_parent?.isUpdateView = true
                }, isReload: false)
                break
            default:
                self.parent?.m_parent?.m_parent?.isUpdateView = true
                self.parent!.swSleepMode.isOn = !(self.parent!.swSleepMode.isOn)
                Debug.print("[ERROR] invaild errcod", event: .error)
            }
        }
    }
}
