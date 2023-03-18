//
//  DeviceNotiTableForTesterViewCell.swift
//  Monit
//
//  Created by 맥 on 2018. 1. 3..
//  Copyright © 2018년 맥. All rights reserved.
//

import UIKit
import SwiftyJSON

class DeviceNotiTableForTesterViewCell: DeviceNotiTableBaseViewCell {
    @IBOutlet weak var btnYes: UIButton!
    @IBOutlet weak var btnNo: UIButton!
    @IBOutlet weak var btnNotKnow: UIButton!
    @IBOutlet weak var lblCheck: UILabel!
    //    @IBOutlet weak var btnDelete: UIButton!
    
    enum TesterSubType: Int {
        case none = 0
        case yes = 1
        case no = 2
        case question = 3
    }
    
    override func setInit() {
        super.setInit()
        setSubType()
        setUI()
    }
    
    override func setNotiType(noti: DeviceNotiInfo?) {
        super.setNotiType(noti: noti)
        
        // set text
        if (noti!.notiType != nil) {
            switch noti!.notiType! {
            case .custom_status:
                imgIcon.image = UIImage(named: "imgLogoNormalDetail")
                lblInfo.text = UIManager.instance.getNotiText(info: m_deviceNotiInfo, isB2BMode: DataManager.instance.m_userInfo.configData.isHuggiesV1Alarm)
            case .custom_memo:
                imgIcon.image = UIImage(named: "imgLogoNormalDetail")
                lblInfo.text = "\(m_deviceNotiInfo!.Extra)"
            case .detect_diaper_changed:
                if (m_deviceNotiInfo!.Extra != "1" && m_deviceNotiInfo!.Extra != "2") {
                    imgIcon.image = UIImage(named: "imgWarningErrorDetail")
                    lblInfo.text = "device_sensor_diaper_status_detectdiaperchanged_confirm_detail".localized
                }
            default: break
            }
        }
    }
    
    func setSubType() {
        if let _type = TesterSubType(rawValue: Int(m_deviceNotiInfo!.Extra) ?? 0) {
            switch _type {
            case .none:
                lblCheck.text = ""
            case .yes:
                lblInfo.text = lblInfo.text ?? ""
                lblCheck.text = "(O)"
            case .no:
                lblInfo.text = lblInfo.text ?? ""
                lblCheck.text = "(X)"
            case .question:
                lblInfo.text = lblInfo.text ?? ""
                lblCheck.text = "(?)"
            }
        } else {
            lblInfo.text = "\(lblInfo.text!)"
        }
    }
    
    func setUI() {
        UI_Utility.customButtonBorder(button: btnYes, radius: btnYes.bounds.height / 2, width: 1, color: COLOR_TYPE.lblGray.color.cgColor)
        UI_Utility.customButtonBorder(button: btnNo, radius: btnNo.bounds.height / 2, width: 1, color: COLOR_TYPE.lblGray.color.cgColor)
        UI_Utility.customButtonBorder(button: btnNotKnow, radius: btnNotKnow.bounds.height / 2, width: 1, color: COLOR_TYPE.lblGray.color.cgColor)

        UI_Utility.customButtonShadow(button: btnYes, radius: 1, offsetWidth: 1, offsetHeight: 1, color: UIColor.black.cgColor, opacity: 0.3)
        UI_Utility.customButtonShadow(button: btnNo, radius: 1, offsetWidth: 1, offsetHeight: 1, color: UIColor.black.cgColor, opacity: 0.3)
        UI_Utility.customButtonShadow(button: btnNotKnow, radius: 1, offsetWidth: 1, offsetHeight: 1, color: UIColor.black.cgColor, opacity: 0.3)
        
        btnYes.setTitle("feedback_true".localized, for: .normal)
        btnNo.setTitle("feedback_false".localized, for: .normal)
        btnNotKnow.setTitle("feedback_dk".localized, for: .normal)
        
        setButton(isHidden: true)
    }
    
    func setButton(isHidden: Bool) {
        lblTime.isHidden = !isHidden
        lblCheck.isHidden = !isHidden
//        btnDelete.isHidden = isHidden
        lblInfo.isHidden = !isHidden
//        btnInfo.isHidden = !isHidden
        btnYes.isHidden = isHidden
        btnNo.isHidden = isHidden
        btnNotKnow.isHidden = isHidden
        
        if (m_deviceNotiInfo!.m_noti == DEVICE_NOTI_TYPE.detect_diaper_changed.rawValue) {
            btnNotKnow.isHidden = true
        }
    }
    
    @IBAction func onClick_info(_ sender: UIButton) {
        if (m_deviceNotiInfo!.notiType != .custom_memo
            && m_deviceNotiInfo!.notiType != .custom_status
            && m_deviceNotiInfo!.notiType != .diaper_changed
            ) {
            setButton(isHidden: !btnYes.isHidden)
        }
        if (m_deviceNotiInfo!.notiType == .detect_diaper_changed && m_deviceNotiInfo!.Extra == "1") {
            setButton(isHidden: !btnYes.isHidden)
        }
    }
    
    @IBAction func onClick_yes(_ sender: UIButton) {
        sendNotificationFeedback(extra: .yes)
    }
    
    @IBAction func onClick_no(_ sender: UIButton) {
        sendNotificationFeedback(extra: .no, callback: { () -> () in
            if (self.m_deviceNotiInfo!.m_noti == DEVICE_NOTI_TYPE.detect_diaper_changed.rawValue) {
                self.deleteItem()
            }
        })
    }
    
    @IBAction func onClick_question(_ sender: UIButton) {
        sendNotificationFeedback(extra: .question)
    }
    
    func sendNotificationFeedback(extra: TesterSubType, callback: Action? = nil) {
        let _send = Send_NotificationFeedback()
        _send.aid = DataManager.instance.m_userInfo.account_id
        _send.token = DataManager.instance.m_userInfo.token
        _send.noti = m_deviceNotiInfo!.m_noti
        _send.type = DEVICE_TYPE.Sensor.rawValue
        _send.did = m_deviceNotiInfo!.m_did
        _send.extra = extra.rawValue.description
        _send.time = m_deviceNotiInfo!.Time
        NetworkManager.instance.Request(_send) { (json) -> () in
            let receive = Receive_NotificationFeedback(json)
            switch receive.ecd {
            case .success:
                self.m_deviceNotiInfo!.Extra = extra.rawValue.description
                DataManager.instance.m_coreDataInfo.storeDeviceNoti.updateItem(info: self.m_deviceNotiInfo!)
                self.m_parent!.table.reloadData()
                callback?()
            default:
                Debug.print("[ERROR] invaild errcod", event: .error)
                let _errStr = String(format: "dialog_contents_err_communication_with_server".localized, APP_ERR_COD.Send_NotificationFeedback.rawValue)
                _ = PopupManager.instance.onlyContentsCustom(contents: _errStr, confirmType: .ok, okHandler: { () -> () in
                })
            }
        }
    }
}
