//
//  SensorDiaryHeaderView.swift
//  Monit
//
//  Created by john.lee on 2020/08/05.
//  Copyright © 2020 맥. All rights reserved.
//

import Foundation

class SensorDiaryHeaderView: UIView {
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblFeeding: UILabel!
    @IBOutlet weak var lblChangeDiaper: UILabel!
    @IBOutlet weak var lblSleepMode: UILabel!
    
    func setUI(arr: [DeviceNotiInfo]?) {
        var _title = ""
        var _feedingAmount = 0
        var _feedingTime = 0
        var _peeCount = 0
        var _pooCount = 0
        var _sleepModeMinute = 0
        
        if let _arr = arr {
            for item in _arr {
                _title = UI_Utility.getDateByLanguageFromString(item.m_castTimeInfo.m_lDate, fromType: .yyyy_MM_dd, language: Config.languageType)
                
                if let _noti = item.notiType {
                    switch _noti {
                    case .feeding_milk:
                        _feedingAmount += Int(item.Extra) ?? 0
                    case .breast_milk:
                        let _total = item.Extra
                        if (_total != "-" && _total != "") {
                            _feedingTime += Int(_total) ?? 0
                        } else {
                            let _left = item.m_extra2
                            if (_left != "-" && _left != "") {
                                _feedingTime += Int(_left) ?? 0
                            }
                            
                            let _right = item.m_extra3
                            if (_right != "-" && _right != "") {
                                _feedingTime += Int(_right) ?? 0
                            }
                        }
                    case .diaper_changed:
                        switch item.Extra {
                        case "2":
                            _peeCount += 1
                        case "3":
                            _pooCount += 1
                        case "4":
                            _peeCount += 1
                            _pooCount += 1
                        default:
                            break
                        }
                    case .sleep_mode:
                        if (item.Extra == "" || item.Extra == "-") {
                        } else {
                            let _nowUTCTimeDate = UI_Utility.convertStringToDate(item.Time, type: .yyMMdd_HHmmss)
                            let _infoTimeDate = UI_Utility.convertStringToDate(item.Extra, type: .yyMMdd_HHmmss)
                            let _calendar = Calendar.current.dateComponents([.minute], from: _nowUTCTimeDate!, to: _infoTimeDate!)
                            _sleepModeMinute += _calendar.minute ?? 0
                        }
                    default:
                        break
                    }
                }
            }
        }
        
        lblTitle.font = UIFont.boldSystemFont(ofSize: 12)
        lblTitle.text = "\(_title)"
        lblFeeding.text = "총\(_feedingAmount)ml+\(_feedingTime)분"
        lblChangeDiaper.text = "소변\(_peeCount)회,대변\(_pooCount)회"
        lblSleepMode.text = "총 \(_sleepModeMinute / 60)시간 \(_sleepModeMinute % 60)분"
    }
}
