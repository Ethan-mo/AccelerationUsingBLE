//
//  DeviceHubDetailSensingStatusContainView.swift
//  Monit
//
//  Created by john.lee on 2019. 2. 12..
//  Copyright © 2019년 맥. All rights reserved.
//

import UIKit

class DeviceHubDetailSensingBaseStatusContainView: UIView {
    @IBOutlet weak var imgTemp: UIImageView!
    @IBOutlet weak var lblTempTitle: UILabel!
    @IBOutlet weak var lblTemp: UILabel!
    @IBOutlet weak var lblTempSymbol: UILabel!
    
    @IBOutlet weak var imgHum: UIImageView!
    @IBOutlet weak var lblHumTitle: UILabel!
    @IBOutlet weak var lblHum: UILabel!
    @IBOutlet weak var lblHumSymbol: UILabel!
    
    @IBOutlet weak var imgVoc: UIImageView?
    @IBOutlet weak var lblVocTitle: UILabel?
    @IBOutlet weak var lblVoc: UILabel?
    
    func setInit() {
        lblTempTitle.text = "device_environment_temperature".localized
        lblHumTitle.text = "device_environment_humidity".localized
        lblVocTitle?.text = "device_environment_voc".localized
    }
    
    func setTemp(temp: HUB_TEMP, value: Double) {
        lblTemp.isHidden = false
        lblTempSymbol.isHidden = false
        lblTempTitle.textColor = COLOR_TYPE.lblGray.color
        lblTemp.textColor = COLOR_TYPE.lblDarkGray.color
        
        switch temp {
        case .normal:
            imgTemp.image = UIImage(named: "imgTempNormalDetail")
        case .low,
             .high:
            imgTemp.image = UIImage(named: "imgTempErrorDetail")
            lblTempTitle.textColor = COLOR_TYPE.red.color
            lblTemp.textColor = COLOR_TYPE.red.color
        }
        let _value = Double(floor(10 * value) / 10)
        lblTemp.text = "\(_value)"
        lblTempSymbol.text = UIManager.instance.temperatureUnitStr
    }
    
    func setHum(hum: HUB_HUM, value: Double) {
        lblHum.isHidden = false
        lblHumSymbol.isHidden = false
        lblHumTitle.textColor = COLOR_TYPE.lblGray.color
        lblHum.textColor = COLOR_TYPE.lblDarkGray.color
        
        switch hum {
        case .normal:
            imgHum.image = UIImage(named: "imgHumNormalDetail")
        case .low,
             .high:
            imgHum.image = UIImage(named: "imgHumErrorDetail")
            lblHumTitle.textColor = COLOR_TYPE.red.color
            lblHum.textColor = COLOR_TYPE.red.color
        }
        let _value = Double(floor(10 * value) / 10)
        lblHum.text = "\(_value)"
    }
    
    func setVoc(voc: HUB_VOC) {
        lblVoc?.isHidden = false
        lblVocTitle?.textColor = COLOR_TYPE.lblGray.color
        lblVoc?.textColor = COLOR_TYPE.lblDarkGray.color
        
        switch voc {
        case .none:
            imgVoc?.image = UIImage(named: "imgVocDisableDetail")
            lblVoc?.isHidden = true
            lblVocTitle?.textColor = COLOR_TYPE.lblWhiteGray.color
        case .good:
            imgVoc?.image = UIImage(named: "imgVocNormalDetail")
            lblVoc?.text = "device_environment_voc_good".localized
        case .normal:
            imgVoc?.image = UIImage(named: "imgVocNormalDetail")
            lblVoc?.text = "device_environment_voc_normal".localized
        case .bad:
            imgVoc?.image = UIImage(named: "imgVocErrorDetail")
            lblVoc?.text = "device_environment_voc_not_good".localized
            lblVocTitle?.textColor = COLOR_TYPE.red.color
            lblVoc?.textColor = COLOR_TYPE.red.color
        case .veryBad:
            imgVoc?.image = UIImage(named: "imgVocErrorDetail")
            lblVoc?.text = "device_environment_voc_very_bad".localized
            lblVocTitle?.textColor = COLOR_TYPE.red.color
            lblVoc?.textColor = COLOR_TYPE.red.color
        }
    }
    
    func setConnect(isConnect: Bool) {
        if (isConnect) {
        } else {
            imgTemp.image = UIImage(named: "imgTempDisableDetail")
            lblTemp.isHidden = true
            lblTempSymbol.isHidden = true
            lblTempTitle.textColor = COLOR_TYPE.lblWhiteGray.color
            
            imgHum.image = UIImage(named: "imgHumDisableDetail")
            lblHum.isHidden = true
            lblHumSymbol.isHidden = true
            lblHumTitle.textColor = COLOR_TYPE.lblWhiteGray.color
            
            imgVoc?.image = UIImage(named: "imgVocDisableDetail")
            lblVoc?.isHidden = true
            lblVocTitle?.textColor = COLOR_TYPE.lblWhiteGray.color
        }
    }
}
