//
//  ConnectSensorTableViewCell.swift
//  Monit
//
//  Created by 맥 on 2017. 9. 14..
//  Copyright © 2017년 맥. All rights reserved.
//

import UIKit

class ConnectSensorForKcTableViewCell: BaseTableViewCell {
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var lblName: UILabel!
  
    @IBOutlet weak var imgConnecting: UIImageView!
    @IBOutlet weak var imgConnectingStatus: UIImageView!
    @IBOutlet weak var imgSensing: UIImageView!
    @IBOutlet weak var imgDiaper: UIImageView!
    @IBOutlet weak var imgBattery: UIImageView!
    
    @IBOutlet weak var lblConnecting: UILabel!
    @IBOutlet weak var lblSensing: UILabel!
    @IBOutlet weak var lblDiaper: UILabel!
    @IBOutlet weak var lblBattery: UILabel!
    
    @IBOutlet weak var viewConnectGroup: UIView!
    @IBOutlet weak var imgNewAlarmSensor: UIImageView!
    @IBOutlet weak var imgNewAlarmDiaper: UIImageView!
    
    var m_detailInfo: DeviceDetailInfo?
    
    var sensorStatusInfo: SensorStatusInfo? {
        get {
            return DataManager.instance.m_userInfo.deviceStatus.m_sensorStatus.getInfoByDeviceId(did: m_detailInfo!.m_did)
        }
    }
    
    var isConnect: Bool {
        get {
            return DataManager.instance.m_dataController.device.m_sensor.isSensorConnect(type: m_detailInfo!.m_deviceType, did: m_detailInfo!.m_did)
        }
    }
    
