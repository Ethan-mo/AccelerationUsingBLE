//
//  DataController_NewAlarm_Noti.swift
//  Monit
//
//  Created by 맥 on 2018. 4. 13..
//  Copyright © 2018년 맥. All rights reserved.
//

import Foundation

class DataController_NewAlarm_SensorFirmware {
    // when sensor connect
    func initInfo(did: Int) {
        if (isNeedUpdate(did: did)) {
            if (!isExist(did: did)) {
                let _itemType: [NEW_ALARM_ITEM_TYPE] = [.sensorSetupMain_firmwareUpdateMain, .sensorSetupMain_firmware, .sensorDetail_setup, .deviceMain_sensorDiaper]
                DataManager.instance.m_dataController.newAlarm.insertOrUpdateItem(aid: DataManager.instance.m_userInfo.account_id, finalItemType: .sensorFirmware, itemType: _itemType, did: did, deviceType: DEVICE_TYPE.Sensor, extra: nil, time: UI_Utility.nowUTCDate(type: .yyMMdd_HHmmss))
            }
        } else {
            if (isExist(did: did)) {
                deleteAll(did: did)
            }
        }
    }
    
    func isExist(did: Int) -> Bool {
        return DataManager.instance.m_userInfo.newAlarm.isExist(info: NewAlarmInfo(id: nil, aid: DataManager.instance.m_userInfo.account_id, did: did, deviceType: DEVICE_TYPE.Sensor.rawValue, finalItemType: NEW_ALARM_ITEM_TYPE.sensorFirmware.rawValue, itemType: NEW_ALARM_ITEM_TYPE.sensorSetupMain_firmwareUpdateMain.rawValue))
    }
    
    func isNeedUpdate(did: Int) -> Bool {
        if let _info = DataManager.instance.m_userInfo.connectSensor.getSensorByDeviceId(deviceId: did, isSuccessCheck: true) {
            let _latestVersion = DataManager.instance.m_configData.m_latestSensorVersion
            let _currentVersion = _info.m_firmware
            if Utility.isUpdateVersion(latestVersion: _latestVersion, currentVersion: _currentVersion) {
                return true
            }
        }
        return false
    }
    
    func deleteAll(did: Int) {
        DataManager.instance.m_dataController.newAlarm.deleteItemByFinalItemType(aid: DataManager.instance.m_userInfo.account_id, did: did, deviceType: DEVICE_TYPE.Sensor, finalItemType: .sensorFirmware)
    }
    
    func isNewAlarmMain(did: Int) -> Bool {
        return DataManager.instance.m_userInfo.newAlarm.isExist(info: NewAlarmInfo(id: nil, aid: DataManager.instance.m_userInfo.account_id, did: did, deviceType: DEVICE_TYPE.Sensor.rawValue, finalItemType: NEW_ALARM_ITEM_TYPE.sensorFirmware.rawValue, itemType: NEW_ALARM_ITEM_TYPE.deviceMain_sensorDiaper.rawValue))
    }
    
    func isNewAlarmDetailSetup(did: Int) -> Bool {
        return DataManager.instance.m_userInfo.newAlarm.isExist(info: NewAlarmInfo(id: nil, aid: DataManager.instance.m_userInfo.account_id, did: did, deviceType: DEVICE_TYPE.Sensor.rawValue, finalItemType: NEW_ALARM_ITEM_TYPE.sensorFirmware.rawValue, itemType: NEW_ALARM_ITEM_TYPE.sensorDetail_setup.rawValue))
    }
    
    func isNewAlarmDetailSetupFirmware(did: Int) -> Bool {
        return DataManager.instance.m_userInfo.newAlarm.isExist(info: NewAlarmInfo(id: nil, aid: DataManager.instance.m_userInfo.account_id, did: did, deviceType: DEVICE_TYPE.Sensor.rawValue, finalItemType: NEW_ALARM_ITEM_TYPE.sensorFirmware.rawValue, itemType: NEW_ALARM_ITEM_TYPE.sensorSetupMain_firmware.rawValue))
    }
    
    func isNewAlarmFirmwarePage(did: Int) -> Bool {
        return DataManager.instance.m_userInfo.newAlarm.isExist(info: NewAlarmInfo(id: nil, aid: DataManager.instance.m_userInfo.account_id, did: did, deviceType: DEVICE_TYPE.Sensor.rawValue, finalItemType: NEW_ALARM_ITEM_TYPE.sensorFirmware.rawValue, itemType: NEW_ALARM_ITEM_TYPE.sensorSetupMain_firmwareUpdateMain.rawValue))
    }
    
    func deleteNewAlarmMain(did: Int) {
        DataManager.instance.m_dataController.newAlarm.deleteItemByInfo(aid: DataManager.instance.m_userInfo.account_id, did: did, deviceType: DEVICE_TYPE.Sensor, finalItemType: .sensorFirmware, itemType: .deviceMain_sensorDiaper)
    }
}

