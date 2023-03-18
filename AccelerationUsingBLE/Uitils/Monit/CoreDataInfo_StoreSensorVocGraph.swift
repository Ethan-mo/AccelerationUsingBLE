//
//  CoreDataInfo_StoreSensorVocGraph.swift
//  Monit
//
//  Created by john.lee on 2019. 4. 2..
//  Copyright © 2019년 맥. All rights reserved.
//

import UIKit
import CoreData

class CoreDataInfo_StoreSensorVocGraph {
    
    let m_entityName = "StoreSensorVocGraph"
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
    
    func addItemToEntity(entity: NSEntityDescription, item: StoreSensorVocGraphInfo, isBackground: Bool = false) -> Int {
        let _coreData = DataManager.instance.m_coreDataInfo
        let _addItem = StoreSensorVocGraph(entity: entity, insertInto: isBackground == true ? _coreData.backgroundContext : _coreData.context)
        let _lastId = lastId
        _addItem.id = Int32(_lastId)
        _addItem.did = item.m_did.description
        _addItem.time = item.m_time
        _addItem.voc = item.m_voc.description
        _addItem.cnt = Int32(item.m_cnt)
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
            Debug.print("[ERROR] StoreSensorVocGraph Error with request: \(error)", event: .error)
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
            Debug.print("[ERROR] StoreSensorVocGraph Error with request: \(error)", event: .error)
        }
    }
    
    func updateItem(info: StoreSensorVocGraphInfo) {
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
                            match.setValue(info.m_voc.description, forKey: "voc")
                            match.setValue(info.m_cnt, forKey: "cnt")
                        }
                    }
                }
                _coreData.saveData()
            }
        } catch let error as NSError {
            Debug.print("[ERROR] StoreSensorVocGraph Error with request: \(error)", event: .error)
        }
    }
    
    func load() -> Array<StoreSensorVocGraphInfo>? {
        let _coreData = DataManager.instance.m_coreDataInfo
        var _arrData = [StoreSensorVocGraphInfo]()
        
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
                    let _voc = match.value(forKey: "voc") as? String ?? ""
                    let _cnt = match.value(forKey: "cnt") as? Int ?? 0
                    let _info = StoreSensorVocGraphInfo(id: _id ?? -1,
                                             did: _did ?? 0,
                                             time: _time ?? Config.DATE_INIT,
                                             voc: _voc,
                                             cnt: _cnt)
                    _arrData.append(_info)
                }
            }
        } catch let error as NSError {
            Debug.print("[ERROR] StoreSensorVocGraph Error with request: \(error)", event: .error)
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
                    Debug.print("StoreSensorVocGraph DeleteOldData: \(String(describing: CastDateFormatDeviceNoti(time: _time).m_timeCast))", event: .dev)
                    _coreData.context.delete(match)
                }
            }
            _coreData.saveData()
        } catch let error as NSError {
            Debug.print("[ERROR] StoreSensorVocGraph Error with request: \(error)", event: .error)
        }
    }
}
