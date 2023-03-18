//
//  BaseConnectHubTableViewCell.swift
//  Monit
//
//  Created by john.lee on 2019. 2. 12..
//  Copyright © 2019년 맥. All rights reserved.
//

import UIKit

class BaseConnectHubTableViewCell: BaseTableViewCell {
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblDisconnectSummary: UILabel!
    
    @IBOutlet weak var imgConnecting: UIImageView!
    @IBOutlet weak var imgRound: UIImageView?
    @IBOutlet weak var imgConnectionStatus: UIImageView!
    @IBOutlet weak var lblPercent: UILabel?
    @IBOutlet weak var viewFill: UIView?
    @IBOutlet weak var imgNewAlarmHub: UIImageView!
    
    // connect group
    @IBOutlet weak var viewConnectGroup: UIView!
    
    @IBOutlet weak var lblTempTitle: UILabel?
    @IBOutlet weak var imgTemp: UIImageView?
    @IBOutlet weak var lblTemp: UILabel!
    @IBOutlet weak var lblTempUnit: UILabel?
    @IBOutlet weak var imgNewAlarmTemp: UIImageView!
    
    @IBOutlet weak var lblHumTitle: UILabel?
    @IBOutlet weak var imgHum: UIImageView?
    @IBOutlet weak var lblHum: UILabel!
    @IBOutlet weak var imgNewAlarmHum: UIImageView!
    
    @IBOutlet weak var lblVocTitle: UILabel?
    @IBOutlet weak var imgVoc: UIImageView?
    @IBOutlet weak var lblVoc: UILabel?
    @IBOutlet weak var imgNewAlarmVoc: UIImageView?
    
    // connect without sensor group
    @IBOutlet weak var viewConnectGroupWithoutSensor: UIView?
    
    @IBOutlet weak var lblTempTitleWithoutSensor: UILabel?
    @IBOutlet weak var imgTempWithoutSensor: UIImageView?
    @IBOutlet weak var lblTempWithoutSensor: UILabel?
    @IBOutlet weak var lblTempUnitWithoutSensor: UILabel?
    @IBOutlet weak var imgNewAlarmTempWithoutSensor: UIImageView?
    
    @IBOutlet weak var lblHumTitleWithoutSensor: UILabel?
    @IBOutlet weak var imgHumWithoutSensor: UIImageView?
    @IBOutlet weak var lblHumWithoutSensor: UILabel?
    @IBOutlet weak var imgNewAlarmHumWithoutSensor: UIImageView?
    
    var m_detailInfo: DeviceDetailInfo?
    
    var hubStatusInfo: HubStatusInfo? {
        get {
            return DataManager.instance.m_userInfo.deviceStatus.m_hubStatus.getInfoByDeviceId(did: m_detailInfo!.m_did)
        }
    }
    
    var isConnect: Bool {
        get {
            return DataManager.instance.m_dataController.device.m_hub.isConnect(type: m_detailInfo!.m_deviceType, did: m_detailInfo!.m_did)
        }
    }
    
