//
//  SigninPolicyMonitXHuggiesViewController.swift
//  Monit X Huggies
//
//  Created by 맥 on 2018. 5. 4..
//  Copyright © 2018년 맥. All rights reserved.
//

import UIKit
import SwiftyJSON

class SigninPolicyMonitXHuggiesViewController: BaseViewController {
    @IBOutlet weak var lblNaviTitle: UILabel!
    @IBOutlet weak var lblSummaryTitle: UILabel!
    @IBOutlet weak var lblSummaryContents: UILabel!
    @IBOutlet weak var chkAgreeAll: CustomCheckBox!
    @IBOutlet weak var chkAgreeTermsOfService: CustomCheckBox!
    @IBOutlet weak var chkAgreeProcessingPolicy: CustomCheckBox!
    @IBOutlet weak var chkAgreePrivacySave: CustomCheckBox!
    @IBOutlet weak var chkAgreeThirdPartyOffer: CustomCheckBox!
    @IBOutlet weak var btnConfirm: UIButton!
    @IBOutlet weak var btnAgreeTermsOfService: UIButton!
    @IBOutlet weak var btnAgreeProcessingPolicy: UIButton!
    @IBOutlet weak var btnAgreePrivacySave: UIButton!
    @IBOutlet weak var btnAgreeThirdPartyOffer: UIButton!
    
    var m_account_id: Int = 0
    var m_token: String = ""
    var m_email: String = ""
    
    var m_isAgreeAll: Bool = false
    var isEssential: Bool {
        get {
            if (chkAgreeTermsOfService.isChecked && chkAgreeProcessingPolicy.isChecked && chkAgreePrivacySave.isChecked &&
                chkAgreeThirdPartyOffer.isChecked) {
                return true
            }
            return false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Debug.print("[UI][\(self.classNameToString()).viewDidLoad()]")
        chkAgreeAll.m_onClickHandler = { () -> () in self.setUI() }
        chkAgreeTermsOfService.m_onClickHandler = { () -> () in self.setUI() }
        chkAgreeProcessingPolicy.m_onClickHandler = { () -> () in self.setUI() }
        chkAgreePrivacySave.m_onClickHandler = { () -> () in self.setUI() }
        chkAgreeThirdPartyOffer.m_onClickHandler = { () -> () in self.setUI() }
    }
  
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUI()
    }
    
    func setInit(account_id: Int, token: String, email: String, isEssential: Bool) {
        if (isEssential) {
            chkAgreeTermsOfService.isChecked = true
            chkAgreeProcessingPolicy.isChecked = true
            chkAgreePrivacySave.isChecked = true
            chkAgreeThirdPartyOffer.isChecked = true
        }
        m_account_id = account_id
        m_token = token
        m_email = email
    }
    
    func setUI() {
        isEnableConfirmButton(isEnable: isEssential)
        if (!isEssential) {
            chkAgreeAll.isChecked = false
            m_isAgreeAll = false
        }
        lblSummaryTitle.text = "agreement_title".localized
        lblSummaryContents.text = "agreement_description".localized
        lblNaviTitle.text = "agreement_title".localized
        chkAgreeAll.setTitle("agreement_all".localized, for: .normal)
        chkAgreeTermsOfService.setTitle("agreement_service".localized, for: .normal)
        chkAgreeProcessingPolicy.setTitle("agreement_privacy".localized, for: .normal)
        chkAgreePrivacySave.setTitle("agreement_collect".localized, for: .normal)
        chkAgreeThirdPartyOffer.setTitle("agreement_disclosure".localized, for: .normal)
    }
    
    func setAgreeAll() {
        chkAgreeTermsOfService.isChecked = !m_isAgreeAll
        chkAgreeProcessingPolicy.isChecked = !m_isAgreeAll
        chkAgreePrivacySave.isChecked = !m_isAgreeAll
        chkAgreeThirdPartyOffer.isChecked = !m_isAgreeAll
        m_isAgreeAll = !m_isAgreeAll
    }
    
