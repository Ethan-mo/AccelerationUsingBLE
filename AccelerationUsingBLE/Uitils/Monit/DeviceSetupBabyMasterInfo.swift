//
//  DeviceSetupBabyMasterInfo.swift
//  Monit
//
//  Created by 맥 on 2017. 10. 2..
//  Copyright © 2017년 맥. All rights reserved.
//

import UIKit
import SwiftyJSON

class DeviceSetupBabyMasterInfo: BaseViewController, LabelFormDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    @IBOutlet weak var lblNaviTitle: UILabel!
    @IBOutlet weak var btnNaviNext: UIButton!
    @IBOutlet weak var lblNameTitle: UILabel!
    @IBOutlet weak var lblBirthTitle: UILabel!
    @IBOutlet weak var lblSexTitle: UILabel!
    
    @IBOutlet weak var viewBirthKr: UIView!
    @IBOutlet weak var lblYearKrTitle: UILabel!
    @IBOutlet weak var lblMonthKrTitle: UILabel!
    @IBOutlet weak var lblDayKrTitle: UILabel!
    @IBOutlet weak var lblYearKr: UILabel!
    @IBOutlet weak var lblMonthKr: UILabel!
    @IBOutlet weak var lblDayKr: UILabel!
    
    @IBOutlet weak var viewBirthEn: UIView!
    @IBOutlet weak var lblEn: UILabel!
    @IBOutlet weak var lblBirthEnSummary: UILabel!
    
    @IBOutlet weak var viewBirthZh: UIView!
    @IBOutlet weak var lblYearZhTitle: UILabel!
    @IBOutlet weak var lblMonthZhTitle: UILabel!
    @IBOutlet weak var lblDayZhTitle: UILabel!
    @IBOutlet weak var lblYearZh: UILabel!
    @IBOutlet weak var lblMonthZh: UILabel!
    @IBOutlet weak var lblDayZh: UILabel!

    @IBOutlet weak var imgNameCheck: UIImageView!
    @IBOutlet weak var lblNameDefault: UILabel!
    @IBOutlet weak var txtNameInput: UITextField!
    @IBOutlet weak var btnNameDelete: UIButton!
    
    @IBOutlet weak var imgBirthdayCheck: UIImageView!
    @IBOutlet weak var viewBirthdayLine: UIView!
    @IBOutlet weak var birthPicker: UIPickerView! // 현재 Picker 사용
    @IBOutlet weak var datePicker: UIDatePicker! // 현재 datePicker 사용안함
    @IBOutlet weak var constBirthday: NSLayoutConstraint!
    
    @IBOutlet weak var imgSexCheck: UIImageView!
    @IBOutlet weak var imgMan: UIImageView!
    @IBOutlet weak var imgWomen: UIImageView!
    @IBOutlet weak var btnMan: UIButton!
    @IBOutlet weak var btnWomen: UIButton!
    @IBOutlet weak var constGender: NSLayoutConstraint!
    
    @IBOutlet weak var imgCheckEating: UIImageView!
    @IBOutlet weak var lblEating: UILabel!
    @IBOutlet weak var btnMom: UIButton!
    @IBOutlet weak var btnMilk: UIButton!
    @IBOutlet weak var btnMeal: UIButton!
    @IBOutlet weak var lblEatingSummary: UILabel!
    
    override var screenType: SCREEN_TYPE { get { return .SENSOR_SETUP_BABYINFO } }
    var m_nameForm: LabelFormController?
    var isBirthday = false
    var isGender = false
    var sex = 0
    var m_yymmdd = ""
    var months: [String]!
    var years: [Int]!
    var yearIndex = Config.languageType == .ko ? 0 : 1
    var monthIndex = Config.languageType == .ko ? 1 : 0
    var isEatingMom = false
    var isEatingMilk = false
    var isEatingMeal = false
    var isDatePicker = false // 현재 Picker 사용
    
    var month = Calendar.current.component(.month, from: Date()) {
        didSet {
            birthPicker.selectRow(month-1, inComponent: monthIndex, animated: false)
        }
    }
    
    var year = Calendar.current.component(.year, from: Date()) {
        didSet {
            birthPicker.selectRow(years.index(of: year)!, inComponent: yearIndex, animated: true)
        }
    }
    
    var onDateSelected: ((_ month: Int, _ year: Int) -> Void)?

    var isCheckEating: Bool {
        get {
            return isEatingMom || isEatingMilk || isEatingMeal
        }
    }
    
    var m_detailInfo: DeviceDetailInfo?

    var connectSensor: BleInfo? {
        get {
            return DataManager.instance.m_userInfo.connectSensor.getSensorByDeviceId(deviceId: m_detailInfo!.m_did)
        }
    }
    
    var isConnectBle: Bool {
        get {
            let _bleInfo = DataManager.instance.m_userInfo.connectSensor.getSensorByDeviceId(deviceId: m_detailInfo!.m_did)
            if (_bleInfo != nil) {
                return true
            }
            return false
        }
    }

    var sensorStatusInfo: SensorStatusInfo? {
        get {
            return DataManager.instance.m_userInfo.deviceStatus.m_sensorStatus.getInfoByDeviceId(did: m_detailInfo!.m_did)
        }
    }

    var userInfo: UserInfoDevice? {
        get {
            return DataManager.instance.m_dataController.device.getUserInfoByDid(did: m_detailInfo!.m_did, type: DEVICE_TYPE.Sensor.rawValue)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Debug.print("[UI][\(self.classNameToString()).viewDidLoad()]")
        birthPicker.delegate = self
        birthPicker.dataSource = self
        txtNameInput.delegate = self
        datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        initPickerInfo()
    }
    
    @objc func dateChanged(_ sender: UIDatePicker) {
        let components = Calendar.current.dateComponents([.year, .month, .day], from: sender.date)
        if let day = components.day, let month = components.month, let year = components.year {
            let _year = String(year)
            let _month = month.description.count == 1 ? "0\(month.description)" : month.description
            let _day = day.description.count == 1 ? "0\(day.description)" : day.description
            lblYearKr.text = _year
            lblYearZh.text = _year
            lblMonthKr.text = _month
            lblMonthZh.text = _month
            lblEn.text = UI_Utility.convertDateStringToString("\(_year)\(_month)01", fromType: .yyyyMMdd, toType: .ENGLISH_MONTHLY_dd)
            
            lblYearKr.font = UIFont.boldSystemFont(ofSize: 14)
            lblYearZh.font = UIFont.boldSystemFont(ofSize: 14)
            lblMonthKr.font = UIFont.boldSystemFont(ofSize: 14)
            lblMonthZh.font = UIFont.boldSystemFont(ofSize: 14)
            lblEn.font = UIFont.boldSystemFont(ofSize: 14)
        }
    }
    
    func setEatingUI() {
        lblEating.text = "account_baby_eating".localized
        lblEatingSummary.text = "setting_sensor_eating_summary".localized
        setEatingMom(isEnabled: false)
        setEatingMilk(isEnabled: false)
        setEatingMeal(isEnabled: false)
    }
    
    func setEatingMom(isEnabled: Bool) {
        if (isEnabled) {
            isEatingMom = true
            btnMom.setImage(UIImage(named: "imgBabyInfo_mom"), for: .normal)
        } else {
            isEatingMom = false
            btnMom.setImage(UIImage(named: "imgBabyInfo_momDisable"), for: .normal)
        }
    }
    
    func setEatingMilk(isEnabled: Bool) {
        if (isEnabled) {
            isEatingMilk = true
            btnMilk.setImage(UIImage(named: "imgBabyInfo_milk"), for: .normal)
        } else {
            isEatingMilk = false
            btnMilk.setImage(UIImage(named: "imgBabyInfo_milkDisable"), for: .normal)
        }
    }
    
    func setEatingMeal(isEnabled: Bool) {
        if (isEnabled) {
            isEatingMeal = true
            btnMeal.setImage(UIImage(named: "imgBabyInfo_meal"), for: .normal)
        } else {
            isEatingMeal = false
            btnMeal.setImage(UIImage(named: "imgBabyInfo_mealDisable"), for: .normal)
        }
    }
    
    func setCheckEatingUI() {
        imgCheckEating.image = UIImage(named: isCheckEating ? "imgCheckEnable" : "imgCheck")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUI()
    }
    
    func setUI() {
        if (m_nameForm == nil) { // , maxByte: Config.MAX_BYTE_LENGTH_NAME
            m_nameForm = LabelFormController(txtInput: txtNameInput, btnDelete: btnNameDelete, minLength: 1, maxLength: 24, imgCheck: imgNameCheck)
            m_nameForm!.setDefaultText(lblDefault: lblNameDefault, defaultText: "account_hint_baby_name".localized)
            m_nameForm!.setDelegate(delegate: self)
        }
        
        Debug.print("[SensorSetupMasterBabyInfo] server babyBirthday: \(sensorStatusInfo!.m_bday)")
        Debug.print("[SensorSetupMasterBabyInfo] server babysex: \(sensorStatusInfo!.m_sex)")
        
        birthUIByLanguage(language: Config.languageType)
        if (sensorStatusInfo!.m_bday == "000101" || sensorStatusInfo!.m_bday == "700101") {
            lblYearKr.text = ""
            lblYearZh.text = ""
            lblMonthKr.text = ""
            lblMonthZh.text = ""
            lblEn.text = ""
        } else {
            let _bday = sensorStatusInfo!.m_bday
            Debug.print("[SensorSetupMasterBabyInfo] sensorStatus bday: \(_bday)")
            txtNameInput.text = sensorStatusInfo!.m_name

            // set datePicker
            datePicker.setDate(UI_Utility.convertStringToDate(_bday, type: .yyMMdd) ?? Date(), animated: false)
            
            // set birthPicker
            let _yyyy = UI_Utility.convertDateStringToString(_bday, fromType: .yyMMdd, toType: .yyyy)
            let _MM = UI_Utility.convertDateStringToString(_bday, fromType: .yyMMdd, toType: .MM)
            birthPicker.selectRow(Int(_MM)!-1, inComponent: monthIndex, animated: false)
            birthPicker.selectRow(years.index(of: Int(_yyyy)!)!, inComponent: yearIndex, animated: false)
            
            setBirthday()
            selectGenderUI(SEX.man == SEX(rawValue: sensorStatusInfo!.m_sex) ? true : false)
            m_nameForm?.editing(isTrim: false)
            
            setEatingUI()
            let _eat = sensorStatusInfo!.m_eat
            if (_eat == 1 || _eat == 3 || _eat == 5 || _eat == 7) {
                setEatingMom(isEnabled: true)
            }
            if (_eat == 2 || _eat == 3 || _eat == 6 || _eat == 7) {
                setEatingMilk(isEnabled: true)
            }
            if (_eat == 4  || _eat == 5 || _eat == 6 || _eat == 7) {
                setEatingMeal(isEnabled: true)
            }
            setCheckEatingUI()
        }
        
        viewBirthdayLine.isHidden = true
        birthPicker.isHidden = true
        datePicker.isHidden = true
        
        lblNaviTitle.text = "setting_device_babyinfo".localized
        btnNaviNext.setTitle("btn_save".localized.uppercased(), for: .normal)
        lblNameTitle.text = "account_baby_name".localized
        lblBirthTitle.text = "account_baby_birthday".localized
        lblBirthTitle.setLineSpacing(lineSpacing: 0, lineHeightMultiple: 0.8)
        lblYearKrTitle.text = "time_year_short".localized
        lblYearZhTitle.text = "time_year_short".localized
        lblMonthKrTitle.text = "time_month_short".localized
        lblMonthZhTitle.text = "time_month_short".localized
        lblDayKrTitle.text = "time_day_short".localized
        lblDayZhTitle.text = "time_day_short".localized
        lblBirthEnSummary.text = "account_hint_birthday".localized
        lblSexTitle.text = "account_baby_sex".localized
        btnMan.setTitle("gender_male".localized.uppercased(), for: .normal)
        btnWomen.setTitle("gender_female".localized.uppercased(), for: .normal)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if (yearIndex == component) {
            return "\(years[row])"
        } else if (monthIndex == component) {
            return months[row]
        }
        return nil
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if (yearIndex == component) {
            return years.count
        } else if (monthIndex == component) {
            return months.count
        }
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let year = years[birthPicker.selectedRow(inComponent: yearIndex)]
        let month = birthPicker.selectedRow(inComponent: monthIndex) + 1
        if let block = onDateSelected {
            block(month, year)
        }
        
        self.month = month
        self.year = year
        let _year = String(year)
        let _month = (String(month).count == 1 ? "0" + String(month) : String(month))
        lblYearKr.text = _year
        lblYearZh.text = _year
        lblMonthKr.text = _month
        lblMonthZh.text = _month
        lblEn.text = UI_Utility.convertDateStringToString("\(_year)\(_month)01", fromType: .yyyyMMdd, toType: .ENGLISH_MONTHLY_dd)
        
        lblYearKr.font = UIFont.boldSystemFont(ofSize: 14)
        lblYearZh.font = UIFont.boldSystemFont(ofSize: 14)
        lblMonthKr.font = UIFont.boldSystemFont(ofSize: 14)
        lblMonthZh.font = UIFont.boldSystemFont(ofSize: 14)
        lblEn.font = UIFont.boldSystemFont(ofSize: 14)
    }
    
    func initPickerInfo() {
        // population years
        var years: [Int] = []
        if years.count == 0 {
            var year = NSCalendar(identifier: NSCalendar.Identifier.gregorian)!.component(.year, from: NSDate() as Date)
            for _ in 1...100 {
                years.append(year + 1)
                year -= 1
            }
        }
        self.years = years
        
        // population months with localized names
        var months: [String] = []
        var month = 0
        for _ in 1...12 {
            months.append(DateFormatter().monthSymbols[month].capitalized)
            month += 1
        }
        self.months = months
        
        let currentMonth = NSCalendar(identifier: NSCalendar.Identifier.gregorian)!.component(.month, from: NSDate() as Date)
        birthPicker.selectRow(currentMonth - 1, inComponent: monthIndex, animated: false)
    }

    func isCustomVaild() -> Bool? {
        return nil
    }
    
    func setVaildVisible(isVisible: Bool) {
    }
    
    func birthdayUI()
    {
        lblBirthEnSummary.isHidden = true
        UIView.animate(withDuration: 0.5, animations: {
            self.constBirthday.constant = 200
            self.view.layoutIfNeeded()
        }, completion: { (bool) in
            self.viewBirthdayLine.isHidden = false
            if (self.isDatePicker) {
                self.datePicker.isHidden = false
            } else {
                self.birthPicker.isHidden = false
            }
        })
    }
    
    func selectGenderUI(_ isman: Bool)
    {
        if (isman) {
            sex = SEX.man.rawValue
        } else {
            sex = SEX.women.rawValue
        }

        isGender = true
        imgMan.image = UIImage(named: "imgCheckRound")
        imgWomen.image = UIImage(named: "imgCheckRound")
        btnMan.setTitleColor(COLOR_TYPE.lblGray.color, for: .normal)
        btnWomen.setTitleColor(COLOR_TYPE.lblGray.color, for: .normal)
        
        if (isman) {
            imgMan.image = UIImage(named: "imgCheckRoundEnable")
            btnMan.setTitleColor(COLOR_TYPE.mint.color, for: .normal)
        } else {
            imgWomen.image = UIImage(named: "imgCheckRoundEnable")
            btnWomen.setTitleColor(COLOR_TYPE.mint.color, for: .normal)
        }
        
        imgSexCheck.image = UIImage(named: "imgCheckEnable")
    }
    
    func needVaildPopup(_ key: String)
    {
        _ = PopupManager.instance.onlyContents(contentsKey: key, confirmType: .ok)
    }
    
    func birthUIByLanguage(language: LANGUAGE_TYPE) {
        viewBirthKr.isHidden = true
        viewBirthEn.isHidden = true
        viewBirthZh.isHidden = true
        switch language {
        case .ko:
            viewBirthKr.isHidden = false
            break
        case .jp:
            viewBirthZh.isHidden = false
            break
        case .zh:
            viewBirthZh.isHidden = false
            break
        case .en:
            viewBirthEn.isHidden = false
            break
        default:
            viewBirthZh.isHidden = false
            break
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func editing_nickname(_ sender: UITextField) {
//        let _buf = [UInt8](txtNameInput.text!.utf8)
//        if (_buf.count > Config.MAX_BYTE_LENGTH_NAME) {
//            txtNameInput.deleteBackward()
//        }
        m_nameForm?.editing(isTrim: false, isRemoveSpecialChar: true)
    }
    
    @IBAction func onClick_deleteName(_ sender: UIButton) {
        m_nameForm?.onClick_delete()
    }
    
    @IBAction func onClick_Back(_ sender: UIButton) {
        UIManager.instance.sceneMoveNaviPop()
    }
    
    @IBAction func onClick_Next(_ sender: UIButton) {
        if (!m_nameForm!.m_isVaild) {
            needVaildPopup("device_warning_dialog_babyname")
        } else if (!isBirthday) {
            needVaildPopup("account_warning_birthday")
        } else if (!isGender) {
            needVaildPopup("account_warning_gender")
        } else if (!isCheckEating) {
            needVaildPopup("account_warning_eating")
        } else {
//            let month = birthPicker.selectedRow(inComponent: 0)+1
//            let year = years[birthPicker.selectedRow(inComponent: 1)]
            
            m_yymmdd = ""
//            m_yymmdd += year.description[year.description.index(year.description.startIndex, offsetBy: 2)...]
//            m_yymmdd += month.description.count == 1 ? "0\(month.description)" : month.description
//            m_yymmdd += "01"
            m_yymmdd += lblYearKr.text!.suffix(2) // 모든 국가별로 값을 넣었으므로 kr만 사용해서 값을 가져온다.
            m_yymmdd += lblMonthKr.text!
            m_yymmdd += isDatePicker ?  lblDayKr.text! : "01"
            if (isConnectBle) {
//                connectSensor!.controller!.m_packetCommend!.setName(name: txtNameInput.text!)
                connectSensor!.controller!.m_packetCommend!.setBabyInfo(bday: m_yymmdd, sex: sex)
            }
            sensorStatusInfo!.m_bday = m_yymmdd
            sensorStatusInfo!.m_eat = (isEatingMom ? 1 : 0) + (isEatingMilk ? 2 : 0) + (isEatingMeal ? 4 : 0)
            
            let _send = Send_SetBabyInfo()
            _send.aid = DataManager.instance.m_userInfo.account_id
            _send.token = DataManager.instance.m_userInfo.token
            _send.type = DEVICE_TYPE.Sensor.rawValue
            _send.did = m_detailInfo!.m_did
            _send.enc = userInfo!.enc
            _send.name = Utility.urlEncode(txtNameInput.text!)
            _send.bday = lblYearKr.text! + lblMonthKr.text! + (isDatePicker ?  lblDayKr.text! : "01")
            _send.sex = sex
            _send.eat = (isEatingMom ? 1 : 0) + (isEatingMilk ? 2 : 0) + (isEatingMeal ? 4 : 0)
            NetworkManager.instance.Request(_send) { (json) -> () in
                self.receive(json)
            }
        }
    }
    
    func receive(_ json: JSON) {
        let receive = Receive_SetBabyInfo(json)
        switch receive.ecd {
        case .success:
            DataManager.instance.m_dataController.device.m_sensor.updateBabyInfo(did: m_detailInfo!.m_did, name: txtNameInput.text!, bday: m_yymmdd, sex: sex)
            UIManager.instance.sceneMoveNaviPop()
        default:
            Debug.print("[ERROR] Receive_SetBabyInfo invaild errcod", event: .error)
            let _errStr = String(format: "dialog_contents_err_communication_with_server".localized, APP_ERR_COD.Send_SetBabyInfo.rawValue)
            _ = PopupManager.instance.onlyContentsCustom(contents: _errStr, confirmType: .ok, okHandler: { () -> () in
            })
        }
    }

    @IBAction func onClick_Birthday(_ sender: UIButton) {
        setBirthday()
    }
    
    func setBirthday() {
        birthdayUI()
//        let month = birthPicker.selectedRow(inComponent: 0)+1
//        let year = years[birthPicker.selectedRow(inComponent: 1)]
//        lblYear.text = String(year)
//        lblMonth.text = (String(month).count == 1 ? "0" + String(month) : String(month))
        
        let componenets = Calendar.current.dateComponents([.year, .month, .day], from: datePicker.date)
        if let day = componenets.day, let month = componenets.month, let year = componenets.year {
            let _year = String(year)
            let _month = (String(month).count == 1 ? "0" + String(month) : String(month))
            let _day = (String(day).count == 1 ? "0" + String(day) : String(day))
            lblYearKr.text = _year
            lblYearZh.text = _year
            lblMonthKr.text = _month
            lblMonthZh.text = _month
            lblEn.text = UI_Utility.convertDateStringToString("\(_year)\(_month)01", fromType: .yyyyMMdd, toType: .ENGLISH_MONTHLY_dd)
            
            lblYearKr.font = UIFont.boldSystemFont(ofSize: 14)
            lblYearZh.font = UIFont.boldSystemFont(ofSize: 14)
            lblMonthKr.font = UIFont.boldSystemFont(ofSize: 14)
            lblMonthZh.font = UIFont.boldSystemFont(ofSize: 14)
            lblEn.font = UIFont.boldSystemFont(ofSize: 14)
        }
        
        imgBirthdayCheck.image = UIImage(named: "imgCheckEnable")
        isBirthday = true
    }
    
    @IBAction func onClick_Man(_ sender: UIButton) {
        selectGenderUI(true)
    }
    
    @IBAction func onClick_Women(_ sender: UIButton) {
        selectGenderUI(false)
    }

    @IBAction func onClick_EatingMom(_ sender: Any) {
        setEatingMom(isEnabled: !isEatingMom)
        setCheckEatingUI()
    }
    
    @IBAction func onClick_EatingMilk(_ sender: Any) {
        setEatingMilk(isEnabled: !isEatingMilk)
        setCheckEatingUI()
    }
    
    @IBAction func onClick_EatingMeal(_ sender: Any) {
        setEatingMeal(isEnabled: !isEatingMeal)
        setCheckEatingUI()
    }
}
