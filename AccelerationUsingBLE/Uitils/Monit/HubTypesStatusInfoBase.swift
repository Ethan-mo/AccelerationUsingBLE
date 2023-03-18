//
//  HubTypesStatusInfoBase.swift
//  Monit
//
//  Created by john.lee on 07/01/2020.
//  Copyright © 2020 맥. All rights reserved.
//

import Foundation

enum HUB_TYPES_POWER: Int {
    case on = 1
    case off = 0
}

enum HUB_TYPES_TEMP {
    case low
    case high
    case normal
}

enum HUB_TYPES_HUM {
    case low
    case high
    case normal
}

enum HUB_TYPES_VOC {
    case none
    case good
    case normal
    case bad
    case veryBad
}

enum HUB_TYPES_SCORE {
    case good
    case normal
    case bad
    case veryBad
}

enum HUB_TYPES_SENSOR_ATTACHED {
    case attached
    case detached
}

class HubTypesStatusInfoBase {
    var m_did: Int = 0
    var m_name: String = ""
    var m_power: Int = 0
    var m_bright: Int = 0
    var m_color: Int = 0
    var m_attached: Int = 0
    var m_temp: Int = 0
    var m_hum: Int = 0
    var m_voc: Int = 0
    var m_ap: String = ""
    var m_apse: String = ""
    var m_tempmax: Int = 0
    var m_tempmin: Int = 0
    var m_hummax: Int = 0
    var m_hummin: Int = 0
    var m_offt: String = ""
    var m_onnt: String = ""
    var m_con: Int = 0
    var m_offptime: String = ""
    var m_onptime: String = ""
    
    init(did: Int, name: String, power: Int, bright: Int, color: Int, attached: Int, temp: Int, hum: Int, voc: Int, ap: String, apse: String, tempmax: Int, tempmin: Int, hummax: Int, hummin: Int, offt: String, onnt: String, con: Int, offptime: String, onptime: String) {
        self.m_did = did
        self.m_name = name
        self.m_power = power
        self.m_bright = bright
        self.m_color = color
        self.m_attached = attached
        self.m_temp = temp
        self.m_hum = hum
        self.m_voc = voc
        self.m_ap = ap
        self.m_apse = apse
        self.m_tempmax = tempmax
        self.m_tempmin = tempmin
        self.m_hummax = hummax
        self.m_hummin = hummin
        self.m_offt = offt
        self.m_onnt = onnt
        self.m_con = con
        self.m_offptime = offptime
        self.m_onptime = onptime
    }
    
    var isPower: Bool {
        get {
            let _power = HUB_TYPES_POWER(rawValue: m_power)!
            if (_power == .on) {
                return true
            } else {
                return false
            }
        }
    }
    
    var isConnect: Bool {
        get {
            return m_con == 1 || m_con == 2 ? true : false
        }
    }
    
    var temp: HUB_TYPES_TEMP {
        get {
            if (m_tempmin <= m_temp && m_temp <= m_tempmax) {
                return .normal
            } else {
                if (m_temp < m_tempmin) {
                    return .low
                }
                if (m_tempmax < m_temp) {
                    return .high
                }
            }
            return .normal
        }
    }
    
    var hum: HUB_TYPES_HUM {
        get {
            if (m_hummin <= m_hum && m_hum <= m_hummax) {
                return .normal
            } else {
                if (m_hum < m_hummin) {
                    return .low
                }
                if (m_hummax < m_hum) {
                    return .high
                }
            }
            return .normal
        }
    }
    
    var voc: HUB_TYPES_VOC {
        get {
            return HubTypesStatusInfoBase.getVocType(attached: m_attached, value: m_voc)
        }
    }
    
    var score: HUB_TYPES_SCORE {
        get {
            return HubTypesStatusInfoBase.getScoreType(value: scoreValue)
        }
    }
    
//    var tempValue: Double {
//        get {
//            let _temp = Double(m_temp) / 100.0
//            return UIManager.instance.getTemperatureProcessing(value: _temp)
//        }
//        set {
//            if (UIManager.instance.temperatureUnit == .Celsius) {
//                m_temp = Int(newValue * 100)
//            } else {
//                m_temp = Int(UI_Utility.fahrenheitToCelsius(tempInF: newValue) * 100)
//            }
//        }
//    }
    
