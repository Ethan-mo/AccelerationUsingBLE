//
//  JoinEmailViewController.swift
//  Monit
//
//  Created by 맥 on 2017. 8. 22..
//  Copyright © 2017년 맥. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class JoinEmailViewController: BaseViewController, LabelFormDelegate, LabelFormPwDelegate {
    
    @IBOutlet weak var lblNaviTitle: UILabel!
    @IBOutlet weak var btnNaviNext: UIButton!
    @IBOutlet weak var lblEmailTitle: UILabel!
    @IBOutlet weak var lblPwTitle: UILabel!
    @IBOutlet weak var lblContentsTitle: UILabel!
    @IBOutlet weak var lblContentsSummary: UILabel!
    
    @IBOutlet weak var imgCheckEmail: UIImageView!
    @IBOutlet weak var imgCheckPw: UIImageView!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPw: UITextField!
    
    @IBOutlet weak var lblEmail: UILabel!
    @IBOutlet weak var lblPw: UILabel!
    @IBOutlet weak var lblEmailValid:UILabel!
    @IBOutlet weak var lblPwValid: UILabel!
    @IBOutlet weak var btnEmailDelete: UIButton!
    @IBOutlet weak var viewEmail: UIView!
    @IBOutlet weak var viewPw: UIView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var emailViewConst: NSLayoutConstraint!
    @IBOutlet weak var pwViewConst: NSLayoutConstraint!
    @IBOutlet weak var imgEncrypt: UIButton!
    @IBOutlet weak var lblPwInformation: VerticalAlignLabel!
    
    @IBOutlet weak var lblPolicyTitle: UILabel!
    @IBOutlet weak var lblPolicyContents: UILabel!
    @IBOutlet weak var imgCheckEU: UIImageView!
    @IBOutlet weak var lblEUTitle: UILabel!
    @IBOutlet weak var chkAgreeEU_Yes: CustomCheckBox!
    @IBOutlet weak var chkAgreeEU_No: CustomCheckBox!
    @IBOutlet weak var btnAgreeEU_Yes: UIButton!
    @IBOutlet weak var btnAgreeEU_No: UIButton!
    @IBOutlet weak var constPolicy: NSLayoutConstraint!
    
//    @IBOutlet weak var chkAgreeAll: CustomCheckBox!
    @IBOutlet weak var chkAgreeTermsOfService: CustomCheckBox!
    @IBOutlet weak var chkAgreeProcessingPolicy: CustomCheckBox!
    @IBOutlet weak var chkAgreeThirdPartyOffer: CustomCheckBox!
    @IBOutlet weak var btnAgreeTermsOfServiceUrl: UIButton!
    @IBOutlet weak var btnAgreeProcessingPolicyUrl: UIButton!
    @IBOutlet weak var btnAgreeThirdPartyOfferUrl: UIButton!
