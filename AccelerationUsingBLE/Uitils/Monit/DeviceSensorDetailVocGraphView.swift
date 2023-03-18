//
//  DeviceSensorDetailNotiTableViewController.swift
//  Monit
//
//  Created by 맥 on 2017. 9. 22..
//  Copyright © 2017년 맥. All rights reserved.
//

import UIKit
import Charts

class DeviceSensorDetailVocGraphView: UIView, ChartViewDelegate {
    @IBOutlet weak var chartView: LineChartView!
    @IBOutlet weak var stView: UIStackView!
    
    @IBOutlet weak var viewFilter: UIView!
    @IBOutlet weak var btnFilterWeekly: UIButton!
    @IBOutlet weak var btnFilterMonthly: UIButton!

    @IBOutlet weak var lblPageContents: UILabel!
    @IBOutlet weak var btnPagePrev: UIButton!
    @IBOutlet weak var btnPageNext: UIButton!

    /// weekly, monthly
    @IBOutlet weak var viewWeeklyAvg: UIView!
    @IBOutlet weak var lblWeeklyAvgTitle: UILabel!
    @IBOutlet weak var lblWeeklyAvgValue: UILabel!
    
    static let AVG_SEC = 600
    static let ONEDAY_RANGE = 86400
    
    class VocInfo {
        var m_vocAvg: Double = 0
        var m_vocCnt: Int = 0
        var m_timeStamp: Int = 0
        
        init (voc: Int, timestamp: Int) {
            self.m_vocAvg = Double(voc)
            self.m_vocCnt = 1
            self.m_timeStamp = timestamp
//            Debug.print("voc:\(voc), timestamp:\(timestamp)")
        }
    }
    
    class GraphXAxisFormatter: NSObject, IAxisValueFormatter {
        var m_type: GRAPH_PAGE_TYPE = .weekly
        var m_stDate: Date!
        
        init(type: GRAPH_PAGE_TYPE, stDate: Date) {
            self.m_type = type
            self.m_stDate = stDate
        }
        
        func stringForValue(_ value: Double, axis: AxisBase?) -> String {
            //        Debug.print(value)
            let calendar = Calendar.current
            if let date = calendar.date(byAdding: .second, value: Int(value), to: self.m_stDate) {
                let _lDate = UI_Utility.UTCToLocal(date: UI_Utility.convertDateToString(date, type: .full))
                let _dateSlice = UI_Utility.getDateToSliceDateString(date: _lDate)
                return "\(_dateSlice.1)/\(_dateSlice.2)"
            }
            return ""
        }
    }
    
    class GraphYAxisFormatter: NSObject, IAxisValueFormatter {
        func stringForValue(_ value: Double, axis: AxisBase?) -> String {
            var _value = Int(value)
            _value = (86400 - _value) / 3600
            return _value.description
        }
    }
    
    var m_parent: DeviceSensorDetailGraphViewController?
    var m_emptyView: GraphEmptyView?
    
    var m_nowPageInfo: PagingData!
    var m_arrFilterInfo: [VocInfo] = []
    
    var m_packetLastUpdateTime: Date? // reload될때 시간을 체크하여 가져온다. (다른 noti와 다름.)
    
    func setCtrl() {
        m_nowPageInfo = PagingData(type: .weekly, idx: 1, bday: m_parent?.m_parent?.m_parent?.sensorStatusInfo?.m_bday ?? "")
        setInitUI()
        setUI()
        self.frame.size.height = m_parent!.viewGraph.frame.size.height
    }
    
    func setUI() {
        setDayUI(type: self.m_nowPageInfo.m_dayType)
        lblPageContents.text = String(format: "%@", m_nowPageInfo.m_dayInfo)

        btnPageNext.isHidden = false
        if (!m_nowPageInfo.isPageMax) {
            btnPageNext.isHidden = true
        }
        btnPagePrev.isHidden = false
        if (!m_nowPageInfo.isPageMin) {
            btnPagePrev.isHidden = true
        }

        setDateSortVocInfo()
        averageInfo(type: self.m_nowPageInfo.m_dayType, data: m_arrFilterInfo) // setDataSort 선행
        setChartUI(arr: m_arrFilterInfo)
        reloadData()
    }
    
