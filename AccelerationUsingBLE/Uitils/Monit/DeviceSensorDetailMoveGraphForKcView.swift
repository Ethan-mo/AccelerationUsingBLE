//
//  DeviceSensorDetailNotiTableViewController.swift
//  Monit
//
//  Created by 맥 on 2017. 9. 22..
//  Copyright © 2017년 맥. All rights reserved.
//

import UIKit
import Charts

class DeviceSensorDetailMoveGraphForKcView: UIView, ChartViewDelegate {
    @IBOutlet weak var lineChartView: LineChartView!
    @IBOutlet weak var btnLeft: UIButton!
    @IBOutlet weak var btnRight: UIButton!
    @IBOutlet weak var lblDayTitle: UILabel!
    @IBOutlet weak var lblDayContents: UILabel!
    @IBOutlet weak var lblClickTitle: UILabel!
    @IBOutlet weak var lblClickInfo: UILabel!
    @IBOutlet weak var lblAvgTitle: UILabel!
    @IBOutlet weak var lblAvgInfo: UILabel!
    
    class SensorMovAvgGraphInfo {
        var m_did: Int = 0
        var m_movAvg: Double = 0
        var m_movCnt: Int = 0
        var m_xAxisValue: Int = 0
        var m_timeStamp: Int = 0
        var m_isHorizontal: Bool = false
    }
    
    struct FilterData {
        var m_xAxis: Double = 0.0
        var m_yAxis: Double = 0.0
    }
    
    static let OUTPUT_DAYS = 7
    static let ONEDAY_RANGE = 86400
    static let AVG_SEC = 600
    
    class GraphXAxisFormatter: NSObject, IAxisValueFormatter {
        let m_graphRangeStDate: Date = {
            let _dateCast = UI_Utility.convertStringToDate(UI_Utility.nowLocalDate(type: .yyyy_MM_dd), type: .yyyy_MM_dd)!
            Debug.print("[SENSOR_MOV_GRAPH] m_graphRangeStDate: \(_dateCast.adding(minutes: -1 * 24 * 60 * (DeviceSensorDetailMoveGraphForKcView.OUTPUT_DAYS - 1)))", event: .dev)
            return _dateCast.adding(minutes: -1 * 24 * 60 * (DeviceSensorDetailMoveGraphForKcView.OUTPUT_DAYS - 1))
        }()
        
        func stringForValue(_ value: Double, axis: AxisBase?) -> String {
//            Debug.print("\(Int(value) % ONEDAY_RANGE)")
            let _dateSlice = UI_Utility.getDateToSliceDate(date: m_graphRangeStDate.adding(second: Int(value)))
            if (_dateSlice.3 == 0) {
                return "\(_dateSlice.1)/\(_dateSlice.2)\n\(String(format: "%02d", _dateSlice.3))"
            }
            return "\(String(format: "%02d", _dateSlice.3))\n"
        }
    }

    var m_parent: DeviceSensorDetailGraphViewController?
    var m_flow = Flow()
    var m_emptyView: GraphEmptyView?
    
    var isPageMin: Bool {
        get {
            if let index = m_arrDate.index(of: m_selectedDateString) {
                if (index + 1 < m_arrDate.count) {
                    return false
                }
            }
            return true
        }
    }
    
    var isPageMax: Bool {
        get {
            if let index = m_arrDate.index(of: m_selectedDateString) {
                if (index > 0) {
                    return false
                }
            }
            return true
        }
    }
    
    var stUTCDateCast: Date {
        get {
            let _localDate = UI_Utility.localToUTC(date: m_graphRangeTodayDateString, fromType: .yyyy_MM_dd, toType: .full)
            let _dateCast = UI_Utility.convertStringToDate(_localDate, type: .full)!
            Debug.print("[SENSOR_MOV_GRAPH] nowUTCDateCast: \(_dateCast.adding(minutes: -1 * 24 * 60 * (DeviceSensorDetailMoveGraphForKcView.OUTPUT_DAYS - 1)))", event: .dev)
            return _dateCast.adding(minutes: -1 * 24 * 60 * (DeviceSensorDetailMoveGraphForKcView.OUTPUT_DAYS - 1))
        }
    }
    
