//
//  DeviceRegisterHubWifiCustomViewController.swift
//  Monit
//
//  Created by 맥 on 2017. 10. 9..
//  Copyright © 2017년 맥. All rights reserved.
//

import UIKit
import CoreBluetooth

class DeviceRegisterLampWifiCustomViewController: BaseViewController {
    @IBOutlet weak var lblNaviTitle: UILabel!
    @IBOutlet weak var btnNaviNext: UIButton!
    @IBOutlet weak var viewStepNew: UIView!
    @IBOutlet weak var viewStepPackage: UIView!
    
    @IBOutlet weak var viewList: UIView!
    
    override var screenType: SCREEN_TYPE { get { return .HUB_REGISTER_CUSTOM } }
    var m_detailInfo: LampWifiConnectDetailInfo?
    var m_child: LampWifiCustomView?
    var registerType: HUB_TYPES_REGISTER_TYPE = .new
    var m_peripheral: CBPeripheral?

    var bleInfo: BleLampInfo? {
        get {
            return DataManager.instance.m_userInfo.connectLamp.getLampByDeviceId(deviceId: m_detailInfo!.m_lampDid)
        }
    }
    
    var connectInfo: LampConnectionController? {
        get {
            if let _info = DataManager.instance.m_userInfo.connectLamp.getLampByDeviceId(deviceId: m_detailInfo!.m_lampDid) {
                return _info.controller!.m_lampConnectionController
            }
            return nil
        }
    }
    
    override func viewDidLoad() {
        isUpdateView = false
        super.viewDidLoad()
        Debug.print("[UI][\(self.classNameToString()).viewDidLoad()]")
        
        viewStepNew.isHidden = true
        viewStepPackage.isHidden = true
        if (registerType == .package) {
            viewStepPackage.isHidden = false
        } else {
            viewStepNew.isHidden = false
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUI()
    }
    
    override func reloadInfo() {
        super.reloadInfo()
        Debug.print("[UI][\(self.classNameToString()).reloadInfo()]")
        
        if (!checkConnectBle()) {
            return
        }
    }
    
    func setInfo(info: LampWifiConnectDetailInfo) {
        self.m_detailInfo = info
    }
    
    func setUI() {
        if (m_child == nil) {
            m_child = .fromNib()
            m_child!.frame = viewList.bounds
        }
        m_child!.registerType = registerType
        m_child!.m_peripheral = m_peripheral
        m_child!.setInfo(info: m_detailInfo!)
        viewList.addSubview(m_child!)
        
        lblNaviTitle.text = UIManager.instance.hubNaviTitle(type: registerType)
        btnNaviNext.setTitle("btn_connect".localized.uppercased(), for: .normal)
    }
    
    func checkConnectBle() -> Bool {
        if (bleInfo == nil) {
            _ = PopupManager.instance.onlyContents(contentsKey: "device_lamp_disconnected_title", confirmType: .ok, okHandler: { () -> () in
                _ = UIManager.instance.sceneMove(scene: .initView, animation: .coverVertical, isAnimation: false)
                DataManager.instance.m_dataController.deviceStatus.deleteLamp(did: self.bleInfo?.m_did ?? 0, adv: self.bleInfo?.m_adv ?? "")
            }, existKey: "need_to_enable_lampbluetooth")

            return false
        }
        
        return true
    }
    
    @IBAction func onClick_back(_ sender: UIButton) {
        UIManager.instance.sceneMoveNaviPop()
    }
    
    @IBAction func onClick_next(_ sender: UIButton) {
        if (!checkConnectBle()) {
            return
        }
        
        if (!(m_child!.m_nameForm!.m_isVaild)) {
            _ = PopupManager.instance.onlyContents(contentsKey: "connection_hub_hint_input_network_name", confirmType: .ok)
            return
        }

        if let _info = connectInfo {
            let _type = WIFI_SECURITY_TYPE(rawValue: _info.m_apSecurityType)
            if (_type! != .NONE) {
                if (!(m_child!.m_pwForm!.m_isVaild)) {
                    _ = PopupManager.instance.onlyContents(contentsKey: "connection_hub_hint_input_ap_password", confirmType: .ok)
                    return
                }
            }
        }
        
        if let _info = connectInfo {
            UIManager.instance.startLampConnection(registerType: registerType, bleInfo: bleInfo, connectInfo: connectInfo, apName: m_child!.txtInput.text!, apPw: m_child!.txtPwInput.text!, apSecurity: _info.m_apSecurityType, index: 99, peripheral: m_peripheral)
        } else {
            Debug.print("[ERROR] security is null", event: .error)
        }
    }
}
