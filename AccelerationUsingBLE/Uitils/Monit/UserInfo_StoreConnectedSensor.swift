//
//  UserInfo_StoreConnectedSensor.swift
//  Monit
//
//  Created by 맥 on 2017. 10. 17..
//  Copyright © 2017년 맥. All rights reserved.
//

import Foundation

import Foundation
import CoreBluetooth
import CoreData

class StoreConnectedSensorInfo {
    var adv: String = ""
    var uuid : String = ""
    var type: Int
    var did: Int
    var srl: String
    var enc: String
    var login_aid: Int
    var cid: Int
    
    init(adv: String, uuid : String, type: Int, did: Int, srl: String, enc: String, login_aid: Int, cid: Int) {
        self.adv = adv
        self.uuid = uuid
        self.type = type
        self.did = did
        self.srl = srl
        self.enc = enc
        self.login_aid = login_aid
        self.cid = cid
    }
}

class UserInfo_StoreConnectedSensor {
    var m_storeConnectedSensor: Array<StoreConnectedSensorInfo>?

    // 서버에서는 연결된 정보가 있어도 로컬 coredata는 없을 수 있다.
    // 서버에는 없어도 로컬 coredata는 있을 수 있다.
    // 기기삭제시 coredata에서 지워준다.
    func syncByData() {
        var _newList = [StoreConnectedSensorInfo]()
        for item in m_storeConnectedSensor! {
            if (item.login_aid == DataManager.instance.m_userInfo.account_id && item.did != 0) {
                var _isFound = false
                for itemNew in _newList {
                    if (itemNew.adv == item.adv) {
                        _isFound = true
                        break
                    }
                }
                if (!_isFound) {
                    _newList.append(item)
                }
            }
        }
        m_storeConnectedSensor = _newList
        for item in m_storeConnectedSensor! {
            Debug.print("StoreItem: \(item.type)\(item.cid),\(item.did),\(item.adv)", event: .warning)
        }
    }
    
    func getInfoByDid(did: Int) -> StoreConnectedSensorInfo? {
        if let _info = m_storeConnectedSensor {
            for item in _info {
                if (item.did == did) {
                    return item
                }
            }
        }
        
        return nil
    }

    func getInfoByAvd(avd: String) -> StoreConnectedSensorInfo? {
        if let _info = m_storeConnectedSensor {
            for item in _info {
                if (item.adv == avd) {
                    return item
                }
            }
        }
        
        return nil
    }
    
    func insertOrUpdate(info: StoreConnectedSensorInfo) {
        var _i = -1
        for (i, item) in m_storeConnectedSensor!.enumerated() {
            if (item.did == info.did && item.login_aid == item.login_aid) {
                _i = i
            }
        }
        if (_i != -1) {
//            // update
//            m_storeConnectedSensor?[_i] = info
            DataManager.instance.m_coreDataInfo.storeConnectedSensor.updateItem(info: info)
        } else {
//            // insert
//            m_storeConnectedSensor?.append(info)
            DataManager.instance.m_coreDataInfo.storeConnectedSensor.addItem(item: info)
        }
        syncByData()
    }

    func deleteItemByAdv(adv: String) {
        var _i = -1
        for (i, item) in m_storeConnectedSensor!.enumerated() {
            if (item.adv == adv) {
                _i = i
                break
            }
        }
        if (_i != -1) {
            // update
            m_storeConnectedSensor?.remove(at: _i)
            DataManager.instance.m_coreDataInfo.storeConnectedSensor.deleteItemsByAdvName(adv: adv, login_aid: DataManager.instance.m_userInfo.account_id)
        }
    }
    
    func deleteItemByDid(did: Int) {
        var _i = -1
        for (i, item) in m_storeConnectedSensor!.enumerated() {
            if (item.did == did) {
                _i = i
                break
            }
        }
        if (_i != -1) {
            // update
            m_storeConnectedSensor?.remove(at: _i)
            DataManager.instance.m_coreDataInfo.storeConnectedSensor.deleteItemsByDid(did: did, login_aid: DataManager.instance.m_userInfo.account_id)
        }
    }
    
    func deleteItemForLeaved() {
        DataManager.instance.m_coreDataInfo.storeConnectedSensor.deleteItemsLoginAid(loginAid: DataManager.instance.m_userInfo.account_id)
    }
}
