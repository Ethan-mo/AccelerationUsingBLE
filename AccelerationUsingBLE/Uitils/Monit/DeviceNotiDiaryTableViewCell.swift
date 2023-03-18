//
//  DeviceNotiTableViewCell.swift
//  Monit
//
//  Created by 맥 on 2017. 9. 26..
//  Copyright © 2017년 맥. All rights reserved.
//

import UIKit

class DeviceNotiDiaryTableViewCell: UITableViewCell {
    @IBOutlet weak var imgIcon: UIImageView!
    @IBOutlet weak var btnInfo: UIButton!
    @IBOutlet weak var lblInfo: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var imgNewAlarm: UIImageView!

    var m_parent: DeviceDetailNotiBaseViewController?
    var m_deviceNotiInfo: DeviceNotiInfo?
    var m_sectionIndex = -1
    var m_index = -1
    var m_editAction: ActionResultAny?
    
    func setInit() {
        setNotiType(noti: m_deviceNotiInfo)
//        setNotiTime(notiType: m_deviceNotiInfo!.notiType)
        imgNewAlarm.isHidden = true
        if let _info = m_deviceNotiInfo {
            if let _lastIdx = m_parent?.m_lastIdx {
                if (_lastIdx != -1 && _lastIdx < _info.m_id) {
                    imgNewAlarm.isHidden = false
                }
            }
        }
    }
    
    func setNotiType(noti: DeviceNotiInfo?) {
        setLabelTime(noti: noti)
        setIcon(noti: noti)
        setLabelInfo(noti: noti)
    }
    
    func setLabelTime(noti: DeviceNotiInfo?) {
        switch noti!.notiType! {
        case .sleep_mode:
            noti?.m_castTimeInfo?.m_dateFormatter.dateFormat = "HH:mm"
            let _first = noti?.m_castTimeInfo?.m_dateFormatter.string(from: noti?.m_castTimeInfo?.m_lTimeCast ?? Date()) ?? ""
            
            noti?.m_castTimeInfo?.m_dateFormatter.dateFormat = "a"
            let _second1 = noti?.m_castTimeInfo?.m_dateFormatter.string(from: noti?.m_castTimeInfo?.m_lTimeCast ?? Date()) ?? ""
            
            noti?.m_castExtraTimeInfo?.m_dateFormatter.dateFormat = "HH:mm"
            let _second2 = noti?.m_castExtraTimeInfo?.m_dateFormatter.string(from: noti?.m_castExtraTimeInfo?.m_lTimeCast ?? Date()) ?? ""
            
            setLabelTimeAttributed(first: _first, second: " \(_second1)\n~\(_second2)")
        default:
            noti?.m_castTimeInfo?.m_dateFormatter.dateFormat = "HH:mm"
            let _first = noti?.m_castTimeInfo?.m_dateFormatter.string(from: noti?.m_castTimeInfo?.m_lTimeCast ?? Date()) ?? ""
            
            noti?.m_castTimeInfo?.m_dateFormatter.dateFormat = "a"
            let _second1 = noti?.m_castTimeInfo?.m_dateFormatter.string(from: noti?.m_castTimeInfo?.m_lTimeCast ?? Date()) ?? ""
            
            setLabelTimeAttributed(first: _first, second: " \(_second1)")
            break
        }
    }
    
    func setIcon(noti: DeviceNotiInfo?) {
        let _imageName = UIManager.instance.getNotiImage(notiType: noti?.notiType ?? .pee_detected, extra: noti?.Extra ?? "")
        imgIcon.image = UIImage(named: _imageName)
    }
    
