//
//  CoreDataInfo_ShareDevice.swift
//  Monit
//
//  Created by 맥 on 2017. 9. 26..
//  Copyright © 2017년 맥. All rights reserved.
//

import UIKit
import CoreData

class CoreDataInfo_StoreDiaperSensingLog {
    
    let m_entityName = "StoreDiaperSensingLog"
    var m_lastId: Int = -1
    var lastId: Int {
        get {
            if (m_lastId == -1) {
                m_lastId = lastIdByCoredata
            }
            m_lastId += 1
            return m_lastId
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
    
    func addItemToEntity(entity: NSEntityDescription, item: DiaperSensingLogInfo, isBackground: Bool = false) -> Int {
        let _coreData = DataManager.instance.m_coreDataInfo
        let _addItem = StoreDiaperSensingLog(entity: entity, insertInto: isBackground == true ? _coreData.backgroundContext : _coreData.context)
        let _lastId = lastId
        _addItem.id = Int32(_lastId)
        _addItem.did = item.m_did.description
        _addItem.time = item.m_time
        _addItem.tem = item.m_tem.description
        _addItem.hum = item.m_hum.description
        _addItem.voc = item.m_voc.description
        _addItem.cap = item.m_cap.description
        _addItem.act = item.m_act.description
        _addItem.sen = item.m_sen.description
        _addItem.mlv = item.m_mlv.description
        _addItem.eth = item.m_eth.description
        _addItem.co2 = item.m_co2.description
        _addItem.pres = item.m_pres.description
        _addItem.comp = item.m_comp.description
        _addItem.cnt = Int32(item.m_cnt)
        _addItem.cnt_second = Int32(item.m_cnt_second)
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
            Debug.print("[ERROR] StoreDiaperSensingLog Error with request: \(error)", event: .error)
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
            Debug.print("[ERROR] StoreDiaperSensingLog Error with request: \(error)", event: .error)
        }
    }
    
    func updateItem(info: DiaperSensingLogInfo) {
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
                            match.setValue(info.m_cnt, forKey: "cnt")
                            match.setValue(info.m_cnt_second, forKey: "cnt_second")
                            match.setValue(info.m_tem.description, forKey: "tem")
                            match.setValue(info.m_hum.description, forKey: "hum")
                            match.setValue(info.m_voc.description, forKey: "voc")
                            match.setValue(info.m_cap.description, forKey: "cap")
                            match.setValue(info.m_act.description, forKey: "act")
                            match.setValue(info.m_sen.description, forKey: "sen")
                            match.setValue(info.m_mlv.description, forKey: "mlv")
                            match.setValue(info.m_eth.description, forKey: "eth")
                            match.setValue(info.m_co2.description, forKey: "co2")
                            match.setValue(info.m_pres.description, forKey: "pres")
                            match.setValue(info.m_comp.description, forKey: "comp")
                        }
                    }
                }
                _coreData.saveData()
            }
        } catch let error as NSError {
            Debug.print("[ERROR] StoreDiaperSensingLog Error with request: \(error)", event: .error)
        }
    }
    
    func getManagedObject(match: NSManagedObject) -> DiaperSensingLogInfo {
        let _did = match.value(forKey: "did") as? String ?? ""
        let _id = match.value(forKey: "id") as? Int ?? -1
        let _time = match.value(forKey: "time") as? String ?? Config.DATE_INIT
        let _cnt = match.value(forKey: "cnt") as? Int ?? 1
        let _cnt_second = match.value(forKey: "cnt_second") as? Int ?? 1
        let _tem = match.value(forKey: "tem") as? String ?? ""
        let _hum = match.value(forKey: "hum") as? String ?? ""
        let _voc = match.value(forKey: "voc") as? String ?? ""
        let _cap = match.value(forKey: "cap") as? String ?? ""
        let _act = match.value(forKey: "act") as? String ?? ""
        let _sen = match.value(forKey: "sen") as? String ?? ""
        let _mlv = match.value(forKey: "mlv") as? String ?? ""
        let _eth = match.value(forKey: "eth") as? String ?? ""
        let _co2 = match.value(forKey: "co2") as? String ?? ""
        let _pres = match.value(forKey: "pres") as? String ?? ""
        let _comp = match.value(forKey: "comp") as? String ?? ""
        let _dataSet = DiaperSensingLogSet(tem: _tem, hum: _hum, voc: _voc, cap: _cap, act: _act, sen: _sen, mlv: _mlv, eth: _eth, co2: _co2, pres: _pres, comp: _comp)
        let _info = DiaperSensingLogInfo(id: _id,
                                       did: Int(_did) ?? 0,
                                       time: _time,
                                       cnt: _cnt,
                                       cnt_second: _cnt_second,
                                       dataSet: _dataSet)
        return _info
    }
    
    func loadByDid(did: Int) -> [DiaperSensingLogInfo]? {
        let _coreData = DataManager.instance.m_coreDataInfo
        var _arrData = [DiaperSensingLogInfo]()

        let _entity = _coreData.getEntity(name: m_entityName)
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        fetchRequest.entity = _entity
        
        do{
            let objects = try _coreData.context.fetch(fetchRequest)
            if objects.count > 0 {
                for item in objects {
                    let match = item as! NSManagedObject
                    let _info = getManagedObject(match: match)
                    if (_info.m_did != 0 && _info.m_did == did) {
                        _arrData.append(_info)
                    }
                }
            }
        } catch let error as NSError {
            Debug.print("[ERROR] StoreDiaperSensingLog Error with request: \(error)", event: .error)
        }
        
        return _arrData
    }
    
    func loadById(id: Int) -> DiaperSensingLogInfo? {
        let _coreData = DataManager.instance.m_coreDataInfo

        let _entity = _coreData.getEntity(name: m_entityName)
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        fetchRequest.entity = _entity
        
        do{
            let objects = try _coreData.context.fetch(fetchRequest)
            if objects.count > 0 {
                for item in objects {
                    let match = item as! NSManagedObject
                    let _info = getManagedObject(match: match)
                    if (_info.m_id != -1 && _info.m_id == id) {
                        return _info
                    }
                }
            }
        } catch let error as NSError {
            Debug.print("[ERROR] StoreDiaperSensingLog Error with request: \(error)", event: .error)
        }
        
        return nil
    }

    func load() -> [DiaperSensingLogInfo]? {
        let _coreData = DataManager.instance.m_coreDataInfo
        var _arrData = [DiaperSensingLogInfo]()
        
        let _entity = _coreData.getEntity(name: m_entityName)
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        fetchRequest.entity = _entity
        
        do{
            let objects = try _coreData.context.fetch(fetchRequest)
            if objects.count > 0 {
                for item in objects {
                    let match = item as! NSManagedObject
                    let _info = getManagedObject(match: match)
                    _arrData.append(_info)
                }
            }
        } catch let error as NSError {
            Debug.print("[ERROR] StoreDiaperSensingLog Error with request: \(error)", event: .error)
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
                    Debug.print("StoreDiaperSensingLog DeleteOldData: \(String(describing: CastDateFormatDeviceNoti(time: _time).m_timeCast))", event: .dev)
                    _coreData.context.delete(match)
                }
            }
            _coreData.saveData()
        } catch let error as NSError {
            Debug.print("[ERROR] StoreDiaperSensingLog Error with request: \(error)", event: .error)
        }
    }
}

