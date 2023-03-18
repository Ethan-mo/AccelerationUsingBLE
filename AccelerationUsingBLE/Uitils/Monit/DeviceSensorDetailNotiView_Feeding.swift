//
//  DeviceSensorDetailNotiView_Feeding.swift
//  Monit
//
//  Created by john.lee on 2020/06/26.
//  Copyright © 2020 맥. All rights reserved.
//

import UIKit

class DeviceSensorDetailNotiView_Feeding: UIView, LabelFormDelegate, UITextFieldDelegate {
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSummary: UILabel!
    @IBOutlet weak var stConst: NSLayoutConstraint!
    @IBOutlet weak var stView: UIStackView!
    
    // buttons
    @IBOutlet weak var btnBreastMilk: UIButton!
    @IBOutlet weak var lblBreastMilkTitle: UILabel!
    
    @IBOutlet weak var btnFeedingMilk: UIButton!
    @IBOutlet weak var lblFeedingMilkTitle: UILabel!
    
    @IBOutlet weak var btnFeedingMeal: UIButton!
    @IBOutlet weak var lblFeedingMealTitle: UILabel!
    
    @IBOutlet weak var btnBreastFeeding: UIButton!
    @IBOutlet weak var lblBreastFeedingTitle: UILabel!
    
    // timer
    @IBOutlet weak var viewTimer: UIView!
    
    // date
    @IBOutlet weak var btnDate: UIButton!
    @IBOutlet weak var lblDateTitle: UILabel!
    @IBOutlet weak var lblDateValue: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var viewDateLineShort: UIView!
    @IBOutlet weak var viewDateLineLong: UIView!
    @IBOutlet weak var imgDateArrow: UIImageView!
    @IBOutlet weak var constDate: NSLayoutConstraint!
    
    // time
    @IBOutlet weak var btnTime: UIButton!
    @IBOutlet weak var lblTimeTitle: UILabel!
    @IBOutlet weak var lblTimeValue: UILabel!
    @IBOutlet weak var timePicker: UIDatePicker!
    @IBOutlet weak var viewTimeLineShort: UIView!
    @IBOutlet weak var viewTimeLineLong: UIView!
    @IBOutlet weak var imgTimeArrow: UIImageView!
    @IBOutlet weak var constTime: NSLayoutConstraint!
    
    // amount
    @IBOutlet weak var btnAmount: UIButton!
    @IBOutlet weak var viewAmount: UIView!
    @IBOutlet weak var lblAmountTitle: UILabel!
    @IBOutlet weak var txtAmountValue: UITextField!
    @IBOutlet weak var viewAmountLineShort: UIView!
    @IBOutlet weak var viewAmountLineLong: UIView!
    @IBOutlet weak var viewAmountValueControl: UIView!
    @IBOutlet weak var constAmount: NSLayoutConstraint!
    
    // term
    @IBOutlet weak var btnTerm: UIButton!
    @IBOutlet weak var viewTerm: UIView!
    @IBOutlet weak var lblTermTitle: UILabel!
    @IBOutlet weak var txtTermValue: UITextField!
    @IBOutlet weak var viewTermLineShort: UIView!
    @IBOutlet weak var viewTermLineLong: UIView!
    @IBOutlet weak var viewTermValueControl: UIView!
    @IBOutlet weak var constTerm: NSLayoutConstraint!
    
    // memo
    @IBOutlet weak var txtMemoInput: UITextField!
    @IBOutlet weak var lblMemoDefault: UILabel!
    @IBOutlet weak var btnMemoDelete: UIButton!
    
    @IBOutlet weak var btnOk: UIButton!
    @IBOutlet weak var btnCancle: UIButton!
    @IBOutlet weak var btnCenterOk: UIButton!
    @IBOutlet weak var viewCenterLine: UIView!
    
    enum VIEW_TYPE {
        case add
        case edit
    }
    
