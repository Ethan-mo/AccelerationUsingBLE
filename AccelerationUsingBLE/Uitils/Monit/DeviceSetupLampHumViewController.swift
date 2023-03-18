//
//  DeviceSetupLampHumViewController.swift
//  Monit
//
//  Created by 맥 on 2017. 10. 2..
//  Copyright © 2017년 맥. All rights reserved.
//

import UIKit

class DeviceSetupLampHumViewController: BaseViewController {
        @IBOutlet weak var lblNaviTitle: UILabel!
        @IBOutlet weak var btnNaviNext: UIButton!
    //    @IBOutlet weak var lblAlarmMasterTitle: UILabel!
        @IBOutlet weak var lblSummary: UILabel!
        @IBOutlet weak var btnHighestTitle: UIButton!
        @IBOutlet weak var btnLowestTitle: UIButton!
        @IBOutlet weak var lblBottomSummary: UILabel!
        
    //    @IBOutlet weak var swMaster: UISwitch!
        
        @IBOutlet weak var btnMax: UIButton!
        @IBOutlet weak var lblMaxValue: UILabel!
        @IBOutlet weak var pkMax: UIPickerView!
        @IBOutlet weak var constMax: NSLayoutConstraint!
        
        @IBOutlet weak var btnMin: UIButton!
        @IBOutlet weak var lblMinValue: UILabel!
        @IBOutlet weak var pkMin: UIPickerView!
        @IBOutlet weak var constMin: NSLayoutConstraint!
    
        var m_detailInfo: DeviceDetailInfo?
        var setupLampHumView: SetupLampHumView?
    
    var userInfo: UserInfoDevice? {
        get {
            return DataManager.instance.m_dataController.device.getUserInfoByDid(did: m_detailInfo!.m_did, type: DEVICE_TYPE.Lamp.rawValue)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUI()
    }

    func setUI() {
        lblNaviTitle.text = "setting_custom_humidity".localized
        btnNaviNext.setTitle("btn_save".localized.uppercased(), for: .normal)
        //        lblAlarmMasterTitle.text = "setting_device_enable_alarm".localized
        lblSummary.text = "setting_custom_humidity".localized
        btnHighestTitle.setTitle("setting_max_humidity_threshold".localized, for: .normal)
        btnLowestTitle.setTitle("setting_min_humidity_threshold".localized, for: .normal)
        lblBottomSummary.text = "setting_custom_humidity_description".localized
        
        if (setupLampHumView == nil) {
            setupLampHumView = .fromNib()
            setupLampHumView?.actionMaxValue = { (value) in
                self.lblMaxValue.text = value
            }
            setupLampHumView?.actionMinValue = { (value) in
                self.lblMinValue.text = value
            }
            setupLampHumView?.setInit(did: m_detailInfo!.m_did, enc: userInfo!.enc, pkMax: pkMax, pkMin: pkMin)
            setupLampHumView?.setUI()
        } else {
            setupLampHumView?.setUI()
        }

        setVisiableMax(isOn: false, isAnimation: false)
        setVisiableMin(isOn: false, isAnimation: false)
    }
    
    func setVisiableMin(isOn: Bool, isAnimation: Bool) {
        if (isAnimation) {
            UIView.animate(withDuration: 0.2, animations: {
                self.constMin?.constant = (isOn ? 254 : 48)
                self.view!.layoutIfNeeded()
            })
        } else {
            self.constMin?.constant = (isOn ? 254 : 48)
            self.view!.layoutIfNeeded()
        }
        pkMin.isHidden = !isOn
    }
    
    func setVisiableMax(isOn: Bool, isAnimation: Bool) {
        if (isAnimation) {
            UIView.animate(withDuration: 0.2, animations: {
                self.constMax?.constant = (isOn ? 254 : 48)
                self.view!.layoutIfNeeded()
            })
        } else {
            self.constMax?.constant = (isOn ? 254 : 48)
            self.view!.layoutIfNeeded()
        }
        pkMax.isHidden = !isOn
    }
    
    @IBAction func onClick_back(_ sender: UIButton) {
         UIManager.instance.sceneMoveNaviPop()
    }
    
    @IBAction func onClick_save(_ sender: UIButton) {
        if (!(setupLampHumView?.vaildCheck() ?? true)) {
            return
        }
        
        setupLampHumView?.onClick_save()
        
        let _humminValue: Float = setupLampHumView?.m_setMinValue ?? 0.0
        let _hummaxValue: Float = setupLampHumView?.m_setMaxValue ?? 0.0
        ScreenAnalyticsManager.instance.googleTagManagerCustom(type: .lamp_setting_humidity_range, items: ["lampid_\(m_detailInfo!.m_did)" : "\(_humminValue/100.0)~\(_hummaxValue/100.0)"])
        
        UIManager.instance.sceneMoveNaviPop()
    }
    
    @IBAction func onClick_min(_ sender: UIButton) {
        setVisiableMin(isOn: pkMin.isHidden == true, isAnimation: true)
        setVisiableMax(isOn: false, isAnimation: true)
    }
    
    @IBAction func onClick_max(_ sender: UIButton) {
        setVisiableMin(isOn: false, isAnimation: true)
        setVisiableMax(isOn: pkMax.isHidden == true, isAnimation: true)
    }
}
