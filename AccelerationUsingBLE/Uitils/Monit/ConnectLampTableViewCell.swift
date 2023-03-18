//
//  BaseConnectLampTableViewCell.swift
//  Monit
//
//  Created by john.lee on 2019. 2. 12..
//  Copyright © 2019년 맥. All rights reserved.
//

import UIKit

class ConnectLampTableViewCell: BaseTableViewCell {
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblDisconnectSummary: UILabel!
    
    @IBOutlet weak var imgConnecting: UIImageView!
    @IBOutlet weak var imgRound: UIImageView?
    @IBOutlet weak var imgConnectionStatus: UIImageView!
    @IBOutlet weak var lblPercent: UILabel?
    @IBOutlet weak var viewFill: UIView?
    @IBOutlet weak var imgNewAlarmLamp: UIImageView!
    
    // connect group
    @IBOutlet weak var viewConnectGroup: UIView!
    
    @IBOutlet weak var lblTempTitle: UILabel!
    @IBOutlet weak var lblTemp: UILabel!
    @IBOutlet weak var lblTempUnit: UILabel?
    @IBOutlet weak var imgNewAlarmTemp: UIImageView!

    @IBOutlet weak var lblHumTitle: UILabel!
    @IBOutlet weak var lblHum: UILabel!
    @IBOutlet weak var imgNewAlarmHum: UIImageView!
    
    var m_detailInfo: DeviceDetailInfo?
    
    var lampStatusInfo: LampStatusInfo? {
        get {
            return DataManager.instance.m_userInfo.deviceStatus.m_lampStatus.getInfoByDeviceId(did: m_detailInfo!.m_did)
        }
    }
    
    var isConnect: Bool {
        get {
            return DataManager.instance.m_dataController.device.m_lamp.isConnect(type: m_detailInfo!.m_deviceType, did: m_detailInfo!.m_did)
        }
    }
    
    var connectStatusImg: String {
        get {
            switch m_detailInfo!.m_deviceType {
            case .myDevice, .otherDevice:
                let _bleInfo = DataManager.instance.m_userInfo.connectLamp.getLampByDeviceId(deviceId: m_detailInfo!.m_did)
                if (_bleInfo != nil) {
                    return "imgConnectStatusBle"
                } else {
                    if let _status = DataManager.instance.m_userInfo.deviceStatus.m_lampStatus.getInfoByDeviceId(did: m_detailInfo!.m_did) {
                        if (_status.isConnect) {
                            return "imgConnectStatusWifi"
                        }
                    }
                }
            default: break
            }
            return ""
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
        if let _statusInfo = lampStatusInfo {
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
            setBright(level: _statusInfo.brightLevel)
            setConnect(isConnect: isConnect)
        } else {
            setConnect(isConnect: false)
            //            lblName.text = "허브"
            //            setTemp(temp: .bad, value: 123)
            //            setHum(hum: .bad, value: 11)
            //            setScore(score: .bad, value: 82)
            //            setConnect(isConnect: true)
        }
        
        lblTitle.text = "device_type_lamp".localized
        lblDisconnectSummary.text = "device_lamp_disconnected".localized
        lblTempTitle.text = "device_environment_temperature".localized
        lblHumTitle.text = "device_environment_humidity".localized
        
        imgNewAlarmLamp.isHidden = true
        if (isConnect) {
            if (DataManager.instance.m_dataController.newAlarm.lampFirmware.isNewAlarmMain(did: m_detailInfo!.m_did)) {
                imgNewAlarmLamp.isHidden = false
            }
        }
        
        imgNewAlarmTemp.isHidden = true
        imgNewAlarmHum.isHidden = true

        if (isNewAlarm(type: .low_temperature) || isNewAlarm(type: .high_temperature)) {
            imgNewAlarmTemp.isHidden = false
        }
        if (isNewAlarm(type: .low_humidity) || isNewAlarm(type: .high_humidity)) {
            imgNewAlarmHum.isHidden = false
        }
    }
    
    func isNewAlarm(type: DEVICE_NOTI_TYPE) -> Bool {
        if (DataManager.instance.m_dataController.newAlarm.noti.isNotiNewAlarm(did: m_detailInfo!.m_did, type: DEVICE_TYPE.Lamp.rawValue, noti: type.rawValue)) {
            return true
        }
        return false
    }
    
    func setBright(level: HUB_TYPES_BRIGHT_TYPE) {
        switch level {
        case .level_1, .level_2, .level_3:
            imgConnecting.image = UIImage(named: "imgHubBright")
        default:
            imgConnecting.image = UIImage(named: "imgHubOn")
        }
    }
    
    func setTemp(temp: HUB_TYPES_TEMP, value: Double) {
        switch temp {
        case .normal:
            lblTemp.textColor = COLOR_TYPE.blue.color
        case .low:
            lblTemp.textColor = COLOR_TYPE.red.color
        case .high:
            lblTemp.textColor = COLOR_TYPE.red.color
        }
        
        let _value = Double(floor(10 * value) / 10)
        lblTemp.text = "\(_value)"
        lblTempUnit?.text = "\(UIManager.instance.temperatureUnitStr)"
    }
    
    func setHum(hum: HUB_TYPES_HUM, value: Double) {
        switch hum {
        case .normal:
            lblHum.textColor = COLOR_TYPE.blue.color
        case .low, .high:
            lblHum.textColor = COLOR_TYPE.red.color
        }
        
        let _value = Double(floor(10 * value) / 10)
        lblHum.text = "\(_value)"
    }
    
    func setConnect(isConnect: Bool) {
        if (isConnect) {
            imgRound?.isHidden = false
            lblPercent?.isHidden = false
            viewFill?.isHidden = false
            viewConnectGroup.isHidden = false
            lblDisconnectSummary.isHidden = true
            imgRound?.image = UIImage(named: "imgRoundSmall")
            imgConnectionStatus.isHidden = false
            imgConnectionStatus.image = UIImage(named: connectStatusImg)
        } else {
            imgRound?.isHidden = false
            lblPercent?.isHidden = true
            viewFill?.isHidden = true
            viewConnectGroup.isHidden = true
            lblDisconnectSummary.isHidden = false
            imgRound?.image = UIImage(named: "imgRoundSmallDIsable")
            imgConnectionStatus.isHidden = true
            imgConnecting.image = UIImage(named: "imgHubOff")
        }
    }
}
