//
//  SensorChartView.swift
//  Monit
//
//  Created by 맥 on 2018. 3. 8..
//  Copyright © 2018년 맥. All rights reserved.
//

import UIKit
import Charts

class SensorChartView: UIView, ChartViewDelegate {
    @IBOutlet weak var lineChartView: LineChartView!
    
    enum ValueType: String {
        case tem
        case hum
        case voc
        case cap
        case act
    }
    
    var m_type: ValueType = .voc
    var m_detailInfo: DeviceDetailInfo?
    var m_yValues : [ChartDataEntry] = [ChartDataEntry]()
    let m_data = LineChartData()
    var ds: LineChartDataSet {
        get {
            return LineChartDataSet(values: m_yValues, label: m_type.rawValue)
        }
    }
    var m_lastCount = 0

    var connectSensor: BleInfo? {
        get {
            return DataManager.instance.m_userInfo.connectSensor.getSensorByDeviceId(deviceId: m_detailInfo?.m_did ?? 0)
        }
    }
    
    var m_updateTimer: Timer?
    var m_timeInterval:Double = 1
    
    func setInit(detailInfo: DeviceDetailInfo?, type: ValueType) {
        m_detailInfo = detailInfo
        m_type = type
        setUI()
    }
    
    func setUI() {
        m_updateTimer?.invalidate()
        m_updateTimer = Timer.scheduledTimer(timeInterval: m_timeInterval, target: self, selector: #selector(update), userInfo: nil, repeats: true)
        
        if let _connectSensor = connectSensor {
            if let _data = _connectSensor.controller?.m_monitorPacket {
                switch m_type {
                case .hum:
                    for (i, item) in _data.m_hum.reversed().enumerated() {
                        m_yValues.append(ChartDataEntry(x: Double(i + 1), y: Double(item)))
                    }
                    m_lastCount = _data.m_hum.count
                case .voc:
                    for (i, item) in _data.m_voc.reversed().enumerated() {
                        m_yValues.append(ChartDataEntry(x: Double(i + 1), y: Double(item)))
                    }
                    m_lastCount = _data.m_voc.count
                case .tem:
                    for (i, item) in _data.m_tem.reversed().enumerated() {
                        m_yValues.append(ChartDataEntry(x: Double(i + 1), y: Double(item)))
                    }
                    m_lastCount = _data.m_tem.count
                case .act:
                    for (i, item) in _data.m_act.reversed().enumerated() {
                        m_yValues.append(ChartDataEntry(x: Double(i + 1), y: Double(item)))
                    }
                    m_lastCount = _data.m_act.count
                case .cap:
                    for (i, item) in _data.m_cap.reversed().enumerated() {
                        m_yValues.append(ChartDataEntry(x: Double(i + 1), y: Double(item)))
                    }
                    m_lastCount = _data.m_cap.count
                }
            }
        }

        m_data.addDataSet(ds)
        
        lineChartView.leftAxis.axisMinimum = 0
        lineChartView.rightAxis.axisMinimum = 0
        switch m_type {
        case .hum:
            lineChartView.leftAxis.axisMaximum = 10000
            lineChartView.rightAxis.axisMaximum = 10000
        case .voc:
            lineChartView.leftAxis.axisMaximum = 100000
            lineChartView.rightAxis.axisMaximum = 100000
        case .tem:
            lineChartView.leftAxis.axisMaximum = 10000
            lineChartView.rightAxis.axisMaximum = 10000
        case .act:
            lineChartView.leftAxis.axisMaximum = 10000
            lineChartView.rightAxis.axisMaximum = 10000
        case .cap: break
        }
        
        lineChartView.data = m_data
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @objc func update() {
        if let _connectSensor = connectSensor {
            if let _data = _connectSensor.controller?.m_monitorPacket {
                switch m_type {
                case .hum:
                    if (m_lastCount != _data.m_hum.count) {
                        m_lastCount = _data.m_hum.count
                        m_data.addEntry(ChartDataEntry(x: Double(m_lastCount), y: Double(_data.m_hum[0])), dataSetIndex: 0)
                    }
                case .voc:
                    if (m_lastCount != _data.m_voc.count) {
                        m_lastCount = _data.m_voc.count
                        m_data.addEntry(ChartDataEntry(x: Double(m_lastCount), y: Double(_data.m_voc[0])), dataSetIndex: 0)
                    }
                case .tem:
                    if (m_lastCount != _data.m_tem.count) {
                        m_lastCount = _data.m_tem.count
                        m_data.addEntry(ChartDataEntry(x: Double(m_lastCount), y: Double(_data.m_tem[0])), dataSetIndex: 0)
                    }
                case .act:
                    if (m_lastCount != _data.m_act.count) {
                        m_lastCount = _data.m_act.count
                        m_data.addEntry(ChartDataEntry(x: Double(m_lastCount), y: Double(_data.m_act[0])), dataSetIndex: 0)
                    }
                case .cap:
                    if (m_lastCount != _data.m_cap.count) {
                        m_lastCount = _data.m_cap.count
                        m_data.addEntry(ChartDataEntry(x: Double(m_lastCount), y: Double(_data.m_cap[0])), dataSetIndex: 0)
                    }
                }
                self.lineChartView.notifyDataSetChanged()
            }
        }
    }
    
    @IBAction func onClick_close(_ sender: UIButton) {
        m_updateTimer?.invalidate()
        self.removeFromSuperview()
    }
}
