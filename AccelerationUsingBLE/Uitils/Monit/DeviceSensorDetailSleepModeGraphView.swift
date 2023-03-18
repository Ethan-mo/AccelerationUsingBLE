//
//  DeviceSensorDetailNotiGraphView.swift
//  Monit
//
//  Created by john.lee on 2019. 4. 8..
//  Copyright © 2019년 맥. All rights reserved.
//

import UIKit
import Charts

class DeviceSensorDetailSleepModeGraphView: UIView, ChartViewDelegate {
    @IBOutlet weak var chartView: LineChartView!
    @IBOutlet weak var stView: UIStackView!
    
    @IBOutlet weak var viewFilter: UIView!
    @IBOutlet weak var btnFilterWeekly: UIButton!
    @IBOutlet weak var btnFilterMonthly: UIButton!

    @IBOutlet weak var lblPageContents: UILabel!
    @IBOutlet weak var btnPagePrev: UIButton!
    @IBOutlet weak var btnPageNext: UIButton!

    /// weekly, monthly
    @IBOutlet weak var viewWeeklyTotal: UIView!
    @IBOutlet weak var lblWeeklyTotalTitle: UILabel!
    @IBOutlet weak var lblWeeklyTotalValue: UILabel!
    
    @IBOutlet weak var viewWeeklyMoveCount: UIView?
    @IBOutlet weak var lblWeeklyMoveCountTitle: UILabel?
    @IBOutlet weak var lblWeeklyMoveCountValue: UILabel?
    @IBOutlet weak var lblWeeklyMoveCountUnit: UILabel!
    
    /// day
    @IBOutlet weak var viewDay: UIView!
    @IBOutlet weak var lblDayTitle: UILabel!
    
    @IBOutlet weak var viewDayTotal: UIView!
    @IBOutlet weak var lblDayTotalTitle: UILabel!
    @IBOutlet weak var lblDayTotalValue: UILabel!
    
    @IBOutlet weak var viewDayMoveCount: UIView?
    @IBOutlet weak var lblDayMoveCountTitle: UILabel?
    @IBOutlet weak var lblDayMoveCountValue: UILabel?
    @IBOutlet weak var lblDayMoveCountUnit: UILabel!
    
    enum SLEEP_TYPE: Int {
        case no_movement = 1
        case normal_sleep = 2
        case deep_sleep = 3
        case moving = 4
    }
    
    class MovInfo {
        var m_movAvg: Double = 0
        var m_movCnt: Int = 0
        var m_timeStamp: Int = 0 // 날짜 타임스탬프
        var m_isHorizontal: Bool = false
        var m_sleepType: SLEEP_TYPE = .moving
        
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
            