    var edUTCDateCast: Date {
        get {
            let _localDate = UI_Utility.localToUTC(date: m_graphRangeTodayDateString, fromType: .yyyy_MM_dd, toType: .full)
            let _dateCast = UI_Utility.convertStringToDate(_localDate, type: .full)!
            Debug.print("[SENSOR_MOV_GRAPH] nowUTCDateLastTimeCast: \(_dateCast.adding(minutes: 24 * 60))", event: .dev)
            return _dateCast.adding(minutes: 24 * 60)
        }
    }

    var prevDateString: String {
        get {
            if let index = m_arrDate.index(of: m_selectedDateString) {
                if (index + 1 < m_arrDate.count) {
                    let _date = m_arrDate[index + 1]
                    return String(_date[_date.index(_date.endIndex, offsetBy: -5)...])
                }
            }
            return ""
        }
    }
    
    var nextDateString: String {
        get {
            if let index = m_arrDate.index(of: m_selectedDateString) {
                if (index > 0) {
                    let _date = m_arrDate[index - 1]
                    return String(_date[_date.index(_date.endIndex, offsetBy: -5)...])
                }
            }
            return ""
        }
    }
    
    var nowDayContents: String {
        get {
            let _nowDateStr = UI_Utility.nowUTCDate(type: .yyyy_MM_dd)
            let _nowDate = UI_Utility.convertStringToDate(_nowDateStr, type: .yyyy_MM_dd)
            let _currentDate = UI_Utility.convertStringToDate(m_selectedDateString, type: .yyyy_MM_dd)
            let componenets = Calendar.current.dateComponents([.day], from: _currentDate!, to: _nowDate!)
            if let day = componenets.day {
                if (day == 0) {
                    return "hub_graph_today".localized
                } else {
                    return String(format: "hub_graph_ago".localized, day.description)
                }
            }
            return ""
        }
    }
    
    var deepSleep: String {
        get {
            var _deepSleepSecond = 0
            let _low = lineChartView.lowestVisibleX
            let _high = lineChartView.highestVisibleX
            for item in m_filterData {
                if (_low <= item.m_xAxisValue && item.m_xAxisValue <= _high) {
                    if (item.m_mov == 0 && !item.m_isHorizontal) {
                        _deepSleepSecond += 10
                    }
                }
            }
            if (_deepSleepSecond >= 3600) {
                return "\(_deepSleepSecond / 3600)\("time_elapsed_hour".localized) \((_deepSleepSecond % 3600) / 60)\("time_elapsed_minute".localized)"
            } else if (_deepSleepSecond >= 60) {
                return "\(_deepSleepSecond / 60)\("time_elapsed_minute".localized)"
            } else {
                return "-"
            }
        }
    }
    
    var nowMove: String {
        get {
            var _movText = "-"
            if let _info = m_parent!.m_parent!.m_parent!.sensorStatusInfo {
                _movText = UIManager.instance.getSensorMovementLevelString(type: _info.movement)
            }
            return _movText
        }
    }
    