    var notiViewController: DeviceSensorDetailNotiForHuggiesViewController?
    var dateValue: String = ""
    var timeValue: String = ""
    var feedingType: DEVICE_NOTI_TYPE = .breast_feeding
    var m_memoForm: LabelFormController?
    var viewType: VIEW_TYPE = .add
    var notiInfo: DeviceNotiInfo?
    
    private var amountValue: Int = 0
    var AmountValue: Int {
        get {
            return amountValue
        }
        set {
            amountValue = newValue
            if (amountValue <= 0) {
                amountValue = 0
            }
            txtAmountValue.text = amountValue.description
        }
    }
    
    private var termValue: Int = 0
    var TermValue: Int {
        get {
            return termValue
        }
        set{
            termValue = newValue
            if (termValue <= 0) {
                termValue = 0
            }
            txtTermValue.text = termValue.description
        }
    }
    
    enum InputType {
        case timer
        case date
        case time
        case amount
        case term
        case memo
    }
    
    override func awakeFromNib() {
        datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        timePicker.addTarget(self, action: #selector(timeChanged(_:)), for: .valueChanged)
        txtAmountValue.delegate = self
        txtTermValue.delegate = self
        txtMemoInput.delegate = self
    }
    
    // 재호출
    func setInit(type: VIEW_TYPE) {
        self.viewType = type
        setUI()
    }
    
    func setEdit(info: DeviceNotiInfo?) {
        self.viewType = .edit
        self.notiInfo = info
        setUI()
        setType(type: info?.notiType ?? .breast_milk)
        
        switch self.feedingType {
        case .breast_milk:
            var _total = 0
            let _totalInfo = info?.Extra ?? ""
            if (_totalInfo != "" && _totalInfo != "-") {
                _total = Int(_totalInfo) ?? 0
            } else {
                let _leftInfo = info?.m_extra2 ?? ""
                if (_leftInfo != "" && _leftInfo != "-") {
                    _total += Int(_leftInfo) ?? 0
                }
                let _rightInfo = info?.m_extra3 ?? ""
                if (_rightInfo != "" && _rightInfo != "-") {
                    _total += Int(_rightInfo) ?? 0
                }
            }
            txtTermValue.text = _total.description
        case .breast_feeding,
             .feeding_milk,
             .feeding_meal:
            txtAmountValue.text = "\(info?.Extra ?? "")"
        default:
            break
        }
        
        // set datePicker
        inputDataUI(date: info?.m_castTimeInfo.m_timeCast ?? Date())
        inputTimeUI(date: info?.m_castTimeInfo.m_timeCast ?? Date())
        
        let _memo = info?.m_memo ?? ""
        if (_memo != "-" && _memo != "") {
            txtMemoInput.text = info?.m_memo ?? ""
            m_memoForm?.editing()
        }
    }
    
    func setUI() {
        lblBreastMilkTitle.text = "모유"
        lblFeedingMilkTitle.text = "분유"
        lblFeedingMealTitle.text = "이유식"
        lblBreastFeedingTitle.text = "유축"
        
        btnCancle.isHidden = true
        btnOk.isHidden = true
        btnCenterOk.isHidden = true
        viewCenterLine.isHidden = true
        
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
        
        txtAmountValue.keyboardType = .numberPad
        txtAmountValue.addDoneCancelToolbar(doneString: "btn_done".localized.uppercased(), cancelString: nil, onDone: (target: self, action: #selector(doneButtonTappedForMyNumericTextField)))
        txtTermValue.keyboardType = .numberPad
        txtTermValue.addDoneCancelToolbar(doneString: "btn_done".localized.uppercased(), cancelString: nil, onDone: (target: self, action: #selector(doneButtonTappedForMyNumericTextField)))
        
        if (m_memoForm == nil) { // , maxByte: Config.MAX_BYTE_LENGTH_NAME
            m_memoForm = LabelFormController(txtInput: txtMemoInput, btnDelete: btnMemoDelete, minLength: 1, maxLength: 24, imgCheck: nil)
            m_memoForm!.setDefaultText(lblDefault: lblMemoDefault, defaultText: "이 곳을 터치하여 메모를 입력해주세요.")
            m_memoForm!.setDelegate(delegate: self)
        }
        m_memoForm?.onClick_delete()
        
        setType(type: .breast_milk)
        
        initDateUI()
        initTimeUI()
        setPopupSize()
    }
    
    @objc func doneButtonTappedForMyNumericTextField() {
        self.endEditing(true)
        txtAmountValue.resignFirstResponder()
    }
    
    func initDateUI() {
        let _strUTCDate = UI_Utility.nowUTCDate(type: .full)
        let _strLocalDate = UI_Utility.UTCToLocal(date: _strUTCDate, fromType: .full, toType: .full)
        let _localDate = UI_Utility.convertStringToLocalDate(_strLocalDate, type: .full)
        
        datePicker.setDate(_localDate!, animated: false)
        setVisiableDate(isOn: false, isAnimation: false)
        setVisiableAmount(isOn: false, isAnimation: false)
        setVisiableTerm(isOn: false, isAnimation: false)
        
        setDateValue(date: _localDate!)
    }
    
    func inputDataUI(date: Date?) {
        datePicker.setDate(date!, animated: false)
        setVisiableDate(isOn: false, isAnimation: false)
        setVisiableAmount(isOn: false, isAnimation: false)
        setVisiableTerm(isOn: false, isAnimation: false)
        
        setDateValue(date: date!)
    }
    
    func initTimeUI() {
        let _strUTCDate = UI_Utility.nowUTCDate(type: .full)
        let _strLocalDate = UI_Utility.UTCToLocal(date: _strUTCDate, fromType: .full, toType: .full)
        let _localDate = UI_Utility.convertStringToLocalDate(_strLocalDate, type: .full)

        timePicker.setDate(_localDate!, animated: false)
        setVisiableTime(isOn: true, isAnimation: false)
        
        setTimeValue(date: _localDate!)
    }
    
    func inputTimeUI(date: Date?) {
        timePicker.setDate(date!, animated: false)
        setVisiableTime(isOn: true, isAnimation: false)
        
        setTimeValue(date: date!)
    }
    
    func setPopupSize() {
        self.layoutIfNeeded()
        let _x = (UIScreen.main.bounds.width / 2) - (stView.frame.width / 2)
        let _y = (UIScreen.main.bounds.height / 2) - (stView.frame.height / 2)
        self.frame = CGRect(x: _x, y: _y, width: stView.frame.width, height: stView.frame.height)
        UI_Utility.customViewBorder(view: self, radius: 20, width: 1, color: COLOR_TYPE.blue.color.cgColor)
    }
    
    func setType(type: DEVICE_NOTI_TYPE) {
        self.feedingType = type
        viewTimer.isHidden = true
        viewAmount.isHidden = true
        viewTerm.isHidden = true
        
        btnBreastMilk.setImage(UIImage(named: "imgDiaryNotiType_BreastMilkDisable"), for: .normal)
        lblBreastMilkTitle.textColor = COLOR_TYPE.lblGray.color
        
        btnFeedingMilk.setImage(UIImage(named: "imgDiaryNotiType_MilkDisable"), for: .normal)
        lblFeedingMilkTitle.textColor = COLOR_TYPE.lblGray.color
        
        btnFeedingMeal.setImage(UIImage(named: "imgDiaryNotiType_MealDisable"), for: .normal)
        lblFeedingMealTitle.textColor = COLOR_TYPE.lblGray.color
        
        btnBreastFeeding.setImage(UIImage(named: "imgDiaryNotiType_BreastFeedingDisable"), for: .normal)
        lblBreastFeedingTitle.textColor = COLOR_TYPE.lblGray.color
        
        switch type {
        case .breast_milk:
            btnBreastMilk.setImage(UIImage(named: "imgDiaryNotiType_BreastMilk"), for: .normal)
            lblBreastMilkTitle.textColor = COLOR_TYPE.lblGray.color
            viewTimer.isHidden = false
            viewTerm.isHidden = false
        case .feeding_milk:
            btnFeedingMilk.setImage(UIImage(named: "imgDiaryNotiType_Milk"), for: .normal)
            lblFeedingMilkTitle.textColor = COLOR_TYPE.lblGray.color
            viewAmount.isHidden = false
        case .feeding_meal:
            btnFeedingMeal.setImage(UIImage(named: "imgDiaryNotiType_Meal"), for: .normal)
            lblFeedingMealTitle.textColor = COLOR_TYPE.lblGray.color
            viewAmount.isHidden = false
        case .breast_feeding:
            btnBreastFeeding.setImage(UIImage(named: "imgDiaryNotiType_BreastFeeding"), for: .normal)
            lblBreastFeedingTitle.textColor = COLOR_TYPE.lblGray.color
            viewAmount.isHidden = false
        default:
            break
        }
        setPopupSize()
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
                self.setPopupSize()
            })
        } else {
            self.constDate?.constant = (isOn ? 155 : 48)
            self.layoutIfNeeded()
            self.setPopupSize()
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
                self.setPopupSize()
            })
        } else {
            self.constTime?.constant = (isOn ? 155 : 48)
            self.layoutIfNeeded()
            self.setPopupSize()
        }
        timePicker.isHidden = !isOn
        viewTimeLineShort.isHidden = !isOn
        viewTimeLineLong.isHidden = isOn
        imgTimeArrow.image = UIImage(named: isOn ? "imgDownArrow" : "imgUpArrow")
    }
    
