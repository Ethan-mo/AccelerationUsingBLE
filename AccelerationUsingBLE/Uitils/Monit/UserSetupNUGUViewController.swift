//
//  UserSetupNUGU.swift
//  Monit
//
//  Created by john.lee on 2019. 1. 18..
//  Copyright © 2019년 맥. All rights reserved.
//

import UIKit

class UserSetupNUGUViewController: BaseViewController {
    @IBOutlet weak var lblNaviTitle: UILabel!
    @IBOutlet weak var lblSpeechBubble: UILabel!
    @IBOutlet weak var lblSummary: UILabel!
    @IBOutlet weak var lblGuideTitle: UILabel!
    @IBOutlet weak var lblGuideContents1: UILabel!
    @IBOutlet weak var btnGuideAppOpen: UIButton!
    @IBOutlet weak var btnGuideContents2: UIButton!
    @IBOutlet weak var btnGuideContents3: UIButton!
    @IBOutlet weak var lblGuideContents4: UILabel!
    @IBOutlet weak var btnAuthIssue: UIButton!
    @IBOutlet weak var lblAuthMemberidTitle: UILabel!
    @IBOutlet weak var lblAuthTitle: UILabel!
    @IBOutlet weak var btnAuthCopyMemberid: UIButton!
    @IBOutlet weak var btnAuthCopy: UIButton!

    @IBOutlet weak var viewCert: UIView!
    @IBOutlet weak var viewCertInfo: UIView!
    @IBOutlet weak var lblCert: UILabel!
    @IBOutlet weak var lblShortidValue: UILabel!
    @IBOutlet weak var lblCtValue: UILabel!
    @IBOutlet weak var constCert: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var timeController = TimerController()
    var authValue: String = ""
    var expiredDate: Date?
    var isViewCertEnabled: Bool = false

