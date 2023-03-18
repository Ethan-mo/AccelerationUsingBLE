//
//  DeviceRegisterHubViewController.swift
//  Monit
//
//  Created by 맥 on 2017. 10. 9..
//  Copyright © 2017년 맥. All rights reserved.
//

import UIKit

class DeviceRegisterLampViewController: BaseViewController {
    @IBOutlet weak var lblNaviTItle: UILabel!
    @IBOutlet weak var lblContentTitle: UILabel!
    @IBOutlet weak var lblContentSummary: UITextView!
    
    @IBOutlet weak var btnConnect: UIButton!
    @IBOutlet weak var imgHowto: UIImageView!
    
    var registerType: HUB_TYPES_REGISTER_TYPE = .new
    
    override func viewDidLoad() {
        isUpdateView = false
        super.viewDidLoad()
        Debug.print("[UI][\(self.classNameToString()).viewDidLoad()]")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUI()
    }
    
    override func reloadInfo() {
        super.reloadInfo()
        Debug.print("[UI][\(self.classNameToString()).reloadInfo()]")
        setUI()
    }
    
    func setUI() {
        if (!BleConnectionLampManager.instance.isStartManager) {
            _ = PopupManager.instance.onlyContents(contentsKey: "toast_need_to_enable_bluetooth_with_err", confirmType: .ok, okHandler: { () -> () in
                _ = UIManager.instance.sceneMove(scene: .deviceRegisterNavi, animation: .coverVertical, isAnimation: false)
            }, existKey: "need_to_enable_bluetooth")
        }

        btnConnect.layer.borderColor = COLOR_TYPE.mint.color.cgColor
        btnConnect.layer.borderWidth = 1
        
        animate()
        
        lblNaviTItle.text = UIManager.instance.hubNaviTitle(type: registerType)
        lblContentTitle.text = "connection_lamp_ready_title".localized
        lblContentSummary.text = "connection_lamp_ready_detail_step1".localized
        btnConnect.setTitle("btn_next".localized.uppercased(), for: .normal)
    }
    
    func animate()
    {
        var images = [UIImage]()
        images.append(UIImage(named: "imgHubTutorial1_1")!)
        images.append(UIImage(named: "imgHubTutorial1_2")!)
  
        imgHowto.animationImages = images
        imgHowto.animationDuration = 2
        imgHowto.animationRepeatCount = 0
        imgHowto.startAnimating()
    }
    
    @IBAction func onClick_back(_ sender: UIButton) {
        UIManager.instance.sceneMoveNaviPop()
    }
    
    @IBAction func onClick_connect(_ sender: UIButton) {
        if let _vc = UIManager.instance.sceneMoveNaviPush(scene: .deviceRegisterLampLight) as? DeviceRegisterLampLightViewController {
            _vc.registerType = registerType
        }
    }
}
