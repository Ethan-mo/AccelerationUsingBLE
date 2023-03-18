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
import SwiftRangeSlider

class DeviceRegisterPackageSetInfoViewController: BaseViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    @IBOutlet weak var lblNaviTitle: UILabel!
    @IBOutlet weak var btnNaviNext: UIButton!
    @IBOutlet weak var lblContentTitle: UILabel!
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
    
    @IBOutlet weak var btnHubInfoTitle: UIButton!
    @IBOutlet weak var lblHubNameTitle: UILabel!
    @IBOutlet weak var imgHubCheckName: UIImageView!
    @IBOutlet weak var txtHubName: UITextField!
    @IBOutlet weak var lblHubNameSub: UILabel!
    @IBOutlet weak var btnHubNameDelete: UIButton!
    
    @IBOutlet weak var imgCheckTempScale: UIImageView!
    @IBOutlet weak var lblTempScaleTitle: UILabel!
    @IBOutlet weak var btnTempScaleC: CustomCheckBox!
    @IBOutlet weak var btnTempScaleF: CustomCheckBox!
    
    @IBOutlet weak var lblTempRangeTitle: UILabel!
    @IBOutlet weak var lblTempRange: UILabel!
    @IBOutlet weak var tempRangeSlider: RangeSlider!
    
    @IBOutlet weak var lblHumRangeTitle: UILabel!
    @IBOutlet weak var lblHumRange: UILabel!
    @IBOutlet weak var humRangeSlider: RangeSlider!
    
    class NameInfoForm: LabelFormDelegate {
        var txtName: UITextField?
        init (txtName: UITextField) {
            self.txtName = txtName
        }
        
        func setVaildVisible(isVisible: Bool) {
        }
        
        func isCustomVaild() -> Bool? {
            return nil
        }
    }
    
    
    override var screenType: SCREEN_TYPE { get { return .SENSOR_REGISTER_BABY_INFO } }
    var m_sensorNameForm: LabelFormController?
    var m_hubNameForm: LabelFormController?
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
    var isEditTemp = false
    var isEditHum = false
    var isDatePicker = false // 현재 Picker 사용
    var originTempUnit: String = {
        return DataManager.instance.m_userInfo.configData.m_tempUnit
    }()
    
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
    
    var m_hubStatusInfo: HubStatusInfo?
    var hubStatusInfo: HubStatusInfo? {
        get {
            if let _info = DataManager.instance.m_userInfo.deviceStatus.m_hubStatus.getInfoByDeviceId(did: m_bleInfo?.controller?.m_hubConnectionController?.m_device_id ?? 0) {
                return _info
            } else {
                return m_hubStatusInfo
            }
        }
    }
    
    var hubConnectionController: HubConnectionController? {
        get {
            return m_bleInfo?.controller?.m_hubConnectionController
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
        txtHubName.delegate = self
        datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        
        initPickerInfo()
        m_hubStatusInfo = HubStatusInfo(did: hubConnectionController?.m_device_id ?? 0, name: "", power: 0, bright: 0, color: 0, attached: 0, temp: 0, hum: 0, voc: 0, ap: "", apse: "", tempmax: 3000, tempmin: 1800, hummax: 6000, hummin: 4000, offt: "0000", onnt: "0000", con: 0, offptime: "", onptime: "")
        
         if (DataManager.instance.m_userInfo.configData.m_tempUnit == "C") {
            btnTempScaleC.isChecked = true
         } else {
            btnTempScaleF.isChecked = true
        }
        
        m_bleInfo?.controller?.setCloudId()
        hubConnectionController?.setCloudId()
        
        setRangeSliderUI()
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
        if (m_sensorNameForm == nil) {
            m_sensorNameForm = LabelFormController(txtInput: txtName, btnDelete: btnNameDelete, minLength: 1, maxLength: 24, imgCheck: imgCheckName) // maxLength: Config.MAX_BYTE_LENGTH_NAME
            m_sensorNameForm!.setDefaultText(lblDefault: lblNameSub, defaultText: "setting_baby_name_hint".localized)
            m_sensorNameForm!.setDelegate(delegate: NameInfoForm(txtName: txtName))
        }
        
        if (m_hubNameForm == nil) {
            m_hubNameForm = LabelFormController(txtInput: txtHubName, btnDelete: btnHubNameDelete, minLength: 1, maxLength: 24, imgCheck: imgHubCheckName) // maxLength: Config.MAX_BYTE_LENGTH_NAME
            m_hubNameForm!.setDefaultText(lblDefault: lblHubNameSub, defaultText: "setting_room_name_hint".localized)
            m_hubNameForm!.setDelegate(delegate: NameInfoForm(txtName: txtHubName))
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
//        lblContentTitle.text = "connection_monit_sensor_babyinfo_title".localized
        lblContentSummary.setTitleWithOutAnimation(title: "setting_title_sensor_information".localized + " ")
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
        btnHubInfoTitle.setTitleWithOutAnimation(title: "setting_title_hub_information".localized + " ")
        lblHubNameTitle.text = "setting_room_name".localized

        setEatingUI()
        
        btnTempScaleC.m_onClickHandler = { () -> () in
            self.btnTempScaleC.isChecked = true
            self.btnTempScaleF.isChecked = false
            DataManager.instance.m_userInfo.configData.m_tempUnit = "C"
            self.setRangeSliderUI()
            self.keyboardHide()
        }
        btnTempScaleF.m_onClickHandler = { () -> () in
            self.btnTempScaleC.isChecked = false
            self.btnTempScaleF.isChecked = true
            DataManager.instance.m_userInfo.configData.m_tempUnit = "F"
            self.setRangeSliderUI()
            self.keyboardHide()
        }
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
                years.append(year)
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
    
    func setRangeSliderUI() {
        if let _statusInfo = hubStatusInfo {
            let _tempmin = Double(_statusInfo.m_tempmin) / 100.0
            let _tempminValue =  UIManager.instance.getTemperatureProcessing(value: _tempmin)
            let _tempmax = Double(_statusInfo.m_tempmax) / 100.0
            let _tempmaxValue = UIManager.instance.getTemperatureProcessing(value: _tempmax)
            
            let _hummin = Double(_statusInfo.m_hummin) / 100.0
            let _hummax = Double(_statusInfo.m_hummax) / 100.0
            
            tempRangeSlider.lowerValue = _tempminValue
            tempRangeSlider.upperValue = _tempmaxValue
            humRangeSlider.lowerValue = _hummin
            humRangeSlider.upperValue = _hummax
            
            if (UIManager.instance.temperatureUnit == .Celsius) {
                tempRangeSlider.minimumValue = 10
                tempRangeSlider.maximumValue = 40
            } else {
                tempRangeSlider.minimumValue = UI_Utility.celsiusToFahrenheit(tempInC: 10)
                tempRangeSlider.maximumValue = UI_Utility.celsiusToFahrenheit(tempInC: 40)
            }
            
            let _tempUnit = UIManager.instance.temperatureUnitStr
            lblTempRange.text = "\(Int(_tempminValue))\(_tempUnit) ~ \(Int(_tempmaxValue)) \(_tempUnit)"
            lblHumRange.text = "\(Int(_hummin))% ~ \(Int(_hummax))%"
        }
    }
    
    @IBAction func onClick_back(_ sender: UIButton) {
        DataManager.instance.m_userInfo.configData.m_tempUnit = originTempUnit
        
        _ = UIManager.instance.sceneMove(scene: .initView, animation: .coverVertical, isAnimation: false)
    }
    
    @IBAction func onClick_Register(_ sender: UIButton) {
        if (!m_sensorNameForm!.m_isVaild) {
            needVaildPopup("device_warning_dialog_babyname")
        } else if (!isGender) {
            needVaildPopup("account_warning_gender")
        } else if (!isBirthday) {
            needVaildPopup("account_warning_birthday")
        } else if (!isCheckEating) {
            needVaildPopup("account_warning_eating")
        } else if (!m_hubNameForm!.m_isVaild) {
            needVaildPopup("setting_warning_dialog_room_name")
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

            var _yymmdd = ""
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
            
            // todo. slider float 단위라 서버에 보낼때도 float단위임
            sendHubName()
            setTempUnit()
            sendTemp()
            sendHum()
        }
    }
    
    func receive(_ json: JSON) {
        let receive = Receive_SetBabyInfo(json)
        switch receive.ecd {
        case .success:
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
    
    func sendHubName() {
        let send = Send_SetDeviceName()
        send.aid = DataManager.instance.m_userInfo.account_id
        send.token = DataManager.instance.m_userInfo.token
        send.type = DEVICE_TYPE.Hub.rawValue
        send.did = hubConnectionController?.m_device_id ?? 0
        send.enc = hubConnectionController?.m_enc ?? ""
        send.name = Utility.urlEncode(txtHubName.text!)
        NetworkManager.instance.Request(send) { (json) -> () in
            let receive = Receive_SetDeviceName(json)
            switch receive.ecd {
            case .success:
                self.hubStatusInfo!.m_name = self.txtHubName.text!
            default:
                Debug.print("[ERROR] Receive_SetDeviceName invaild errcod", event: .error)
                let _errStr = String(format: "dialog_contents_err_communication_with_server".localized, APP_ERR_COD.Send_SetDeviceName.rawValue)
                _ = PopupManager.instance.onlyContentsCustom(contents: _errStr, confirmType: .ok, okHandler: { () -> () in
                })
            }
        }
    }
    
    func sendTemp() {
        var _tempmin: Float = Float(hubStatusInfo!.m_tempmin)
        if (UIManager.instance.temperatureUnit == .Celsius) {
            _tempmin = Float(UI_Utility.celsiusToFahrenheit(tempInC: Double(_tempmin)))
        }
        var _tempmax: Float = Float(hubStatusInfo!.m_tempmax)
        if (UIManager.instance.temperatureUnit == .Celsius) {
            _tempmax = Float(UI_Utility.celsiusToFahrenheit(tempInC: Double(_tempmax)))
        }
        ScreenAnalyticsManager.instance.googleTagManagerCustom(type: .hub_setting_temperature_range, items: ["hubid_\(hubConnectionController?.m_device_id ?? 0)" : "\(_tempmin/100.0)-\(_tempmax/100.0)"])
        
        guard (isEditTemp) else { return }
        
        let send = Send_SetAlarmThreshold()
        send.aid = DataManager.instance.m_userInfo.account_id
        send.token = DataManager.instance.m_userInfo.token
        send.type = DEVICE_TYPE.Hub.rawValue
        send.did = hubConnectionController?.m_device_id ?? 0
        send.enc = hubConnectionController?.m_enc ?? ""
        send.tmin = hubStatusInfo!.m_tempmin
        send.tmax = hubStatusInfo!.m_tempmax
        NetworkManager.instance.Request(send) { (json) -> () in
            let receive = Receive_SetAlarmThreshold(json)
            switch receive.ecd {
            case .success: break
            default:
                Debug.print("[ERROR] Send_SetAlarmThreshold invaild errcod", event: .error)
                let _errStr = String(format: "dialog_contents_err_communication_with_server".localized, APP_ERR_COD.Send_SetAlarmThreshold.rawValue)
                _ = PopupManager.instance.onlyContentsCustom(contents: _errStr, confirmType: .ok)
            }
        }
    }
    
    func sendHum() {
        let _humminValue: Float = Float(hubStatusInfo!.m_hummin)
        let _hummaxValue: Float = Float(hubStatusInfo!.m_hummax)
        ScreenAnalyticsManager.instance.googleTagManagerCustom(type: .hub_setting_humidity_range, items: ["hubid_\(hubConnectionController?.m_device_id ?? 0)" : "\(_humminValue/100.0)-\(_hummaxValue/100.0)"])
        
        guard (isEditHum) else { return }
        
        let send = Send_SetAlarmThreshold()
        send.aid = DataManager.instance.m_userInfo.account_id
        send.token = DataManager.instance.m_userInfo.token
        send.type = DEVICE_TYPE.Hub.rawValue
        send.did = hubConnectionController?.m_device_id ?? 0
        send.enc = hubConnectionController?.m_enc ?? ""
        send.hmin = hubStatusInfo!.m_hummin
        send.hmax = hubStatusInfo!.m_hummax
        NetworkManager.instance.Request(send) { (json) -> () in
            let receive = Receive_SetAlarmThreshold(json)
            switch receive.ecd {
            case .success: break
            default:
                Debug.print("[ERROR] Send_SetAlarmThreshold invaild errcod", event: .error)
                let _errStr = String(format: "dialog_contents_err_communication_with_server".localized, APP_ERR_COD.Send_SetAlarmThreshold.rawValue)
                _ = PopupManager.instance.onlyContentsCustom(contents: _errStr, confirmType: .ok)
            }
        }
    }
    
    func setTempUnit() {
        ScreenAnalyticsManager.instance.googleTagManagerCustom(type: .hub_setting_temperature_scale, items: ["hubid_\(hubConnectionController?.m_device_id ?? 0)" : "\(DataManager.instance.m_userInfo.configData.m_tempUnit)"])
        
        guard (DataManager.instance.m_userInfo.configData.m_tempUnit != originTempUnit) else { return }
        
        let send = Send_SetAppInfo()
        send.aid = DataManager.instance.m_userInfo.account_id
        send.token = DataManager.instance.m_userInfo.token
        send.temunit = DataManager.instance.m_userInfo.configData.m_tempUnit
        NetworkManager.instance.Request(send) { (json) -> () in
            let receive = Receive_SetAppInfo(json)
            switch receive.ecd {
            case .success:
                Widget_Utility.setSharedInfo(channel: Config.channelOsNum, key: .temperatureUnit, value: DataManager.instance.m_userInfo.configData.m_tempUnit)
            default:
                Debug.print("[ERROR] Send_SetAppInfo invaild errcod", event: .error)
                let _errStr = String(format: "dialog_contents_err_communication_with_server".localized, APP_ERR_COD.Send_SetAppInfo.rawValue)
                _ = PopupManager.instance.onlyContentsCustom(contents: _errStr, confirmType: .ok)
            }
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
        }

        imgCheckBirthday.image = UIImage(named: "imgCheckEnable")
        isBirthday = true
        keyboardHide()
    }
    
    func keyboardHide() {
        self.view.endEditing(true)
    }
    
    @IBAction func editing_name(_ sender: UITextField) {
        m_sensorNameForm?.editing(isTrim: false, isRemoveSpecialChar: true)
    }
    
    @IBAction func editing_hubName(_ sender: UITextField) {
        m_hubNameForm?.editing(isTrim: false, isRemoveSpecialChar: true)
    }
    
    @IBAction func onClick_nameDelete(_ sender: UIButton) {
        m_sensorNameForm?.onClick_delete()
    }
    
    @IBAction func onClick_hubNameDelete(_ sender: UIButton) {
        m_hubNameForm?.onClick_delete()
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
    
    @IBAction func editing_temRangeSlider(_ sender: RangeSlider) {
        isEditTemp = true
        
        hubStatusInfo?.m_tempmin = Int(UIManager.instance.temperatureUnit == .Fahrenheit ? UI_Utility.fahrenheitToCelsius(tempInF: sender.lowerValue) * 100 : sender.lowerValue * 100)

        hubStatusInfo?.m_tempmax = Int(UIManager.instance.temperatureUnit == .Fahrenheit ? UI_Utility.fahrenheitToCelsius(tempInF: sender.upperValue) * 100 : sender.upperValue * 100)
        
        setRangeSliderUI()
        keyboardHide()
    }
    
    @IBAction func editing_humRangeSlider(_ sender: RangeSlider) {
        isEditHum = true
        
        hubStatusInfo?.m_hummin = Int(sender.lowerValue * 100.0)
        hubStatusInfo?.m_hummax = Int(sender.upperValue * 100.0)
        setRangeSliderUI()
        keyboardHide()
    }
    
    @IBAction func onClick_helpSensor(_ sender: Any) {
        let _param = UIManager.instance.getBoardParam(board: BOARD_TYPE.connect_device_info, boardId: 21)
        let _scene = UIManager.instance.sceneMoveNaviPush(scene: .customWebView, isAniamtion: false) as! CustomWebViewController
        _scene.setInit(url: "\(Config.BOARD_DEFAULT_URL)\(_param)", naviTitle: "help".localized)
        keyboardHide()
    }
    
    @IBAction func onClick_helpHub(_ sender: Any) {
        let _param = UIManager.instance.getBoardParam(board: BOARD_TYPE.connect_device_info, boardId: 22)
        let _scene = UIManager.instance.sceneMoveNaviPush(scene: .customWebView, isAniamtion: false) as! CustomWebViewController
        _scene.setInit(url: "\(Config.BOARD_DEFAULT_URL)\(_param)", naviTitle: "help".localized)
        keyboardHide()
    }
    
}
