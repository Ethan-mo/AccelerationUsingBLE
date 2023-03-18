//
//  DataController_DeviceStatus.swift
//  Monit
//
//  Created by 맥 on 2017. 10. 30..
//  Copyright © 2017년 맥. All rights reserved.
//

import UIKit
import SwiftyJSON

class DataController_DeviceStatus {
    
    private var m_updateFullStatusHandler: ((Bool) -> Void)?
    private var m_updateStatusHandler: ((Bool) -> Void)?
 
    func initFullStatus(handler: @escaping (Bool) -> Void) {
        m_updateFullStatusHandler = handler
        
        TimerManager.instance.startFullStatus()
        TimerManager.instance.startStatus()
        
        let send = Send_GetDeviceFullStatus()
        send.isResending = true
        send.aid = DataManager.instance.m_userInfo.account_id
        send.token = DataManager.instance.m_userInfo.token
        send.isIndicator = false
        send.logPrintLevel = .warning
        NetworkManager.instance.Request(send) { (json) -> () in
            self.receiveGetDeviceFullStatusForInit(json)
        }
    }
    
    func receiveGetDeviceFullStatusForInit(_ json: JSON) {
        let receive = Receive_GetDeviceFullStatus(json)
        switch receive.ecd {
        case .success:
            DataManager.instance.m_userInfo.deviceStatus.m_sensorStatus.updateFullStatusInfo(arrStatus: receive.arrSensorStatusInfo)
            DataManager.instance.m_userInfo.deviceStatus.m_hubStatus.updateFullStatusInfo(arrStatus: receive.arrHubStatusInfo)
            DataManager.instance.m_userInfo.deviceStatus.m_lampStatus.updateFullStatusInfo(arrStatus: receive.arrLampStatusInfo)
            if (m_updateFullStatusHandler != nil) {
                m_updateFullStatusHandler!(true)
            }
        default: Debug.print("[ERROR] invaild errcod", event: .error)
            if (m_updateFullStatusHandler != nil) {
                m_updateFullStatusHandler!(false)
            }
        }
    }
    
    func updateFullStatus(handler: @escaping (Bool) -> Void) {
        m_updateFullStatusHandler = handler

        TimerManager.instance.startFullStatus()
        TimerManager.instance.startStatus()

        let send = Send_GetDeviceFullStatus()
        send.existPopupType = "updateStatus"
//        send.isErrorPopupOn = false
        send.aid = DataManager.instance.m_userInfo.account_id
        send.token = DataManager.instance.m_userInfo.token
        send.isIndicator = false
        send.logPrintLevel = .warning
        NetworkManager.instance.Request(send) { (json) -> () in
            self.receiveGetDeviceFullStatus(json)
        }
    }
    
    func receiveGetDeviceFullStatus(_ json: JSON) {
        let receive = Receive_GetDeviceFullStatus(json)
        switch receive.ecd {
        case .success:
            var _isFail = false
            if (!(DataManager.instance.m_userInfo.deviceStatus.m_sensorStatus.isEqualInfo(newStatusInfo: receive.arrSensorStatusInfo))) {
                _isFail = true
            }
            DataManager.instance.m_userInfo.deviceStatus.m_sensorStatus.updateFullStatusInfo(arrStatus: receive.arrSensorStatusInfo)
            
            if (!(DataManager.instance.m_userInfo.deviceStatus.m_hubStatus.isEqualInfo(newStatusInfo: receive.arrHubStatusInfo))) {
                _isFail = true
            }
            DataManager.instance.m_userInfo.deviceStatus.m_hubStatus.updateFullStatusInfo(arrStatus: receive.arrHubStatusInfo)
            
            if (!(DataManager.instance.m_userInfo.deviceStatus.m_lampStatus.isEqualInfo(newStatusInfo: receive.arrLampStatusInfo))) {
                _isFail = true
            }
            DataManager.instance.m_userInfo.deviceStatus.m_lampStatus.updateFullStatusInfo(arrStatus: receive.arrLampStatusInfo)
            
            if (!(DataManager.instance.m_dataController.device.isDataVaildCheck)) {
                _isFail = true
            }
            
            if (!_isFail) {
                if (m_updateFullStatusHandler != nil) {
                    m_updateFullStatusHandler!(true)
                }
            } else {
                if (m_updateFullStatusHandler != nil) {
                    m_updateFullStatusHandler!(false)
                }
            }
        default: Debug.print("[ERROR] invaild errcod", event: .error)
            if (m_updateFullStatusHandler != nil) {
                m_updateFullStatusHandler!(false)
            }
        }
    }
    
