//
//  DeviceRegisterHubViewController.swift
//  Monit
//
//  Created by 맥 on 2017. 10. 9..
//  Copyright © 2017년 맥. All rights reserved.
//

import UIKit

class DeviceRegisterPackageHubOnViewController: BaseViewController {
    @IBOutlet weak var lblNaviTItle: UILabel!
    @IBOutlet weak var lblContentTitle: UIButton!
    @IBOutlet weak var lblContentSummary: VerticalAlignLabel!
    
    @IBOutlet weak var btnConnect: UIButton!
    @IBOutlet weak var imgHowto: UIImageView!
    
    override var screenType: SCREEN_TYPE { get { return .HUB_REGISTER_READY } }
    var registerType: HUB_TYPES_REGISTER_TYPE = .new
    
    override func viewDidLoad() {
        isUpdateView = false
        super.viewDidLoad()
        Debug.print("[UI][\(self.classNameToString()).viewDidLoad()]")
    }
    
    override func viewWillAppear(_ animated: Bool) {
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
        btnConnect.layer.borderColor = COLOR_TYPE.mint.color.cgColor
        btnConnect.layer.borderWidth = 1
        
        animate()
        
        lblNaviTItle.text = UIManager.instance.hubNaviTitle(type: registerType)
        lblContentTitle.setTitleWithOutAnimation(title: "connection_package_ready_title".localized + " ")
        lblContentSummary.text = "\("connection_hub_ready_detail_step1".localized)\n\("connection_hub_ready_detail_step2".localized)"
        btnConnect.setTitle("btn_next".localized.uppercased(), for: .normal)
    }
    
    func availableBluetooth() {
        if (!BleConnectionManager.instance.isStartManager) {
            _ = PopupManager.instance.onlyContents(contentsKey: "toast_need_to_enable_bluetooth_with_err", confirmType: .ok, okHandler: { () -> () in
                _ = UIManager.instance.sceneMove(scene: .initView, animation: .coverVertical, isAnimation: false)
            }, existKey: "need_to_enable_bluetooth")
        }
    }
    
    func animate()
    {
        var images = [UIImage]()
        images.append(UIImage(named: "imgKcHubTutorial1_1")!)
        images.append(UIImage(named: "imgKcHubTutorial1_1")!)
        images.append(UIImage(named: "imgKcHubTutorial1_2")!)
        images.append(UIImage(named: "imgKcHubTutorial1_2")!)
        images.append(UIImage(named: "imgKcHubTutorial2_1")!)
        images.append(UIImage(named: "imgKcHubTutorial2_2")!)
        images.append(UIImage(named: "imgKcHubTutorial2_1")!)
        images.append(UIImage(named: "imgKcHubTutorial2_2")!)
        
        imgHowto.animationImages = images
        imgHowto.animationDuration = 5
        imgHowto.animationRepeatCount = 0
        imgHowto.startAnimating()
    }
    
    @IBAction func onClick_back(_ sender: UIButton) {
        UIManager.instance.sceneMoveNaviPop()
    }
    
    @IBAction func onClick_next(_ sender: UIButton) {
//        if let _vc =
//
//            as? DeviceRegisterHubLightViewController {
//            _vc.registerType = registerType
//        }
        _ = UIManager.instance.sceneMoveNaviPush(scene: .deviceRegisterPackageSensorIntoHub)
    }
    
    @IBAction func onClick_help(_ sender: Any) {
        let _param = UIManager.instance.getBoardParamSensorIntoHub()
        let _scene = UIManager.instance.sceneMoveNaviPush(scene: .customWebView, isAniamtion: false) as! CustomWebViewController
        _scene.setInit(url: "\(Config.BOARD_DEFAULT_URL)\(_param)", naviTitle: "help".localized)
    }
}
