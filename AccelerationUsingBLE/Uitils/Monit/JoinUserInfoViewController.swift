//
//  JoinUserInfoViewController.swift
//  Monit
//
//  Created by 맥 on 2017. 8. 28..
//  Copyright © 2017년 맥. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class JoinUserInfoViewController: BaseViewController, LabelFormDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var lblNaviTitle: UILabel!
    @IBOutlet weak var btnNaviNext: UIButton!
    @IBOutlet weak var lblContentTitle: UILabel!
    @IBOutlet weak var lblContentSummary: UILabel!
    @IBOutlet weak var lblNicknameTitle: UILabel!
    @IBOutlet weak var lblBirthTitle: UILabel!
    @IBOutlet weak var lblSexTitle: UILabel!

    @IBOutlet weak var viewBirthKr: UIView!
    @IBOutlet weak var lblYearKrTitle: UILabel!
    @IBOutlet weak var lblMonthKrTitle: UILabel!
    @IBOutlet weak var lblYearKr: UILabel!
    @IBOutlet weak var lblMonthKr: UILabel!
    
    @IBOutlet weak var viewBirthEn: UIView!
    @IBOutlet weak var lblEn: UILabel!
    @IBOutlet weak var lblBirthEnSummary: UILabel!
    
    @IBOutlet weak var viewBirthZh: UIView!
    @IBOutlet weak var lblYearZhTitle: UILabel!
    @IBOutlet weak var lblMonthZhTitle: UILabel!
    @IBOutlet weak var lblYearZh: UILabel!
    @IBOutlet weak var lblMonthZh: UILabel!
    
    @IBOutlet weak var imgCheckNickname: UIImageView!
    @IBOutlet weak var imgCheckBirthday: UIImageView!
    @IBOutlet weak var imgCheckGender: UIImageView!
    
    @IBOutlet weak var txtNickname: UITextField!
    @IBOutlet weak var lblNickname: UILabel!
    @IBOutlet weak var btnDeleteNickname: UIButton!
    @IBOutlet weak var txtNicknameVaild: UILabel!
    @IBOutlet weak var constNickname: NSLayoutConstraint!

    @IBOutlet weak var viewBirthdayLine: UIView!
    @IBOutlet weak var birthPicker: UIPickerView!
    @IBOutlet weak var constBirthday: NSLayoutConstraint!
    
    @IBOutlet weak var imgMan: UIImageView!
    @IBOutlet weak var imgWomen: UIImageView!
    @IBOutlet weak var btnMan: UIButton!
    @IBOutlet weak var btnWomen: UIButton!
    @IBOutlet weak var constGender: NSLayoutConstraint!
    
