//
//  DeviceSensorDetailNotiTableViewController.swift
//  Monit
//
//  Created by 맥 on 2017. 9. 22..
//  Copyright © 2017년 맥. All rights reserved.
//

import UIKit
import Charts

class DeviceHubDetailGraphCommonGraphView: UIView, ChartViewDelegate {
    @IBOutlet weak var chartView: LineChartView!
    @IBOutlet weak var stView: UIStackView!
    
    @IBOutlet weak var viewFilter: UIView!
    @IBOutlet weak var btnFilterWeekly: UIButton!
    @IBOutlet weak var btnFilterMonthly: UIButton!
    
    @IBOutlet weak var lblPageContents: UILabel!
    @IBOutlet weak var btnPagePrev: UIButton!
    @IBOutlet weak var btnPageNext: UIButton!
    
    /// weekly, monthly
    @IBOutlet weak var viewWeeklyNowTemp: UIView!
    @IBOutlet weak var lblWeeklyNowTempTitle: UILabel!
    @IBOutlet weak var lblWeeklyNowTempValue: UILabel!
    @IBOutlet weak var lblWeeklyNowTempUnit: UILabel!
    
    @IBOutlet weak var viewWeeklyNowAvgTemp: UIView!
    @IBOutlet weak var lblWeeklyNowAvgTempTitle: UILabel!
    @IBOutlet weak var lblWeeklyNowAvgTempValue: UILabel!
    @IBOutlet weak var lblWeeklyNowAvgTempUnit: UILabel!
    
    /// day
    @IBOutlet weak var viewDay: UIView!
    @IBOutlet weak var lblDayTitle: UILabel!
    
    @IBOutlet weak var viewDayCurrentTemp: UIView!
    @IBOutlet weak var lblDayCurrentTempTitle: UILabel!
    @IBOutlet weak var lblDayCurrentTempValue: UILabel!
    @IBOutlet weak var lblDayCurrentTempUnit: UILabel!
    
    static let AVG_SEC = 600
    static let ONEDAY_RANGE = 86400
    
    var m_parent: DeviceHubDetailGraphViewController?
    var m_emptyView: GraphEmptyView?
    var m_initFlow = Flow()
    
    var m_nowPageInfo: PagingData!
    var m_state: HUB_TYPES_GRAPH_TYPE = .tem
    var m_lastUpdateTime: Date? // reload될때 시간을 체크하여 가져온다. (다른 noti와 다름.)
    var m_filterData: [HubGraphInfo] = []
    
