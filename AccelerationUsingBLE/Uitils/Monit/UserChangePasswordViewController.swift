//
//  UserChangePasswordViewController.swift
//  Monit
//
//  Created by 맥 on 2017. 9. 5..
//  Copyright © 2017년 맥. All rights reserved.
//

import UIKit
import SwiftyJSON

class UserChangePasswordViewController: BaseViewController, LabelFormPwDelegate {
    @IBOutlet weak var lblNaviTitle: UILabel!
    @IBOutlet weak var btnNaviNext: UIButton!
   
    @IBOutlet weak var lblCurrentPwTitle: UILabel!
    @IBOutlet weak var imgCurrentCheckPassword: UIImageView!
    @IBOutlet weak var txtCurrentPw: UITextField!
    @IBOutlet weak var lblCurrentPw: UILabel!
    @IBOutlet weak var lblCurrentPwValid: UILabel!
    @IBOutlet weak var currentPasswordViewConst: NSLayoutConstraint!
    @IBOutlet weak var imgCurrentEncrypt: UIButton!
    
    @IBOutlet weak var lblPwTitle: UILabel!
    @IBOutlet weak var imgCheckPassword: UIImageView!
    @IBOutlet weak var txtPw: UITextField!
    @IBOutlet weak var lblPw: UILabel!
    @IBOutlet weak var lblPwValid: UILabel!
    @IBOutlet weak var pwViewConst: NSLayoutConstraint!
    @IBOutlet weak var imgEncrypt: UIButton!
    @IBOutlet weak var lblPwInformation: VerticalAlignLabel!
    
    class UserChangePasswordCurrent: LabelFormPwDelegate {
        var currentPasswordViewConst: NSLayoutConstraint?
        var parentView: UIView?
        var lblCurrentPwValid: UILabel?
        
        func setPwFormVaildVisible(isVisible: Bool) {
            UIView.animate(withDuration: 0.2, animations: {
                self.currentPasswordViewConst?.constant = (isVisible ? 74 : 54)
                self.parentView?.layoutIfNeeded()
            })

            lblCurrentPwValid?.isHidden = !isVisible
        }
        
        func isPwFormCustomVaild() -> Bool? {
            return nil
        }
    }
    
    override var screenType: SCREEN_TYPE { get { return .ACCOUNT_CHANGE_PASSWORD } }
    var m_currentPwForm: LabelFormPasswordController?
    var m_pwForm: LabelFormPasswordController?
    
    var currentPwDelegate = UserChangePasswordCurrent()

    override func viewDidLoad() {
        super.viewDidLoad()
        Debug.print("[UI][\(self.classNameToString()).viewDidLoad()]")
        txtPw.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUI()
    }

    func setUI() {
        if (m_currentPwForm == nil) {
            currentPwDelegate.currentPasswordViewConst = currentPasswordViewConst
            currentPwDelegate.parentView = self.view
            currentPwDelegate.lblCurrentPwValid = lblCurrentPwValid
                
            m_currentPwForm = LabelFormPasswordController(txtInput: txtCurrentPw, btnEncrypt: imgCurrentEncrypt, minLength: Config.MIN_PASSWORD_LENGTH, maxLength: Config.MAX_PASSWORD_LENGTH, imgCheck: imgCurrentCheckPassword)
            m_currentPwForm!.setDefaultText(lblDefault: lblCurrentPw, defaultText: "account_current_password_hint".localized)
            m_currentPwForm!.setDelegate(delegate: currentPwDelegate)
        }
        
        if (m_pwForm == nil) {
            m_pwForm = LabelFormPasswordController(txtInput: txtPw, btnEncrypt: imgEncrypt, minLength: Config.MIN_PASSWORD_LENGTH, maxLength: Config.MAX_PASSWORD_LENGTH, imgCheck: imgCheckPassword)
            m_pwForm!.setDefaultText(lblDefault: lblPw, defaultText: "account_new_password_hint".localized)
            m_pwForm!.setDelegate(delegate: self)
        }
        
        lblNaviTitle.text = "account_change_password".localized
        btnNaviNext.setTitle("btn_save".localized.uppercased(), for: .normal)
        lblCurrentPwTitle.text = "account_current_password".localized
        lblPwTitle.text = "account_new_password".localized
        lblPwInformation.text = "account_password_description".localized
//        lblPasswordInformation.verticalAlignment = .top
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

    func needVaildPopup(_ key: String)
    {
        _ = PopupManager.instance.onlyContents(contentsKey: key, confirmType: .ok)
    }
    
    @IBAction func editing_currentPw(_ sender: UITextField) {
        m_currentPwForm?.editing()
    }
    
    @IBAction func onclick_currentEncrypt(_ sender: UIButton) {
        m_currentPwForm?.onClick_encrypt()
    }
    
    @IBAction func editing_Pw(_ sender: UITextField) {
        m_pwForm?.editing()
    }
    
    @IBAction func onclick_encrypt(_ sender: UIButton) {
        m_pwForm?.onClick_encrypt()
    }
    
    @IBAction func onClick_back(_ sender: UIButton) {
        UIManager.instance.sceneMoveNaviPop()
    }

    @IBAction func onClick_save(_ sender: UIButton) {
        if (!m_currentPwForm!.m_isVaild) {
            needVaildPopup("account_warning_dialog_password")
        } else if (!m_pwForm!.m_isVaild) {
            needVaildPopup("account_warning_dialog_password")
        } else {
            let send = Send_ChangePasswordV2()
            send.aid = DataManager.instance.m_userInfo.account_id
            send.token = DataManager.instance.m_userInfo.token
            send.current_pw = Utility.md5(txtCurrentPw.text!)!
            send.pw = Utility.md5(txtPw.text!)!
            NetworkManager.instance.Request(send) { (json) -> () in
                self.getReceiveData(json)
            }
        }
    }
    
    func getReceiveData(_ json: JSON) {
        let receive = Receive_ChangePasswordV2(json)
        
        switch receive.ecd {
        case .success:
            _ = PopupManager.instance.onlyContents(contentsKey: "toast_change_password_succeeded", confirmType: .ok, okHandler: { () -> () in
                UIManager.instance.sceneMoveNaviPop()
            })
        case .current_password_not_match:
            _ = PopupManager.instance.onlyContents(contentsKey: "account_current_password_not_match", confirmType: .ok, okHandler: { () -> () in
            })
        default: Debug.print("[ERROR] invaild errcod", event: .error)
        }
    }
}
