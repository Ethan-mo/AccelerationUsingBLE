//
//  DeviceRegisterSensorBabyViewController.swift
//  Monit
//
//  Created by 맥 on 2017. 9. 13..
//  Copyright © 2017년 맥. All rights reserved.
//

import UIKit
import CoreBluetooth
import SwiftyJSON

class DeviceRegisterSensorBabyViewController: BaseViewController, LabelFormDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    @IBOutlet weak var lblNaviTitle: UILabel!
    @IBOutlet weak var btnNaviNext: UIButton!
    @IBOutlet weak var lblContentTitle: UIButton!
    @IBOutlet weak var lblContentSummary: UIButton!
    @IBOutlet weak var lblNicknameTitle: UILabel!
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
    
    @IBOutlet weak var imgCheckName: UIImageView!
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var lblNameSub: UILabel!
    @IBOutlet weak var btnNameDelete: UIButton!
    
    @IBOutlet weak var imgCheckSex: UIImageView!
    @IBOutlet weak var imgCheckMan: UIImageView!
    @IBOutlet weak var imgCheckWomen: UIImageView!
    @IBOutlet weak var btnCheckMan: UIButton!
    @IBOutlet weak var btnCheckWomen: UIButton!
    
    @IBOutlet weak var imgCheckBirthday: UIImageView!
    @IBOutlet weak var imgBirthdayLine: UIView!
    @IBOutlet weak var imgBirthdayBottomLine: UIView!
    @IBOutlet weak var birthPicker: UIPickerView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var constBirthday: NSLayoutConstraint!
    
    @IBOutlet weak var imgCheckEating: UIImageView!
    @IBOutlet weak var lblEating: UILabel!
    @IBOutlet weak var btnMom: UIButton!
    @IBOutlet weak var btnMilk: UIButton!
    @IBOutlet weak var btnMeal: UIButton!
    @IBOutlet weak var lblEatingSummary: UILabel!
    
    
    override var screenType: SCREEN_TYPE { get { return .SENSOR_REGISTER_BABY_INFO } }
    var m_nameForm: LabelFormController?
    var isBirthday = false
    var isGender = false
    var sex = 0
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

    var m_peripheral: CBPeripheral?
    var m_bleInfo: BleInfo? {
        get {
            return DataManager.instance.m_userInfo.connectSensor.getSensorByPeripheral(peripheral: m_peripheral)
        }
    }
    
    override func viewDidLoad() {
        m_category = .registerSensor
        isKeyboardFrameUp = true
        isUpdateView = false
        super.viewDidLoad()
        Debug.print("[UI][\(self.classNameToString()).viewDidLoad()]")
        birthPicker.delegate = self
        birthPicker.dataSource = self
        txtName.delegate = self
        datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        
        initPickerInfo()
        m_bleInfo?.controller?.setCloudId()
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
            lblDayKr.text = _day
            lblDayZh.text = _day
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
        if (m_nameForm == nil) {
            m_nameForm = LabelFormController(txtInput: txtName, btnDelete: btnNameDelete, minLength: 1, maxLength: 24, imgCheck: imgCheckName) // maxLength: Config.MAX_BYTE_LENGTH_NAME
            m_nameForm!.setDefaultText(lblDefault: lblNameSub, defaultText: "setting_baby_name_hint".localized)
            m_nameForm!.setDelegate(delegate: self)
        }
        
        birthUIByLanguage(language: Config.languageType)
        lblYearKr.text = ""
        lblYearZh.text = ""
        lblMonthKr.text = ""
        lblMonthZh.text = ""
        lblEn.text = ""
        
        imgBirthdayLine.isHidden = true
        birthPicker.isHidden = true
        datePicker.isHidden = true
        
        lblNaviTitle.text = "title_connection".localized
        btnNaviNext.setTitle("btn_done".localized.uppercased(), for: .normal)
        lblContentTitle.setTitleWithOutAnimation(title: "connection_monit_sensor_babyinfo_title".localized + " ")
//        lblContentSummary.text = "connection_monit_sensor_babyinfo_detail".localized
        lblContentSummary.setTitleWithOutAnimation(title: "connection_monit_sensor_babyinfo_detail".localized + " ")
        lblNicknameTitle.text = "account_baby_name".localized
        lblBirthTitle.text = "account_birthday".localized
        lblBirthTitle.setLineSpacing(lineSpacing: 0, lineHeightMultiple: 0.8)
        lblYearKrTitle.text = "time_year_short".localized
        lblYearZhTitle.text = "time_year_short".localized
        lblMonthKrTitle.text = "time_month_short".localized
        lblMonthZhTitle.text = "time_month_short".localized
        lblDayKrTitle.text = "time_day_short".localized
        lblDayZhTitle.text = "time_day_short".localized
        lblBirthEnSummary.text = "account_hint_birthday".localized
        lblSexTitle.text = "account_baby_sex".localized
        btnCheckMan.setTitle("sex_baby_boy".localized.uppercased(), for: .normal)
        btnCheckWomen.setTitle("sex_baby_girl".localized.uppercased(), for: .normal)
        
        setEatingUI()
    }
    
    override func reloadInfo() {
        super.reloadInfo()
        Debug.print("[UI][\(self.classNameToString()).reloadInfo()]")
        if (m_bleInfo == nil) {
            _ = PopupManager.instance.onlyContents(contentsKey: "device_sensor_disconnected", confirmType: .ok, okHandler: { () -> () in
                _ = UIManager.instance.sceneMove(scene: .initView, animation: .coverVertical, isAnimation: false)
            })
        }
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
            self.imgBirthdayLine.isHidden = false
            if (self.isDatePicker) {
                self.datePicker.isHidden = false
            } else {
                self.birthPicker.isHidden = false
            }
        })
    }
    
    func selectGenderUI(_ isman: Bool)
    {
        imgCheckMan.image = UIImage(named: "imgCheckRound")
        imgCheckWomen.image = UIImage(named: "imgCheckRound")
        btnCheckMan.setTitleColor(COLOR_TYPE.lblGray.color, for: .normal)
        btnCheckWomen.setTitleColor(COLOR_TYPE.lblGray.color, for: .normal)
        
        if (isman) {
            imgCheckMan.image = UIImage(named: "imgCheckRoundEnable")
            btnCheckMan.setTitleColor(COLOR_TYPE.mint.color, for: .normal)
        } else {
            imgCheckWomen.image = UIImage(named: "imgCheckRoundEnable")
            btnCheckWomen.setTitleColor(COLOR_TYPE.mint.color, for: .normal)
        }
        
        imgCheckSex.image = UIImage(named: "imgCheckEnable")
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
    
    func keyboardHide() {
        self.view.endEditing(true)
    }
    
    @IBAction func onClick_back(_ sender: UIButton) {
        _ = UIManager.instance.sceneMove(scene: .initView, animation: .coverVertical, isAnimation: false)
    }
    
    @IBAction func onClick_Register(_ sender: UIButton) {
        if (!m_nameForm!.m_isVaild) {
            needVaildPopup("device_warning_dialog_babyname")
        } else if (!isGender) {
            needVaildPopup("account_warning_gender")
        } else if (!isBirthday) {
            needVaildPopup("account_warning_birthday")
        } else if (!isCheckEating) {
            needVaildPopup("account_warning_eating")
        } else {
            if (m_bleInfo == nil) {
                _ = PopupManager.instance.onlyContents(contentsKey: "device_sensor_disconnected", confirmType: .ok, okHandler: { () -> () in
                    _ = UIManager.instance.sceneMove(scene: .initView, animation: .coverVertical, isAnimation: false)
                })
                return
            } else {
                if (m_bleInfo!.controller!.m_status != .connectSuccess) {
                    //                needVaildPopup("devcieRegisterInitSensing") // 설정중입니다 (뜰일 거의 없음.)
                    return
                }
            }
            
//            let month = birthPicker.selectedRow(inComponent: 0)+1
//            let year = years[birthPicker.selectedRow(inComponent: 1)]

            var _yymmdd = ""
//            _yymmdd += year.description[year.description.index(year.description.startIndex, offsetBy: 2)...]
//            _yymmdd += month.description.count == 1 ? "0\(month.description)" : month.description
//            _yymmdd += "01"
            _yymmdd += lblYearKr.text!.suffix(2) // 모든 국가별로 값을 넣었으므로 kr만 사용해서 값을 가져온다.
            _yymmdd += lblMonthKr.text!
            _yymmdd += isDatePicker ?  lblDayKr.text! : "01"
//            m_bleInfo!.controller!.m_packetCommend!.setName(name: txtName.text!)
            m_bleInfo!.controller!.m_packetCommend!.setBabyInfo(bday: _yymmdd, sex: sex)
            
            let _send = Send_SetBabyInfo()
            _send.aid = DataManager.instance.m_userInfo.account_id
            _send.token = DataManager.instance.m_userInfo.token
            _send.type = DEVICE_TYPE.Sensor.rawValue
            _send.did = m_bleInfo!.m_did
            _send.enc = m_bleInfo!.m_enc
            _send.name = Utility.urlEncode(txtName.text!)
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
//            if let _view = UIManager.instance.sceneMoveNaviPush(scene: .deviceRegisterSensorFinish) as? DeviceRegisterSensorFinishViewController {
//                _view.m_peripheral = self.m_peripheral
//            }
//            break

            // deviceDiaperAttach
            // 팝업 띄우고, 펌웨어 업데이트 (동시 업데이트 기능 해야함)
            if let _view = UIManager.instance.sceneMoveNaviPush(scene: .deviceDiaperAttachGuide) as? DeviceDiaperAttachGuideViewController {
                _view.m_peripheral = self.m_peripheral
            }
        default:
            Debug.print("[ERROR] invaild errcod", event: .error)
            let _errStr = String(format: "dialog_contents_err_communication_with_server".localized, APP_ERR_COD.Send_SetBabyInfo.rawValue)
            _ = PopupManager.instance.onlyContentsCustom(contents: _errStr, confirmType: .ok, okHandler: { () -> () in
            })
        }
    }
    
    @IBAction func onClick_birthdayPicker(_ sender: UIButton) {
        birthdayUI()
        
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
            
            birthPicker.selectRow(years.index(of: Int(_year)!)!, inComponent: yearIndex, animated: false)
        }
        
        // data picker..
//        let month = birthPicker.selectedRow(inComponent: 0)+1
//        let year = years[birthPicker.selectedRow(inComponent: 1)]
//        lblBirthdayYear.text = String(year)
//        lblBirthdayMonth.text = (String(month).count == 1 ? "0" + String(month) : String(month))
        
        imgCheckBirthday.image = UIImage(named: "imgCheckEnable")
        isBirthday = true
        keyboardHide()
    }
    
    @IBAction func editing_name(_ sender: UITextField) {
//        let _buf = [UInt8](txtName.text!.utf8)
//        if (_buf.count > Config.MAX_BYTE_LENGTH_NAME) {
//            txtName.deleteBackward()
//        }
        m_nameForm?.editing(isTrim: false, isRemoveSpecialChar: true)
    }
    
    @IBAction func onClick_nameDelete(_ sender: UIButton) {
        m_nameForm?.onClick_delete()
    }
    
    @IBAction func onClick_genderMan(_ sender: UIButton) {
        isGender = true
        sex = SEX.man.rawValue
        selectGenderUI(true)
        keyboardHide()
    }
    
    @IBAction func onClick_genderWomen(_ sender: Any) {
        isGender = true
        sex = SEX.women.rawValue
        selectGenderUI(false)
        keyboardHide()
    }
    
    @IBAction func onClick_EatingMom(_ sender: Any) {
        setEatingMom(isEnabled: !isEatingMom)
        setCheckEatingUI()
        keyboardHide()
    }
    
    @IBAction func onClick_EatingMilk(_ sender: Any) {
        setEatingMilk(isEnabled: !isEatingMilk)
        setCheckEatingUI()
        keyboardHide()
    }
    
    @IBAction func onClick_EatingMeal(_ sender: Any) {
        setEatingMeal(isEnabled: !isEatingMeal)
        setCheckEatingUI()
        keyboardHide()
    }
    
    @IBAction func onClick_helpSensor(_ sender: Any) {
        let _param = UIManager.instance.getBoardParam(board: BOARD_TYPE.connect_device_info, boardId: 21)
        let _scene = UIManager.instance.sceneMoveNaviPush(scene: .customWebView, isAniamtion: false) as! CustomWebViewController
        _scene.setInit(url: "\(Config.BOARD_DEFAULT_URL)\(_param)", naviTitle: "help".localized)
        keyboardHide()
    }
    
}
