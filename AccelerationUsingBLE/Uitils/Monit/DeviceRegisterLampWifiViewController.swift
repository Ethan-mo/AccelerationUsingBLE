//
//  DeviceRegisterHubWifiViewController.swift
//  Monit
//
//  Created by 맥 on 2017. 10. 9..
//  Copyright © 2017년 맥. All rights reserved.
//

import UIKit
import CoreBluetooth

class DeviceRegisterLampWifiViewController: BaseViewController {
    @IBOutlet weak var lblNaviTitle: UILabel!
    @IBOutlet weak var viewStepNew: UIView!
    @IBOutlet weak var viewStepPackage: UIView!
    @IBOutlet weak var lblContentTitle: UIButton!
    @IBOutlet weak var lblContentSummary: UILabel!
    
    @IBOutlet weak var btnConnect: UIButton!

    var m_detailInfo: LampWifiConnectDetailInfo?
    var registerType: HUB_TYPES_REGISTER_TYPE = .new
    var m_peripheral: CBPeripheral?
    
    var bleInfo: BleLampInfo? {
        get {
            return DataManager.instance.m_userInfo.connectLamp.getLampByDeviceId(deviceId: m_detailInfo?.m_lampDid ?? 0)
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
    }
    
    func setInfo(info: LampWifiConnectDetailInfo?) {
        self.m_detailInfo = info
    }
    
    func setUI() {
        btnConnect.layer.borderColor = COLOR_TYPE.mint.color.cgColor
        btnConnect.layer.borderWidth = 1

        lblNaviTitle.text = UIManager.instance.hubNaviTitle(type: registerType)
        lblContentTitle.setTitleWithOutAnimation(title: "connection_hub_select_ap_title".localized + " ")
        lblContentSummary.text = "connection_lamp_scan_ap_detail".localized
        btnConnect.setTitle("connection_scan_ap".localized.uppercased(), for: .normal)
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
        _ = UIManager.instance.sceneMove(scene: .initView, animation: .coverVertical, isAnimation: false)
        DataManager.instance.m_dataController.deviceStatus.deleteLamp(did: self.bleInfo?.m_did ?? 0, adv: self.bleInfo?.m_adv ?? "")
    }
    
    @IBAction func onClick_connect(_ sender: UIButton) {
        if (!checkConnectBle()) {
            return
        }
        
        if let view = UIManager.instance.sceneMoveNaviPush(scene: .deviceRegisterLampWifiSelect, isAniamtion: false) as? DeviceRegisterLampWifiSelectViewController {
            view.registerType = registerType
            view.m_peripheral = m_peripheral
            view.setInfo(info: m_detailInfo)
        }
    }
    
}