    var currentCircleSlider: CircleSlider!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setInit() {
        if let _statusInfo = hubStatusInfo {
            let _att = _statusInfo.m_attached > 0 ? "/U\(_statusInfo.m_attached)" : ""
            if (DataManager.instance.m_userInfo.configData.isMaster) {
                lblName.text = "\(_statusInfo.m_name) - \(_statusInfo.m_did)\(_att)"
            } else {
                lblName.text = _statusInfo.m_name
            }
            let _temp = Double(_statusInfo.m_temp) / 100.0
            let _tempValue = UIManager.instance.getTemperatureProcessing(value: _temp)
            
            setHum(hum: _statusInfo.hum, value: _statusInfo.humValue)
            setTemp(temp: _statusInfo.temp, value: _tempValue)
            setScore(score: _statusInfo.score, value: _statusInfo.scoreValue)
            setVoc(voc: _statusInfo.voc)
            setBright(level: _statusInfo.brightLevel)
            setConnect(isConnect: isConnect)
        } else {
            //            lblName.text = "허브"
            //            setTemp(temp: .bad, value: 123)
            //            setHum(hum: .bad, value: 11)
            //            setScore(score: .bad, value: 82)
            //            setConnect(isConnect: true)
        }
        
        lblTitle.text = "device_type_hub".localized
        lblDisconnectSummary.text = "device_hub_disconnected".localized
        lblTempTitle?.text = "device_environment_temperature".localized
        lblHumTitle?.text = "device_environment_humidity".localized
        lblVocTitle?.text = "device_sensor_voc".localized
        lblTempTitleWithoutSensor?.text = "device_environment_temperature".localized
        lblHumTitleWithoutSensor?.text = "device_environment_humidity".localized
        
        imgNewAlarmHub.isHidden = true
        if (isConnect) {
            if (DataManager.instance.m_dataController.newAlarm.hubFirmware.isNewAlarmMain(did: m_detailInfo!.m_did)) {
                imgNewAlarmHub.isHidden = false
            }
        }
        
        imgNewAlarmTemp.isHidden = true
        imgNewAlarmHum.isHidden = true
        imgNewAlarmVoc?.isHidden = true
        
        if (isNewAlarm(type: .low_temperature) || isNewAlarm(type: .high_temperature)) {
            imgNewAlarmTemp.isHidden = false
        }
        if (isNewAlarm(type: .low_humidity) || isNewAlarm(type: .high_humidity)) {
            imgNewAlarmHum.isHidden = false
        }
        if (isNewAlarm(type: .voc_warning)) {
            imgNewAlarmVoc?.isHidden = false
        }
    }
    
    func isNewAlarm(type: DEVICE_NOTI_TYPE) -> Bool {
        if (DataManager.instance.m_dataController.newAlarm.noti.isNotiNewAlarm(did: m_detailInfo!.m_did, type: DEVICE_TYPE.Hub.rawValue, noti: type.rawValue)) {
            return true
        }
        return false
    }
    
    func setBright(level: HUB_TYPES_BRIGHT_TYPE) {
        switch level {
        case .level_1, .level_2, .level_3:
            imgConnecting.image = UIImage(named: Config.channel == .kc ? "imgKcHubBright" : "imgHubBright")
        default:
            imgConnecting.image = UIImage(named: Config.channel == .kc ? "imgKcHubOn" : "imgHubOn")
        }
    }
    
    func setSlider(amount: Int, color: UIColor) { // amount: 1~100
        lblPercent?.text = amount.description
        lblPercent?.textColor = color
        if currentCircleSlider != nil { currentCircleSlider.removeFromSuperview() }
        currentCircleSlider = UIManager.instance.makeCircleSlider(amount: Float(amount) * 0.01, width: 3.1, diameter: 62, color: color)
        viewFill?.addSubview(currentCircleSlider)
    }
    
