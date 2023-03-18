//
//  SigninMainViewController.swift
//  Monit
//
//  Created by 맥 on 2017. 8. 17..
//  Copyright © 2017년 맥. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

// login으로 바로가지 말자. init 거쳐서 가자.
class SigninMainGoodmonitViewController: BaseViewController {
    @IBOutlet weak var btnTestLogin1: UIButton!
    @IBOutlet weak var btnTestLogin2: UIButton!
    @IBOutlet weak var btnTestLogin3: UIButton!
    
    @IBOutlet weak var imgSubBackground: UIImageView!
    @IBOutlet weak var btnSignin: UIButton!
    @IBOutlet weak var btnForgotPw: UIButton!
    @IBOutlet weak var btnSignup: UIButton!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPw: UITextField!
    @IBOutlet weak var btnEmailDelete: UIButton!
    @IBOutlet weak var lblEmail: UILabel!
    @IBOutlet weak var lblPassword: UILabel!
    @IBOutlet weak var imgEncrypt: UIButton!

    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    
    override var screenType: SCREEN_TYPE { get { return .MONIT_SIGNIN } }
    var m_parent: SigninMainViewController?
    
    var m_nameForm: LabelFormController?
    var m_pwForm: LabelFormPasswordController?
    
    override func viewDidLoad() {
        isKeyboardFrameUp = true
        super.viewDidLoad()
        Debug.print("[UI][\(self.classNameToString()).viewDidLoad()]")
        txtEmail.delegate = self
        txtPw.delegate = self
       
        let screenSize = UIScreen.main.bounds
        heightConstraint.constant = screenSize.height
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUI()
    }
    func configure(){
        imgSubBackground.layer.cornerRadius = CGFloat(20)
    }
    func setUI()
    {
        // test login
        #if DEBUG
        /// 20221122 디버그모드로 배포
        btnTestLogin1.isHidden = true
        btnTestLogin2.isHidden = true
        btnTestLogin3.isHidden = true
//            btnTestLogin1.isHidden = false
//            btnTestLogin2.isHidden = false
//            btnTestLogin3.isHidden = false
//            btnTestLogin1.addTarget(self, action: #selector(onClick_TestLogin1(sender:)), for: .touchUpInside)
//            btnTestLogin2.addTarget(self, action: #selector(onClick_TestLogin2(sender:)), for: .touchUpInside)
//            btnTestLogin3.addTarget(self, action: #selector(onClick_TestLogin3(sender:)), for: .touchUpInside)
        #else
            btnTestLogin1.isHidden = true
            btnTestLogin2.isHidden = true
            btnTestLogin3.isHidden = true

        #endif

        setBtnSignin()
        
        if (m_nameForm == nil) {
            m_nameForm = LabelFormController(txtInput: txtEmail, btnDelete: btnEmailDelete, minLength: 1, maxLength: 50, maxByte: -1, imgCheck: nil)
            m_nameForm!.setDefaultText(lblDefault: lblEmail, defaultText: "signin_email".localized)
        }
        
        if (m_pwForm == nil) {
            m_pwForm = LabelFormPasswordController(txtInput: txtPw, btnEncrypt: imgEncrypt, minLength: Config.MIN_PASSWORD_LENGTH, maxLength: Config.MAX_PASSWORD_LENGTH, imgCheck: nil)
            m_pwForm!.setDefaultText(lblDefault: lblPassword, defaultText: "signin_password".localized)
            m_pwForm!.m_encryptImgName = "imgDecryptWhite"
            m_pwForm!.m_decryptImgName = "imgEncryptWhite"
        }
        
        btnSignin.setTitle("title_signin".localized.uppercased(), for: .normal)
        btnForgotPw.setTitle("signin_forgot_password".localized.uppercased(), for: .normal)
        btnForgotPw.titleLabel!.textAlignment = .center
        btnSignup.setTitle("title_signup".localized.uppercased(), for: .normal)
        btnSignup.titleLabel!.textAlignment = .center
    }

    func setBtnSignin()
    {
        UI_Utility.customButtonBorder(button: btnSignin, radius: 20, width: 1, color: UIColor.clear.cgColor)
        UI_Utility.customButtonShadow(button: btnSignin, radius: 1, offsetWidth: 2, offsetHeight: 2, color: UIColor.black.cgColor, opacity: 0.5)
    }

