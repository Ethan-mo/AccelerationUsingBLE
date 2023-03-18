//
//  DeviceRegisterSensorFinishViewController.swift
//  Monit
//
//  Created by 맥 on 2017. 9. 14..
//  Copyright © 2017년 맥. All rights reserved.
//

import UIKit
import SwiftyJSON
import CoreBluetooth

class DeviceRegisterSensorFinishViewController: BaseViewController {
    @IBOutlet weak var lblNaviTitle: UILabel!
    @IBOutlet weak var btnNaviNext: UIButton!
    @IBOutlet weak var lblContentTitle: UILabel!
    @IBOutlet weak var lblContentSummary: UILabel!
    @IBOutlet weak var imgAttachAnimation: UIImageView!
    
    @IBOutlet weak var btnOtherConnect: UIButton!

    override var screenType: SCREEN_TYPE { get { return .SENSOR_REGISTER_SUCCESS } }
    
    var m_peripheral: CBPeripheral?
    var m_bleInfo: BleInfo? {
        get {
            return DataManager.instance.m_userInfo.connectSensor.getSensorByPeripheral(peripheral: m_peripheral)
        }
    }
    
    override func viewDidLoad() {
        m_category = .registerSensor
        isUpdateView = false
        super.viewDidLoad()
        Debug.print("[UI][\(self.classNameToString()).viewDidLoad()]")
        setUI()
    }
    
    func setUI() {
        lblNaviTitle.text = "title_connection".localized
        btnNaviNext.setTitle("btn_done".localized.uppercased(), for: .normal)
        lblContentTitle.text = "connection_monit_sensor_connected_title".localized
        lblContentSummary.text = "connection_monit_sensor_connected_detail".localized
        btnOtherConnect.setTitle("connection_connect_other_device".localized.uppercased(), for: .normal)
        
        UI_Utility.textUnderline(btnOtherConnect.titleLabel)
        
        animate()
    }
    
    func animate()
    {
        var images = [UIImage]()
        let _animSeq: [Int] = [1, 1,
                               2, 2,
                               3, 3, 3]
        for item in _animSeq {
            images.append(UIImage(named: "imgSensorAttachTutorial\(item.description)")!)
        }

        imgAttachAnimation.animationImages = images
        imgAttachAnimation.animationDuration = 4.5
        imgAttachAnimation.animationRepeatCount = 0
        imgAttachAnimation.startAnimating()
    }

    @IBAction func onClick_otherConnect(_ sender: UIButton) {
        UIManager.instance.setMoveNextScene(finishScenePush: .deviceRegister, moveScene: .initView)
    }
    
    @IBAction func onClick_Complete(_ sender: UIButton) {
        let _lastVer = DataManager.instance.m_configData.m_latestSensorVersion
        // goto firmware update scene OR device list scene
        if (Utility.isUpdateVersion(latestVersion: _lastVer, currentVersion: m_bleInfo?.m_firmware ?? "9.9.9")) {
            _ = PopupManager.instance.onlyContents(contentsKey: "contents_need_firmware_update", confirmType: .noYes,
                                                   okHandler: { () -> () in
                                                    UIManager.instance.m_moveSceneDeviceType = DEVICE_TYPE.Sensor.rawValue
                                                    UIManager.instance.m_moveSceneDeviceID = self.m_bleInfo?.m_did ?? 0
                                                    UIManager.instance.setMoveNextScene(finishScenePush: .deviceSetupSensorFirmware, moveScene: .initView)
                                                    UIManager.instance.m_deviceNeedHubPopup = true
            }, cancleHandler: { () -> () in
                self.confirmHub()
            })
        // goto Connect scene Hub Or device list scene
        } else {
            confirmHub()
        }
    }
    
    func confirmHub() {
        _ = PopupManager.instance.onlyContents(contentsKey: "dialog_contents_ask_for_connectint_hub", confirmType: .ok,
                                               okHandler: { () -> () in
                                                UIManager.instance.setMoveNextScene(finishScenePush: .deviceRegisterHub, moveScene: .initView)
        })
    }
}
