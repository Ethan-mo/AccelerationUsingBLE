//
//  DeviceSensorDetailSensingView_DiaperChange.swift
//  Monit
//
//  Created by john.lee on 16/08/2019.
//  Copyright © 2019 맥. All rights reserved.
//

import UIKit
import AudioToolbox

class DeviceSensorDetailNotiView_SleepMode: UIView, LabelFormDelegate, UITextFieldDelegate {
    @IBOutlet weak var stView: UIStackView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSummary: UILabel!
    
    // set type
    @IBOutlet weak var btnNaps: UIButton!
    @IBOutlet weak var lblNaps: UILabel!
    
    @IBOutlet weak var btnNightSleep: UIButton!
    @IBOutlet weak var lblNightSleep: UILabel!
    
    // timer
    @IBOutlet weak var viewTimer: UIView!
    
    /// set start end time
    // start
    @IBOutlet weak var btnDateStart: UIButton!
    @IBOutlet weak var lblDateStart: UILabel!
    @IBOutlet weak var lblTimeStart: UILabel!
    // end
    @IBOutlet weak var btnDateEnd: UIButton!
    @IBOutlet weak var lblDateEnd: UILabel!
    @IBOutlet weak var lblTimeEnd: UILabel!
    
    // date
    @IBOutlet weak var viewDate: UIView!
    @IBOutlet weak var btnDate: UIButton!
    @IBOutlet weak var lblDateTitle: UILabel!
    @IBOutlet weak var lblDateValue: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var viewDateLineShort: UIView!
    @IBOutlet weak var imgDateArrow: UIImageView!
    @IBOutlet weak var constDate: NSLayoutConstraint!
    
    // time
    @IBOutlet weak var viewTime: UIView!
    @IBOutlet weak var btnTime: UIButton!
    @IBOutlet weak var lblTimeTitle: UILabel!
    @IBOutlet weak var lblTimeValue: UILabel!
    @IBOutlet weak var timePicker: UIDatePicker!
    @IBOutlet weak var viewTimeLineShort: UIView!
    @IBOutlet weak var viewTimeLineLong: UIView!
    @IBOutlet weak var imgTimeArrow: UIImageView!
    @IBOutlet weak var constTime: NSLayoutConstraint!
    
    // memo
    @IBOutlet weak var txtMemoInput: UITextField!
    @IBOutlet weak var lblMemoDefault: UILabel!
    @IBOutlet weak var btnMemoDelete: UIButton!
    
    @IBOutlet weak var btnOk: UIButton!
    @IBOutlet weak var btnCancle: UIButton!
    @IBOutlet weak var btnCenterOk: UIButton!
    @IBOutlet weak var viewCenterLine: UIView!
    
    class TimePicker {
        var lblDate: UILabel!
        var lblTime: UILabel!
        
        init (lblDate: UILabel, lblTime: UILabel) {
            self.lblDate = lblDate
            self.lblTime = lblTime
        }
    }
    
    class TimeSet {
        var dateCast = Date()
        var dateValue: String = ""
        
        var timeCast = Date()
        var timeValue: String = ""
        
        func setDateValue(date: Date) {
            self.dateCast = date
            let componentsDate = Calendar.current.dateComponents([.year, .month, .day], from: date)
            if let day = componentsDate.day, let month = componentsDate.month, let year = componentsDate.year {
                let _year = String(year)
                let _month = month.description.count == 1 ? "0\(month.description)" : month.description
                let _day = day.description.count == 1 ? "0\(day.description)" : day.description
                let _index = _year.index(_year.startIndex, offsetBy: 2)
                let _result = _year[_index...] + _month + _day
                self.dateValue = _result.description
            }
        }
        
        func setTimeValue(date: Date) {
            self.timeCast = date
            let componentsTime = Calendar.current.dateComponents([.hour, .minute, .second], from: date)
            if let hour = componentsTime.hour, let minute = componentsTime.minute, let second = componentsTime.second {
                let _hour = hour.description.count == 1 ? "0\(hour.description)" : hour.description
                let _minute = minute.description.count == 1 ? "0\(minute.description)" : minute.description
                let _second = second.description.count == 1 ? "0\(second.description)" : second.description
                let _result = _hour + _minute + _second
                self.timeValue = _result.description
            }
        }
    }
    
    enum VIEW_TYPE {
        case add
        case edit
    }
    
