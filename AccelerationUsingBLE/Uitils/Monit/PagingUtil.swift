//
//  PagingData.swift
//  Monit
//
//  Created by john.lee on 2020/06/03.
//  Copyright © 2020 맥. All rights reserved.
//

import Foundation
import Charts

enum GRAPH_PAGE_TYPE: Int {
    case day
    case weekly
    case monthly
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
        if (value >= 0) {
            let _value = m_type == .weekly ? value / 2 : value
            let calendar = Calendar.current
            if let date = calendar.date(byAdding: .day, value: Int(_value), to: self.m_stDate) {
                let _lDate = UI_Utility.UTCToLocal(date: UI_Utility.convertDateToString(date, type: .full))
                let _dateSlice = UI_Utility.getDateToSliceDateString(date: _lDate)
                return "\(_dateSlice.1)/\(_dateSlice.2)"
            }
        }
        return ""
    }
}

class PagingData {
    var m_idx: Int = 0
    var m_dday: Int = 0
    var m_dayType: GRAPH_PAGE_TYPE = .weekly
    var m_stDateCast: Date! // localDate yyyy-MM-dd 00:00:00
    var m_edDateCast: Date! // localDate yyyy-MM-dd 23:59:59
    var m_dayInfo: String = ""
    var m_bday: String = ""
    
    var isPageMax: Bool {
        get {
            if (m_idx <= 1) {
                return false
            }
            return true
        }
    }
    
    var isPageMin: Bool {
        get {
            if (m_dday <= 0) {
                return false
            }
            return true
        }
    }
    
    init (type: GRAPH_PAGE_TYPE, idx: Int, bday: String) {
        setInfo(type: type, idx: idx, bday: bday)
    }
    
    func setInfo(type: GRAPH_PAGE_TYPE, idx: Int, bday: String) {
        self.m_idx = setIdxConversion(type: type, idx: idx)
        self.m_dayType = type
        self.m_bday = bday
        let _nowDateStr = UI_Utility.nowLocalDate(type: .yyyy_MM_dd)
        let _nowDate = UI_Utility.convertStringToDate(_nowDateStr, type: .yyyy_MM_dd)
        switch type {
        case .day:
            self.m_stDateCast = Date(timeInterval: TimeInterval((86400 * -1 * (m_idx)) + 86400), since: _nowDate!)
            self.m_edDateCast = Date(timeInterval: TimeInterval(86400 * -1 * (m_idx - 1) + 86399), since: _nowDate!)
            //                let _sliceStDate = UI_Utility.getDateToSliceDate(date: m_stDateCast)
            //                let _sliceEdDate = UI_Utility.getDateToSliceDate(date: m_edDateCast)
            //                self.m_dayInfo = "\(_sliceStDate.0)-\(_sliceStDate.1)-\(_sliceStDate.2) ~ \(_sliceEdDate.0)-\(_sliceEdDate.1)-\(_sliceEdDate.2)"
            self.m_dayInfo = UI_Utility.getDateByLanguageFromString(UI_Utility.convertDateToString(self.m_stDateCast, type: .full), fromType: .full, language: Config.languageType)
        
        case .weekly:
            self.m_stDateCast = Date(timeInterval: TimeInterval((86400 * -7 * (m_idx)) + 86400), since: _nowDate!)
            self.m_edDateCast = Date(timeInterval: TimeInterval(86400 * -7 * (m_idx - 1) + 86399), since: _nowDate!)
            //                let _sliceStDate = UI_Utility.getDateToSliceDate(date: m_stDateCast)
            //                let _sliceEdDate = UI_Utility.getDateToSliceDate(date: m_edDateCast)
            //                self.m_dayInfo = "\(_sliceStDate.0)-\(_sliceStDate.1)-\(_sliceStDate.2) ~ \(_sliceEdDate.0)-\(_sliceEdDate.1)-\(_sliceEdDate.2)"
            self.m_dayInfo = UI_Utility.getDateByLanguageFromString(UI_Utility.convertDateToString(self.m_stDateCast, type: .full), fromType: .full, language: Config.languageType) + " ~ " + UI_Utility.getDateByLanguageFromString(UI_Utility.convertDateToString(self.m_edDateCast, type: .full), fromType: .full, language: Config.languageType)

        case .monthly:
            self.m_stDateCast = Date(timeInterval: TimeInterval((-2629743.83 * Double(m_idx))), since: _nowDate!)
            let _strDate = UI_Utility.convertDateToString(self.m_stDateCast, type: .yyyy_MM_dd)
            self.m_stDateCast = UI_Utility.convertStringToDate(_strDate, type: .yyyy_MM_dd)
            self.m_edDateCast = Date(timeInterval: TimeInterval(-2629743.83 * Double(m_idx - 1) + 86399), since: _nowDate!)
            //                self.m_edDateCast = Date(timeInterval: TimeInterval(86400 * -7 * (setIdxConversion(type: DAY_TYPE.weekly, idx: idx) - 1) + 86399), since: _nowDate!) // 주 마지막 일짜 기준으로
                            //                self.m_stDateCast = Date(timeInterval: TimeInterval((-2629743.83 * Double(m_idx))), since: self.m_edDateCast)
            //                let _sliceStDate = UI_Utility.getDateToSliceDate(date: m_stDateCast)
            //                let _sliceEdDate = UI_Utility.getDateToSliceDate(date: m_edDateCast)
            //                self.m_dayInfo = "\(_sliceStDate.0)-\(_sliceStDate.1)-\(_sliceStDate.2) ~ \(_sliceEdDate.0)-\(_sliceEdDate.1)-\(_sliceEdDate.2)"
            self.m_dayInfo = UI_Utility.getDateByLanguageFromString(UI_Utility.convertDateToString(self.m_stDateCast, type: .full), fromType: .full, language: Config.languageType) + " ~ " + UI_Utility.getDateByLanguageFromString(UI_Utility.convertDateToString(self.m_edDateCast, type: .full), fromType: .full, language: Config.languageType)
        }
        
        if (self.m_bday.count > 0) {
            let formatter = DateFormatter()
            formatter.timeZone = TimeZone(abbreviation: "UTC")
            formatter.dateFormat = "yyMMdd"
            switch type {
            case .day:
                let components = NSCalendar.current.dateComponents([.day], from: formatter.date(from: self.m_bday)!, to: m_edDateCast)
                self.m_dday = components.day!
            case .weekly:
                let components = NSCalendar.current.dateComponents([.day], from: formatter.date(from: self.m_bday)!, to: m_edDateCast)
                self.m_dday = components.day! / 7
            case .monthly:
                let components = NSCalendar.current.dateComponents([.month], from: formatter.date(from: self.m_bday)!, to: m_edDateCast)
                self.m_dday = components.month!
            }
        } else {
            self.m_dday = 0
        }
        
        Debug.print("stDateCast: \(String(describing: self.m_stDateCast))", event: .dev)
        Debug.print("edDateCast: \(String(describing: self.m_edDateCast))", event: .dev)
        Debug.print("[GRAPH SENSOR] idx: \(m_idx), type: \(String(describing: m_dayType)), dayInfo: \(m_dayInfo)")
    }
    
