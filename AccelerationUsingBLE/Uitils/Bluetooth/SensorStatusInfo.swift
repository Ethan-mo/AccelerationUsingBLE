//
//  SensorStatusInfo.swift
//  AccelerationUsingBLE
//
//  Created by 모상현 on 2023/02/08.
//

import UIKit

// 센서 상태 정보를 정리
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
    
    // 왜있는지 모르겠음. 현재 연결상태를 판단해줌
    var con: Int {
        return m_con > 0 ? 1 : 0
    }
    
    // 현재 센서의 작동 모드를 판별해줌
    var operation: SENSOR_OPERATION {
        if let _operation = SENSOR_OPERATION(rawValue: m_operation) {
            return _operation
        } else {
            return .none
        }
    }
    
    // 현재 센서의 움직임을 4단계로 나누어 판단한다.
    var movement: SENSOR_MOVEMENT {
        return SensorStatusInfo.GetMovementLevel(mov: m_movement)
    }
    
    // 수면수치인 13값을 받아올 경우 isSleep으로 표현한다.
    var isSleep: Bool {
        return m_sleep == Config.SLEEP_VALUE
    }
    
    // 센서 상태를 표기해준다.
    /// 노말: 0
    /// 소변: 1
    /// 대변: 2
    /// maxvoc: 3
    /// hold: 4
    /// fart: 5
    /// detectDiaperChanged: 6
    /// attachSensor: 7
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
    
    // 허브와 연결되어있는지 판단
    var isHubConnect: Bool {
        get {
            // 일단 nil상태가 아닌 상태에서,
            if let _operation = SENSOR_OPERATION(rawValue: m_operation) {
                switch _operation {
                    // 아래 4개의 케이스일경우,
                    // isHubConnect가 true
                    // 그 외에는 false
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
    
    // 배터리 상태를 표시해준다.
    var battery: SENSOR_BATTERY_STATUS {
        get {
            // 배터리 초기값은 0이다.
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
                print("[ERROR] battery invalid: \(_battery)")
                returnValue = ._0
            }
            
            switch operation {
                // 17, 33
            case .cableCharging, .hubCharging:
                returnValue = .charging
                // 18, 34
            case .cableFinishedCharge, .hubFinishedCharge:
                returnValue = .full
            default: break
            }
            
            return returnValue
        }
    }
    
    // 센서의 voc값을 평균으로 계산하고, 5가지 분류로 표기한다.
    /// 0, level1, level2, level3, level4, level5
    var vocAvg: SENSOR_VOC_AVG {
        get {
            return SensorStatusInfo.GetVocAvg(vocAvg: m_voc_avg)
        }
    }
    // 센서 상태를 점수로 계산하고, 단계별로 나누어 표기한다.
    /// good, bad, need_changed
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
        } else {
            return .need_changed
        }
    }
}
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