    var m_packetLastUpdateTime: Date? // reload될때 시간을 체크하여 가져온다. (다른 noti와 다름.)
    var m_arrDate: [String] = {
        var _todayDate = UI_Utility.nowLocalDate(type: .yyyy_MM_dd)
        var _date: [String] = [_todayDate]
        return _date
    }()
    var m_selectedDateString: String = {
        return UI_Utility.nowLocalDate(type: .yyyy_MM_dd)
    }()
    let m_graphRangeTodayDateString: String = UI_Utility.nowLocalDate(type: .yyyy_MM_dd)
    let m_graphRangeStDateString: String = {
        let _dateCast = UI_Utility.convertStringToDate(UI_Utility.nowLocalDate(type: .yyyy_MM_dd), type: .yyyy_MM_dd)!
        Debug.print("[SENSOR_MOV_GRAPH] m_graphRangeStDateString: \(_dateCast.adding(minutes: -1 * 24 * 60 * (DeviceSensorDetailMoveGraphForKcView.OUTPUT_DAYS - 1)))", event: .dev)
        let _addDate = _dateCast.adding(minutes: -1 * 24 * 60 * (DeviceSensorDetailMoveGraphForKcView.OUTPUT_DAYS - 1))
        return UI_Utility.convertDateToString(_addDate, type: .yyyy_MM_dd)
    }()
    let m_graphRangeStDate: Date = {
        let _dateCast = UI_Utility.convertStringToDate(UI_Utility.nowLocalDate(type: .yyyy_MM_dd), type: .yyyy_MM_dd)!
        Debug.print("[SENSOR_MOV_GRAPH] m_graphRangeStDate: \(_dateCast.adding(minutes: -1 * 24 * 60 * (DeviceSensorDetailMoveGraphForKcView.OUTPUT_DAYS - 1)))", event: .dev)
        return _dateCast.adding(minutes: -1 * 24 * 60 * (DeviceSensorDetailMoveGraphForKcView.OUTPUT_DAYS - 1))
    }()
    var selectedDateToAxisValue: Double {
        get {
            let _selectedDateCast = UI_Utility.convertStringToDate(m_selectedDateString, type: .yyyy_MM_dd)!
            let calendar = Calendar.current
            let date1 = calendar.startOfDay(for: m_graphRangeStDate.adding(second: -1 * DeviceSensorDetailMoveGraphView.ONEDAY_RANGE))
            let date2 = calendar.startOfDay(for: _selectedDateCast)
            let components = calendar.dateComponents([.second], from: date1, to: date2)
            let _movePosX = components.second! - Int(lineChartView.highestVisibleX - lineChartView.lowestVisibleX)
            Debug.print("[SENSOR_MOV_GRAPH] selectedDateToAxisValue: \(components.second!), \(lineChartView.highestVisibleX - lineChartView.lowestVisibleX)", event: .dev)
            return Double(_movePosX)
        }
    }
    var m_filterData: [SensorMovGraphInfo] = []
    var graphInit = Flow()
    
    func setCtrl() {
        lineChartView.delegate = self
        lblClickTitle.text = "sensor_move_graph_deep_sleep".localized
        setUI()
    }
    
    func setUI() {
        lblAvgTitle.text = "sensor_move_graph_now".localized
        setDateSort()
        setDateUI()
        setDataFilter()
        lblClickInfo.text = deepSleep
        lblAvgInfo.text = nowMove
        reloadData()
    }
    
    func setDateSort() {
        for item in 1...(DeviceSensorDetailMoveGraphForKcView.OUTPUT_DAYS - 1) {
            let _lDate = UI_Utility.convertDateToString(NSDate(timeIntervalSinceNow: TimeInterval(-86400 * item)) as Date, type: .yyyy_MM_dd)
            if (!m_arrDate.contains(_lDate)) {
                m_arrDate.append(_lDate)
            }
        }
    }
    
    func setDateUI() {
        btnLeft.isHidden = false
        btnRight.isHidden = false
        if (isPageMin) {
            btnLeft.isHidden = true
        }
        if (isPageMax) {
            btnRight.isHidden = true
        }
        lblDayTitle.text = nowDayContents
        lblDayContents.text = m_selectedDateString
    }
    
    func setPrevPage() {
        if let index = m_arrDate.index(of: m_selectedDateString) {
            if (index + 1 < m_arrDate.count) {
                m_selectedDateString = m_arrDate[index + 1]
            }
        }
        Debug.print("[SENSOR_MOV_GRAPH] prev NowDate: \(m_selectedDateString)")
    }
    
    func setNextPage() {
        if let index = m_arrDate.index(of: m_selectedDateString) {
            if (index > 0) {
                m_selectedDateString = m_arrDate[index - 1]
            }
        }
        Debug.print("[SENSOR_MOV_GRAPH] next NowDate: \(m_selectedDateString)")
    }
    
