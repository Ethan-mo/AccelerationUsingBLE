//
//  UserSetupMainTableViewController.swift
//  Monit
//
//  Created by 맥 on 2017. 9. 7..
//  Copyright © 2017년 맥. All rights reserved.
//

import UIKit
import SwiftyJSON
import Firebase
import JWTDecode
import Alamofire

class UserSetupMainTableViewController: BaseTableViewController {
    @IBOutlet weak var lblMemberIDTitle: UILabel!
    @IBOutlet weak var lblChangePwTitle: UILabel!
    @IBOutlet weak var lblNicknameTitle: UILabel!
    @IBOutlet weak var lblSexTitle: UILabel!
    @IBOutlet weak var lblBirthTitle: UILabel!
    @IBOutlet weak var lblNoticeBoardTitle: UILabel!
    @IBOutlet weak var lblAppVersionTitle: UILabel!

    @IBOutlet weak var lblMemberID: UILabel!
    @IBOutlet weak var lblNickValue: UILabel!
    @IBOutlet weak var lblSexValue: UILabel!
    @IBOutlet weak var lblBirthdayValue: UILabel!
    @IBOutlet weak var lblLogout: UILabel!
    @IBOutlet weak var lblLeave: UILabel!
    @IBOutlet weak var lblPrivacy: UILabel!
    @IBOutlet weak var lblTerms: UILabel!
    @IBOutlet weak var lblSupport: UILabel!
    @IBOutlet weak var lblCollectInfo: UILabel!
    @IBOutlet weak var lbl3rdParty: UILabel!
    @IBOutlet weak var lblNUGU: UILabel!
    @IBOutlet weak var lblAssistant: UILabel!
    @IBOutlet weak var lblAppVersion: UILabel!
    
    @IBOutlet weak var cellPw: UITableViewCell!
    @IBOutlet weak var cellNickname: UITableViewCell!
    @IBOutlet weak var cellSex: UITableViewCell!
    @IBOutlet weak var cellBirth: UITableViewCell!
    @IBOutlet weak var cellNoticeBoard: UITableViewCell!
    @IBOutlet weak var cellLeave: UITableViewCell!
    @IBOutlet weak var cellTermsOfUse: UITableViewCell!
    @IBOutlet weak var cellCollectInfo: UITableViewCell!
    @IBOutlet weak var cell3rdParty: UITableViewCell!
    @IBOutlet weak var cellNUGU: UITableViewCell!
    @IBOutlet weak var cellAssistant: UITableViewCell!
    @IBOutlet weak var imgNicknameArrow: UIImageView!
    
    @IBOutlet var viewMarketing: UIView!
    @IBOutlet weak var viewMarketingMain: UIView!
    @IBOutlet weak var lblMarketingTitle: UILabel!
    @IBOutlet weak var lblMarketingContents: UILabel!
    @IBOutlet weak var btnMarketingUrl: UIButton!
    @IBOutlet weak var btnMarketingYes: UIButton!
    @IBOutlet weak var btnMarketingNo: UIButton!
    @IBOutlet weak var btnMarketingCancle: UIButton!
 
    enum CATEGORY : Int {
        case userInfo = 0
        case policy = 1
        case help = 2
        case account_link = 3
        case appver = 4
        case signout = 5
        case leave = 6
    }
    
    enum SUB_CATEGORY_USERINFO : Int {
        case memberId = 0
        case changePassword = 1
        case nickname = 2
        case sex = 3
        case birth = 4
    }
    
    enum SUB_CATEGORY_POLICY: Int {
        case privacy = 0
        case temsOfUse = 1
        case collectInfo = 2
        case thirdParty = 3
    }
    
    enum SUB_CATEGROY_HELP: Int {
        case noticeBoard = 0
        case support = 1
    }
    
    enum SUB_CATEGORY_ACCOUNT_LINK: Int {
        case nugu = 0
        case assistant = 1
    }
    
    enum SUB_CATEGORY_APPVER: Int {
        case appVersion = 0
    }
    
