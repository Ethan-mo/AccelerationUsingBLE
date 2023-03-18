//
//  SigninMainMonitXHuggiesViewController.swift
//  Monit
//
//  Created by 맥 on 2018. 1. 10..
//  Copyright © 2018년 맥. All rights reserved.
//

import UIKit
import SafariServices

class SigninMainMonitXHuggiesViewController : BaseViewController {
    @IBOutlet weak var btnSignin: UIButton!
    @IBOutlet weak var btnSignup: UIButton!
    @IBOutlet weak var webContainerView: UIView!
    @IBOutlet weak var webInnerView: UIView!
    @IBOutlet weak var lblNaviTitle: UILabel!
    @IBOutlet weak var btnTestLogin1: UIButton!
    
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    
    var m_parent: SigninMainViewController?
    var m_popup: CustomWebView?
    var m_account_id: Int = 0
    var m_token: String = ""
    var m_email: String = ""
 
    override func viewDidLoad() {
        super.viewDidLoad()
        Debug.print("[UI][\(self.classNameToString()).viewDidLoad()]")
        let screenSize = UIScreen.main.bounds
        heightConstraint.constant = screenSize.height
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUI()
    }

    func setUI() {
//        #if DEBUG
//            btnTestLogin1.isHidden = false
//            btnTestLogin1.addTarget(self, action: #selector(onClick_testLogin1(sender:)), for: .touchUpInside)
//        #else
//            btnTestLogin1.isHidden = true
//        #endif

        setBtnSignin()
    }
    
    func setBtnSignin()
    {
        UIView.performWithoutAnimation {
            btnSignin.setTitle("title_signin".localized, for: .normal)
            btnSignup.setTitle("title_signup".localized, for: .normal)
            btnSignin.layoutIfNeeded()
            btnSignup.layoutIfNeeded()
        }
        btnSignup.titleLabel!.textAlignment = .center
        UI_Utility.customButtonBorder(button: btnSignin, radius: 25, width: 1, color: COLOR_TYPE._black_77_77_77.color.cgColor)
        btnSignin.titleLabel!.font = UIFont.boldSystemFont(ofSize: 16)
        UI_Utility.customButtonBorder(button: btnSignup, radius: 25, width: 1, color: COLOR_TYPE._black_77_77_77.color.cgColor)
        btnSignup.titleLabel!.font = UIFont.boldSystemFont(ofSize: 16)
    }
    
    func scriptCallSignin(value: String) {
//        webContainerView.isHidden = true
        
        var _id = ""
        var _token = ""
        let _arrData = value.split(separator: ",")
        if (_arrData.count == 2) {
            _id = _arrData[0].description
            _token = _arrData[1].description
        } else {
            _id = value
        }

        let send = Send_YKSignin()
        send.url = Config.WEB_URL_YK_SIGNIN
        send.userid = _id
        send.token = _token
          //        send.accessTOken = accesstoken
        send.time = Int64(Utility.timeStamp)
        
        NetworkManager.instance.Request(send) { (json) -> () in
            let receive = Receive_YKSignin(json)
            switch receive.ecd {
            case .success:
                let _step = receive.step!
                switch _step {
                case 1, 2, 3:
                    self.m_account_id = receive.aid!
                    self.m_token = receive.token!
                    self.m_email = _id
                default: Debug.print("[ERROR] invaild errcod", event: .error)
                }
                switch _step {
                case 1, 2, 3: self.policyAgreeCheck()
                default: Debug.print("[ERROR] invaild errcod", event: .error)
                }
            case .signin_invaildEmail:
                self.alert(messageKey: "toast_invalid_user_info")
            case .signin_invaildPw:
                self.alert(messageKey: "toast_invalid_user_info")
            default: Debug.print("[ERROR] invaild errcod", event: .error)
            }
        }
    }
    
    func policyAgreeCheck()
    {
        let send = Send_GetPolicy()
        send.aid = m_account_id
        send.token = m_token
        NetworkManager.instance.Request(send) { (json) -> () in
            let receive = Receive_GetPolicy(json)
            switch receive.ecd {
            case .success:
                var _isEssential = false
                for item in receive.data {
                    if (item.ptype ?? -1 == POLICY_AGREE_TYPE.huggies_service.rawValue) {
                        if (item.agree ?? -1 == 1) {
                            _isEssential = true
                            break
                        }
                    }
                }

                if (_isEssential) {
                    DataManager.instance.m_userInfo.account_id = self.m_account_id
                    DataManager.instance.m_userInfo.token = self.m_token
                    DataManager.instance.m_userInfo.email = self.m_email
                    _ = UIManager.instance.sceneMove(scene: .initView, animation: .coverVertical, isAnimation: false)
                } else {
                    let _scene = UIManager.instance.sceneMove(scene: .policyMonitXHuggies, animation: .coverVertical, isAnimation: false) as! SigninPolicyMonitXHuggiesViewController
                    _scene.setInit(account_id: self.m_account_id, token: self.m_token, email: self.m_email, isEssential: false)
                }
            default: Debug.print("[ERROR] invaild errcod", event: .error)
            }
        }
    }

    func alert(messageKey: String) {
        NativePopupManager.instance.onlyContents(message: messageKey.localized) { () -> () in }
    }
    
