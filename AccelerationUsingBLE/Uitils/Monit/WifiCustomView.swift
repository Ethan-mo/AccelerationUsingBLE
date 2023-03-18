//
//  WifiCustomView.swift
//  Monit
//
//  Created by 맥 on 2017. 10. 9..
//  Copyright © 2017년 맥. All rights reserved.
//

import UIKit
import CoreBluetooth

class WifiCustomView: UIView, UITextFieldDelegate {
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSummary: UILabel!
    @IBOutlet weak var lblNameTitle: UILabel!
    @IBOutlet weak var btnSecuTitle: UIButton!
    @IBOutlet weak var lblPwTitle: UILabel!

    @IBOutlet weak var lblDefault: UILabel!
    @IBOutlet weak var txtInput: UITextField!
    @IBOutlet weak var btnDelete: UIButton!
    
    @IBOutlet weak var lblSecuType: UILabel!
    
    @IBOutlet weak var lblPwDefault: UILabel!
    @IBOutlet weak var txtPwInput: UITextField!
    @IBOutlet weak var btnPwDelete: UIButton!
    
    @IBOutlet weak var viewPw: UIView!
    
    var m_nameForm: LabelFormController?
    var m_pwForm: LabelFormPasswordController?
    var m_detailInfo: WifiConnectDetailInfo?
    var registerType: HUB_TYPES_REGISTER_TYPE = .new
    var m_peripheral: CBPeripheral?
    
    var connectInfo: HubConnectionController? {
        get {
            if let _info = DataManager.instance.m_userInfo.connectSensor.getSensorByDeviceId(deviceId: m_detailInfo!.m_sensorDid) {
                return _info.controller!.m_hubConnectionController
            }
            return nil
        }
    }
    
    func setInfo(info: WifiConnectDetailInfo) {
        self.m_detailInfo = info
        txtInput.delegate = self
        txtPwInput.delegate = self
        
            NotificationCenter.default.addObserver(self, selector:
                #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide,
                                                 object: nil)
            NotificationCenter.default.addObserver(self, selector:
                #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow,
                                                 object: nil)

        
        setUI()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        endEditing(true)
    }

    @objc func keyboardWillShow(_ sender:Notification){
        frame.origin.y = -150
    }
    
    @objc func keyboardWillHide(_ sender:Notification){
        frame.origin.y = 0
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        endEditing(true)
        
        self.txtInput.resignFirstResponder()
        self.txtPwInput.resignFirstResponder()
        return true
    }
    
    func setUI() {
        if (m_nameForm == nil) {
            m_nameForm = LabelFormController(txtInput: txtInput, btnDelete: btnDelete, minLength: 1, maxLength: 50, maxByte: -1, imgCheck: nil)
            m_nameForm!.setDefaultText(lblDefault: lblDefault, defaultText: "connection_hub_hint_input_network_name".localized)
        }

        if (m_pwForm == nil) {
            m_pwForm = LabelFormPasswordController(txtInput: txtPwInput, btnEncrypt: btnPwDelete, minLength: 1, maxLength: 50, imgCheck: nil)
            m_pwForm!.setDefaultText(lblDefault: lblPwDefault, defaultText: "connection_hub_hint_input_ap_password".localized)
        }

        if let _info = connectInfo {
            let _type = WIFI_SECURITY_TYPE(rawValue: _info.m_apSecurityType)
            
            lblSecuType.text = UIManager.instance.getWifiSecurityString(type: _type!)
            
            if (_type! == .NONE) {
                viewPw.isHidden = true
            } else {
                viewPw.isHidden = false
            }
        }
        
        lblTitle.text = "connection_hub_add_new_network_title".localized
        lblSummary.text = "connection_hub_select_ap_detail_etc".localized
        lblNameTitle.text = "connection_hub_network_name".localized
        btnSecuTitle.setTitle("connection_hub_network_security".localized, for: .normal)
        lblPwTitle.text = "connection_hub_ap_password".localized
    }
    
    @IBAction func editingChange(_ sender: UITextField) {
        m_nameForm?.editing(isTrim: false)
    }
    
    @IBAction func onClick_delete(_ sender: UIButton) {
        m_nameForm?.onClick_delete()
    }
    
    @IBAction func onClick_secu(_ sender: UIButton) {
        if let _view = UIManager.instance.sceneMoveNaviPush(scene: .deviceRegisterHubWifiCustomSecu) as? DeviceRegisterHubWifiCustomSecuViewController {
            _view.registerType = registerType
            _view.m_peripheral = m_peripheral
            _view.setInfo(info: m_detailInfo!)
        }
    }
    
    @IBAction func editingChange_pw(_ sender: UITextField) {
        m_pwForm?.editing(isTrim: false)
    }
    
    @IBAction func onClick_encrypt_pw(_ sender: UIButton) {
        m_pwForm?.onClick_encrypt()
    }
}
