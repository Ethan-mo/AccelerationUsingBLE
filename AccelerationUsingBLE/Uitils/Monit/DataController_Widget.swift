//
//  DataController_Widget.swift
//  Monit
//
//  Created by john.lee on 2019. 3. 21..
//  Copyright © 2019년 맥. All rights reserved.
//

import Foundation

class DataController_Widget {
    let WIDGET_DEVICE_SENSOR_LIST = "widget_device_sensor_list"
    let WIDGET_DEVICE_HUB_LIST = "widget_device_hub_list"
    let WIDGET_DEVICE_LAMP_LIST = "widget_device_lamp_list"
    
    var getTotalCount: Int {
        get {
            return getWidgetDevice(type: .Sensor).count + getWidgetDevice(type: .Hub).count
        }
    }
    
    func getLocalString(type: DEVICE_TYPE) -> String {
        var _listString = ""
        switch type {
        case .Sensor: _listString = WIDGET_DEVICE_SENSOR_LIST
        case .Hub: _listString = WIDGET_DEVICE_HUB_LIST
        case .Lamp: _listString = WIDGET_DEVICE_LAMP_LIST
        }
        return _listString
    }
    
    func isContainsDevice(type: DEVICE_TYPE, did: Int) -> Bool {
        let _list = getWidgetDevice(type: type)
        if (_list.contains(did)) {
            return true
        }
        return false
    }
    
    func getWidgetDevice(type: DEVICE_TYPE) -> [Int] {
        var _retValue: [Int] = []
        let _list = DataManager.instance.m_configData.getLocalStringAes256(name: getLocalString(type: type))
        guard (_list != "") else {
            return _retValue
        }
        
        let _arrList = _list.split(separator: ",")
        for item in _arrList {
            if let _item = Int(item) {
                _retValue.append(_item)
            }
        }
        return _retValue
    }
    
    func addWidgetDevice(type: DEVICE_TYPE, did: Int) {
        var _list = getWidgetDevice(type: type)
        if (!_list.contains(did)) {
            _list.append(did)
        }
        DataManager.instance.m_configData.setLocalAes256(name: getLocalString(type: type), value: _list.map {"\($0)"}.joined(separator: ","))
        
        updateSetSharedDeviceList()
    }
    
    func removeWidgetDevice(type: DEVICE_TYPE, did: Int) {
        var _list = getWidgetDevice(type: type)
        
        if let _index = _list.index(of: did) {
            _list.remove(at: _index)
        }
        DataManager.instance.m_configData.setLocalAes256(name: getLocalString(type: type), value: _list.map {"\($0)"}.joined(separator: ","))
        
        updateSetSharedDeviceList()
    }
    
    func updateSetSharedDeviceList() {
        Widget_Utility.setSharedInfo(channel: Config.channelOsNum, key: .deviceSensorList, value: DataManager.instance.m_configData.getLocalStringAes256(name: WIDGET_DEVICE_SENSOR_LIST))
        Widget_Utility.setSharedInfo(channel: Config.channelOsNum, key: .deviceHubList, value: DataManager.instance.m_configData.getLocalStringAes256(name: WIDGET_DEVICE_HUB_LIST))
        Widget_Utility.setSharedInfo(channel: Config.channelOsNum, key: .deviceLampList, value: DataManager.instance.m_configData.getLocalStringAes256(name: WIDGET_DEVICE_LAMP_LIST))
    }
}