    func setVisiableAmount(isOn: Bool, isAnimation: Bool) {
        if (isAnimation) {
            UIView.animate(withDuration: 0.2, animations: {
                self.constAmount?.constant = (isOn ? 110 : 48)
                self.layoutIfNeeded()
                self.setPopupSize()
            })
        } else {
            self.constAmount?.constant = (isOn ? 110 : 48)
            self.layoutIfNeeded()
            self.setPopupSize()
        }
        viewAmountValueControl.isHidden = !isOn
        viewAmountLineShort.isHidden = !isOn
        viewAmountLineLong.isHidden = isOn
    }
    
    func setVisiableTerm(isOn: Bool, isAnimation: Bool) {
        if (isAnimation) {
            UIView.animate(withDuration: 0.2, animations: {
                self.constTerm?.constant = (isOn ? 110 : 48)
                self.layoutIfNeeded()
                self.setPopupSize()
            })
        } else {
            self.constTerm?.constant = (isOn ? 110 : 48)
            self.layoutIfNeeded()
            self.setPopupSize()
        }
        viewTermValueControl.isHidden = !isOn
        viewTermLineShort.isHidden = !isOn
        viewTermLineLong.isHidden = isOn
    }
    
    func visiableReset(type: InputType) {
        setVisiableDate(isOn: false, isAnimation: false)
        setVisiableTime(isOn: false, isAnimation: false)
        btnAmount.isHidden = false
        setVisiableAmount(isOn: false, isAnimation: false)
        btnTerm.isHidden = false
        setVisiableTerm(isOn: false, isAnimation: false)
        
        switch type {
        case .date:
            setVisiableDate(isOn: true, isAnimation: true)
        case .time:
            setVisiableTime(isOn: true, isAnimation: true)
        case .amount:
            btnAmount.isHidden = true
            setVisiableAmount(isOn: true, isAnimation: true)
        case .term:
            btnTerm.isHidden = true
            setVisiableTerm(isOn: true, isAnimation: true)
        default:
            break
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.endEditing(true)
        txtTermValue.resignFirstResponder()
        txtAmountValue.resignFirstResponder()
        return true
    }
    
    func setVaildVisible(isVisible: Bool) {
    }
    
    func isCustomVaild() -> Bool? {
        return nil
    }
    
    @IBAction func onClick_date(_ sender: Any) {
        visiableReset(type: .date)
    }
    
    @IBAction func onClick_time(_ sender: Any) {
        visiableReset(type: .time)
    }
    
    @IBAction func onClick_Amount(_ sender: UIButton) {
        visiableReset(type: .amount)
    }
    
    @IBAction func onClick_Term(_ sender: UIButton) {
        visiableReset(type: .term)
    }
    
    @IBAction func onClick_cancle(_ sender: Any) { // remove button
        sendInfo(editType: .delete)
    }
    
    @IBAction func onClick_ok(_ sender: Any) {
        sendInfo(editType: .modify)
    }
    
    @IBAction func onClick_centerOK(_ sender: UIButton) {
        sendInfo(editType: .none)
    }
    
    func sendInfo(editType: NOTI_EDIT_TYPE) {
        let _utcDate = UI_Utility.localToUTC(date: "\(dateValue)-\(timeValue)", fromType: .yyMMdd_HHmmss, toType: .yyMMdd_HHmmss)
        
        let send = Send_SetFeeding()
        send.aid = DataManager.instance.m_userInfo.account_id
        send.token = DataManager.instance.m_userInfo.token
        send.type = DEVICE_TYPE.Sensor.rawValue
        send.did = notiViewController!.m_parent!.m_parent!.m_detailInfo!.m_did
        send.enc = notiViewController!.m_parent!.m_parent!.userInfo!.enc
        if let _info = self.notiInfo {
            send.edit_type = editType.rawValue
            send.nid = _info.m_nid
        }
        send.time = _utcDate
        send.feeding_type = self.feedingType.rawValue
        switch self.feedingType {
        case .breast_milk:
            send.total = Int(txtTermValue.text ?? "0")
        case .breast_feeding,
             .feeding_milk,
             .feeding_meal:
            send.total = Int(txtAmountValue.text ?? "0")
        default:
            break
        }
        
        if (txtMemoInput.text != "") {
            send.memo = Utility.urlEncode(txtMemoInput.text)
        }
        
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
        self.removeFromSuperview()
    }
    
    @IBAction func onClick_BreastMilk(_ sender: UIButton) {
        setType(type: DEVICE_NOTI_TYPE.breast_milk)
    }
    
    @IBAction func onClick_Milk(_ sender: UIButton) {
        setType(type: DEVICE_NOTI_TYPE.feeding_milk)
    }
    
    @IBAction func onClick_Meal(_ sender: UIButton) {
        setType(type: DEVICE_NOTI_TYPE.feeding_meal)
    }
    
    @IBAction func onClick_BreastFeeding(_ sender: UIButton) {
        setType(type: DEVICE_NOTI_TYPE.breast_feeding)
    }
    
    @IBAction func edit_amountValue(_ sender: UITextField) {
        AmountValue = Int(sender.text ?? "") ?? 0
    }
    
    @IBAction func edit_termValue(_ sender: UITextField) {
        TermValue = Int(sender.text ?? "") ?? 0
    }
    
    @IBAction func onClick_amountIncrease1(_ sender: UIButton) {
        AmountValue -= 10
    }
    
    @IBAction func onClick_amountIncrease2(_ sender: UIButton) {
        AmountValue -= 5
    }
    
    @IBAction func onClick_amountIncrease3(_ sender: UIButton) {
        AmountValue += 5
    }
    
    @IBAction func onClick_amountIncrease4(_ sender: UIButton) {
        AmountValue += 10
    }
    
    @IBAction func onClick_termIncrease1(_ sender: UIButton) {
        TermValue -= 10
    }
    
    @IBAction func onClick_termIncrease2(_ sender: UIButton) {
        TermValue -= 1
    }
    
    @IBAction func onClick_termIncrease3(_ sender: UIButton) {
        TermValue += 1
    }
    
    @IBAction func onClick_termIncrease4(_ sender: UIButton) {
        TermValue += 10
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
    
    @IBAction func onClick_timer(_ sender: Any) {
        BreastMilkTimer.playType(playType: .ready, directionType: .none)
        self.removeFromSuperview()
        self.notiViewController?.sensorSetUI()
    }
}