    func setDataFilter() {
        var _filterData: [SensorMovGraphInfo] = []
        let _todayStTimestamp = stUTCDateCast.millisecondsSince1970
        let _todayEdTimestamp = edUTCDateCast.millisecondsSince1970
        for item in DataManager.instance.m_userInfo.sensorMovGraph.m_lst { // 서버에서 받은 패킷당 정보가 리스트에 저장 되어있다.
            if let _detailInfo = m_parent!.m_parent!.m_parent!.m_detailInfo {
                if (item.m_did == _detailInfo.m_did) {
                    var _isContainData = false // 포함되는 항목은 기간내, 그래프 시작시간이 구간내에 포함, 그래프 종료 시간이 구간내에 포함, 그래프 시작 종료 시간이 구간내에 포함.
                    if (item.m_castTimeInfo.m_timeCast.millisecondsSince1970 <= _todayStTimestamp && _todayEdTimestamp <= item.m_edTimeInfo.m_timeCast.millisecondsSince1970) {
                        _isContainData = true
                    } else if (_todayStTimestamp <= item.m_castTimeInfo.m_timeCast.millisecondsSince1970 && item.m_castTimeInfo.m_timeCast.millisecondsSince1970 <= _todayEdTimestamp) {
                        _isContainData = true
                    } else if (_todayStTimestamp <= item.m_edTimeInfo.m_timeCast.millisecondsSince1970 && item.m_edTimeInfo.m_timeCast.millisecondsSince1970 <= _todayEdTimestamp) {
                        _isContainData = true
                    }
                    if (_isContainData) {
                        let _orginTimestamp = item.m_castTimeInfo.m_timeCast.millisecondsSince1970
                        for (i, itemMov) in item.m_descryptMov.enumerated() {
                            if (_todayStTimestamp <= _orginTimestamp + 10 * i && _orginTimestamp + 10 * i <= _todayEdTimestamp) { // 상세한 시간 구간을 확인한다.
                                let _mov = Int(String(itemMov), radix: 16) ?? 0
                                if (_mov != 15) {
                                    let _xAxisValue = Double((_orginTimestamp + 10 * i) - _todayStTimestamp) // / 60.0
//                                    Debug.print("\(_xAxisValue),\(_mov)")
                                    _filterData.append(SensorMovGraphInfo(did: _detailInfo.m_did, mov: _mov == 14 ? 0 : _mov, xAxisValue: _xAxisValue, isHorizontal: _mov == 14 ? true : false, timestamp: _orginTimestamp + 10 * i))
                                }
                            }
                        }
                    }
                }
            }
        }

        // 5분 단위로 변경
        var _dic: [Int: SensorMovAvgGraphInfo] = [:]
        for item in _filterData {
            let _xAxisValuePart = Int(Int(item.m_xAxisValue) / DeviceSensorDetailMoveGraphView.AVG_SEC)

            if let _value = _dic[_xAxisValuePart] {
                _value.m_movAvg = (Double(_value.m_movAvg) * Double(_value.m_movCnt) + Double(item.m_mov)) / Double(_value.m_movCnt + 1)
//                Debug.print("\(_xAxisValuePart), \(_value.m_movAvg) = \(_value.m_movAvg) * \(_value.m_movCnt) + \(item.m_mov) / \(_value.m_movCnt + 1)")
                _value.m_movCnt += 1
                _dic.updateValue(_value, forKey: _xAxisValuePart)
            } else {
                let _info = SensorMovAvgGraphInfo()
                _info.m_did = item.m_did
                _info.m_movAvg = Double(item.m_mov)
                _info.m_movCnt = 1
                _info.m_xAxisValue = _xAxisValuePart
                _info.m_timeStamp = Int(item.m_timestamp / DeviceSensorDetailMoveGraphView.AVG_SEC) * DeviceSensorDetailMoveGraphView.AVG_SEC
                _info.m_isHorizontal = item.m_isHorizontal
                _dic.updateValue(_info, forKey: _xAxisValuePart)
            }
        }

        var _filterDataAvg: [SensorMovGraphInfo] = []
        for (_, value) in _dic {
//            Debug.print("\(value.m_xAxisValue), \(value.m_movAvg), \(value.m_movCnt)")
            _filterDataAvg.append(SensorMovGraphInfo(did: value.m_did, mov: Int(value.m_movAvg), xAxisValue: Double(value.m_xAxisValue * DeviceSensorDetailMoveGraphView.AVG_SEC), isHorizontal: false, timestamp: value.m_timeStamp))
        }
        
        _filterDataAvg.sort { (object1, object2) -> Bool in
            return object1.m_xAxisValue < object2.m_xAxisValue
        }
//        for item in _filterDataAvg {
//            Debug.print("\(item.m_xAxisValue), \(item.m_mov), \(item.m_isHorizontal)")
//        }
        self.m_filterData = _filterDataAvg
    }

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
        var _arrFilterData: [FilterData] = []
//        var _arrHighlightsEntry: [Highlight] = []
        var _chartYValues: [ChartDataEntry] = []
        var _chartYColors: [NSUIColor] = []
        let _chartData = LineChartData()
        
