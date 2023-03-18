//
//  DeviceSensorDetailNotiGraphView.swift
//  Monit
//
//  Created by john.lee on 2019. 4. 8..
//  Copyright © 2019년 맥. All rights reserved.
//

import UIKit
import Charts

class DeviceSensorDetailNotiGraphForKcView: UIView, ChartViewDelegate {
    @IBOutlet weak var barChartView: BarChartView!
    
    @IBOutlet weak var lblFilterWeekly: UILabel!
    @IBOutlet weak var lblFilterMonthly: UILabel!
    @IBOutlet weak var viewFilterWeeklyBar: UIView!
    @IBOutlet weak var viewFilterMonthlyBar: UIView!
    @IBOutlet weak var btnFilterWeekly: UIButton!
    @IBOutlet weak var btnFilterMonthly: UIButton!
    
    @IBOutlet weak var lblPageTitle: UILabel!
    @IBOutlet weak var lblPageContents: UILabel!
    @IBOutlet weak var btnPagePrev: UIButton!
    @IBOutlet weak var btnPageNext: UIButton!

    @IBOutlet weak var lblServerAvgCountTitle: UILabel!
    @IBOutlet weak var lblServerAvgCountContents: UILabel!
    @IBOutlet weak var lblMyAvgCountTitle: UILabel!
    @IBOutlet weak var lblMyAvgCountContents: UILabel!
    
    class DayFilterInfo {
        var m_diff: Int = -1
        var m_date: Date!
        var m_month: Int = 0
        var m_day: Int = 0
        var m_total: Int = 0
        
        init (nowDate: Date, currentDate: Date) {
            let _strDate = UI_Utility.convertDateToString(currentDate, type: .yyyy_MM_dd)
            let _nowDate = UI_Utility.convertStringToDate(_strDate, type: .yyyy_MM_dd)
            let _componenets = Calendar.current.dateComponents([.day], from: nowDate, to: _nowDate!)
            if let _day = _componenets.day {
                self.m_diff = _day + 1
            }
            let _sliceDate = UI_Utility.getDateToSliceDate(date: currentDate)
            self.m_date = currentDate
            self.m_month = _sliceDate.1
            self.m_day = _sliceDate.2
        }
        
        func addValue(value: Int) {
            m_total += value
        }
    }
    
    class DigitValueFormatter: NSObject, IValueFormatter {
        var m_arrDayFilterInfo: [DayFilterInfo] = []
        
        func stringForValue(_ value: Double, entry: ChartDataEntry, dataSetIndex: Int, viewPortHandler: ViewPortHandler?) -> String {
            if (Int(value) >= DeviceSensorDetailGraphForKcViewController.maxValue) {
                return getTotalValueByDiff(diff: Int(entry.x)).description
            }
            return Int(value).description
        }
        
        func getTotalValueByDiff(diff: Int) -> Int {
            for item in m_arrDayFilterInfo {
                if (item.m_diff == diff) {
                    return item.m_total
                }
            }
            return 0
        }
    }
    
    class GraphXAxisFormatter: NSObject, IAxisValueFormatter {
        var m_type: GRAPH_PAGE_TYPE!
        var m_stDate: Date!
        
        init(type: GRAPH_PAGE_TYPE, stDate: Date) {
            self.m_type = type
            self.m_stDate = stDate
        }
        
        func stringForValue(_ value: Double, axis: AxisBase?) -> String {
            //        Debug.print(value)
            if (value != 0) {
                switch m_type! {
                case .day: return ""
                case .weekly:
                    if (value > 7) {
                        return ""
                    }
                    let calendar = Calendar.current
                    if let date = calendar.date(byAdding: .day, value: Int(value) - 1, to: self.m_stDate) {
                        let _lDate = UI_Utility.UTCToLocal(date: UI_Utility.convertDateToString(date, type: .full))
                        let _dateSlice = UI_Utility.getDateToSliceDateString(date: _lDate)
                        return "\(_dateSlice.1)/\(_dateSlice.2)"
                    }
                case .monthly:
                    if (value > 31) {
                        return ""
                    }
                    if (Int(value) % 7 != 0) {
                        return ""
                    }
                    let calendar = Calendar.current
                    if let date = calendar.date(byAdding: .day, value: Int(value) - 1, to: self.m_stDate) {
                        let _lDate = UI_Utility.UTCToLocal(date: UI_Utility.convertDateToString(date, type: .full))
                        let _dateSlice = UI_Utility.getDateToSliceDateString(date: _lDate)
                        return "\(_dateSlice.1)/\(_dateSlice.2)"
                    }
                }
            }
            return ""
        }
    }