    enum InputType {
        case timer
        case date
        case time
        case memo
    }
    
    enum TIME_TYPE {
        case none
        case start
        case end
    }
    
    var parent: DeviceSensorDetailNotiForHuggiesViewController?
    var startTimeSet = TimeSet()
    var endTimeSet = TimeSet()
    
    var m_memoForm: LabelFormController?
    var viewType: VIEW_TYPE = .add
    var notiInfo: DeviceNotiInfo?
    var sleepModeType: SLEEP_MODE_TYPE = .none
    var timeType: TIME_TYPE = .none
    
    override func awakeFromNib() {
        datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        timePicker.addTarget(self, action: #selector(timeChanged(_:)), for: .valueChanged)
        txtMemoInput.delegate = self
        
        btnCancle.setTitle("btn_cancel".localized.uppercased(), for: .normal)
        btnOk.setTitle("btn_ok".localized.uppercased(), for: .normal)
    }
    
    // 재호출
    func setInit(type: VIEW_TYPE) {
        self.viewType = type
        UI_Utility.customViewBorder(view: self, radius: 20, width: 1, color: COLOR_TYPE.blue.color.cgColor)
        setUI()
    }
    
    func setEdit(info: DeviceNotiInfo?) {
        self.viewType = .edit
        self.notiInfo = info
        setUI()
        let _extra2Type = SLEEP_MODE_TYPE(rawValue: Int(info?.m_extra2 ?? "0") ?? 0) ?? .none
        setType(type: _extra2Type)
        
        // set datePicker
        inputDataUI(type: .start, date: info?.m_castTimeInfo.m_timeCast ?? Date())
        inputTimeUI(type: .start, date: info?.m_castTimeInfo.m_timeCast ?? Date())
        
        inputDataUI(type: .end, date: info?.m_castExtraTimeInfo?.m_timeCast ?? Date())
        inputTimeUI(type: .end, date: info?.m_castExtraTimeInfo?.m_timeCast ?? Date())
        
        let _memo = info?.m_memo ?? ""
        if (_memo != "-" && _memo != "") {
            txtMemoInput.text = info?.m_memo ?? ""
            m_memoForm?.editing()
        }
        
        viewTimer.isHidden = true
        
        setPopupSize()
    }
    
    func setUI() {
        lblNaps.text = "낮잠"
        lblNightSleep.text = "밤잠"
        
        btnCancle.isHidden = true
        btnOk.isHidden = true
        btnCenterOk.isHidden = true
        viewCenterLine.isHidden = true
        
        btnCenterOk.isHidden = true
        viewCenterLine.isHidden = true
        
        viewTimer.isHidden = false
        
        switch self.viewType {
        case .add:
            btnCenterOk.isHidden = false
            btnCenterOk.setTitle("btn_ok".localized.uppercased(), for: .normal)
        case .edit:
            btnCancle.isHidden = false
            btnOk.isHidden = false
            viewCenterLine.isHidden = false
            btnCancle.setTitle("btn_remove".localized.uppercased(), for: .normal)
            btnOk.setTitle("btn_ok".localized.uppercased(), for: .normal)
        }
        
        if (m_memoForm == nil) { // , maxByte: Config.MAX_BYTE_LENGTH_NAME
            m_memoForm = LabelFormController(txtInput: txtMemoInput, btnDelete: btnMemoDelete, minLength: 1, maxLength: 24, imgCheck: nil)
            m_memoForm!.setDefaultText(lblDefault: lblMemoDefault, defaultText: "이 곳을 터치하여 메모를 입력해주세요.")
            m_memoForm!.setDelegate(delegate: self)
        }
        m_memoForm?.onClick_delete()
        
        setType(type: .none)
        setTimeType(type: .none)
        
        initDateUI()
        initTimeUI()
        setPopupSize()
    }
    
    // 현재 시간으로 설정
    func initDateUI() {
        let _strUTCDate = UI_Utility.nowUTCDate(type: .full)
        let _strLocalDate = UI_Utility.UTCToLocal(date: _strUTCDate, fromType: .full, toType: .full)
        let _localDate = UI_Utility.convertStringToLocalDate(_strLocalDate, type: .full)
        
        datePicker.setDate(_localDate!, animated: false)
        setVisiableDate(isOn: false, isAnimation: false)
        
        let _addLocalData = _localDate?.adding(minutes: 60)
        
        setDateValue(type: .start, date: _localDate!)
        setDateValue(type: .end, date: _addLocalData!)
    }
    
    func inputDataUI(type: TIME_TYPE, date: Date?) {
        datePicker.setDate(date!, animated: false)
        setVisiableDate(isOn: false, isAnimation: false)
 
        setDateValue(type: type, date: date!)
    }
    
    // 현재 시간으로 설정
    func initTimeUI() {
        let _strUTCDate = UI_Utility.nowUTCDate(type: .full)
        let _strLocalDate = UI_Utility.UTCToLocal(date: _strUTCDate, fromType: .full, toType: .full)
        let _localDate = UI_Utility.convertStringToLocalDate(_strLocalDate, type: .full)

        timePicker.setDate(_localDate!, animated: false)
        setVisiableTime(isOn: true, isAnimation: false)
        
        let _addLocalData = _localDate?.adding(minutes: 60)
        
        setTimeValue(type: .start, date: _localDate!)
        setTimeValue(type: .end, date: _addLocalData!)
    }
    
    func inputTimeUI(type: TIME_TYPE, date: Date?) {
        timePicker.setDate(date!, animated: false)
        setVisiableTime(isOn: true, isAnimation: false)
        
        setTimeValue(type: type, date: date!)
    }
    
    @objc func dateChanged(_ sender: UIDatePicker) {
        setDateValue(type: self.timeType, date: sender.date)
    }
    
    @objc func timeChanged(_ sender: UIDatePicker) {
        setTimeValue(type: self.timeType, date: sender.date)
    }
    
    // Date 값 설정 및 라벨 변경
    func setDateValue(type: TIME_TYPE, date: Date) {
        let _dateValue = UI_Utility.getDateByLanguageFromDate(date, language: Config.languageType)
        switch type {
        case .start:
            lblDateStart.text = "\(_dateValue)"
        case .end:
            lblDateEnd.text = "\(_dateValue)"
        default:
            break
        }
        lblDateValue.text = _dateValue
        
        switch type {
        case .start:
            startTimeSet.setDateValue(date: date)
        case .end:
            endTimeSet.setDateValue(date: date)
        default:
            break
        }
    }
    
    // Time 값 설정 및 라벨 변경
    func setTimeValue(type: TIME_TYPE, date: Date) {
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
        switch type {
        case .start:
            lblTimeStart.text = "\(_dateValue)"
        case .end:
            lblTimeEnd.text = "\(_dateValue)"
        default:
            break
        }
        lblTimeValue.text = _dateValue
        
        switch type {
        case .start:
            startTimeSet.setTimeValue(date: date)
        case .end:
            endTimeSet.setTimeValue(date: date)
        default:
            break
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
    
    func setPopupSize() {
        self.layoutIfNeeded()
        let _x = (UIScreen.main.bounds.width / 2) - (stView.frame.width / 2)
        let _y = (UIScreen.main.bounds.height / 2) - (stView.frame.height / 2)
        self.frame = CGRect(x: _x, y: _y, width: stView.frame.width, height: stView.frame.height)
        UI_Utility.customViewBorder(view: self, radius: 20, width: 1, color: COLOR_TYPE.blue.color.cgColor)
    }
    
    func setType(type: SLEEP_MODE_TYPE) {
        self.sleepModeType = type

        btnNaps.setImage(UIImage(named: "imgDiaryNotiType_SleepDisable"), for: .normal)
        lblNaps.textColor = COLOR_TYPE.lblGray.color
        
        btnNightSleep.setImage(UIImage(named: "imgDiaryNotiType_SleepDisable"), for: .normal)
        lblNightSleep.textColor = COLOR_TYPE.lblGray.color
        
        switch type {
        case .none:
            break
        case .naps:
            btnNaps.setImage(UIImage(named: "imgDiaryNotiType_Sleep"), for: .normal)
            lblNaps.textColor = COLOR_TYPE.lblGray.color
        case .night_sleep:
            btnNightSleep.setImage(UIImage(named: "imgDiaryNotiType_Sleep"), for: .normal)
            lblNightSleep.textColor = COLOR_TYPE.lblGray.color
        }
        setPopupSize()
    }
    
    func setTimeType(type: TIME_TYPE) {
        self.timeType = type

        viewDate.isHidden = true
        viewTime.isHidden = true
        btnDateStart.setImage(UIImage(named: "imgDiarySleepStartDateLineDisable"), for: .normal)
        btnDateEnd.setImage(UIImage(named: "imgDiarySleepEndDateLineDisable"), for: .normal)

        switch type {
        case .none: break
        case .start:
            viewDate.isHidden = false
            viewTime.isHidden = false
            btnDateStart.setImage(UIImage(named: "imgDiarySleepStartDateLine"), for: .normal)
            setDateValue(type: .start, date: startTimeSet.dateCast)
            setTimeValue(type: .start, date: startTimeSet.timeCast)
            datePicker.setDate(startTimeSet.dateCast, animated: false)
            timePicker.setDate(startTimeSet.timeCast, animated: false)
        case .end:
            viewDate.isHidden = false
            viewTime.isHidden = false
            btnDateEnd.setImage(UIImage(named: "imgDiarySleepEndDateLine"), for: .normal)
            setDateValue(type: .end, date: endTimeSet.dateCast)
            setTimeValue(type: .end, date: endTimeSet.timeCast)
            datePicker.setDate(endTimeSet.dateCast, animated: false)
            timePicker.setDate(endTimeSet.timeCast, animated: false)
        }
        setPopupSize()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.endEditing(true)
        return true
    }
    
    func setVaildVisible(isVisible: Bool) {
    }
    
    func isCustomVaild() -> Bool? {
        return nil
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
        sendInfo(editType: .delete)
    }
    
    @IBAction func onClick_ok(_ sender: Any) {
        sendInfo(editType: .modify)
    }
    
    @IBAction func onClick_centerOK(_ sender: UIButton) {
        sendInfo(editType: .none)
    }
    
    func sendInfo(editType: NOTI_EDIT_TYPE) {
        let _startUtcDate = UI_Utility.localToUTC(date: "\(startTimeSet.dateValue)-\(startTimeSet.timeValue)", fromType: .yyMMdd_HHmmss, toType: .yyMMdd_HHmmss)
        let _endUtcDate = UI_Utility.localToUTC(date: "\(endTimeSet.dateValue)-\(endTimeSet.timeValue)", fromType: .yyMMdd_HHmmss, toType: .yyMMdd_HHmmss)

        let send = Send_SetSleepMode()
        send.aid = DataManager.instance.m_userInfo.account_id
        send.token = DataManager.instance.m_userInfo.token
        send.did = parent!.m_parent!.m_parent!.m_detailInfo!.m_did
        send.enc = parent!.m_parent!.m_parent!.userInfo!.enc
        if let _info = self.notiInfo {
            send.edit_type = editType.rawValue
            send.nid = _info.m_nid
        }
        if self.sleepModeType != .none {
            send.sleep_type = self.sleepModeType.rawValue
        }
        if (txtMemoInput.text != "") {
            send.memo = Utility.urlEncode(txtMemoInput.text)
        }
        send.time = _startUtcDate
        send.finish_time = _endUtcDate
        NetworkManager.instance.Request(send) { (json) -> () in
            let receive = Receive_SetSleepMode(json)
            switch receive.ecd {
            case .success:
                DataManager.instance.m_dataController.deviceNoti.updateForDetailView()
                break
            default:
                self.parent?.m_parent?.m_parent?.isUpdateView = true
                Debug.print("[ERROR] invaild errcod", event: .error)
            }
        }
        self.removeFromSuperview()
    }
    
    @IBAction func onClick_naps(_ sender: UIButton) {
        setType(type: .naps)
    }
    
    @IBAction func onClick_nightSleep(_ sender: UIButton) {
        setType(type: .night_sleep)
    }
    
    @IBAction func onClick_startTimer(_ sender: Any) {
        SleepModeTimer.startSleepMode()
        SleepModeTimer.sleepModeType = self.sleepModeType
        self.removeFromSuperview()
        self.parent?.sensorSetUI()
    }
    
    @IBAction func editing_memo(_ sender: UITextField) {
        m_memoForm?.editing()
    }
    
    @IBAction func onClick_deleteMemo(_ sender: UIButton) {
        m_memoForm?.onClick_delete()
    }
    
    @IBAction func onClick_closeWindow(_ sender: UIButton) {
        self.removeFromSuperview()
    }
    
    @IBAction func onClick_TimeStart(_ sender: UIButton) {
        setTimeType(type: .start)
    }
    
    @IBAction func onClick_TimeEnd(_ sender: UIButton) {
        setTimeType(type: .end)
    }
}
