//
//  DataController_DeviceNoti.swift
//  Monit
//
//  Created by 맥 on 2017. 9. 27..
//  Copyright © 2017년 맥. All rights reserved.
//

import Foundation
import SwiftyJSON

// id를 발급하기 위해 코어데이터에 먼저 삽입 후, 런타임 데이터에 저장한다.
class DataController_DeviceNoti {
    
    var m_updateAction: Action?

    func setInit() {
        loadCoreDataToLocal()
        setUpdate(updateAction: nil)
    }
    
    func loadCoreDataToLocal() {
//        DataManager.instance.m_coreDataInfo.storeDeviceNoti.deleteOldData()
        let _arrData = DataManager.instance.m_coreDataInfo.storeDeviceNoti.load() // class 생성시 어떤게 비용 많이 먹는지 체크.
//        DataManager.instance.m_coreDataInfo.storeDeviceNoti.lastId = lastId(arrData: _arrData)
//        DataManager.instance.m_userInfo.deviceNoti.m_deviceNoti = _arrData!
    }

    func lastId(arrData: [DeviceNotiInfo]?) -> Int {
        var _retValue = 0
        if let _list = arrData {
            for item in _list {
                if (_retValue < item.m_id) {
                    _retValue = item.m_id
                }
            }
        }
        return _retValue
    }
    
    func setUpdate(updateAction: Action?) {
        self.m_updateAction = updateAction

        update(handler: { (arrNotiInfo) -> () in
            self.saveData(arrNotiInfo: arrNotiInfo)
            self.m_updateAction?()
        })
    }
    
    func saveData(arrNotiInfo: Array<DeviceNotiInfo>?) {
        if let _arrNotiInfo = arrNotiInfo {
            addItems(items: _arrNotiInfo)
            var _sensor = [Int]()
            var _hub = [Int]()
            var _lamp = [Int]()
            for item in _arrNotiInfo {
                if ((!_sensor.contains(item.m_did)) && item.m_type == DEVICE_TYPE.Sensor.rawValue) {
                    _sensor.append(item.m_did)
                }
                if ((!_sensor.contains(item.m_did)) && item.m_type == DEVICE_TYPE.Hub.rawValue) {
                    _hub.append(item.m_did)
                }
                if ((!_lamp.contains(item.m_did)) && item.m_type == DEVICE_TYPE.Lamp.rawValue) {
                    _lamp.append(item.m_did)
                }
            }
            for item in _sensor {
                DataManager.instance.m_dataController.newAlarm.noti.initNotiNewAlarm(did: item, type: DEVICE_TYPE.Sensor.rawValue)
            }
            for item in _hub {
                DataManager.instance.m_dataController.newAlarm.noti.initNotiNewAlarm(did: item, type: DEVICE_TYPE.Hub.rawValue)
            }
            for item in _lamp {
                DataManager.instance.m_dataController.newAlarm.noti.initNotiNewAlarm(did: item, type: DEVICE_TYPE.Lamp.rawValue)
            }
        }
    }
    
    func addItem(item: DeviceNotiInfo, isBackground: Bool = false) {
        let _entity = DataManager.instance.m_coreDataInfo.getEntity(name: DataManager.instance.m_coreDataInfo.storeDeviceNoti.m_entityName)
        if (DataManager.instance.m_userInfo.deviceNoti.isExist(item: item)) {
            DataManager.instance.m_coreDataInfo.storeDeviceNoti.updateItemByNid(nid: item.m_nid, noti: item.m_noti, extra: item.Extra, extra2: item.m_extra2, extra3: item.m_extra3, extra4: item.m_extra4, extra5: item.m_extra5, memo: item.m_memo, time: item.Time, finishTime: item.FinishTime)
            DataManager.instance.m_userInfo.deviceNoti.setNotiUpdateByNid(nid: item.m_nid, noti: item.m_noti, extra: item.Extra, extra2: item.m_extra2, extra3: item.m_extra3, extra4: item.m_extra4, extra5: item.m_extra5, memo: item.m_memo, time: item.Time, finishTime: item.FinishTime)
        } else {
            item.m_id = DataManager.instance.m_coreDataInfo.storeDeviceNoti.addItemToEntity(entity: _entity!, item: item, isBackground: isBackground)
            tagManager(item: item)
            DataManager.instance.m_userInfo.deviceNoti.addNoti(arr: [item])
        }

        if (isBackground) {
            DataManager.instance.m_coreDataInfo.backgroundSaveData()
        } else {
            DataManager.instance.m_coreDataInfo.saveData()
        }
    }
    
