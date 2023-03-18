//
//  DataController_NewAlarm_Noti.swift
//  Monit
//
//  Created by 맥 on 2018. 4. 13..
//  Copyright © 2018년 맥. All rights reserved.
//

import Foundation

class DataController_NewAlarm_HubFirmware {
    // when sensor connect

    func initInfo() {
        if let _allInfo = DataManager.instance.m_userInfo.shareDevice.allInfo {
            for item in _allInfo {
                if (item.type == DEVICE_TYPE.Hub.rawValue) {
                    if (isNeedUpdate(did: item.did, currentFwv: item.fwv)) {
                        if (!isExist(did: item.did)) {
                            let _itemType: [NEW_ALARM_ITEM_TYPE] = [.hubSetupMain_firmwareUpdateMain, .hubSetupMain_firmware, .hubDetail_setup, .deviceMain_hub]
                            DataManager.instance.m_dataController.newAlarm.insertOrUpdateItem(aid: DataManager.instance.m_userInfo.account_id, finalItemType: .hubFirmware, itemType: _itemType, did: item.did, deviceType: DEVICE_TYPE.Hub, extra: nil, time: UI_Utility.nowUTCDate(type: .yyMMdd_HHmmss))
                        }
                    } else {
                        if (isExist(did: item.did)) {
                            deleteAll(did: item.did)
                        }
                    }
                }
            }
        }
    }

    func isExist(did: Int) -> Bool {
        return DataManager.instance.m_userInfo.newAlarm.isExist(info: NewAlarmInfo(id: nil, aid: DataManager.instance.m_userInfo.account_id, did: did, deviceType: DEVICE_TYPE.Hub.rawValue, finalItemType: NEW_ALARM_ITEM_TYPE.hubFirmware.rawValue, itemType: NEW_ALARM_ITEM_TYPE.hubSetupMain_firmwareUpdateMain.rawValue))
    }

    func isNeedUpdate(did: Int, currentFwv: String) -> Bool {
        let _latestVersion = DataManager.instance.m_configData.m_latestHubVersion
        let _currentVersion = currentFwv
        if Utility.isUpdateVersion(latestVersion: _latestVersion, currentVersion: _currentVersion) {
            return true
        }
        return false
    }

    func deleteAll(did: Int) {
        DataManager.instance.m_dataController.newAlarm.deleteItemByFinalItemType(aid: DataManager.instance.m_userInfo.account_id, did: did, deviceType: DEVICE_TYPE.Hub, finalItemType: .hubFirmware)
    }

    func isNewAlarmMain(did: Int) -> Bool {
        return DataManager.instance.m_userInfo.newAlarm.isExist(info: NewAlarmInfo(id: nil, aid: DataManager.instance.m_userInfo.account_id, did: did, deviceType: DEVICE_TYPE.Hub.rawValue, finalItemType: NEW_ALARM_ITEM_TYPE.hubFirmware.rawValue, itemType: NEW_ALARM_ITEM_TYPE.deviceMain_hub.rawValue))
    }

    func isNewAlarmDetailSetup(did: Int) -> Bool {
        return DataManager.instance.m_userInfo.newAlarm.isExist(info: NewAlarmInfo(id: nil, aid: DataManager.instance.m_userInfo.account_id, did: did, deviceType: DEVICE_TYPE.Hub.rawValue, finalItemType: NEW_ALARM_ITEM_TYPE.hubFirmware.rawValue, itemType: NEW_ALARM_ITEM_TYPE.hubDetail_setup.rawValue))
    }

    func isNewAlarmDetailSetupFirmware(did: Int) -> Bool {
        return DataManager.instance.m_userInfo.newAlarm.isExist(info: NewAlarmInfo(id: nil, aid: DataManager.instance.m_userInfo.account_id, did: did, deviceType: DEVICE_TYPE.Hub.rawValue, finalItemType: NEW_ALARM_ITEM_TYPE.hubFirmware.rawValue, itemType: NEW_ALARM_ITEM_TYPE.hubSetupMain_firmware.rawValue))
    }

    func isNewAlarmFirmwarePage(did: Int) -> Bool {
        return DataManager.instance.m_userInfo.newAlarm.isExist(info: NewAlarmInfo(id: nil, aid: DataManager.instance.m_userInfo.account_id, did: did, deviceType: DEVICE_TYPE.Hub.rawValue, finalItemType: NEW_ALARM_ITEM_TYPE.hubFirmware.rawValue, itemType: NEW_ALARM_ITEM_TYPE.hubSetupMain_firmwareUpdateMain.rawValue))
    }

    func deleteNewAlarmMain(did: Int) {
        DataManager.instance.m_dataController.newAlarm.deleteItemByInfo(aid: DataManager.instance.m_userInfo.account_id, did: did, deviceType: DEVICE_TYPE.Hub, finalItemType: .hubFirmware, itemType: .deviceMain_hub)
    }
}

