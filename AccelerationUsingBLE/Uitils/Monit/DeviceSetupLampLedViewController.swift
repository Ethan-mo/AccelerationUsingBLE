//
//  DeviceSetupLampTempViewController.swift
//  Monit
//
//  Created by 맥 on 2017. 10. 2..
//  Copyright © 2017년 맥. All rights reserved.
//

import UIKit
import SwiftyJSON

class DeviceSetupLampLedViewController: BaseViewController, UIPickerViewDataSource,UIPickerViewDelegate {
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

    var picker1Options = [Int]()
    var picker2Options = [Int]()
    
    var m_uiFlow = Flow()
    
    var m_detailInfo: DeviceDetailInfo?
    
    var m_bottom: Int = 0
    var m_top: Int = 23

    var m_setMaxValue: Int = 0
    var m_setMinValue: Int = 0
    
    var lampStatusInfo: LampStatusInfo? {
        get {
            return DataManager.instance.m_userInfo.deviceStatus.m_lampStatus.getInfoByDeviceId(did: m_detailInfo!.m_did)
        }
    }
    
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
          pkMax.delegate = self;
          pkMin.delegate = self;
          
          setRange()
          selectRow()
          setVisiableMax(isOn: false, isAnimation: false)
          setVisiableMin(isOn: false, isAnimation: false)
          
          if let _statusInfo = lampStatusInfo {
              lblMaxValue.text = "\(_statusInfo.ledOnTimeStr)"
              lblMinValue.text = "\(_statusInfo.ledOffTimeStr)"
              m_setMaxValue = _statusInfo.ledOnTime
              m_setMinValue = _statusInfo.ledOffTime
          }
          
          lblNaviTitle.text = "setting_custom_led_on_off_time".localized
          btnNaviNext.setTitle("btn_save".localized.uppercased(), for: .normal)
          //        lblAlarmMasterTitle.text = "setting_device_enable_alarm".localized
          lblSummary.text = "setting_custom_led_on_off_time".localized
          btnHighestTitle.setTitle("setting_led_on_time".localized, for: .normal)
          btnLowestTitle.setTitle("setting_led_off_time".localized, for: .normal)
          lblBottomSummary.text = "setting_custom_led_on_off_time_description".localized
          
          m_uiFlow.reset {
              pkMax.reloadAllComponents()
              pkMin.reloadAllComponents()
          }

      }
      
      func setRange() {
          picker1Options.removeAll()
          picker2Options.removeAll()
          for i in m_bottom ... m_top {
              picker1Options.append(i)
          }
          
          for i in m_bottom ... m_top {
              picker2Options.append(i)
          }
      }
      
      func selectRow() {
          if let _statusInfo = lampStatusInfo {
              for (i, item) in picker1Options.enumerated() {
                  if (picker1Options.count == i + 1) {
                      if (item == _statusInfo.ledOnTime) {
                          pkMax.selectRow(i, inComponent: 0, animated: false)
                      }
                      break
                  }
                  
                  if (item <= _statusInfo.ledOnTime && _statusInfo.ledOnTime < picker1Options[i + 1]) {
                      pkMax.selectRow(i, inComponent: 0, animated: false)
                      break
                  }
              }
              
              for (i, item) in picker2Options.enumerated() {
                  if (picker2Options.count == i + 1) {
                      if (item == _statusInfo.ledOffTime) {
                          pkMin.selectRow(i, inComponent: 0, animated: false)
                      }
                      break
                  }
                  
                  if (item <= _statusInfo.ledOffTime && _statusInfo.ledOffTime < picker2Options[i + 1]) {
                      pkMin.selectRow(i, inComponent: 0, animated: false)
                      break
                  }
              }
          }
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
      
      func numberOfComponents(in pickerView: UIPickerView) -> Int {
          return 1
      }
      
      func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
          if (pickerView.tag == 0){
              return picker1Options.count
          }else{
              return picker2Options.count
          }
      }
      
      func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
          if (pickerView.tag == 0){
              return "\(picker1Options[row])"
          }else{
              return "\(picker2Options[row])"
          }
      }
      
      func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
          if (pickerView.tag == 0){
              lblMaxValue.text = "\(picker1Options[row]):00"
              m_setMaxValue = picker1Options[row]
          }else{
              lblMinValue.text = "\(picker2Options[row]):00"
              m_setMinValue = picker2Options[row]
          }
      }
    
      @IBAction func onClick_back(_ sender: UIButton) {
          UIManager.instance.sceneMoveNaviPop()
      }
      
      //    @IBAction func changeValue_alaram(_ sender: UISwitch) {
      //        setSwMaster(isOn: sender.isOn, isAnimation: true)
      //    }
      
      @IBAction func onClick_min(_ sender: UIButton) {
          setVisiableMin(isOn: true, isAnimation: true)
          setVisiableMax(isOn: false, isAnimation: true)
      }
      
      @IBAction func onClick_max(_ sender: UIButton) {
          setVisiableMin(isOn: false, isAnimation: true)
          setVisiableMax(isOn: true, isAnimation: true)
      }
    
    @IBAction func onClick_save(_ sender: UIButton) {
        if let _statusInfo = lampStatusInfo {
            _statusInfo.ledOffTime = m_setMinValue
            _statusInfo.ledOnTime = m_setMaxValue
            
            let send = Send_SetLedOnOffTime()
            send.aid = DataManager.instance.m_userInfo.account_id
            send.token = DataManager.instance.m_userInfo.token
            send.type = DEVICE_TYPE.Lamp.rawValue
            send.did = m_detailInfo!.m_did
            send.enc = userInfo!.enc
            send.onnt = _statusInfo.m_onnt
            send.offt = _statusInfo.m_offt
            NetworkManager.instance.Request(send) { (json) -> () in
                let receive = Receive_SetLedOnOffTime(json)
                switch receive.ecd {
                case .success:
                    ScreenAnalyticsManager.instance.googleTagManagerCustom(type: .lamp_setting_led_indicator_enabled_time, items: ["lampid_\(self.m_detailInfo!.m_did)" : "\(self.m_setMinValue)-\(self.m_setMaxValue)"])
                    
                    UIManager.instance.sceneMoveNaviPop()
                //                    self.setSwAlarmMasterInfoChange(isOn: self.swMaster.isOn)
                default:
                    Debug.print("[ERROR] Send_SetLedOnOffTime invaild errcod", event: .error)
                    let _errStr = String(format: "dialog_contents_err_communication_with_server".localized, APP_ERR_COD.Send_SetLedOnOffTime.rawValue)
                    _ = PopupManager.instance.onlyContentsCustom(contents: _errStr, confirmType: .ok, okHandler: { () -> () in
                        UIManager.instance.sceneMoveNaviPop()
                    })
                }
            }
        } else {
            let _errStr = String(format: "dialog_contents_err_communication_with_server".localized, APP_ERR_COD.Send_SetLedOnOffTime.rawValue)
            _ = PopupManager.instance.onlyContentsCustom(contents: _errStr, confirmType: .ok, okHandler: { () -> () in
                UIManager.instance.sceneMoveNaviPop()
            })
        }
    }
}