    var humValue: Double {
        get {
            return Double(m_hum) / 100.0
        }
        set {
            m_hum = Int(newValue * 100)
        }
    }
    
    var vocValue: Double {
        get {
            return Double(m_voc) / 100.0
        }
        set {
            m_voc = Int(newValue * 100)
        }
    }
    
    var hummaxValue: Double {
        get {
            return Double(m_hummax) / 100.0
        }
        set {
            m_hummax = Int(newValue * 100)
        }
    }
    
    var humminValue: Double {
        get {
            return Double(m_hummin) / 100.0
        }
        set {
            m_hummin = Int(newValue * 100)
        }
    }
    
    var scoreValue: Int {
        get {
            var score = 100.0
            var avg = 0.0
            var diff = 0.0
            
            // -----------------
            let _tempminValue = Double(m_tempmin) / 100.0
            let _tempmaxValue = Double(m_tempmax) / 100.0
            let _tempValue = Double(m_temp) / 100.0
            if (m_voc != -1) {
                avg = (_tempminValue + _tempmaxValue) / 2
                if (_tempValue < _tempminValue) {
                    score -= 10
                    score -= (_tempminValue - _tempValue) * 10
                } else if (_tempValue > _tempmaxValue) {
                    score -= 10
                    score -= (_tempValue - _tempmaxValue) * 10
                } else {
                    diff = _tempValue - avg
                    if (diff > 0) { score -= diff * 5 }
                    else { score += diff * 5 }
                }
                
                avg = (humminValue + hummaxValue) / 2
                if (humValue < humminValue) {
                    score -= 10
                    score -= (humminValue - humValue) * 2
                } else if (humValue > hummaxValue) {
                    score -= 10
                    score -= (humValue - hummaxValue) * 2
                } else {
                    diff = humValue - avg
                    if (diff > 0) { score -= diff }
                    else { score += diff }
                }
                
                switch (voc) {
                case .bad, .veryBad:
                    score -= 10
                    score -= (vocValue - 150) / 4 + 1
                default:
                    score -= vocValue / 4 + 1
                }
            } else {
                avg = (_tempminValue + _tempmaxValue) / 2
                if (_tempValue < _tempminValue) {
                    score -= 12
                    score -= (_tempminValue - _tempValue) * 15
                } else if (_tempValue > _tempmaxValue) {
                    score -= 12
                    score -= (_tempValue - _tempmaxValue) * 15
                } else {
                    diff = _tempValue - avg
                    if (diff > 0) { score -= diff * 7 }
                    else { score += diff * 7 }
                }
                
                avg = (humminValue + hummaxValue) / 2
                if (humValue < humminValue) {
                    score -= 12
                    score -= (humminValue - humValue) * 3
                } else if (humValue > hummaxValue) {
                    score -= 12
                    score -= (humValue - hummaxValue) * 3
                } else {
                    diff = humValue - avg
                    if (diff > 0) { score -= diff }
                    else { score += diff }
                }
            }
            
            if (score < 0) {
                score = 0
            }
            
            return Int(score)
        }
    }
    
    var isLed: Bool {
        get {
            if (m_offt[m_offt.index(m_offt.endIndex, offsetBy: -1)...] == "0") {
                return true
            } else {
                return false
            }
        }
        set {
            if (m_onnt.count == 5 && m_offt.count == 5) {
                let _startIndexOnnt = m_onnt.index(m_onnt.startIndex, offsetBy: 4)
                m_onnt = m_onnt[..<_startIndexOnnt] + (newValue ? "0" : "1")
                let _startIndexOfft = m_offt.index(m_offt.startIndex, offsetBy: 4)
                m_offt = m_offt[..<_startIndexOfft] + (newValue ? "0" : "1")
            } else {
                m_onnt = "0000\(newValue ? "0" : "1")"
                m_offt = "0000\(newValue ? "0" : "1")"
            }
        }
    }
    
