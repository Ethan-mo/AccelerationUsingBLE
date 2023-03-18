//
//  UserInfo_StoreConnectedLamp.swift
//  Monit
//
//  Created by 맥 on 2017. 10. 17..
//  Copyright © 2017년 맥. All rights reserved.
//

import Foundation

import Foundation
import CoreBluetooth
import CoreData

class StoreConnectedLampInfo {
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

class UserInfo_StoreConnectedLamp {
    var m_storeConnectedLamp: Array<StoreConnectedLampInfo>?

    // 서버에서는 연결된 정보가 있어도 로컬 coredata는 없을 수 있다.
    // 서버에는 없어도 로컬 coredata는 있을 수 있다.
    // 기기삭제시 coredata에서 지워준다.
    func syncByData() {
        var _newList = [StoreConnectedLampInfo]()
        for item in m_storeConnectedLamp! {
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
        m_storeConnectedLamp = _newList
        for item in m_storeConnectedLamp! {
            Debug.print("StoreItem: \(item.type)\(item.cid),\(item.did),\(item.adv)", event: .warning)
        }
    }
    
    func getInfoByDid(did: Int) -> StoreConnectedLampInfo? {
        if let _info = m_storeConnectedLamp {
            for item in _info {
                if (item.did == did) {
                    return item
                }
            }
        }
        
        return nil
    }

    func getInfoByAvd(avd: String) -> StoreConnectedLampInfo? {
        if let _info = m_storeConnectedLamp {
            for item in _info {
                if (item.adv == avd) {
                    return item
                }
            }
        }
        
        return nil
    }
    
    func insertOrUpdate(info: StoreConnectedLampInfo) {
        var _i = -1
        for (i, item) in m_storeConnectedLamp!.enumerated() {
            if (item.did == info.did && item.login_aid == item.login_aid) {
                _i = i
            }
        }
        if (_i != -1) {
//            // update
//            m_storeConnectedLamp?[_i] = info
            DataManager.instance.m_coreDataInfo.storeConnectedLamp.updateItem(info: info)
        } else {
//            // insert
//            m_storeConnectedLamp?.append(info)
            DataManager.instance.m_coreDataInfo.storeConnectedLamp.addItem(item: info)
        }
        syncByData()
    }

    func deleteItemByAdv(adv: String) {
        var _i = -1
        for (i, item) in m_storeConnectedLamp!.enumerated() {
            if (item.adv == adv) {
                _i = i
                break
            }
        }
        if (_i != -1) {
            // update
            m_storeConnectedLamp?.remove(at: _i)
            DataManager.instance.m_coreDataInfo.storeConnectedLamp.deleteItemsByAdvName(adv: adv, login_aid: DataManager.instance.m_userInfo.account_id)
        }
    }
    
    func deleteItemByDid(did: Int) {
        var _i = -1
        for (i, item) in m_storeConnectedLamp!.enumerated() {
            if (item.did == did) {
                _i = i
                break
            }
        }
        if (_i != -1) {
            // update
            m_storeConnectedLamp?.remove(at: _i)
            DataManager.instance.m_coreDataInfo.storeConnectedLamp.deleteItemsByDid(did: did, login_aid: DataManager.instance.m_userInfo.account_id)
        }
    }
    
    func deleteItemForLeaved() {
        DataManager.instance.m_coreDataInfo.storeConnectedLamp.deleteItemsLoginAid(loginAid: DataManager.instance.m_userInfo.account_id)
    }
}
