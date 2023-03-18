//
//  SetupHubTempView.swift
//  Monit
//
//  Created by john.lee on 2018. 8. 14..
//  Copyright © 2018년 맥. All rights reserved.
//

import UIKit

class SetupHubHumView: UIView, UIPickerViewDataSource,UIPickerViewDelegate {
    var pkMax: UIPickerView?
    var pkMin: UIPickerView?
    var picker1Options = [Int]()
    var picker2Options = [Int]()
    var actionMaxValue: ActionResultString?
    var actionMinValue: ActionResultString?
    
    var m_uiFlow = Flow()
    
    var m_did: Int = 0
    var m_enc: String = ""
    var hubStatusInfo: HubStatusInfo? {
        get {
            if let _info = DataManager.instance.m_userInfo.deviceStatus.m_hubStatus.getInfoByDeviceId(did: m_did) {
                return _info
            } else {
                return HubStatusInfo(did: m_did, name: "", power: 0, bright: 0, color: 0, attached: 0, temp: 0, hum: 0, voc: 0, ap: "", apse: "", tempmax: 3000, tempmin: 2000, hummax: 6000, hummin: 2000, offt: "0000", onnt: "0000", con: 0, offptime: "", onptime: "")
            }
        }
    }
    
    var m_humBottom: Int = 0
    var m_humTop: Int = 100
    
    var m_setMaxValue: Float = 0
    var m_setMinValue: Float = 0
    
    func setInit(did: Int, enc: String, pkMax: UIPickerView, pkMin: UIPickerView) {
        m_did = did
        m_enc = enc
        self.pkMax = pkMax
        self.pkMin = pkMin
        self.pkMax?.delegate = self
        self.pkMin?.delegate = self
    }
    
    func setUI() {
        setRange()
        selectRow()

        if let _statusInfo = hubStatusInfo {
            actionMaxValue?("\(_statusInfo.hummaxValue) %")
            actionMinValue?("\(_statusInfo.humminValue) %")
            m_setMaxValue = Float(_statusInfo.hummaxValue)
            m_setMinValue = Float(_statusInfo.humminValue)
        }
        
        m_uiFlow.reset {
            pkMax?.reloadAllComponents()
            pkMin?.reloadAllComponents()
        }
    }
    
    func setRange() {
        picker1Options.removeAll()
        picker2Options.removeAll()
        for i in m_humBottom ... m_humTop {
            picker1Options.append(i)
        }
        
        for i in m_humBottom ... m_humTop {
            picker2Options.append(i)
        }
    }
    
    func selectRow() {
        if let _statusInfo = hubStatusInfo {
            for (i, item) in picker1Options.enumerated() {
                if (picker1Options.count == i + 1) {
                    if (item == Int(_statusInfo.hummaxValue)) {
                        pkMax?.selectRow(i, inComponent: 0, animated: false)
                    }
                    break
                }
                
                if (item <= Int(_statusInfo.hummaxValue) && Int(_statusInfo.hummaxValue) < picker1Options[i + 1]) {
                    pkMax?.selectRow(i, inComponent: 0, animated: false)
                    break
                }
            }
            
            for (i, item) in picker2Options.enumerated() {
                if (picker2Options.count == i + 1) {
                    if (item == Int(_statusInfo.humminValue)) {
                        pkMin?.selectRow(i, inComponent: 0, animated: false)
                    }
                    break
                }
                
                if (item <= Int(_statusInfo.humminValue) && Int(_statusInfo.humminValue) < picker2Options[i + 1]) {
                    pkMin?.selectRow(i, inComponent: 0, animated: false)
                    break
                }
            }
        }
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
            actionMaxValue?("\(picker1Options[row]) %")
            m_setMaxValue = Float(picker1Options[row])
        }else{
            actionMinValue?("\(picker2Options[row]) %")
            m_setMinValue = Float(picker2Options[row])
        }
    }
    
    func vaildCheck() -> Bool {
        if (hubStatusInfo != nil) {
            if (m_setMinValue >= m_setMaxValue) {
                _ = PopupManager.instance.onlyContents(contentsKey: "toast_invalid_min_max_range", confirmType: .ok)
                return false
            }
        } else {
            Debug.print("[ERROR] hubStatusInfo is null", event: .error)
            let _errStr = String(format: "dialog_contents_err_communication_with_server".localized, APP_ERR_COD.Send_SetAlarmThreshold.rawValue)
            _ = PopupManager.instance.onlyContentsCustom(contents: _errStr, confirmType: .ok)
            return false
        }
        return true
    }
    
    func onClick_save() {
        if (!vaildCheck()) {
            return
        }
        
        if let _statusInfo = hubStatusInfo {
            _statusInfo.humminValue = Double(m_setMinValue)
            _statusInfo.hummaxValue = Double(m_setMaxValue)
            
            let send = Send_SetAlarmThreshold()
            send.aid = DataManager.instance.m_userInfo.account_id
            send.token = DataManager.instance.m_userInfo.token
            send.type = DEVICE_TYPE.Hub.rawValue
            send.did = m_did
            send.enc = m_enc
            send.hmin = _statusInfo.m_hummin
            send.hmax = _statusInfo.m_hummax
            NetworkManager.instance.Request(send) { (json) -> () in
                let receive = Receive_SetAlarmThreshold(json)
                switch receive.ecd {
                case .success: break
                default:
                    Debug.print("[ERROR] Send_SetAlarmThreshold invaild errcod", event: .error)
                    let _errStr = String(format: "dialog_contents_err_communication_with_server".localized, APP_ERR_COD.Send_SetAlarmThreshold.rawValue)
                    _ = PopupManager.instance.onlyContentsCustom(contents: _errStr, confirmType: .ok)
                }
            }
        }
    }
}
