//
//  DeviceSetupSensorConnectingViewController.swift
//  Monit
//
//  Created by john.lee on 2018. 5. 2..
//  Copyright © 2018년 맥. All rights reserved.
//

import UIKit

class DeviceSetupSensorConnectingViewController: BaseViewController {
    @IBOutlet weak var lblNaviTitle: UILabel!
    @IBOutlet weak var lblConnectingTitle: UILabel!
    @IBOutlet weak var lblConnectingContents: UILabel!
    @IBOutlet weak var lblGuide1: UILabel!
    @IBOutlet weak var lblGuide2: UILabel!
    @IBOutlet weak var lblGuide3: UILabel!
    @IBOutlet weak var imgConnecting: UIImageView!
    
    enum BLE_CONNECT_TYPE {
        case firmware
        case normal
    }

    override var screenType: SCREEN_TYPE { get { return .SENSOR_SETUP_FIRMWARE_NEED_BLE } }
    var m_connectType: BLE_CONNECT_TYPE = .normal
    var m_detailInfo: DeviceDetailInfo?
    var m_updateTimer: Timer?
    var m_timeInterval: Double = 0.1
    var m_time: Double = 0
    var m_flow = Flow()
    var m_isForceInit: Bool = false
    
    var connectSensor: BleInfo? {
        get {
            return DataManager.instance.m_userInfo.connectSensor.getSensorByDeviceId(deviceId: m_detailInfo?.m_did ?? 0)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Debug.print("[UI][\(self.classNameToString()).viewDidLoad()]")
        setUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        m_flow.reset {
            UIManager.instance.sceneMoveNaviPop(isAnimation: false)
        }
    }
    
    func setInit(detailInfo: DeviceDetailInfo?, connectType: BLE_CONNECT_TYPE) {
        Debug.print("[SensorSetupFirmwareConnecting] setInit()")
        m_detailInfo = detailInfo
        m_connectType = connectType
    }
    
    func setUI() {
        Debug.print("[SensorSetupFirmwareConnecting] setUI()")
        lblNaviTitle.text = "title_firmware_update".localized
//        lblConnectingTitle.text = "guide_direct_connection_for_firmware_update".localized
        lblConnectingContents.text = "guide_direct_connection_description".localized
        lblGuide1.text = "guide_direct_connection_description1".localized
        lblGuide2.text = "guide_direct_connection_description2".localized
        lblGuide3.text = "guide_direct_connection_description3".localized
        
        animate()
        
        self.m_updateTimer?.invalidate()
        self.m_updateTimer = Timer.scheduledTimer(timeInterval: self.m_timeInterval, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
    }
    
    @objc func update() {
        m_time += m_timeInterval
        
        if (UIManager.instance.rootCurrentView as? DeviceSetupSensorConnectingViewController == nil) {
            self.m_updateTimer?.invalidate()
        }
        
        if (connectSensor != nil) {
            self.m_updateTimer?.invalidate()
            if (m_connectType == .firmware) {
//                let _scene = UIManager.instance.sceneMoveNaviPush(scene: .deviceSetupSensorFirmware) as? DeviceSetupSensorFirmwareViewController
//                _scene?.setInit(detailInfo: m_detailInfo)
                UIManager.instance.sceneMoveNaviPop()
                _ = PopupManager.instance.onlyContents(contentsKey: "toast_sensor_is_connected_directly", confirmType: .ok)
            } else if (m_connectType == .normal) {
                UIManager.instance.sceneMoveNaviPop()
                _ = PopupManager.instance.onlyContents(contentsKey: "toast_sensor_is_connected_directly", confirmType: .ok)
            }
        }
    }
    
    func animate()
    {
        var images = [UIImage]()
        if (Config.channel == .kc) {
            images.append(UIImage(named: "imgKcHubTutorial3_1")!)
            images.append(UIImage(named: "imgKcHubTutorial3_2")!)
            images.append(UIImage(named: "imgKcHubTutorial3_3")!)
            images.append(UIImage(named: "imgKcHubTutorial3_4")!)
        } else {
            images.append(UIImage(named: "imgHubTutorial3_1")!)
            images.append(UIImage(named: "imgHubTutorial3_2")!)
            images.append(UIImage(named: "imgHubTutorial3_3")!)
            images.append(UIImage(named: "imgHubTutorial3_4")!)
        }
        
        
        imgConnecting.animationImages = images
        imgConnecting.animationDuration = 2
        imgConnecting.animationRepeatCount = 0
        imgConnecting.startAnimating()
    }
    
    @IBAction func onClick_back(_ sender: UIButton) {
        if (m_isForceInit) {
            _ = UIManager.instance.sceneMove(scene: .initView, animation: .coverVertical, isAnimation: false)
        } else {
            UIManager.instance.sceneMoveNaviPop()
        }
        
        if (m_connectType == .firmware) {
            //            _ = PopupManager.instance.onlyContents(contentsKey: "dialog_contents_failed_connection_reason_ble", confirmType: .ok)
            _ = PopupManager.instance.onlyContents(contentsKey: "toast_sensor_is_not_connected_directly", confirmType: .ok)
        } else {
            _ = PopupManager.instance.onlyContents(contentsKey: "toast_sensor_is_not_connected_directly", confirmType: .ok)
        }
    }
}
