//
//  DataController_newAlarm.swift
//  Monit
//
//  Created by 맥 on 2017. 9. 27..
//  Copyright © 2017년 맥. All rights reserved.
//

import Foundation
import SwiftyJSON

// id를 발급하기 위해 코어데이터에 먼저 삽입 후, 런타임 데이터에 저장한다.
// finalItemType은 최상위의 부모를 의미 (해당값에 관련된 뉴알림을 찾아서 다 지울 수 있음)
// itemType에 저장된 순서대로, 부모, 자식 한줄씩 local db에 저장되며. 중간 값을 지워도 해당 부모를 가진 객체는 다 지워지게 된다.
// 예) 페이지를 한번 봤을때 데이터를 지워주면 뉴알림을 더이상 보이지 않게 할 수 있음.
class DataController_NewAlarm {
    
    var noti = DataController_NewAlarm_Noti()
    var sensorFirmware = DataController_NewAlarm_SensorFirmware()
    var hubFirmware = DataController_NewAlarm_HubFirmware()
    var lampFirmware = DataController_NewAlarm_LampFirmware()
    
    var m_updateAction: Action?
    
    func setInit() {
        loadCoreDataToLocal()
    }
    
    func loadCoreDataToLocal() {
        let _arrData = DataManager.instance.m_coreDataInfo.storeNewAlarm.load()
        DataManager.instance.m_coreDataInfo.storeNewAlarm.lastId = lastId(arrData: _arrData)
        DataManager.instance.m_userInfo.newAlarm.m_lst = _arrData!
    }
    