    func setLabelInfo(noti: DeviceNotiInfo?) {
        // get text
        let _title = UIManager.instance.getNotiText(info: m_deviceNotiInfo, isB2BMode: DataManager.instance.m_userInfo.configData.isHuggiesV1Alarm)
        var _contensts = ""
        if let _memo = noti?.m_memo {
            if (_memo != "-" && _memo != "") {
                _contensts = _memo
            }
        }

        // Set UIColor
        var _color = COLOR_TYPE._brown_194_141_103.color
        switch noti!.notiType! {
        case .diaper_changed:
            _color = COLOR_TYPE._brown_194_141_103.color
        case .sleep_mode:
            _color = COLOR_TYPE._blue_71_88_144.color
        case .breast_milk,
            .breast_feeding,
            .feeding_meal,
            .feeding_milk:
            _color = COLOR_TYPE._red_217_117_117.color
        case .diaper_score:
            _color = COLOR_TYPE._brown_194_141_103.color
        default:
            break
        }
        
        // one line
        lblInfo.font = UIFont.boldSystemFont(ofSize: 14)
        lblInfo.text = _title
        lblInfo.textColor = _color
        
        // multi line
        switch noti!.notiType! {
        case .diaper_changed:
            if (_contensts != "") {
                setLabelInfoAttributed(title: _title, contents: "\n\(_contensts)", titleColor: _color)
            }
        case .sleep_mode:
            var _sleepType = ""
            if let _type = noti?.m_extra2 {
                if (_type != "-" && _type != "") {
                    _sleepType = _type == "1" ? "device_sensor_naps".localized : "device_sensor_night_sleep".localized
                }
            }
            
            let _sleepContents = (_contensts != "") ? "(\(_contensts))" : ""
            if (_sleepType != "" || _sleepContents != "") {
                setLabelInfoAttributed(title: _title, contents: "\n\(_sleepType) \(_sleepContents)", titleColor: _color)
            }
        case .breast_milk:
            var _type = ""
            var _isTotal = false
            if let _total = noti?.Extra {
                if (_total != "-" && _total != "") {
                    _type = "\(_total)\("time_minute_short".localized)"
                    _isTotal = true
                }
            }
            if (!_isTotal) {
                if let _left = noti?.m_extra2 {
                    if (_left != "-" && _left != "") {
                        _type += "\("device_sensor_breast_milk_left".localized) \(_left)\("time_minute_short".localized)"
                    }
                }
                if let _right = noti?.m_extra3 {
                    if (_right != "-" && _right != "") {
                        _type += ", \("device_sensor_breast_milk_right".localized) \(_right)\("time_minute_short".localized)"
                    }
                }
            }
            
            let _breastMilkContents = (_contensts != "") ? "(\(_contensts))" : ""
            if (_type != "" || _breastMilkContents != "") {
                setLabelInfoAttributed(title: _title, contents: "\n\(_type) \(_breastMilkContents)", titleColor: _color)
            }
        case .breast_feeding,
            .feeding_meal,
            .feeding_milk:
            if (_contensts != "") {
                setLabelInfoAttributed(title: _title, contents: "\n\(_contensts)", titleColor: _color)
            }
        default:
            break
        }
    }
    
    func setLabelTimeAttributed(first: String, second: String) {
        let _attributed1 = LabelAttributed(labelValue: first, attributed:
            [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 12)])
        let _attributed2 = LabelAttributed(labelValue: second, attributed:
            [NSAttributedStringKey.font : UIFont(name: Config.FONT_NotoSans, size: 12.0)!])
        
        UI_Utility.multiAttributedLabel(label: lblTime, arrAttributed: [_attributed1, _attributed2])
    }
    
    func setLabelInfoAttributed(title: String, contents: String, titleColor: UIColor) {
        let _attributed1 = LabelAttributed(labelValue: title, attributed:
            [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 14),
             NSAttributedStringKey.foregroundColor : titleColor])
        let _attributed2 = LabelAttributed(labelValue: "\(contents)", attributed:
            [NSAttributedStringKey.font : UIFont(name: Config.FONT_NotoSans, size: 12.0)!,
             NSAttributedStringKey.foregroundColor : COLOR_TYPE.lblGray.color])
        
        UI_Utility.multiAttributedLabel(label: lblInfo, arrAttributed: [_attributed1, _attributed2])
    }
    
    @IBAction func onClick_edit(_ sender: UIButton) {
        m_editAction?(m_deviceNotiInfo)
    }
}
