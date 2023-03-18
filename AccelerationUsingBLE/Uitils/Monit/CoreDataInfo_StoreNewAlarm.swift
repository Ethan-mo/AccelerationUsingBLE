//
//  CoreDataInfo_ShareDevice.swift
//  Monit
//
//  Created by 맥 on 2017. 9. 26..
//  Copyright © 2017년 맥. All rights reserved.
//

import UIKit
import CoreData

class CoreDataInfo_StoreNewAlarm {

    let m_entityName = "StoreNewAlarm"
    var m_lastId: Int = 0
    var lastId: Int {
        get {
            m_lastId += 1
            return m_lastId
        }
        set {
            m_lastId = newValue
        }
    }
    var lastIdByCoredata: Int { // 비용 비쌈. 자주 실행 금지
        get {
            var _retValue = 0
            if let _list = load() {
                for item in _list {
                    if (_retValue < item.m_id) {
                        _retValue = item.m_id
                    }
                }
            }
            return _retValue
        }
    }
    
    func addItemToEntity(entity: NSEntityDescription, item: NewAlarmInfo, isBackground: Bool = false) -> Int {
        let _coreData = DataManager.instance.m_coreDataInfo
        let _addItem = StoreNewAlarm(entity: entity, insertInto: isBackground == true ? _coreData.backgroundContext : _coreData.context)
        let _lastId = lastId
        _addItem.id = Int32(_lastId)
        _addItem.aid = item.m_aid.description
        _addItem.did = item.m_did.description
        _addItem.device_type = item.m_deviceType.description
        _addItem.final_item_type = item.m_finalItemType.description
        _addItem.item_type = item.m_itemType.description
        _addItem.extra = item.m_extra
        _addItem.parent_item_type = item.m_parentItemType.description
        _addItem.time = item.m_time
        return _lastId
    }
    
    func deleteItemsById(id: Int) {
        let _coreData = DataManager.instance.m_coreDataInfo
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: m_entityName)
        fetchRequest.returnsObjectsAsFaults = false

        do
        {
            let objects = try _coreData.context.fetch(fetchRequest)
            for item in objects
            {
                let match = item as! NSManagedObject
                let _id = match.value(forKey: "id") as? Int
                if (_id != 0 && _id == id) {
                    _coreData.context.delete(match)
                }
            }
            _coreData.saveData()
        } catch let error as NSError {
            Debug.print("[ERROR] NewAlarm Error with request: \(error)", event: .error)
        }
    }

    func updateItem(info: NewAlarmInfo) {
        let _coreData = DataManager.instance.m_coreDataInfo
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: m_entityName)
        do {
            let objects = try _coreData.context.fetch(fetchRequest)
            if objects.count > 0 {
                for item in objects {
                    let match = item as! NSManagedObject
                    let _aid = Int(match.value(forKey: "aid") as? String ?? "") ?? -1
                    let _did = Int(match.value(forKey: "did") as? String ?? "") ?? -1
                    let _device_type = Int(match.value(forKey: "device_type") as? String ?? "") ?? -1
                    let _final_item_type = Int(match.value(forKey: "final_item_type") as? String ?? "") ?? -1
                    let _item_type = Int(match.value(forKey: "item_type") as? String ?? "") ?? -1
                    if (info.m_aid == _aid && info.m_did == _did && info.m_deviceType == _device_type && info.m_itemType == _item_type && info.m_finalItemType == _final_item_type) {
                        match.setValue(info.m_extra, forKey: "extra")
                        match.setValue(info.m_time, forKey: "time")
                    }
                }
                _coreData.saveData()
            }
        } catch let error as NSError {
            Debug.print("[ERROR] NewAlarm Error with request: \(error)", event: .error)
        }
    }

    func load() -> Array<NewAlarmInfo>? {
        let _coreData = DataManager.instance.m_coreDataInfo
        var _arrData = [NewAlarmInfo]()
        
        let _entity = _coreData.getEntity(name: m_entityName)
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        fetchRequest.entity = _entity
        
        do{
            let objects = try _coreData.context.fetch(fetchRequest)
            if objects.count > 0 {
                for item in objects {
                    let match = item as! NSManagedObject
                    let _id = match.value(forKey: "id") as? Int
                    let _aid = Int(match.value(forKey: "aid") as? String ?? "")
                    let _did = Int(match.value(forKey: "did") as? String ?? "")
                    let _deviceType = Int(match.value(forKey: "device_type") as? String ?? "")
                    let _finalItemType = Int(match.value(forKey: "final_item_type") as? String ?? "")
                    let _itemType = Int(match.value(forKey: "item_type") as? String ?? "")
                    let _extra = match.value(forKey: "extra") as? String
                    let _parentItemType = Int(match.value(forKey: "parent_item_type") as? String ?? "")
                    let _time = match.value(forKey: "time") as? String
                    let _info = NewAlarmInfo(id: _id ?? -1,
                                             aid: _aid ?? -1,
                                             did: _did ?? -1,
                                             deviceType: _deviceType ?? -1,
                                             finalItemType: _finalItemType ?? -1,
                                             itemType: _itemType ?? -1,
                                             extra: _extra ?? "",
                                             parentItemType: _parentItemType ?? -1,
                                             time: _time ?? Config.DATE_INIT)
                    _arrData.append(_info)
                }
            }
        } catch let error as NSError {
            Debug.print("[ERROR] NewAlarm Error with request: \(error)", event: .error)
        }
        
        return _arrData
    }
}