//    @IBOutlet weak var scView: UIScrollView!
    
    override var screenType: SCREEN_TYPE { get { return .JOIN_PARENT } }
    var m_nameForm: LabelFormController?
    var isBirthday = false
    var isGender = false
    var sex = -1
    var months: [String]!
    var years: [Int]!
    var yearIndex = Config.languageType == .ko ? 0 : 1
    var monthIndex = Config.languageType == .ko ? 1 : 0
    
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

    override func viewDidLoad() {
        isKeyboardFrameUp = true
        super.viewDidLoad()
        Debug.print("[UI][\(self.classNameToString()).viewDidLoad()]")
        birthPicker.delegate = self
        birthPicker.dataSource = self
        txtNickname.delegate = self
        initPickerInfo()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUI()
    }

    func setUI() {
        if (m_nameForm == nil) {
            m_nameForm = LabelFormController(txtInput: txtNickname, btnDelete: btnDeleteNickname, minLength: 1, maxLength: 12, maxByte: -1, imgCheck: imgCheckNickname)
            m_nameForm!.setDefaultText(lblDefault: lblNickname, defaultText: "account_hint_nickname".localized)
            m_nameForm!.setDelegate(delegate: self)
        }
        
        birthUIByLanguage(language: Config.languageType)
        lblYearKr.text = ""
        lblYearZh.text = ""
        lblMonthKr.text = ""
        lblMonthZh.text = ""
        lblEn.text = ""
        
        viewBirthdayLine.isHidden = true
        birthPicker.isHidden = true
        
        lblNaviTitle.text = "title_signup".localized
        btnNaviNext.setTitle("btn_next".localized.uppercased(), for: .normal)
        lblContentTitle.text = "signup_step3_title".localized
        lblContentSummary.text = "signup_step3_detail".localized
        lblNicknameTitle.text = "account_nickname".localized
        lblBirthTitle.text = "account_birthday".localized
        lblBirthTitle.setLineSpacing(lineSpacing: 0, lineHeightMultiple: 0.8)
        lblYearKrTitle.text = "time_year_short".localized
        lblYearZhTitle.text = "time_year_short".localized
        lblMonthKrTitle.text = "time_month_short".localized
        lblMonthZhTitle.text = "time_month_short".localized
        lblBirthEnSummary.text = "account_hint_birthday".localized
        lblSexTitle.text = "account_gender".localized
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
    
    func isCustomVaild() -> Bool? {
        return nil
    }
    
    func setVaildVisible(isVisible: Bool) {
        UIView.animate(withDuration: 0.2, animations: {
            self.constNickname.constant = (isVisible ? 74 : 54)
            self.view.layoutIfNeeded()
        })
        txtNicknameVaild.text = "account_warning_nickname".localized
        txtNicknameVaild.isHidden = !isVisible
    }
    
    func birthdayUI()
    {
        lblBirthEnSummary.isHidden = true
        UIView.animate(withDuration: 0.5, animations: {
            self.constBirthday.constant = 200
            self.view.layoutIfNeeded()
        }, completion: { (bool) in
            self.viewBirthdayLine.isHidden = false
            self.birthPicker.isHidden = false
        })
    }
    
    func selectGenderUI(_ isman: Bool)
    {
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
        
        imgCheckGender.image = UIImage(named: "imgCheckEnable")
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
    

    @IBAction func onClick_Back(_ sender: UIButton) {
        _ = UIManager.instance.sceneMove(scene: .mainSignin, animation: .coverVertical, isAnimation: false)
    }
    
    @IBAction func onClick_Next(_ sender: UIButton) {
        if (!m_nameForm!.m_isVaild) {
            needVaildPopup("account_warning_dialog_nickname")
//        } else if (!isBirthday) {
//            needVaildPopup("account_warning_birthday")
//        } else if (!isGender) {
//            needVaildPopup("account_warning_dialog_gender")
        } else {
            let send = Send_Join3()
            send.aid = DataManager.instance.m_userInfo.account_id
            send.token = DataManager.instance.m_userInfo.token
            send.nick = Utility.urlEncode(txtNickname.text)
            let _bday = lblYearKr.text! + lblMonthKr.text!
            send.bday = _bday == "" ? "" : _bday
            send.sex = sex
            NetworkManager.instance.Request(send) { (json) -> () in
                self.getReceiveData(json)
            }
        }
    }
    
    func getReceiveData(_ json: JSON) {
        let receive = Receive_Join3(json)
        
        switch receive.ecd {
        case .success: _ = UIManager.instance.sceneMoveNaviPush(scene: .joinFinish)
        default: Debug.print("[ERROR] invaild errcod", event: .error)
        }
    }
 
    @IBAction func editing_nickname(_ sender: UITextField) {
        m_nameForm?.editing(isTrim: false)
    }
    
    @IBAction func onClick_deleteNickname(_ sender: UIButton) {
        m_nameForm?.onClick_delete()
    }
    
    @IBAction func onClick_Birthday(_ sender: UIButton) {
        birthdayUI()

        let year = years[birthPicker.selectedRow(inComponent: yearIndex)]
        let month = birthPicker.selectedRow(inComponent: monthIndex) + 1
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
        
        imgCheckBirthday.image = UIImage(named: "imgCheckEnable")
        isBirthday = true
    }
    
    @IBAction func onClick_Man(_ sender: UIButton) {
        isGender = true
        sex = SEX.man.rawValue
        selectGenderUI(true)
    }
    
    @IBAction func onClick_Women(_ sender: UIButton) {
        isGender = true
        sex = SEX.women.rawValue
        selectGenderUI(false)
    }
}