    func addItems(items: [DeviceNotiInfo], isBackground: Bool = false) {
        let _entity = DataManager.instance.m_coreDataInfo.getEntity(name: DataManager.instance.m_coreDataInfo.storeDeviceNoti.m_entityName)
        for item in items {
            if (DataManager.instance.m_userInfo.deviceNoti.isExist(item: item)) {
                DataManager.instance.m_coreDataInfo.storeDeviceNoti.updateItemByNid(nid: item.m_nid, noti: item.m_noti, extra: item.Extra, extra2: item.m_extra2, extra3: item.m_extra3, extra4: item.m_extra4, extra5: item.m_extra5, memo: item.m_memo, time: item.Time, finishTime: item.FinishTime)
                DataManager.instance.m_userInfo.deviceNoti.setNotiUpdateByNid(nid: item.m_nid, noti: item.m_noti, extra: item.Extra, extra2: item.m_extra2, extra3: item.m_extra3, extra4: item.m_extra4, extra5: item.m_extra5, memo: item.m_memo, time: item.Time, finishTime: item.FinishTime)
            } else {
                item.m_id = DataManager.instance.m_coreDataInfo.storeDeviceNoti.addItemToEntity(entity: _entity!, item: item, isBackground: isBackground)
                tagManager(item: item)
                DataManager.instance.m_userInfo.deviceNoti.addNoti(arr: [item])
            }
        }
        if (isBackground) {
            DataManager.instance.m_coreDataInfo.backgroundSaveData()
        } else {
            DataManager.instance.m_coreDataInfo.saveData()
        }
    }
    
    func tagManager(item: DeviceNotiInfo) {
        switch NotificationType(rawValue: item.m_noti)
        {
        case .PEE_DETECTED:
            ScreenAnalyticsManager.instance.googleTagManagerCustom(type: .sensor_alarm_pee_detected, items: ["sensorid_\(item.m_did)" : item.Time])
            break
        case .POO_DETECTED:
            ScreenAnalyticsManager.instance.googleTagManagerCustom(type: .sensor_alarm_poo_detected, items: ["sensorid_\(item.m_did)" : item.Time])
            break
        case .FART_DETECTED:
            ScreenAnalyticsManager.instance.googleTagManagerCustom(type: .sensor_alarm_fart_detected, items: ["sensorid_\(item.m_did)" : item.Time])
            break
        case .DIAPER_CHANGED:
            ScreenAnalyticsManager.instance.googleTagManagerCustom(type: .sensor_alarm_diaper_changed, items: ["sensorid_\(item.m_did)" : item.Time])
            break
        default:
            break
        }
        
        if let _type = DEVICE_TYPE(rawValue: item.m_type) {
            if (_type == .Hub) {
                switch NotificationType(rawValue: item.m_noti)
                {
                case .HIGH_TEMPERATURE:
                    ScreenAnalyticsManager.instance.googleTagManagerCustom(type: .hub_alarm_high_temperature_detected, items: ["hubid_\(item.m_did)" : item.Time])
                    break
                case .LOW_TEMPERATURE:
                    ScreenAnalyticsManager.instance.googleTagManagerCustom(type: .hub_alarm_low_temperature_detected, items: ["hubid_\(item.m_did)" : item.Time])
                    break
                case .HIGH_HUMIDITY:
                    ScreenAnalyticsManager.instance.googleTagManagerCustom(type: .hub_alarm_high_humidity_detected, items: ["hubid_\(item.m_did)" : item.Time])
                    break
                case .LOW_HUMIDITY:
                    ScreenAnalyticsManager.instance.googleTagManagerCustom(type: .hub_alarm_low_humidity_detected, items: ["hubid_\(item.m_did)" : item.Time])
                    break
                default:
                    break
                }
            } else if (_type == .Lamp) {
                switch NotificationType(rawValue: item.m_noti)
                {
                case .HIGH_TEMPERATURE:
                    ScreenAnalyticsManager.instance.googleTagManagerCustom(type: .lamp_alarm_high_temperature_detected, items: ["lampid_\(item.m_did)" : item.Time])
                    break
                case .LOW_TEMPERATURE:
                    ScreenAnalyticsManager.instance.googleTagManagerCustom(type: .lamp_alarm_low_temperature_detected, items: ["lampid_\(item.m_did)" : item.Time])
                    break
                case .HIGH_HUMIDITY:
                    ScreenAnalyticsManager.instance.googleTagManagerCustom(type: .lamp_alarm_high_humidity_detected, items: ["lampid_\(item.m_did)" : item.Time])
                    break
                case .LOW_HUMIDITY:
                    ScreenAnalyticsManager.instance.googleTagManagerCustom(type: .lamp_alarm_low_humidity_detected, items: ["lampid_\(item.m_did)" : item.Time])
                    break
                default:
                    break
                }
            }
        }
    }

