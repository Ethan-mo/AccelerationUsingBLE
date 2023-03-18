//
//  DeviceSensorDetailNotiGraphView.swift
//  Monit
//
//  Created by john.lee on 2019. 4. 8..
//  Copyright © 2019년 맥. All rights reserved.
//

import UIKit
import Charts

class DeviceSensorDetailNotiGraphView: UIView, ChartViewDelegate {
    @IBOutlet weak var barChartView: BarChartView!
    @IBOutlet weak var stView: UIStackView!
    
    @IBOutlet weak var viewFilter: UIView!
    @IBOutlet weak var btnFilterWeekly: UIButton!
    @IBOutlet weak var btnFilterMonthly: UIButton!

    @IBOutlet weak var lblPageContents: UILabel!
    @IBOutlet weak var btnPagePrev: UIButton!
    @IBOutlet weak var btnPageNext: UIButton!

    /// weekly, monthly
    @IBOutlet weak var viewWeeklyDiaperCount: UIView!
    @IBOutlet weak var lblWeeklyDiaperCountTitle: UILabel!
    @IBOutlet weak var lblWeeklyDiaperCountValue: UILabel!
    @IBOutlet weak var lblWeeklyDiaperCountUnit: UILabel!
    
    @IBOutlet weak var viewWeeklyPeeCount: UIView!
    @IBOutlet weak var lblWeeklyPeeCountTitle: UILabel!
    @IBOutlet weak var lblWeeklyPeeCountValue: UILabel!
    @IBOutlet weak var lblWeeklyPeeCountUnit: UILabel!
    
    @IBOutlet weak var viewWeeklyPooCount: UIView!
    @IBOutlet weak var lblWeeklyPooCountTitle: UILabel!
    @IBOutlet weak var lblWeeklyPooCountValue: UILabel!
    @IBOutlet weak var lblWeeklyPooCountUnit: UILabel!
    
    /// day
    @IBOutlet weak var viewDay: UIView!
    @IBOutlet weak var lblDayTitle: UILabel!
    
    @IBOutlet weak var viewDayDiaperCount: UIView!
    @IBOutlet weak var lblDayDiapereCountTitle: UILabel!
    @IBOutlet weak var lblDayDiaperCountValue: UILabel!
    @IBOutlet weak var lblDayDiaperCountUnit: UILabel!
    
    @IBOutlet weak var viewDayPeeCount: UIView!
    @IBOutlet weak var lblDayPeeCountTitle: UILabel!
    @IBOutlet weak var lblDayPeeCountValue: UILabel!
    @IBOutlet weak var lblDayPeeCountUnit: UILabel!
    
    @IBOutlet weak var viewDayPooCount: UIView!
    @IBOutlet weak var lblDayPooCountTitle: UILabel!
    @IBOutlet weak var lblDayPooCountValue: UILabel!
    @IBOutlet weak var lblDayPooCountUnit: UILabel!
    
    @IBOutlet weak var viewDayDiaperScoreCount: UIView!
    @IBOutlet weak var lblDayDiaperScoreCountTitle: UILabel!
    @IBOutlet weak var lblDayDiaperScoreCountValue: UILabel!
    @IBOutlet weak var lblDayDiaperScoreCountUnit: UILabel!
    
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
                self.m_diff = _day
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
            if (Int(value) >= DeviceSensorDetailGraphViewController.maxValue) {
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
    
    var m_parent: DeviceSensorDetailGraphViewController?
    var m_emptyView: GraphEmptyView?

    var m_nowPageInfo: PagingData!
    var m_arrFilterData: [DeviceNotiInfo] = []
    var m_arrDayFilterInfo: [DayFilterInfo] = []
    
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

        setDateSort()
        averageInfo(type: self.m_nowPageInfo.m_dayType, data: m_arrFilterData) // setDataSort 선행
        setChartUI()
    }
    
