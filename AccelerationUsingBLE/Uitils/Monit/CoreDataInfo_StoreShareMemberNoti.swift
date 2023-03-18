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
class CoreDataInfo_StoreShareMemberNoti {
    
    let m_entityName = "StoreShareMemberNoti"
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
    
    func addItemToEntity(entity: NSEntityDescription, item: ShareMemberNotiInfo, isBackground: Bool = false) -> Int {
        let _coreData = DataManager.instance.m_coreDataInfo
        let _addItem = StoreShareMemberNoti(entity: entity, insertInto: isBackground == true ? _coreData.backgroundContext : _coreData.context)
        let _lastId = lastId
        _addItem.id = Int32(_lastId)
        _addItem.noti = item.m_noti.description
        _addItem.time = item.m_time
        _addItem.extra = item.m_extra
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
            Debug.print("[ERROR] StoreShareMemberNoti Error with request: \(error)", event: .error)
        }
    }
    
    func updateItem(info: ShareMemberNotiInfo) {
        let _coreData = DataManager.instance.m_coreDataInfo
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: m_entityName)
        do {
            let objects = try _coreData.context.fetch(fetchRequest)
            if objects.count > 0 {
                for item in objects {
                    let match = item as! NSManagedObject
                    if let _id = match.value(forKey: "id") as? Int {
                        if (_id != 0 && _id == info.m_id) {
                            match.setValue(info.m_noti.description, forKey: "noti")
                            match.setValue(info.m_time, forKey: "time")
                            match.setValue(info.m_extra, forKey: "extra")
                        }
                    }
                }
                _coreData.saveData()
            }
        } catch let error as NSError {
            Debug.print("[ERROR] StoreShareMemberNoti Error with request: \(error)", event: .error)
        }
    }
    
    func load() -> Array<ShareMemberNotiInfo>? {
        let _coreData = DataManager.instance.m_coreDataInfo
        var _arrData = [ShareMemberNotiInfo]()
        
        let _entity = _coreData.getEntity(name: m_entityName)
        let request = NSFetchRequest<NSFetchRequestResult>()
        request.entity = _entity
        
        do{
            let objects = try _coreData.context.fetch(request)
            if objects.count > 0 {
                for item in objects {
                    let match = item as! NSManagedObject
                    let _id = match.value(forKey: "id") as? Int
                    let _noti = Int(match.value(forKey: "noti") as? String ?? "")
                    let _time = match.value(forKey: "time") as? String
                    let _extra = match.value(forKey: "extra") as? String
                    let _info = ShareMemberNotiInfo(id: _id ?? -1,
                                                      noti: _noti ?? 0,
                                                      time: _time ?? Config.DATE_INIT,
                                                      extra: _extra ?? "")
                    _arrData.append(_info)
                }
            }
        } catch let error as NSError {
            Debug.print("[ERROR] StoreShareMemberNoti Error with request: \(error)", event: .error)
        }
        
        return _arrData
    }
}