    struct FilterData {
        var m_xAxis: Double = 0.0
        var m_yAxis: Double = 0.0
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
            let _hour = Int(value) / 60
            if (_hour % 6 == 0) {
                if (m_type == .day) {
                    return "\(_hour)"
                } else {
                    if (value >= 0) {
                        let calendar = Calendar.current
                        if let date = calendar.date(byAdding: .minute, value: Int(value), to: self.m_stDate) {
                            let _lDate = UI_Utility.UTCToLocal(date: UI_Utility.convertDateToString(date, type: .full))
                            let _dateSlice = UI_Utility.getDateToSliceDateString(date: _lDate)
                            return "\(_dateSlice.1)/\(_dateSlice.2)"
                        }
                    }
                }
            }
            return ""
        }
    }
    
    var avgValue: String {
        get {
            var _arrInfo = [Double]()
            for item in m_filterData {
                if let _info = item.m_statusInfo {
                    let _temp = Double(_info.m_temp) / 100.0
                    let _tempValue = UIManager.instance.getTemperatureProcessing(value: _temp)
                    
                    if (_tempValue == -0.01) {
                        continue
                    }
                    switch m_state {
                    case .score: _arrInfo.append(Double(_info.scoreValue))
                    case .tem: _arrInfo.append(_tempValue)
                    case .hum: _arrInfo.append(_info.humValue)
                    case .voc:
                        if (_info.vocValue != -0.01) {
                            _arrInfo.append(_info.vocValue)
                        }
                    }
                }
            }
            if (_arrInfo.count == 0) {
                return "-"
            }
            
            var _total: Double = 0.0
            for item in _arrInfo {
                _total += item
            }
            let _avg = (_total / Double(_arrInfo.count))
            let _avgToDouble = (Double(Int(_avg * 10)) / 10.0) as Double
            
            switch m_state {
            case .score: return _avgToDouble.description
            case .tem: return Int(_avg).description
            case .hum: return _avgToDouble.description
            case .voc: return DeviceHubTypesDetailGraphViewController.getVocString(type: HubTypesStatusInfoBase.getVocType(attached: 1, value: Int(_avg * 100)))
            }
        }
    }
    
    var nowValue: String {
        get {
            var _retValue = "-"
            let _lastDate = NSDate(timeIntervalSinceNow: TimeInterval(-600)) as Date
            let _lst = DataManager.instance.m_userInfo.hubGraph.m_lst
            for item in _lst {
                //                Debug.print("\(_lastDate), \(item.m_timeCast)")
                if (_lastDate <= item.m_castTimeInfo.m_timeCast) {
                    if let _info = item.m_statusInfo {
                        let _temp = Double(_info.m_temp) / 100.0
                        let _tempValue = UIManager.instance.getTemperatureProcessing(value: _temp)
                        
                        if (_tempValue != -0.01) {
                            switch m_state {
                            case .score: _retValue = Double(_info.scoreValue).description
                            case .tem: _retValue = Int(_tempValue).description
                            case .hum: _retValue = _info.humValue.description
                            case .voc:
                                if (_info.vocValue != -0.01) {
                                    _retValue = DeviceHubTypesDetailGraphViewController.getVocString(type: _info.voc)
                                }
                            }
                            break
                        }
                    }
                }
            }
            return _retValue.description
        }
    }
    
    func setCtrl(state: HUB_TYPES_GRAPH_TYPE) {
        m_initFlow.one {
            self.m_state = state
            m_nowPageInfo = PagingData(type: .day, idx: 1, bday: "200101")
            setInitUI()
            setUI()
        }
    }
    
    func setChangeType(state: HUB_TYPES_GRAPH_TYPE) {
        self.m_state = state
        m_nowPageInfo = PagingData(type: .day, idx: 1, bday: "200101")
        setUI()
    }
    
    func setInitUI() {
        chartView.delegate = self
        self.frame.size.height = m_parent!.viewGraph.frame.size.height
        
        UI_Utility.customViewBorder(view: viewFilter, radius: 8, width: 1, color: UIColor.clear.cgColor)
        UI_Utility.customButtonBorder(button: btnFilterWeekly, radius: 8, width: 1, color: UIColor.clear.cgColor)
        UI_Utility.customButtonBorder(button: btnFilterMonthly, radius: 8, width: 1, color: UIColor.clear.cgColor)
        
        UI_Utility.customViewBorder(view: viewWeeklyNowTemp, radius: 10, width: 1, color: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0))
        UI_Utility.customViewShadow(view: viewWeeklyNowTemp, radius: 1, offsetWidth: 1, offsetHeight: 1, color: UIColor.gray.cgColor, opacity: 0.5)
        UI_Utility.customViewBorder(view: viewWeeklyNowAvgTemp, radius: 10, width: 1, color: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0))
        UI_Utility.customViewShadow(view: viewWeeklyNowAvgTemp, radius: 1, offsetWidth: 1, offsetHeight: 1, color: UIColor.gray.cgColor, opacity: 0.5)
        
        viewDay.isHidden = true
        UI_Utility.customViewBorder(view: viewDayCurrentTemp, radius: 8, width: 1, color: UIColor.clear.cgColor)
        UI_Utility.customViewBorder(view: viewDayCurrentTemp, radius: 8, width: 1, color: UIColor.clear.cgColor)
        
         btnFilterWeekly.setTitle("time_day".localized, for: .normal)
        btnFilterMonthly.setTitle("sensor_graph_week".localized, for: .normal)
    }
    
    func setUI() {
        setDayUI(type: m_nowPageInfo.m_dayType)
        lblPageContents.text = String(format: "%@", m_nowPageInfo.m_dayInfo)

        btnPageNext.isHidden = false
        if (!m_nowPageInfo.isPageMax) {
            btnPageNext.isHidden = true
        }
        btnPagePrev.isHidden = false
        if (!m_nowPageInfo.isPageMin) {
            btnPagePrev.isHidden = true
        }
        
        setDataFilter()
        averageInfo(type: self.m_nowPageInfo.m_dayType) // setDataSort 선행
        lblDayCurrentTempTitle.text = self.m_state == .tem ? "lamp_environment_graph_temperature_selected".localized : "lamp_environment_graph_humidity_selected".localized
        
        reloadNoti()
    }
    
    func averageInfo(type: GRAPH_PAGE_TYPE) {
        if (type == .weekly) {
            lblWeeklyNowTempTitle.text = self.m_state == .tem ? "lamp_environment_graph_temperature_current".localized : "lamp_environment_graph_humidity_current".localized
            lblWeeklyNowAvgTempTitle.text = self.m_state == .tem ? "lamp_environment_graph_temperature_average".localized : "lamp_environment_graph_humidity_average".localized
        } else {
            lblWeeklyNowTempTitle.text = self.m_state == .tem ? "lamp_environment_graph_temperature_average".localized : "lamp_environment_graph_humidity_current".localized
            lblWeeklyNowAvgTempTitle.text = self.m_state == .tem ? "lamp_environment_graph_temperature_average".localized: "lamp_environment_graph_humidity_average".localized
        }
        
        lblWeeklyNowTempValue.text = nowValue
        lblWeeklyNowTempUnit.text = self.m_state == .tem ? UIManager.instance.temperatureUnitStr : "%"
        lblWeeklyNowAvgTempValue.text = avgValue
        lblWeeklyNowAvgTempUnit.text = self.m_state == .tem ? UIManager.instance.temperatureUnitStr : "%"
    }
    
    func averageDayInfo(type: GRAPH_PAGE_TYPE, info: HubGraphInfo, value: String) {
         viewDay.isHidden = false
         stView.layoutIfNeeded()
         
//        let _lDate = UI_Utility.UTCToLocal(date: UI_Utility.convertDateToString(info.m_castTimeInfo.m_timeCast, type: .full))
//        let _dateSlice = UI_Utility.getDateToSliceDateString(date: _lDate)
        lblDayTitle.text = UI_Utility.getDateByLanguageFromString(
        UI_Utility.convertDateToString(info.m_castTimeInfo.m_lTimeCast, type: .full), fromType: .full, language: Config.languageType)
        lblDayCurrentTempValue.text = value
        lblDayCurrentTempUnit.text = self.m_state == .tem ? UIManager.instance.temperatureUnitStr : "%"
     }
    
    func setDataFilter() {
        let _lst = DataManager.instance.m_userInfo.hubGraph.m_lst
        self.m_filterData = _lst.filter({ (item: HubGraphInfo) -> (Bool) in
            if let _detailInfo = m_parent!.m_parent!.m_parent!.m_detailInfo {
                if (item.m_did == _detailInfo.m_did) {
                    if (m_nowPageInfo.m_stDateCast <= item.m_castTimeInfo.m_lTimeCast && item.m_castTimeInfo.m_lTimeCast <= m_nowPageInfo.m_edDateCast) {
                        return true
                    }
                }
            }
            return false
        })
        
        self.m_filterData.sort { (object1, object2) -> Bool in
            return object1.m_castTimeInfo.m_timeCast < object2.m_castTimeInfo.m_timeCast
        }
//        for item in self.m_filterData {
//            Debug.print("tem:\(item.m_tem), hum:\(item.m_hum), voc:\(item.m_voc), \(item.m_xAxisValue) \(item.m_castTimeInfo.m_lTime)")
//        }
    }
    
    func reloadNoti() {
        setChartUI()
        if (m_lastUpdateTime == nil || m_lastUpdateTime! < NSDate(timeIntervalSinceNow: TimeInterval(-1 * Config.HUB_TYPES_GRAPH_UPDATE_LIMIT)) as Date) {
            if let _detailInfo = m_parent!.m_parent!.m_parent!.m_detailInfo {
                self.m_lastUpdateTime = Date()
                UIManager.instance.indicator(true)
                DataManager.instance.m_dataController.hubGraph.updateByDid(did: _detailInfo.m_did, handler: { (isSuccess) -> () in
                    if (isSuccess) {
                        UIManager.instance.indicator(false)
                        UIManager.instance.currentUIReload()
                    }
                })
            }
        }
    }
    
    func getColorByValue(value: Int) -> UIColor {
        var _retValue: UIColor = Config.channel == .kc ? COLOR_TYPE.green.color : COLOR_TYPE.blue.color
        switch m_state {
        case .score:
            switch HubStatusInfo.getScoreType(value: value) {
            case .good: _retValue = COLOR_TYPE.green.color
            case .normal: _retValue = COLOR_TYPE.gaugeGreen.color
            case .bad: _retValue = COLOR_TYPE.gaugeYellow.color
            case .veryBad: _retValue = COLOR_TYPE.gaugeRed.color
            }
        case .tem, .hum, .voc:
            let _tempValue = UIManager.instance.temperatureUnit == .Celsius ? value : Int(UI_Utility.fahrenheitToCelsius(tempInF: Double(value / 100)) * 100)
            if let _status = DataManager.instance.m_userInfo.deviceStatus.m_hubStatus.getInfoByDeviceId(did: m_parent!.m_parent!.m_parent!.m_detailInfo?.m_did ?? -1) {
                let _info = HubStatusInfo(did: m_parent!.m_parent!.m_parent!.m_detailInfo?.m_did ?? -1, name: "", power: 0, bright: 0, color: 0, attached: 1, temp: _tempValue, hum: value, voc: value, ap: "", apse: "", tempmax: _status.m_tempmax, tempmin: _status.m_tempmin, hummax: _status.m_hummax, hummin: _status.m_hummin, offt: "", onnt: "", con: 0, offptime: "", onptime: "")
                _retValue = getColorByHubStatusInfo(info: _info)
            }
        }
        return _retValue
    }
    
    func getColorByHubStatusInfo(info: HubStatusInfo?) -> UIColor {
        var _retValue: UIColor = Config.channel == .kc ? COLOR_TYPE.green.color : COLOR_TYPE.blue.color
        if let _info = info {
            let _temp = Double(_info.m_temp) / 100.0
            let _tempValue = UIManager.instance.getTemperatureProcessing(value: _temp)
            
            if (_tempValue != -0.01) {
                switch m_state {
                case .score:
                    switch _info.score {
                    case .good: _retValue = COLOR_TYPE.green.color
                    case .normal: _retValue = COLOR_TYPE.gaugeGreen.color
                    case .bad: _retValue = COLOR_TYPE.gaugeYellow.color
                    case .veryBad: _retValue = COLOR_TYPE.gaugeRed.color
                    }
                case .tem:
                    switch _info.temp {
                    case .normal:
                        switch Config.channel {
                        case .goodmonit, .kao: _retValue = COLOR_TYPE.blue.color
                        case .monitXHuggies: _retValue = COLOR_TYPE.blue.color
                        case .kc: _retValue = COLOR_TYPE.green.color
                        }
                    case .low:
                        switch Config.channel {
                        case .goodmonit, .kao: _retValue = COLOR_TYPE.red.color
                        case .monitXHuggies: _retValue = COLOR_TYPE.red.color
                        case .kc: _retValue = COLOR_TYPE.blue.color
                        }
                    case .high:
                        switch Config.channel {
                        case .goodmonit, .kao: _retValue = COLOR_TYPE.red.color
                        case .monitXHuggies: _retValue = COLOR_TYPE.red.color
                        case .kc: _retValue = COLOR_TYPE.red.color
                        }
                    }
                case .hum:
                    switch _info.hum {
                    case .normal:
                        switch Config.channel {
                        case .goodmonit, .kao: _retValue = COLOR_TYPE.blue.color
                        case .monitXHuggies: _retValue = COLOR_TYPE.blue.color
                        case .kc: _retValue = COLOR_TYPE.green.color
                        }
                    case .low, .high:
                        switch Config.channel {
                        case .goodmonit, .kao: _retValue = COLOR_TYPE.red.color
                        case .monitXHuggies: _retValue = COLOR_TYPE.red.color
                        case .kc: _retValue = COLOR_TYPE.orange.color
                        }
                    }
                case .voc:
                    switch _info.voc {
                    case .good, .normal: _retValue = COLOR_TYPE.blue.color
                    case .bad, .veryBad: _retValue = COLOR_TYPE.gaugeRed.color
                    default: break
                    }
                }
            }
        }
        return _retValue
    }
    
    func setDayUI(type: GRAPH_PAGE_TYPE) {
        switch type {
        case .day:
            btnFilterWeekly.backgroundColor = UIColor.white
            btnFilterMonthly.backgroundColor = UIColor.clear
        case .weekly:
            btnFilterWeekly.backgroundColor = UIColor.clear
            btnFilterMonthly.backgroundColor = UIColor.white
        case .monthly:
            break
        }
    }
    
    func setChartUI() {
        let _isDailyType = m_nowPageInfo.m_dayType == .day
        
        var _arrFilterData: [FilterData] = []
        var _arrHighlightsEntry: [Highlight] = []
        var _chartYValues: [ChartDataEntry] = []
        var _chartYColors: [NSUIColor] = []
        let _chartData = LineChartData()
        
        for item in m_filterData {
            if let _info = item.m_statusInfo {
                let _temp = Double(_info.m_temp) / 100.0
                let _tempValue = UIManager.instance.getTemperatureProcessing(value: _temp)
                
                if (_tempValue != -0.01) {
                    var _xAxisValue = 0.0
                    if (_isDailyType) {
                        _xAxisValue = item.m_xAxisValue
                    } else {
                        let _dateComponents = Calendar.current.dateComponents([.day], from: m_nowPageInfo.m_stDateCast, to: item.m_castTimeInfo.m_lTimeCast)
                        _xAxisValue = Double(1440 * (_dateComponents.day ?? 0) + Int(item.m_xAxisValue))
                    }
                    
                    var _filterData = FilterData()
                    _filterData.m_xAxis = Double(_xAxisValue)
                    switch m_state {
                    case .score:
                        _filterData.m_yAxis = Double(_info.scoreValue)
                        _chartYValues.append(ChartDataEntry(x: _xAxisValue, y: Double(_info.scoreValue)))
                        _chartYColors.append(getColorByHubStatusInfo(info: _info))
                        _arrFilterData.append(_filterData)
                    case .tem:
                        _filterData.m_yAxis = Double(_tempValue)
                        _chartYValues.append(ChartDataEntry(x: _xAxisValue, y: Double(_tempValue)))
                        _chartYColors.append(getColorByHubStatusInfo(info: _info))
                        _arrFilterData.append(_filterData)
                    case .hum:
                        _filterData.m_yAxis = Double(_info.humValue)
                        _chartYValues.append(ChartDataEntry(x: _xAxisValue, y: Double(_info.humValue)))
                        _chartYColors.append(getColorByHubStatusInfo(info: _info))
                        _arrFilterData.append(_filterData)
                    case .voc:
                        if (_info.vocValue != -0.01) {
                            _filterData.m_yAxis = Double(_info.vocValue)
                            _chartYValues.append(ChartDataEntry(x: _xAxisValue, y: Double(_info.vocValue)))
                            _chartYColors.append(getColorByHubStatusInfo(info: _info))
                            _arrFilterData.append(_filterData)
                        }
                    }
                }
            }
        }
        
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
        
        if (_minFilterData != nil) {
            _arrHighlightsEntry.append(Highlight(x: Double(_minFilterData!.m_xAxis), y: Double(_minFilterData!.m_yAxis), dataSetIndex: 0))
        }
        if (_maxFilterData != nil) {
            _arrHighlightsEntry.append(Highlight(x: Double(_maxFilterData!.m_xAxis), y: Double(_maxFilterData!.m_yAxis), dataSetIndex: 0))
        }
        
        var _axisMinimum = _minFilterData?.m_yAxis ?? 0.0
        var _axisMaximum = _maxFilterData?.m_yAxis ?? 100.0
        _axisMaximum = _axisMaximum == 0 ? 100.0 : _axisMaximum
        
        let _offset = (_axisMaximum - _axisMinimum) / 2
        _axisMinimum -= _offset
        _axisMaximum += _offset
        Debug.print("[GRAPH HUB] axisMinimum: \(_axisMinimum)", event: .dev)
        Debug.print("[GRAPH HUB] axisMaximum: \(_axisMaximum)", event: .dev)
        
        let _ds = LineChartDataSet(values: _chartYValues, label: nil)
        _ds.drawCircleHoleEnabled = false
        _ds.colors = _chartYColors
        _ds.lineWidth = 2
        _ds.drawCirclesEnabled = false
        _ds.circleRadius = 1
        _ds.drawValuesEnabled = false
        _chartData.addDataSet(_ds)
        
        chartView.leftAxis.axisMinimum = _axisMinimum
        chartView.leftAxis.axisMaximum = _axisMaximum
        chartView.leftAxis.drawGridLinesEnabled = false
        chartView.leftAxis.drawLabelsEnabled = false
        chartView.clipValuesToContentEnabled = false
        chartView.leftAxis.labelFont = UIFont(name: Config.FONT_NotoSans, size: 10.0)!
        
        chartView.rightAxis.drawGridLinesEnabled = false
        chartView.rightAxis.drawLabelsEnabled = false
        chartView.rightAxis.labelFont = UIFont(name: Config.FONT_NotoSans, size: 10.0)!
        
        chartView.xAxis.drawGridLinesEnabled = true
        chartView.xAxis.drawAxisLineEnabled = false
        chartView.xAxis.gridColor = COLOR_TYPE.lblWhiteGray.color
        chartView.xAxis.axisRange = _isDailyType ? 1440 : 1440 * 7
        chartView.xAxis.axisMinimum = 0
        chartView.xAxis.axisMaximum = _isDailyType ? 1440 : 1440 * 7
        chartView.xAxis.labelPosition = .bottom
        chartView.xAxis.valueFormatter = GraphXAxisFormatter(type: m_nowPageInfo.m_dayType, stDate: m_nowPageInfo.m_stDateCast)
        chartView.xAxis.labelCount = 13
        chartView.xAxis.forceLabelsEnabled = true
        chartView.xAxis.granularity = 1
        chartView.xAxis.labelFont = UIFont(name: Config.FONT_NotoSans, size: 9.0)!
        
        chartView.data = _chartData
        chartView.chartDescription?.text = ""
        chartView.pinchZoomEnabled = false
        chartView.scaleXEnabled = false
        chartView.scaleYEnabled = false
        chartView.legend.enabled = false
        
        let marker: HubTypesGraphBalloonMarker = HubTypesGraphBalloonMarker(state: m_state, color: COLOR_TYPE.lblGray.color, font: UIFont(name: Config.FONT_NotoSans, size: 12)!, textColor: UIColor.white, insets: UIEdgeInsets(top: 0, left: 7.0, bottom: 4.0, right: 7.0))
        //        marker.image = UIImage(named: "imgCheckRound")
        
        if let _minValue = _minFilterData {
            marker.m_bttomOffsetValue = _minValue.m_yAxis
        }
        
        marker.minimumSize = CGSize(width: 30.0, height: 30.0)
        chartView.marker = marker
        chartView.highlightValues(_arrHighlightsEntry)
        
        setEmptyGraph(isEnable: _arrFilterData.count <= 0)
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
        Debug.print("[GRAPH HUB] chartValueSelected \(entry.y)", event: .dev)
        for item in m_filterData {
            var _xAxisValue = 0.0
            if (m_nowPageInfo.m_dayType == .day) {
                _xAxisValue = item.m_xAxisValue
            } else {
                let _dateComponents = Calendar.current.dateComponents([.day], from: m_nowPageInfo.m_stDateCast, to: item.m_castTimeInfo.m_lTimeCast)
                _xAxisValue = Double(1440 * (_dateComponents.day ?? 0) + Int(item.m_xAxisValue))
            }
            
            if (_xAxisValue == entry.x) {
                var _value = "-"
                switch m_state {
                case .score: _value = entry.y.description
                case .tem: _value = Int(entry.y).description
                case .hum: _value = entry.y.description
                case .voc: _value = DeviceHubTypesDetailGraphViewController.getVocString(type: HubTypesStatusInfoBase.getVocType(attached: 1, value: Int(entry.y * 100)))
                }
                averageDayInfo(type: m_nowPageInfo.m_dayType, info: item, value: _value)
            }
        }
    }
    
    @IBAction func onClick_daily(_ sender: UIButton) {
        m_nowPageInfo.setDaily()
        setUI()
    }

    @IBAction func onClick_weekly(_ sender: UIButton) {
        m_nowPageInfo.setWeekly()
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
