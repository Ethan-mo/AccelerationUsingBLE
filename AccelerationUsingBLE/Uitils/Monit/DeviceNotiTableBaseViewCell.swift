//
//  DeviceNotiTableBaseViewCell.swift
//  Monit
//
//  Created by 맥 on 2018. 1. 4..
//  Copyright © 2018년 맥. All rights reserved.
//

import UIKit

class DeviceNotiTableBaseViewCell: UITableViewCell {
    @IBOutlet weak var imgIcon: UIImageView!
    @IBOutlet weak var btnInfo: UIButton!
    @IBOutlet weak var lblInfo: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var imgNewAlarm: UIImageView!

    var m_parent: DeviceDetailNotiBaseViewController?
    var m_deviceNotiInfo: DeviceNotiInfo?
    var m_sectionIndex = -1
    var m_index = -1

    func setInit() {
        setNotiType(noti: m_deviceNotiInfo)
        setNotiTime(notiType: m_deviceNotiInfo!.notiType)
        imgNewAlarm.isHidden = true
        if let _info = m_deviceNotiInfo {
            if let _lastIdx = m_parent?.m_lastIdx {
                if (_lastIdx != -1 && _lastIdx < _info.m_id) {
                    imgNewAlarm.isHidden = false
                }
            }
        }
    }
    
    func setNotiType(noti: DeviceNotiInfo?) {
        let _imageName = UIManager.instance.getNotiImage(notiType: noti?.notiType ?? .pee_detected, extra: noti?.Extra ?? "")
        imgIcon.image = UIImage(named: _imageName)
        lblInfo.text = String(format: UIManager.instance.getNotiText(info: m_deviceNotiInfo, isB2BMode: DataManager.instance.m_userInfo.configData.isHuggiesV1Alarm))

        // Set Color
        switch noti!.notiType! {
        case .sleep_mode:
            lblInfo.textColor = COLOR_TYPE._blue_71_88_144.color
        default:
            break
        }
    }
    
    func setNotiTime(notiType: DEVICE_NOTI_TYPE?) {
        if let _notiType = notiType {
            if (_notiType == .sleep_mode) {
                if (m_deviceNotiInfo!.m_castExtraTimeInfo != nil) {
                    lblTime.text = "\(m_deviceNotiInfo!.m_castTimeInfo.m_lNotiTime.description) ~ \(m_deviceNotiInfo!.m_castExtraTimeInfo?.m_lNotiTime ?? "")"
                } else {
                    lblTime.text = "\(m_deviceNotiInfo!.m_castTimeInfo.m_lNotiTime.description)"
                }
            } else {
                lblTime.text = m_deviceNotiInfo!.m_castTimeInfo.m_lNotiTime
            }
        } else {
            lblTime.text = m_deviceNotiInfo!.m_castTimeInfo.m_lNotiTime
        }
    }
    
    func deleteItem() {
        let _send = Send_SetNotificationEdit()
        _send.aid = DataManager.instance.m_userInfo.account_id
        _send.token = DataManager.instance.m_userInfo.token
        _send.type = m_deviceNotiInfo?.m_type ?? -1
        _send.did = m_deviceNotiInfo?.m_did ?? -1
        _send.edit_type = NOTI_EDIT_TYPE.delete.rawValue
        _send.nid = m_deviceNotiInfo?.m_nid ?? -1
        _send.enc = DataManager.instance.m_dataController.device.getUserInfoByDid(did: m_deviceNotiInfo?.m_did ?? -1, type: m_deviceNotiInfo?.m_type ?? -1)?.enc ?? ""
        NetworkManager.instance.Request(_send) { (json) -> () in
            let receive = Receive_GetNotificationEdit(json)
            switch receive.ecd {
            case .success:
                DataManager.instance.m_dataController.deviceNoti.updateForDetailView(finishHandler: { () -> () in
                    self.m_parent!.setUI()
                    self.m_parent!.table.reloadData()
                })
            default:
                Debug.print("[ERROR] invaild errcod", event: .error)
                let _errStr = String(format: "dialog_contents_err_communication_with_server".localized, "0")
                _ = PopupManager.instance.onlyContentsCustom(contents: _errStr, confirmType: .ok, okHandler: { () -> () in
                })
            }
        }
    }
    
    @IBAction func onClick_updateTime(_ sender: Any) {
    }
    
    @IBAction func onClick_updateTimeConfirm(_ sender: Any) {
        let _send = Send_SetNotificationEdit()
        _send.aid = DataManager.instance.m_userInfo.account_id
        _send.token = DataManager.instance.m_userInfo.token
        _send.type = m_deviceNotiInfo?.m_type ?? -1
        _send.did = m_deviceNotiInfo?.m_did ?? -1
        _send.edit_type = NOTI_EDIT_TYPE.modify.rawValue
        _send.nid = m_deviceNotiInfo?.m_nid ?? -1
        _send.enc = DataManager.instance.m_dataController.device.getUserInfoByDid(did: m_deviceNotiInfo?.m_did ?? -1, type: m_deviceNotiInfo?.m_type ?? -1)?.enc ?? ""
//        _send.time = txtTestUpdate.text// "211111-111111" txtUpdateTime?.text
//        _send.extra = txtTestUpdate?.text ?? ""// "211111-111111" txtUpdateTime?.text
        NetworkManager.instance.Request(_send) { (json) -> () in
            let receive = Receive_GetNotificationEdit(json)
            switch receive.ecd {
            case .success:
                DataManager.instance.m_dataController.deviceNoti.updateForDetailView(finishHandler: { () -> () in
                    self.m_parent!.setUI()
                    self.m_parent!.table.reloadData()
                })
            default:
                Debug.print("[ERROR] invaild errcod", event: .error)
                let _errStr = String(format: "dialog_contents_err_communication_with_server".localized, "0")
                _ = PopupManager.instance.onlyContentsCustom(contents: _errStr, confirmType: .ok, okHandler: { () -> () in
                })
            }
        }
    }
}
