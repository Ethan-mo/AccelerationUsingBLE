//
//  CoreDataInfo_ShareDevice.swift
//  Monit
//
//  Created by 맥 on 2017. 9. 26..
//  Copyright © 2017년 맥. All rights reserved.
//

import UIKit
import CoreData

// 알림 로컬 정보
// coredata 신규 쿼리 추가로 전유저 오류 방지를 위해 null처리
class CoreDataInfo_StoreDeviceNotiReady {
    
    let m_entityName = "StoreDeviceNotiReady"
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

    func addItemToEntity(entity: NSEntityDescription, item: DeviceNotiReadyInfo, isBackground: Bool = false) -> Int {
        let _coreData = DataManager.instance.m_coreDataInfo
        let _addItem = StoreDeviceNotiReady(entity: entity, insertInto: isBackground == true ? _coreData.backgroundContext : _coreData.context)
        let _lastId = lastId
        _addItem.id = Int32(_lastId)
        _addItem.type = item.m_type.description
        _addItem.did = item.m_did.description
        _addItem.noti = item.m_noti.description
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
                let _id = match.value(forKey: "id") as! Int
                if (_id != 0 && _id == id) {
                    _coreData.context.delete(match)
                }
            }
            _coreData.saveData()
        } catch let error as NSError {
            Debug.print("[ERROR] StoreDeviceNoti Error with request: \(error)", event: .error)
        }
    }
    
    func load() -> Array<DeviceNotiReadyInfo>? {
        let _coreData = DataManager.instance.m_coreDataInfo
        var _arrData = [DeviceNotiReadyInfo]()
        
        let _entity = _coreData.getEntity(name: m_entityName)
        let request = NSFetchRequest<NSFetchRequestResult>()
        request.entity = _entity
        
        do{
            let objects = try _coreData.context.fetch(request)
            if objects.count > 0 {
                for item in objects {
                    let match = item as! NSManagedObject
                    let _id = match.value(forKey: "id") as? Int
                    let _type = Int(match.value(forKey: "type") as? String ?? "")
                    let _did = Int(match.value(forKey: "did") as? String ?? "")
                    let _noti = Int(match.value(forKey: "noti") as? String ?? "")
                    let _time = match.value(forKey: "time") as? String
                    let _info = DeviceNotiReadyInfo(id: _id ?? -1,
                                               type: _type ?? 0,
                                               did: _did ?? 0,
                                               noti: _noti ?? 0,
                                               time: _time ?? Config.DATE_INIT)
                    _arrData.append(_info)
                }
            }
        } catch let error as NSError {
            Debug.print("[ERROR] StoreDeviceNotiReady Error with request: \(error)", event: .error)
        }
        
        return _arrData
    }
}