    func scriptCallOpenUrl(url: String) {
        if (Utility.currentReachabilityStatus != .notReachable) {
            webContainerView.isHidden = true
            if let _url = URL(string: url), UIApplication.shared.canOpenURL(_url) {
                let svc = SFSafariViewController(url: _url)
                self.present(svc, animated: true, completion: nil)
            }
        } else {
            Debug.print(Utility.currentReachabilityStatus, event: .warning)
            _ = PopupManager.instance.onlyContents(contentsKey: "internet_disconnected_detail", confirmType: .ok)
        }
    }
    
    func scriptCallCloseWebView(value: String) {
        closeWebView()
    }
    
    // 국내 하기스가 OAuth2로 변경함에 따라, 로그인이 완료 되면 자바스크립트에서 -> 코드를 실행하던 scriptcall 방식에서 / 스키마 주소로 OAuth2에 대한 정보를 받아서 처리한다.
    @IBAction func onClick_signin(_ sender: UIButton) {
        if (Utility.currentReachabilityStatus != .notReachable) {
            webContainerView.isHidden = false
            let svc = SFSafariViewController(url: URL(string: Config.MONIT_X_HUGGIES_OAUTH2_SIGNIN_URL)!)
            self.present(svc, animated: true, completion: nil)
        } else {
            Debug.print(Utility.currentReachabilityStatus, event: .warning)
            _ = PopupManager.instance.onlyContents(contentsKey: "internet_disconnected_detail", confirmType: .ok)
        }
    }
    
//    func generateState(withLength len: Int) -> String {
//        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
//        let length = UInt32(letters.count)
//
//        var randomString = ""
//        for _ in 0..<len {
//            let rand = arc4random_uniform(length)
//            let idx = letters.index(letters.startIndex, offsetBy: Int(rand))
//            let letter = letters[idx]
//            randomString += String(letter)
//        }
//        return randomString
//    }
    
//    func testGet(_ credential: OAuthSwiftCredential, _ response: OAuthSwiftResponse?, _ parameters: [String: Any]) -> Void {
//
//    }
    
//    func _oAuthTest() {
//        let oauthswift = OAuth2Swift(
//            consumerKey: "MONIT",
//            consumerSecret: "secret",
//            authorizeUrl: "https://dev-ykbrand.stiscloudbonds.com/connect/authorize",
//            accessTokenUrl: "https://dev-ykbrand.stiscloudbonds.com/connect/token",
//            responseType: "code id_token"
//        )
//        _ = oauthswift.authorize(withCallbackURL: URL(string: "http://monitdev.azurewebsites.net/")!, scope: "openid offline_access", state: "AAAAA", success: { (sdf1, sdf2, sdf3) -> () in }, failure: nil)
//
//        let oauthswift = OAuth2Swift(
//            consumerKey: "MONIT",
//            consumerSecret: "secret",
//            authorizeUrl: "https://dev-ykbrand.stiscloudbonds.com/connect/authorize",
//            accessTokenUrl: "https://dev-ykbrand.stiscloudbonds.com/connect/token",
//            responseType: "code id_token"
//        )
//        _ = oauthswift.authorize(withCallbackURL: URL(string: "http://monitdev.azurewebsites.net/")!, scope: "openid offline_access", state: "MONIT", success: { (sdf1, sdf2, sdf3) -> () in }, failure: nil)
//    }

    @IBAction func onClick_signup(_ sender: UIButton) {
        openSignup(siteCode: "MONIT")
    }
    
    func openSignup(siteCode: String) {
        if (Utility.currentReachabilityStatus != .notReachable) {
            if (siteCode != "close") {
                let svc = SFSafariViewController(url: URL(string: String(format: "%@%@", Config.MONIT_X_HUGGIES_OAUTH2_SIGNUP_URL, siteCode))!)
                self.present(svc, animated: true, completion: nil)
            } else {
                _ = UIManager.instance.sceneMove(scene: .initView, animation: .coverVertical, isAnimation: false)
            }
        } else {
            Debug.print(Utility.currentReachabilityStatus, event: .warning)
            _ = PopupManager.instance.onlyContents(contentsKey: "internet_disconnected_detail", confirmType: .ok)
        }
    }
    
    @IBAction func onClick_webViewClose(_ sender: UIButton) {
        closeWebView()
    }
    
    func closeWebView() {
        m_popup?.removeFromSuperview()
        m_popup = nil
        webContainerView.isHidden = true
    }
    
    #if DEBUG
    @objc func onClick_testLogin1(sender: UIButton) {
        let send = Send_YKSignin()
        send.url = Config.WEB_URL_YK_SIGNIN
        send.userid = "koogihot"
        send.time = 1522220987
        
        NetworkManager.instance.Request(send) { (json) -> () in
            let receive = Receive_YKSignin(json)
            switch receive.ecd {
            case .success:
                let _step = receive.step!
                switch _step {
                case 1, 2, 3:
                    DataManager.instance.m_userInfo.account_id = receive.aid!
                    DataManager.instance.m_userInfo.token = receive.token!
                    DataManager.instance.m_userInfo.email = "koogihot"
                default: Debug.print("[ERROR] invaild errcod", event: .error)
                }
                _ = UIManager.instance.sceneMove(scene: .initView, animation: .coverVertical, isAnimation: false)
            case .signin_invaildEmail:
                self.alert(messageKey: "toast_invalid_user_info")
            case .signin_invaildPw:
                self.alert(messageKey: "toast_invalid_user_info")
            default: Debug.print("[ERROR] invaild errcod", event: .error)
            }
        }
    }
    #endif
}

