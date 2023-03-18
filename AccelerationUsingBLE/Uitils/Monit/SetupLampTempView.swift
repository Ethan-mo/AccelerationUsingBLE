//
//  SetupLampTempView.swift
//  Monit
//
//  Created by john.lee on 2018. 8. 14..
//  Copyright © 2018년 맥. All rights reserved.
//

import UIKit

class SetupLampTempView: UIView, UIPickerViewDataSource,UIPickerViewDelegate {
    var pkMax: UIPickerView?
    var pkMin: UIPickerView?
    var picker1Options = [Float]()
    var picker2Options = [Float]()
    var actionMaxValue: ActionResultString?
    var actionMinValue: ActionResultString?
   
    var m_uiFlow = Flow()
    
    var m_did: Int = 0
    var m_enc: String = ""
    var lampStatusInfo: LampStatusInfo? {
        get {
            if let _info = DataManager.instance.m_userInfo.deviceStatus.m_lampStatus.getInfoByDeviceId(did: m_did) {
                return _info
            } else {
                return LampStatusInfo(did: m_did, name: "", power: 0, bright: 0, color: 0, attached: 0, temp: 0, hum: 0, voc: 0, ap: "", apse: "", tempmax: 3000, tempmin: 2000, hummax: 6000, hummin: 2000, offt: "0000", onnt: "0000", con: 0, offptime: "", onptime: "")
            }
        }
    }
    
    var m_cTempBottom: Int = 0
    var m_cTempTop: Int = 50
    
    var m_fTempBottom: Int = 32
    var m_fTempTop: Int = 122
    
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

        if let _statusInfo = lampStatusInfo {
            let _tempmax = Double(_statusInfo.m_tempmax) / 100.0
            let _tempmaxValue = UIManager.instance.getTemperatureProcessing(value: _tempmax)
            
            let _tempmin = Double(_statusInfo.m_tempmin) / 100.0
            let _tempminValue =  UIManager.instance.getTemperatureProcessing(value: _tempmin)
            
            actionMaxValue?("\(_tempmaxValue) \(UIManager.instance.temperatureUnitStr)")
            actionMinValue?("\(_tempminValue) \(UIManager.instance.temperatureUnitStr)")
            m_setMaxValue = Float(_tempmaxValue)
            m_setMinValue = Float(_tempminValue)
        }
        
        m_uiFlow.reset {
            pkMax?.reloadAllComponents()
            pkMin?.reloadAllComponents()
        }
    }
    
    func setRange() {
        picker1Options.removeAll()
        picker2Options.removeAll()
        if (UIManager.instance.temperatureUnit == .Celsius) {
            for i in m_cTempBottom ... m_cTempTop {
                for j in 0 ... 1 {
                    if (i == m_cTempTop && j == 1) {
                        break
                    } else {
                        picker1Options.append(Float(Float(i) + 0.5 * Float(j)))
                    }
                }
            }
            
            for i in m_cTempBottom ... m_cTempTop {
                for j in 0 ... 1 {
                    if (i == m_cTempTop && j == 1) {
                        break
                    } else {
                        picker2Options.append(Float(Float(i) + 0.5 * Float(j)))
                    }
                }
            }
        } else {
            for i in m_fTempBottom ... m_fTempTop {
                for j in 0 ... 1 {
                    if (i == m_fTempTop && j == 1) {
                        break
                    } else {
                        picker1Options.append(Float(Float(i) + 0.5 * Float(j)))
                    }
                }
            }
            
            for i in m_fTempBottom ... m_fTempTop {
                for j in 0 ... 1 {
                    if (i == m_fTempTop && j == 1) {
                        break
                    } else {
                        picker2Options.append(Float(Float(i) + 0.5 * Float(j)))
                    }
                }
            }
        }
    }
    
    func selectRow() {
        if let _statusInfo = lampStatusInfo {
            let _tempmax = Double(_statusInfo.m_tempmax) / 100.0
            let _tempmaxValue = UIManager.instance.getTemperatureProcessing(value: _tempmax)
            
            let _tempmin = Double(_statusInfo.m_tempmin) / 100.0
            let _tempminValue =  UIManager.instance.getTemperatureProcessing(value: _tempmin)
            
            for (i, item) in picker1Options.enumerated() {
                if (picker1Options.count == i + 1) {
                    if (Double(item) == _tempmaxValue) {
                        pkMax?.selectRow(i, inComponent: 0, animated: false)
                    }
                    break
                }
                
                if (Double(item) <= _tempmaxValue && _tempmaxValue < Double(picker1Options[i + 1])) {
                    pkMax?.selectRow(i, inComponent: 0, animated: false)
                    break
                }
            }
            
            for (i, item) in picker2Options.enumerated() {
                if (picker2Options.count == i + 1) {
                    if (Double(item) == _tempminValue) {
                        pkMin?.selectRow(i, inComponent: 0, animated: false)
                    }
                    break
                }
                
                if (Double(item) <= _tempminValue && _tempminValue < Double(picker2Options[i + 1])) {
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
            actionMaxValue?("\(picker1Options[row]) \(UIManager.instance.temperatureUnitStr)")
            m_setMaxValue = picker1Options[row]
        }else{
            actionMinValue?("\(picker2Options[row]) \(UIManager.instance.temperatureUnitStr)")
            m_setMinValue = picker2Options[row]
        }
    }
    
    func vaildCheck() -> Bool {
        if (lampStatusInfo != nil) {
            if (m_setMinValue >= m_setMaxValue) {
                _ = PopupManager.instance.onlyContents(contentsKey: "toast_invalid_min_max_range", confirmType: .ok)
                return false
            }
        } else {
            Debug.print("[ERROR] lampStatusInfo is null", event: .error)
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
        
        if let _statusInfo = lampStatusInfo {
            
            var _tempmax = 0
            if (UIManager.instance.temperatureUnit == .Celsius) {
                _tempmax = Int(Double(m_setMaxValue) * 100)
            } else {
                _tempmax = Int(UI_Utility.fahrenheitToCelsius(tempInF: Double(m_setMaxValue)) * 100)
            }
            
            var _tempmin = 0
            if (UIManager.instance.temperatureUnit == .Celsius) {
                _tempmin = Int(Double(m_setMinValue) * 100)
            } else {
                _tempmin = Int(UI_Utility.fahrenheitToCelsius(tempInF: Double(m_setMinValue)) * 100)
            }
 
            _statusInfo.m_tempmin = _tempmin
            _statusInfo.m_tempmax = _tempmax
            
            let send = Send_SetAlarmThreshold()
            send.aid = DataManager.instance.m_userInfo.account_id
            send.token = DataManager.instance.m_userInfo.token
            send.type = DEVICE_TYPE.Lamp.rawValue
            send.did = m_did
            send.enc = m_enc
            send.tmin = _statusInfo.m_tempmin
            send.tmax = _statusInfo.m_tempmax
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