    func update(handler: @escaping (Array<DeviceNotiInfo>?) -> Void) {
//        DataManager.instance.m_userInfo.configData.isNotiNidUpdate = false // test
        
        // nid update.
        if (!DataManager.instance.m_userInfo.configData.isNotiNidUpdate) {
            if (DataManager.instance.m_userInfo.deviceNoti.m_deviceNoti.count == 0) {
                DataManager.instance.m_userInfo.configData.isNotiNidUpdate = true
            } else {
                if (DataManager.instance.m_userInfo.deviceNoti.isNidUpdate) {
                    nidUpdate(handler: handler)
                    return
                } else {
                    DataManager.instance.m_userInfo.configData.isNotiNidUpdate = true
                }
            }
        }
        
        // normal update.
        let send = Send_GetNotification()
        send.isErrorPopupOn = false
        send.isIndicator = false
        send.aid = DataManager.instance.m_userInfo.account_id
        send.token = DataManager.instance.m_userInfo.token
        send.time = UI_Utility.convertDateToString(DataManager.instance.m_userInfo.deviceNoti.m_lastTime, type: .yyMMdd_HHmmss)
        NetworkManager.instance.Request(send) { (json) -> () in
            self.receiveGetNotification(json, handler: handler)
        }
    }
    
    func nidUpdate(handler: @escaping (Array<DeviceNotiInfo>?) -> Void) {
        if let _firstTime = DataManager.instance.m_userInfo.deviceNoti.m_firstTime {
            let send = Send_GetNotification()
            send.isErrorPopupOn = false
            send.isIndicator = false
            send.aid = DataManager.instance.m_userInfo.account_id
            send.token = DataManager.instance.m_userInfo.token
            send.time = UI_Utility.convertDateToString(_firstTime, type: .yyMMdd_HHmmss)
            send.is_full = 1
            NetworkManager.instance.Request(send) { (json) -> () in
                self.receiveGetNotification(json, handler: handler)
                DataManager.instance.m_userInfo.configData.isNotiNidUpdate = true
            }
        }
    }
    
    func receiveGetNotification(_ json: JSON, handler: @escaping (Array<DeviceNotiInfo>?) -> Void) {
        let receive = Receive_GetNotification(json)
        switch receive.ecd {
        case .success: handler(receive.notification)
        default:
            Debug.print("[ERROR] invaild errcod", event: .error)
            handler(nil)
        }
    }

    func updateForDetailView(finishHandler: Action? = nil, isReload: Bool = true) {
        setUpdate(updateAction: { () -> () in
            self.sendUpdateEdit(finishHandler: finishHandler)
            if (isReload) {
                UIManager.instance.currentUIReload()
            }
        })
//        // detail 페이지에 있을때, 기기 별로 가져옴.
//        if let _currentView = UIManager.instance.rootCurrentView {
//            if let _view = _currentView as? DeviceSensorDetailViewController {
//                _view.reloadNoti()
//            }
//            if let _view = _currentView as? DeviceHubDetailViewController {
//                _view.reloadNoti()
//            }
//        }
    }

