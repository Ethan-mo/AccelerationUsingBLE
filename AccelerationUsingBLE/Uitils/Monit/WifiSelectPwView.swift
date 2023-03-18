//
//  WifiSelectPasswordView.swift
//  Monit
//
//  Created by 맥 on 2017. 10. 9..
//  Copyright © 2017년 맥. All rights reserved.
//

import UIKit
import CoreBluetooth

class WifiSelectPwView: UIView, UITextFieldDelegate {
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblConnectAp: UILabel!
    @IBOutlet weak var lblPwTitle: UILabel!
    @IBOutlet weak var lblPwDefault: UILabel!
    @IBOutlet weak var txtPwInput: UITextField!
    @IBOutlet weak var btnPwDelete: UIButton!

    var m_parent: DeviceRegisterHubWifiSelectPasswordViewController?
    var m_pwForm: LabelFormPasswordController?
    var registerType: HUB_TYPES_REGISTER_TYPE = .new
    var m_peripheral: CBPeripheral?
    
    func setInfo() {
        setUI()
    }
    
    func setUI() {
        txtPwInput.delegate = self
        
        if (m_pwForm == nil) {
            m_pwForm = LabelFormPasswordController(txtInput: txtPwInput, btnEncrypt: btnPwDelete, minLength: 1, maxLength: 50, imgCheck: nil)
            m_pwForm!.setDefaultText(lblDefault: lblPwDefault, defaultText: "connection_hub_hint_input_ap_password".localized)
            
        }
        
        lblTitle.text = "connection_hub_select_ap_title".localized
        if let _info = m_parent!.connectInfo {
            lblConnectAp.text = "\("connection_hub_selected_ap_name".localized) \(_info.m_apName)"
        } else {
            Debug.print("[ERROR] connectInfo is null", event: .error)
        }

        lblPwTitle.text = "connection_hub_ap_password".localized
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        endEditing(true)
        self.txtPwInput.resignFirstResponder()
        return true
    }
    
    func hideKeyboard() {
        endEditing(true)
    }

    @IBAction func editingChange(_ sender: UITextField) {
        m_pwForm?.editing(isTrim: false)
    }
    
    @IBAction func onClick_encrypt_pw(_ sender: UIButton) {
        m_pwForm?.onClick_encrypt()
    }
}