    override var screenType: SCREEN_TYPE { get { return .ACCOUNT_NUGU } }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUI()
    }
    
    func setUI() {
        lblNaviTitle.text = "nugu_title".localized
        lblSpeechBubble.text = "nugu_speech_bubble".localized
//        lblSummary.text = "nugu_summary".localized
        lblGuideTitle.text = "nugu_guide_title".localized
        lblGuideContents1.text = "nugu_guide_contents_1".localized
        btnGuideAppOpen.setTitle("nugu_guide_btn_app_open".localized, for: .normal)
//        btnGuideContents2.setTitle("nugu_guide_contents_2".localized, for: .normal)
        
        let _attributed1 = LabelAttributed(labelValue: "을 누르시고,", attributed: [NSAttributedStringKey.foregroundColor : COLOR_TYPE.lblDarkGray.color])
        let _attributed2 = LabelAttributed(labelValue: "NUGU Play ", attributed: [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 14), NSAttributedStringKey.foregroundColor : COLOR_TYPE.lblDarkGray.color])
        let _attributed3 = LabelAttributed(labelValue: "에서 'MONIT'을 눌러주세요.", attributed: [NSAttributedStringKey.foregroundColor : COLOR_TYPE.lblDarkGray.color])
        let _arrAttributed = NSMutableAttributedString()
        for item in [_attributed1, _attributed2, _attributed3] {
            _arrAttributed.append(item.attributedString)
        }
        btnGuideContents2.setAttributedTitle(_arrAttributed, for: .normal)
        
        btnGuideContents3.setTitle("nugu_guide_contents_3".localized, for: .normal)
        lblGuideContents4.text = "nugu_guide_contents_4".localized
        btnAuthIssue.setTitle("nugu_auth_btn_issue".localized, for: .normal)
        lblAuthMemberidTitle.text = "nugu_auth_memberid_title".localized
        lblAuthTitle.text = "nugu_auth_key_title".localized
        btnAuthCopyMemberid.setTitle("nugu_auth_btn_copy".localized, for: .normal)
        btnAuthCopy.setTitle("nugu_auth_btn_copy".localized, for: .normal)

        setCtInfo(isEnable: false)
        viewCertInfo.layer.borderColor = COLOR_TYPE.green.color.cgColor
        viewCertInfo.layer.borderWidth = 1
    }
    
    func setCtInfo(isEnable: Bool, value: String = "", expiredTime: String = "") {
        viewCertInfo.isHidden = !isEnable
        isViewCertEnabled = isEnable
        
        UIView.animate(withDuration: 0.2, animations: {
            self.constCert.constant = (isEnable ? 180 : 80)
            self.view.layoutIfNeeded()
        })
        
        if (isEnable) {
            scrollView.setContentOffset(CGPoint(x: scrollView.contentOffset.x, y: scrollView.contentOffset.y + 100), animated: true)
        } else {
        }
        
        if (isEnable) {
            lblShortidValue.text = DataManager.instance.m_userInfo.shareMember.getMyGroupMasterInfo()?.sid ?? ""
            lblCtValue.text = value
            startAuthTimer(expiredTime: expiredTime)
        }
    }
    
    func startAuthTimer(expiredTime: String) {
        guard (expiredTime != "") else { return }
        expiredDate = UI_Utility.convertStringToDate(expiredTime, type: .yyMMdd_HHmmss)
        
        guard (expiredDate != nil) else { return }
        
        let _dateComp = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: Date(), to: expiredDate!)

        timeController.start(interval: 0.1, finishTime: Double(_dateComp.minute! * 60 + _dateComp.second!), updateCallback: {() -> () in
//        timeController.start(interval: 0.1, finishTime: Double(10), updateCallback: {() -> () in // test
            self.setAuthTimer()
        }, finishCallback: {() -> () in
            self.setCtInfo(isEnable: false)
        })
    }
    
    func setAuthTimer() {
        guard (expiredDate != nil) else { return }
        let _dateComp = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: Date(), to: expiredDate!)
        
        let _attributed1 = LabelAttributed(labelValue: "nugu_auth_key_title".localized, attributed: [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 14), NSAttributedStringKey.foregroundColor : COLOR_TYPE.lblDarkGray.color])

        let _attributed2 = LabelAttributed(labelValue: "  \(String(format: "%02d", _dateComp.minute!)):\(String(format: "%02d", _dateComp.second!))", attributed: [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 12), NSAttributedStringKey.foregroundColor : COLOR_TYPE.lblGray.color])
        
        UI_Utility.multiAttributedLabel(label: lblCert, arrAttributed: [_attributed1, _attributed2])
    }
    
    func oAuthLoginSuccess() {
        _ = PopupManager.instance.onlyContents(contentsKey: "toast_oauth_authentication_succeeded", confirmType: .ok)
        setCtInfo(isEnable: false)
    }

    @IBAction func onClick_back(_ sender: UIButton) {
        UIManager.instance.sceneMoveNaviPop()
    }
    
    @IBAction func onClick_nuguApp(_ sender: UIButton) {
        let appScheme = "Nugu://"
        let appSchemeURL = URL(string: appScheme)
        if UIApplication.shared.canOpenURL(appSchemeURL! as URL) {
            _ = Utility.urlOpen(appScheme)
        } else {
            _ = Utility.urlOpen(Config.NUGU_APPSTORE)
        }
    }
    
    @IBAction func onClick_value(_ sender: UIButton) {
        if (isViewCertEnabled) {
            return
        }
        
        let send = Send_OAuthGetAuth()
        send.aid = DataManager.instance.m_userInfo.account_id
        send.token = DataManager.instance.m_userInfo.token
        NetworkManager.instance.Request(send) { (json) -> () in
            let receive = Receive_OAuthGetAuth(json)
            switch receive.ecd {
            case .success:
                self.authValue = receive.auth_key ?? ""
                self.setCtInfo(isEnable: true, value: self.authValue, expiredTime: receive.time ?? "")
            default:
                Debug.print("[ERROR] Send_OAuthGetAuth invaild errcod", event: .error)
            }
        }
    }
    
    @IBAction func onClick_copyShortid(_ sender: UIButton) {
        UIPasteboard.general.string = DataManager.instance.m_userInfo.shareMember.getMyGroupMasterInfo()?.sid ?? ""
        NativePopupManager.instance.toast(message: "toast_copy_completed".localized)
    }
    
    @IBAction func onClick_copyKey(_ sender: UIButton) {
        UIPasteboard.general.string = self.authValue
        NativePopupManager.instance.toast(message: "toast_copy_completed".localized)
    }
}
