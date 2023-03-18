//
//  DataController_ShareMemberNoti.swift
//  Monit
//
//  Created by 맥 on 2017. 9. 27..
//  Copyright © 2017년 맥. All rights reserved.
//

import Foundation
import SwiftyJSON

// id를 발급하기 위해 코어데이터에 먼저 삽입 후, 런타임 데이터에 저장한다.
class DataController_ShareMemberNoti {
    
    var m_updateAction: Action?
    
    func setInit() {
        loadCoreDataToLocal()
    }
    
    func loadCoreDataToLocal() {
        let _arrData = DataManager.instance.m_coreDataInfo.storeShareMemberNoti.load()
        DataManager.instance.m_coreDataInfo.storeShareMemberNoti.lastId = lastId(arrData: _arrData)
        DataManager.instance.m_userInfo.shareMemberNoti.m_shareMemberNoti = _arrData!
    }
    
    func lastId(arrData: [ShareMemberNotiInfo]?) -> Int {
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

    func saveData(arrNotiInfo: Array<ShareMemberNotiInfo>?) {
        if let _arrNotiInfo = arrNotiInfo {
            addItems(items: _arrNotiInfo)
        }
    }
    
    func addItem(item: ShareMemberNotiInfo, isBackground: Bool = false) {
        let _entity = DataManager.instance.m_coreDataInfo.getEntity(name: DataManager.instance.m_coreDataInfo.storeShareMemberNoti.m_entityName)
        if (!(DataManager.instance.m_userInfo.shareMemberNoti.isExist(item: item))) {
            item.m_id = DataManager.instance.m_coreDataInfo.storeShareMemberNoti.addItemToEntity(entity: _entity!, item: item, isBackground: isBackground)
            DataManager.instance.m_userInfo.shareMemberNoti.addNoti(arr: [item])
        }
        if (isBackground) {
            DataManager.instance.m_coreDataInfo.backgroundSaveData()
        } else {
            DataManager.instance.m_coreDataInfo.saveData()
        }
    }
    
    func addItems(items: [ShareMemberNotiInfo], isBackground: Bool = false) {
        let _entity = DataManager.instance.m_coreDataInfo.getEntity(name: DataManager.instance.m_coreDataInfo.storeShareMemberNoti.m_entityName)
        for item in items {
            if (!(DataManager.instance.m_userInfo.shareMemberNoti.isExist(item: item))) {
                item.m_id = DataManager.instance.m_coreDataInfo.storeShareMemberNoti.addItemToEntity(entity: _entity!, item: item, isBackground: isBackground)
                DataManager.instance.m_userInfo.shareMemberNoti.addNoti(arr: [item])
            }
        }
        if (isBackground) {
            DataManager.instance.m_coreDataInfo.backgroundSaveData()
        } else {
            DataManager.instance.m_coreDataInfo.saveData()
        }
    }
    
    func updateForDetailView() {
        if let _currentView = UIManager.instance.rootCurrentView {
            if let _view = _currentView as? ShareMemberMainV2ViewController {
                _view.reloadNoti()
            }
        }
    }
    
    var m_isNotiUpdating = false
    func updateNoti() {
        if (m_isNotiUpdating) {
            Debug.print("isNotiUpdating..", event: .warning)
            return
        }
        
        self.m_isNotiUpdating = true
        sendUpdate(handler: { (arrNotiInfo) -> () in
            if let _arrNotiInfo = arrNotiInfo {
                if (_arrNotiInfo.count > 0) {
                    if (_arrNotiInfo.count > 30) {
                        let _progress = UIManager.instance.progressView(title: "toast_noti_loading".localized)
                        DispatchQueue.global(qos: .background).async {
                            for (i, item) in _arrNotiInfo.enumerated() {
                                self.addItem(item: item, isBackground: true)
                                DispatchQueue.main.async(flags: .barrier) {
                                    _progress.progressValue =  Float(i) / Float(_arrNotiInfo.count)
                                }
                            }
                            DispatchQueue.main.async {
                                _progress.progressValue = 1
                                _progress.close()
                            }
                            self.m_isNotiUpdating = false
                            UIManager.instance.currentUIReload()
                        }
                    } else {
                        for item in _arrNotiInfo {
                            self.addItem(item: item)
                        }
                        self.m_isNotiUpdating = false
                        UIManager.instance.currentUIReload()
                    }
                } else {
                    self.m_isNotiUpdating = false
                }
            } else {
                self.m_isNotiUpdating = false
            }
        })
    }
    
    func sendUpdate(handler: @escaping (Array<ShareMemberNotiInfo>?) -> Void) {
        let send = Send_GetCloudNotification()
        send.isErrorPopupOn = false
        send.isIndicator = false
        send.aid = DataManager.instance.m_userInfo.account_id
        send.token = DataManager.instance.m_userInfo.token
        send.time = UI_Utility.convertDateToString(DataManager.instance.m_userInfo.shareMemberNoti.getLastTime(), type: .yyMMdd_HHmmss)
        NetworkManager.instance.Request(send) { (json) -> () in
            let receive = Receive_GetCloudNotification(json)
            switch receive.ecd {
            case .success: handler(receive.notification)
            default:
                Debug.print("[ERROR] invaild errcod", event: .error)
                handler(nil)
            }
        }
    }
}