    func setInitUI() {
        barChartView.delegate = self
        
        UI_Utility.customViewBorder(view: viewFilter, radius: 8, width: 1, color: UIColor.clear.cgColor)
        UI_Utility.customButtonBorder(button: btnFilterWeekly, radius: 8, width: 1, color: UIColor.clear.cgColor)
        UI_Utility.customButtonBorder(button: btnFilterMonthly, radius: 8, width: 1, color: UIColor.clear.cgColor)
        
        UI_Utility.customViewBorder(view: viewWeeklyDiaperCount, radius: 10, width: 1, color: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0))
        UI_Utility.customViewShadow(view: viewWeeklyDiaperCount, radius: 1, offsetWidth: 1, offsetHeight: 1, color: UIColor.gray.cgColor, opacity: 0.5)
        UI_Utility.customViewBorder(view: viewWeeklyPeeCount, radius: 10, width: 1, color: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0))
        UI_Utility.customViewShadow(view: viewWeeklyPeeCount, radius: 1, offsetWidth: 1, offsetHeight: 1, color: UIColor.gray.cgColor, opacity: 0.5)
        UI_Utility.customViewBorder(view: viewWeeklyPooCount, radius: 10, width: 1, color: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0))
        UI_Utility.customViewShadow(view: viewWeeklyPooCount, radius: 1, offsetWidth: 1, offsetHeight: 1, color: UIColor.gray.cgColor, opacity: 0.5)
        
        viewDay.isHidden = true
        UI_Utility.customViewBorder(view: viewDayDiaperCount, radius: 8, width: 1, color: UIColor.clear.cgColor)
        UI_Utility.customViewBorder(view: viewDayPeeCount, radius: 8, width: 1, color: UIColor.clear.cgColor)
        UI_Utility.customViewBorder(view: viewDayPooCount, radius: 8, width: 1, color: UIColor.clear.cgColor)
        UI_Utility.customViewBorder(view: viewDayDiaperScoreCount, radius: 8, width: 1, color: UIColor.clear.cgColor)
        
        btnFilterWeekly.setTitle("sensor_graph_week".localized, for: .normal)
        btnFilterMonthly.setTitle("sensor_graph_month".localized, for: .normal)
        
        lblDayDiapereCountTitle.text = "sensor_diaper_graph_day_total_count".localized
        lblDayPeeCountTitle.text = "sensor_diaper_graph_day_pee_count".localized
        lblDayPooCountTitle.text = "sensor_diaper_graph_day_poo_count".localized
        lblDayDiaperScoreCountTitle.text = "sensor_diaper_graph_day_soiled_count".localized
        
        lblWeeklyDiaperCountUnit.text = "sensor_graph_count".localized
        lblWeeklyPeeCountUnit.text = "sensor_graph_count".localized
        lblWeeklyPooCountUnit.text = "sensor_graph_count".localized
        
        lblDayDiaperCountUnit.text = "sensor_graph_count".localized
        lblDayPeeCountUnit.text = "sensor_graph_count".localized
        lblDayPooCountUnit.text = "sensor_graph_count".localized
        lblDayDiaperScoreCountUnit.text = "sensor_graph_count".localized
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
    
    func setDateSort() {
        let _arrData = DataManager.instance.m_userInfo.deviceNoti.m_deviceNoti
        let _filterDate = _arrData.filter({ (v: DeviceNotiInfo) -> (Bool) in
            if (v.m_type == DEVICE_TYPE.Sensor.rawValue
                && v.m_did == m_parent?.m_parent?.m_parent?.m_detailInfo?.m_did ?? -1
                && (v.m_noti == NotificationType.DIAPER_CHANGED.rawValue || v.m_noti == NotificationType.DIAPER_SCORE.rawValue)) {
                if (m_nowPageInfo.m_stDateCast <= v.m_castTimeInfo.m_lTimeCast && v.m_castTimeInfo.m_lTimeCast < m_nowPageInfo.m_edDateCast) {
                    //                        Debug.print("\(m_nowPageInfo.m_stDateCast) <= \(v.m_castTimeInfo.m_lTimeCast) < \(m_nowPageInfo.m_edDateCast)", event: .dev)
                    return true
                }
            }
            return false
        })
        self.m_arrFilterData = _filterDate
        
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
    
    func averageInfo(type: GRAPH_PAGE_TYPE, data: [DeviceNotiInfo]) {
        if (type == .weekly) {
            lblWeeklyDiaperCountTitle.text = "sensor_diaper_graph_average_total_count".localized
            lblWeeklyPeeCountTitle.text = "sensor_diaper_graph_average_pee_count".localized
            lblWeeklyPooCountTitle.text = "sensor_diaper_graph_average_poo_count".localized
        } else {
            lblWeeklyDiaperCountTitle.text = "sensor_diaper_graph_average_total_count".localized
            lblWeeklyPeeCountTitle.text = "sensor_diaper_graph_average_pee_count".localized
            lblWeeklyPooCountTitle.text = "sensor_diaper_graph_average_poo_count".localized
        }
        
        lblWeeklyDiaperCountValue.text = getAverageInfo(type: type, filterNotiType: .DIAPER_CHANGED, filterValue: nil, data: data).description
        lblWeeklyPeeCountValue.text = "\(getAverageInfo(type: type, filterNotiType: .DIAPER_CHANGED, filterValue: "2", data: data) + getAverageInfo(type: type, filterNotiType: .DIAPER_CHANGED, filterValue: "4", data: data))"
        lblWeeklyPooCountValue.text = "\(getAverageInfo(type: type, filterNotiType: .DIAPER_CHANGED, filterValue: "3", data: data) + getAverageInfo(type: type, filterNotiType: .DIAPER_CHANGED, filterValue: "4", data: data))"
    }
    
    func averageDayInfo(type: GRAPH_PAGE_TYPE, x: Double, info: DayFilterInfo, data: [DeviceNotiInfo]) {
        viewDay.isHidden = false
        stView.layoutIfNeeded()
        
        let _diffDay = diffDayValueByX(type: type, x: x)
        
        let calendar = Calendar.current
        if let date = calendar.date(byAdding: .day, value: _diffDay, to: m_nowPageInfo.m_stDateCast) {
            let _lDate = UI_Utility.convertDateToString(date, type: .full)
            let _dateSlice = UI_Utility.getDateToSliceDateString(date: _lDate)
            
            lblDayTitle.text = UI_Utility.getDateByLanguageFromString(
                UI_Utility.convertDateToString(date, type: .full), fromType: .full, language: Config.languageType)
            
            let _filterDate = data.filter({ (v: DeviceNotiInfo) -> (Bool) in
                let _lDate = UI_Utility.convertDateStringToString(v.m_castTimeInfo.m_lTime, fromType: .yyMMdd_HHmmss, toType: .full)
                let _vSlice = UI_Utility.getDateToSliceDateString(date: _lDate)
                if (_vSlice.0 == _dateSlice.0 && _vSlice.1 == _dateSlice.1 && _vSlice.2 == _dateSlice.2) {
                    return true
                }
                return false
            })
            
            // 정확한 수치 안나옴
            lblDayDiaperCountValue.text = getAverageInfo(type: type, filterNotiType: .DIAPER_CHANGED, filterValue: nil, data: _filterDate, isDay: true).description
            lblDayPeeCountValue.text = "\(getAverageInfo(type: type, filterNotiType: .DIAPER_CHANGED, filterValue: "2", data: _filterDate, isDay: true) + getAverageInfo(type: type, filterNotiType: .DIAPER_CHANGED, filterValue: "4", data: _filterDate, isDay: true))"
            lblDayPooCountValue.text = "\(getAverageInfo(type: type, filterNotiType: .DIAPER_CHANGED, filterValue: "3", data: _filterDate, isDay: true) + getAverageInfo(type: type, filterNotiType: .DIAPER_CHANGED, filterValue: "4", data: _filterDate, isDay: true))"
            lblDayDiaperScoreCountValue.text = "\(getAverageInfo(type: type, filterNotiType: .DIAPER_SCORE, filterValue: "", data: _filterDate, isDay: true))"
        }
    }
    
    func diffDayValueByX(type: GRAPH_PAGE_TYPE, x: Double) -> Int {
        return type == .weekly ? Int((x - 1) / 2) : Int(x)
    }
 
    func getAverageInfo(type: GRAPH_PAGE_TYPE, filterNotiType: NotificationType, filterValue: String?, data: [DeviceNotiInfo], isDay: Bool = false) -> Int {
        var count = 0
        for item in data {
            if (item.m_noti == NotificationType.DIAPER_SCORE.rawValue) {
                count += 1
            } else {
                if let _filterValue = filterValue {
                    if (item.m_noti == filterNotiType.rawValue && item.Extra == _filterValue) {
                        count += 1
                    }
                } else {
                    if (item.m_noti == filterNotiType.rawValue) {
                        count += 1
                    }
                }
            }
        }
        if (!isDay) {
            var _arrCount: [String] = []
            for item in data {
                if (!_arrCount.contains(item.m_castTimeInfo.m_lDate)) {
                    _arrCount.append(item.m_castTimeInfo.m_lDate)
                }
            }
            if (count > 0) {
                if (type == .weekly) {
                    count = count / _arrCount.count
                } else {
                    count = count / _arrCount.count
                }
            }
        }
        
        return count
    }
    
    func setChartUI() {
        // 칸 사이사이에 라인을 표시하기 위해 가로표시범위 * 2를 한다.
        let _isWeeklyType = m_nowPageInfo.m_dayType == .weekly

        var _chartYValues: [BarChartDataEntry] = []
        var _chartYColors: [NSUIColor] = []
        var _chartYTextColors: [NSUIColor] = []

        for item in m_arrDayFilterInfo {
            _chartYValues.append(BarChartDataEntry(x: Double(_isWeeklyType ? (item.m_diff * 2 + 1) : item.m_diff), y: Double(item.m_total >= DeviceSensorDetailGraphViewController.maxValue ? DeviceSensorDetailGraphViewController.maxValue : item.m_total)))
            _chartYColors.append(COLOR_TYPE._brown_174_140_107.color)
            _chartYTextColors.append(COLOR_TYPE._brown_174_140_107.color)
        }
        
        let _ds = BarChartDataSet(values: _chartYValues, label: nil)
        _ds.colors = _chartYColors
        _ds.valueFont = UIFont(name: Config.FONT_NotoSans, size: 10.0)!
        _ds.valueColors = _chartYTextColors
        
        let _chartData = BarChartData()
        _chartData.addDataSet(_ds)
        _chartData.setDrawValues(_isWeeklyType)
        
        // 세로축(왼쪽) 라벨 및 수치
        barChartView.leftAxis.axisMinimum = 0
        barChartView.leftAxis.axisMaximum = 20
        barChartView.leftAxis.drawGridLinesEnabled = true
        barChartView.leftAxis.drawAxisLineEnabled = false
        barChartView.leftAxis.drawLabelsEnabled = true
        barChartView.leftAxis.labelFont = UIFont(name: Config.FONT_NotoSans, size: 10.0)!

        // 세로축(오른쪽) 라벨 및 수치
        barChartView.rightAxis.drawGridLinesEnabled = false
        barChartView.rightAxis.drawLabelsEnabled = false
        
        // 하단 라벨 및 수치
        barChartView.xAxis.axisRange = _isWeeklyType ? 7 * 2 : 32
        barChartView.xAxis.axisMinimum = 0
        barChartView.xAxis.axisMaximum = _isWeeklyType ? 7 * 2 : 32
        barChartView.xAxis.drawGridLinesEnabled = true
        barChartView.xAxis.drawAxisLineEnabled = false
        barChartView.xAxis.gridColor = COLOR_TYPE.lblWhiteGray.color
        barChartView.xAxis.labelPosition = .bottom
        barChartView.xAxis.valueFormatter = GraphXAxisFormatter(type: m_nowPageInfo.m_dayType, stDate: m_nowPageInfo.m_stDateCast)
        barChartView.xAxis.labelCount = _isWeeklyType ? 7 * 2 : 32
        barChartView.xAxis.forceLabelsEnabled = false // 하단 라벨, 뒤에 선 고정
        barChartView.xAxis.granularity = _isWeeklyType ? 2 : 4  // 세로선 몇번째마다 표시할지 (라벨에 영향을 준다.)
        barChartView.xAxis.centerAxisLabelsEnabled = _isWeeklyType ? true : false // 라벨 가운대 정렬
        barChartView.xAxis.labelFont = UIFont(name: Config.FONT_NotoSans, size: 10.0)!
        
        if (self.m_nowPageInfo.m_dayType == .monthly) {
            let marker: SensorNotiGraphBalloonMarker = SensorNotiGraphBalloonMarker(color: UIColor.clear, font: UIFont(name: Config.FONT_NotoSans, size: 11)!, textColor: COLOR_TYPE.purple.color, insets: UIEdgeInsets(top: 0, left: 7.0, bottom: 0, right: 7.0))
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
        
        let _digitValueFormatter = DigitValueFormatter()
        _digitValueFormatter.m_arrDayFilterInfo = m_arrDayFilterInfo
        _chartData.setValueFormatter(_digitValueFormatter)
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
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        Debug.print("[SENSOR_MOV_GRAPH] chartValueSelected \(entry.y)", event: .dev)
        for item in m_arrDayFilterInfo {
            let _isWeeklyType = m_nowPageInfo.m_dayType == .weekly
            if (Double(_isWeeklyType ? item.m_diff * 2 + 1 : item.m_diff) == entry.x) {
                averageDayInfo(type: self.m_nowPageInfo.m_dayType, x: entry.x, info: item, data: m_arrFilterData)
                return
            }
        }
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
