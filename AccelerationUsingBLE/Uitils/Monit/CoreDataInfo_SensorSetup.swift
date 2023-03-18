//
//  CoreDataInfo_ShareDevice.swift
//  Monit
//
//  Created by 맥 on 2017. 9. 26..
//  Copyright © 2017년 맥. All rights reserved.
//

import UIKit
import CoreData

// 셋업 로컬 정보
class CoreDataInfo_SensorSetup {
    
    let m_entityName = "SensorSetup"
    
    func addItemToEntity(entity: NSEntityDescription, item: SensorSetupInfo) {
        let _addItem = SensorSetup(entity: entity, insertInto: DataManager.instance.m_coreDataInfo.context)
        _addItem.cid = Int32(item.m_cid)
        _addItem.did = Int32(item.m_did)
        _addItem.alarm_master = item.m_alarm_master
        _addItem.alarm_connect = item.m_alarm_connect
        _addItem.alarm_poo = item.m_alarm_poo
    }
    
    func deleteItemsByCid(cid: Int) {
        let _context = DataManager.instance.m_coreDataInfo.context
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: m_entityName)
        fetchRequest.returnsObjectsAsFaults = false
        
        do
        {
            let results = try _context.fetch(fetchRequest)
            for managedObject in results
            {
                let managedObjectData = managedObject as! NSManagedObject
                let _cid = managedObjectData.value(forKey: "cid") as! Int
                if (_cid == cid) {
                    _context.delete(managedObjectData)
                }
            }
            DataManager.instance.m_coreDataInfo.saveData()
        } catch let error as NSError {
            Debug.print("SensorSetup Error with request: \(error)")
        }
    }
    
    func deleteAllAndSave(list: Array<SensorSetupInfo>) {
        DataManager.instance.m_coreDataInfo.deleteAllData(entity: m_entityName)
        addItems(list: list)
    }
    
    func updateItem(SensorSetupInfo: SensorSetupInfo) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: m_entityName)
        do{
            let objects = try DataManager.instance.m_coreDataInfo.context.fetch(fetchRequest)
            if objects.count > 0 {
                for item in objects {
                    let match = item as! NSManagedObject
                    let _cid = match.value(forKey: "cid") as! Int
                    let _did = match.value(forKey: "did") as! Int
                    if (_cid == SensorSetupInfo.m_cid && _did == SensorSetupInfo.m_did) {
                        match.setValue(SensorSetupInfo.m_alarm_master, forKey: "alarm_master")
                        match.setValue(SensorSetupInfo.m_alarm_connect, forKey: "alarm_connect")
                        match.setValue(SensorSetupInfo.m_alarm_poo, forKey: "alarm_poo")
                    } else {
                        Debug.print("SensorSetup FindContact => Device Nothing founded!!")
                    }
                }
                DataManager.instance.m_coreDataInfo.saveData()
            }else{
                Debug.print("SensorSetup FindContact => Nothing founded!!")
            }
        } catch let error as NSError {
            Debug.print("SensorSetup Error with request: \(error)")
        }
    }
    
    func addItem(item: SensorSetupInfo) {
        let _entity = DataManager.instance.m_coreDataInfo.getEntity(name: m_entityName)
        addItemToEntity(entity: _entity!, item: item)
        DataManager.instance.m_coreDataInfo.saveData()
    }
    
    func addItems(list: Array<SensorSetupInfo>) {
        let _entity = DataManager.instance.m_coreDataInfo.getEntity(name: m_entityName)
        for item in list {
            addItemToEntity(entity: _entity!, item: item)
        }
        DataManager.instance.m_coreDataInfo.saveData()
    }
    
    func load() -> Array<SensorSetupInfo>? {
        var _arrData = [SensorSetupInfo]()
        
        let _entity = DataManager.instance.m_coreDataInfo.getEntity(name: m_entityName)
        let request = NSFetchRequest<NSFetchRequestResult>()
        request.entity = _entity
        
        do{
            let objects = try DataManager.instance.m_coreDataInfo.context.fetch(request)
            if objects.count > 0 {
                for item in objects {
                    let match = item as! NSManagedObject
                    let _cid = match.value(forKey: "cid") as! Int
                    let _did = match.value(forKey: "did") as! Int
                    let _alarm_master = match.value(forKey: "alarm_master") as! Bool
                    let _alarm_connect = match.value(forKey: "alarm_connect") as! Bool
                    let _alarm_poo = match.value(forKey: "alarm_poo") as! Bool
                    let _info = SensorSetupInfo(cid: _cid, did: _did, alarm_master: _alarm_master, alarm_connect: _alarm_connect, alarm_poo: _alarm_poo)
                    _arrData.append(_info)
                }
            }else{
                Debug.print("SensorSetup FindContact => Nothing founded!!")
            }
        } catch let error as NSError {
            Debug.print("SensorSetup Error with request: \(error)")
        }
        
        return _arrData
    }
}
