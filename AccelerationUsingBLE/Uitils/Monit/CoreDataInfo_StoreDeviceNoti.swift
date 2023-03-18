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
class CoreDataInfo_StoreDeviceNoti {
    
    let m_entityName = "StoreDeviceNoti"
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
    
    func addItemToEntity(entity: NSEntityDescription, item: DeviceNotiInfo, isBackground: Bool = false) -> Int {
        let _coreData = DataManager.instance.m_coreDataInfo
        let _addItem = StoreDeviceNoti(entity: entity, insertInto: isBackground == true ? _coreData.backgroundContext : _coreData.context)
        let _lastId = lastId
        _addItem.id = Int32(_lastId)
        _addItem.nid = Int32(item.m_nid)
        _addItem.type = item.m_type.description
        _addItem.did = item.m_did.description
        _addItem.noti = item.m_noti.description
        _addItem.extra = item.Extra
        _addItem.extra2 = item.m_extra2
        _addItem.extra3 = item.m_extra3
        _addItem.extra4 = item.m_extra4
        _addItem.extra5 = item.m_extra5
        _addItem.memo = item.m_memo
        _addItem.time = item.Time
        _addItem.finish_time = item.FinishTime
        return _lastId
    }
    
    func deleteItemsByNid(nid: Int) {
        let _coreData = DataManager.instance.m_coreDataInfo
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: m_entityName)
        fetchRequest.returnsObjectsAsFaults = false
        
