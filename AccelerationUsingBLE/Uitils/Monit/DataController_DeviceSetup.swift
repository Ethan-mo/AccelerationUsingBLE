//
//  DataController_DeviceSetup.swift
//  Monit
//
//  Created by 맥 on 2017. 9. 29..
//  Copyright © 2017년 맥. All rights reserved.
//

import Foundation

class DataController_DeviceSetup {
    
    func setInit() {
        sensorLoadCoreDataToLocal()
        DataManager.instance.m_userInfo.deviceSetup.m_sensorSetup.noneInputData()
        sensorSaveLocalToCoreData()
        
        hubLoadCoreDataToLocal()
        DataManager.instance.m_userInfo.deviceSetup.m_hubSetup.noneInputData()
        hubSaveLocalToCoreData()
    }
    
    func sensorLoadCoreDataToLocal() {
        let _arrData = DataManager.instance.m_coreDataInfo.sensorSetup.load()
        DataManager.instance.m_userInfo.deviceSetup.m_sensorSetup.m_sensorSetup = _arrData
    }
    
    func sensorSaveLocalToCoreData() {
        let _arrData = DataManager.instance.m_userInfo.deviceSetup.m_sensorSetup.m_sensorSetup
        DataManager.instance.m_coreDataInfo.sensorSetup.deleteAllAndSave(list: _arrData!)
    }
    
    func hubLoadCoreDataToLocal() {
        let _arrData = DataManager.instance.m_coreDataInfo.hubSetup.load()
        DataManager.instance.m_userInfo.deviceSetup.m_hubSetup.m_hubSetup = _arrData
    }
    
    func hubSaveLocalToCoreData() {
        let _arrData = DataManager.instance.m_userInfo.deviceSetup.m_hubSetup.m_hubSetup
        DataManager.instance.m_coreDataInfo.hubSetup.deleteAllAndSave(list: _arrData!)
    }
}