    func setInitUI() {
        chartView.delegate = self

        UI_Utility.customViewBorder(view: viewFilter, radius: 8, width: 1, color: UIColor.clear.cgColor)
        UI_Utility.customButtonBorder(button: btnFilterWeekly, radius: 8, width: 1, color: UIColor.clear.cgColor)
        UI_Utility.customButtonBorder(button: btnFilterMonthly, radius: 8, width: 1, color: UIColor.clear.cgColor)

        UI_Utility.customViewBorder(view: viewWeeklyAvg, radius: 10, width: 1, color: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0))
        UI_Utility.customViewShadow(view: viewWeeklyAvg, radius: 1, offsetWidth: 1, offsetHeight: 1, color: UIColor.gray.cgColor, opacity: 0.5)
        
        btnFilterWeekly.setTitle("sensor_graph_week".localized, for: .normal)
        btnFilterMonthly.setTitle("sensor_graph_month".localized, for: .normal)
    }
    
    func setDayUI(type: GRAPH_PAGE_TYPE) {
        switch type {
        case .day: break
        case .weekly:
            btnFilterWeekly.backgroundColor = UIColor.white
            btnFilterMonthly.backgroundColor = UIColor.clear
        case .monthly:
            btnFilterWeekly.backgroundColor = UIColor.clear
            btnFilterMonthly.backgroundColor = UIColor.white
        }
    }
    
    func setDateSortVocInfo() {
        // 데이터 필터
        let _arrVocInfo = setFilterDate()
        // 5분 단위로 변경
        self.m_arrFilterInfo = setFilterAverageData(arr: _arrVocInfo)
    }
    
    func setFilterDate() -> [VocInfo] {
        var _arrVocInfo: [VocInfo] = []
        let _todayStTimestamp = m_nowPageInfo.m_stDateCast.millisecondsSince1970
        let _todayEdTimestamp = m_nowPageInfo.m_edDateCast.millisecondsSince1970
        for item in DataManager.instance.m_userInfo.sensorVocGraph.m_lst {
            if let _detailInfo = m_parent!.m_parent!.m_parent!.m_detailInfo {
                if (item.m_did == _detailInfo.m_did) {
                    var _isContainData = false // 포함되는 항목은 기간내, 그래프 시작시간이 구간내에 포함, 그래프 종료 시간이 구간내에 포함, 그래프 시작 종료 시간이 구간내에 포함.
                    if (item.m_castTimeInfo.m_lTimeCast.millisecondsSince1970 <= _todayStTimestamp && _todayEdTimestamp <= item.m_edTimeInfo.m_lTimeCast.millisecondsSince1970) {
                        _isContainData = true
                    } else if (_todayStTimestamp <= item.m_castTimeInfo.m_lTimeCast.millisecondsSince1970 && item.m_castTimeInfo.m_lTimeCast.millisecondsSince1970 <= _todayEdTimestamp) {
                        _isContainData = true
                    } else if (_todayStTimestamp <= item.m_edTimeInfo.m_lTimeCast.millisecondsSince1970 && item.m_edTimeInfo.m_lTimeCast.millisecondsSince1970 <= _todayEdTimestamp) {
                        _isContainData = true
                    }
                    if (_isContainData) {
                        let _orginTimestamp = item.m_castTimeInfo.m_lTimeCast.millisecondsSince1970
                        var _sliceVoc = ""
//                        Debug.print("m_descryptVoc: \(item.m_descryptVoc)")
                        for (i, itemVoc) in item.m_descryptVoc.enumerated() {
                            if (i % 2 == 1) {
                                _sliceVoc += String(itemVoc)
                                if (_todayStTimestamp <= _orginTimestamp + 300 * (i / 2) && _orginTimestamp + 300 * (i / 2) <= _todayEdTimestamp) { // 상세한 시간 구간을 확인한다.
                                    let _voc = (Int(_sliceVoc, radix: 16) ?? 0) * 1000 / 100
//                                    let _xAxisValue = Double((_orginTimestamp + 300 * (i / 2)) - _todayStTimestamp) // / 60.0
                                    //                                                                        Debug.print("\(_xAxisValue),\(_voc)")
                                    _arrVocInfo.append(VocInfo(voc: _voc, timestamp: _orginTimestamp + 300 * i / 2))
                                }
                            } else {
                                _sliceVoc = String(itemVoc)
                            }
                        }
                    }
                }
            }
        }
        return _arrVocInfo
    }
    
    func setFilterAverageData(arr: [VocInfo]) -> [VocInfo] {
        var _dic: [Int: VocInfo] = [:]
        for item in arr {
            let _timeStamp = Int(Int(item.m_timeStamp) / DeviceSensorDetailVocGraphView.AVG_SEC)
            
            if let _value = _dic[_timeStamp] {
                _value.m_vocAvg = (Double(_value.m_vocAvg) * Double(_value.m_vocCnt) + Double(item.m_vocAvg)) / Double(_value.m_vocCnt + 1)
                //                Debug.print("\(_xAxisValuePart), \(_value.m_vocAvg) = \(_value.m_vocAvg) * \(_value.m_vocCnt) + \(item.m_voc) / \(_value.m_vocCnt + 1)")item
                _value.m_vocCnt += 1
                _dic.updateValue(_value, forKey: _timeStamp)
            } else {
                _dic.updateValue(item, forKey: _timeStamp)
            }
        }
        
        var _arrVocAverageInfo: [VocInfo] = []
        for (_, value) in _dic {
            _arrVocAverageInfo.append(value)
        }
        _arrVocAverageInfo.sort { (object1, object2) -> Bool in
            return object1.m_timeStamp < object2.m_timeStamp
        }
        
//        for item in _arrVocAverageInfo {
//            Debug.print("m_vocAvg:\(item.m_vocAvg), m_vocCnt:\(item.m_vocCnt), m_timeStamp:\(item.m_timeStamp)")
//        }
        
        return _arrVocAverageInfo
    }
    
    
