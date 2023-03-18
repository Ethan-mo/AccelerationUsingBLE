//
//  File.swift
//  Monit
//
//  Created by john.lee on 2019. 3. 20..
//  Copyright © 2019년 맥. All rights reserved.
//

import Foundation

enum SENSOR_OPERATION: Int {
    case none = -1
    case sensing = 0
    case idle = 4 // sensing
    case diaperChanged = 8 // sensing
    case avoidSensing = 12 // sensing
    
    case cableNoCharge = 16
    case cableCharging = 17
    case cableFinishedCharge = 18
    case cableChargeError = 19
    
    case hubNoCharge = 32
    case hubCharging = 33
    case hubFinishedCharge = 34
    case hubChargeError = 35
    
    case debugNoCharge = 48
    case debugCharging = 49
    case debugFinishedCharge = 50
    case debugChargeError = 51
}

enum SENSOR_MOVEMENT: Int {
    case none = 0
    case level_1 = 1
    case level_2 = 2
    case level_3 = 3
}

enum SENSOR_DIAPER_STATUS: Int {
    case normal = 0
    case pee = 1
    case poo = 2
    case maxvoc = 3 // 잘 나오지 않음., abnormal로 처리.
    case hold = 4 // 뗫다가 다시 붙임., abnormal로 처리.
    case fart = 5
    case detectDiaperChanged = 6
    case attachSensor = 7
}

enum SENSOR_BATTERY_STATUS {
    case _0
    case _10
    case _20
    case _30
    case _40
    case _50
    case _60
    case _70
    case _80
    case _90
    case _100
    case charging
    case full
}

enum SENSOR_VOC_AVG: Int {
    case none = 0
    case level_1 = 1
    case level_2 = 2
    case level_3 = 3
    case level_4 = 4
}

enum SENSOR_DIAPER_SCORE: Int {
    case good = 1
    case bad = 2
    case need_changed = 3
}

class SensorStatusInfo {
    var m_did: Int = 0
    var m_battery: Int = 0
    var m_operation: Int = 0
    var m_movement: Int = 0
    var m_diaperstatus: Int = 0
    var m_temp: Int = 0
    var m_hum: Int = 0
    var m_voc: Int = 0
    var m_name: String = ""
    var m_bday: String = ""
    var m_sex: Int = 0
    var m_eat: Int = 0
    var m_sens: Int = 0
    var m_con: Int = 0
    var m_whereConn: Int = 0
    var m_voc_avg: Int = 0
    var m_dscore: Int = 0
    var m_sleep: Int = 0
    
    init(did: Int, battery: Int, operation: Int, movement: Int, diaperstatus: Int, temp: Int, hum: Int, voc: Int, name: String, bday: String, sex: Int, eat: Int, sens: Int, con: Int, whereConn: Int, voc_avg: Int, dscore: Int, sleep: Int) {
        self.m_did = did
        self.m_name = name
        self.m_battery = battery
        self.m_operation = operation
        self.m_movement = movement
        self.m_diaperstatus = diaperstatus
        self.m_temp = temp
        self.m_hum = hum
        self.m_voc = voc
        self.m_name = name
        self.m_bday = bday
        self.m_sex = sex
        self.m_eat = eat
        self.m_sens = sens
        self.m_con = con
        self.m_whereConn = whereConn
        self.m_voc_avg = voc_avg
        self.m_dscore = dscore
        self.m_sleep = sleep
    }
    
    var con: Int {
        get {
            if (m_con > 0) {
                return 1
            } else {
                return 0
            }
        }
    }
    
    var operation: SENSOR_OPERATION {
        get {
            if let _operation = SENSOR_OPERATION(rawValue: m_operation) {
                return _operation
            } else {
                return .none
            }
        }
    }
    
    var movement: SENSOR_MOVEMENT {
        get {
            return SensorStatusInfo.GetMovementLevel(mov: m_movement)
        }
    }
    
    var isSleep: Bool {
        get {
            return m_sleep == Config.SLEEP_VALUE
        }
    }
    
    var diaperStatus: SENSOR_DIAPER_STATUS {
        get {
            if (m_diaperstatus == -1) {
                return .normal
            } else {
                if let _status = SENSOR_DIAPER_STATUS(rawValue: m_diaperstatus) {
                    return _status
                } else {
                    return .normal
                }
            }
        }
    }
    
    var isHubConnect: Bool {
        get {
            if let _operation = SENSOR_OPERATION(rawValue: m_operation) {
                switch _operation {
                case .hubNoCharge,
                     .hubCharging,
                     .hubFinishedCharge,
                     .hubChargeError:
                    return true
                default: break
                }
            }
            return false
        }
    }
    
    var battery: SENSOR_BATTERY_STATUS {
        get {
            var returnValue = SENSOR_BATTERY_STATUS._0
            let _battery: Int = m_battery / 100
            switch _battery {
            case 0: returnValue = ._0
            case 1..<20: returnValue = ._10
            case 20..<30: returnValue = ._20
            case 30..<40: returnValue = ._30
            case 40..<50: returnValue = ._40
            case 50..<60: returnValue = ._50
            case 60..<70: returnValue = ._60
            case 70..<80: returnValue = ._70
            case 80..<90: returnValue = ._80
            case 90..<100: returnValue = ._90
            case 100: returnValue = ._100
            default:
                Debug.print("[ERROR] battery invalid: \(_battery)", event: .error)
                returnValue = ._0
            }
            
            switch operation {
            case .cableCharging,
                 .hubCharging:
                returnValue = .charging
            case .cableFinishedCharge,
                 .hubFinishedCharge:
                returnValue = .full
            default: break
            }
            
            return returnValue
        }
    }
    
    var vocAvg: SENSOR_VOC_AVG {
        get {
            return SensorStatusInfo.GetVocAvg(vocAvg: m_voc_avg)
        }
    }
    
    var diaperScore: SENSOR_DIAPER_SCORE {
        get {
            return SensorStatusInfo.GetDiaperScore(score: m_dscore)
        }
    }
    
    
    static func GetMovementLevel(mov: Int) -> SENSOR_MOVEMENT {
        if (0 == mov) {
            return .none
        } else if (1 <= mov && mov <= 3) {
            return .level_1
        } else if (4 <= mov && mov <= 7) {
            return .level_2
        } else if (8 <= mov && mov <= 12) {
            return .level_3
        } else {
            return .level_1
        }
    }
    
    static func GetVocAvg(vocAvg: Int) -> SENSOR_VOC_AVG {
        let _vocAvg = vocAvg / 100
        
        if (0 == _vocAvg) {
            return .none
        } else if (1 <= _vocAvg && _vocAvg <= 100) {
            return .level_1
        } else if (101 <= _vocAvg && _vocAvg <= 300) {
            return .level_2
        } else if (301 <= _vocAvg && _vocAvg <= 1000) {
            return .level_3
        } else if (1001 <= _vocAvg) {
            return .level_4
        } else {
            return .level_4
        }
    }
    
    static func GetDiaperScore(score: Int) -> SENSOR_DIAPER_SCORE {
        if (90 <= score && score <= 100) {
            return .good
        } else if (60 <= score && score <= 89) {
            return .bad
        } else if (score <= 59) {
            return .need_changed
        } else {
            return .need_changed
        }
    }
}
