//
//  DeviceRegisterHubWifiCustomViewController.swift
//  Monit
//
//  Created by 맥 on 2017. 10. 9..
//  Copyright © 2017년 맥. All rights reserved.
//

import UIKit
import CoreBluetooth

class DeviceRegisterHubWifiCustomViewController: BaseViewController {
    @IBOutlet weak var lblNaviTitle: UILabel!
    @IBOutlet weak var btnNaviNext: UIButton!
    @IBOutlet weak var viewStepNew: UIView!
    @IBOutlet weak var viewStepPackage: UIView!
    
    @IBOutlet weak var viewList: UIView!
    
    override var screenType: SCREEN_TYPE { get { return .HUB_REGISTER_CUSTOM } }
    var m_detailInfo: WifiConnectDetailInfo?
    var m_child: WifiCustomView?
    var registerType: HUB_TYPES_REGISTER_TYPE = .new
    var m_peripheral: CBPeripheral?

    var bleInfo: BleInfo? {
        get {
            return DataManager.instance.m_userInfo.connectSensor.getSensorByDeviceId(deviceId: m_detailInfo!.m_sensorDid)
        }
    }
    
    var connectInfo: HubConnectionController? {
        get {
            if let _info = DataManager.instance.m_userInfo.connectSensor.getSensorByDeviceId(deviceId: m_detailInfo!.m_sensorDid) {
                return _info.controller!.m_hubConnectionController
            }
            return nil
        }
    }
    
    var isSensorDisconnect: Bool {
        get {
            if let _info = DataManager.instance.m_userInfo.connectSensor.getSensorByDeviceId(deviceId: m_detailInfo!.m_sensorDid) {
                if (!_info.isHubConnect) {
                    return true
                }
            } else {
                return true
            }
            return false
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
        if (isSensorDisconnect) {
            _ = PopupManager.instance.onlyContents(contentsKey: "dialog_contents_failed_hub_connection_empty_sensor", confirmType: .ok, okHandler: { () -> () in
                _ = UIManager.instance.sceneMove(scene: .deviceRegisterNavi, animation: .coverVertical, isAnimation: false)
            })
        }
    }
    
    func setInfo(info: WifiConnectDetailInfo) {
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
        
        if (isSensorDisconnect) {
            _ = PopupManager.instance.onlyContents(contentsKey: "dialog_contents_failed_hub_connection_empty_sensor", confirmType: .ok, okHandler: { () -> () in
                _ = UIManager.instance.sceneMove(scene: .deviceRegisterNavi, animation: .coverVertical, isAnimation: false)
            })
        }
        
        lblNaviTitle.text = UIManager.instance.hubNaviTitle(type: registerType)
        btnNaviNext.setTitle("btn_connect".localized.uppercased(), for: .normal)
    }
    
    @IBAction func onClick_back(_ sender: UIButton) {
        UIManager.instance.sceneMoveNaviPop()
    }
    
    @IBAction func onClick_next(_ sender: UIButton) {
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
            UIManager.instance.startConnection(registerType: registerType, bleInfo: bleInfo, connectInfo: connectInfo, apName: m_child!.txtInput.text!, apPw: m_child!.txtPwInput.text!, apSecurity: _info.m_apSecurityType, index: 99, peripheral: m_peripheral)
        } else {
            Debug.print("[ERROR] security is null", event: .error)
        }
    }
}