    func lastId(arrData: [NewAlarmInfo]?) -> Int {
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
    
    func saveData(arrInfo: Array<NewAlarmInfo>?) {
        if let _arrInfo = arrInfo {
            addItems(items: _arrInfo)
        }
    }

    func insertOrUpdateItem(aid: Int?, finalItemType: NEW_ALARM_ITEM_TYPE, itemType: [NEW_ALARM_ITEM_TYPE], did: Int?, deviceType: DEVICE_TYPE?, extra: String?, time: String?) {
        if (itemType.count == 0) {
            return
        }
        var _lst = [NewAlarmInfo]()
        var _parentType: NEW_ALARM_ITEM_TYPE?
        for item in itemType {
            if (_parentType == nil) {
                _lst.append(NewAlarmInfo(id: 0, aid: aid, did: did, deviceType: deviceType?.rawValue ?? nil, finalItemType: finalItemType.rawValue, itemType: item.rawValue, extra: extra, parentItemType: nil, time: time))
            } else {
                _lst.append(NewAlarmInfo(id: 0, aid: aid, did: did, deviceType: deviceType?.rawValue ?? nil, finalItemType: finalItemType.rawValue, itemType: item.rawValue, extra: extra, parentItemType: _parentType?.rawValue ?? nil, time: time))
            }
            _parentType = item
        }
        addItems(items: _lst)
        for item in _lst {
            Debug.print("[NewAlarm] insertOrUpdateItem: itemType-\(item.m_itemType), parentItemType-\(item.m_parentItemType), extra-\(extra ?? "")")
        }
        
    }
    
    func addItem(item: NewAlarmInfo, isBackground: Bool = false) {
        let _entity = DataManager.instance.m_coreDataInfo.getEntity(name: DataManager.instance.m_coreDataInfo.storeNewAlarm.m_entityName)
        if (!(DataManager.instance.m_userInfo.newAlarm.isExist(info: item))) {
            item.m_id = DataManager.instance.m_coreDataInfo.storeNewAlarm.addItemToEntity(entity: _entity!, item: item, isBackground: isBackground)
            DataManager.instance.m_userInfo.newAlarm.addItem(arr: [item])
        } else {
            DataManager.instance.m_coreDataInfo.storeNewAlarm.updateItem(info: item)
            DataManager.instance.m_userInfo.newAlarm.updateItem(info: item)
        }
        if (isBackground) {
            DataManager.instance.m_coreDataInfo.backgroundSaveData()
        } else {
            DataManager.instance.m_coreDataInfo.saveData()
        }
    }
    
    func addItems(items: [NewAlarmInfo], isBackground: Bool = false) {
        let _entity = DataManager.instance.m_coreDataInfo.getEntity(name: DataManager.instance.m_coreDataInfo.storeNewAlarm.m_entityName)
        for item in items {
            if (!(DataManager.instance.m_userInfo.newAlarm.isExist(info: item))) {
                item.m_id = DataManager.instance.m_coreDataInfo.storeNewAlarm.addItemToEntity(entity: _entity!, item: item, isBackground: isBackground)
                DataManager.instance.m_userInfo.newAlarm.addItem(arr: [item])
            } else {
                DataManager.instance.m_coreDataInfo.storeNewAlarm.updateItem(info: item)
                DataManager.instance.m_userInfo.newAlarm.updateItem(info: item)
            }
        }
        if (isBackground) {
            DataManager.instance.m_coreDataInfo.backgroundSaveData()
        } else {
            DataManager.instance.m_coreDataInfo.saveData()
        }
    }
    
    func deleteItemByFinalItemType(aid: Int?, did: Int?, deviceType: DEVICE_TYPE?, finalItemType: NEW_ALARM_ITEM_TYPE) {
        var _arrDelIdx = [Int]()
        for item in DataManager.instance.m_userInfo.newAlarm.m_lst {
            if (aid == item.m_aid && did == item.m_did && deviceType?.rawValue ?? -1 == item.m_deviceType && finalItemType.rawValue == item.m_finalItemType) {
                Debug.print("[NewAlarm] deleteItemByFinalItemType: itemType-\(item.m_itemType), parentItemType-\(item.m_parentItemType)")
                _arrDelIdx.append(item.m_id)
            }
        }
        
        for item in _arrDelIdx {
            deleteItemById(id: item)
        }
    }

    func deleteItemByInfo(aid: Int?, did: Int?, deviceType: DEVICE_TYPE?, finalItemType: NEW_ALARM_ITEM_TYPE, itemType: NEW_ALARM_ITEM_TYPE?) {
        if (itemType == nil) {
            return
        }
        
        var _arrDelIdx = [Int]()
        for item in DataManager.instance.m_userInfo.newAlarm.m_lst {
            if (aid == item.m_aid && did == item.m_did && deviceType?.rawValue ?? -1 == item.m_deviceType && itemType!.rawValue == item.m_itemType && finalItemType.rawValue == item.m_finalItemType) {
                Debug.print("[NewAlarm] deleteItemByInfo: itemType-\(item.m_itemType), parentItemType-\(item.m_parentItemType)")
                _arrDelIdx.append(item.m_id)
                
                deleteParentItemByInfo(aid: aid, did: did, deviceType: deviceType, finalItemType: finalItemType, itemType: NEW_ALARM_ITEM_TYPE(rawValue: item.m_itemType), arrDelIdx: &_arrDelIdx)
            }
        }
        
        for item in _arrDelIdx {
            deleteItemById(id: item)
        }
    }
    
    func deleteParentItemByInfo(aid: Int?, did: Int?, deviceType: DEVICE_TYPE?, finalItemType: NEW_ALARM_ITEM_TYPE, itemType: NEW_ALARM_ITEM_TYPE?, arrDelIdx: inout [Int]) {
        if (itemType == nil) {
            return
        }
        for item in DataManager.instance.m_userInfo.newAlarm.m_lst {
            if (aid == item.m_aid && did == item.m_did && deviceType?.rawValue ?? -1 == item.m_deviceType && itemType!.rawValue == item.m_parentItemType && finalItemType.rawValue == item.m_finalItemType) {
                Debug.print("[NewAlarm] deleteParentItemByInfo: itemType-\(item.m_itemType), parentItemType-\(item.m_parentItemType)")
                arrDelIdx.append(item.m_id)
                
                deleteParentItemByInfo(aid: aid, did: did, deviceType: deviceType, finalItemType: finalItemType, itemType: NEW_ALARM_ITEM_TYPE(rawValue: item.m_itemType), arrDelIdx: &arrDelIdx)
            }
        }
    }
    
    func deleteItemById(id: Int) {
        var _delList = Array<NewAlarmInfo>()
        for item in DataManager.instance.m_userInfo.newAlarm.m_lst {
            if (item.m_id == id) {
                _delList.append(item)
            }
        }
        
        for item in _delList {
            if let index = DataManager.instance.m_userInfo.newAlarm.m_lst.index(where: { $0 === item }) {
                DataManager.instance.m_userInfo.newAlarm.m_lst.remove(at: index)
            }
        }
        
        DataManager.instance.m_coreDataInfo.storeNewAlarm.deleteItemsById(id: id)
    }
}


