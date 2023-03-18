//
//  ShareMemberNotiTableViewCell.swift
//  Monit
//
//  Created by 맥 on 2018. 3. 14..
//  Copyright © 2018년 맥. All rights reserved.
//

import UIKit

class ShareMemberNotiTableViewCell: UITableViewCell {
    @IBOutlet weak var imgIcon: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblInfo: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    
    var m_parent: ShareMemberNotiViewController?
    var m_notiInfo: ShareMemberNotiInfo?

    func setInit() {
        setUI()
    }
    
    func setUI() {
        setIcon()
        setTitle()
        setContents()
        lblTime.text = m_notiInfo!.m_castTimeInfo.m_lNotiTime
    }
    
    func setIcon() {
        if let _noit = m_notiInfo?.notiType {
            switch _noit {
            case .MY_CLOUD_INVITE,
                 .MY_CLOUD_REQUEST,
                 .OTHER_CLOUD_INVITED,
                 .OTHER_CLOUD_REQUEST:
                imgIcon.image = UIImage(named: "imgGroupAddMember")
            case .MY_CLOUD_DELETE,
                 .MY_CLOUD_LEAVE,
                 .OTHER_CLOUD_DELETED,
                 .OTHER_CLOUD_LEAVE:
                imgIcon.image = UIImage(named: "imgGroupRemoveMember")
            case .CLOUD_INIT_DEVICE:
                imgIcon.image = UIImage(named: "imgGroupInitDevice")
            }
        }
    }
    
    func setTitle() {
        if let _noit = m_notiInfo?.notiType {
            switch _noit {
            case .MY_CLOUD_INVITE,
                 .MY_CLOUD_REQUEST,
                 .MY_CLOUD_DELETE,
                 .MY_CLOUD_LEAVE:
                lblTitle.text = "group_mygroup".localized
            case .OTHER_CLOUD_INVITED,
                 .OTHER_CLOUD_REQUEST,
                 .OTHER_CLOUD_DELETED,
                 .OTHER_CLOUD_LEAVE:
                lblTitle.text = String(format: "'%@' %@", m_notiInfo?.m_extra ?? "", "group_title_group".localized)
            case .CLOUD_INIT_DEVICE:
                lblTitle.text = "group_mygroup".localized
            }
        }
    }
    
    func setContents() {
        if let _noit = m_notiInfo?.notiType {
            switch _noit {
            case .MY_CLOUD_INVITE: lblInfo.text = String(format: "%@ : '%@'", "group_message_my_group_invite".localized, m_notiInfo?.m_extra ?? "")
            case .MY_CLOUD_REQUEST: lblInfo.text = String(format: "%@ : '%@'", "group_message_my_group_request".localized, m_notiInfo?.m_extra ?? "")
            case .MY_CLOUD_DELETE: lblInfo.text = String(format: "%@ : '%@'", "group_message_my_group_delete".localized, m_notiInfo?.m_extra ?? "")
            case .MY_CLOUD_LEAVE: lblInfo.text = String(format: "%@ : '%@'", "group_message_my_group_leave".localized, m_notiInfo?.m_extra ?? "")
            case .OTHER_CLOUD_INVITED: lblInfo.text = String(format: "%@", "group_message_my_group_request".localized)
            case .OTHER_CLOUD_REQUEST: lblInfo.text = String(format: "%@", "group_message_other_group_request".localized)
            case .OTHER_CLOUD_DELETED: lblInfo.text = String(format: "%@", "group_message_other_group_deleted".localized)
            case .OTHER_CLOUD_LEAVE: lblInfo.text = String(format: "%@", "group_message_other_group_leave".localized)
            case .CLOUD_INIT_DEVICE: lblInfo.text = String(format: "%@ : '%@'", "group_message_init_device".localized, m_notiInfo?.m_extra ?? "")
            }
        }
    }
}
