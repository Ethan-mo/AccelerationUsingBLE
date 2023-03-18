//
//  DeviceRegisterHubWifiViewController.swift
//  Monit
//
//  Created by 맥 on 2017. 10. 9..
//  Copyright © 2017년 맥. All rights reserved.
//

import UIKit
import CoreBluetooth

class DeviceRegisterHubWifiViewController: BaseViewController {
    @IBOutlet weak var lblNaviTitle: UILabel!
    @IBOutlet weak var viewStepNew: UIView!
    @IBOutlet weak var viewStepPackage: UIView!
    @IBOutlet weak var lblContentTitle: UIButton!
    @IBOutlet weak var lblContentSummary: UILabel!
    
    @IBOutlet weak var btnConnect: UIButton!
    
    override var screenType: SCREEN_TYPE { get { return .HUB_REGISTER_SELECT_WIFI } }
    var m_detailInfo: WifiConnectDetailInfo?
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
    
    func setInfo(info: WifiConnectDetailInfo?) {
        self.m_detailInfo = info
    }
    
    func setUI() {
        btnConnect.layer.borderColor = COLOR_TYPE.mint.color.cgColor
        btnConnect.layer.borderWidth = 1
        
        if (isSensorDisconnect) {
            _ = PopupManager.instance.onlyContents(contentsKey: "dialog_contents_failed_hub_connection_empty_sensor", confirmType: .ok, okHandler: { () -> () in
                _ = UIManager.instance.sceneMove(scene: .deviceRegisterNavi, animation: .coverVertical, isAnimation: false)
            })
        }
        
        lblNaviTitle.text = UIManager.instance.hubNaviTitle(type: registerType)
        lblContentTitle.setTitleWithOutAnimation(title: "connection_hub_select_ap_title".localized + " ")
        lblContentSummary.text = "connection_hub_scan_ap_detail".localized
        btnConnect.setTitle("connection_scan_ap".localized.uppercased(), for: .normal)
    }
    
    @IBAction func onClick_back(_ sender: UIButton) {
        _ = UIManager.instance.sceneMove(scene: .initView, animation: .coverVertical, isAnimation: false)
    }
    
    @IBAction func onClick_connect(_ sender: UIButton) {
        if let view = UIManager.instance.sceneMoveNaviPush(scene: .deviceRegisterHubWifiSelect, isAniamtion: false) as? DeviceRegisterHubWifiSelectViewController {
            view.registerType = registerType
            view.m_peripheral = m_peripheral
            view.setInfo(info: m_detailInfo)
        }
    }
}