//    func setDateSortVocInfo() {
//        var _filterData: [SensorVocGraphInfo] = []
//        let _todayStTimestamp = m_nowPageInfo.m_stDateCast.millisecondsSince1970
//        let _todayEdTimestamp = m_nowPageInfo.m_edDateCast.millisecondsSince1970
//        for item in DataManager.instance.m_userInfo.sensorVocGraph.m_lst { // 서버에서 받은 패킷당 정보가 리스트에 저장 되어있다.
//            if let _detailInfo = m_parent!.m_parent!.m_parent!.m_detailInfo {
//                if (item.m_did == _detailInfo.m_did) {
//                    var _isContainData = false // 포함되는 항목은 기간내, 그래프 시작시간이 구간내에 포함, 그래프 종료 시간이 구간내에 포함, 그래프 시작 종료 시간이 구간내에 포함.
//                    if (item.m_castTimeInfo.m_timeCast.millisecondsSince1970 <= _todayStTimestamp && _todayEdTimestamp <= item.m_edTimeInfo.m_timeCast.millisecondsSince1970) {
//                        _isContainData = true
//                    } else if (_todayStTimestamp <= item.m_castTimeInfo.m_timeCast.millisecondsSince1970 && item.m_castTimeInfo.m_timeCast.millisecondsSince1970 <= _todayEdTimestamp) {
//                        _isContainData = true
//                    } else if (_todayStTimestamp <= item.m_edTimeInfo.m_timeCast.millisecondsSince1970 && item.m_edTimeInfo.m_timeCast.millisecondsSince1970 <= _todayEdTimestamp) {
//                        _isContainData = true
//                    }
//                    if (_isContainData) {
//                        let _orginTimestamp = item.m_castTimeInfo.m_timeCast.millisecondsSince1970
//                        var _sliceVoc = ""
//                        for (i, itemVoc) in item.m_descryptVoc.enumerated() {
//                            if (i % 2 == 1) {
//                                _sliceVoc += String(itemVoc)
//                                if (_todayStTimestamp <= _orginTimestamp + 300 * (i / 2) && _orginTimestamp + 300 * (i / 2) <= _todayEdTimestamp) { // 상세한 시간 구간을 확인한다.
//                                    let _voc = Int(String(_sliceVoc), radix: 16) ?? 0 * 1000
//                                    let _xAxisValue = Double((_orginTimestamp + 300 * (i / 2)) - _todayStTimestamp) // / 60.0
////                                                                        Debug.print("\(_xAxisValue),\(_voc)")
//                                    _filterData.append(SensorVocGraphInfo(did: _detailInfo.m_did, voc: _voc, xAxisValue: _xAxisValue, timestamp: _orginTimestamp + 300 * i / 2))
//                                }
//                            } else {
//                                _sliceVoc = String(itemVoc)
//                            }
//                        }
//                    }
//                }
//            }
//        }
//
//        _filterData.sort { (object1, object2) -> Bool in
//            return object1.m_xAxisValue < object2.m_xAxisValue
//        }
//        //        for item in _filterDataAvg {
//        //            Debug.print("\(item.m_xAxisValue), \(item.m_voc), \(item.m_isHorizontal)")
//        //        }
//        self.m_filterData = _filterData
//    }
    
    func averageInfo(type: GRAPH_PAGE_TYPE, data: [VocInfo]) {
        if (type == .weekly) {
            lblWeeklyAvgTitle.text = "lamp_environment_graph_voc_average".localized
        } else {
            lblWeeklyAvgTitle.text = "lamp_environment_graph_voc_average".localized
        }
        
        var _total: Double = 0
        if (data.count > 0) {
            for item in data {
                _total += item.m_vocAvg
            }
            _total = _total / Double(data.count)
        }
        
        lblWeeklyAvgValue.text = "\(Int(_total))"
    }
    
    // 데이터 업데이트 해야함.
    func reloadData() {
        setChartUI(arr: m_arrFilterInfo)
        if (m_packetLastUpdateTime == nil || m_packetLastUpdateTime! < NSDate(timeIntervalSinceNow: TimeInterval(-1 * Config.SENSOR_MOV_GRAPH_UPDATE_LIMIT)) as Date) {
            if let _detailInfo = m_parent!.m_parent!.m_parent!.m_detailInfo {
                self.m_packetLastUpdateTime = Date()
                UIManager.instance.indicator(true)
                DataManager.instance.m_dataController.sensorVocGraph.updateByDid(did: _detailInfo.m_did, handler: { (isSuccess) -> () in
                    if (isSuccess) {
                        UIManager.instance.indicator(false)
                        UIManager.instance.currentUIReload()
                    }
                })
            }
        }
    }
    
    func setChartUI(arr: [VocInfo]) {
        let _isWeeklyType = m_nowPageInfo.m_dayType == .weekly
        
        var _chartYValues: [ChartDataEntry] = []
        var _chartYColors: [NSUIColor] = []
        
        for (i, item) in arr.enumerated() {
            let _x = item.m_timeStamp - m_nowPageInfo.m_stDateCast.millisecondsSince1970
            _chartYValues.append(BarChartDataEntry(x: Double(_x), y: Double(Int(item.m_vocAvg))))
            
            if (arr.count > i + 1) {
                if (arr[i + 1].m_timeStamp - item.m_timeStamp == DeviceSensorDetailVocGraphView.AVG_SEC) {
                    _chartYColors.append(COLOR_TYPE._brown_174_140_107.color)
                } else {
                    _chartYColors.append(UIColor.clear)
                }
            } else {
                _chartYColors.append(UIColor.clear)
            }
        }
        
        let _ds = LineChartDataSet(values: _chartYValues, label: nil)
        _ds.drawCircleHoleEnabled = false
        _ds.colors = _chartYColors
        _ds.lineWidth = 1
        _ds.drawCirclesEnabled = false
        _ds.circleRadius = 10
        _ds.drawValuesEnabled = false
        
        let _chartData = LineChartData()
        _chartData.addDataSet(_ds)
        
        // 세로축(왼쪽) 라벨 및 수치
        chartView.leftAxis.axisMinimum = -100
        chartView.leftAxis.axisMaximum = 2500
        chartView.leftAxis.drawGridLinesEnabled = true
        chartView.leftAxis.drawLabelsEnabled = true
        chartView.leftAxis.granularity = 500 // 세로선 몇번째마다 표시할지
        chartView.leftAxis.labelFont = UIFont(name: Config.FONT_NotoSans, size: 10.0)!
        
        // 세로축(오른쪽) 라벨 및 수치
        chartView.rightAxis.drawGridLinesEnabled = false
        chartView.rightAxis.drawLabelsEnabled = false
        
        // 하단 라벨 및 수치
        chartView.xAxis.axisRange = _isWeeklyType ? 7 * Double(DeviceSensorDetailVocGraphView.ONEDAY_RANGE) : 32 * Double(DeviceSensorDetailVocGraphView.ONEDAY_RANGE) // 다음날짜까지 표시해준다.
        chartView.xAxis.axisMinimum = 0
        chartView.xAxis.axisMaximum = _isWeeklyType ? 7 * Double(DeviceSensorDetailVocGraphView.ONEDAY_RANGE) : 32 * Double(DeviceSensorDetailVocGraphView.ONEDAY_RANGE)  // 다음날짜까지 표시해준다.
        chartView.xAxis.drawGridLinesEnabled = true
        chartView.xAxis.drawAxisLineEnabled = false
        chartView.xAxis.gridColor = COLOR_TYPE.lblWhiteGray.color
        chartView.xAxis.labelPosition = .bottom
        chartView.xAxis.valueFormatter = GraphXAxisFormatter(type: m_nowPageInfo.m_dayType, stDate: m_nowPageInfo.m_stDateCast)
        chartView.xAxis.labelCount = _isWeeklyType ? 7 : 32
        chartView.xAxis.forceLabelsEnabled = false // 하단 라벨, 뒤에 선 고정
        chartView.xAxis.granularity = _isWeeklyType ? Double(DeviceSensorDetailVocGraphView.ONEDAY_RANGE) : Double(DeviceSensorDetailVocGraphView.ONEDAY_RANGE * 4)  // 세로선 몇번째마다 표시할지 (라벨에 영향을 준다.)
//        chartView.xAxis.centerAxisLabelsEnabled = true // 라벨 가운대 정렬
        chartView.xAxis.labelFont = UIFont(name: Config.FONT_NotoSans, size: 10.0)!
        
        chartView.data = _chartData
        chartView.clipValuesToContentEnabled = true
        chartView.chartDescription?.text = ""
        chartView.pinchZoomEnabled = false
        chartView.scaleXEnabled = false // 가로축 스케일 조정
        chartView.scaleYEnabled = false
        chartView.legend.enabled = false // 표 이름표
        chartView.doubleTapToZoomEnabled = false // 더블탭 스케일
    }
    
    @IBAction func onClick_weekly(_ sender: UIButton) {
        m_nowPageInfo.setWeekly()
        setUI()
    }
    
    @IBAction func onClick_monthly(_ sender: UIButton) {
        m_nowPageInfo.setMonthly()
        setUI()
    }
    
    @IBAction func onClick_pagePrev(_ sender: UIButton) {
        m_nowPageInfo.setPrevPage()
        setUI()
    }
    
    @IBAction func onClick_pageNext(_ sender: UIButton) {
        m_nowPageInfo.setNextPage()
        setUI()
    }
}
