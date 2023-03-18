//
//  DeviceRegisterHubWifiSelectViewController.swift
//  Monit
//
//  Created by 맥 on 2017. 10. 9..
//  Copyright © 2017년 맥. All rights reserved.
//

import UIKit
import CoreBluetooth

class LampWifiConnectDetailInfo {
    var m_lampDid: Int = 0

    init(lampDid: Int) {
        self.m_lampDid = lampDid
    }
}

class DeviceRegisterLampWifiSelectViewController: BaseViewController {
    @IBOutlet weak var lblNaviTitle: UILabel!
    @IBOutlet weak var viewStepNew: UIView!
    @IBOutlet weak var viewStepPackage: UIView!
    @IBOutlet weak var lblContentTitle: UIButton!
    @IBOutlet weak var lblContentSummary: UILabel!
    @IBOutlet weak var lblContentSummaryEtc: UILabel!
    
    @IBOutlet weak var viewList: UIView!
    
    override var screenType: SCREEN_TYPE { get { return .HUB_REGISTER_SELECT_WIFI } }
    var m_detailInfo: LampWifiConnectDetailInfo?
    var m_popup: LampWifiSelectView?
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
        
        if (!checkConnectBle()) {
            return
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setInfo(info: LampWifiConnectDetailInfo?) {
        self.m_detailInfo = info
    }
    
    func setUI() {
        if (m_popup == nil) {
            m_popup = .fromNib()
            m_popup!.frame = viewList.bounds
            m_popup!.registerType = registerType
            m_popup!.m_peripheral = m_peripheral
            m_popup!.setInfo(info: m_detailInfo!)
            viewList.addSubview(m_popup!)
        }

        lblNaviTitle.text = UIManager.instance.hubNaviTitle(type: registerType)
        lblContentTitle.setTitleWithOutAnimation(title: "connection_hub_scan_network_list".localized + " ")
        if (Config.channel != .kc ) {
            lblContentTitle.setImage(UIImage(named: ""), for: .normal)
        }
        lblContentSummary.text = "connection_lamp_select_ap_detail".localized
        lblContentSummaryEtc.text = "connection_lamp_select_ap_detail_etc".localized
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
    }
}
