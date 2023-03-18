//
//  CoreDataInfo_ShareDevice.swift
//  Monit
//
//  Created by 맥 on 2017. 9. 26..
//  Copyright © 2017년 맥. All rights reserved.
//

import UIKit
import CoreData

class CoreDataInfo_StoreHubGraph {
    
    let m_entityName = "StoreHubGraph"
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
    
    func addItemToEntity(entity: NSEntityDescription, item: HubGraphInfo, isBackground: Bool = false) -> Int {
        let _coreData = DataManager.instance.m_coreDataInfo
        let _addItem = StoreHubGraph(entity: entity, insertInto: isBackground == true ? _coreData.backgroundContext : _coreData.context)
        let _lastId = lastId
        _addItem.id = Int32(_lastId)
        _addItem.did = item.m_did.description
        _addItem.time = item.m_time
        _addItem.tem = item.m_tem.description
        _addItem.hum = item.m_hum.description
        _addItem.voc = item.m_voc.description
        return _lastId
    }
    
    func deleteItemsByDid(did: Int) {
        let _coreData = DataManager.instance.m_coreDataInfo
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: m_entityName)
        fetchRequest.returnsObjectsAsFaults = false
        
        do
        {
            let objects = try _coreData.context.fetch(fetchRequest)
            for item in objects
            {
                let match = item as! NSManagedObject
                let _did = Int(match.value(forKey: "did") as? String ?? "") ?? -1
                if (_did == did) {
                    _coreData.context.delete(match)
                }
            }
            _coreData.saveData()
        } catch let error as NSError {
            Debug.print("[ERROR] StoreHubGraph Error with request: \(error)", event: .error)
        }
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
                let _id = match.value(forKey: "id") as! Int
                if (_id != 0 && _id == id) {
                    _coreData.context.delete(match)
                }
            }
            _coreData.saveData()
        } catch let error as NSError {
            Debug.print("[ERROR] StoreHubGraph Error with request: \(error)", event: .error)
        }
    }
    
    func updateItem(info: HubGraphInfo) {
        let _coreData = DataManager.instance.m_coreDataInfo
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: m_entityName)
        do {
            let objects = try _coreData.context.fetch(fetchRequest)
            if objects.count > 0 {
                for item in objects {
                    let match = item as! NSManagedObject
                    if let _id = match.value(forKey: "id") as? Int {
                        if (_id != 0 && _id == info.m_id) {
                            match.setValue(info.m_did.description, forKey: "did")
                            match.setValue(info.m_time, forKey: "time")
                            match.setValue(info.m_tem.description, forKey: "tem")
                            match.setValue(info.m_hum.description, forKey: "hum")
                            match.setValue(info.m_voc.description, forKey: "voc")
                        }
                    }
                }
                _coreData.saveData()
            }
        } catch let error as NSError {
            Debug.print("[ERROR] StoreHubGraph Error with request: \(error)", event: .error)
        }
    }

    func load() -> Array<HubGraphInfo>? {
        let _coreData = DataManager.instance.m_coreDataInfo
        var _arrData = [HubGraphInfo]()
        
        let _entity = _coreData.getEntity(name: m_entityName)
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        fetchRequest.entity = _entity
        
        do{
            let objects = try _coreData.context.fetch(fetchRequest)
            if objects.count > 0 {
                for item in objects {
                    let match = item as! NSManagedObject
                    let _id = match.value(forKey: "id") as? Int
                    let _did = Int(match.value(forKey: "did") as? String ?? "")
                    let _time = match.value(forKey: "time") as? String
                    let _tem = Int(match.value(forKey: "tem") as? String ?? "")
                    let _hum = Int(match.value(forKey: "hum") as? String ?? "")
                    let _voc = Int(match.value(forKey: "voc") as? String ?? "")
                    let _info = HubGraphInfo(id: _id ?? -1,
                                               did: _did ?? 0,
                                               time: _time ?? Config.DATE_INIT,
                                               tem: _tem ?? 0,
                                               hum: _hum ?? 0,
                                               voc: _voc ?? 0)
                    _arrData.append(_info)
                }
            }
        } catch let error as NSError {
            Debug.print("[ERROR] StoreHubGraph Error with request: \(error)", event: .error)
        }
        
        return _arrData
    }
    
    func deleteOldData() {
        let _coreData = DataManager.instance.m_coreDataInfo
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: m_entityName)
        fetchRequest.returnsObjectsAsFaults = false
        
        do
        {
            let objects = try _coreData.context.fetch(fetchRequest)
            for item in objects
            {
                let match = item as! NSManagedObject
                let _time = match.value(forKey: "time") as? String ?? Config.DATE_INIT
                if (NSDate(timeIntervalSinceNow: TimeInterval(-86400 * 8)) as Date > CastDateFormatDeviceNoti(time: _time).m_timeCast) {
                    Debug.print("StoreHubGraph DeleteOldData: \(String(describing: CastDateFormatDeviceNoti(time: _time).m_timeCast))", event: .dev)
                    _coreData.context.delete(match)
                }
            }
            _coreData.saveData()
        } catch let error as NSError {
            Debug.print("[ERROR] StoreHubGraph Error with request: \(error)", event: .error)
        }
    }
}

