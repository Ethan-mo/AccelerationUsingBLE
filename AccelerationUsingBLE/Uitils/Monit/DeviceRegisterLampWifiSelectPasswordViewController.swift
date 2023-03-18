//
//  DeviceRegisterHubWifiSelectPasswordViewController.swift
//  Monit
//
//  Created by 맥 on 2017. 10. 9..
//  Copyright © 2017년 맥. All rights reserved.
//

import UIKit
import CoreBluetooth

class DeviceRegisterLampWifiSelectPasswordViewController: BaseViewController {
    @IBOutlet weak var lblNaviTitle: UILabel!
    @IBOutlet weak var btnNaviNext: UIButton!
    @IBOutlet weak var viewStepNew: UIView!
    @IBOutlet weak var viewStepPackage: UIView!
    
    @IBOutlet weak var viewList: UIView!
    
    override var screenType: SCREEN_TYPE { get { return .HUB_REGISTER_PASSWORD } }
    var m_detailInfo: LampWifiConnectDetailInfo?
    var m_popup: LampWifiSelectPwView?
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
    
    func setInfo(info: LampWifiConnectDetailInfo) {
        self.m_detailInfo = info
    }

    override func reloadInfo() {
        super.reloadInfo()
        Debug.print("[UI][\(self.classNameToString()).reloadInfo()]")
        
        if (!checkConnectBle()) {
            return
        }
    }
    
    func setUI() {
        m_popup = .fromNib()
        m_popup!.frame = viewList.bounds
        m_popup!.m_parent = self
        m_popup!.setInfo()
        viewList.addSubview(m_popup!)
        
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
        
        if let _info = connectInfo {
            UIManager.instance.startLampConnection(registerType: registerType, bleInfo: bleInfo, connectInfo: connectInfo, apName: _info.m_apName, apPw: m_popup!.txtPwInput.text!, apSecurity: _info.m_apSecurityType, index: _info.m_apIndex, peripheral: m_peripheral)
            m_popup?.hideKeyboard()
        } else {
            Debug.print("[ERROR] connectInfo is null", event: .error)
        }
    }
}
