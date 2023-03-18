//
//  FeedbackMenuView.swift
//  Monit
//
//  Created by 맥 on 2018. 1. 3..
//  Copyright © 2018년 맥. All rights reserved.
//

import UIKit

class FeedbackMenuV2View: UIView, UITextFieldDelegate {
    @IBOutlet weak var btnTesterPee: UIButton!
    @IBOutlet weak var btnTesterPoo: UIButton!
    @IBOutlet weak var btnTesterCustomMemo: UIButton!
    @IBOutlet weak var btnTesterAdd: UIButton!
    @IBOutlet weak var btnTesterClose: UIButton!
    @IBOutlet weak var subGroup: UIView!
    
    enum TesterSubType: Int {
        case feedback_pee = 11
        case feedback_poo = 12
    }

    var m_parent: DeviceSensorDetailNotiViewController?

    override func awakeFromNib() {
        setInit()
    }
    
    func setInit() {
        setSubGroup(isEnable: false)
        
        self.frame = CGRect(x: UIScreen.main.bounds.size.width - self.frame.size.width, y: UIScreen.main.bounds.size.height - self.frame.size.height, width: frame.size.width, height: frame.size.height)
    }
    
    func setUI() {
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        for subview in subviews {
            if !subview.isHidden && subview.isUserInteractionEnabled && subview.point(inside: convert(point, to: subview), with: event) {
                return true
            }
        }
        return false
    }
    
    func setSubGroup(isEnable: Bool) {
        if (isEnable) {
            subGroup.isHidden = false
            btnTesterAdd.isHidden = true
            btnTesterClose.isHidden = false
        } else {
            subGroup.isHidden = true
            btnTesterAdd.isHidden = false
            btnTesterClose.isHidden = true
        }
    }
    
    func customMemoPopup() {
        let alert = UIAlertController(title: "feedback_diaper_status".localized, message: "feedback_input_text".localized, preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "btn_cancel".localized.uppercased(), style: .default, handler: { (action: UIAlertAction!) in
        }))

        alert.addAction(UIAlertAction(title: "btn_send".localized.uppercased(), style: .default, handler: { (action: UIAlertAction!) in
            let textField = alert.textFields![0] // Force unwrapping because we know it exists.
            let _text = textField.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            if (_text.count > 0) {
                self.sendNotificationFeedback(notiType: .custom_memo, extra: _text)
            }
        }))
        
        alert.addTextField { (textField: UITextField!) -> Void in
            textField.text = ""
        }
        
        self.m_parent?.present(alert, animated: true, completion: nil)
    }
    
    func addCustomType(notiType: DEVICE_NOTI_TYPE, extra: String = "") {
//        var _utcTime = UIManager.instance.localToUTC(date: UIManager.instance.nowLocalDate(type: .full).description)
//        _utcTime = UIManager.instance.convertDateStringToString(_utcTime, fromType: .full, toType: .yyMMdd_HHmmss)
        // after noti item
//        let _info = DeviceNotiInfo(id: 0, nid: 0, type: DEVICE_TYPE.Sensor.rawValue, did: m_parent!.m_did, noti: notiType.rawValue , time: _utcTime, extra: extra)
        
//        DataManager.instance.m_dataController.deviceNoti.saveData(arrNotiInfo: [_info])
        m_parent!.setUI()
        m_parent?.view.endEditing(true)
        m_parent!.table.reloadData()
    }

    @IBAction func onClick_pee(_ sender: UIButton) {
        sendNotificationFeedback(notiType: .custom_status, extra: TesterSubType.feedback_pee.rawValue.description)
    }
    
    @IBAction func onClick_poo(_ sender: UIButton) {
        sendNotificationFeedback(notiType: .custom_status, extra: TesterSubType.feedback_poo.rawValue.description)
    }

    @IBAction func onClick_customMemo(_ sender: UIButton) {
        customMemoPopup()
    }
    
    @IBAction func onClick_add(_ sender: UIButton) {
        setSubGroup(isEnable: true)
    }
    
    @IBAction func onClick_close(_ sender: UIButton) {
        setSubGroup(isEnable: false)
    }

    func sendNotificationFeedback(notiType: DEVICE_NOTI_TYPE, extra: String) {
        let _send = Send_NotificationFeedback()
        _send.aid = DataManager.instance.m_userInfo.account_id
        _send.token = DataManager.instance.m_userInfo.token
        _send.noti = notiType.rawValue
        _send.type = DEVICE_TYPE.Sensor.rawValue
        _send.did = m_parent!.m_did
        _send.extra = Utility.urlEncode(extra)
        _send.time = UI_Utility.nowUTCDate(type: .yyMMdd_HHmmss)
        NetworkManager.instance.Request(_send) { (json) -> () in
            let receive = Receive_NotificationFeedback(json)
            switch receive.ecd {
            case .success:
                self.addCustomType(notiType: notiType, extra: extra)
                DataManager.instance.m_dataController.deviceNoti.updateForDetailView()
            default:
                Debug.print("[ERROR] invaild errcod", event: .error)
                let _errStr = String(format: "dialog_contents_err_communication_with_server".localized, APP_ERR_COD.Send_NotificationFeedback.rawValue)
                _ = PopupManager.instance.onlyContentsCustom(contents: _errStr, confirmType: .ok, okHandler: { () -> () in
                })
            }
        }
    }
}