    var m_parent: DeviceSensorDetailGraphForKcViewController?
    var m_emptyView: GraphEmptyView?
    
    var m_state: DeviceSensorDetailGraphForKcViewController.GRAPH_TYPE = .diaper
    var m_nowPageInfo: PagingData!
    var m_arrDayFilterInfo: [DayFilterInfo] = []
    
    func setCtrl(state: DeviceSensorDetailGraphForKcViewController.GRAPH_TYPE) {
        self.m_state = state
//        barChartView.delegate = self

        m_nowPageInfo = PagingData(type: .weekly, idx: 1, bday: m_parent?.m_parent?.m_parent?.sensorStatusInfo?.m_bday ?? "")
        
        setUI()
    }

    func setUI() {
        setDayUI(type: self.m_nowPageInfo.m_dayType)
        lblPageTitle.text = String(format: "D + %d%@", m_nowPageInfo.m_dday, m_nowPageInfo.m_dayType == .weekly ? "sensor_graph_week".localized : "sensor_graph_month".localized)
        lblPageContents.text = String(format: "%@", m_nowPageInfo.m_dayInfo)
        
        btnPageNext.isHidden = false
        if (!m_nowPageInfo.isPageMax) {
            btnPageNext.isHidden = true
        }
        btnPagePrev.isHidden = false
        if (!m_nowPageInfo.isPageMin) {
            btnPagePrev.isHidden = true
        }

        setDateSort(type: m_state)
        setAvgValue()
        setServerAvgValue()
        setChartUI()
    }
    
    func setDayUI(type: GRAPH_PAGE_TYPE) {
        lblFilterWeekly.text = "sensor_graph_weekly".localized
        lblFilterMonthly.text = "sensor_graph_monthly".localized
        lblFilterWeekly.textColor = COLOR_TYPE.lblWhiteGray.color
        lblFilterMonthly.textColor = COLOR_TYPE.lblWhiteGray.color
        viewFilterWeeklyBar.backgroundColor = COLOR_TYPE.lblWhiteGray.color
        viewFilterMonthlyBar.backgroundColor = COLOR_TYPE.lblWhiteGray.color
        btnFilterWeekly.isEnabled = true
        btnFilterMonthly.isEnabled = true
        
        switch type {
        case .day: break
        case .weekly:
            lblFilterWeekly.textColor = COLOR_TYPE.purple.color
            viewFilterWeeklyBar.backgroundColor = COLOR_TYPE.purple.color
            btnFilterWeekly.isEnabled = false
            lblMyAvgCountTitle.text = "sensor_graph_average_week".localized
            lblServerAvgCountTitle.text = "sensor_graph_server_average_week".localized
        case .monthly:
            lblFilterMonthly.textColor = COLOR_TYPE.purple.color
            viewFilterMonthlyBar.backgroundColor = COLOR_TYPE.purple.color
            btnFilterMonthly.isEnabled = false
            lblMyAvgCountTitle.text = "sensor_graph_average_month".localized
            lblServerAvgCountTitle.text = "sensor_graph_server_average_month".localized
        }
    }
    
    func setAvgValue() {
        var _arrInfo = [Int]()
        for item in m_arrDayFilterInfo {
            _arrInfo.append(item.m_total)
        }
        if (_arrInfo.count == 0) {
            lblMyAvgCountContents.text = "-"
            return
        }
        
        var _total: Int = 0
        for item in _arrInfo {
            _total += item
        }
        
        let _value = Double(floor(10 * (Double(_total) / Double(self.m_nowPageInfo.m_dayType == .monthly ? 31 : 7))) / 10)
        
        let _attributed1 = LabelAttributed(labelValue: _value.description, attributed: [NSAttributedStringKey.font: UIFont(name: Config.FONT_NotoSans, size: 20.0)!])
        let _attributed2 = LabelAttributed(labelValue: " \("sensor_graph_count".localized)", attributed: [NSAttributedStringKey.font: UIFont(name: Config.FONT_NotoSans, size: 14.0)!, NSAttributedStringKey.foregroundColor : COLOR_TYPE.lblGray.color])
        
        UI_Utility.multiAttributedLabel(label: lblMyAvgCountContents, arrAttributed: [_attributed1, _attributed2])
    }
    
