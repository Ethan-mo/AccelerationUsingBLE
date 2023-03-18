//
//  DeviceRegisterHubWifiSelectViewController.swift
//  Monit
//
//  Created by 맥 on 2017. 10. 9..
//  Copyright © 2017년 맥. All rights reserved.
//

import UIKit
import CoreBluetooth

class WifiConnectDetailInfo {
    var m_sensorDid: Int = 0
    var m_hubDid: Int = 0
    
    init(sensorDid: Int, hubDid: Int) {
        self.m_sensorDid = sensorDid
        self.m_hubDid = hubDid
    }
}

class DeviceRegisterHubWifiSelectViewController: BaseViewController {
    @IBOutlet weak var lblNaviTitle: UILabel!
    @IBOutlet weak var viewStepNew: UIView!
    @IBOutlet weak var viewStepPackage: UIView!
    @IBOutlet weak var lblContentTitle: UIButton!
    @IBOutlet weak var lblContentSummary: UILabel!
    @IBOutlet weak var lblContentSummaryEtc: UILabel!
    
    @IBOutlet weak var viewList: UIView!
    
    override var screenType: SCREEN_TYPE { get { return .HUB_REGISTER_SELECT_WIFI } }
    var m_detailInfo: WifiConnectDetailInfo?
    var m_popup: WifiSelectView?
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setInfo(info: WifiConnectDetailInfo?) {
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

        if (isSensorDisconnect) {
            _ = PopupManager.instance.onlyContents(contentsKey: "dialog_contents_failed_hub_connection_empty_sensor", confirmType: .ok, okHandler: { () -> () in
                _ = UIManager.instance.sceneMove(scene: .deviceRegisterNavi, animation: .coverVertical, isAnimation: false)
            })
        }
        
        lblNaviTitle.text = UIManager.instance.hubNaviTitle(type: registerType)
        lblContentTitle.setTitleWithOutAnimation(title: "connection_hub_scan_network_list".localized + " ")
//        if (Config.channel != .kc ) {
//            lblContentTitle.setImage(UIImage(named: ""), for: .normal)
//        }
        lblContentSummary.text = "connection_hub_select_ap_detail".localized
        lblContentSummaryEtc.text = "connection_hub_select_ap_detail_etc".localized
    }

    @IBAction func onClick_back(_ sender: UIButton) {
        _ = UIManager.instance.sceneMove(scene: .initView, animation: .coverVertical, isAnimation: false)
    }
    
    @IBAction func onClick_help(_ sender: Any) {
        let _param = UIManager.instance.getBoardParam(board: BOARD_TYPE.connect_device_hub, boardId: 20)
        let _scene = UIManager.instance.sceneMoveNaviPush(scene: .customWebView, isAniamtion: false) as! CustomWebViewController
        _scene.setInit(url: "\(Config.BOARD_DEFAULT_URL)\(_param)", naviTitle: "help".localized)
    }
}