    func isEnableConfirmButton(isEnable: Bool) {
        if (isEnable) {
            btnConfirm.backgroundColor = COLOR_TYPE.green.color
            btnConfirm.setTitleColor(UIColor.white, for: .normal)
            UI_Utility.customButtonBorder(button: btnConfirm, radius: 20, width: 1, color: COLOR_TYPE.green.color.cgColor)
            UI_Utility.customButtonShadow(button: btnConfirm, radius: 1, offsetWidth: 2, offsetHeight: 2, color: UIColor.black.cgColor, opacity: 0.5)
        } else {
            btnConfirm.backgroundColor = UIColor.white
            btnConfirm.setTitleColor(COLOR_TYPE.lblWhiteGray.color, for: .normal)
            UI_Utility.customButtonBorder(button: btnConfirm, radius: 20, width: 1, color: COLOR_TYPE.lblWhiteGray.color.cgColor)
            UI_Utility.customButtonShadow(button: btnConfirm, radius: 1, offsetWidth: 2, offsetHeight: 2, color: UIColor.black.cgColor, opacity: 0.2)
        }
    }

    @IBAction func onClick_back(_ sender: UIButton) {
        _ = UIManager.instance.sceneMove(scene: .initView, animation: .coverVertical, isAnimation: false)
    }

    @IBAction func onClick_agreeAll(_ sender: UIButton) {
        setAgreeAll()
        setUI()
    }
    
    @IBAction func onClick_agreeItem(_ sender: UIButton) {
    }
    
    @IBAction func onClick_finish(_ sender: UIButton) {
        if (isEssential) {
            let send = Send_SetPolicy()
            send.aid = m_account_id
            send.token = m_token
            send.data.append(Send_SetPolicy.SetPolicyInfo(ptype: POLICY_AGREE_TYPE.huggies_service.rawValue, agree: chkAgreeTermsOfService.isChecked ? 1 : 0))
            send.data.append(Send_SetPolicy.SetPolicyInfo(ptype: POLICY_AGREE_TYPE.huggies_privacy.rawValue, agree: chkAgreeProcessingPolicy.isChecked ? 1 : 0))
            send.data.append(Send_SetPolicy.SetPolicyInfo(ptype: POLICY_AGREE_TYPE.huggies_collect.rawValue, agree: chkAgreePrivacySave.isChecked ? 1 : 0))
            send.data.append(Send_SetPolicy.SetPolicyInfo(ptype: POLICY_AGREE_TYPE.huggies_3rdparty.rawValue, agree: chkAgreeThirdPartyOffer.isChecked ? 1 : 0))
            NetworkManager.instance.Request(send) { (json) -> () in
                self.getReceiveData(json)
            }
        }
    }
    
    func getReceiveData(_ json: JSON) {
        let receive = Receive_SetPolicy(json)
        switch receive.ecd {
        case .success:
            DataManager.instance.m_userInfo.account_id = m_account_id
            DataManager.instance.m_userInfo.token = m_token
            DataManager.instance.m_userInfo.email = m_email
            _ = UIManager.instance.sceneMove(scene: .initView, animation: .coverVertical, isAnimation: false)
        default: Debug.print("[ERROR] invaild errcod", event: .error)
        }
    }

    @IBAction func onClick_agreeTermsOfService(_ sender: UIButton) {
        _ = Utility.urlOpen(Config.HUGGIES_TERMS_URL)
    }
    
    @IBAction func onClick_agreeProcessingPolicy(_ sender: UIButton) {
        _ = Utility.urlOpen(Config.HUGGIES_PRIVACY_URL)
    }
    
    @IBAction func onClick_agreePrivacySave(_ sender: UIButton) {
        _ = Utility.urlOpen(Config.HUGGIES_COLLECT_URL)
    }
    
    @IBAction func onClick_agreeThirdPartyOffer(_ sender: UIButton) {
        _ = Utility.urlOpen(Config.HUGGIES_THIRDPARTY_URL)
    }
}
