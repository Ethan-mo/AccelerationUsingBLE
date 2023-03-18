//
//  DeviceRegisterHubWifiSelectPasswordViewController.swift
//  Monit
//
//  Created by 맥 on 2017. 10. 9..
//  Copyright © 2017년 맥. All rights reserved.
//

import UIKit
import CoreBluetooth

class DeviceRegisterHubWifiSelectPasswordViewController: BaseViewController {
    @IBOutlet weak var lblNaviTitle: UILabel!
    @IBOutlet weak var btnNaviNext: UIButton!
    @IBOutlet weak var viewStepNew: UIView!
    @IBOutlet weak var viewStepPackage: UIView!
    
    @IBOutlet weak var viewList: UIView!
    
    override var screenType: SCREEN_TYPE { get { return .HUB_REGISTER_PASSWORD } }
    var m_detailInfo: WifiConnectDetailInfo?
    var m_popup: WifiSelectPwView?
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
    
    func setInfo(info: WifiConnectDetailInfo) {
        self.m_detailInfo = info
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
    
    func setUI() {
        m_popup = .fromNib()
        m_popup!.frame = viewList.bounds
        m_popup!.m_parent = self
        m_popup!.setInfo()
        viewList.addSubview(m_popup!)
        
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
        if let _info = connectInfo {
            UIManager.instance.startConnection(registerType: registerType, bleInfo: bleInfo, connectInfo: connectInfo, apName: _info.m_apName, apPw: m_popup!.txtPwInput.text!, apSecurity: _info.m_apSecurityType, index: _info.m_apIndex, peripheral: m_peripheral)
            m_popup?.hideKeyboard()
        } else {
            Debug.print("[ERROR] connectInfo is null", event: .error)
        }
    }
}