    func setTemp(temp: HUB_TYPES_TEMP, value: Double) {
        switch temp {
        case .normal:
            imgTemp?.image = UIImage(named: Config.channel == .kc ? "imgKcTempNormalMain" : "imgTempNormalMain")
            imgTempWithoutSensor?.image = UIImage(named: Config.channel == .kc ? "imgKcTempNormalMain" : "imgTempNormalMain")
            
            switch Config.channel {
            case .monitXHuggies:
                lblTemp.textColor = COLOR_TYPE.blue.color
                lblTempWithoutSensor?.textColor = COLOR_TYPE.blue.color
            case .goodmonit, .kao:
                lblTemp.textColor = COLOR_TYPE.blue.color
                lblTempWithoutSensor?.textColor = COLOR_TYPE.blue.color
            case .kc:
                lblTemp.textColor = COLOR_TYPE.lblGray.color
                lblTempWithoutSensor?.textColor = COLOR_TYPE.lblGray.color
            }
        case .low:
            imgTemp?.image = UIImage(named: Config.channel == .kc ? "imgKcTempErrorMain_glow_blue" : "imgTempErrorMain")
            imgTempWithoutSensor?.image = UIImage(named: Config.channel == .kc ? "imgKcTempErrorMain_glow_blue" : "imgTempErrorMain")
            
            switch Config.channel {
            case .monitXHuggies:
                lblTemp.textColor = COLOR_TYPE.red.color
                lblTempWithoutSensor?.textColor = COLOR_TYPE.red.color
            case .goodmonit, .kao:
                lblTemp.textColor = COLOR_TYPE.red.color
                lblTempWithoutSensor?.textColor = COLOR_TYPE.red.color
            case .kc:
                lblTemp.textColor = COLOR_TYPE.blue.color
                lblTempWithoutSensor?.textColor = COLOR_TYPE.blue.color
            }
        case .high:
            imgTemp?.image = UIImage(named: Config.channel == .kc ? "imgKcTempErrorMain_glow_red" : "imgTempErrorMain")
            imgTempWithoutSensor?.image = UIImage(named: Config.channel == .kc ? "imgKcTempErrorMain_glow_red" : "imgTempErrorMain")
            
            switch Config.channel {
            case .monitXHuggies:
                lblTemp.textColor = COLOR_TYPE.red.color
                lblTempWithoutSensor?.textColor = COLOR_TYPE.red.color
            case .goodmonit, .kao:
                lblTemp.textColor = COLOR_TYPE.red.color
                lblTempWithoutSensor?.textColor = COLOR_TYPE.red.color
            case .kc:
                lblTemp.textColor = COLOR_TYPE.red.color
                lblTempWithoutSensor?.textColor = COLOR_TYPE.red.color
            }
        }
        
        let _value = Double(floor(10 * value) / 10)
        switch Config.channel {
        case .monitXHuggies:
            lblTemp.text = "\(_value)"
            lblTempUnit?.text = "\(UIManager.instance.temperatureUnitStr)"
            lblTempWithoutSensor?.text = "\(_value)"
            lblTempUnitWithoutSensor?.text = "\(UIManager.instance.temperatureUnitStr)"
        case .goodmonit, .kao:
            lblTemp.text = "\(_value)"
            lblTempUnit?.text = "\(UIManager.instance.temperatureUnitStr)"
            lblTempWithoutSensor?.text = "\(_value)"
            lblTempUnitWithoutSensor?.text = "\(UIManager.instance.temperatureUnitStr)"
        case .kc:
            lblTemp.text = "\(_value)\(UIManager.instance.temperatureUnitStr)"
            lblTempWithoutSensor?.text = "\(_value)\(UIManager.instance.temperatureUnitStr)"
        }
    }
    
    func setHum(hum: HUB_TYPES_HUM, value: Double) {
        switch hum {
        case .normal:
            imgHum?.image = UIImage(named: Config.channel == .kc ? "imgKcHumNormalMain" : "imgHumNormalMain")
            imgHumWithoutSensor?.image = UIImage(named: Config.channel == .kc ? "imgKcHumNormalMain" : "imgHumNormalMain")
            
            switch Config.channel {
            case .monitXHuggies:
                lblHum.textColor = COLOR_TYPE.blue.color
                lblHumWithoutSensor?.textColor = COLOR_TYPE.blue.color
            case .goodmonit, .kao:
                lblHum.textColor = COLOR_TYPE.blue.color
                lblHumWithoutSensor?.textColor = COLOR_TYPE.blue.color
            case .kc:
                lblHum.textColor = COLOR_TYPE.lblGray.color
                lblHumWithoutSensor?.textColor = COLOR_TYPE.lblGray.color
            }
        case .low, .high:
            imgHum?.image = UIImage(named: Config.channel == .kc ? "imgKcHumErrorMain_glow" : "imgHumErrorMain")
            imgHumWithoutSensor?.image = UIImage(named: Config.channel == .kc ? "imgKcHumErrorMain_glow" : "imgHumErrorMain")
            
            switch Config.channel {
            case .monitXHuggies:
                lblHum.textColor = COLOR_TYPE.red.color
                lblHumWithoutSensor?.textColor = COLOR_TYPE.red.color
            case .goodmonit, .kao:
                lblHum.textColor = COLOR_TYPE.red.color
                lblHumWithoutSensor?.textColor = COLOR_TYPE.red.color
            case .kc:
                lblHum.textColor = COLOR_TYPE.orange.color
                lblHumWithoutSensor?.textColor = COLOR_TYPE.orange.color
            }
        }
        
        let _value = Double(floor(10 * value) / 10)
        switch Config.channel {
        case .monitXHuggies:
            lblHum.text = "\(_value)"
            lblHumWithoutSensor?.text = "\(_value)"
        case .goodmonit, .kao:
            lblHum.text = "\(_value)"
            lblHumWithoutSensor?.text = "\(_value)"
        case .kc:
            lblHum.text = "\(_value)%"
            lblHumWithoutSensor?.text = "\(_value)%"
        }
    }
    