    func updateStatus(handler: @escaping (Bool) -> Void) {
        m_updateStatusHandler = handler
        
        TimerManager.instance.startStatus()
        
        let send = Send_GetDeviceStatus()
        send.existPopupType = "updateStatus"
//        send.isErrorPopupOn = false
        send.aid = DataManager.instance.m_userInfo.account_id
        send.token = DataManager.instance.m_userInfo.token
        send.isIndicator = false
        send.logPrintLevel = .dev
        NetworkManager.instance.Request(send) { (json) -> () in
            self.receiveGetDeviceStatus(json)
        }
    }
    
    func receiveGetDeviceStatus(_ json: JSON) {
        let receive = Receive_GetDeviceStatus(json)
        switch receive.ecd {
        case .success:
            var _isFail = false
            if (!(DataManager.instance.m_userInfo.deviceStatus.m_sensorStatus.isEqualInfo(newStatusInfo: receive.arrSensorStatusInfo))) {
                _isFail = true
            }
            DataManager.instance.m_userInfo.deviceStatus.m_sensorStatus.updateStatusInfo(arrStatus: receive.arrSensorStatusInfo)
            
            if (!(DataManager.instance.m_userInfo.deviceStatus.m_hubStatus.isEqualInfo(newStatusInfo: receive.arrHubStatusInfo))) {
                _isFail = true
            }
            DataManager.instance.m_userInfo.deviceStatus.m_hubStatus.updateStatusInfo(arrStatus: receive.arrHubStatusInfo)
            
            if (!(DataManager.instance.m_userInfo.deviceStatus.m_lampStatus.isEqualInfo(newStatusInfo: receive.arrLampStatusInfo))) {
                _isFail = true
            }
            DataManager.instance.m_userInfo.deviceStatus.m_lampStatus.updateStatusInfo(arrStatus: receive.arrLampStatusInfo)
            
            if (!_isFail) {
                if (m_updateStatusHandler != nil) {
                    m_updateStatusHandler!(true)
                }
            } else {
                if (m_updateStatusHandler != nil) {
                    m_updateStatusHandler!(false)
                }
            }
        default: Debug.print("[ERROR] invaild errcod", event: .error)
            if (m_updateStatusHandler != nil) {
                m_updateStatusHandler!(false)
            }
        }
    }
    
    func sensorInit(did: Int, enc: String, adv: String, isGoInit: Bool = true) {
        let send = Send_InitDevice()
        send.aid = DataManager.instance.m_userInfo.account_id
        send.token = DataManager.instance.m_userInfo.token
        send.type = DEVICE_TYPE.Sensor.rawValue
        send.did = did
        send.enc = enc
        BleConnectionManager.instance.breakRetriveDevice()
        NetworkManager.instance.Request(send) { (json) -> () in
            let receive = Receive_InitDevice(json)
            switch receive.ecd {
            case .success:
                if let _bleInfo = DataManager.instance.m_userInfo.connectSensor.getSensorByDeviceId(deviceId: did) {
                    _bleInfo.controller!.m_packetCommend!.setInit(completion: { (isSuccess) in
                        if (isSuccess) {
                            self.deleteSensor(did: did, adv: adv)
                            if (isGoInit) {
                                _ = UIManager.instance.sceneMove(scene: .initView, animation: .coverVertical, isAnimation: false)
                            }
                        } else {
                            Debug.print("[ERROR] Sensor init invaild errcod", event: .error)
                            let _errStr = String(format: "dialog_contents_err_communication_with_server".localized, APP_ERR_COD.setSensorInit.rawValue)
                            _ = PopupManager.instance.onlyContentsCustom(contents: _errStr, confirmType: .ok, okHandler: { () -> () in
                            })
                        }
                    })
                } else {
                    self.deleteSensor(did: did, adv: adv)
                    if (isGoInit) {
                        _ = UIManager.instance.sceneMove(scene: .initView, animation: .coverVertical, isAnimation: false)
                    }
                }
            default:
                Debug.print("[ERROR] Send_InitDevice invaild errcod", event: .error)
                BleConnectionManager.instance.retrieveDevice()
                let _errStr = String(format: "dialog_contents_err_communication_with_server".localized, APP_ERR_COD.setSensorInit.rawValue)
                _ = PopupManager.instance.onlyContentsCustom(contents: _errStr, confirmType: .ok, okHandler: { () -> () in
                })
            }
        }
    }
    
