//
//  ConnectSensorTableViewCell.swift
//  Monit
//
//  Created by 맥 on 2017. 9. 14..
//  Copyright © 2017년 맥. All rights reserved.
//

import UIKit

class ConnectSensorTableViewCell: BaseTableViewCell {
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var lblName: UILabel!
  
    @IBOutlet weak var imgConnecting: UIImageView!
    @IBOutlet weak var imgConnectingStatus: UIImageView!
    @IBOutlet weak var imgBattery: UIImageView!
    @IBOutlet weak var lblConnecting: UILabel!
    
    @IBOutlet weak var imgDiaper: UIImageView!
    @IBOutlet weak var imgVocAvg: UIImageView!
    @IBOutlet weak var imgMov: UIImageView!
    
    @IBOutlet weak var lblDiaper: UILabel!
    @IBOutlet weak var lblVocAvg: UILabel!
    @IBOutlet weak var lblMov: UILabel!
    
    @IBOutlet weak var viewConnectGroup: UIView!
    @IBOutlet weak var imgNewAlarmSensor: UIImageView!
    @IBOutlet weak var imgNewAlarmDiaper: UIImageView!

    // connect sensor operation
    @IBOutlet weak var viewSensorOperation: UIView?
    @IBOutlet weak var lblSensorOperation: UILabel?
    @IBOutlet weak var lblSensorOperationBatteryContents: UILabel?
    @IBOutlet weak var viewSensorOperationBattery: UIView!
    @IBOutlet weak var imgSensorOperationBattery: UIImageView!
    @IBOutlet weak var lblSensorOperationBattery: UILabel!
    
    var m_detailInfo: DeviceDetailInfo?
    
    var sensorStatusInfo: SensorStatusInfo? {
        get {
            return DataManager.instance.m_userInfo.deviceStatus.m_sensorStatus.getInfoByDeviceId(did: m_detailInfo!.m_did)
        }
    }
    