    enum SUB_CATEGORY_SIGNOUT: Int {
        case signout = 0
    }
    
    enum SUB_CATEGORY_LEAVE: Int {
        case leave = 0
    }
    
    var m_arrHeader : [String] = []
    var m_parentView : UIView?
   
    func setUI() {
        setOnClick()

        lblNickValue.text = DataManager.instance.m_userInfo.shareMember.getMyGroupMasterInfo()?.nick ?? ""

        if (DataManager.instance.m_userInfo.sex != -1) {
            lblSexValue.text = DataManager.instance.m_userInfo.sexString
        } else {
            lblSexValue.text = ""
        }
        
        let _bday = DataManager.instance.m_userInfo.bday
        if (_bday == "19700101") {
            lblBirthdayValue.text = ""
        } else {
            if (_bday.count > 0) {
                let _yyyy = UI_Utility.convertDateStringToString(_bday, fromType: .yyyyMMdd, toType: .yyyy)
                let _MM = UI_Utility.convertDateStringToString(_bday, fromType: .yyyyMMdd, toType: .MM)
                if (Config.languageType == .ko) {
                    lblBirthdayValue.text = String(format: "%@.%@", _yyyy, _MM)
                } else {
                    lblBirthdayValue.text = UI_Utility.convertDateStringToString(_bday, fromType: .yyyyMMdd, toType: .ENGLISH_MONTHLY_dd)
                }
            } else {
                lblBirthdayValue.text = ""
            }
        }
        
        lblAppVersion.text = Config.bundleVersion
        
        if (Config.channel == .goodmonit || Config.channel == .kc) {
            let _email = String(format: ": %@", DataManager.instance.m_userInfo.email)
            m_arrHeader.append("title_account".localized + _email)
        } else {
            m_arrHeader.append("title_account".localized)
        }

        m_arrHeader.append("legal_notice".localized)
        m_arrHeader.append("help".localized)
        m_arrHeader.append("account_setup_header_nugu".localized)
        m_arrHeader.append("")
        m_arrHeader.append("")
        m_arrHeader.append("")
        
        lblMemberIDTitle.text = "account_shortid".localized
        lblMemberID.text = DataManager.instance.m_userInfo.shareMember.getMyGroupMasterInfo()?.sid ?? ""
        
        lblChangePwTitle.text = "account_change_password".localized
        
        lblNicknameTitle.text = "account_nickname".localized
        lblSexTitle.text = "account_gender".localized
        lblBirthTitle.text = "account_birthday".localized
        lblPrivacy.text = "legal_privacy".localized
        lblTerms.text = "legal_terms".localized
        lblSupport.text = "help_support".localized
        lblCollectInfo.text = "legal_collect_privacy".localized
        lbl3rdParty.text = "legal_provide_3rd_party".localized
        lblNoticeBoardTitle.text = "notice_title".localized
        lblNUGU.text = "nugu_title".localized
        lblAssistant.text = "assistant_title".localized
        lblAppVersionTitle.text = "setting_device_app_version".localized
        lblLogout.text = "btn_signout".localized
        lblLeave.text = "btn_leave".localized
        
        if (Config.channel != .monitXHuggies) {
            cellTermsOfUse.separatorInset = UIEdgeInsets.zero // 하단 라인을 앞쪽까지 붙인다.
        }
    }
    
