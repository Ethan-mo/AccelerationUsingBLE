//
//  ShareMemberShareMemberCell.swift
//  Monit
//
//  Created by 맥 on 2018. 2. 28..
//  Copyright © 2018년 맥. All rights reserved.
//

import UIKit
import SwiftyJSON

class ShareMemberShareMemberCell: UICollectionViewCell {
    @IBOutlet weak var imgIcon: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblContents: UILabel!
    @IBOutlet weak var btnAdd: UIButton!
    @IBOutlet weak var btnRemove: UIButton!
    
    var m_parent: ShareMemberShareViewController!
    var m_isNone: Bool = true
    var m_index: Int = 0
    var m_name: String = ""
    var m_shortid: String = ""
    
    var ftype: Int {
        get {
            return m_index + 1
        }
    }
    
    func setInit(parent: ShareMemberShareViewController, index: Int, isNone: Bool, name: String, shortid: String) {
        m_parent = parent
        m_isNone = isNone
        m_index = index
        m_name = name
        m_shortid = shortid
        setUI()
    }
    
    func setUI() {
        lblTitle.isHidden = true
        lblContents.isHidden = true
        btnAdd.isHidden = true
        btnRemove.isHidden = true
        
        if (m_isNone) {
            btnAdd.isHidden = false
            
            if (Config.channel == .kc) {
                switch m_index {
                case 0, 1, 2 ,3: imgIcon.image = UIImage(named: "imgGroupIconDisable");
                    break
                default: break
                }
            } else {
                switch m_index {
                case 0: imgIcon.image = UIImage(named: "imgMotherDisable")
                case 1: imgIcon.image = UIImage(named: "imgFatherDisable")
                case 2: imgIcon.image = UIImage(named: "imgGrandMotherDisable")
                case 3: imgIcon.image = UIImage(named: "imgGrandFatherDisable")
                    break
                default: break
                }
            }
        } else {
            btnRemove.isHidden = false
            lblTitle.isHidden = false
            lblContents.isHidden = false
            lblTitle.text = m_name
            lblContents.text = m_shortid
            
            if (Config.channel == .kc) {
                switch m_index {
                case 0, 1, 2 ,3: imgIcon.image = UIImage(named: "imgGroupIcon");
                default: break
                }
            } else {
                switch m_index {
                case 0: imgIcon.image = UIImage(named: "imgMother")
                case 1: imgIcon.image = UIImage(named: "imgFather")
                case 2: imgIcon.image = UIImage(named: "imgGrandMother")
                case 3: imgIcon.image = UIImage(named: "imgGrandFather")
                default: break
                }
            }
        }
    }

    @IBAction func onClick_Add(_ sender: UIButton) {
        Debug.print("onclick Add")
        inputPopup()
    }
    
    @IBAction func onclick_remove(_ sender: UIButton) {
        if let _memberInfo = m_parent.memberInfo {
            var _currentInfo: UserInfoMember?
            for item in _memberInfo {
                if (item.sid == m_shortid) {
                    _currentInfo = item
                    break
                }
            }
            if (_currentInfo == nil) {
                return
            }
       
            let _info: UserInfoMember = _currentInfo!
            let _popupInfo = PopupDetailInfo()
            _popupInfo.title = "group_delete_dialog_title".localized
            _popupInfo.contents = "\(m_name)\("group_delete_dialog_description".localized)"
            _popupInfo.buttonType = .both
            _popupInfo.left = "btn_cancel".localized
            _popupInfo.right = "btn_ok".localized
            _popupInfo.rightColor = COLOR_TYPE.mint.color
            _ = PopupManager.instance.setDetail(popupDetailInfo: _popupInfo,
                                                okHandler: { () -> () in
                                                    let send = Send_DeleteCloudMember()
                                                    send.aid = DataManager.instance.m_userInfo.account_id
                                                    send.token = DataManager.instance.m_userInfo.token
                                                    send.tid = _info.aid
                                                    NetworkManager.instance.Request(send) { (json) -> () in
                                                        self.getReceiveData(json, deleteAid: _info.aid)
                                                    }
            }, cancleHandler: { () -> () in
                UIManager.instance.currentUIReload()
            })
        }
    }

    func getReceiveData(_ json: JSON, deleteAid: Int) {
        let receive = Receive_DeleteCloudMember(json)
        
        switch receive.ecd {
        case .success:
            DataManager.instance.m_userInfo.shareMember.deleteMyGroupMember(aid: deleteAid)
            UIManager.instance.currentUIReload()
        case .shareMember_emailExist:
            _ = PopupManager.instance.onlyContents(contentsKey: "toast_delete_group_member_failed", confirmType: .ok)
            DataManager.instance.m_userInfo.shareMember.deleteMyGroupMember(aid: deleteAid)
        default: Debug.print("[ERROR] invaild errcod", event: .error)
        }
        
        self.setUI()
    }
    
    func inputPopup() {
        let _message = String(format: "%@\n\n%@", "dialog_contents_input_invitee_short_id".localized, "group_short_id_description".localized)
        let alert = UIAlertController(title: "group_invite_member".localized, message: _message, preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.text = ""
            textField.placeholder = "group_invite_member_hint".localized
        }
        
        alert.addAction(UIAlertAction(title: "btn_ok".localized, style: .default, handler: { (action: UIAlertAction!) in
            let textField = alert.textFields![0] // Force unwrapping because we know it exists.
            if (textField.text!.count > 0) {
                let send = Send_InviteCloudMember()
                send.aid = DataManager.instance.m_userInfo.account_id
                send.token = DataManager.instance.m_userInfo.token
                send.sid = Utility.urlEncode(textField.text!)
                send.ftype = self.ftype
                
                NetworkManager.instance.Request(send) { (json) -> () in
                    let receive = Receive_InviteCloudMember(json)
                    switch receive.ecd {
                    case .success:
                        let _addMember = UserInfoMember(cid: DataManager.instance.m_userInfo.account_id, aid: receive.aid!, nick: receive.nick!, sid: textField.text!, ftype: self.ftype)
                        DataManager.instance.m_userInfo.shareMember.addMyGroupMember(addMember: _addMember)
                        
                        ScreenAnalyticsManager.instance.googleTagManagerCustom(type: .group, items: ["accountid_\(DataManager.instance.m_userInfo.account_id)" : "\(receive.nick!)_/\(textField.text!)"])
                        
                        UIManager.instance.currentUIReload()
                    case .shareMember_emailExist: _ = PopupManager.instance.onlyContents(contentsKey: "toast_invite_group_member_failed", confirmType: .ok)
                    case .shareMember_limitMember: _ = PopupManager.instance.onlyContents(contentsKey: "toast_invite_group_member_exceeded", confirmType: .ok)
                    case .shareMember_alreadyMember: _ = PopupManager.instance.onlyContents(contentsKey: "toast_invite_group_member_failed", confirmType: .ok)
                    default: Debug.print("[ERROR] invaild errcod", event: .error)
                    }
                }
            }
        }))
        
        alert.addAction(UIAlertAction(title: "btn_cancel".localized, style: .cancel, handler: { (action: UIAlertAction!) in
        }))
        
        m_parent.present(alert, animated: true, completion: nil)
    }

    func needVaildPopup(_ key: String)
    {
        _ = PopupManager.instance.onlyContents(contentsKey: key, confirmType: .ok)
    }
}