    func lampInit(did: Int, enc: String, adv: String, isGoInit: Bool = true) {
        let send = Send_InitDevice()
        send.aid = DataManager.instance.m_userInfo.account_id
        send.token = DataManager.instance.m_userInfo.token
        send.type = DEVICE_TYPE.Lamp.rawValue
        send.did = did
        send.enc = enc
        BleConnectionLampManager.instance.breakRetriveDevice()
        NetworkManager.instance.Request(send) { (json) -> () in
            let receive = Receive_InitDevice(json)
            switch receive.ecd {
            case .success:
//                if let _bleInfo = DataManager.instance.m_userInfo.connectLamp.getLampByDeviceId(deviceId: did) {
//                    _bleInfo.controller!.m_packetCommend!.setInit(completion: { (isSuccess) in
//                        if (isSuccess) {
//                            self.deleteLamp(did: did, adv: adv)
//                            if (isGoInit) {
//                                _ = UIManager.instance.sceneMove(scene: .initView, animation: .coverVertical, isAnimation: false)
//                            }
//                        } else {
//                            Debug.print("[ERROR] Sensor init invaild errcod", event: .error)
//                            let _errStr = String(format: "dialog_contents_err_communication_with_server".localized, APP_ERR_COD.setSensorInit.rawValue)
//                            _ = PopupManager.instance.onlyContentsCustom(contents: _errStr, confirmType: .ok, okHandler: { () -> () in
//                            })
//                        }
//                    })
//                } else {
                    self.deleteLamp(did: did, adv: adv)
                    if (isGoInit) {
                        _ = UIManager.instance.sceneMove(scene: .initView, animation: .coverVertical, isAnimation: false)
                    }
//                }
            default:
                Debug.print("[ERROR] Send_InitDevice invaild errcod", event: .error)
                BleConnectionLampManager.instance.retrieveDevice()
                let _errStr = String(format: "dialog_contents_err_communication_with_server".localized, APP_ERR_COD.setSensorInit.rawValue)
                _ = PopupManager.instance.onlyContentsCustom(contents: _errStr, confirmType: .ok, okHandler: { () -> () in
                })
            }
        }
    }
    