    func setServerAvgValue() {
        self.setServerAverageValue(value: "-")
        
        let send = Send_GetSensorGraphAverage()
        send.aid = DataManager.instance.m_userInfo.account_id
        send.token = DataManager.instance.m_userInfo.token
        send.dtype = m_nowPageInfo.m_dayType.rawValue
        send.didx = m_nowPageInfo.m_dday
//                send.stime = UI_Utility.convertDateToString(m_nowPageInfo.m_stDateCast, type: .yyMMdd_HHmmss)
//                send.etime = UI_Utility.convertDateToString(m_nowPageInfo.m_edDateCast, type: .yyMMdd_HHmmss)
        send.did = m_parent?.m_parent?.m_parent?.m_detailInfo?.m_did ?? -1
        send.isIndicator = false
        NetworkManager.instance.Request(send) { (json) -> () in
            let receive = Receive_GetSensorGraphAverage(json)
            switch receive.ecd {
            case .success:
                switch self.m_state {
                case .diaper: self.setServerAverageValue(value: receive.change?.description ?? "-")
                case .pee: self.setServerAverageValue(value: receive.pee?.description ?? "-")
                case .poo: self.setServerAverageValue(value: receive.poo?.description ?? "-")
                case .fart: self.setServerAverageValue(value: receive.fart?.description ?? "-")
                default: break
                }
            default:
                Debug.print("[ERROR] Send_GetSensorGraphAverage invaild errcod", event: .error)
                self.setServerAverageValue(value: "-")
            }
        }
    }
    
    func setServerAverageValue(value: String) {
        let _attributed1 = LabelAttributed(labelValue: value, attributed: [NSAttributedStringKey.font: UIFont(name: Config.FONT_NotoSans, size: 20.0)!])
        let _attributed2 = LabelAttributed(labelValue: " \("sensor_graph_count".localized)", attributed: [NSAttributedStringKey.font: UIFont(name: Config.FONT_NotoSans, size: 14.0)!, NSAttributedStringKey.foregroundColor : COLOR_TYPE.lblGray.color])
        
        UI_Utility.multiAttributedLabel(label: lblServerAvgCountContents, arrAttributed: [_attributed1, _attributed2])
    }

    func setDateSort(type: DeviceSensorDetailGraphForKcViewController.GRAPH_TYPE) {
        let _arrData = DataManager.instance.m_userInfo.deviceNoti.m_deviceNoti
        let _filterDate = _arrData.filter({ (v: DeviceNotiInfo) -> (Bool) in
            if (v.m_type == DEVICE_TYPE.Sensor.rawValue && v.m_did == m_parent?.m_parent?.m_parent?.m_detailInfo?.m_did ?? -1) {
                var _notiType = 0
                switch type {
                case .pee: _notiType = 1
                case .poo: _notiType = 2
                case .fart: _notiType = 5
                case .diaper: _notiType = 4
                default:
                    break
                }
                if (v.m_noti == _notiType) {
                    if (m_nowPageInfo.m_stDateCast <= v.m_castTimeInfo.m_lTimeCast && v.m_castTimeInfo.m_lTimeCast < m_nowPageInfo.m_edDateCast) {
                        //                        Debug.print("\(m_nowPageInfo.m_stDateCast) <= \(v.m_castTimeInfo.m_lTimeCast) < \(m_nowPageInfo.m_edDateCast)", event: .dev)
                        return true
                    }
                }
            }
            return false
        })
        
        var _arrDayFilterInfo: [DayFilterInfo] = []
        
        for item in _filterDate {
            var _isFound = false
            for itemDay in _arrDayFilterInfo {
                let _filterInfo = UI_Utility.getDateToSliceDate(date: item.m_castTimeInfo.m_lTimeCast)
                if (itemDay.m_month == _filterInfo.1 && itemDay.m_day == _filterInfo.2) {
                    itemDay.addValue(value: 1)
                    _isFound = true
                    break
                }
            }
            if (!_isFound) {
                let _info = DayFilterInfo(nowDate: m_nowPageInfo.m_stDateCast, currentDate: item.m_castTimeInfo.m_lTimeCast)
                _info.addValue(value: 1)
                _arrDayFilterInfo.append(_info)
            }
        }
        self.m_arrDayFilterInfo = _arrDayFilterInfo
    }
    
