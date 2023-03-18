//
//  DataController_StoreConnectedSensor.swift
//  Monit
//
//  Created by 맥 on 2017. 10. 17..
//  Copyright © 2017년 맥. All rights reserved.
//

import Foundation

class DataController_StoreConnectedSensor {
    
    func setInit() {
        loadCoreDataToLocal()
         DataManager.instance.m_userInfo.storeConnectedSensor.syncByData()
//        saveLocalToCoreData()
    }
    
    func loadCoreDataToLocal() {
        let _arrData = DataManager.instance.m_coreDataInfo.storeConnectedSensor.load()
        DataManager.instance.m_userInfo.storeConnectedSensor.m_storeConnectedSensor = _arrData
    }
    
//    func saveLocalToCoreData() {
//        let _arrData = DataManager.instance.m_userInfo.storeConnectedSensor.m_storeConnectedSensor
//        DataManager.instance.m_coreDataInfo.storeConnectedSensor.deleteAllAndSave(list: _arrData!)
//    }
}
