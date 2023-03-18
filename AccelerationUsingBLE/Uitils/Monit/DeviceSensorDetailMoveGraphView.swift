//
//  DeviceSensorDetailNotiTableViewController.swift
//  Monit
//
//  Created by 맥 on 2017. 9. 22..
//  Copyright © 2017년 맥. All rights reserved.
//

import UIKit
import Charts

class DeviceSensorDetailMoveGraphView: UIView, ChartViewDelegate {
    @IBOutlet weak var chartView: LineChartView!
    @IBOutlet weak var stView: UIStackView!
    
    @IBOutlet weak var viewFilter: UIView!
    @IBOutlet weak var btnFilterWeekly: UIButton!
    @IBOutlet weak var btnFilterMonthly: UIButton!

    @IBOutlet weak var lblPageContents: UILabel!
    @IBOutlet weak var btnPagePrev: UIButton!
    @IBOutlet weak var btnPageNext: UIButton!

    /// weekly, monthly
    @IBOutlet weak var viewWeeklyLevel: UIView!
    @IBOutlet weak var lblWeeklyLevelTitle: UILabel!
    @IBOutlet weak var lblWeeklyLevelValue: UILabel!
    
    @IBOutlet weak var viewWeeklyLevelText: UIView!
    @IBOutlet weak var lblWeeklyLevelTextTitle: UILabel!
    @IBOutlet weak var lblWeeklyLevelTextValue: UILabel!
    
    /// day
    @IBOutlet weak var viewDay: UIView!
    @IBOutlet weak var dayChartView: LineChartView!
    @IBOutlet weak var lblDayTitle: UILabel!
    
    @IBOutlet weak var viewDayLevel: UIView!
    @IBOutlet weak var lblDayLevelTitle: UILabel!
    @IBOutlet weak var lblDayLevelValue: UILabel!
    
    @IBOutlet weak var viewDayLevelText: UIView!
    @IBOutlet weak var lblDayLevelTextTitle: UILabel!
    @IBOutlet weak var lblDayLevelTextValue: UILabel!

    static let ONEDAY_RANGE = 86400
    static let AVG_SEC = 600

    class MovInfo {
        var m_movAvg: Double = 0
        var m_movCnt: Int = 0
        var m_timeStamp: Int = 0 // 날짜 타임스탬프
        var m_isHorizontal: Bool = false

        var m_diff: Int = -1
        var m_date: Date!
        var m_month: Int = 0
        var m_day: Int = 0
        var m_sec: Int = 0

        init (mov: Int, isHorizontal: Bool, timestamp: Int, castDate: CastDateFormat, addSec: Double, nowDate: Date) {
            self.m_movAvg = Double(mov)
            self.m_movCnt = 1
            self.m_isHorizontal = isHorizontal
            self.m_timeStamp = timestamp

            let _castlDate = castDate.m_lTimeCast.adding(second: Int(addSec))
            let _componenets = Calendar.current.dateComponents([.day], from: nowDate, to: _castlDate)
            if let _day = _componenets.day {
                self.m_diff = _day
            }
            let _sliceDate = UI_Utility.getDateToSliceDate(date: _castlDate)
            self.m_date = _castlDate
            self.m_month = _sliceDate.1
            self.m_day = _sliceDate.2
            self.m_sec = _sliceDate.3 * 3600 + _sliceDate.4 * 60 + _sliceDate.5
            
//            Debug.print("st:\(nowDate), cast:\(_castlDate), diff:\(m_diff), mov:\(mov), isHorizontal:\(isHorizontal)")
        }
    }
    
    class GraphYAxisFormatter: NSObject, IAxisValueFormatter {
        func stringForValue(_ value: Double, axis: AxisBase?) -> String {
            return UIManager.instance.getSensorMovementLevelString(type: SensorStatusInfo.GetMovementLevel(mov: Int(value)))
        }
    }

    class DayGraphXAxisFormatter: NSObject, IAxisValueFormatter {
        func stringForValue(_ value: Double, axis: AxisBase?) -> String {
            return "\(Int(value) / 3600)\("time_hour".localized)"
        }
    }