            //                Debug.print("st:\(nowDate), cast:\(_castlDate), diff:\(m_diff), mov:\(mov), isHorizontal:\(isHorizontal)")
        }
    }
    
    class SleepModeInfo {
        var m_diff: Int = -1
        var m_date: Date!
        var m_month: Int = 0
        var m_day: Int = 0
        var m_sec: Int = 0
        var m_castTimeInfo: CastDateFormatDeviceNoti!
        
        init (castDate: CastDateFormatDeviceNoti!, nowDate: Date) {
            self.m_castTimeInfo = castDate
            if let _castDate = castDate {
                let _componenets = Calendar.current.dateComponents([.day], from: nowDate, to: _castDate.m_lDateCast!)
                if let _day = _componenets.day {
                    self.m_diff = _day
                }
                let _sliceDate = UI_Utility.getDateToSliceDate(date: _castDate.m_lTimeCast)
                self.m_date = _castDate.m_lTimeCast
                self.m_month = _sliceDate.1
                self.m_day = _sliceDate.2
                self.m_sec = _sliceDate.3 * 3600 + _sliceDate.4 * 60 + _sliceDate.5
            }
        }
    }
    
    class SleepModeFilterInfo {
        var st_info: SleepModeInfo!
        var ed_info: SleepModeInfo!
        
        init (notiInfo: DeviceNotiInfo, nowDate: Date) {
            st_info = SleepModeInfo(castDate: notiInfo.m_castTimeInfo, nowDate: nowDate)
            ed_info = SleepModeInfo(castDate: notiInfo.m_castExtraTimeInfo, nowDate: nowDate)
        }
    }
    
    class GraphYAxisFormatter: NSObject, IAxisValueFormatter {
        func stringForValue(_ value: Double, axis: AxisBase?) -> String {
            var _value = Int(value)
            _value = (86400 - _value) / 3600
            return _value.description
        }
    }
    
    class SleepType {
        static let NORMAL_SLEEP_THRESHOLD = 180
        static let DEEP_SLEEP_THRESHOLD = 300
        
        static func setDeelSleep(arrInfo: [MovInfo]) {
            // 사용안함(15), 연결끊김(-1)은 제외하고, 0~12 사이에 있는 움직임으로 판단
            let _arrInfo = arrInfo.filter({ (v: MovInfo) -> (Bool) in
                if (0 <= v.m_movAvg && v.m_movAvg <= 2) {
                   return true
                }
                return false
            })
            setSleep(arrInfo: _arrInfo, sleepType: .normal_sleep, thresholdCount: NORMAL_SLEEP_THRESHOLD)
            setSleep(arrInfo: _arrInfo, sleepType: .deep_sleep, thresholdCount: DEEP_SLEEP_THRESHOLD)
        }
        
        private static func setSleep(arrInfo: [MovInfo], sleepType: SLEEP_TYPE, thresholdCount: Int) {
            var _stCount = 0
            var _sleepCount = 0
            var _beforeStCount = -1
            
            func countInit(stCount: Int) {
                _stCount = stCount
                _sleepCount = 0
            }

            for (i, item) in arrInfo.enumerated() {
                if (i == 0) { // 첫번째
                    countInit(stCount: i)
                    _ = addSleepCount(info: item, sleepType: sleepType, count: &_sleepCount)
                } else {
                    let _diffSecond = item.m_timeStamp - arrInfo[i - 1].m_timeStamp
                    if (10 <= _diffSecond && _diffSecond <= 20) { // 연결되어 있음
                        if (!addSleepCount(info: item, sleepType: sleepType, count: &_sleepCount)) {
                            countInit(stCount: i) // 범위내 값이 없으면 첫번째로 셋팅
                        }
                    } else { // 연결되어 있지 않으면 해당 값을 첫번째로 셋팅
                        countInit(stCount: i)
                        _ = addSleepCount(info: item, sleepType: sleepType, count: &_sleepCount)
                    }
                }

                if (thresholdCount <= _sleepCount) {
                    // 값이 다음과 같이 들어옴 (stRange : 0, SleepCount 180) (stRange : 0, SleepCount 181) (stRange : 0, SleepCount 182)
                    // (stRange : 730, SleepCount 180) (stRange : 730, SleepCount 181)
                    // stCount값을 저장해서 전체를 매번 바꾸지 않도록 한다.
                    //Debug.print("range:\(_stCount), endRagne:\(_sleepCount)")
                    if (_beforeStCount != _stCount) {
                        _beforeStCount = _stCount
                        setChangeSleepType(arrInfo: arrInfo, type: sleepType, stRange: _stCount, sleepRange: _stCount + _sleepCount - 1)
                    } else {
                        setChangeSleepType(arrInfo: arrInfo, type: sleepType, stRange: _stCount + _sleepCount - 1, sleepRange: _stCount + _sleepCount - 1)
                    }
                }
//                Debug.print("itemInfo - sleepType:\(sleepType.rawValue), i:\(i), mov:\(item.m_movAvg), _stCount: \(_stCount), _sleepCount: \(_sleepCount), m_timeStamp: \(item.m_timeStamp), date:\(item.m_date)")
            }
            
//            for item in arrInfo {
//                Debug.print("changeInfo - mov:\(item.m_movAvg), sleepType:\(item.m_sleepType), m_timeStamp: \(item.m_timeStamp)")
//            }
        }
        
        // 카운트 증가
        private static func addSleepCount(info: MovInfo, sleepType: SLEEP_TYPE, count: inout Int) -> Bool {
            if (sleepType == .normal_sleep) {
                if (0 <= Int(info.m_movAvg) && Int(info.m_movAvg) <= 2) {
                    count += 1
                    return true
                }
            } else if (sleepType == .deep_sleep) {
                if (0 <= Int(info.m_movAvg) && Int(info.m_movAvg) <= 1) {
                    count += 1
                    return true
                }
            }
            return false
        }
        
        // 수면 모드 타입 변경
        private static func setChangeSleepType(arrInfo: [MovInfo], type: SLEEP_TYPE, stRange: Int, sleepRange: Int) {
            let _arr = arrInfo[stRange...sleepRange]
            //Debug.print("range:\(stRange), endRagne:\(sleepRange)")
            for item in _arr {
                item.m_sleepType = type
            }
            
//            for (i, item) in arrInfo.enumerated() {
//                 if (stRange <= i && i <= stRange + sleepCount) {
//                     item.m_sleepType = type
//                 }
//             }
        }
    }
    
    var m_parent: DeviceSensorDetailGraphViewController?
    var m_emptyView: GraphEmptyView?

    var m_nowPageInfo: PagingData!
    var m_arrFilterInfo: [SleepModeFilterInfo] = []
    var m_arrMovInfo: [MovInfo] = []
    
    var m_packetLastUpdateTime: Date? // reload될때 시간을 체크하여 가져온다. (다른 noti와 다름.)
    
    var isAutoMoveEnabled: Bool {
        get {
            if let _detailInfo = m_parent!.m_parent!.m_parent!.m_detailInfo {
                if (DataManager.instance.m_userInfo.shareDevice.isAlarmStatusSpecific(did: _detailInfo.m_did, type: DEVICE_TYPE.Sensor.rawValue, almType: .auto_move_detected) ?? false) {
                    return true
                }
            }
            
            return false
        }
    }

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
        averageInfo(type: self.m_nowPageInfo.m_dayType, data: m_arrFilterInfo, autoData: m_arrMovInfo) // setDataSort 선행
        //setChartUI()
        reloadData()
    }
    
    func setInitUI() {
        chartView.delegate = self
        
        UI_Utility.customViewBorder(view: viewFilter, radius: 8, width: 1, color: UIColor.clear.cgColor)
        UI_Utility.customButtonBorder(button: btnFilterWeekly, radius: 8, width: 1, color: UIColor.clear.cgColor)
        UI_Utility.customButtonBorder(button: btnFilterMonthly, radius: 8, width: 1, color: UIColor.clear.cgColor)
        
        UI_Utility.customViewBorder(view: viewWeeklyTotal, radius: 10, width: 1, color: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0))
        UI_Utility.customViewShadow(view: viewWeeklyTotal, radius: 1, offsetWidth: 1, offsetHeight: 1, color: UIColor.gray.cgColor, opacity: 0.5)
        UI_Utility.customViewBorder(view: viewWeeklyMoveCount!, radius: 10, width: 1, color: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0))
        UI_Utility.customViewShadow(view: viewWeeklyMoveCount!, radius: 1, offsetWidth: 1, offsetHeight: 1, color: UIColor.gray.cgColor, opacity: 0.5)
        
        viewDay.isHidden = true
        UI_Utility.customViewBorder(view: viewDayTotal, radius: 8, width: 1, color: UIColor.clear.cgColor)
        UI_Utility.customViewBorder(view: viewDayMoveCount!, radius: 8, width: 1, color: UIColor.clear.cgColor)
        
        btnFilterWeekly.setTitle("sensor_graph_week".localized, for: .normal)
        btnFilterMonthly.setTitle("sensor_graph_month".localized, for: .normal)
        
        lblDayTotalTitle.text = "sensor_sleep_graph_day_total_time".localized
        lblDayMoveCountTitle?.text = "sensor_sleep_graph_day_movement_count".localized
        
        lblWeeklyMoveCountUnit.text = "sensor_graph_count".localized
        lblDayMoveCountUnit.text = "sensor_graph_count".localized
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
        setDateSortSleepInfo()
        if (isAutoMoveEnabled) {
            setDateSortAutoMovInfo()
        } else {
            setDateSortMovInfo()
        }
    }
    
    func setDateSortSleepInfo() {
        let _arrData = DataManager.instance.m_userInfo.deviceNoti.m_deviceNoti
        let _filterDate = _arrData.filter({ (v: DeviceNotiInfo) -> (Bool) in
            if (v.m_type == DEVICE_TYPE.Sensor.rawValue && v.m_did == m_parent?.m_parent?.m_parent?.m_detailInfo?.m_did ?? -1) {
                if (v.m_noti == NotificationType.SLEEP_MODE.rawValue && v.m_castExtraTimeInfo != nil) { // extra에 날짜가 있는 것만 필터한다.
                    if (m_nowPageInfo.m_stDateCast <= v.m_castTimeInfo.m_lTimeCast && v.m_castTimeInfo.m_lTimeCast < m_nowPageInfo.m_edDateCast) {
//                        Debug.print("\(m_nowPageInfo.m_stDateCast) <= \(v.m_castTimeInfo.m_lTimeCast) < \(m_nowPageInfo.m_edDateCast)", event: .dev)
                        return true
                    }
                }
            }
            return false
        })
        
        var _arrDayFilterInfo: [SleepModeFilterInfo] = []
        for item in _filterDate {
            let _info = SleepModeFilterInfo(notiInfo: item, nowDate: m_nowPageInfo.m_stDateCast)
            _arrDayFilterInfo.append(_info)
        }
        self.m_arrFilterInfo = _arrDayFilterInfo
    }
    
    func setDateSortMovInfo() {
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
//                        Debug.print("movDescryptMov: \(item.m_castTimeInfo.m_lTimeCast), descrypt: \(item.m_descryptMov)")
                        for (i, itemMov) in item.m_descryptMov.enumerated() {
                            let _timeStamp = _orginTimestamp + 10 * i
                            let _mov = Int(String(itemMov), radix: 16) ?? 0
                            if (0 <= _mov && _mov <= 12) {
                                //                                        let _xAxisValue = Double((_orginTimestamp + 10 * i) - _todayStTimestamp) // / 60.0
                                _arrMovInfo.append(
                                    MovInfo(mov: _mov,
                                            isHorizontal: false,
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
        
        var _arrSleepFilterMovInfo: [MovInfo] = []
        for item in _arrMovInfo {
            for sleepItem in m_arrFilterInfo {
                if (sleepItem.st_info.m_castTimeInfo.m_lTimeCast.millisecondsSince1970 <= item.m_timeStamp && item.m_timeStamp <= sleepItem.ed_info.m_castTimeInfo.m_lTimeCast.millisecondsSince1970) { // 상세한 시간 구간을 확인한다.
                    _arrSleepFilterMovInfo.append(item)
                }
            }
        }
      
        _arrSleepFilterMovInfo.sort { (object1, object2) -> Bool in
            return object1.m_timeStamp < object2.m_timeStamp
        }
        
        SleepType.setDeelSleep(arrInfo: _arrSleepFilterMovInfo) // deepSleep 알고리즘
        self.m_arrMovInfo = _arrSleepFilterMovInfo
    }
    
    func setDateSortAutoMovInfo() {
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
//                        Debug.print("movDescryptMov: \(item.m_castTimeInfo.m_lTimeCast), descrypt: \(item.m_descryptMov)")
                        for (i, itemMov) in item.m_descryptMov.enumerated() {
                            let _timeStamp = _orginTimestamp + 10 * i
                            let _mov = Int(String(itemMov), radix: 16) ?? 0
                            if (0 <= _mov && _mov <= 12) {
                                //                                        let _xAxisValue = Double((_orginTimestamp + 10 * i) - _todayStTimestamp) // / 60.0
                                _arrMovInfo.append(
                                    MovInfo(mov: _mov,
                                            isHorizontal: false,
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
        
        _arrMovInfo.sort { (object1, object2) -> Bool in
            return object1.m_timeStamp < object2.m_timeStamp
        }
        
        SleepType.setDeelSleep(arrInfo: _arrMovInfo) // deepSleep 알고리즘
        self.m_arrMovInfo = _arrMovInfo
    }
    
    func averageInfo(type: GRAPH_PAGE_TYPE, data: [SleepModeFilterInfo], autoData: [MovInfo]) {
        if (type == .weekly) {
            lblWeeklyTotalTitle.text = "sensor_sleep_graph_average_total_time".localized
            lblWeeklyMoveCountTitle?.text = "sensor_sleep_graph_average_movement_count".localized
        } else {
            lblWeeklyTotalTitle.text = "sensor_sleep_graph_average_total_time".localized
            lblWeeklyMoveCountTitle?.text = "sensor_sleep_graph_average_movement_count".localized
        }
        
        var _totalValue = ""
        let _minute = getAverageSleepTimeInfo(type: type, data: data, autoData: autoData)
        if (_minute > 59) {
            _totalValue = "\(_minute / 60)\("time_hour_short".localized) \(_minute % 60)\("time_minute_short".localized)"
        } else {
            _totalValue = "\(_minute)\("time_minute_short".localized)"
        }
        lblWeeklyTotalValue.text = _totalValue
        lblWeeklyMoveCountValue?.text = "\(getAverageMoveDetectedCount(type: type))"
    }
    
    func averageDayInfo(type: GRAPH_PAGE_TYPE, x: Double) {
        viewDay.isHidden = false
        stView.layoutIfNeeded()
        
        let _diffDay = diffDayValueByX(type: type, x: x)
        
        let calendar = Calendar.current
        if let date = calendar.date(byAdding: .day, value: _diffDay, to: m_nowPageInfo.m_stDateCast) {
//            let _lDate = UI_Utility.convertDateToString(date, type: .full)
//            let _dateSlice = UI_Utility.getDateToSliceDateString(date: _lDate)
            lblDayTitle.text = UI_Utility.getDateByLanguageFromString(
            UI_Utility.convertDateToString(date, type: .full), fromType: .full, language: Config.languageType)
        }
        
        var _second: Int = 0
        if (isAutoMoveEnabled) {
            let _filterDateDeepSleep = m_arrMovInfo.filter({ v -> (Bool) in
                if (v.m_sleepType == .deep_sleep) {
                    return true
                }
                return false
            })

            for (item) in _filterDateDeepSleep {
                let _isWeeklyType = m_nowPageInfo.m_dayType == .weekly
                let _x = _isWeeklyType ? item.m_diff * 2 + 1 : item.m_diff
                if (x == Double(_x)) {
                    _second += 10
                }
            }
        } else {
            for item in m_arrFilterInfo {
                if (item.st_info.m_diff < item.ed_info.m_diff) { // 하루를 넘어감
                    for i in item.st_info.m_diff...item.ed_info.m_diff {
                        if (i == item.st_info.m_diff && i == _diffDay) { // 시작
                            _second += 86400 - item.st_info.m_sec
                        } else if (i == item.ed_info.m_diff && i == _diffDay) { // 종료
                            _second += item.ed_info.m_sec
                        } else if (i == _diffDay) {
                            _second += 86400
                        }
                    }
                } else { // 하루 안에 있는 경우
                    _second += item.ed_info.m_sec - item.st_info.m_sec
                }
            }
        }
        
        var _totalValue = ""
        let _minute = _second / 60
        if (_minute > 59) {
            _totalValue = "\(_minute / 60)\("time_hour_short".localized) \(_minute % 60)\("time_minute_short".localized)"
        } else {
            _totalValue = "\(_minute)\("time_minute_short".localized)"
        }
        lblDayTotalValue.text = _totalValue
        
        if let date = calendar.date(byAdding: .day, value: _diffDay, to: m_nowPageInfo.m_stDateCast) {
            let _lDate = UI_Utility.convertDateToString(date, type: .yyyy_MM_dd)
            lblDayMoveCountValue?.text = "\(getAverageMoveDetectedDayCount(date: _lDate))"
        }
    }
    
    func diffDayValueByX(type: GRAPH_PAGE_TYPE, x: Double) -> Int {
        return type == .weekly ? Int((x - 1) / 2) : Int(x)
    }
    
    func getAverageSleepTimeInfo(type: GRAPH_PAGE_TYPE, data: [SleepModeFilterInfo], autoData: [MovInfo]) -> Int {
        var _minute = 0
        if (isAutoMoveEnabled) {
            let _filterDateDeepSleep = m_arrMovInfo.filter({ v -> (Bool) in
                if (v.m_sleepType == .deep_sleep) {
                    return true
                }
                return false
            })
            
            _minute = _filterDateDeepSleep.count * 10 / 60
        } else {
            for item in data {
                let _diff = Calendar.current.dateComponents([.minute], from: item.st_info.m_castTimeInfo.m_lTimeCast, to: item.ed_info.m_castTimeInfo.m_lTimeCast)
                _minute += _diff.minute ?? 0
            }
        }
        

        if (type == .weekly) {
            _minute = _minute / 7
        } else {
            _minute = _minute / 30
        }

        return _minute
    }
    
    func getAverageMoveDetectedCount(type: GRAPH_PAGE_TYPE) -> Int {
        let _arrData = DataManager.instance.m_userInfo.deviceNoti.m_deviceNoti
        let _filterDate = _arrData.filter({ (v: DeviceNotiInfo) -> (Bool) in
            if (v.m_type == DEVICE_TYPE.Sensor.rawValue
                && v.m_did == m_parent?.m_parent?.m_parent?.m_detailInfo?.m_did ?? -1
                && (v.m_noti == NotificationType.MOVE_DETECTED.rawValue)) {
                if (m_nowPageInfo.m_stDateCast <= v.m_castTimeInfo.m_lTimeCast && v.m_castTimeInfo.m_lTimeCast < m_nowPageInfo.m_edDateCast) {
                    //                        Debug.print("\(m_nowPageInfo.m_stDateCast) <= \(v.m_castTimeInfo.m_lTimeCast) < \(m_nowPageInfo.m_edDateCast)", event: .dev)
                    return true
                }
            }
            return false
        })
        return _filterDate.count
    }
    
    func getAverageMoveDetectedDayCount(date: String) -> Int {
        let _arrData = DataManager.instance.m_userInfo.deviceNoti.m_deviceNoti
        let _filterDate = _arrData.filter({ (v: DeviceNotiInfo) -> (Bool) in
            if (v.m_type == DEVICE_TYPE.Sensor.rawValue
                && v.m_did == m_parent?.m_parent?.m_parent?.m_detailInfo?.m_did ?? -1
                && (v.m_noti == NotificationType.MOVE_DETECTED.rawValue)) {
                if (v.m_castTimeInfo.m_lDate == date) {
                    //                        Debug.print("\(m_nowPageInfo.m_stDateCast) <= \(v.m_castTimeInfo.m_lTimeCast) < \(m_nowPageInfo.m_edDateCast)", event: .dev)
                    return true
                }
            }
            return false
        })
        return _filterDate.count
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
        // 칸 사이사이에 라인을 표시하기 위해 가로표시범위 * 2를 한다.
        let _isWeeklyType = m_nowPageInfo.m_dayType == .weekly
        
        var _chartYValues: [ChartDataEntry] = []
        var _chartYColors: [NSUIColor] = []

        var _stX: Double = 0
        var _edX: Double = 0
        var _stY: Double = 0
        var _edY: Double = 0
        if (isAutoMoveEnabled) {
            let _filterDateDeepSleep = m_arrMovInfo.filter({ v -> (Bool) in
                if (v.m_sleepType == .deep_sleep) {
                    return true
                }
                return false
            })
            
            //Debug.print("print init - m_arrMovInfo:\(_filterDateDeepSleep.count)")
            for (i, item) in _filterDateDeepSleep.enumerated() {
                let _x = Double(_isWeeklyType ? item.m_diff * 2 + 1 : item.m_diff)
                let _y = Double(86400 - item.m_sec)

                if (i == 0) {
                    _stX = _x
                    _stY = _y
                    _edX = _x
                    _edY = _y + 10
                    //Debug.print("print st - x:\(_stX), y:\(_stY) | x:\(_edX), y:\(_edY)")
                } else {
                    let _diffSecond = item.m_timeStamp - m_arrMovInfo[i - 1].m_timeStamp
                    // 연결되어 있음 & 날짜가 같음 && 마지막이 아님 (마지막은 출력해야함)
                    if (10 <= _diffSecond && _diffSecond <= 20
                            && _stX == _x
                            && i < _filterDateDeepSleep.count - 1) {
                        _edX = _x
                        _edY = _y
                        //Debug.print("time stamp - x:\(item.m_timeStamp), y:\(m_arrMovInfo[i - 1].m_timeStamp) | i:\(i)")
                    } else { // 연결되어 있지 않으면 해당 값을 첫번째로 셋팅
                        //Debug.print("print ed - x:\(_stX), y:\(_stY) | x:\(_edX), y:\(_edY)")
                        
                        _chartYValues.append(ChartDataEntry(x: _stX, y: _stY))
                        _chartYValues.append(ChartDataEntry(x: _edX, y: _edY))
                        _chartYColors.append(COLOR_TYPE._blue_71_88_144.color)
//                            _chartYColors.append(COLOR_TYPE.red.color)
                        _chartYColors.append(UIColor.clear)
                        
                        _stX = _x
                        _stY = _y
                        _edX = _x
                        _edY = _y + 10
                        //Debug.print("print st - x:\(_stX), y:\(_stY) | x:\(_edX), y:\(_edY)")
                    }
//                                _chartYValues.append(ChartDataEntry(x: Double(_x), y: Double(86400 - item.m_sec)))
//                                _chartYValues.append(ChartDataEntry(x: Double(_x), y: Double(86400 - item.m_sec + 10)))
//                                _chartYColors.append(COLOR_TYPE._blue_71_88_144.color)
//    //                            _chartYColors.append(COLOR_TYPE.red.color)
//                                _chartYColors.append(UIColor.clear)
                }
            }
        } else {
            for item in m_arrFilterInfo {
                if (item.st_info.m_diff < item.ed_info.m_diff) { // 하루를 넘어감
                    for i in item.st_info.m_diff...item.ed_info.m_diff {
                        let _x = _isWeeklyType ? (i * 2 + 1) : i
                        if (i == item.st_info.m_diff) { // 시작
                            _chartYValues.append(ChartDataEntry(x: Double(_x), y: Double(86400 - item.st_info.m_sec)))
                            _chartYValues.append(ChartDataEntry(x: Double(_x), y: Double(86400 - 86400)))
                        } else if (i == item.ed_info.m_diff) { // 종료
                            _chartYValues.append(ChartDataEntry(x: Double(_x), y: Double(86400 - 0)))
                            _chartYValues.append(ChartDataEntry(x: Double(_x), y: Double(86400 - item.ed_info.m_sec)))
                        } else {
                            _chartYValues.append(ChartDataEntry(x: Double(_x), y: Double(86400 - 0)))
                            _chartYValues.append(ChartDataEntry(x: Double(_x), y: Double(86400 - 86400)))
                        }
                        _chartYColors.append(COLOR_TYPE._blue_71_88_144.color)
                        _chartYColors.append(UIColor.clear)
                    }
                } else { // 하루 안에 있는 경우
                    let _x = _isWeeklyType ? item.st_info.m_diff * 2 + 1 : item.st_info.m_diff
                    _chartYValues.append(ChartDataEntry(x: Double(_x), y: Double(86400 - item.st_info.m_sec)))
                    _chartYValues.append(ChartDataEntry(x: Double(_x), y: Double(86400 - item.ed_info.m_sec)))
                    _chartYColors.append(COLOR_TYPE._blue_71_88_144.color)
                    _chartYColors.append(UIColor.clear)
                }
            }
            
            let _filterDateNotDeepSleep = m_arrMovInfo.filter({ v -> (Bool) in
                if (v.m_sleepType != .deep_sleep) {
                    return true
                }
                return false
            })

            for item in _filterDateNotDeepSleep {
                let _x = _isWeeklyType ? item.m_diff * 2 + 1 : item.m_diff
                            _chartYValues.append(ChartDataEntry(x: Double(_x), y: Double(86400 - item.m_sec)))
                            _chartYValues.append(ChartDataEntry(x: Double(_x), y: Double(86400 - item.m_sec + 10)))
                            _chartYColors.append(COLOR_TYPE.lblWhiteGray.color)
    //                            _chartYColors.append(COLOR_TYPE.red.color)
                            _chartYColors.append(UIColor.clear)
            }
            
        }
        
        let _ds = LineChartDataSet(values: _chartYValues, label: nil)
        _ds.drawCircleHoleEnabled = false
        _ds.colors = _chartYColors
        _ds.lineWidth = _isWeeklyType ? 25 : 5
        _ds.drawCirclesEnabled = false
        _ds.circleRadius = 10
        _ds.drawValuesEnabled = false
        
        let _chartData = LineChartData()
        _chartData.addDataSet(_ds)
        
        // 세로축(왼쪽) 라벨 및 수치
        chartView.leftAxis.axisMinimum = 0
        chartView.leftAxis.axisMaximum = 86400
        chartView.leftAxis.drawGridLinesEnabled = true
        chartView.leftAxis.drawLabelsEnabled = true
        chartView.leftAxis.valueFormatter = GraphYAxisFormatter()
        chartView.leftAxis.granularity = 12342 // 세로선 몇번째마다 표시할지
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
        chartView.clipValuesToContentEnabled = true
        chartView.chartDescription?.text = ""
        chartView.pinchZoomEnabled = false
        chartView.scaleXEnabled = false // 가로축 스케일 조정
        chartView.scaleYEnabled = false
        chartView.legend.enabled = false // 표 이름표
        chartView.doubleTapToZoomEnabled = false // 더블탭 스케일
        
        if (isAutoMoveEnabled) {
            let _filterDateDeepSleep = m_arrMovInfo.filter({ v -> (Bool) in
                if (v.m_sleepType == .deep_sleep) {
                    return true
                }
                return false
            })

            setEmptyGraph(isEnable: _filterDateDeepSleep.count <= 0)
        } else {
            setEmptyGraph(isEnable: m_arrFilterInfo.count <= 0)
        }
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
        Debug.print("[SENSOR_SLEEP_MODE_GRAPH] chartValueSelected x:\(entry.x), y:\(entry.y)", event: .dev)
        averageDayInfo(type: m_nowPageInfo.m_dayType, x: entry.x)
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
