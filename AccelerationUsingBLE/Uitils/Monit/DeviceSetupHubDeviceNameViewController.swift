//
//  DeviceSetupHubDeviceNameViewController.swift
//  Monit
//
//  Created by 맥 on 2017. 10. 2..
//  Copyright © 2017년 맥. All rights reserved.
//

import UIKit
import SwiftyJSON

class DeviceSetupHubDeviceNameViewController: BaseViewController {
    @IBOutlet weak var lblNaviTitle: UILabel!
    @IBOutlet weak var btnNaviNext: UIButton!
    @IBOutlet weak var lblDeviceNameTitle: UILabel!
    
    @IBOutlet weak var lblDefault: UILabel!
    @IBOutlet weak var txtInput: UITextField!
    @IBOutlet weak var btnDelete: UIButton!
    
    override var screenType: SCREEN_TYPE { get { return .HUB_SETUP_NAME } }
    var m_detailInfo: DeviceDetailInfo?
    var m_nameForm: LabelFormController?
    
    var hubStatusInfo: HubStatusInfo? {
        get {
            return DataManager.instance.m_userInfo.deviceStatus.m_hubStatus.getInfoByDeviceId(did: m_detailInfo!.m_did)
        }
    }
    
    var userInfo: UserInfoDevice? {
        get {
            return DataManager.instance.m_dataController.device.getUserInfoByDid(did: m_detailInfo!.m_did, type: DEVICE_TYPE.Hub.rawValue)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Debug.print("[UI][\(self.classNameToString()).viewDidLoad()]")
        txtInput.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUI()
    }

    func setUI() {
        m_nameForm = LabelFormController(txtInput: txtInput, btnDelete: btnDelete, minLength: 1, maxLength: 24, maxByte: -1, imgCheck: nil)
        m_nameForm?.setDefaultText(lblDefault: lblDefault, defaultText: "device_warning_dialog_hubname".localized)
        
        txtInput.text = hubStatusInfo!.m_name
        m_nameForm?.editing(isTrim: false)
        
        lblNaviTitle.text = "setting_room_name".localized
        btnNaviNext.setTitle("btn_save".localized.uppercased(), for: .normal)
        lblDeviceNameTitle.text = "setting_room_name".localized
    }
    
    @IBAction func onClick_save(_ sender: UIButton) {
        if (m_nameForm!.m_isVaild) {
            let send = Send_SetDeviceName()
            send.aid = DataManager.instance.m_userInfo.account_id
            send.token = DataManager.instance.m_userInfo.token
            send.type = DEVICE_TYPE.Hub.rawValue
            send.did = m_detailInfo!.m_did
            send.enc = userInfo!.enc
            send.name = Utility.urlEncode(txtInput.text!)
            NetworkManager.instance.Request(send) { (json) -> () in
                self.receiveSetDeviceName(json)
            }
        } else {
            _ = PopupManager.instance.onlyContents(contentsKey: "device_warning_dialog_hubname", confirmType: .ok)
        }
    }
    
    @IBAction func editing_name(_ sender: UITextField) {
        m_nameForm?.editing(isTrim: false, isRemoveSpecialChar: true)
    }
    
    @IBAction func onClick_back(_ sender: UIButton) {
        UIManager.instance.sceneMoveNaviPop()
    }
    
    func receiveSetDeviceName(_ json: JSON) {
        let receive = Receive_SetDeviceName(json)
        switch receive.ecd {
        case .success:
            hubStatusInfo!.m_name = txtInput.text!
            UIManager.instance.sceneMoveNaviPop()
        default:
            Debug.print("[ERROR] Receive_SetDeviceName invaild errcod", event: .error)
            let _errStr = String(format: "dialog_contents_err_communication_with_server".localized, APP_ERR_COD.Send_SetDeviceName.rawValue)
            _ = PopupManager.instance.onlyContentsCustom(contents: _errStr, confirmType: .ok, okHandler: { () -> () in
            })
        }
    }
    
    @IBAction func onClick_delete(_ sender: UIButton) {
        m_nameForm?.onClick_delete()
    }
}