        do
        {
            let objects = try _coreData.context.fetch(fetchRequest)
            for item in objects
            {
                let match = item as! NSManagedObject
                let _nid = match.value(forKey: "nid") as! Int
                if (_nid != 0 && _nid == nid) {
                    _coreData.context.delete(match)
                }
            }
            _coreData.saveData()
        } catch let error as NSError {
            Debug.print("[ERROR] StoreDeviceNoti Error with request: \(error)", event: .error)
        }
    }
    
    func deleteItemsByDid(type: Int, did: Int) {
        let _coreData = DataManager.instance.m_coreDataInfo
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: m_entityName)
        fetchRequest.returnsObjectsAsFaults = false
        
        do
        {
            let objects = try _coreData.context.fetch(fetchRequest)
            for item in objects
            {
                let match = item as! NSManagedObject
                let _type = Int(match.value(forKey: "type") as? String ?? "") ?? -1
                let _did = Int(match.value(forKey: "did") as? String ?? "") ?? -1
                if (_type == type && _did == did) {
                    _coreData.context.delete(match)
                }
            }
            _coreData.saveData()
        } catch let error as NSError {
            Debug.print("[ERROR] StoreDeviceNoti Error with request: \(error)", event: .error)
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
            Debug.print("[ERROR] StoreDeviceNoti Error with request: \(error)", event: .error)
        }
    }
    
    func updateItem(info: DeviceNotiInfo) {
        let _coreData = DataManager.instance.m_coreDataInfo
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: m_entityName)
        do {
            let objects = try _coreData.context.fetch(fetchRequest)
            if objects.count > 0 {
                for item in objects {
                    let match = item as! NSManagedObject
                    if let _id = match.value(forKey: "id") as? Int {
                        if (_id != 0 && _id == info.m_id) {
                            match.setValue(info.m_type.description, forKey: "type")
                            match.setValue(info.m_did.description, forKey: "did")
                            match.setValue(info.m_noti.description, forKey: "noti")
                            match.setValue(info.Extra, forKey: "extra")
                            match.setValue(info.m_extra2, forKey: "extra2")
                            match.setValue(info.m_extra3, forKey: "extra3")
                            match.setValue(info.m_extra4, forKey: "extra4")
                            match.setValue(info.m_extra5, forKey: "extra5")
                            match.setValue(info.m_memo, forKey: "memo")
                            match.setValue(info.Time, forKey: "time")
                            match.setValue(info.FinishTime, forKey: "finish_time")
                        }
                    }
                }
                _coreData.saveData()
            }
        } catch let error as NSError {
            Debug.print("[ERROR] StoreDeviceNoti Error with request: \(error)", event: .error)
        }
    }
    
    func updateItemByNid(nid: Int, noti: Int, extra: String, extra2: String, extra3: String, extra4: String, extra5: String, memo: String, time: String, finishTime: String) {
        let _coreData = DataManager.instance.m_coreDataInfo
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: m_entityName)
        do {
            let objects = try _coreData.context.fetch(fetchRequest)
            if objects.count > 0 {
                for item in objects {
                    let match = item as! NSManagedObject
                    if let _nid = match.value(forKey: "nid") as? Int {
                        if (_nid != 0 && _nid == nid) {
                            match.setValue(noti.description, forKey: "noti")
                            match.setValue(extra, forKey: "extra")
                            match.setValue(extra2, forKey: "extra2")
                            match.setValue(extra3, forKey: "extra3")
                            match.setValue(extra4, forKey: "extra4")
                            match.setValue(extra5, forKey: "extra5")
                            match.setValue(memo, forKey: "memo")
                            match.setValue(time, forKey: "time")
                            match.setValue(finishTime, forKey: "finish_time")
                        }
                    }
                }
                _coreData.saveData()
            }
        } catch let error as NSError {
            Debug.print("[ERROR] StoreDeviceNoti Error with request: \(error)", event: .error)
        }
    }
    
    func load() -> Array<DeviceNotiInfo>? {
        let _coreData = DataManager.instance.m_coreDataInfo
        var _arrData = [DeviceNotiInfo]()
        
        let _entity = _coreData.getEntity(name: m_entityName)
        let request = NSFetchRequest<NSFetchRequestResult>()
        request.entity = _entity
        
        do{
            let objects = try _coreData.context.fetch(request)
            if objects.count > 0 {
                for item in objects {
                    let match = item as! NSManagedObject
                    let _id = match.value(forKey: "id") as? Int
                    let _nid = match.value(forKey: "nid") as? Int
                    let _type = Int(match.value(forKey: "type") as? String ?? "")
                    let _did = Int(match.value(forKey: "did") as? String ?? "")
                    let _noti = Int(match.value(forKey: "noti") as? String ?? "")
                    let _extra = match.value(forKey: "extra") as? String
                    let _extra2 = match.value(forKey: "extra2") as? String
                    let _extra3 = match.value(forKey: "extra3") as? String
                    let _extra4 = match.value(forKey: "extra4") as? String
                    let _extra5 = match.value(forKey: "extra5") as? String
                    let _memo = match.value(forKey: "memo") as? String
                    let _time = match.value(forKey: "time") as? String
                    let _finishTime = match.value(forKey: "finish_time") as? String
                    let _info = DeviceNotiInfo(id: _id ?? -1,
                                               nid: _nid ?? 0,
                                               type: _type ?? 0,
                                               did: _did ?? 0,
                                               noti: _noti ?? 0,
                                               extra: _extra ?? "",
                                               extra2: _extra2 ?? "",
                                               extra3: _extra3 ?? "",
                                               extra4: _extra4 ?? "",
                                               extra5: _extra5 ?? "",
                                               memo: _memo ?? "",
                                               time: _time ?? Config.DATE_INIT,
                                               finishTime: _finishTime ?? Config.DATE_INIT
                    )
                    _arrData.append(_info)
                }
            }
        } catch let error as NSError {
            Debug.print("[ERROR] StoreDeviceNoti Error with request: \(error)", event: .error)
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
                let _noti = Int(match.value(forKey: "noti") as? String ?? "") ?? 0
                if (NSDate(timeIntervalSinceNow: TimeInterval(-86400 * 30)) as Date > CastDateFormatDeviceNoti(time: _time).m_timeCast) {
                    if let _notiType = DEVICE_NOTI_TYPE(rawValue: _noti) {
                        switch _notiType {
                        case .pee_detected,
                            .poo_detected,
                            .diaper_changed,
                            .fart_detected:
                            break
                        default:
                            Debug.print("StoreDeviceNoti DeleteOldData: \(String(describing: CastDateFormatDeviceNoti(time: _time).m_timeCast))", event: .dev)
                            _coreData.context.delete(match)
                        }
                    }
                }
            }
            _coreData.saveData()
        } catch let error as NSError {
            Debug.print("[ERROR] StoreDeviceNoti Error with request: \(error)", event: .error)
        }
    }
}