    func setChartUI() {
        //        var _arrHighlightsEntry: [Highlight] = []
        var _chartYValues: [BarChartDataEntry] = []
        var _chartYColors: [NSUIColor] = []
        var _chartYTextColors: [NSUIColor] = []
        let _chartData = BarChartData()
        
        for item in m_arrDayFilterInfo {
            _chartYValues.append(BarChartDataEntry(x: Double(item.m_diff), y: Double(item.m_total >= DeviceSensorDetailGraphForKcViewController.maxValue ? DeviceSensorDetailGraphForKcViewController.maxValue : item.m_total)))
            _chartYColors.append(COLOR_TYPE.purple.color)
            _chartYTextColors.append(COLOR_TYPE.purple.color)
        }
        
        let _ds = BarChartDataSet(values: _chartYValues, label: nil)
        //        _ds.drawCircleHoleEnabled = false
        _ds.colors = _chartYColors
        _ds.valueFont = UIFont(name: Config.FONT_NotoSans, size: 10.0)!
        _ds.valueColors = _chartYTextColors
        //        _ds.lineWidth = 2
        //        _ds.drawCirclesEnabled = false
        //        _ds.circleRadius = 1
        //        _ds.drawValuesEnabled = true
        _chartData.addDataSet(_ds)
        _chartData.setDrawValues(self.m_nowPageInfo.m_dayType == .weekly)
        let _digitValueFormatter = DigitValueFormatter()
        _digitValueFormatter.m_arrDayFilterInfo = m_arrDayFilterInfo
        _chartData.setValueFormatter(_digitValueFormatter)
        //
        barChartView.leftAxis.labelFont = UIFont(name: Config.FONT_NotoSans, size: 10.0)!
        barChartView.leftAxis.axisMinimum = 0
        barChartView.leftAxis.axisMaximum = 20
        barChartView.leftAxis.drawGridLinesEnabled = true
        barChartView.leftAxis.drawAxisLineEnabled = false
        barChartView.leftAxis.drawLabelsEnabled = true
        //        barChartView.clipValuesToContentEnabled = false
        //
        barChartView.rightAxis.drawGridLinesEnabled = false
        barChartView.rightAxis.drawLabelsEnabled = false
        //
        barChartView.xAxis.labelFont = UIFont(name: Config.FONT_NotoSans, size: 10.0)!
        barChartView.xAxis.drawGridLinesEnabled = false
        //        barChartView.xAxis.drawAxisLineEnabled = false
        barChartView.xAxis.axisRange = m_nowPageInfo.m_dayType == .weekly ? 8 : 32
        barChartView.xAxis.axisMinimum = 0
        barChartView.xAxis.axisMaximum = m_nowPageInfo.m_dayType == .weekly ? 8 : 32
        barChartView.xAxis.labelPosition = .bottom
        barChartView.xAxis.valueFormatter = GraphXAxisFormatter(type: m_nowPageInfo.m_dayType, stDate: m_nowPageInfo.m_stDateCast)
        barChartView.xAxis.labelCount = m_nowPageInfo.m_dayType == .weekly ? 8 : 32
        //        barChartView.xAxis.forceLabelsEnabled = false
        
        if (self.m_nowPageInfo.m_dayType == .monthly) {
            let marker : SensorGraphForKcBalloonMarker = SensorGraphForKcBalloonMarker(color: UIColor.clear, font: UIFont(name: Config.FONT_NotoSans, size: 11)!, textColor: COLOR_TYPE.purple.color, insets: UIEdgeInsets(top: 0, left: 7.0, bottom: 0, right: 7.0))
            marker.minimumSize = CGSize(width: CGFloat(80.0), height: CGFloat(20.0))
            marker.m_parent = self
            marker.m_arrDayFilterInfo = m_arrDayFilterInfo
            marker.font = UIFont(name: Config.FONT_NotoSans, size: 10.0)!
            barChartView.marker = marker
            barChartView.drawValueAboveBarEnabled = false
        } else {
            barChartView.marker = nil
            barChartView.drawValueAboveBarEnabled = true
        }
        
        barChartView.data = _chartData
        barChartView.chartDescription?.text = ""
        barChartView.pinchZoomEnabled = false
        barChartView.scaleXEnabled = false
        barChartView.scaleYEnabled = false
        barChartView.legend.enabled = false
        
        setEmptyGraph(isEnable: m_arrDayFilterInfo.count <= 0)
    }
    