    var isAutoMoveDetected: Bool {
        get {
            if (DataManager.instance.m_userInfo.shareDevice.isAlarmStatusSpecific(did: m_detailInfo!.m_did, type: DEVICE_TYPE.Sensor.rawValue, almType: .auto_move_detected) ?? false) {
                if let _sensorStatus = DataManager.instance.m_userInfo.deviceStatus.m_sensorStatus.getInfoByDeviceId(did: m_detailInfo!.m_did) {
                    if (_sensorStatus.isSleep) {
                        return true
                    } else {
                        return false
                    }
                }
            }
            
            return false
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
        if let _sensorStatusInfo = sensorStatusInfo {
            let _whereStr = _sensorStatusInfo.m_whereConn.description
            var _whereConn = ""
            if (_whereStr.count > 1) {
                let _id = String(_whereStr.prefix(_whereStr.count - 1))
                switch (String(_sensorStatusInfo.m_whereConn.description.suffix(1))) {
                case "0" : _whereConn = "/P\(_id)"
                case "2" : _whereConn = "/H\(_id)"
                case "3" : _whereConn = "/U\(_id)"
                default: break
                }
            }

            if (DataManager.instance.m_userInfo.configData.isMaster) {
                lblName.text = "\(_sensorStatusInfo.m_name)-\(_sensorStatusInfo.m_did)\(_whereConn)"
            } else {
                lblName.text = sensorStatusInfo!.m_name
            }
            setDiaperStatus(diaperScore: _sensorStatusInfo.diaperScore)
            setVocAvg(vocAvg: _sensorStatusInfo.vocAvg)
            setMov(mov: _sensorStatusInfo.movement)
            setBattery(battery: _sensorStatusInfo.battery)
            setSensorOperation(operation: _sensorStatusInfo.operation)
            setConnect(isConnect: isConnect)
        } else {
            setConnect(isConnect: false)
        }
        lblTitle.text = "device_type_diaper_sensor".localized
        lblConnecting.text = "device_sensor_disconnected".localized

        imgNewAlarmSensor.isHidden = true
        if (DataManager.instance.m_dataController.newAlarm.sensorFirmware.isNewAlarmMain(did: m_detailInfo!.m_did)) {
            imgNewAlarmSensor.isHidden = false
        }
        
        imgNewAlarmDiaper.isHidden = true
        if (Config.channel == .kc) {
            if (isNewAlarm(type: .pee_detected)
                || isNewAlarm(type: .poo_detected)
                || isNewAlarm(type: .abnormal_detected)
                || isNewAlarm(type: .diaper_changed)
                || isNewAlarm(type: .fart_detected)) {
                imgNewAlarmDiaper.isHidden = false
            }
        } else {
            if (isNewAlarm(type: .diaper_changed)
                || isNewAlarm(type: .diaper_score)) {
                imgNewAlarmDiaper.isHidden = false
            }
        }
        
        if (DataManager.instance.m_userInfo.configData.isBeta) {
            if (isNewAlarm(type: .pee_detected)
                || isNewAlarm(type: .poo_detected)
                || isNewAlarm(type: .abnormal_detected)
                || isNewAlarm(type: .diaper_changed)
                || isNewAlarm(type: .fart_detected)
                || isNewAlarm(type: .diaper_score)) {
                imgNewAlarmDiaper.isHidden = false
            }
        }
    }
    
    func isNewAlarm(type: DEVICE_NOTI_TYPE) -> Bool {
        if (DataManager.instance.m_dataController.newAlarm.noti.isNotiNewAlarm(did: m_detailInfo!.m_did, type: DEVICE_TYPE.Sensor.rawValue, noti: type.rawValue)) {
            return true
        }
        return false
    }

    func setDiaperStatus(diaperScore: SENSOR_DIAPER_SCORE) {
        switch diaperScore {
        case .good:
            imgDiaper.image = UIImage(named: "imgDiaperNormalMain_Brown")
            lblDiaper.text = "device_sensor_diaper_status_normal".localized
            lblDiaper.textColor = COLOR_TYPE.lblGray.color
        case .bad:
            imgDiaper.image = UIImage(named: "imgDiaperWarningMain")
            lblDiaper.text = "device_sensor_diaper_status_soiled".localized
            lblDiaper.textColor = COLOR_TYPE._orange_244_167_119.color
        case .need_changed:
            imgDiaper.image = UIImage(named: "imgDiaperErrorMain")
            lblDiaper.text = "device_sensor_diaper_status_check_diaper".localized
            lblDiaper.textColor = COLOR_TYPE.red.color
        }
    }
    
    func setVocAvg(vocAvg: SENSOR_VOC_AVG) {
        switch vocAvg {
        case .none:
            imgVocAvg.image = UIImage(named: "imgFartNormalMain_Brown")
            lblVocAvg.text = "device_environment_voc_avg_level0".localized
            lblVocAvg.textColor = COLOR_TYPE.lblGray.color
        case .level_1:
            imgVocAvg.image = UIImage(named: "imgFartWarningMain")
            lblVocAvg.text = "device_environment_voc_avg_level1".localized
            lblVocAvg.textColor = COLOR_TYPE._orange_244_167_119.color
        case .level_2:
            imgVocAvg.image = UIImage(named: "imgFartWarningMain")
            lblVocAvg.text = "device_environment_voc_avg_level2".localized
            lblVocAvg.textColor = COLOR_TYPE._orange_244_167_119.color
        case .level_3:
            imgVocAvg.image = UIImage(named: "imgFartErrorMain")
            lblVocAvg.text = "device_environment_voc_avg_level3".localized
            lblVocAvg.textColor = COLOR_TYPE.red.color
        case .level_4:
            imgVocAvg.image = UIImage(named: "imgFartBlackMain")
            lblVocAvg.text = "device_environment_voc_avg_level4".localized
            lblVocAvg.textColor = COLOR_TYPE.lblDarkGray.color
        }
    }
    
    func setMov(mov: SENSOR_MOVEMENT) {
        switch mov {
        case .none:
            imgMov.image = UIImage(named: "imgMoveNormalMain")
            lblMov.text = "movement_not_moving".localized
            lblMov.textColor = COLOR_TYPE.lblGray.color
        case .level_1:
            imgMov.image = UIImage(named: "imgMoveNormalMain")
            lblMov.text = "device_sensor_movement_sleeping".localized
            lblMov.textColor = COLOR_TYPE.lblGray.color
        case .level_2:
            imgMov.image = UIImage(named: "imgMoveNormalMain")
            lblMov.text = "device_sensor_movement_crawling".localized
            lblMov.textColor = COLOR_TYPE.lblGray.color
        case .level_3:
            imgMov.image = UIImage(named: "imgMoveNormalMain")
            lblMov.text = "device_sensor_movement_running".localized
            lblMov.textColor = COLOR_TYPE.lblGray.color
        }
        
        if (isAutoMoveDetected) {
            imgMov.image = UIImage(named: "imgMoveNormalMain")
            lblMov.text = "device_sensor_movement_sleeping".localized
            lblMov.textColor = COLOR_TYPE.lblGray.color
        }
    }
    
    func setBattery(battery: SENSOR_BATTERY_STATUS) {
        lblSensorOperationBattery?.textColor = COLOR_TYPE.purple.color
        
        switch battery {
        case ._0: imgBattery.image = UIImage(named: "imgBatteryV2_0")
        case ._10: imgBattery.image = UIImage(named: "imgBatteryV2_10")
        case ._20: imgBattery.image = UIImage(named: "imgBatteryV2_20")
        case ._30: imgBattery.image = UIImage(named: "imgBatteryV2_30")
        case ._40: imgBattery.image = UIImage(named: "imgBatteryV2_40")
        case ._50: imgBattery.image = UIImage(named: "imgBatteryV2_50")
        case ._60: imgBattery.image = UIImage(named: "imgBatteryV2_60")
        case ._70: imgBattery.image = UIImage(named: "imgBatteryV2_70")
        case ._80: imgBattery.image = UIImage(named: "imgBatteryV2_80")
        case ._90: imgBattery.image = UIImage(named: "imgBatteryV2_90")
        case ._100: imgBattery.image = UIImage(named: "imgBatteryV2_100")
        case .charging: imgBattery.image = UIImage(named: "imgBatteryV2_Charging")
        case .full: imgBattery.image = UIImage(named: "imgBatteryV2_Full")
        }
        
        switch battery {
        case ._0: imgSensorOperationBattery?.image = UIImage(named: "imgBatteryV2_0")
        case ._10: imgSensorOperationBattery?.image = UIImage(named: "imgBatteryV2_10")
        case ._20: imgSensorOperationBattery?.image = UIImage(named: "imgBatteryV2_20")
        case ._30: imgSensorOperationBattery?.image = UIImage(named: "imgBatteryV2_30")
        case ._40: imgSensorOperationBattery?.image = UIImage(named: "imgBatteryV2_40")
        case ._50: imgSensorOperationBattery?.image = UIImage(named: "imgBatteryV2_50")
        case ._60: imgSensorOperationBattery?.image = UIImage(named: "imgBatteryV2_60")
        case ._70: imgSensorOperationBattery?.image = UIImage(named: "imgBatteryV2_70")
        case ._80: imgSensorOperationBattery?.image = UIImage(named: "imgBatteryV2_80")
        case ._90: imgSensorOperationBattery?.image = UIImage(named: "imgBatteryV2_90")
        case ._100: imgSensorOperationBattery?.image = UIImage(named: "imgBatteryV2_100")
        case .charging: imgSensorOperationBattery?.image = UIImage(named: "imgBatteryV2_Charging")
        case .full: imgSensorOperationBattery?.image = UIImage(named: "imgBatteryV2_Full")
        }
        
        if let _battery = sensorStatusInfo?.m_battery {
            if (Int(_battery / 100) == 100 ) {
                lblSensorOperationBattery?.text = "device_sensor_operation_fully_charged".localized
            } else {
                lblSensorOperationBattery?.text = "\((Int(_battery / 100)).description)%"
            }
            
            if (_battery < 20) {
                lblSensorOperationBattery?.textColor = COLOR_TYPE.red.color
            }
        }
    }
    
    func setSensorOperation(operation: SENSOR_OPERATION) {
        viewConnectGroup.isHidden = true
        viewSensorOperation?.isHidden = true
        viewSensorOperationBattery?.isHidden = true
        imgBattery.isHidden = true
        lblSensorOperation?.isHidden = true // 배터리 아이콘 숨길때
        lblSensorOperationBatteryContents?.isHidden = true // 배터리 아이콘 보여줄때
        switch operation {
        case .idle: // 대기중
            lblSensorOperation?.text = "device_sensor_diaper_status_idle_detail".localized
            lblSensorOperation?.isHidden = false
            viewSensorOperation?.isHidden = false
        case .cableCharging, // 충전중
             .hubCharging,
             .cableChargeError,
             .hubChargeError:
            lblSensorOperationBatteryContents?.text = "device_sensor_diaper_status_charging_detail".localized
            lblSensorOperationBatteryContents?.isHidden = false
            viewSensorOperation?.isHidden = false
            viewSensorOperationBattery?.isHidden = false
        case .cableFinishedCharge, // 충전완료
             .hubFinishedCharge:
            lblSensorOperationBatteryContents?.text = "device_sensor_diaper_status_charged_detail".localized
            lblSensorOperationBatteryContents?.isHidden = false
            viewSensorOperation?.isHidden = false
            viewSensorOperationBattery?.isHidden = false
        default: // 그외
            viewConnectGroup.isHidden = false
            imgBattery.isHidden = false
        }
    }
    
    func setConnect(isConnect: Bool) {
        if (isConnect) {
            imgConnecting.image = UIImage(named: "imgSensorOn")
            lblConnecting.isHidden = true
            imgConnectingStatus.isHidden = false
            imgConnectingStatus.image = UIImage(named: connectStatusImg)
        } else {
            viewConnectGroup.isHidden = true
            imgConnecting.image = UIImage(named: "imgSensorOff")
            lblConnecting.isHidden = false
            imgConnectingStatus.isHidden = true
            imgBattery.isHidden = true
            viewSensorOperation?.isHidden = true
        }
    }
}
