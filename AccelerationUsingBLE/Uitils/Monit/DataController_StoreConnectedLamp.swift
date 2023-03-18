//
//  DataController_StoreConnectedLamp.swift
//  Monit
//
//  Created by 맥 on 2017. 10. 17..
//  Copyright © 2017년 맥. All rights reserved.
//

import Foundation

class DataController_StoreConnectedLamp {
    
    func setInit() {
        loadCoreDataToLocal()
         DataManager.instance.m_userInfo.storeConnectedLamp.syncByData()
//        saveLocalToCoreData()
    }
    
    func loadCoreDataToLocal() {
        let _arrData = DataManager.instance.m_coreDataInfo.storeConnectedLamp.load()
        DataManager.instance.m_userInfo.storeConnectedLamp.m_storeConnectedLamp = _arrData
    }
    
//    func saveLocalToCoreData() {
//        let _arrData = DataManager.instance.m_userInfo.storeConnectedLamp.m_storeConnectedLamp
//        DataManager.instance.m_coreDataInfo.storeConnectedLamp.deleteAllAndSave(list: _arrData!)
//    }
}
