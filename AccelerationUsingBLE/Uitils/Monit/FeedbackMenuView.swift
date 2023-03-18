//
//  FeedbackMenuView.swift
//  Monit
//
//  Created by 맥 on 2018. 1. 3..
//  Copyright © 2018년 맥. All rights reserved.
//

import UIKit

class FeedbackMenuView: UIView, UITextFieldDelegate {
//    @IBOutlet weak var btnTesterStart: UIButton!
//    @IBOutlet weak var btnTesterEnd: UIButton!
    @IBOutlet weak var btnTesterClear: UIButton!
    @IBOutlet weak var btnTesterPee: UIButton!
    @IBOutlet weak var btnTesterPoo: UIButton!
    @IBOutlet weak var btnTesterCustomMemo: UIButton!
    @IBOutlet weak var lblDiaperStatusTitle: UILabel!
    @IBOutlet weak var txtTesterInput: UITextField!
    @IBOutlet weak var lblTesterDefault: UILabel!
    @IBOutlet weak var btnTesterDelete: UIButton!
    @IBOutlet weak var naviHeightView: UIView!
    @IBOutlet weak var lblNaviArrow: UILabel!
    
    enum TesterSubType: Int {
        case feedback_none = 10
        case feedback_pee = 11
        case feedback_poo = 12
    }
    
    var m_parent: DeviceSensorDetailNotiViewController?
    var m_testerMemoForm: LabelFormController?
    var m_isEnable: Bool = false
    var m_keyboardSize: CGFloat = 0

    override func awakeFromNib() {
        NotificationCenter.default.addObserver(self, selector:
            #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide,
                                             object: nil)
        NotificationCenter.default.addObserver(self, selector:
            #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow,
                                             object: nil)
    }
    
    func setUI() {
        txtTesterInput.delegate = self
        
//        UI_Utility.customButtonBorder(button: btnTesterStart, radius: 0, width: 1, color: COLOR_TYPE.green.color.cgColor)
//        UI_Utility.customButtonBorder(button: btnTesterEnd, radius: 0, width: 1, color: COLOR_TYPE.green.color.cgColor)
        UI_Utility.customButtonBorder(button: btnTesterClear, radius: btnTesterClear.bounds.height / 2, width: 1, color: COLOR_TYPE.lblGray.color.cgColor)
        UI_Utility.customButtonBorder(button: btnTesterPee, radius: btnTesterPee.bounds.height / 2, width: 1, color: COLOR_TYPE.lblGray.color.cgColor)
        UI_Utility.customButtonBorder(button: btnTesterPoo, radius: btnTesterPoo.bounds.height / 2, width: 1, color: COLOR_TYPE.lblGray.color.cgColor)
        UI_Utility.customButtonBorder(button: btnTesterCustomMemo, radius: btnTesterCustomMemo.bounds.height / 2, width: 1, color: COLOR_TYPE.green.color.cgColor)
        
        UI_Utility.customButtonShadow(button: btnTesterClear, radius: 1, offsetWidth: 1, offsetHeight: 1, color: UIColor.black.cgColor, opacity: 0.3)
        UI_Utility.customButtonShadow(button: btnTesterPee, radius: 1, offsetWidth: 1, offsetHeight: 1, color: UIColor.black.cgColor, opacity: 0.3)
        UI_Utility.customButtonShadow(button: btnTesterPoo, radius: 1, offsetWidth: 1, offsetHeight: 1, color: UIColor.black.cgColor, opacity: 0.3)
        UI_Utility.customButtonShadow(button: btnTesterCustomMemo, radius: 1, offsetWidth: 1, offsetHeight: 1, color: UIColor.black.cgColor, opacity: 0.3)
  
        m_testerMemoForm = LabelFormController(txtInput: txtTesterInput, btnDelete: btnTesterDelete, minLength: 1, maxLength: 2000, maxByte: -1, imgCheck: nil)
        m_testerMemoForm?.setDefaultText(lblDefault: lblTesterDefault, defaultText: "feedback_input_text".localized)
        btnTesterCustomMemo.setTitle("btn_send".localized.uppercased(), for: .normal)
        lblDiaperStatusTitle.text = "feedback_diaper_status".localized
        btnTesterClear.setTitle("feedback_none".localized.uppercased(), for: .normal)
        btnTesterPee.setTitle("feedback_pee".localized.uppercased(), for: .normal)
        btnTesterPoo.setTitle("feedback_poo".localized.uppercased(), for: .normal)

        let _parentHeight = m_parent!.m_parent!.view.bounds.height
        self.frame = CGRect(x: 0, y: _parentHeight - naviHeightView.frame.size.height, width: self.superview!.bounds.width, height: frame.size.height)

        setStatus(isEnable: true)
    }
    
    @objc func keyboardWillShow(_ sender:Notification){
        if let keyboardFrame: NSValue = sender.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            m_keyboardSize = keyboardHeight
            self.frame.origin.y -= keyboardHeight
        }
    }
    
    @objc func keyboardWillHide(_ sender:Notification){
        self.frame.origin.y += m_keyboardSize
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.endEditing(true)
        return false
    }
    
    @IBAction func onClick_changeStatus(_ sender: UIButton) {
        changeStatus()
    }
    
    func changeStatus() {
        setStatus(isEnable: !m_isEnable)
    }
    
    func setStatus(isEnable: Bool) {
        if (isEnable) {
            self.frame.origin.y -= 160 - naviHeightView.frame.size.height
            lblNaviArrow.text = "▼"
        } else {
            self.frame.origin.y += 160 - naviHeightView.frame.size.height
            lblNaviArrow.text = "▲"
            m_parent?.view.endEditing(true)
        }
        
        m_isEnable = isEnable
    }
    
    func addCustomType(notiType: DEVICE_NOTI_TYPE, extra: String = "") {
//        var _utcTime = UIManager.instance.localToUTC(date: UIManager.instance.nowLocalDate(type: .full).description)
//        _utcTime = UIManager.instance.convertDateStringToString(_utcTime, fromType: .full, toType: .yyMMdd_HHmmss)
        // after noti item
//        let _info = DeviceNotiInfo(id: 0, nid: 0, type: DEVICE_TYPE.Sensor.rawValue, did: m_parent!.m_did, noti: notiType.rawValue , time: _utcTime, extra: extra)
        
//        DataManager.instance.m_dataController.deviceNoti.saveData(arrNotiInfo: [_info])
        m_parent!.setUI()
        m_parent?.view.endEditing(true)
        m_testerMemoForm?.onClick_delete()
        changeStatus()
        m_parent!.table.reloadData()
    }

    @IBAction func onClick_clear(_ sender: UIButton) {
        sendNotificationFeedback(notiType: .custom_status, extra: "10")
    }
    
    @IBAction func onClick_pee(_ sender: UIButton) {
        sendNotificationFeedback(notiType: .custom_status, extra: "11")
    }
    
    @IBAction func onClick_poo(_ sender: UIButton) {
        sendNotificationFeedback(notiType: .custom_status, extra: "12")
    }
    
    @IBAction func editing_memo(_ sender: Any) {
        m_testerMemoForm?.editing(isTrim: false)
    }
    
    @IBAction func onClick_delete(_ sender: UIButton) {
        m_testerMemoForm?.onClick_delete()
    }
    
    @IBAction func onClick_customMemo(_ sender: UIButton) {
        if (m_testerMemoForm!.m_isVaild) {
            sendNotificationFeedback(notiType: .custom_memo, extra: m_testerMemoForm!.m_txtInput!.text!)
        }
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