//    @IBOutlet weak var btnAgreeAll: UIButton!
    @IBOutlet weak var btnAgreeTermsOfService: UIButton!
    @IBOutlet weak var btnAgreeProcessingPolicy: UIButton!
    @IBOutlet weak var btnAgreeThirdPartyOffer: UIButton!
    @IBOutlet weak var viewAgreeThridPartyOffer: UIView!
    
    override var screenType: SCREEN_TYPE { get { return .JOIN_EMAIL_INPUT } }
    var m_nameForm: LabelFormController?
    var m_pwForm: LabelFormPasswordController?
    
    var m_isAgreeAll: Bool = false
    var isEssential: Bool {
        get {
            if (Config.channel == .kao) {
                if ((chkAgreeEU_Yes.isChecked || chkAgreeEU_No.isChecked) &&
                    chkAgreeTermsOfService.isChecked && chkAgreeProcessingPolicy.isChecked &&
                        chkAgreeThirdPartyOffer.isChecked) {
                    return true
                }
            } else {
                if ((chkAgreeEU_Yes.isChecked || chkAgreeEU_No.isChecked) &&
                    chkAgreeTermsOfService.isChecked && chkAgreeProcessingPolicy.isChecked) {
                    return true
                }
            }
            
            return false
        }
    }
    
    override func viewDidLoad() {
        isKeyboardFrameUp = true
        super.viewDidLoad()
        Debug.print("[UI][\(self.classNameToString()).viewDidLoad()]")
        txtEmail.delegate = self
        txtPw.delegate = self
        
//        chkAgreeAll.m_onClickHandler = { () -> () in self.setUI() }
        chkAgreeEU_Yes.m_onClickHandler = { () -> () in
            self.chkAgreeEU_No.isChecked = false
            self.setPrivacyUI(isGDPR: self.chkAgreeEU_Yes.isChecked)
            self.setUI()
        }
        chkAgreeEU_No.m_onClickHandler = { () -> () in
            self.chkAgreeEU_Yes.isChecked = false
            self.setPrivacyUI(isGDPR: false)
            self.setUI()
        }
        chkAgreeTermsOfService.m_onClickHandler = { () -> () in self.setUI() }
        chkAgreeProcessingPolicy.m_onClickHandler = { () -> () in self.setUI() }
        chkAgreeThirdPartyOffer.m_onClickHandler = { () -> () in self.setUI() }

        if (Config.channel == .kc) {
            self.chkAgreeEU_No.isChecked = true
        }
        
        lblNaviTitle.text = "title_signup".localized
        btnNaviNext.setTitleWithOutAnimation(title: "btn_done".localized.uppercased())
        lblContentsTitle.text = Config.channel == .kc ? "signup_step1_title_kc".localized : "signup_step1_title".localized
        lblContentsSummary.text = Config.channel == .kc ? "signup_step1_detail_kc".localized : "signup_step1_detail".localized
        lblEmailTitle.text = "signin_email".localized
        lblPwTitle.text = "signin_password".localized
        lblPwInformation.text = "account_password_description".localized
        
        lblPolicyTitle.text = "agreement_title".localized
//        lblPolicyContents.text = "agreement_description_gdpr".localized
        
        constPolicy.constant = Config.channel == .kc ? 165 : 210
        setGDPRContens()
        lblEUTitle.text = "agreement_eu_citizen".localized
        btnAgreeEU_Yes.setTitleWithOutAnimation(title: "btn_yes".localized.uppercased())
        btnAgreeEU_No.setTitleWithOutAnimation(title: "btn_no".localized.uppercased())

//        btnAgreeAll.setTitleWithOutAnimation(title: "agreement_all".localized)
        
        setServiceUI()
        setPrivacyUI(isGDPR: false)
        setThirdPartyUI()

        btnAgreeTermsOfServiceUrl.setTitleWithOutAnimation(title: "btn_show".localized.uppercased())
        btnAgreeProcessingPolicyUrl.setTitleWithOutAnimation(title: "btn_show".localized.uppercased())
        btnAgreeThirdPartyOfferUrl.setTitleWithOutAnimation(title: "btn_show".localized.uppercased())
        
        UI_Utility.textUnderline(btnAgreeTermsOfServiceUrl.titleLabel)
        UI_Utility.textUnderline(btnAgreeProcessingPolicyUrl.titleLabel)
        UI_Utility.textUnderline(btnAgreeThirdPartyOfferUrl.titleLabel)
        
        if (Config.channel == .kao) {
            viewAgreeThridPartyOffer.isHidden = false
        } else {
            viewAgreeThridPartyOffer.isHidden = true
        }
        
        self.view.layoutIfNeeded()
    }
    
    func setGDPRContens() {
        let _gdprTxt = Config.channel == .kc ? "agreement_description_kc".localized :  "agreement_description_gdpr".localized
        let range: Range<String.Index>? = _gdprTxt.range(of: "*")
        let index: Int = (range != nil) ? _gdprTxt.distance(from: _gdprTxt.startIndex, to: range!.lowerBound) : 0
        
        let _attributed = NSMutableAttributedString(string: Config.channel == .kc ? "agreement_description_kc".localized : "agreement_description_gdpr".localized, attributes: [NSAttributedStringKey.font: UIFont(name: Config.FONT_NotoSans, size: 14.0)!, NSAttributedStringKey.foregroundColor : COLOR_TYPE.lblDarkGray.color])
        _attributed.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.red, range: NSRange(location: index,length: 1))

        lblPolicyContents.attributedText = _attributed
    }
    
    func setServiceUI() {
        let _attributed = NSMutableAttributedString(string: "* \("agreement_service_goodmonit".localized)", attributes: [NSAttributedStringKey.font: UIFont(name: Config.FONT_NotoSans, size: 12.0)!, NSAttributedStringKey.foregroundColor : COLOR_TYPE.lblGray.color])
        _attributed.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.red, range: NSRange(location: 0,length: 1))
        
        UIView.setAnimationsEnabled(false)
        btnAgreeTermsOfService.setAttributedTitle(_attributed, for: .normal)
        btnAgreeTermsOfService.layoutIfNeeded()
        UIView.setAnimationsEnabled(true)
    }
    
    func setPrivacyUI(isGDPR: Bool) {
        let _str = isGDPR ? "agreement_privacy_gdpr_goodmonit".localized : "agreement_privacy_goodmonit".localized
        
        let _attributed = NSMutableAttributedString(string: "* \(_str)", attributes: [NSAttributedStringKey.font: UIFont(name: Config.FONT_NotoSans, size: 12.0)!, NSAttributedStringKey.foregroundColor : COLOR_TYPE.lblGray.color])
        _attributed.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.red, range: NSRange(location: 0,length: 1))
        
        UIView.setAnimationsEnabled(false)
        btnAgreeProcessingPolicy.setAttributedTitle(_attributed, for: .normal)
        btnAgreeProcessingPolicy.layoutIfNeeded()
        UIView.setAnimationsEnabled(true)
    }
    
    func setThirdPartyUI() {
        let _attributed = NSMutableAttributedString(string: "* \("legal_provide_3rd_party".localized)", attributes: [NSAttributedStringKey.font: UIFont(name: Config.FONT_NotoSans, size: 12.0)!, NSAttributedStringKey.foregroundColor : COLOR_TYPE.lblGray.color])
        _attributed.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.red, range: NSRange(location: 0,length: 1))
        
        UIView.setAnimationsEnabled(false)
        btnAgreeThirdPartyOffer.setAttributedTitle(_attributed, for: .normal)
        btnAgreeThirdPartyOffer.layoutIfNeeded()
        UIView.setAnimationsEnabled(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUI()
    }
    
    func setUI() {
        if (m_nameForm == nil) {
            m_nameForm = LabelFormController(txtInput: txtEmail, btnDelete: btnEmailDelete, minLength: 1, maxLength: 50, maxByte: -1, imgCheck: imgCheckEmail)
            m_nameForm!.setDefaultText(lblDefault: lblEmail, defaultText: "account_hint_email".localized)
            m_nameForm!.setDelegate(delegate: self)
        }
        
        if (m_pwForm == nil) {
            m_pwForm = LabelFormPasswordController(txtInput: txtPw, btnEncrypt: imgEncrypt, minLength: Config.MIN_PASSWORD_LENGTH, maxLength: Config.MAX_PASSWORD_LENGTH, imgCheck: imgCheckPw)
            m_pwForm!.setDefaultText(lblDefault: lblPw, defaultText: "account_hint_password".localized)
            m_pwForm!.setDelegate(delegate: self)
        }
        
        if (!isEssential) {
            //            chkAgreeAll.isChecked = false
            m_isAgreeAll = false
            imgCheckEU.image = UIImage(named: "imgCheck")
        } else {
            imgCheckEU.image = UIImage(named: "imgCheckEnable")
        }
    }
    
    func setAgreeAll() {
        chkAgreeTermsOfService.isChecked = !m_isAgreeAll
        chkAgreeProcessingPolicy.isChecked = !m_isAgreeAll
        chkAgreeThirdPartyOffer.isChecked = !m_isAgreeAll
        m_isAgreeAll = !m_isAgreeAll
    }

    func isCustomVaild() -> Bool? {
        return UIManager.instance.isVaildatedEmail(text: txtEmail.text!)
    }
    
    func setVaildVisible(isVisible: Bool) {
        UIView.animate(withDuration: 0.2, animations: {
            self.emailViewConst.constant = (isVisible ? 74 : 54)
            self.view.layoutIfNeeded()
        })
        
        lblEmailValid.text = "account_warning_email".localized
        lblEmailValid.isHidden = !isVisible
    }
    
    func isPwFormCustomVaild() -> Bool? {
        var _retValue = false
        let _isVaild = UIManager.instance.isValidatedPw(txtPw.text!)
        if (_isVaild) {
            _retValue = true
        }
        
        let _isVaildType = UIManager.instance.validatedPw(txtPw.text!)
        switch _isVaildType {
        case .alphabet_lower:
            lblPwValid.text = "account_warning_password_no_alphabet_lowercase".localized
        case .alphabet_upper:
            lblPwValid.text = "account_warning_password_no_alphabet_uppercase".localized
        case .digit:
            lblPwValid.text = "account_warning_password_no_number".localized
        case .special:
            lblPwValid.text = "account_warning_password_no_special_character".localized
        case .length:
            lblPwValid.text = "account_warning_password_digit".localized
        case .success:
            lblPwValid.text = ""
        }
        return _retValue
    }
    
    func setPwFormVaildVisible(isVisible: Bool) {
        UIView.animate(withDuration: 0.2, animations: {
            self.pwViewConst.constant = (isVisible ? 74 : 54)
            self.view.layoutIfNeeded()
        })
        
        lblPwValid.isHidden = !isVisible
    }
    
    @IBAction func onClick_EmailDelete(_ sender: UIButton) {
        m_nameForm?.onClick_delete()
    }

    @IBAction func editing_Email(_ sender: UITextField) {
        m_nameForm?.editing()
    }
    
    @IBAction func editing_Pw(_ sender: UITextField) {
        m_pwForm?.editing()
    }
    
    @IBAction func onclick_encrypt(_ sender: UIButton) {
        m_pwForm?.onClick_encrypt()
    }
    
    @IBAction func onClick_agreeAll(_ sender: UIButton) {
        setAgreeAll()
        setUI()
    }
   
    @IBAction func onClick_Next(_ sender: UIButton) {
        if (txtEmail.text!.count > 0) {
            if (!(UIManager.instance.isVaildatedEmail(text: txtEmail.text!))) {
                needVaildPopup("account_warning_email")
                return
            }
        }
        
        if (!m_nameForm!.m_isVaild) {
            needVaildPopup("account_warning_dialog_email")
        } else if (!m_pwForm!.m_isVaild) {
            needVaildPopup("account_warning_dialog_password")
        } else if (!isEssential) {
            needVaildPopup("account_warning_dialog_agreement")
        } else {
            let send = Send_Join1()
            send.email = Utility.urlEncode(txtEmail.text!)
            send.pw = Utility.md5(txtPw.text!)!
            send.lang = Config.lang
            send.atype = Config.channelOsNum
            
            NetworkManager.instance.Request(send) { (json) -> () in
                self.getReceiveData(json)
            }
        }
    }
    
    func getReceiveData(_ json: JSON) {
        let receive = Receive_Join1(json)
        
        switch receive.ecd {
            case .success:
                DataManager.instance.m_userInfo.account_id = receive.aid!
                DataManager.instance.m_userInfo.token = receive.token!
                DataManager.instance.m_userInfo.email = txtEmail.text!
                DataManager.instance.m_userInfo.short_id = receive.sid ?? ""
                
                sendPolicy(aid: receive.aid!, token: receive.token!)
            case .join_emailExist: _ = PopupManager.instance.onlyContents(contentsKey: "account_warning_duplicated_email", confirmType: .ok)
            case .join_emailLeave: _ = PopupManager.instance.onlyContents(contentsKey: "account_warning_leave_email", confirmType: .ok)
            case .join_emailSendFail: _ = PopupManager.instance.onlyContents(contentsKey: "toast_failed_to_send_an_email", confirmType: .ok)
            default: Debug.print("[ERROR] invaild errcod", event: .error)
        }
    }
    
    func sendPolicy(aid: Int, token: String) {
        if (isEssential) {
            let send = Send_SetPolicy()
            send.aid = aid
            send.token = token
            send.data.append(Send_SetPolicy.SetPolicyInfo(ptype: UIManager.instance.getPolicyServiceType(channel: Config.channel).rawValue, agree: 1))
            send.data.append(Send_SetPolicy.SetPolicyInfo(ptype: UIManager.instance.getPolicyPrivacyType(isEU: chkAgreeEU_Yes.isChecked, channel: Config.channel).rawValue, agree: 1))
            NetworkManager.instance.Request(send) { (json) -> () in
                let receive = Receive_SetPolicy(json)
                switch receive.ecd {
                case .success:
                    _ = UIManager.instance.sceneMoveNaviPush(scene: .joinEmailAuth)
                default:
                    Debug.print("[ERROR] invaild errcod", event: .error)
                }
            }
        }
    }
    
    func needVaildPopup(_ key: String)
    {
        _ = PopupManager.instance.onlyContents(contentsKey: key, confirmType: .ok)
    }
    
    @IBAction func onclick_back(_ sender: UIButton) {
        _ = UIManager.instance.sceneMove(scene: .mainSignin, animation: .coverVertical, isAnimation: false)
    }

    @IBAction func onClick_agreeTermsOfService(_ sender: UIButton) {
        let _type = UIManager.instance.getPolicyServiceType(channel: Config.channel)
        
        _ = Utility.urlOpen(UIManager.instance.getPolicyServiceURL(type: _type))
    }

    @IBAction func onClick_agreeProcessingPolicy(_ sender: UIButton) {
        let _type = UIManager.instance.getPolicyPrivacyType(isEU: chkAgreeEU_Yes.isChecked, channel: Config.channel)
        
        _ = Utility.urlOpen(UIManager.instance.getPolicyPrivacyURL(type: _type))
    }
 
    @IBAction func onClick_agreeThirdPartyOffer(_ sender: UIButton) {
        switch Config.channel {
        case .monitXHuggies:
            _ = Utility.urlOpen(Config.HUGGIES_THIRDPARTY_URL)
        case .kao:
            _ = Utility.urlOpen(Config.KAO_THIRDPARTY_URL)
        default:
            _ = Utility.urlOpen(Config.HUGGIES_THIRDPARTY_URL)
        }
        
    }
}
