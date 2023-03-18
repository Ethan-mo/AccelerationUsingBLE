//
//  CoreDataInfo_ConnectSensor.swift
//  Monit
//
//  Created by 맥 on 2017. 10. 17..
//  Copyright © 2017년 맥. All rights reserved.
//

import UIKit
import CoreData

// 연결된 장비 정보
class CoreDataInfo_StoreConnectedSensor {
    
    let m_entityName = "StoreConnectedSensor"
    
    func addItemToEntity(entity: NSEntityDescription, item: StoreConnectedSensorInfo, isBackground: Bool = false) {
        let _coreData = DataManager.instance.m_coreDataInfo
        let _addItem = StoreConnectedSensor(entity: entity, insertInto: isBackground == true ? _coreData.backgroundContext : _coreData.context)
        _addItem.adv = DataManager.instance.m_configData.localEncryptData(string: item.adv)
        _addItem.uuid = DataManager.instance.m_configData.localEncryptData(string: item.uuid)
        _addItem.type = DataManager.instance.m_configData.localEncryptData(string: item.type.description)
        _addItem.did = DataManager.instance.m_configData.localEncryptData(string: item.did.description)
        _addItem.srl = DataManager.instance.m_configData.localEncryptData(string: item.srl)
        _addItem.enc = DataManager.instance.m_configData.localEncryptData(string: item.enc)
        _addItem.login_aid = DataManager.instance.m_configData.localEncryptData(string: item.login_aid.description)
        _addItem.cid = DataManager.instance.m_configData.localEncryptData(string: item.cid.description)
    }

    func deleteItemsLoginAid(loginAid: Int) {
        let _coreData = DataManager.instance.m_coreDataInfo
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: m_entityName)
        fetchRequest.returnsObjectsAsFaults = false
        
        do
        {
            let objects = try _coreData.context.fetch(fetchRequest)
            for item in objects
            {
                let match = item as! NSManagedObject
                let _login_aid = _coreData.getValueInt(obj: match, key: "login_aid")
                if (_login_aid == loginAid) {
                    _coreData.context.delete(match)
                }
            }
            _coreData.saveData()
        } catch let error as NSError {
            Debug.print("[ERROR] StoreConnectedSensor Error with request: \(error)", event: .error)
        }
    }
    
    func deleteItemsByAdvName(adv: String, login_aid: Int) {
        let _coreData = DataManager.instance.m_coreDataInfo
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: m_entityName)
        fetchRequest.returnsObjectsAsFaults = false
        
        do
        {
            let objects = try _coreData.context.fetch(fetchRequest)
            for item in objects
            {
                let match = item as! NSManagedObject
                let _adv = _coreData.getValueString(obj: match, key: "adv")
                let _login_aid = _coreData.getValueInt(obj: match, key: "login_aid")
                if (_adv == adv && _login_aid == login_aid) {
                    _coreData.context.delete(match)
                }
            }
            _coreData.saveData()
        } catch let error as NSError {
            Debug.print("[ERROR] StoreConnectedSensor Error with request: \(error)", event: .error)
        }
    }
    
    func deleteItemsByDid(did: Int, login_aid: Int) {
        let _coreData = DataManager.instance.m_coreDataInfo
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: m_entityName)
        fetchRequest.returnsObjectsAsFaults = false
        
        do
        {
            let objects = try _coreData.context.fetch(fetchRequest)
            for item in objects
            {
                let match = item as! NSManagedObject
                let _did = _coreData.getValueInt(obj: match, key: "did")
                let _login_aid = _coreData.getValueInt(obj: match, key: "login_aid")
                if (_did == did && _login_aid == login_aid) {
                    _coreData.context.delete(match)
                }
            }
            _coreData.saveData()
        } catch let error as NSError {
            Debug.print("[ERROR] StoreConnectedSensor Error with request: \(error)", event: .error)
        }
    }
    
    func updateItem(info: StoreConnectedSensorInfo) {
        let _coreData = DataManager.instance.m_coreDataInfo
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: m_entityName)
        do{
            let objects = try _coreData.context.fetch(fetchRequest)
            if objects.count > 0 {
                for item in objects {
                    let match = item as! NSManagedObject
                    let _type = Int(_coreData.getValueString(obj: match, key: "type")) ?? DEVICE_TYPE.Sensor.rawValue
                    let _did = _coreData.getValueInt(obj: match, key: "did")
                    let _login_aid = _coreData.getValueInt(obj: match, key: "login_aid")
                    if (_type == info.type && _did == info.did && _login_aid == info.login_aid) {
                        _coreData.setValueString(obj: match, key: "adv", value: info.adv)
                        _coreData.setValueString(obj: match, key: "uuid", value: info.uuid)
                        _coreData.setValueString(obj: match, key: "srl", value: info.srl)
                        _coreData.setValueString(obj: match, key: "enc", value: info.enc)
                        _coreData.setValueInt(obj: match, key: "cid", value: info.cid)
                    }
                }
                _coreData.saveData()
            }
        } catch let error as NSError {
            Debug.print("[ERROR] StoreConnectedSensor Error with request: \(error)", event: .error)
        }
    }
    
    func addItem(item: StoreConnectedSensorInfo, isBackground: Bool = false) {
        let _coreData = DataManager.instance.m_coreDataInfo
        let _entity = _coreData.getEntity(name: m_entityName)
        addItemToEntity(entity: _entity!, item: item, isBackground: isBackground)
        if (isBackground) {
            _coreData.backgroundSaveData()
        } else {
            _coreData.saveData()
        }
    }
    
    func addItems(list: Array<StoreConnectedSensorInfo>, isBackground: Bool = false) {
        let _coreData = DataManager.instance.m_coreDataInfo
        let _entity = _coreData.getEntity(name: m_entityName)
        for item in list {
            addItemToEntity(entity: _entity!, item: item, isBackground: isBackground)
        }
        if (isBackground) {
            _coreData.backgroundSaveData()
        } else {
            _coreData.saveData()
        }
    }

    func load() -> Array<StoreConnectedSensorInfo>? {
        let _coreData = DataManager.instance.m_coreDataInfo
        var _arrData = [StoreConnectedSensorInfo]()
        
        let _entity = _coreData.getEntity(name: m_entityName)
        let request = NSFetchRequest<NSFetchRequestResult>()
        request.entity = _entity
        
        do{
            let objects = try _coreData.context.fetch(request)
            if objects.count > 0 {
                for item in objects {
                    let match = item as! NSManagedObject
                    let _adv = _coreData.getValueString(obj: match, key: "adv")
                    let _uuid = _coreData.getValueString(obj: match, key: "uuid")
                    let _type = Int(_coreData.getValueString(obj: match, key: "type")) ?? DEVICE_TYPE.Sensor.rawValue
                    let _did = _coreData.getValueInt(obj: match, key: "did")
                    let _srl = _coreData.getValueString(obj: match, key: "srl")
                    let _enc = _coreData.getValueString(obj: match, key: "enc")
                    let _login_aid = _coreData.getValueInt(obj: match, key: "login_aid")
                    let _cid = _coreData.getValueInt(obj: match, key: "cid")
                    let _info = StoreConnectedSensorInfo(adv: _adv,
                                                         uuid: _uuid,
                                                         type: _type,
                                                         did: _did,
                                                         srl: _srl,
                                                         enc: _enc,
                                                         login_aid: _login_aid,
                                                         cid: _cid
                                                         )
                    _arrData.append(_info)
                }
            }
        } catch let error as NSError {
            Debug.print("[ERROR] StoreConnectedSensor Error with request: \(error)", event: .error)
        }
        
        return _arrData
    }
}
