//
//  SensorStatusInfo.swift
//  Monit
//
//  Created by 맥 on 2017. 9. 25..
//  Copyright © 2017년 맥. All rights reserved.
//

import Foundation

class UserInfo_SensorStatus {
    var m_sensor: Array<SensorStatusInfo>?
    
    func getInfoByDeviceId(did: Int) -> SensorStatusInfo? {
        if (m_sensor == nil) {
            return nil
        }
        
        for item in m_sensor! {
            if (item.m_did == did) {
                return item
            }
        }
        return nil
    }

    func updateFullStatusInfo(arrStatus: Array<SensorStatusInfo>) {
        m_sensor = arrStatus
    }
    
    // 서버값 업데이트
    func updateStatusInfo(arrStatus: Array<SensorStatusInfo>) {
        for item in arrStatus {
            // 센서가 직접 연결되어도 업데이트 되어야 하는 값
            let _status = getInfoByDeviceId(did: item.m_did)
            if (_status != nil) {
                _status?.m_voc_avg = item.m_voc_avg
                _status?.m_dscore = item.m_dscore
            } else {
                Debug.print("SensorStatusInfo >  getInfoByDeviceId > Not Found Item ", event: .warning)
                UIManager.instance.currentUIReload()
            }

            // connecting direct sensor
            if (DataManager.instance.m_userInfo.connectSensor.getSensorByDeviceId(deviceId: item.m_did) != nil) {
                if let _status = getInfoByDeviceId(did: item.m_did) {
                    _status.m_whereConn = item.m_whereConn
                }
                continue
            }

            if (_status != nil) {
                _status?.m_battery = item.m_battery
                _status?.m_operation = item.m_operation
                _status?.m_movement = item.m_movement
                _status?.m_diaperstatus = item.m_diaperstatus
                _status?.m_temp = item.m_temp
                _status?.m_hum = item.m_hum
                _status?.m_voc = item.m_voc
                _status?.m_con = item.m_con
                _status?.m_whereConn = item.m_whereConn
                _status?.m_voc_avg = item.m_voc_avg
                _status?.m_dscore = item.m_dscore
            } else {
                Debug.print("SensorStatusInfo >  getInfoByDeviceId > Not Found Item ", event: .warning)
                UIManager.instance.currentUIReload()
            }
        }
    }
    
    func isEqualInfo(newStatusInfo: Array<SensorStatusInfo>?) -> Bool {
        if let _beforeInfo = m_sensor {
            if let _newInfo = newStatusInfo {
                for beforeItem in _beforeInfo {
                    var _isFound = false
                    for newItem in _newInfo {
                        if (beforeItem.m_did == newItem.m_did) {
                            _isFound = true
                        }
                    }
                    if (!_isFound) {
                        return false
                    }
                }
                
                for newItem in _newInfo {
                    var _isFound = false
                    for beforeItem in _beforeInfo {
                        if (beforeItem.m_did == newItem.m_did) {
                            _isFound = true
                        }
                    }
                    if (!_isFound) {
                        return false
                    }
                }
            }
        }
        
        return true
    }
}