    @IBAction func SetEmailEditing(_ sender: UITextField) {
        m_nameForm?.editing()
    }
    
    @IBAction func SetPwEditing(_ sender: UITextField) {
        m_pwForm?.editing()
    }
    
    @IBAction func OnDeleteEmail(_ sender: UIButton) {
        m_nameForm?.onClick_delete()
    }
    
    @IBAction func onClick_encrypt(_ sender: UIButton) {
        m_pwForm?.onClick_encrypt()
    }

    @IBAction func onClickSignin(_ sender: UIButton) {
        if (!(UIManager.instance.isVaildatedEmail(text: txtEmail.text!))) {
            alert(messageKey: "toast_invalid_user_info")
        } else if (!(txtPw.text!.count > 0)) {
            alert(messageKey: "toast_invalid_user_info")
        } else {
            let send = Send_Signin()
            send.email = Utility.urlEncode(txtEmail.text!)
            send.pw = Utility.md5(txtPw.text!)!
            NetworkManager.instance.Request(send) { (json) -> () in
                self.getReceiveData(json)
            }
        }
    }
    
    func getReceiveData(_ json: JSON) {
        let receive = Receive_Signin(json)
    
        switch receive.ecd {
        case .success:
                let _step = receive.step!
                
                switch _step {
                case 1, 2, 3:
                    DataManager.instance.m_userInfo.account_id = receive.aid!
                    DataManager.instance.m_userInfo.token = receive.token!
                    DataManager.instance.m_userInfo.email = txtEmail.text!
                default: Debug.print("[ERROR] invaild errcod", event: .error)
                }
                
                switch _step {
                    case 1: _ = UIManager.instance.sceneMove(scene: .joinEmailAuthNavi, animation: .coverVertical, isAnimation: false)
                    case 2: _ = UIManager.instance.sceneMove(scene: .joinUserInfoNavi, animation: .coverVertical, isAnimation: false)
                    case 3: _ = UIManager.instance.sceneMove(scene: .initView, animation: .coverVertical, isAnimation: false)
                    default: Debug.print("[ERROR] invaild errcod", event: .error)
                }
        case .signin_invaildEmail:
            alert(messageKey: "toast_invalid_user_info")
        case .signin_invaildPw:
            alert(messageKey: "toast_invalid_user_info")
        case .join_emailLeave:
            alert(messageKey: "account_warning_leave_email")
        default: Debug.print("[ERROR] invaild errcod", event: .error)
        }
    }
    
    func alert(messageKey: String) {
        NativePopupManager.instance.onlyContents(message: messageKey.localized) { () -> () in }
    }
    
    @IBAction func onClick_findPassword(_ sender: UIButton) {
        _ = UIManager.instance.sceneMove(scene: .findPassword, animation: .coverVertical, isAnimation: false)
    }
    
    @IBAction func OnClick_Join(_ sender: UIButton) {
        _ = UIManager.instance.sceneMove(scene: .joinEmailNavi, animation: .coverVertical, isAnimation: false)
    }
    
    // testLogin1
    #if DEBUG
    @objc func onClick_TestLogin1(sender: UIButton) {
        let send = Send_Signin()
        send.email = Utility.urlEncode("win1042@naver.com2")
        send.pw = Utility.md5("test1234!")!
        
        txtEmail.text = "win1042@naver.com2"
        NetworkManager.instance.Request(send) { (json) -> () in
            self.getReceiveData(json)
        }
    }
    
    @objc func onClick_TestLogin2(sender: UIButton) {
        let send = Send_Signin()
        send.email = Utility.urlEncode("win1042@naver.com3")
        send.pw = Utility.md5("test1234!")!
        
        txtEmail.text = "win1042@naver.com3"
        NetworkManager.instance.Request(send) { (json) -> () in
            self.getReceiveData(json)
        }
    }
    
    @objc func onClick_TestLogin3(sender: UIButton) {
        let send = Send_Signin()
        send.email = Utility.urlEncode("win1042@naver.com4")
        send.pw = Utility.md5("test1234!")!
        
        txtEmail.text = "win1042@naver.com4"
        NetworkManager.instance.Request(send) { (json) -> () in
            self.getReceiveData(json)
        }
    }
    #endif
}