    func setOnClick() {
        let _changePw = UITapGestureRecognizer(target: self, action: #selector(UserSetupMainTableViewController.onClick_changePw))
        lblChangePwTitle.isUserInteractionEnabled = true
        lblChangePwTitle.addGestureRecognizer(_changePw)
        
        let _logout = UITapGestureRecognizer(target: self, action: #selector(UserSetupMainTableViewController.onClick_logout))
        lblLogout.isUserInteractionEnabled = true
        lblLogout.addGestureRecognizer(_logout)
        
        let _leave = UITapGestureRecognizer(target: self, action: #selector(UserSetupMainTableViewController.onClick_leave))
        lblLeave.isUserInteractionEnabled = true
        lblLeave.addGestureRecognizer(_leave)
        
        let _privacy = UITapGestureRecognizer(target: self, action: #selector(UserSetupMainTableViewController.onClick_privacy))
        lblPrivacy.isUserInteractionEnabled = true
        lblPrivacy.addGestureRecognizer(_privacy)
        
        let _terms = UITapGestureRecognizer(target: self, action: #selector(UserSetupMainTableViewController.onClick_terms))
        lblTerms.isUserInteractionEnabled = true
        lblTerms.addGestureRecognizer(_terms)
        
        let _support = UITapGestureRecognizer(target: self, action: #selector(UserSetupMainTableViewController.onClick_support))
        lblSupport.isUserInteractionEnabled = true
        lblSupport.addGestureRecognizer(_support)
        
        let _collectInfo = UITapGestureRecognizer(target: self, action: #selector(UserSetupMainTableViewController.onClick_collectInfo))
        lblCollectInfo.isUserInteractionEnabled = true
        lblCollectInfo.addGestureRecognizer(_collectInfo)
        
        let _3rdParty = UITapGestureRecognizer(target: self, action: #selector(UserSetupMainTableViewController.onClick_3rdParty))
        lbl3rdParty.isUserInteractionEnabled = true
        lbl3rdParty.addGestureRecognizer(_3rdParty)
        
        let _nickname = UITapGestureRecognizer(target: self, action: #selector(UserSetupMainTableViewController.onClick_nickname))
        lblNicknameTitle.isUserInteractionEnabled = true
        lblNicknameTitle.addGestureRecognizer(_nickname)
        
        let _nugu = UITapGestureRecognizer(target: self, action: #selector(UserSetupMainTableViewController.onClick_nugu))
        lblNUGU.isUserInteractionEnabled = true
        lblNUGU.addGestureRecognizer(_nugu)
        
        let _assistant = UITapGestureRecognizer(target: self, action: #selector(UserSetupMainTableViewController.onClick_assistant))
        lblAssistant.isUserInteractionEnabled = true
        lblAssistant.addGestureRecognizer(_assistant)
        
        let _noticeBoard = UITapGestureRecognizer(target: self, action: #selector(UserSetupMainTableViewController.onClick_noticeBoard))
        lblNoticeBoardTitle.isUserInteractionEnabled = true
        lblNoticeBoardTitle.addGestureRecognizer(_noticeBoard)
    }
    
    @objc func onClick_changePw() {
        _ = UIManager.instance.sceneMoveNaviPush(scene: .setupChangePassword)
    }
    
    @objc func onClick_nickname() {
        _ = UIManager.instance.sceneMoveNaviPush(scene: .setupChangeNick)
    }
    
    @objc func onClick_nugu() {
        _ = UIManager.instance.sceneMoveNaviPush(scene: .setupNUGU)
    }
    
    @objc func onClick_assistant() {
        _ = UIManager.instance.sceneMoveNaviPush(scene: .setupAssistant)
    }
    
    @objc func onClick_noticeBoard() {
        let _param = UIManager.instance.getBoardParam(board: BOARD_TYPE.notice)
        let _scene = UIManager.instance.sceneMoveNaviPush(scene: .customWebView, isAniamtion: false) as! CustomWebViewController
        _scene.setInit(url: "\(Config.BOARD_DEFAULT_URL)\(_param)", naviTitle: "notice_title".localized)
    }
    
    @objc func onClick_logout() {
        _ = PopupManager.instance.onlyContents(contentsKey: "dialog_contents_sign_out_confirm_description", confirmType: .cancleOK, okHandler: { () -> () in
            let send = Send_Signout()
            send.aid = DataManager.instance.m_userInfo.account_id
            send.token = DataManager.instance.m_userInfo.token
            NetworkManager.instance.Request(send) { (json) -> () in
                self.getReceiveDataSignout(json)
            }
        })
    }
    
    func getReceiveDataSignout(_ json: JSON) {
        let receive = Receive_Signout(json)
        switch receive.ecd {
        case .success:
            SystemManager.instance.logOut()
            if (Config.channel == .monitXHuggies) {
                YKSignout()
            }
        default: Debug.print("[ERROR] invaild errcod", event: .error)
        }
    }
    
    func YKSignout() {
        let _token = DataManager.instance.m_userInfo.configData.OAuthToken
        if (_token != "") {
            do {
                let jwt = try decode(jwt: _token)
                let claim = jwt.claim(name: "login_key")
                if let login_key = claim.string {
                    DataManager.instance.m_userInfo.configData.OAuthToken = ""
                    sendYKSignout(login_key: login_key)
                }
            } catch (let error) {
                Debug.print("[ERROR] YKSignout jwt parsing error \(error)", event: .error)
            }
        }
    }
    
    func sendYKSignout(login_key: String) {
      guard let url = URL(string: Config.MONIT_X_HUGGIES_OAUTH2_SIGNOUT_URL) else {
        return
      }
      Alamofire.request(url,
                        method: .post,
                        parameters: ["login_key": login_key])
      .validate()
      .responseJSON { response in
        guard response.result.isSuccess else {
            Debug.print("[ERROR] sendYKSignout send error \(String(describing: response.result.error))", event: .error)
            return
        }
      }
    }
    
    @objc func onClick_leave() {
        _ = PopupManager.instance.withTitle(titleKey: "dialog_contents_leave_confirm", contentsKey: "dialog_contents_leave_confirm_description", confirmType: .cancleLeave, okHandler: { () -> () in
            let send = Send_Leave()
            send.aid = DataManager.instance.m_userInfo.account_id
            send.token = DataManager.instance.m_userInfo.token
            
            NetworkManager.instance.Request(send) { (json) -> () in
                self.getReceiveDataLeave(json)
            }
        })
    }
    
    func getReceiveDataLeave(_ json: JSON) {
        let receive = Receive_Leave(json)
        switch receive.ecd {
        case .success:
            DataManager.instance.m_userInfo.storeConnectedSensor.deleteItemForLeaved()
            SystemManager.instance.leave()
            _ = UIManager.instance.sceneMove(scene: .initView, animation: .coverVertical, isAnimation: false)
        default: Debug.print("[ERROR] invaild errcod", event: .error)
        }
    }

    // gdpr 약관 동의 여부에 따라 변경
    @objc func onClick_privacy() {
        ScreenAnalyticsManager.instance.googleTagManagerCustom(type: .account_privacy_policy, items: ["accountid_\(DataManager.instance.m_userInfo.account_id.description)" : UI_Utility.nowUTCDate(type: .yyMMdd_HHmmss)])
        
        var _isFound = false
        for item in DataManager.instance.m_userInfo.arrPolicy {
            if let _ptype = item.ptype, let _agree = item.agree, _agree == 1 {
                if (POLICY_AGREE_TYPE.goodmonit_privacy_gdpr.rawValue == _ptype) {
                    _isFound = true
                    _ = Utility.urlOpen(UIManager.instance.getPolicyPrivacyURL(type: .goodmonit_privacy_gdpr))
                    return
                }
                if (POLICY_AGREE_TYPE.goodmonit_privacy.rawValue == _ptype) {
                    _isFound = true
                    _ = Utility.urlOpen(UIManager.instance.getPolicyPrivacyURL(type: .goodmonit_privacy))
                    return
                }
                if (POLICY_AGREE_TYPE.huggies_privacy.rawValue == _ptype) {
                    _isFound = true
                    _ = Utility.urlOpen(UIManager.instance.getPolicyPrivacyURL(type: .huggies_privacy))
                    return
                }
                if (POLICY_AGREE_TYPE.kao_privacy_gdpr.rawValue == _ptype) {
                    _isFound = true
                    _ = Utility.urlOpen(UIManager.instance.getPolicyPrivacyURL(type: .kao_privacy_gdpr))
                    return
                }
                if (POLICY_AGREE_TYPE.kao_privacy.rawValue == _ptype) {
                    _isFound = true
                    _ = Utility.urlOpen(UIManager.instance.getPolicyPrivacyURL(type: .kao_privacy))
                    return
                }
            }
        }
        if (!_isFound) {
            switch Config.channel {
            case .monitXHuggies:
                _ = Utility.urlOpen(UIManager.instance.getPolicyPrivacyURL(type: .huggies_privacy))
            case .goodmonit:
                _ = Utility.urlOpen(UIManager.instance.getPolicyPrivacyURL(type: .goodmonit_privacy))
            case .kao:
                _ = Utility.urlOpen(UIManager.instance.getPolicyPrivacyURL(type: .kao_privacy))
            default:
                _ = Utility.urlOpen(UIManager.instance.getPolicyPrivacyURL(type: .goodmonit_privacy))
            }
        }
    }
    
    @objc func onClick_terms() {
        ScreenAnalyticsManager.instance.googleTagManagerCustom(type: .account_terms_and_conditions, items: ["accountid_\(DataManager.instance.m_userInfo.account_id.description)" : UI_Utility.nowUTCDate(type: .yyMMdd_HHmmss)])
        
        switch Config.channel {
        case .monitXHuggies:
            _ = Utility.urlOpen(UIManager.instance.getPolicyServiceURL(type: .huggies_service))
        case .goodmonit:
            _ = Utility.urlOpen(UIManager.instance.getPolicyServiceURL(type: .goodmonit_service))
        case .kao:
            _ = Utility.urlOpen(UIManager.instance.getPolicyServiceURL(type: .kao_service))
        default:
            _ = Utility.urlOpen(UIManager.instance.getPolicyServiceURL(type: .goodmonit_service))
        }
        
//        if (Config.channel == .kc) {
//            _ = Utility.urlOpen(Config.KC_TERMS_URL)
//            return
//        }
        
//        var _isFound = false
//        for item in DataManager.instance.m_userInfo.arrPolicy {
//            if let _ptype = item.ptype, let _agree = item.agree, _agree == 1 {
//                if (POLICY_AGREE_TYPE.goodmonit_service.rawValue == _ptype) {
//                    _isFound = true
//                    _ = Utility.urlOpen(UIManager.instance.getPolicyServiceURL(type: .goodmonit_service))
//                    return
//                }
//                if (POLICY_AGREE_TYPE.huggies_service.rawValue == _ptype) {
//                    _isFound = true
//                    _ = Utility.urlOpen(UIManager.instance.getPolicyServiceURL(type: .huggies_service))
//                    return
//                }
//            }
//        }
//        if (!_isFound) {
//            if (Config.languageType == .ko) {
//                _ = Utility.urlOpen(UIManager.instance.getPolicyServiceURL(type: .huggies_service))
//            } else {
//                _ = Utility.urlOpen(UIManager.instance.getPolicyServiceURL(type: .goodmonit_service))
//            }
//        }
    }
    
//    @objc func onClick_warranty() {
//        switch Config.channel {
//        case .goodmonit: _ = Utility.urlOpen(Config.WARRANTY_URL)
//        case .monitXHuggies: _ = Utility.urlOpen(Config.HUGGIES_WARRANTY_URL)
//        }

//        lblMarketingTitle.text = "마케팅 수신 동의"
//        lblMarketingContents.text = "마케팅 수신에 동의하시겠습니까?"
//        btnMarketingUrl.setTitleWithOutAnimation(title: "agreement_title_link".localized.uppercased())
//        btnMarketingYes.setTitleWithOutAnimation(title: "btn_yes".localized.uppercased())
//        btnMarketingNo.setTitleWithOutAnimation(title: "btn_no".localized.uppercased())
//        btnMarketingCancle.setTitleWithOutAnimation(title: "btn_cancel".localized.uppercased())
//
//        viewMarketing.backgroundColor = UIColor.gray.withAlphaComponent(0.4)
//        viewMarketing.frame = m_parentView!.frame
//        viewMarketingMain.center = m_parentView!.center
//        viewMarketingMain.layer.cornerRadius = 9.0
//        m_parentView?.addSubview(viewMarketing)
//        UI_Utility.textUnderline(btnMarketingUrl.titleLabel)
//        lblMarketingTitle.font = UIFont.boldSystemFont(ofSize: 14.0)
//    }
    
    @objc func onClick_support() {
        ScreenAnalyticsManager.instance.googleTagManagerCustom(type: .account_customer_support, items: ["accountid_\(DataManager.instance.m_userInfo.account_id.description)" : UI_Utility.nowUTCDate(type: .yyMMdd_HHmmss)])
        
        switch Config.channel {
        case .kc, .kao:
            _ = Utility.urlOpen(Config.KC_SUPPORT_URL)
        default:
            _ = Utility.urlOpen(Config.SUPPORT_URL)
        }
    }
    
    @objc func onClick_collectInfo() {
        switch Config.channel {
        case .goodmonit, .kc, .kao: break
        case .monitXHuggies: _ = Utility.urlOpen(Config.HUGGIES_COLLECT_URL)
        }
    }
    
    @objc func onClick_3rdParty() {
        switch Config.channel {
        case .goodmonit, .kc: break
        case .kao: _ = Utility.urlOpen(Config.KAO_THIRDPARTY_URL)
        case .monitXHuggies: _ = Utility.urlOpen(Config.HUGGIES_THIRDPARTY_URL)
        }
    }

    // send log - 현재 사용하지 않음, 모니터링 모드 때만 파일 기록 되도록 수정해 놓아서, 디버그 파일도 수정 필요함
//    @objc func onClick_sendReport() {
//        _ = PopupManager.instance.onlyContents(contentsKey: "dialog_contents_send_report", confirmType: .cancleOK, okHandler: { () -> () in
////            Crashlytics.sharedInstance().crash()
//            ReportManager.instance.fileSend(isMonitoring: false)
//        })
//    }

    @IBAction func onClick_marketingUrl(_ sender: UIButton) {
        _ = Utility.urlOpen(Config.HUGGIES_THIRDPARTY_URL)
    }
    
    @IBAction func onClick_marketingYes(_ sender: UIButton) {
//        let send = Send_SetPolicy()
//        send.aid = DataManager.instance.m_userInfo.account_id
//        send.token = DataManager.instance.m_userInfo.token
//        send.data.append(Send_SetPolicy.SetPolicyInfo(ptype: Int(POLICY_AGREE_TYPE.huggies_service.rawValue) ?? -1, agree: 1))
//        NetworkManager.instance.Request(send) { (json) -> () in
//            let receive = Receive_SetPolicy(json)
//            switch receive.ecd {
//            case .success: break
//            default:
//                Debug.print("[ERROR] invaild errcod", event: .error)
//            }
//        }
    }
    
    @IBAction func onClick_marketingNo(_ sender: UIButton) {
        //        let send = Send_SetPolicy()
        //        send.aid = DataManager.instance.m_userInfo.account_id
        //        send.token = DataManager.instance.m_userInfo.token
        //        send.data.append(Send_SetPolicy.SetPolicyInfo(ptype: Int(POLICY_AGREE_TYPE.huggies_service.rawValue) ?? -1, agree: 0))
        //        NetworkManager.instance.Request(send) { (json) -> () in
        //            let receive = Receive_SetPolicy(json)
        //            switch receive.ecd {
        //            case .success: break
        //            default:
        //                Debug.print("[ERROR] invaild errcod", event: .error)
        //            }
        //        }
    }
  
    @IBAction func onClick_marketingCancle(_ sender: UIButton) {
        viewMarketing.removeFromSuperview()
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        
        var _input = ""
        for (i, item) in header.textLabel!.text!.enumerated() {
            if (i == 0) {
                _input = item.description.uppercased()
            } else {
                _input += item.description.lowercased()
            }
        }
        header.textLabel?.text = _input
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (CATEGORY.account_link.rawValue == section) {
            if (Config.channel != .monitXHuggies && !DataManager.instance.m_userInfo.configData.isMaster) {
                return nil
            }
        }
        return m_arrHeader[section]
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (CATEGORY.userInfo.rawValue == section) {
            return 40.0
        }
        
        else if (CATEGORY.account_link.rawValue == section) {
            if (Config.channel != .monitXHuggies && !DataManager.instance.m_userInfo.configData.isMaster) {
                return CGFloat.leastNonzeroMagnitude
            }
        }
        
        if (m_arrHeader[section] == "") {
            return 7.0
        }
        
        return 20.0
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if (CATEGORY.account_link.rawValue == section) {
            if (Config.channel != .monitXHuggies && !DataManager.instance.m_userInfo.configData.isMaster) {
                return CGFloat.leastNonzeroMagnitude
            }
        }
        return 20.0
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var isHidden = false

        // set hidden list
        switch Config.channel {
        case .goodmonit, .kc:
            if (isCellHidden(indexPath: indexPath, sectionIdx: CATEGORY.policy.rawValue, rowIdx: SUB_CATEGORY_POLICY.collectInfo.rawValue)) {
                cellCollectInfo.isHidden = true
                isHidden = true
            }
            if (isCellHidden(indexPath: indexPath, sectionIdx: CATEGORY.policy.rawValue, rowIdx: SUB_CATEGORY_POLICY.thirdParty.rawValue)) {
                cell3rdParty.isHidden = true
                isHidden = true
            }
        case .kao:
            if (isCellHidden(indexPath: indexPath, sectionIdx: CATEGORY.policy.rawValue, rowIdx: SUB_CATEGORY_POLICY.collectInfo.rawValue)) {
                cellCollectInfo.isHidden = true
                isHidden = true
            }
        case .monitXHuggies:
            if (isCellHidden(indexPath: indexPath, sectionIdx: CATEGORY.userInfo.rawValue, rowIdx: SUB_CATEGORY_USERINFO.changePassword.rawValue)) {
                cellPw.isHidden = true
                isHidden = true
            }
            if (isCellHidden(indexPath: indexPath, sectionIdx: CATEGORY.userInfo.rawValue, rowIdx: SUB_CATEGORY_USERINFO.sex.rawValue)) {
                cellSex.isHidden = true
                isHidden = true
            }
            if (isCellHidden(indexPath: indexPath, sectionIdx: CATEGORY.userInfo.rawValue, rowIdx: SUB_CATEGORY_USERINFO.birth.rawValue)) {
                cellBirth.isHidden = true
                isHidden = true
            }
            if (isCellHidden(indexPath: indexPath, sectionIdx: CATEGORY.leave.rawValue, rowIdx: SUB_CATEGORY_LEAVE.leave.rawValue)) {
                cellLeave.isHidden = true
                isHidden = true
            }
        }

        if (Config.channel != .monitXHuggies && !DataManager.instance.m_userInfo.configData.isMaster) {
            if (isCellHidden(indexPath: indexPath, sectionIdx: CATEGORY.account_link.rawValue, rowIdx: SUB_CATEGORY_ACCOUNT_LINK.nugu.rawValue)) {
                cellNUGU.isHidden = true
                isHidden = true
            }
            if (isCellHidden(indexPath: indexPath, sectionIdx: CATEGORY.account_link.rawValue, rowIdx: SUB_CATEGORY_ACCOUNT_LINK.assistant.rawValue)) {
                cellAssistant.isHidden = true
                isHidden = true
            }
        }
        
        return isHidden ? 0 : 44.0
    }
    
    func isCellHidden(indexPath: IndexPath, sectionIdx: Int, rowIdx: Int) -> Bool {
        if (indexPath.section == sectionIdx && indexPath.row == rowIdx) {
            return true
        }
        
        return false
    }
}
