//
//  DeviceRegisterViewController.swift
//  Monit
//
//  Created by 맥 on 2017. 9. 4..
//  Copyright © 2017년 맥. All rights reserved.
//

import UIKit

class DeviceRegisterViewController: BaseViewController {
    @IBOutlet weak var lblNaviTitle: UILabel!
    @IBOutlet weak var lblTopSummary: UILabel!
    @IBOutlet weak var lblBottomSummary: UILabel!
    @IBOutlet weak var viewBottomSummary: UIView!
    @IBOutlet weak var lblBottomSummary2: UILabel!
    @IBOutlet weak var viewBottomSummary2: UIView!
    
    @IBOutlet weak var viewPackageImg: UIView!
    @IBOutlet weak var viewPackageSummary: UIView!
    @IBOutlet weak var viewPackage: UIView!
    @IBOutlet weak var viewSensor: UIView!
    @IBOutlet weak var viewHub: UIView!
    @IBOutlet weak var viewLamp: UIView!
    @IBOutlet weak var viewSensorTopLine: UIView!
    @IBOutlet weak var btnPackage: UIButton!
    @IBOutlet weak var btnSensor: UIButton!
    @IBOutlet weak var btnHub: UIButton!
    @IBOutlet weak var btnLamp: UIButton!
    @IBOutlet weak var imgHub: UIImageView!
    @IBOutlet weak var imgHubArrowRight: UIImageView!
    @IBOutlet weak var imgLamp: UIImageView!
    @IBOutlet weak var imgLampArrowRight: UIImageView!
    @IBOutlet weak var lblProductList: VerticalAlignLabel!
   
    override var screenType: SCREEN_TYPE { get { return .DEVICE_REGISTER } }
    var isLocalSensorConnect: Bool {
        get {
            for item in DataManager.instance.m_userInfo.connectSensor.successConnectSensor {
                if (item.m_did != 0) {
                    return true
                }
            }
            return false
        }
    }
    
    override func viewDidLoad() {
        isUpdateView = false
        super.viewDidLoad()
        Debug.print("[UI][\(self.classNameToString()).viewDidLoad()]")
        
        viewPackageImg.isHidden = true
        viewPackageSummary.isHidden = true
        viewPackage.isHidden = true
        viewSensor.isHidden = true
        viewHub.isHidden = true
        viewLamp.isHidden = true
        viewSensorTopLine.isHidden = true
        
        switch Config.channel {
        case .goodmonit:
            viewSensor.isHidden = false
            viewHub.isHidden = false
            viewLamp.isHidden = false
        case .monitXHuggies:
            viewSensor.isHidden = false
            viewHub.isHidden = false
            viewLamp.isHidden = false
        case .kc:
            viewPackageImg.isHidden = false
            viewPackageSummary.isHidden = false
            //            viewPackage.isHidden = false
            //            viewSensorTopLine.isHidden = false
            viewSensor.isHidden = false
            viewHub.isHidden = false
        case .kao:
            viewSensor.isHidden = false
            viewHub.isHidden = false
        }
        
        if (DataManager.instance.m_userInfo.configData.isMaster) {
            viewPackageImg.isHidden = false
            viewPackageSummary.isHidden = false
            viewPackage.isHidden = false
            viewPackage.isHidden = false
            viewSensorTopLine.isHidden = false
            viewSensor.isHidden = false
            viewHub.isHidden = false
            viewLamp.isHidden = false
            viewSensorTopLine.isHidden = false
        }
        
        if (DataManager.instance.m_userInfo.configData.isNewProduct) {
            viewLamp.isHidden = false
        }
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
        if (isLocalSensorConnect || Utility.isSimulator) {
            imgHub.image = UIImage(named: "imgDeviceAddHub")
            btnHub.setTitleColor(COLOR_TYPE.lblDarkGray.color, for: .normal)
            btnHub.isUserInteractionEnabled = true
            imgHubArrowRight.image = UIImage(named: "imgRightArrow")
        } else {
            imgHub.image = UIImage(named: "imgDeviceAddHubDisable")
            btnHub.setTitleColor(COLOR_TYPE.lblWhiteGray.color, for: .normal)
            btnHub.isUserInteractionEnabled = false
            imgHubArrowRight.image = UIImage(named: "imgRightArrowDisable")
        }
        
        lblNaviTitle.text = "title_connection".localized
        btnPackage.setTitle("device_monit_package".localized, for: .normal)
        btnSensor.setTitle("device_type_diaper_sensor".localized, for: .normal)
        btnHub.setTitle("device_type_hub".localized, for: .normal)
        btnLamp.setTitle("device_type_lamp".localized, for: .normal)
        lblTopSummary.text = "connection_select_device".localized
        lblBottomSummary.text = "device_monit_hub_connection_condition".localized
        viewBottomSummary.isHidden = isLocalSensorConnect
        lblBottomSummary2.text = "device_monit_hub_lamp_differentiation".localized
        viewBottomSummary2.isHidden = Config.channel != .monitXHuggies
        
        lblProductList.text = "connection_package_components".localized
        lblProductList.text = "connection_package_components".localized
        
        UIManager.instance.moveNextScene(dic: [.deviceRegisterHub : .deviceRegisterHub])
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onClick_Back(_ sender: UIButton) {
        _ = UIManager.instance.sceneMove(scene: .initView, animation: .coverVertical, isAnimation: false)
    }

    @IBAction func onClick_AddPackage(_ sender: UIButton) {
//        _ = UIManager.instance.sceneMoveNaviPush(scene: .deviceDiaperAttachGuide, isAniamtion: false)
//        return
        
        if (UIManager.instance.isBluetoothPopup()) {
            return
        }
        
        if (BleConnectionManager.instance.isStartManager) {
            _ = UIManager.instance.sceneMoveNaviPush(scene: .deviceRegisterPackageSensorOn)
            
        } else {
            if (UIManager.instance.isBluetoothPopup()) {
                return
            }
        }
    }
    
    @IBAction func onClick_AddSensor(_ sender: UIButton) {
        if (UIManager.instance.isBluetoothPopup()) {
            return
        }
        
        if (BleConnectionManager.instance.isStartManager) {
            _ = UIManager.instance.sceneMoveNaviPush(scene: .deviceRegisterSensor)
        } else {
            if (UIManager.instance.isBluetoothPopup()) {
                return
            }
        }
    }
    
    @IBAction func onClick_AddHub(_ sender: UIButton) {
        if (BleConnectionManager.instance.isStartManager) {
            _ = UIManager.instance.sceneMoveNaviPush(scene: .deviceRegisterHub)
        } else {
            if (UIManager.instance.isBluetoothPopup()) {
                return
            }
        }
    }
    
    @IBAction func onClick_AddLamp(_ sender: UIButton) {
        if (BleConnectionManager.instance.isStartManager) {
            _ = UIManager.instance.sceneMoveNaviPush(scene: .deviceRegisterLamp)
        } else {
            if (UIManager.instance.isBluetoothPopup()) {
                return
            }
        }
    }
}