    func setVoc(voc: HUB_TYPES_VOC) {
        viewConnectGroup.isHidden = false
        viewConnectGroupWithoutSensor?.isHidden = true
        
        guard (Config.channel != .kc) else { return }
        
        switch Config.channel {
        case .monitXHuggies:
            if (voc == .none) {
                viewConnectGroup.isHidden = true
                viewConnectGroupWithoutSensor?.isHidden = false
            }
        case .goodmonit, .kao:
            if (voc == .none) {
                viewConnectGroup.isHidden = true
                viewConnectGroupWithoutSensor?.isHidden = false
            }
        case .kc: break
        }
        
        switch voc {
        case .none:
            imgVoc?.image = UIImage(named: "imgVocDisableMain")
            lblVoc?.text = ""
            
            switch Config.channel {
            case .monitXHuggies:
                lblVoc?.textColor = COLOR_TYPE.blue.color
            case .goodmonit, .kao:
                lblVoc?.textColor = COLOR_TYPE.blue.color
            case .kc:
                lblVoc?.textColor = COLOR_TYPE.lblGray.color
            }
        case .good:
            imgVoc?.image = UIImage(named: "imgVocNormalMain")
            lblVoc?.text = "device_environment_voc_good".localized
            
            switch Config.channel {
            case .monitXHuggies:
                lblVoc?.textColor = COLOR_TYPE.blue.color
            case .goodmonit, .kao:
                lblVoc?.textColor = COLOR_TYPE.blue.color
            case .kc:
                lblVoc?.textColor = COLOR_TYPE.lblGray.color
            }
        case .normal:
            imgVoc?.image = UIImage(named: "imgVocNormalMain")
            lblVoc?.text = "device_environment_voc_normal".localized
            
            switch Config.channel {
            case .monitXHuggies:
                lblVoc?.textColor = COLOR_TYPE.blue.color
            case .goodmonit, .kao:
                lblVoc?.textColor = COLOR_TYPE.blue.color
            case .kc:
                lblVoc?.textColor = COLOR_TYPE.lblGray.color
            }
        case .bad:
            imgVoc?.image = UIImage(named: "imgVocErrorMain")
            lblVoc?.text = "device_environment_voc_not_good".localized
            lblVoc?.textColor = COLOR_TYPE.red.color
        case .veryBad:
            imgVoc?.image = UIImage(named: "imgVocErrorMain")
            lblVoc?.text = "device_environment_voc_very_bad".localized
            lblVoc?.textColor = COLOR_TYPE.red.color
        }
    }
    
    func setScore(score: HUB_TYPES_SCORE, value: Int) {
        switch score {
        case .good:
            setSlider(amount: value, color: COLOR_TYPE.gaugeBlue.color)
        case .normal:
            setSlider(amount: value, color: COLOR_TYPE.gaugeGreen.color)
        case .bad:
            setSlider(amount: value, color: COLOR_TYPE.gaugeYellow.color)
        case .veryBad:
            setSlider(amount: value, color: COLOR_TYPE.gaugeRed.color)
        }
    }
    
    func setConnect(isConnect: Bool) {
        if (isConnect) {
            imgRound?.isHidden = false
            lblPercent?.isHidden = false
            viewFill?.isHidden = false
            lblDisconnectSummary.isHidden = true
            imgRound?.image = UIImage(named: "imgRoundSmall")
            imgConnectionStatus.isHidden = false
            imgConnectionStatus.image = UIImage(named: "imgConnectStatusWifi")
        } else {
            imgRound?.isHidden = false
            lblPercent?.isHidden = true
            viewFill?.isHidden = true
            viewConnectGroup.isHidden = true
            viewConnectGroupWithoutSensor?.isHidden = true
            lblDisconnectSummary.isHidden = false
            imgRound?.image = UIImage(named: "imgRoundSmallDIsable")
            imgConnectionStatus.isHidden = true
            imgConnecting.image = UIImage(named: "imgHubOff")
        }
    }
}
