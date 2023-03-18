//
//  UserChangeNickViewController.swift
//  Monit
//
//  Created by 맥 on 2017. 9. 7..
//  Copyright © 2017년 맥. All rights reserved.
//

import UIKit
import SwiftyJSON

class SigninNickMonitXHuggiesViewController: BaseViewController, LabelFormDelegate {
    @IBOutlet weak var lblNaviTItle: UILabel!
    @IBOutlet weak var btnNaviNext: UIButton!
    @IBOutlet weak var lblNicknameTitle: UILabel!
    
    @IBOutlet weak var imgCheckNickname: UIImageView!
    @IBOutlet weak var txtNickname: UITextField!
    @IBOutlet weak var lblNickname: UILabel!
    @IBOutlet weak var btnDeleteNickname: UIButton!
    @IBOutlet weak var txtNicknameVaild: UILabel!
    @IBOutlet weak var constNickname: NSLayoutConstraint!
    
    var m_nameForm: LabelFormController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Debug.print("[UI][\(self.classNameToString()).viewDidLoad()]")
        txtNickname.delegate = self
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
        
        lblNaviTItle.text = "account_change_nickname".localized
        btnNaviNext.setTitle("btn_save".localized.uppercased(), for: .normal)
        lblNicknameTitle.text = "account_nickname".localized
        let _nick = DataManager.instance.m_userInfo.shareMember.getMyGroupMasterInfo()?.nick ?? ""
        txtNickname.text = _nick
        m_nameForm?.editing(isTrim: false)
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
    
    func needVaildPopup(_ key: String)
    {
        _ = PopupManager.instance.onlyContents(contentsKey: key, confirmType: .ok)
    }
    
    @IBAction func onClick_Back(_ sender: UIButton) {
        UIManager.instance.sceneMoveNaviPop()
    }
    
    @IBAction func onClick_Next(_ sender: UIButton) {
        let _nick = DataManager.instance.m_userInfo.shareMember.getMyGroupMasterInfo()?.nick ?? ""
        if (!m_nameForm!.m_isVaild) {
            needVaildPopup("account_warning_dialog_nickname")
        } else if (txtNickname.text == _nick) {
            needVaildPopup("toast_change_same_nickname")
        } else {
            let send = Send_ChangeNickname()
            send.aid = DataManager.instance.m_userInfo.account_id
            send.token = DataManager.instance.m_userInfo.token
            send.nick = Utility.urlEncode(txtNickname.text)
            NetworkManager.instance.Request(send) { (json) -> () in
                self.getReceiveData(json)
            }
        }
    }
    
    func getReceiveData(_ json: JSON) {
        let receive = Receive_ChangeNickname(json)
        switch receive.ecd {
        case .success:
            if let _Info = DataManager.instance.m_userInfo.shareMember.getMyGroupMasterInfo() {
                _Info.nick = txtNickname.text!
            }
            _ = PopupManager.instance.onlyContents(contentsKey: "toast_change_nickname_succeeded", confirmType: .ok, okHandler: { () -> () in
                UIManager.instance.sceneMoveNaviPop()
            })
        default: Debug.print("[ERROR] invaild errcod", event: .error)
        _ = PopupManager.instance.onlyContents(contentsKey: "toast_change_nickname_failed", confirmType: .ok, okHandler: { () -> () in
            UIManager.instance.sceneMoveNaviPop()
        })
        }
    }
    
    @IBAction func editing_nickname(_ sender: UITextField) {
        m_nameForm?.editing(isTrim: false)
    }
    
    @IBAction func onClick_deleteNickname(_ sender: UIButton) {
        m_nameForm?.onClick_delete()
    }
}
