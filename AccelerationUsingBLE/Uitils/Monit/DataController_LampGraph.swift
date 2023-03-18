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
class DataController_LampGraph {
    
    var m_updateAction: Action?
    
    func setInit() {
        loadCoreDataToLocal()
    }
    
    func loadCoreDataToLocal() {
        DataManager.instance.m_coreDataInfo.storeLampGraph.deleteOldData()
        let _arrData = DataManager.instance.m_coreDataInfo.storeLampGraph.load()
        DataManager.instance.m_coreDataInfo.storeLampGraph.lastId = lastId(arrData: _arrData)
        DataManager.instance.m_userInfo.lampGraph.m_lst = _arrData!
    }
    
    func lastId(arrData: [LampGraphInfo]?) -> Int {
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
    
    func saveData(arrInfo: Array<LampGraphInfo>?) {
        if let _arrInfo = arrInfo {
            addItems(items: _arrInfo)
        }
    }
    
    func addItem(item: LampGraphInfo, isBackground: Bool = false) {
        let _entity = DataManager.instance.m_coreDataInfo.getEntity(name: DataManager.instance.m_coreDataInfo.storeLampGraph.m_entityName)
        if (!(DataManager.instance.m_userInfo.lampGraph.isExist(item: item))) {
            item.m_id = DataManager.instance.m_coreDataInfo.storeLampGraph.addItemToEntity(entity: _entity!, item: item, isBackground: isBackground)
            DataManager.instance.m_userInfo.lampGraph.addItem(arr: [item])
        }
        if (isBackground) {
            DataManager.instance.m_coreDataInfo.backgroundSaveData()
        } else {
            DataManager.instance.m_coreDataInfo.saveData()
        }
    }
    
    func addItems(items: [LampGraphInfo], isBackground: Bool = false) {
        let _entity = DataManager.instance.m_coreDataInfo.getEntity(name: DataManager.instance.m_coreDataInfo.storeLampGraph.m_entityName)
        for item in items {
            if (!(DataManager.instance.m_userInfo.lampGraph.isExist(item: item))) {
                item.m_id = DataManager.instance.m_coreDataInfo.storeLampGraph.addItemToEntity(entity: _entity!, item: item, isBackground: isBackground)
                DataManager.instance.m_userInfo.lampGraph.addItem(arr: [item])
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
        sendUpdateByDid(did: did, handler: { (arrInfo) -> () in
            if let _arrInfo = arrInfo {
                if (_arrInfo.count > 0) {
                    if (_arrInfo.count > 30) {
                        let _progress = UIManager.instance.progressView(title: "toast_noti_loading".localized)
                        DispatchQueue.global(qos: .background).async {
                            for (i, item) in _arrInfo.enumerated() {
                                //                                Thread.sleep(forTimeInterval: 0.0001)
                                self.addItem(item: item, isBackground: true)
                                DispatchQueue.main.async(flags: .barrier) {
                                    _progress.progressValue =  Float(i) / Float(_arrInfo.count)
                                }
                            }
                            DispatchQueue.main.async {
                                _progress.progressValue = 1
                                _progress.close()
                                self.m_isDataUpdating = false
                                handler?(true)
                            }
                        }
                    } else {
                        for item in _arrInfo {
                            self.addItem(item: item)
                        }
                        self.m_isDataUpdating = false
                        handler?(true)
                    }
                } else {
                    self.m_isDataUpdating = false
                    handler?(true)
                }
            } else {
                self.m_isDataUpdating = false
                handler?(true)
            }
        })
    }
    
    func sendUpdateByDid(did: Int, handler: @escaping (Array<LampGraphInfo>?) -> Void) {
        let send = Send_GetLampGraphList()
        send.isErrorPopupOn = false
        send.isIndicator = false
        send.aid = DataManager.instance.m_userInfo.account_id
        send.did = did
        send.token = DataManager.instance.m_userInfo.token
        send.time = UI_Utility.convertDateToString(DataManager.instance.m_userInfo.lampGraph.getLastTimeByDid(did: did), type: .yyMMdd_HHmmss)
        NetworkManager.instance.Request(send) { (json) -> () in
            let receive = Receive_GetLampGraphList(json)
            switch receive.ecd {
            case .success:
                receive.convert(did: did)
                handler(receive.lst)
            default:
                Debug.print("[ERROR] invaild errcod", event: .error)
                handler(nil)
            }
        }
    }
}