    var connectStatusImg: String {
        get {
            switch m_detailInfo!.m_deviceType {
            case .myDevice, .otherDevice:
                let _bleInfo = DataManager.instance.m_userInfo.connectSensor.getSensorByDeviceId(deviceId: m_detailInfo!.m_did)
                if (_bleInfo != nil) {
                    return "imgConnectStatusBle"
                } else {
                    if let _status = DataManager.instance.m_userInfo.deviceStatus.m_sensorStatus.getInfoByDeviceId(did: m_detailInfo!.m_did) {
                        if (_status.con == 1) {
                            return "imgConnectStatusWifi"
                        }
                    }
                }
            default: break
            }
            return ""
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setInit() {
        if (sensorStatusInfo != nil) {
            let _whereStr = sensorStatusInfo!.m_whereConn.description
            var _whereConn = ""
            if (_whereStr.count > 1) {
                let _id = String(_whereStr.prefix(_whereStr.count - 1))
                switch (String(sensorStatusInfo!.m_whereConn.description.suffix(1))) {
                case "0" : _whereConn = "/P\(_id)"
                case "2" : _whereConn = "/H\(_id)"
                case "3" : _whereConn = "/U\(_id)"
                default: break
                }
            }

            if (DataManager.instance.m_userInfo.configData.isMaster) {
                lblName.text = "\(sensorStatusInfo!.m_name)-\(sensorStatusInfo!.m_did)\(_whereConn)"
            } else {
                lblName.text = sensorStatusInfo!.m_name
            }
            setDiaperStatus(diaperStatus: sensorStatusInfo!.diaperStatus)
            setBattery(battery: sensorStatusInfo!.battery)
            setOperation(operation: sensorStatusInfo!.operation)
            setConnect(isConnect: isConnect)
        }
        lblTitle.text = "device_type_diaper_sensor".localized
        lblConnecting.text = "device_sensor_disconnected".localized

        imgNewAlarmSensor.isHidden = true
        if (DataManager.instance.m_dataController.newAlarm.sensorFirmware.isNewAlarmMain(did: m_detailInfo!.m_did)) {
            imgNewAlarmSensor.isHidden = false
        }
        
        imgNewAlarmDiaper.isHidden = true
        if (isNewAlarm(type: .pee_detected)
            || isNewAlarm(type: .poo_detected)
            || isNewAlarm(type: .abnormal_detected)
            || isNewAlarm(type: .diaper_changed)
            || isNewAlarm(type: .fart_detected)) {
            imgNewAlarmDiaper.isHidden = false
        }
    }
    
    func isNewAlarm(type: DEVICE_NOTI_TYPE) -> Bool {
        if (DataManager.instance.m_dataController.newAlarm.noti.isNotiNewAlarm(did: m_detailInfo!.m_did, type: DEVICE_TYPE.Sensor.rawValue, noti: type.rawValue)) {
            return true
        }
        return false
    }

    func setDiaperStatus(diaperStatus: SENSOR_DIAPER_STATUS) {
        switch diaperStatus {
        case .normal:
            imgDiaper.image = UIImage(named: "imgDiaperNormalMain")
            lblDiaper.text = "device_sensor_diaper_status_normal".localized
            lblDiaper.textColor = COLOR_TYPE.lblGray.color
        case .pee:
            imgDiaper.image = UIImage(named: "imgPeeErrorMain")
            lblDiaper.text = "device_sensor_diaper_status_pee".localized
            lblDiaper.textColor = COLOR_TYPE.red.color
        case .poo:
            imgDiaper.image = UIImage(named: "imgPooErrorMain")
            lblDiaper.text = "device_sensor_diaper_status_poo".localized
            lblDiaper.textColor = COLOR_TYPE.red.color
        case .hold:
            imgDiaper.image = UIImage(named: "imgWarningErrorMain")
            lblDiaper.text = "device_sensor_diaper_status_abnormal".localized
            lblDiaper.textColor = COLOR_TYPE.red.color
        case .maxvoc:
            imgDiaper.image = UIImage(named: "imgWarningErrorMain")
            lblDiaper.text = "device_sensor_diaper_status_abnormal".localized
            lblDiaper.textColor = COLOR_TYPE.red.color
        case .fart:
            imgDiaper.image = UIImage(named: "imgFartErrorMain")
            lblDiaper.text = "device_sensor_diaper_status_fart".localized
            lblDiaper.textColor = COLOR_TYPE.red.color
        case .detectDiaperChanged,
             .attachSensor:
            break
        }
    }
    
    func setOperation(operation: SENSOR_OPERATION) {
        imgSensing.image = UIImage(named: "imgConnectReadyMain")
        lblSensing.text = "device_sensor_operation_idle".localized
        
        switch operation {
        case .none,
             .cableNoCharge,
             .hubNoCharge:
            imgSensing.image = UIImage(named: "imgConnectSensingMain")
            lblSensing.text = "device_sensor_operation_sensing".localized
        case .idle:
            imgSensing.image = UIImage(named: "imgConnectReadyMain")
            lblSensing.text = "device_sensor_operation_idle".localized
        case .sensing:
            imgSensing.image = UIImage(named: "imgConnectSensingMain")
            lblSensing.text = "device_sensor_operation_sensing".localized
        case .diaperChanged:
            imgSensing.image = UIImage(named: "imgConnectAnalyzingMain")
            lblSensing.text = "\("device_sensor_operation_analyzing".localized)"
        case .avoidSensing:
            imgSensing.image = UIImage(named: "imgConnectAnalyzingMain")
            lblSensing.text = "\("device_sensor_operation_analyzing".localized)!"
        case .cableCharging,
             .cableFinishedCharge,
             .cableChargeError,
             .hubCharging,
             .hubFinishedCharge,
             .hubChargeError:
            imgSensing.image = UIImage(named: "imgConnectSensingMain")
            lblSensing.text = "device_sensor_operation_charging".localized
            
            // diaper info
            imgDiaper.image = UIImage(named: "imgDiaperDisableMain")
            lblDiaper.text = ""
        default: break
        }
    }
    
    func setBattery(battery: SENSOR_BATTERY_STATUS) {
        lblBattery.isHidden = false
        lblBattery.textColor = COLOR_TYPE.lblGray.color
        
        switch battery {
        case ._0: imgBattery.image = UIImage(named: "imgBattery0")
        case ._10: imgBattery.image = UIImage(named: "imgBattery10")
        case ._20: imgBattery.image = UIImage(named: "imgBattery20")
        case ._30: imgBattery.image = UIImage(named: "imgBattery30")
        case ._40: imgBattery.image = UIImage(named: "imgBattery40")
        case ._50: imgBattery.image = UIImage(named: "imgBattery50")
        case ._60: imgBattery.image = UIImage(named: "imgBattery60")
        case ._70: imgBattery.image = UIImage(named: "imgBattery70")
        case ._80: imgBattery.image = UIImage(named: "imgBattery80")
        case ._90: imgBattery.image = UIImage(named: "imgBattery90")
        case ._100: imgBattery.image = UIImage(named: "imgBattery100")
        case .charging: imgBattery.image = UIImage(named: "imgBatteryCharging")
        case .full: imgBattery.image = UIImage(named: "imgBatteryFull")
        }
        
        if let _battery = sensorStatusInfo?.m_battery {
            lblBattery.text = "\((Int(_battery / 100)).description)%"
            
            if (_battery < 20) {
                lblBattery.textColor = COLOR_TYPE.red.color
            }
        }
    }
    
    func setConnect(isConnect: Bool) {
        if (isConnect) {
            viewConnectGroup.isHidden = false
            imgConnecting.image = UIImage(named: "imgSensorOn")
            lblConnecting.isHidden = true
            imgConnectingStatus.isHidden = false
            imgConnectingStatus.image = UIImage(named: connectStatusImg)
        } else {
            viewConnectGroup.isHidden = true
            imgConnecting.image = UIImage(named: "imgSensorOff")
            lblConnecting.isHidden = false
            imgConnectingStatus.isHidden = true
        }
    }
}
