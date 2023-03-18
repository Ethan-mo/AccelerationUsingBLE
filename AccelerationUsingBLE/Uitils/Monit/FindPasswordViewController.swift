//
//  FindPasswordViewController.swift
//  Monit
//
//  Created by 맥 on 2017. 9. 8..
//  Copyright © 2017년 맥. All rights reserved.
//

import UIKit
import SwiftyJSON

class FindPasswordViewController: BaseViewController, LabelFormDelegate {
    @IBOutlet weak var lblNaviTitle: UILabel!
    @IBOutlet weak var btnNaviNext: UIButton!
    @IBOutlet weak var lblEmailTitle: UILabel!
    @IBOutlet weak var imgCheckEmail: UIImageView!
    @IBOutlet weak var txtEmailInput: UITextField!
    @IBOutlet weak var lblEmail: UILabel!
    @IBOutlet weak var btnDeleteEmail: UIButton!
    @IBOutlet weak var txtEmailVaild: UILabel!
    @IBOutlet weak var constEmail: NSLayoutConstraint!

    override var screenType: SCREEN_TYPE { get { return .PASSWORD_FIND } }
    var m_nameForm: LabelFormController?

    override func viewDidLoad() {
        super.viewDidLoad()
        Debug.print("[UI][\(self.classNameToString()).viewDidLoad()]")
        txtEmailInput.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUI()
    }
    
    func setUI() {
        if (m_nameForm == nil) {
            m_nameForm = LabelFormController(txtInput: txtEmailInput, btnDelete: btnDeleteEmail, minLength: 1, maxLength: 50, maxByte: -1, imgCheck: imgCheckEmail)
            m_nameForm!.setDefaultText(lblDefault: lblEmail, defaultText: "account_hint_email".localized)
            m_nameForm!.setDelegate(delegate: self)
        }
       
        lblNaviTitle.text = "title_forgot_password".localized
        btnNaviNext.setTitle("btn_done".localized.uppercased(), for: .normal)
        lblEmailTitle.text = "signin_email".localized
    }
    
    func isCustomVaild() -> Bool? {
        return UIManager.instance.isVaildatedEmail(text: txtEmailInput.text!)
    }
    
    func setVaildVisible(isVisible: Bool) {
        UIView.animate(withDuration: 0.2, animations: {
            self.constEmail.constant = (isVisible ? 74 : 54)
            self.view.layoutIfNeeded()
        })
        txtEmailVaild.text = "account_warning_email".localized
        txtEmailVaild.isHidden = !isVisible
    }
    
    func needVaildPopup(_ key: String)
    {
        _ = PopupManager.instance.onlyContents(contentsKey: key, confirmType: .ok)
    }
    
    @IBAction func onClick_Back(_ sender: UIButton) {
        _ = UIManager.instance.sceneMove(scene: .mainSignin, animation: .coverVertical, isAnimation: false)
    }
    
    @IBAction func onClick_Next(_ sender: UIButton) {
        if (txtEmailInput.text!.count > 0) {
            if (!(UIManager.instance.isVaildatedEmail(text: txtEmailInput.text!))) {
                needVaildPopup("account_warning_email")
                return
            }
        }
        
        if (!m_nameForm!.m_isVaild) {
            needVaildPopup("account_warning_dialog_email")
        } else {
            let send = Send_ResetPassword()
            send.email = Utility.urlEncode(txtEmailInput.text!)
            send.lang = Config.lang
            send.atype = Config.channelOsNum
            NetworkManager.instance.Request(send) { (json) -> () in
                self.getReceiveData(json)
            }
        }
    }
    
    func getReceiveData(_ json: JSON) {
        let receive = Receive_ResetPassword(json)
        switch receive.ecd {
        case .success:
            _ = PopupManager.instance.onlyContents(contentsKey: "toast_sent_new_password_email", confirmType: .ok, okHandler: { () -> () in
                _ = UIManager.instance.sceneMove(scene: .mainSignin, animation: .coverVertical, isAnimation: false)
            })
        case .signin_invaildEmail,
             .findPassword_invalidInfo: needVaildPopup("account_warning_dialog_findpw_description")
        case .findPassword_sendFail:
            needVaildPopup("toast_failed_to_send_an_email")
        default: Debug.print("[ERROR] invaild errcod", event: .error)
        }
    }
    
    @IBAction func editing_email(_ sender: UITextField) {
        m_nameForm?.editing()
    }
    
    @IBAction func onClick_deleteEmail(_ sender: UIButton) {
        m_nameForm?.onClick_delete()
    }
}