    var ledOnTime: Int {
        get {
            if (m_onnt.count == 5) {
                let _startIndex = m_onnt.index(m_onnt.startIndex, offsetBy: 4)
                let _utcTime = String(m_onnt[..<_startIndex])

                let _full = UI_Utility.convertDateStringToString(_utcTime, fromType: .HHmm, toType: .full)
                let _localTime = UI_Utility.UTCToLocal(date: _full)
                let _HH = UI_Utility.convertDateStringToString(_localTime, fromType: .full, toType: .HH)
                return Int(_HH)!
            } else {
                let _full = UI_Utility.convertDateStringToString("0000", fromType: .HHmm, toType: .full)
                let _localTime = UI_Utility.UTCToLocal(date: _full)
                let _HH = UI_Utility.convertDateStringToString(_localTime, fromType: .full, toType: .HH)
                return Int(_HH)!
            }
        }
        set {
            var _value = newValue.description
            if (_value.count == 1) {
                _value = "0" + _value
            }
            let _full = UI_Utility.convertDateStringToString(_value, fromType: .HH, toType: .full)
            let _utcTime = UI_Utility.localToUTC(date: _full)
            let _HHmm = UI_Utility.convertDateStringToString(_utcTime, fromType: .full, toType: .HHmm)
            m_onnt = _HHmm + (isLed ? "0" : "1")
        }
    }
    
    var ledOnTimeStr: String {
        get {
            return "\(ledOnTime):00"
        }
    }
    
    var ledOffTime: Int {
        get {
            if (m_offt.count == 5) {
                let _startIndex = m_offt.index(m_offt.startIndex, offsetBy: 4)
                let _utcTime = String(m_offt[..<_startIndex])

                let _full = UI_Utility.convertDateStringToString(_utcTime, fromType: .HHmm, toType: .full)
                let _localTime = UI_Utility.UTCToLocal(date: _full)
                let _HH = UI_Utility.convertDateStringToString(_localTime, fromType: .full, toType: .HH)
                return Int(_HH)!
            } else {
                let _full = UI_Utility.convertDateStringToString("0000", fromType: .HHmm, toType: .full)
                let _localTime = UI_Utility.UTCToLocal(date: _full)
                let _HH = UI_Utility.convertDateStringToString(_localTime, fromType: .full, toType: .HH)
                return Int(_HH)!
            }
        }
        set {
            var _value = newValue.description
            if (_value.count == 1) {
                _value = "0" + _value
            }
            let _full = UI_Utility.convertDateStringToString(_value, fromType: .HH, toType: .full)
            let _utcTime = UI_Utility.localToUTC(date: _full)
            let _HHmm = UI_Utility.convertDateStringToString(_utcTime, fromType: .full, toType: .HHmm)
            m_offt = _HHmm + (isLed ? "0" : "1")
        }
    }
    
    var ledOffTimeStr: String {
        get {
            return "\(ledOffTime):00"
        }
    }
    
    var brightLevel: HUB_TYPES_BRIGHT_TYPE {
        get {
            if let _level = HUB_TYPES_BRIGHT_TYPE(rawValue: m_bright) {
                return _level
            }
            return .start
        }
        set {
            m_bright = newValue.rawValue
        }
    }
    
    var brightLevelV2: HUB_TYPES_BRIGHT_V2_TYPE {
        get {
            if let _level = HUB_TYPES_BRIGHT_V2_TYPE(rawValue: m_bright) {
                return _level
            }
            return .level_1
        }
        set {
            m_bright = newValue.rawValue
        }
    }
    
    static func getScoreType(value: Int) -> HUB_TYPES_SCORE {
        switch value {
        case 0..<50:
            return .veryBad
        case 50..<70:
            return .bad
        case 70..<90:
            return .normal
        case 90..<101:
            return .good
        default:
            return .veryBad
        }
    }
    
    static func getVocType(attached: Int, value: Int) -> HUB_TYPES_VOC {
        if (attached == 0) {
            return .none
        }
        if (0 <= value && value < 5100) {
            return .good
        } else if (value < 15100) {
            return .normal
        } else if (value < 30100) {
            return .bad
        } else if (30100 <= value) {
            return .veryBad
        }
        return .normal
    }
}