    func sensorLeave(cid: Int, did:Int, adv: String) {
        if let _info = DataManager.instance.m_userInfo.shareMember.getOtherGroupMasterInfoByCloudId(cid: cid) {
            let send = Send_LeaveCloud()
            send.aid = DataManager.instance.m_userInfo.account_id
            send.token = DataManager.instance.m_userInfo.token
            send.tid = _info.aid
            NetworkManager.instance.Request(send) { (json) -> () in
                let receive = Receive_LeaveCloud(json)
                switch receive.ecd {
                case .success:
                    self.deleteSensor(did: did, adv: adv)
                    _ = UIManager.instance.sceneMove(scene: .initView, animation: .coverVertical, isAnimation: false)
                case .shareMember_noneGroup: _ = PopupManager.instance.onlyContents(contentsKey: "toast_leave_group_failed", confirmType: .ok)
                default:
                    Debug.print("[ERROR] invaild errcod", event: .error)
                    let _errStr = String(format: "dialog_contents_err_communication_with_server".localized, APP_ERR_COD.Send_LeaveCloud.rawValue)
                    _ = PopupManager.instance.onlyContentsCustom(contents: _errStr, confirmType: .ok, okHandler: { () -> () in
                    })
                }
            }
        } else {
            let _errStr = String(format: "dialog_contents_err_communication_with_server".localized, APP_ERR_COD.Send_LeaveCloud.rawValue)
            _ = PopupManager.instance.onlyContentsCustom(contents: _errStr, confirmType: .ok, okHandler: { () -> () in
            })
            return
        }
    }
    
    func lampLeave(cid: Int, did:Int, adv: String) {
        if let _info = DataManager.instance.m_userInfo.shareMember.getOtherGroupMasterInfoByCloudId(cid: cid) {
            let send = Send_LeaveCloud()
            send.aid = DataManager.instance.m_userInfo.account_id
            send.token = DataManager.instance.m_userInfo.token
            send.tid = _info.aid
            NetworkManager.instance.Request(send) { (json) -> () in
                let receive = Receive_LeaveCloud(json)
                switch receive.ecd {
                case .success:
                    self.deleteLamp(did: did, adv: adv)
                    _ = UIManager.instance.sceneMove(scene: .initView, animation: .coverVertical, isAnimation: false)
                case .shareMember_noneGroup: _ = PopupManager.instance.onlyContents(contentsKey: "toast_leave_group_failed", confirmType: .ok)
                default:
                    Debug.print("[ERROR] invaild errcod", event: .error)
                    let _errStr = String(format: "dialog_contents_err_communication_with_server".localized, APP_ERR_COD.Send_LeaveCloud.rawValue)
                    _ = PopupManager.instance.onlyContentsCustom(contents: _errStr, confirmType: .ok, okHandler: { () -> () in
                    })
                }
            }
        } else {
            let _errStr = String(format: "dialog_contents_err_communication_with_server".localized, APP_ERR_COD.Send_LeaveCloud.rawValue)
            _ = PopupManager.instance.onlyContentsCustom(contents: _errStr, confirmType: .ok, okHandler: { () -> () in
            })
            return
        }
    }
    
    func deleteSensor(did: Int, adv: String) {
        DataManager.instance.m_dataController.device.m_sensor.removeSensorByDevice(did: did)
        if let _bleInfo = DataManager.instance.m_userInfo.connectSensor.getSensorByDeviceId(deviceId: did) {
            BleConnectionManager.instance.disconnectDevice(peripheral: _bleInfo.peripheral)
        } else {
            BleConnectionManager.instance.disconnectReconnect(adv: adv)
        }
        DataManager.instance.m_userInfo.deviceNoti.deleteItemByDid(type: DEVICE_TYPE.Sensor.rawValue, did: did)
        DataManager.instance.m_userInfo.storeConnectedSensor.deleteItemByDid(did: did)
        BleConnectionManager.instance.retrieveDevice()
    }
    
    func deleteLamp(did: Int, adv: String) {
        DataManager.instance.m_dataController.device.m_lamp.removeLampByDevice(did: did)
        if let _bleInfo = DataManager.instance.m_userInfo.connectLamp.getLampByDeviceId(deviceId: did) {
            BleConnectionLampManager.instance.disconnectDevice(peripheral: _bleInfo.peripheral)
        } else {
            BleConnectionLampManager.instance.disconnectReconnect(adv: adv)
        }
        DataManager.instance.m_userInfo.deviceNoti.deleteItemByDid(type: DEVICE_TYPE.Lamp.rawValue, did: did)
        DataManager.instance.m_userInfo.storeConnectedLamp.deleteItemByDid(did: did)
        BleConnectionLampManager.instance.retrieveDevice()
    }
}