        for (i, item) in m_filterData.enumerated() {
            var _filterData = FilterData()
            _filterData.m_xAxis = Double(item.m_xAxisValue)
            _filterData.m_yAxis = Double(item.m_mov)
            _chartYValues.append(ChartDataEntry(x: item.m_xAxisValue, y: Double(item.m_mov)))
     
            if (m_filterData.count > i + 1) {
                if (m_filterData[i + 1].m_xAxisValue - item.m_xAxisValue == Double(DeviceSensorDetailMoveGraphView.AVG_SEC)) {
                    let _isDeepsleep = !item.m_isHorizontal && item.m_mov == 0
                    let _isNextDeepsleep = !m_filterData[i + 1].m_isHorizontal && m_filterData[i + 1].m_mov == 0
                    _chartYColors.append(_isDeepsleep && _isNextDeepsleep ? COLOR_TYPE.purple.color : COLOR_TYPE.red.color)
                } else {
                    _chartYColors.append(UIColor.clear)
                }
            } else {
                _chartYColors.append(COLOR_TYPE.lblWhiteGray.color)
            }
//            _chartYColors.append(COLOR_TYPE.purple.color)
            _arrFilterData.append(_filterData)
        }
        
//        for item in 0...(DeviceSensorDetailMoveGraphView.OUTPUT_DAYS - 1) {
//            _arrHighlightsEntry.append(Highlight(x: Double(DeviceSensorDetailMoveGraphView.ONEDAY_RANGE * item), y: Double(0), dataSetIndex: 0))
//        }

        var _minFilterData: FilterData?
        var _maxFilterData: FilterData?
        for item in _arrFilterData {
            if (_minFilterData == nil) {
                _minFilterData = item
            }
            if (_maxFilterData == nil) {
                _maxFilterData = item
            }
            
            if (_minFilterData!.m_yAxis > item.m_yAxis) {
                _minFilterData = item
            }
            if (_maxFilterData!.m_yAxis < item.m_yAxis) {
                _maxFilterData = item
            }
        }
        
        var _axisMinimum = _minFilterData?.m_yAxis ?? -1
        var _axisMaximum = _maxFilterData?.m_yAxis ?? 13.0
        _axisMaximum = _axisMaximum == 0 ? 13.0 : _axisMaximum
        
        let _offset = (_axisMaximum - _axisMinimum) / 2
        _axisMinimum -= _offset
        _axisMaximum += _offset
//        Debug.print("[SENSOR_MOV_GRAPH] axisMinimum: \(_minFilterData?.m_yAxis ?? 0)", event: .dev)
//        Debug.print("[SENSOR_MOV_GRAPH] axisMaximum: \(_maxFilterData?.m_yAxis ?? 13.0)", event: .dev)
        
        let _ds = LineChartDataSet(values: _chartYValues, label: nil)
        _ds.drawCircleHoleEnabled = false
        _ds.colors = _chartYColors
        _ds.lineWidth = 1
        _ds.drawCirclesEnabled = false
        _ds.circleRadius = 1
        _ds.drawValuesEnabled = false
        _chartData.addDataSet(_ds)
        
        lineChartView.leftAxis.axisMinimum = -2 // _axisMinimum
        lineChartView.leftAxis.axisMaximum = 13 // _axisMaximum
        lineChartView.leftAxis.drawGridLinesEnabled = false
        lineChartView.leftAxis.drawLabelsEnabled = false
        lineChartView.clipValuesToContentEnabled = false
        lineChartView.leftAxis.labelFont = UIFont(name: Config.FONT_NotoSans, size: 10.0)!
        
        lineChartView.rightAxis.drawGridLinesEnabled = false
        lineChartView.rightAxis.drawLabelsEnabled = false
        lineChartView.rightAxis.labelFont = UIFont(name: Config.FONT_NotoSans, size: 10.0)!
        
