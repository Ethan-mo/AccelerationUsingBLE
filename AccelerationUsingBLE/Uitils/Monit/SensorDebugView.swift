//
//  SensorDebugView.swift
//  Monit
//
//  Created by 맥 on 2018. 3. 12..
//  Copyright © 2018년 맥. All rights reserved.
//

import UIKit

class SensorDebugView: UIView {
    
    var m_detailInfo: DeviceDetailInfo?
    
    var sensorStatusInfo: SensorStatusInfo? {
        get {
            return DataManager.instance.m_userInfo.deviceStatus.m_sensorStatus.getInfoByDeviceId(did: m_detailInfo!.m_did)
        }
    }
    
    var isConnect: Bool {
        get {
            return DataManager.instance.m_dataController.device.m_sensor.isSensorConnect(type: m_detailInfo!.m_deviceType, did: m_detailInfo!.m_did)
        }
    }
    
    var userInfo: UserInfoDevice? {
        get {
            return DataManager.instance.m_dataController.device.getUserInfoByDid(did: m_detailInfo!.m_did, type: DEVICE_TYPE.Sensor.rawValue)
        }
    }
    
    var connectSensor: BleInfo? {
        get {
            return DataManager.instance.m_userInfo.connectSensor.getSensorByDeviceId(deviceId: m_detailInfo!.m_did)
        }
    }
    
    func setInfo(detailInfo: DeviceDetailInfo?) {
        m_detailInfo = detailInfo
    }
    
    @IBAction func onClick_chartsHum(_ sender: UIButton) {
        let _view: SensorChartView = .fromNib()
        self.addSubview(_view)
        _view.frame = self.frame
        _view.setInit(detailInfo: m_detailInfo, type: .hum)
    }
    
    @IBAction func onClick_chartsVoc(_ sender: UIButton) {
        let _view: SensorChartView = .fromNib()
        self.addSubview(_view)
        _view.frame = self.frame
        _view.setInit(detailInfo: m_detailInfo, type: .voc)
    }
    
    @IBAction func onClick_chartsTem(_ sender: UIButton) {
        let _view: SensorChartView = .fromNib()
        self.addSubview(_view)
        _view.frame = self.frame
        _view.setInit(detailInfo: m_detailInfo, type: .tem)
    }
    
    @IBAction func onClick_chartsCap(_ sender: UIButton) {
        let _view: SensorChartView = .fromNib()
        self.addSubview(_view)
        _view.frame = self.frame
        _view.setInit(detailInfo: m_detailInfo, type: .cap)
    }
    
    @IBAction func onClick_chartsAct(_ sender: UIButton) {
        let _view: SensorChartView = .fromNib()
        self.addSubview(_view)
        _view.frame = self.frame
        _view.setInit(detailInfo: m_detailInfo, type: .act)
    }

    @IBAction func onClick_sensor_Disconnect(_ sender: UIButton) {
        BleConnectionManager.instance.manager.cancelPeripheralConnection(connectSensor!.peripheral!)
    }
    
    @IBAction func onClick_monitorClear(_ sender: UIButton) {
        connectSensor?.controller?.m_monitorPacket?.m_hum.removeAll()
        connectSensor?.controller?.m_monitorPacket?.m_voc.removeAll()
        connectSensor?.controller?.m_monitorPacket?.m_tem.removeAll()
        connectSensor?.controller?.m_monitorPacket?.m_act.removeAll()
        connectSensor?.controller?.m_monitorPacket?.m_cap.removeAll()
    }
    
    @IBAction func onClick_close(_ sender: UIButton) {
        self.removeFromSuperview()
    }
}