    func setIdxConversion(type: GRAPH_PAGE_TYPE, idx: Int) -> Int {
        var _idx = idx
        if (m_dayType != type && m_idx == idx) {
            var _return = 0
            switch type {
            case .day:
                _return = 1
            case .weekly:
                _return = (idx - 1) * 4 + 1
            case .monthly:
                _idx = idx / 4 + 1
                if (idx % 4 == 0) {
                    _idx -= 1
                }
                _return = _idx
                
                if (self.m_bday.count > 0) {
                    let formatter = DateFormatter()
                    formatter.timeZone = TimeZone(abbreviation: "UTC")
                    formatter.dateFormat = "yyMMdd"
                    let _nowDateStr = UI_Utility.nowLocalDate(type: .yyyy_MM_dd)
                    let _nowDate = UI_Utility.convertStringToDate(_nowDateStr, type: .yyyy_MM_dd)
                    let components = NSCalendar.current.dateComponents([.month], from: formatter.date(from: self.m_bday)!, to: _nowDate!)
                    Debug.print(components.month!)
                    if (_return > components.month! + 1) {
                        _return = components.month! + 1
                    }
                }
            }
            return _return
        }
        return _idx
    }
    
    func setDaily() {
        setInfo(type: .day, idx: m_idx, bday: self.m_bday)
    }
       
    func setWeekly() {
        setInfo(type: .weekly, idx: m_idx, bday: self.m_bday)
    }
    
    func setMonthly() {
        setInfo(type: .monthly, idx: m_idx, bday: self.m_bday)
    }
    
    func setPrevPage() {
        setInfo(type: m_dayType, idx: m_idx + 1, bday: self.m_bday)
    }
    
    func setNextPage() {
        if (isPageMax) {
            setInfo(type: m_dayType, idx: m_idx - 1, bday: self.m_bday)
        }
    }
    
}
