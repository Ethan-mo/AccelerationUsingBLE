//
//  DeviceRegisterSensorViewController.swift
//  Monit
//
//  Created by 맥 on 2017. 9. 13..
//  Copyright © 2017년 맥. All rights reserved.
//

import UIKit
import CoreBluetooth

class DeviceRegisterSensorViewController: BaseViewController {
    @IBOutlet weak var lblNaviTitle: UILabel!
    @IBOutlet weak var lblTitle: UIButton!
    @IBOutlet weak var lblSummary: UITextView!
    
    @IBOutlet weak var btnStartConnection: UIButton!
    @IBOutlet weak var imgHowto: UIImageView!
    
    override var screenType: SCREEN_TYPE { get { return .SENSOR_REGISTER_READY } }
    
    override func viewDidLoad() {
        isUpdateView = false
        super.viewDidLoad()
        Debug.print("[UI][\(self.classNameToString()).viewDidLoad()]")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        m_category = .registerSensor
        super.viewWillAppear(animated)
        availableBluetooth()
        setUI()
    }
    
    override func reloadInfo() {
        super.reloadInfo()
        Debug.print("[UI][\(self.classNameToString()).reloadInfo()]")
        availableBluetooth()
    }
    
    func setUI() {
        btnStartConnection.layer.borderColor = COLOR_TYPE.mint.color.cgColor
        btnStartConnection.layer.borderWidth = 1
        
        if (Config.channel == .kc) {
            animateKc()
        } else {
            animate()
        }
        
        lblNaviTitle.text = "title_connection".localized
        lblTitle.setTitleWithOutAnimation(title: "connection_monit_sensor_ready_title".localized + " ")
        
        lblSummary.text = "connection_monit_sensor_ready_detail_step1".localized
        btnStartConnection.setTitle("btn_next".localized.uppercased(), for: .normal)
    }
    
    func availableBluetooth() {
        if (!BleConnectionManager.instance.isStartManager) {
            _ = PopupManager.instance.onlyContents(contentsKey: "toast_need_to_enable_bluetooth_with_err", confirmType: .ok, okHandler: { () -> () in
                _ = UIManager.instance.sceneMove(scene: .deviceRegisterNavi, animation: .coverVertical, isAnimation: false)
            }, existKey: "need_to_enable_bluetooth")
        }
    }
    
    func animate()
    {
        var images = [UIImage]()
        images.append(UIImage(named: "imgSensorTutorial1_1")!)
        images.append(UIImage(named: "imgSensorTutorial1_2")!)
        images.append(UIImage(named: "imgSensorTutorial1_3")!)
        
        imgHowto.animationImages = images
        imgHowto.animationDuration = 2
        imgHowto.animationRepeatCount = 0
        imgHowto.startAnimating()
    }
    
    func animateKc()
    {
        var images = [UIImage]()
        images.append(UIImage(named: "imgKcSensorTutorial1_1")!)
        images.append(UIImage(named: "imgKcSensorTutorial1_2")!)
        images.append(UIImage(named: "imgKcSensorTutorial1_3")!)
        
        imgHowto.animationImages = images
        imgHowto.animationDuration = 2
        imgHowto.animationRepeatCount = 0
        imgHowto.startAnimating()
    }

    @IBAction func onClick_back(_ sender: UIButton) {
        UIManager.instance.sceneMoveNaviPop()
    }
    
    @IBAction func onClick_StartConnection(_ sender: UIButton) {
        _ = UIManager.instance.sceneMoveNaviPush(scene: .deviceRegisterSensorLight)
    }
    
    @IBAction func onClick_help(_ sender: Any) {
        let _param = UIManager.instance.getBoardParam(board: BOARD_TYPE.connect_device_sensor, boardId: 18)
        let _scene = UIManager.instance.sceneMoveNaviPush(scene: .customWebView, isAniamtion: false) as! CustomWebViewController
        _scene.setInit(url: "\(Config.BOARD_DEFAULT_URL)\(_param)", naviTitle: "help".localized)
    }
}