    var m_isNotiUpdating = false
    func updateByDid(did: Int, type: Int) {
        if (m_isNotiUpdating) {
            Debug.print("isNotiUpdating..", event: .warning)
            return
        }
        
        self.m_isNotiUpdating = true
        sendUpdateByDid(did: did, type: type, handler: { (arrNotiInfo) -> () in
            if let _arrNotiInfo = arrNotiInfo {
                if (_arrNotiInfo.count > 0) {
                    if (_arrNotiInfo.count > 30) {
                        let _progress = UIManager.instance.progressView(title: "toast_noti_loading".localized)
                        DispatchQueue.global(qos: .background).async {
                            for (i, item) in _arrNotiInfo.enumerated() {
//                                Thread.sleep(forTimeInterval: 0.0001)
                                self.addItem(item: item, isBackground: true)
                                DispatchQueue.main.async(flags: .barrier) {
                                    _progress.progressValue =  Float(i) / Float(_arrNotiInfo.count)
                                }
                            }
                            DispatchQueue.main.async {
                                _progress.progressValue = 1
                                _progress.close()
                            }
                            self.m_isNotiUpdating = false
                            UIManager.instance.currentUIReload()
                        }
                    } else {
                        for item in _arrNotiInfo {
                            self.addItem(item: item)
                        }
                        self.m_isNotiUpdating = false
                        UIManager.instance.currentUIReload()
                    }
                } else {
                    self.m_isNotiUpdating = false
                }
            } else {
                self.m_isNotiUpdating = false
            }
        })
    }

    func sendUpdateByDid(did: Int, type: Int, handler: @escaping (Array<DeviceNotiInfo>?) -> Void) {
        let send = Send_GetNotification()
        send.isErrorPopupOn = false
        send.isIndicator = false
        send.aid = DataManager.instance.m_userInfo.account_id
        send.type = type
        send.did = did
        send.token = DataManager.instance.m_userInfo.token
        send.time = UI_Utility.convertDateToString(DataManager.instance.m_userInfo.deviceNoti.getLastTimeByDid(type: type ,did: did), type: .yyMMdd_HHmmss)
        NetworkManager.instance.Request(send) { (json) -> () in
            let receive = Receive_GetNotification(json)
            switch receive.ecd {
            case .success: handler(receive.notification)
            default:
                Debug.print("[ERROR] invaild errcod", event: .error)
                handler(nil)
            }
        }
    }
    
    func sendUpdateEdit(finishHandler: Action? = nil) {
        let send = Send_GetNotificationEdit()
        send.isErrorPopupOn = false
        send.isIndicator = false
        send.aid = DataManager.instance.m_userInfo.account_id
        send.token = DataManager.instance.m_userInfo.token
        send.time = DataManager.instance.m_userInfo.configData.notificationEditTime
        NetworkManager.instance.Request(send) { (json) -> () in
            let receive = Receive_GetNotificationEdit(json)
            switch receive.ecd {
            case .success:
                self.editInfo(lstInfo: receive.notification)
                finishHandler?()
            default:
                Debug.print("[ERROR] invaild errcod", event: .error)
            }
        }
    }

    func editInfo(lstInfo: [DeviceNotiEditInfo]) {
        for item in lstInfo {
            if (item.m_edit_type == NOTI_EDIT_TYPE.delete.rawValue) {
                DataManager.instance.m_coreDataInfo.storeDeviceNoti.deleteItemsByNid(nid: item.m_nid)
                DataManager.instance.m_userInfo.deviceNoti.deleteItemByNid(nid: item.m_nid)
            } else if (item.m_edit_type == NOTI_EDIT_TYPE.modify.rawValue) {
                DataManager.instance.m_coreDataInfo.storeDeviceNoti.updateItemByNid(nid: item.m_nid, noti: item.m_noti, extra: item.m_extra, extra2: item.m_extra2, extra3: item.m_extra3, extra4: item.m_extra4, extra5: item.m_extra5, memo: item.m_memo, time: item.m_time, finishTime: item.m_finish_time)
                DataManager.instance.m_userInfo.deviceNoti.setNotiUpdateByNid(nid: item.m_nid, noti: item.m_noti, extra: item.m_extra, extra2: item.m_extra2, extra3: item.m_extra3, extra4: item.m_extra4, extra5: item.m_extra5, memo: item.m_memo, time: item.m_time, finishTime: item.m_finish_time)
            }
        }
        if (lstInfo.count > 0) {
            if let _maxInfo = lstInfo.max(by: { $0.m_created < $1.m_created }) {
                DataManager.instance.m_userInfo.configData.notificationEditTime = _maxInfo.m_created
            }
        }
    }
}
