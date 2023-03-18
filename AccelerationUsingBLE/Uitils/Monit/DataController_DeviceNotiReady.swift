//
//  DataController_DeviceNotiReady.swift
//  Monit
//
//  Created by john.lee on 2019. 1. 2..
//  Copyright © 2019년 맥. All rights reserved.
//

import Foundation

class DataController_DeviceNotiReady {
    func setInit() {
        loadCoreDataToLocal()
    }
    
    func loadCoreDataToLocal() {
        let _arrData = DataManager.instance.m_coreDataInfo.storeDeviceNotiReady.load()
        DataManager.instance.m_coreDataInfo.storeDeviceNotiReady.lastId = lastId(arrData: _arrData)
        DataManager.instance.m_userInfo.deviceNotiReady.m_deviceNotiReady = _arrData!
    }
    
    func lastId(arrData: [DeviceNotiReadyInfo]?) -> Int {
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
    
    func sendReadyInfo() {
        if (DataManager.instance.m_userInfo.deviceNotiReady.isSending) {
            for item in DataManager.instance.m_userInfo.deviceNotiReady.m_deviceNotiReady {
                guard (Int64(item.m_time) != nil) else {
                    Debug.print("Resend Sensor Packet is null: did \(item.m_did), dps \(item.m_noti), time \(item.m_time)", event: .error)
                    self.deleteItems(items: [item])
                    continue
                }
    
                guard (Int64(Utility.timeStamp) - Int64(item.m_time)! < 600) else {
                    Debug.print("Resend Sensor Packet over: did \(item.m_did), dps \(item.m_noti), time \(item.m_time) nowtime \(Int64(Utility.timeStamp))", event: .warning)
                    self.deleteItems(items: [item])
                    continue
                }
                
                DataManager.instance.m_dataController.device.m_sensor.sendDeviceStatus(did: item.m_did, dps: item.m_noti, mov: 0, opr: 0, isChangeDps: true, isChangeMov: false, isChangeOpr: false, timeStamp: Int64(item.m_time)!, dTimeStamp: nil, handler: { (success) in
                    if (success) {
                        Debug.print("Resend Sensor Packet success: did \(item.m_did), dps \(item.m_noti), time \(item.m_time)", event: .warning)
                        self.deleteItems(items: [item])
                    } else {
                        Debug.print("Resend Sensor Packet fail: did \(item.m_did), dps \(item.m_noti), time \(item.m_time)", event: .warning)
                    }
                })
            }
        }
    }
    
    func addItems(items: [DeviceNotiReadyInfo]?, isBackground: Bool = false) {
        guard (items != nil) else { return }
        
        let _entity = DataManager.instance.m_coreDataInfo.getEntity(name: DataManager.instance.m_coreDataInfo.storeDeviceNotiReady.m_entityName)
        for item in items! {
            if (!DataManager.instance.m_userInfo.deviceNotiReady.isExist(item: item)) {
                item.m_id = DataManager.instance.m_coreDataInfo.storeDeviceNotiReady.addItemToEntity(entity: _entity!, item: item, isBackground: isBackground)
                DataManager.instance.m_userInfo.deviceNotiReady.addNoti(arr: [item])
            }
        }
        if (isBackground) {
            DataManager.instance.m_coreDataInfo.backgroundSaveData()
        } else {
            DataManager.instance.m_coreDataInfo.saveData()
        }
    }
    
    func deleteItems(items: [DeviceNotiReadyInfo]) {
        for item in items {
            DataManager.instance.m_coreDataInfo.storeDeviceNotiReady.deleteItemsById(id: item.m_id)
            DataManager.instance.m_userInfo.deviceNotiReady.deleteItemById(id: item.m_id)
        }
    }
}
