//
//  JoinEmailAuthViewController.swift
//  Monit
//
//  Created by 맥 on 2017. 8. 28..
//  Copyright © 2017년 맥. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class JoinEmailAuthViewController: BaseViewController {
    @IBOutlet weak var lblNaviTitle: UILabel!
    @IBOutlet weak var btnNaviNext: UIButton!
    @IBOutlet weak var lblAuthEmailTitle: UILabel!
    
    @IBOutlet weak var btnResend: UIButton!
    @IBOutlet weak var lblSendSummary: UILabel!
    
    @IBOutlet weak var imgLogoDefault: UIImageView!
    @IBOutlet weak var imgLogoKC: UIImageView!
    
    override var screenType: SCREEN_TYPE { get { return .JOIN_EMAIL_AUTH } }

    override func viewDidLoad() {
        super.viewDidLoad()
        Debug.print("[UI][\(self.classNameToString()).viewDidLoad()]")
        
        setLogoUI()
        setUI()
    }
    
    func setLogoUI() {
        imgLogoDefault.isHidden = true
        imgLogoKC.isHidden = true
        switch Config.channel {
        case .kc: imgLogoKC.isHidden = false
        default: imgLogoDefault.isHidden = false
        }
    }

    func setUI() {
        lblSendSummary.text = String(format: "signup_check_auth_email_description".localized, DataManager.instance.m_userInfo.email)
        lblNaviTitle.text = "title_signup".localized
        btnNaviNext.setTitle("btn_next".localized.uppercased(), for: .normal)
        lblAuthEmailTitle.text = "signup_check_auth_email".localized
        btnResend.setTitle("signup_send_auth_email".localized.uppercased(), for: .normal)
        
        UI_Utility.textUnderline(btnResend.titleLabel)
    }
    
    func getReceiveDataJoin2(_ json: JSON) {
        let receive = Receive_Join2(json)
        switch receive.ecd {
        case .success: _ = UIManager.instance.sceneMoveNaviPush(scene: .joinUserInfo)
        case .join_emailAuthNone: _ = PopupManager.instance.onlyContents(contentsKey: "signup_not_authenticated", confirmType: .ok)
        default: Debug.print("[ERROR] invaild errcod", event: .error)
        }
    }
    
    func getReceiveDataResendAuth(_ json: JSON) {
        let receive = Receive_ResendAuth(json)
        switch receive.ecd {
        case .success: _ = PopupManager.instance.onlyContents(contentsKey: "toast_sent_an_authentication_email", confirmType: .ok)
        default: Debug.print("[ERROR] invaild errcod", event: .error)
        }
    }
    
    @IBAction func onClick_Back(_ sender: UIButton) {
        _ = UIManager.instance.sceneMove(scene: .mainSignin, animation: .coverVertical, isAnimation: false)
    }

    @IBAction func onClick_Next(_ sender: UIButton) {
        let send = Send_Join2()
        send.aid = DataManager.instance.m_userInfo.account_id
        send.token = DataManager.instance.m_userInfo.token
        NetworkManager.instance.Request(send) { (json) -> () in
            self.getReceiveDataJoin2(json)
        }
    }
    
    @IBAction func onClick_ResendAuth(_ sender: UIButton) {
        let send = Send_ResendAuth()
        send.aid = DataManager.instance.m_userInfo.account_id
        send.token = DataManager.instance.m_userInfo.token
        send.lang = Config.lang
        send.atype = Config.channelOsNum
        NetworkManager.instance.Request(send) { (json) -> () in
            self.getReceiveDataResendAuth(json)
        }
    }
    
}
