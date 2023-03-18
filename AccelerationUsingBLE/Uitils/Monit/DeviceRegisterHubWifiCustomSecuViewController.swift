//
//  DeviceRegisterHubWifiCustomSecuViewController.swift
//  Monit
//
//  Created by 맥 on 2017. 10. 9..
//  Copyright © 2017년 맥. All rights reserved.
//

import UIKit
import CoreBluetooth

class DeviceRegisterHubWifiCustomSecuViewController: BaseViewController {
    @IBOutlet weak var lblNaviTitle: UILabel!
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var viewStepNew: UIView!
    @IBOutlet weak var viewStepPackage: UIView!
    
    @IBOutlet weak var viewList: UIView!
    
    override var screenType: SCREEN_TYPE { get { return .HUB_REGISTER_CUSTOM_SECURE } }
    var m_detailInfo: WifiConnectDetailInfo?
    var m_child: WifiCustomSecuView?
    var registerType: HUB_TYPES_REGISTER_TYPE = .new
    var m_peripheral: CBPeripheral?
    
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
    
    var connectInfo: HubConnectionController? {
        get {
            if let _info = DataManager.instance.m_userInfo.connectSensor.getSensorByDeviceId(deviceId: m_detailInfo!.m_sensorDid) {
                return _info.controller!.m_hubConnectionController
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
        m_child = .fromNib()
        m_child!.frame = viewList.bounds
        m_child!.setInfo(info: m_detailInfo!)
        viewList.addSubview(m_child!)

        if (isSensorDisconnect) {
            _ = PopupManager.instance.onlyContents(contentsKey: "dialog_contents_failed_hub_connection_empty_sensor", confirmType: .ok, okHandler: { () -> () in
                _ = UIManager.instance.sceneMove(scene: .deviceRegisterNavi, animation: .coverVertical, isAnimation: false)
            })
        }
        
        lblNaviTitle.text = UIManager.instance.hubNaviTitle(type: registerType)
        btnNext.setTitle("btn_done".localized.uppercased(), for: .normal)
    }
    
    @IBAction func onClick_back(_ sender: UIButton) {
        UIManager.instance.sceneMoveNaviPop()
    }
    
    @IBAction func onClick_done(_ sender: UIButton) {
        if let _child = m_child {
            if let _info = connectInfo {
                if let _selectValue = _child.m_selectValue {
                    _info.m_apSecurityType = _selectValue.rawValue
                } else {
                    _info.m_apSecurityType = WIFI_SECURITY_TYPE.NONE.rawValue
                }
            }
        }
        UIManager.instance.sceneMoveNaviPop()
    }
}