        lineChartView.xAxis.drawGridLinesEnabled = true
        lineChartView.xAxis.drawAxisLineEnabled = false
        lineChartView.xAxis.gridColor = COLOR_TYPE.lblWhiteGray.color
        lineChartView.xAxis.axisRange = Double(DeviceSensorDetailMoveGraphView.ONEDAY_RANGE)
        lineChartView.xAxis.axisMinimum = 0
        lineChartView.xAxis.axisMaximum = Double(DeviceSensorDetailMoveGraphView.ONEDAY_RANGE * DeviceSensorDetailMoveGraphForKcView.OUTPUT_DAYS)
        lineChartView.xAxis.labelPosition = .bottom
        lineChartView.xAxis.valueFormatter = GraphXAxisFormatter()
        lineChartView.xAxis.labelCount = 13
        lineChartView.xAxis.forceLabelsEnabled = false // 하단 라벨, 뒤에 선 고정
        lineChartView.xAxis.granularity = 1
        lineChartView.xAxis.labelFont = UIFont(name: Config.FONT_NotoSans, size: 10.0)!
        
        lineChartView.data = _chartData
        lineChartView.chartDescription?.text = ""
        lineChartView.pinchZoomEnabled = false
        lineChartView.scaleXEnabled = true
        lineChartView.scaleYEnabled = false
        lineChartView.legend.enabled = false
        lineChartView.doubleTapToZoomEnabled = false
        
        graphInit.one {
            lineChartView.setVisibleXRangeMaximum(Double(52000)) // view range
            lineChartView.moveViewToX(Double(DeviceSensorDetailMoveGraphView.ONEDAY_RANGE * DeviceSensorDetailMoveGraphForKcView.OUTPUT_DAYS)) // move to xAxis
        }
        
        let marker = SensorMovGraphBalloonMarker(color: COLOR_TYPE.lblGray.color, font: UIFont(name: Config.FONT_NotoSans, size: 12)!, textColor: UIColor.white, insets: UIEdgeInsets(top: 0, left: 7.0, bottom: 4.0, right: 7.0))

        if let _minValue = _minFilterData {
            marker.m_bttomOffsetValue = _minValue.m_yAxis
        }
        
        marker.minimumSize = CGSize(width: 30.0, height: 30.0)
        lineChartView.marker = marker
//        lineChartView.highlightValues(_arrHighlightsEntry)
        
        setEmptyGraph(isEnable: _arrFilterData.count <= 0)
    }

    func setEmptyGraph(isEnable: Bool) {
        if (isEnable) {
            if (m_emptyView == nil) {
                m_emptyView = .fromNib()
                m_emptyView!.frame = lineChartView.bounds
                m_emptyView!.setInfo()
                self.lineChartView.addSubview(m_emptyView!)
            }
            m_emptyView?.isHidden = false
        } else {
            m_emptyView?.isHidden = true
        }
    }
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        Debug.print("[SENSOR_MOV_GRAPH] chartValueSelected \(entry.y)", event: .dev)
        for item in m_filterData {
            if (item.m_xAxisValue == entry.x) {
                lblAvgTitle.text = item.lTimeSelectString
                lblAvgInfo.text = UIManager.instance.getSensorMovementLevelString(type: item.movLevel)
                break
            }
        }
    }
    
    func chartTranslated(_ chartView: ChartViewBase, dX: CGFloat, dY: CGFloat) {
        setLblTitleDate(highestVisibleX: lineChartView.highestVisibleX)
        setDeepSleep()
    }
    
    func setLblTitleDate(highestVisibleX: Double) {
        let _highestVisibleX = Int(highestVisibleX) % DeviceSensorDetailMoveGraphView.ONEDAY_RANGE == 0 ? highestVisibleX - 1 : highestVisibleX
        m_selectedDateString = xAxisToDate(value: _highestVisibleX)
        setDateUI()
    }
    
    func setDeepSleep() {
        lblClickInfo.text = deepSleep
    }
    
    func xAxisToDate(value: Double) -> String {
        return UI_Utility.convertDateToString(m_graphRangeStDate.adding(second: Int(value)), type: .yyyy_MM_dd)
    }
    
    @IBAction func onClick_prev(_ sender: UIButton) {
        setPrevPage()
        lineChartView.moveViewToX(selectedDateToAxisValue) // move to xAxis
        setDateUI()
    }
    
    @IBAction func onClick_next(_ sender: UIButton) {
        setNextPage()
        lineChartView.moveViewToX(selectedDateToAxisValue) // move to xAxis
        setDateUI()
    }
}