    func setEmptyGraph(isEnable: Bool) {
        if (isEnable) {
            if (m_emptyView == nil) {
                m_emptyView = .fromNib()
                m_emptyView!.frame = barChartView.bounds
                m_emptyView!.setInfo()
                self.barChartView.addSubview(m_emptyView!)
            }
            m_emptyView?.isHidden = false
        } else {
            m_emptyView?.isHidden = true
        }
    }
    
    @IBAction func onClick_weekly(_ sender: UIButton) {
        m_nowPageInfo.setWeekly()
        setUI()
        
        switch m_state {
        case .diaper:
            ScreenAnalyticsManager.instance.googleTagManagerCustom(type: .sensor_graph_diaper_button_weekly, items: ["sensorid_\(m_parent?.m_parent?.m_parent?.m_detailInfo?.m_did ?? 0)" : UI_Utility.nowUTCDate(type: .yyMMdd_HHmmss)])
            break
        case .pee:
            ScreenAnalyticsManager.instance.googleTagManagerCustom(type: .sensor_graph_pee_button_weekly, items: ["sensorid_\(m_parent?.m_parent?.m_parent?.m_detailInfo?.m_did ?? 0)" : UI_Utility.nowUTCDate(type: .yyMMdd_HHmmss)])
            break
        case .poo:
            ScreenAnalyticsManager.instance.googleTagManagerCustom(type: .sensor_graph_poo_button_weekly, items: ["sensorid_\(m_parent?.m_parent?.m_parent?.m_detailInfo?.m_did ?? 0)" : UI_Utility.nowUTCDate(type: .yyMMdd_HHmmss)])
            break
        case .fart:
            ScreenAnalyticsManager.instance.googleTagManagerCustom(type: .sensor_graph_fart_button_weekly, items: ["sensorid_\(m_parent?.m_parent?.m_parent?.m_detailInfo?.m_did ?? 0)" : UI_Utility.nowUTCDate(type: .yyMMdd_HHmmss)])
            break
        default:
            break
        }
    }
    
    @IBAction func onClick_monthly(_ sender: UIButton) {
        m_nowPageInfo.setMonthly()
        setUI()

        switch m_state {
        case .diaper:
            ScreenAnalyticsManager.instance.googleTagManagerCustom(type: .sensor_graph_diaper_button_monthly, items: ["sensorid_\(m_parent?.m_parent?.m_parent?.m_detailInfo?.m_did ?? 0)" : UI_Utility.nowUTCDate(type: .yyMMdd_HHmmss)])
            break
        case .pee:
            ScreenAnalyticsManager.instance.googleTagManagerCustom(type: .sensor_graph_pee_button_monthly, items: ["sensorid_\(m_parent?.m_parent?.m_parent?.m_detailInfo?.m_did ?? 0)" : UI_Utility.nowUTCDate(type: .yyMMdd_HHmmss)])
            break
        case .poo:
            ScreenAnalyticsManager.instance.googleTagManagerCustom(type: .sensor_graph_poo_button_monthly, items: ["sensorid_\(m_parent?.m_parent?.m_parent?.m_detailInfo?.m_did ?? 0)" : UI_Utility.nowUTCDate(type: .yyMMdd_HHmmss)])
            break
        case .fart:
            ScreenAnalyticsManager.instance.googleTagManagerCustom(type: .sensor_graph_fart_button_monthly, items: ["sensorid_\(m_parent?.m_parent?.m_parent?.m_detailInfo?.m_did ?? 0)" : UI_Utility.nowUTCDate(type: .yyMMdd_HHmmss)])
            break
        default:
            break
        }
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
