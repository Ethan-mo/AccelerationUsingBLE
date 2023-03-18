//
//  DataController_hubGraph.swift
//  Monit
//
//  Created by 맥 on 2017. 9. 27..
//  Copyright © 2017년 맥. All rights reserved.
//

import Foundation
import SwiftyJSON

// id를 발급하기 위해 코어데이터에 먼저 삽입 후, 런타임 데이터에 저장한다.
class DataController_SensorVocGraph {
    
    var m_updateAction: Action?
    
    func setInit() {
        loadCoreDataToLocal()
    }
    
    func loadCoreDataToLocal() {
        DataManager.instance.m_coreDataInfo.storeSensorVocGraph.deleteOldData()
        let _arrData = DataManager.instance.m_coreDataInfo.storeSensorVocGraph.load()
        DataManager.instance.m_coreDataInfo.storeSensorVocGraph.lastId = lastId(arrData: _arrData)
        DataManager.instance.m_userInfo.sensorVocGraph.m_lst = _arrData!
    }
    
    func lastId(arrData: [StoreSensorVocGraphInfo]?) -> Int {
        var _retValue = 0
        if let _list = arrData {
            for item in _list {
                if (_retValue < item.m_id) {
                    _retValue = item.m_id
                }
            }
        }
        return _retValue
    }
    
    func saveData(arrInfo: Array<StoreSensorVocGraphInfo>?) {
        if let _arrInfo = arrInfo {
            addItems(items: _arrInfo)
        }
    }
    
    func addItem(item: StoreSensorVocGraphInfo, isBackground: Bool = false) {
        let _entity = DataManager.instance.m_coreDataInfo.getEntity(name: DataManager.instance.m_coreDataInfo.storeSensorVocGraph.m_entityName)
        if (!(DataManager.instance.m_userInfo.sensorVocGraph.isExist(item: item))) {
            item.m_id = DataManager.instance.m_coreDataInfo.storeSensorVocGraph.addItemToEntity(entity: _entity!, item: item, isBackground: isBackground)
            DataManager.instance.m_userInfo.sensorVocGraph.addItem(arr: [item])
        }
        if (isBackground) {
            DataManager.instance.m_coreDataInfo.backgroundSaveData()
        } else {
            DataManager.instance.m_coreDataInfo.saveData()
        }
    }
    
    func addItems(items: [StoreSensorVocGraphInfo], isBackground: Bool = false) {
        let _entity = DataManager.instance.m_coreDataInfo.getEntity(name: DataManager.instance.m_coreDataInfo.storeSensorVocGraph.m_entityName)
        for item in items {
            if (!(DataManager.instance.m_userInfo.sensorVocGraph.isExist(item: item))) {
                item.m_id = DataManager.instance.m_coreDataInfo.storeSensorVocGraph.addItemToEntity(entity: _entity!, item: item, isBackground: isBackground)
                DataManager.instance.m_userInfo.sensorVocGraph.addItem(arr: [item])
            }
        }
        if (isBackground) {
            DataManager.instance.m_coreDataInfo.backgroundSaveData()
        } else {
            DataManager.instance.m_coreDataInfo.saveData()
        }
    }
    
    var m_isDataUpdating = false
    func updateByDid(did: Int, handler: ActionResultBool? = nil) {
        if (m_isDataUpdating) {
            Debug.print("isNotiUpdating..", event: .warning)
            handler?(false)
            return
        }
        
        self.m_isDataUpdating = true
        sendUpdateByDid(did: did, handler: { (receiveInfo) -> () in
            if let _info = receiveInfo {
                self.addItem(item: _info)
                handler?(true)
            }
            self.m_isDataUpdating = false
        })
    }
    
    func sendUpdateByDid(did: Int, handler: @escaping (StoreSensorVocGraphInfo?) -> Void) {
        let send = Send_GetSensorVocGraphList()
        send.isErrorPopupOn = false
        send.isIndicator = false
        send.aid = DataManager.instance.m_userInfo.account_id
        send.did = did
        send.token = DataManager.instance.m_userInfo.token
        send.time = UI_Utility.convertDateToString(DataManager.instance.m_userInfo.sensorVocGraph.getLastTimeByDid(did: did), type: .yyMMdd_HHmmss)
        NetworkManager.instance.Request(send) { (json) -> () in
            let receive = Receive_GetSensorVocGraphList(json)
            switch receive.ecd {
            case .success:
                if (receive.time ?? "" != "") {
                    handler(StoreSensorVocGraphInfo(id: 0, did: did, time: receive.time ?? "", voc: receive.voc ?? "", cnt: receive.cnt ?? 0))
                } else {
                    handler(nil)
                }
            default:
                Debug.print("[ERROR] invaild errcod", event: .error)
                handler(nil)
            }
        }
    }
}