    var m_parent: DeviceSensorDetailGraphViewController?
    var m_emptyView: GraphEmptyView?

    var m_nowPageInfo: PagingData!
    var m_arrWeeklyFilterInfo: [MovInfo] = []
    var m_arrFilterInfo: [MovInfo] = []

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

        setDateSortMovInfo()
        averageInfo(type: self.m_nowPageInfo.m_dayType, data: m_arrWeeklyFilterInfo) // setDataSort 선행
        setChartUI()
        reloadData()
    }

    func setInitUI() {
        chartView.delegate = self

        UI_Utility.customViewBorder(view: viewFilter, radius: 8, width: 1, color: UIColor.clear.cgColor)
        UI_Utility.customButtonBorder(button: btnFilterWeekly, radius: 8, width: 1, color: UIColor.clear.cgColor)
        UI_Utility.customButtonBorder(button: btnFilterMonthly, radius: 8, width: 1, color: UIColor.clear.cgColor)

        UI_Utility.customViewBorder(view: viewWeeklyLevel, radius: 10, width: 1, color: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0))
        UI_Utility.customViewShadow(view: viewWeeklyLevel, radius: 1, offsetWidth: 1, offsetHeight: 1, color: UIColor.gray.cgColor, opacity: 0.5)
        UI_Utility.customViewBorder(view: viewWeeklyLevelText, radius: 10, width: 1, color: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0))
        UI_Utility.customViewShadow(view: viewWeeklyLevelText, radius: 1, offsetWidth: 1, offsetHeight: 1, color: UIColor.gray.cgColor, opacity: 0.5)

        viewDay.isHidden = true
        UI_Utility.customViewBorder(view: viewDayLevel, radius: 8, width: 1, color: UIColor.clear.cgColor)
        UI_Utility.customViewBorder(view: viewDayLevelText, radius: 8, width: 1, color: UIColor.clear.cgColor)

        btnFilterWeekly.setTitle("sensor_graph_week".localized, for: .normal)
        btnFilterMonthly.setTitle("sensor_graph_month".localized, for: .normal)
        
        lblDayLevelTitle.text = "sensor_movement_graph_average_value".localized
        lblDayLevelTextTitle.text = "sensor_movement_graph_average_text".localized
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

    func setDateSortMovInfo() {
        // 데이터 필터
        let _arrMovInfo = setFilterDate()
        // 5분 단위로 변경
        self.m_arrFilterInfo = setFilterAverageData(arr: _arrMovInfo)
        // set weekly data
        self.m_arrWeeklyFilterInfo = setWeeklyData(arr: self.m_arrFilterInfo)
    }
    
    func setFilterDate() -> [MovInfo] {
        var _arrMovInfo: [MovInfo] = []
        let _todayStTimestamp = m_nowPageInfo.m_stDateCast.millisecondsSince1970
        let _todayEdTimestamp = m_nowPageInfo.m_edDateCast.millisecondsSince1970
        for item in DataManager.instance.m_userInfo.sensorMovGraph.m_lst {
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
                        for (i, itemMov) in item.m_descryptMov.enumerated() {
                            let _timeStamp = _orginTimestamp + 10 * i
                            if (_todayStTimestamp <= _timeStamp && _timeStamp <= _todayEdTimestamp) {
                                let _mov = Int(String(itemMov), radix: 16) ?? 0
                                if (_mov != 15) {
                                    _arrMovInfo.append(
                                        MovInfo(mov: _mov == 14 ? 0 : _mov,
                                                isHorizontal: _mov == 14 ? true : false,
                                                timestamp: _timeStamp,
                                                castDate: item.m_castTimeInfo,
                                                addSec: Double(10 * i),
                                                nowDate: m_nowPageInfo.m_stDateCast))
                                }
                            }
                        }
                    }
                }
            }
        }
        return _arrMovInfo
    }
    
    func setFilterAverageData(arr: [MovInfo]) -> [MovInfo] {
        var _dic: [Int: MovInfo] = [:]
        for item in arr {
            let _timeStamp = Int(Int(item.m_timeStamp) / DeviceSensorDetailMoveGraphView.AVG_SEC)
            
            if let _value = _dic[_timeStamp] {
                _value.m_movAvg = (Double(_value.m_movAvg) * Double(_value.m_movCnt) + Double(item.m_movAvg)) / Double(_value.m_movCnt + 1)
                //                Debug.print("\(_xAxisValuePart), \(_value.m_movAvg) = \(_value.m_movAvg) * \(_value.m_movCnt) + \(item.m_mov) / \(_value.m_movCnt + 1)")item
                _value.m_movCnt += 1
                if (_value.m_movAvg > 0) {
                    _value.m_isHorizontal = false
                }
                _dic.updateValue(_value, forKey: _timeStamp)
            } else {
                _dic.updateValue(item, forKey: _timeStamp)
            }
        }
        
        var _arrMovAverageInfo: [MovInfo] = []
        for (_, value) in _dic {
            _arrMovAverageInfo.append(value)
        }
        _arrMovAverageInfo.sort { (object1, object2) -> Bool in
            return object1.m_timeStamp < object2.m_timeStamp
        }
        //        for item in _arrMovAverageInfo {
        //            Debug.print("m_movAvg:\(item.m_movAvg), m_movCnt:\(item.m_movCnt), m_date:\(item.m_date), m_diff:\(item.m_diff)")
        //        }
        return _arrMovAverageInfo
    }
    
    func setWeeklyData(arr: [MovInfo]) -> [MovInfo] {
        var _dic : [Int: MovInfo] = [:]
        let _componenets = Calendar.current.dateComponents([.day], from: m_nowPageInfo.m_stDateCast, to: m_nowPageInfo.m_edDateCast)
        if let _day = _componenets.day {
            for i in 0...(_day) {
                for item in arr {
                    if (item.m_diff == i) {
                        if let _value = _dic[i] {
                            _value.m_movAvg = (Double(_value.m_movAvg) * Double(_value.m_movCnt) + Double(item.m_movAvg)) / Double(_value.m_movCnt + 1)
                            //                Debug.print("\(_xAxisValuePart), \(_value.m_movAvg) = \(_value.m_movAvg) * \(_value.m_movCnt) + \(item.m_mov) / \(_value.m_movCnt + 1)")item
                            _value.m_movCnt += 1
                            if (_value.m_movAvg > 0) {
                                _value.m_isHorizontal = false
                            }
                            _dic.updateValue(_value, forKey: i)
                        } else {
                            _dic.updateValue(item, forKey: i)
                        }
                    }
                }
            }
        }
        var _arrMovAverageInfo: [MovInfo] = []
        for (_, value) in _dic {
            _arrMovAverageInfo.append(value)
        }
        
//        var _info = MovInfo(mov: 3,
//                isHorizontal: false,
//                timestamp: 12312,
//                castDate: CastDateFormat(time: Config.DATE_INIT),
//                addSec: 0,
//                nowDate: Date())
//        _info.m_diff = 1
//        _arrMovAverageInfo.append(_info)
//
//        var _info2 = MovInfo(mov: 5,
//                isHorizontal: false,
//                timestamp: 12312,
//                castDate: CastDateFormat(time: Config.DATE_INIT),
//                addSec: 0,
//                nowDate: Date())
//        _info2.m_diff = 2
//        _arrMovAverageInfo.append(_info2)
//
//        var _info3 = MovInfo(mov: 1,
//                isHorizontal: false,
//                timestamp: 12312,
//                castDate: CastDateFormat(time: Config.DATE_INIT),
//                addSec: 0,
//                nowDate: Date())
//        _info3.m_diff = 4
//        _arrMovAverageInfo.append(_info3)
//
//        var _info4 = MovInfo(mov: 12,
//                isHorizontal: false,
//                timestamp: 12312,
//                castDate: CastDateFormat(time: Config.DATE_INIT),
//                addSec: 0,
//                nowDate: Date())
//        _info4.m_diff = 5
//        _arrMovAverageInfo.append(_info4)
//
//        var _info5 = MovInfo(mov: 10,
//                isHorizontal: false,
//                timestamp: 12312,
//                castDate: CastDateFormat(time: Config.DATE_INIT),
//                addSec: 0,
//                nowDate: Date())
//        _info5.m_diff = 7
//        _arrMovAverageInfo.append(_info5)

        _arrMovAverageInfo.sort { (object1, object2) -> Bool in
            return object1.m_timeStamp < object2.m_timeStamp
        }
        
//        for item in _arrMovAverageInfo {
//            Debug.print("m_movAvg:\(item.m_movAvg), m_movCnt:\(item.m_movCnt), m_date:\(item.m_date), m_diff:\(item.m_diff)")
//        }
        return _arrMovAverageInfo
    }

    func averageInfo(type: GRAPH_PAGE_TYPE, data: [MovInfo]) {
        if (type == .weekly) {
            lblWeeklyLevelTitle.text = "sensor_movement_graph_average_value".localized
            lblWeeklyLevelTextTitle.text = "sensor_movement_graph_average_text".localized
        } else {
            lblWeeklyLevelTitle.text = "sensor_movement_graph_average_value".localized
            lblWeeklyLevelTextTitle.text = "sensor_movement_graph_average_text".localized
        }
        
        var _total: Double = 0
        if (data.count > 0) {
            for item in data {
                _total += item.m_movAvg
            }
            _total = _total / Double(data.count)
        }
        
        lblWeeklyLevelValue.text = Int(_total / Double(12) * Double(10)).description
        lblWeeklyLevelTextValue.text = UIManager.instance.getSensorMovementLevelString(type: SensorStatusInfo.GetMovementLevel(mov: Int(_total)))
    }
    
    func averageDayInfo(type: GRAPH_PAGE_TYPE, x: Double, data: [MovInfo]) {
        viewDay.isHidden = false
        stView.layoutIfNeeded()
        
        let _diffDay = diffDayValueByX(type: type, x: x)
        
        let calendar = Calendar.current
        if let date = calendar.date(byAdding: .day, value: _diffDay, to: m_nowPageInfo.m_stDateCast) {
            let _lDate = UI_Utility.convertDateToString(date, type: .full)
//            let _dateSlice = UI_Utility.getDateToSliceDateString(date: _lDate)
            lblDayTitle.text = UI_Utility.getDateByLanguageFromString(
            UI_Utility.convertDateToString(date, type: .full), fromType: .full, language: Config.languageType)
        }
        
        let _arrInfo = setDayFilterData(diff: _diffDay, arr: m_arrFilterInfo)
        
        var _total: Double = 0
        if (data.count > 0) {
            for item in _arrInfo {
                _total += item.m_movAvg
            }
            _total = _total / Double(data.count)
        }
        
        lblDayLevelValue.text = Int(_total / Double(12) * Double(10)).description
        lblDayLevelTextValue.text = UIManager.instance.getSensorMovementLevelString(type: SensorStatusInfo.GetMovementLevel(mov: Int(_total)))
        
        setDayChartUI(diff: _diffDay, arr: _arrInfo)
    }
    
    func setDayFilterData(diff: Int, arr: [MovInfo]) -> [MovInfo] {
        var _arrFilter: [MovInfo] = []
        for item in arr {
            if (diff == item.m_diff) {
                _arrFilter.append(item)
            }
        }
        return _arrFilter
    }
    
    func setDayChartUI(diff: Int, arr: [MovInfo]) {
        var _chartYValues: [ChartDataEntry] = []
        var _chartYColors: [NSUIColor] = []
        
        for (i, item) in arr.enumerated() {
            var _x = 0
            if let date = Calendar.current.date(byAdding: .day, value: diff, to: m_nowPageInfo.m_stDateCast) {
                _x = item.m_timeStamp - date.millisecondsSince1970
            }
            _chartYValues.append(BarChartDataEntry(x: Double(_x), y: Double(Int(item.m_movAvg))))
            
            if (arr.count > i + 1) {
                if (arr[i + 1].m_timeStamp - item.m_timeStamp == DeviceSensorDetailMoveGraphView.AVG_SEC) {
                    _chartYColors.append(COLOR_TYPE.purple.color)
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
        _ds.lineWidth = 2
        _ds.drawCirclesEnabled = false
        _ds.circleRadius = 4
        _ds.drawValuesEnabled = false

        let _chartData = LineChartData()
        _chartData.addDataSet(_ds)

        // 세로축(왼쪽) 라벨 및 수치
        dayChartView.leftAxis.axisMinimum = 0
        dayChartView.leftAxis.axisMaximum = 12
        dayChartView.leftAxis.drawGridLinesEnabled = true
        dayChartView.leftAxis.drawAxisLineEnabled = false
        dayChartView.leftAxis.drawLabelsEnabled = true
        dayChartView.leftAxis.valueFormatter = GraphYAxisFormatter()
        dayChartView.leftAxis.granularity = 4 // 세로선 몇번째마다 표시할지
        dayChartView.leftAxis.labelFont = UIFont(name: Config.FONT_NotoSans, size: 10.0)!

        // 세로축(오른쪽) 라벨 및 수치
        dayChartView.rightAxis.drawGridLinesEnabled = false
        dayChartView.rightAxis.drawLabelsEnabled = false

        // 하단 라벨 및 수치
        dayChartView.xAxis.axisRange = Double(DeviceSensorDetailMoveGraphView.ONEDAY_RANGE)
        dayChartView.xAxis.axisMinimum = 0
        dayChartView.xAxis.axisMaximum = Double(DeviceSensorDetailMoveGraphView.ONEDAY_RANGE)
        dayChartView.xAxis.drawGridLinesEnabled = true
        dayChartView.xAxis.drawAxisLineEnabled = false
        dayChartView.xAxis.gridColor = COLOR_TYPE.lblWhiteGray.color
        dayChartView.xAxis.labelPosition = .bottom
        dayChartView.xAxis.valueFormatter = DayGraphXAxisFormatter()
        dayChartView.xAxis.labelCount = DeviceSensorDetailMoveGraphView.ONEDAY_RANGE / 4
        dayChartView.xAxis.forceLabelsEnabled = false // 하단 라벨, 뒤에 선 고정
        dayChartView.xAxis.granularity = Double(DeviceSensorDetailMoveGraphView.ONEDAY_RANGE / 4)  // 세로선 몇번째마다 표시할지 (라벨에 영향을 준다.)
        dayChartView.xAxis.centerAxisLabelsEnabled = false // 라벨 가운대 정렬
        dayChartView.xAxis.labelFont = UIFont(name: Config.FONT_NotoSans, size: 10.0)!

        dayChartView.data = _chartData
        dayChartView.chartDescription?.text = ""
        dayChartView.pinchZoomEnabled = false
        dayChartView.scaleXEnabled = false
        dayChartView.scaleYEnabled = false
        dayChartView.legend.enabled = false

        setEmptyGraph(isEnable: m_arrFilterInfo.count <= 0)
    }

    func diffDayValueByX(type: GRAPH_PAGE_TYPE, x: Double) -> Int {
        return type == .weekly ? Int((x - 1) / 2) : Int(x)
    }

    // 데이터 업데이트 해야함.
    func reloadData() {
        setChartUI()
        if (m_packetLastUpdateTime == nil || m_packetLastUpdateTime! < NSDate(timeIntervalSinceNow: TimeInterval(-1 * Config.SENSOR_MOV_GRAPH_UPDATE_LIMIT)) as Date) {
            if let _detailInfo = m_parent!.m_parent!.m_parent!.m_detailInfo {
                self.m_packetLastUpdateTime = Date()
                UIManager.instance.indicator(true)
                DataManager.instance.m_dataController.sensorMovGraph.updateByDid(did: _detailInfo.m_did, handler: { (isSuccess) -> () in
                    if (isSuccess) {
                        UIManager.instance.indicator(false)
                        UIManager.instance.currentUIReload()
                    }
                })
            }
        }
    }

    func setChartUI() {
        let _isWeeklyType = m_nowPageInfo.m_dayType == .weekly

        var _chartYValues: [ChartDataEntry] = []
        var _chartYColors: [NSUIColor] = []
        var _chartCircleColors: [NSUIColor] = []
        
        for (i, item) in m_arrWeeklyFilterInfo.enumerated() {
            _chartYValues.append(BarChartDataEntry(x: Double(_isWeeklyType ? (item.m_diff * 2 + 1) : item.m_diff), y: Double(Int(item.m_movAvg))))
            
            if (m_arrWeeklyFilterInfo.count > i + 1) {
                let _info = m_arrWeeklyFilterInfo[i + 1]
                if (item.m_diff + 1 == _info.m_diff) {
                    _chartYColors.append(COLOR_TYPE.purple.color)
                } else {
                    _chartYColors.append(UIColor.clear)
                }
            } else {
                _chartYColors.append(COLOR_TYPE.purple.color)
            }
            _chartCircleColors.append(COLOR_TYPE.purple.color)
        }
        
        let _ds = LineChartDataSet(values: _chartYValues, label: nil)
        _ds.drawCircleHoleEnabled = false
        _ds.colors = _chartYColors
        _ds.lineWidth = 2
        _ds.drawCirclesEnabled = true
        _ds.circleRadius = 4
        _ds.circleColors = _chartCircleColors
        _ds.drawValuesEnabled = false

        let _chartData = LineChartData()
        _chartData.addDataSet(_ds)

        // 세로축(왼쪽) 라벨 및 수치
        chartView.leftAxis.axisMinimum = 0
        chartView.leftAxis.axisMaximum = 12
        chartView.leftAxis.drawGridLinesEnabled = true
        chartView.leftAxis.drawAxisLineEnabled = false
        chartView.leftAxis.drawLabelsEnabled = true
        chartView.leftAxis.valueFormatter = GraphYAxisFormatter()
        chartView.leftAxis.granularity = 4 // 세로선 몇번째마다 표시할지
        chartView.leftAxis.labelFont = UIFont(name: Config.FONT_NotoSans, size: 10.0)!

        // 세로축(오른쪽) 라벨 및 수치
        chartView.rightAxis.drawGridLinesEnabled = false
        chartView.rightAxis.drawLabelsEnabled = false

        // 하단 라벨 및 수치
        chartView.xAxis.axisRange = _isWeeklyType ? 7 * 2 : 32
        chartView.xAxis.axisMinimum = 0
        chartView.xAxis.axisMaximum = _isWeeklyType ? 7 * 2 : 32
        chartView.xAxis.drawGridLinesEnabled = true
        chartView.xAxis.drawAxisLineEnabled = false
        chartView.xAxis.gridColor = COLOR_TYPE.lblWhiteGray.color
        chartView.xAxis.labelPosition = .bottom
        chartView.xAxis.valueFormatter = GraphXAxisFormatter(type: m_nowPageInfo.m_dayType, stDate: m_nowPageInfo.m_stDateCast)
        chartView.xAxis.labelCount = _isWeeklyType ? 7 * 2 : 32
        chartView.xAxis.forceLabelsEnabled = false // 하단 라벨, 뒤에 선 고정
        chartView.xAxis.granularity = _isWeeklyType ? 2 : 4  // 세로선 몇번째마다 표시할지 (라벨에 영향을 준다.)
        chartView.xAxis.centerAxisLabelsEnabled = _isWeeklyType ? true : false // 라벨 가운대 정렬
        chartView.xAxis.labelFont = UIFont(name: Config.FONT_NotoSans, size: 10.0)!

        chartView.data = _chartData
        chartView.chartDescription?.text = ""
        chartView.pinchZoomEnabled = false
        chartView.scaleXEnabled = false
        chartView.scaleYEnabled = false
        chartView.legend.enabled = false

        setEmptyGraph(isEnable: m_arrFilterInfo.count <= 0)
    }

    func setEmptyGraph(isEnable: Bool) {
        if (isEnable) {
            if (m_emptyView == nil) {
                m_emptyView = .fromNib()
                m_emptyView!.frame = chartView.bounds
                m_emptyView!.setInfo()
                self.chartView.addSubview(m_emptyView!)
            }
            m_emptyView?.isHidden = false
        } else {
            m_emptyView?.isHidden = true
        }
    }

    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        Debug.print("[SENSOR_MOVE_GRAPH] chartValueSelected \(entry.y)", event: .dev)
        averageDayInfo(type: m_nowPageInfo.m_dayType, x: entry.x, data: m_arrFilterInfo)
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
