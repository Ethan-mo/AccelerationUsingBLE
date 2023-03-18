//
//  UIManager.swift
//  Monit
//
//  Created by 맥 on 2017. 10. 31..
//  Copyright © 2017년 맥. All rights reserved.
//

import UIKit
import UserNotifications
import CoreBluetooth

class CastDateFormat {
    var m_dateFormatter = DateFormatter()
    var m_date: String = "" // yyyy-MM-dd
    var m_lDate: String = "" // yyyy-MM-dd
    var m_time: String = "" // yyMMdd-HHmmss
    var m_lTime: String = "" // yyMMdd-HHmmss
    var m_dateCast: Date!
    var m_lDateCast: Date!
    var m_timeCast: Date!
    var m_lTimeCast: Date!
    
    init () {
    }
    
    init (time: String) {
        setInit(time: time)
    }

    func setInit(time: String) {
        self.m_time = time
        
        // timeCast
        m_dateFormatter.dateFormat = DATE_TYPE.yyMMdd_HHmmss.rawValue
        m_dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        self.m_timeCast = m_dateFormatter.date(from: time)
        
        // lTime
        m_dateFormatter.dateFormat = DATE_TYPE.yyMMdd_HHmmss.rawValue
        m_dateFormatter.timeZone = TimeZone.current
        self.m_lTime = m_dateFormatter.string(from: m_timeCast)
        
        // lTimeCast
        m_dateFormatter.dateFormat = DATE_TYPE.yyMMdd_HHmmss.rawValue
        m_dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        self.m_lTimeCast = m_dateFormatter.date(from: self.m_lTime)
        
        // date
        m_dateFormatter.dateFormat = DATE_TYPE.yyyy_MM_dd.rawValue
        self.m_date = m_dateFormatter.string(from: m_timeCast)
        
        // dateCast
        m_dateFormatter.dateFormat = DATE_TYPE.yyyy_MM_dd.rawValue
        m_dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        self.m_dateCast = m_dateFormatter.date(from: self.m_date)
        
        // lDate
        m_dateFormatter.dateFormat = DATE_TYPE.yyyy_MM_dd.rawValue
        self.m_lDate = m_dateFormatter.string(from: m_lTimeCast)
        
        // lDateCast
        m_dateFormatter.dateFormat = DATE_TYPE.yyyy_MM_dd.rawValue
        m_dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        self.m_lDateCast = m_dateFormatter.date(from: self.m_lDate)
        
//        Debug.print("m_time:\(time), m_lTime:\(m_lTime), m_timeCast:\(m_timeCast), m_lTime:\(m_lTimeCast), m_date:\(m_date), m_dateCast:\(m_dateCast), m_lDate:\(m_lDate), m_lDateCast:\(m_lDateCast)")
    }
}

class UIManager {
    static var m_instance: UIManager!
    static var instance: UIManager {
        get {
            if (m_instance == nil) {
                m_instance = UIManager()
            }
            
            return m_instance
        }
    }

    enum PASSWORD_VAILD_TYPE
    {
        case success
        case digit
        case special
        case alphabet_lower
        case alphabet_upper
        case length
    }
    
    var m_finishScenePush: SCENE_MOVE_PUSH?
    var m_moveSceneDeviceType: Int = 0
    var m_moveSceneDeviceID: Int = 0
    var m_deviceNeedHubPopup: Bool = false
    var m_deviceNeedLampPopup: Bool = false

    var rootCurrentView: UIViewController? {
        get {
            if let _view = getTopViewController(from: UIApplication.shared.keyWindow?.rootViewController) {
                return _view
            }
            return nil
        }
    }
    
    var m_indicator : IndicatorView?
    
    var isNotificationAuth: Bool {
        get {
            if #available(iOS 10.0, *) {
                let notificationType = UIApplication.shared.currentUserNotificationSettings!.types
                if notificationType == [] {
                    return false
                } else {
                    return true
                }
            } else {
                // Fallback on earlier versions
                if UIApplication.shared.isRegisteredForRemoteNotifications {
                    return true
                } else {
                    return false
                }
            }
        }
    }
    
    var temperatureUnit: TEMPERATURE_UNIT {
        get {
//            let locale = NSLocale.current as NSLocale
//            let obj = locale.object(forKey: NSLocale.Key(rawValue: "kCFLocaleTemperatureUnitKey"))
//            if (obj as? String == TEMPERATURE_UNIT.Fahrenheit.rawValue) {
//                return .Fahrenheit
//            } else {
//                return .Celsius
//            }
            
            if (DataManager.instance.m_userInfo.configData.m_tempUnit == "C") {
                return .Celsius
            } else {
                return .Fahrenheit
            }
        }
    }
    
    var temperatureUnitStr: String {
        get {
//            let locale = NSLocale.current as NSLocale
//            let obj = locale.object(forKey: NSLocale.Key(rawValue: "kCFLocaleTemperatureUnitKey"))
//            if (obj as? String == TEMPERATURE_UNIT.Fahrenheit.rawValue) {
//                return "unit_temperature_fahrenheit".localized
//            } else {
//                return "unit_temperature_celsius".localized
//            }
            
            if (DataManager.instance.m_userInfo.configData.m_tempUnit == "C") {
                return "unit_temperature_celsius".localized
            } else {
                return "unit_temperature_fahrenheit".localized
            }
        }
    }
    
    func setContensEnable(isOn: Bool, orginPosX: CGFloat, btnTitle: UIButton, lblValue: UILabel?, imgArrow: UIImageView?, lblDescription: UILabel? = nil) {
        if (isOn) {
            btnTitle.isUserInteractionEnabled = true
            btnTitle.setTitleColor(COLOR_TYPE.lblGray.color, for: .normal)
//            imgArrow?.isHidden = false
            imgArrow?.image = UIImage(named: "imgRightArrow")
            lblValue?.textColor = COLOR_TYPE.lblGray.color
            lblValue?.bounds.origin.x = orginPosX
            lblDescription?.textColor = COLOR_TYPE.lblGray.color
        } else {
            btnTitle.isUserInteractionEnabled = false
            btnTitle.setTitleColor(COLOR_TYPE.lblWhiteGray.color, for: .normal)
//            imgArrow?.isHidden = true
            imgArrow?.image = UIImage(named: "imgRightArrowDisable")
            lblValue?.textColor = COLOR_TYPE.lblWhiteGray.color
            lblValue?.bounds.origin.x = orginPosX + 20
            lblDescription?.textColor = COLOR_TYPE.lblWhiteGray.color
        }
    }
    
    func setContentEnableForConnect(isOn: Bool, isMaster: Bool, orginPosX: CGFloat, btnTitle: UIButton, lblValue: UILabel, imgArrow: UIImageView?, lblDescription: UILabel? = nil) {
        var _isEnable = false
        if (isMaster) {
            if (isOn) {
                _isEnable = true
            } else {
                _isEnable = false
            }
        } else {
            _isEnable = false
        }
        
        if (_isEnable) {
            btnTitle.isUserInteractionEnabled = true
            btnTitle.setTitleColor(COLOR_TYPE.lblGray.color, for: .normal)
            imgArrow?.image = UIImage(named: "imgRightArrow")
            lblValue.textColor = COLOR_TYPE.lblGray.color
            lblDescription?.textColor = COLOR_TYPE.lblGray.color
        } else {
            btnTitle.isUserInteractionEnabled = false
            btnTitle.setTitleColor(COLOR_TYPE.lblWhiteGray.color, for: .normal)
            imgArrow?.image = UIImage(named: "imgRightArrowDisable")
            lblValue.textColor = COLOR_TYPE.lblWhiteGray.color
            lblDescription?.textColor = COLOR_TYPE.lblWhiteGray.color
        }
        
        if (isMaster) {
            imgArrow?.isHidden = false
            lblValue.bounds.origin.x = orginPosX
        } else {
            imgArrow?.isHidden = true
            lblValue.bounds.origin.x = orginPosX + 20
        }
    }
    
    func setContentEnableSw(isOn: Bool, lblTitle: UILabel, sw: UISwitch, lblDescription: UILabel? = nil) {
        if (isOn) {
            lblTitle.textColor = COLOR_TYPE.lblGray.color
            sw.onTintColor = COLOR_TYPE.swEnableBG.color
            sw.isEnabled = true
            lblDescription?.textColor = COLOR_TYPE.lblGray.color
        } else {
            lblTitle.textColor = COLOR_TYPE.lblWhiteGray.color
            sw.onTintColor = COLOR_TYPE.swDisableBG.color
            sw.isEnabled = false
            lblDescription?.textColor = COLOR_TYPE.lblWhiteGray.color
        }
    }
    
    func currentUIReload() {
        
        Debug.print("[UI] reload!")
        
        if let _baseViewContrller = rootCurrentView as? BaseViewController {
            if (_baseViewContrller.isUpdateView) {
                _baseViewContrller.reloadInfo()
            }
        }
        if let _baseTableViewContrller = rootCurrentView as? BaseTableViewController {
            if (_baseTableViewContrller.isUpdateView) {
                _baseTableViewContrller.reloadInfo()
            }
        }
        if let _basePageViewContrller = rootCurrentView as? BasePageViewController {
            if (_basePageViewContrller.isUpdateView) {
                _basePageViewContrller.reloadInfo()
            }
        }
    }
    
    func deviceRefrash() {
        var _isContinue = true
        if let _currentView = rootCurrentView {
            if let _view = _currentView as? BaseViewController {
                if (!(_view.isUpdateView)) {
                    _isContinue = false
                }
            }
        }
        
        if (_isContinue) {
            _ = PopupManager.instance.onlyContents(contentsKey: "toast_sharing_member_renewed", confirmType: .ok, okHandler: { () -> () in
                _ = self.sceneMove(scene: .initView, animation: .coverVertical, isAnimation: false)
            })
        }
    }

    func getTopViewController(from viewController: UIViewController?) -> UIViewController? {
        if let tabBarViewController = viewController as? UITabBarController {
            return getTopViewController(from: tabBarViewController.selectedViewController)
        } else if let navigationController = viewController as? UINavigationController {
            return getTopViewController(from: navigationController.visibleViewController)
        } else if let presentedViewController = viewController?.presentedViewController {
            return getTopViewController(from: presentedViewController)
        } else {
            return viewController
        }
    }
    
    func getWifiSecurityString(type: WIFI_SECURITY_TYPE) -> String {
        switch type {
        case .NONE: return "connection_hub_network_security_none".localized
        case .WEB: return "WEP"
        case .WPA: return "WPA"
        case .WPA2: return "WPA2"
        case .WPA_TKIP: return "WPA_TKIP"
        case .WPA2_TKIP: return "WPA2_TKIP"
        case .EAP: return "EAP"
        }
    }
    
    func setMoveNextScene(finishScenePush: SCENE_MOVE_PUSH, moveScene: SCENE_MOVE) {
        self.m_finishScenePush = finishScenePush
        _ = sceneMove(scene: moveScene, animation: .coverVertical, isAnimation: false)
    }

    func sceneMove(scene: SCENE_MOVE, animation: UIModalTransitionStyle, isAnimation: Bool = true) -> UIViewController
    {
        if (scene == .initView) {
            Debug.print("Go initView", event: .warning)
        }
        
        let storyboard: UIStoryboard = UIStoryboard(name: SystemManager.instance.GetStoryBoardName(scene), bundle: nil)
        let uvc = storyboard.instantiateViewController(withIdentifier: scene.rawValue)
        uvc.modalTransitionStyle = animation
        uvc.modalPresentationStyle = .fullScreen
        rootCurrentView?.present(uvc, animated: isAnimation)
        
        return uvc
    }
    
    func sceneMoveDismiss()
    {
        rootCurrentView?.dismiss(animated: true, completion: nil)
    }
    
    func sceneMoveNaviPush(scene: SCENE_MOVE_PUSH, isAniamtion: Bool = true) -> UIViewController {
        
        let storyboard: UIStoryboard = UIStoryboard(name: SystemManager.instance.GetStoryBoardNameForPush(scene), bundle: nil)
        let uvc = storyboard.instantiateViewController(withIdentifier: scene.rawValue)
        rootCurrentView?.navigationController?.pushViewController(uvc, animated: isAniamtion)
        
        return uvc
    }
    
    func sceneMoveNaviPop(isAnimation: Bool = true) {
        rootCurrentView?.navigationController?.popViewController(animated: isAnimation)
    }
    
    func moveNextScene(dic: [SCENE_MOVE_PUSH : SCENE_MOVE_PUSH]?) {
        if (dic == nil) {
            return
        }
        
        if let _scene = m_finishScenePush {
            for item in dic! {
                if (_scene == item.key) {
                    if (item.key == item.value) {
                        m_finishScenePush = nil
                    }
                    _ = sceneMoveNaviPush(scene: item.value, isAniamtion: false)
                    break
                }
            }
        }
    }
    
    func viewBtnDelete(textField: UITextField!, btnDelete: UIButton!)
    {
        let text = textField.text
        let newLength = text?.count
        
        if (newLength! > 0)
        {
            btnDelete.isHidden = false
        }
        else
        {
            btnDelete.isHidden = true
        }
    }

    func validatedPw(_ pw: String) -> PASSWORD_VAILD_TYPE {
        var lowerCaseLetter: Bool = false
        var upperCaseLetter: Bool = false
        var digit: Bool = false
        var specialCharacter: Bool = false
        
        if (Config.MIN_PASSWORD_LENGTH <= pw.count && pw.count <= Config.MAX_PASSWORD_LENGTH) {
            for char in pw.unicodeScalars {
                if !lowerCaseLetter {
                    lowerCaseLetter = CharacterSet.lowercaseLetters.contains(char)
                }
                if !upperCaseLetter {
                    upperCaseLetter = CharacterSet.uppercaseLetters.contains(char)
                }
                if !digit {
                    digit = CharacterSet.decimalDigits.contains(char)
                }
                if !specialCharacter {
                    specialCharacter = CharacterSet.punctuationCharacters.contains(char)
                }
            }
            if (!lowerCaseLetter) {
                return .alphabet_lower
            }
            else if (!upperCaseLetter) {
                return .alphabet_upper
            }
            else if (!digit) {
                return .digit
            }
            else if (!specialCharacter) {
                return .special
            }
        } else {
            return .length
        }
        return .success
    }
    
    func isValidatedPw(_ pw: String) -> Bool {
        let _vaild = validatedPw(pw)
        
        switch _vaild {
        case .success:
            return true
        default:
            return false
        }
    }
    
    func isVaildatedEmail(text: String) -> Bool {
        let isVal1 : Bool = UI_Utility.isContainString(data: text, character: "@")
        let isVal2 : Bool = UI_Utility.isContainString(data: text, character: ".")
        if (isVal1 && isVal2) {
            return true
        }
        return false
    }
    
    func indicator(_ isEnable: Bool) {
        if (!isEnable) {
            if let _indicator = m_indicator {
                _indicator.stop()
                _indicator.removeFromSuperview()
            }
        }
        else {
            if let _indicator = m_indicator {
                _indicator.stop()
                _indicator.removeFromSuperview()
            }

            let newIndicator: IndicatorView = .fromNib()
            let viewColor = UIColor.gray
            newIndicator.backgroundColor = viewColor.withAlphaComponent(0)
            newIndicator.frame = (rootCurrentView?.view.frame)! // 팝업뷰를 화면크기에 맞추기

            rootCurrentView?.view.addSubview(newIndicator)
            newIndicator.start()
            m_indicator = newIndicator
        }
    }

    func makeCircleSlider(amount: Float, width:CGFloat, diameter:CGFloat, color: UIColor) -> CircleSlider {
        let circleSlider = CircleSlider(frame: CGRect(x: 0, y: 0, width: diameter, height: diameter))
        circleSlider.makeSlider(amount: amount, width: width, diameter: diameter, color: color)
        return circleSlider
    }
    
    func getLabelsInView(view: UIView, arrExclude: [String]?) -> [UILabel] {
        var _arrExclude:[String] = ["lblPopupTitle", "lblPopupSummary", "btnPopupLeft", "btnPopupCenter", "btnPopupRight"]
        if (arrExclude != nil) {
            for item in arrExclude! {
                _arrExclude.append(item)
            }
        }
        
        var results = [UILabel]()
        for subview in view.subviews as [UIView] {
            var _isContinue = false
            for item in _arrExclude {
                if (subview.restorationIdentifier == item) {
                    _isContinue = true
                    break
                }
            }
            
            if (_isContinue) {
                continue
            }
            
            if let labelView = subview as? UILabel {
                results += [labelView]
            } else {
                results += getLabelsInView(view: subview, arrExclude: _arrExclude)
            }
        }
        return results
    }
    
    func getButtonsInView(view: UIView, arrExclude: [String]?) -> [UIButton] {
        var _arrExclude:[String] = ["lblPopupTitle", "lblPopupSummary", "btnPopupLeft", "btnPopupCenter", "btnPopupRight"]
        if (arrExclude != nil) {
            for item in arrExclude! {
                _arrExclude.append(item)
            }
        }
        
        var results = [UIButton]()
        for subview in view.subviews as [UIView] {
            var _isContinue = false
            for item in _arrExclude {
                if (subview.restorationIdentifier == item) {
                    _isContinue = true
                    break
                }
            }
            
            if (_isContinue) {
                continue
            }
            
            if let buttonView = subview as? UIButton {
                results += [buttonView]
            } else {
                results += getButtonsInView(view: subview, arrExclude: _arrExclude)
            }
        }
        return results
    }
    
    func getSwitchInView(view: UIView, arrExclude: [String]?) -> [UISwitch] {
        var _arrExclude = [String]()
        if (arrExclude != nil) {
            for item in arrExclude! {
                _arrExclude.append(item)
            }
        }
        
        var results = [UISwitch]()
        for subview in view.subviews as [UIView] {
            var _isContinue = false
            for item in _arrExclude {
                if (subview.restorationIdentifier == item) {
                    _isContinue = true
                    break
                }
            }
            
            if (_isContinue) {
                continue
            }
            
            if let switchView = subview as? UISwitch {
                results += [switchView]
            } else {
                results += getSwitchInView(view: subview, arrExclude: _arrExclude)
            }
        }
        return results
    }
    
    func oAuthLoginSuccess() {
        if let _view = UIManager.instance.rootCurrentView as? UserSetupNUGUViewController {
            _view.oAuthLoginSuccess()
        }
        if let _view = UIManager.instance.rootCurrentView as? UserSetupAssistantViewController {
            _view.oAuthLoginSuccess()
        }
    }
    
    func getImageInView(view: UIView, arrExclude: [String]?) -> [UIImageView] {
        var _arrExclude = [String]()
        if (arrExclude != nil) {
            for item in arrExclude! {
                _arrExclude.append(item)
            }
        }
        
        var results = [UIImageView]()
        for subview in view.subviews as [UIView] {
            var _isContinue = false
            for item in _arrExclude {
                if (subview.restorationIdentifier == item) {
                    _isContinue = true
                    break
                }
            }
            
            if (_isContinue) {
                continue
            }
            
            if let imageView = subview as? UIImageView {
                results += [imageView]
            } else {
                results += getImageInView(view: subview, arrExclude: _arrExclude)
            }
        }
        return results
    }
    
    func getNotiText(info: DeviceNotiInfo?, isB2BMode: Bool) -> String {
        guard (info != nil) else { return "" }
        
        var _retValue = ""
        if let notiType = info?.notiType {
            switch notiType {
            case .pee_detected:
                if (isB2BMode) {
                    _retValue = "\("notification_diaper_status_diaper_soiled_title".localized)(\("device_sensor_diaper_status_pee".localized))"
                } else {
                    _retValue = "notification_diaper_status_diaper_soiled_title".localized
                }
            case .poo_detected:
                if (isB2BMode) {
                    _retValue = "\("notification_diaper_status_diaper_soiled_title".localized)(\("device_sensor_diaper_status_poo".localized))"
                } else {
                    _retValue = "notification_diaper_status_diaper_soiled_title".localized
                }
            case .abnormal_detected: _retValue = "device_sensor_diaper_status_abnormal_detail".localized
            case .diaper_changed:
                if (Config.channel != .kc) {
                    switch info?.Extra ?? "" {
                    case "2":
                        _retValue = "device_sensor_diaper_status_pee".localized
                    case "3":
                        _retValue = "device_sensor_diaper_status_poo".localized
                    case "4":
                        _retValue = "device_sensor_diaper_status_mixed".localized
                    default:
                        _retValue = "device_sensor_diaper_status_nothing".localized
                    }
                } else {
                    _retValue = "notification_diaper_status_diaper_changed_title".localized
                }
            case .fart_detected: _retValue = "notification_diaper_status_fart_detected_detail".localized
            case .detect_diaper_changed: _retValue = "notification_diaper_status_diaper_changed_title".localized
            case .low_temperature: _retValue = getSpecialProcessing(notiType: notiType, extra: info?.Extra ?? "")
            case .high_temperature: _retValue = getSpecialProcessing(notiType: notiType, extra: info?.Extra ?? "")
            case .low_humidity: _retValue = getSpecialProcessing(notiType: notiType, extra: info?.Extra ?? "")
            case .high_humidity: _retValue = getSpecialProcessing(notiType: notiType, extra: info?.Extra ?? "")
            case .voc_warning: _retValue = "notification_environment_bad_voc_title".localized
            case .low_battery: _retValue = "notification_low_battery_title".localized
            case .disconnected: _retValue = "device_sensor_operation_disconnected".localized
            case .connected: _retValue = "device_sensor_operation_connected".localized
            case .sensor_long_disconnected: _retValue = "device_sensor_operation_disconnected".localized
            case .custom_status:
                if (info?.Extra ?? "" == "10") {
                    _retValue = "\("feedback_none".localized)"
                } else if (info?.Extra ?? "" == "11") {
                    _retValue = "\("feedback_pee".localized)"
                } else if (info?.Extra ?? "" == "12") {
                    _retValue = "\("feedback_poo".localized)"
                }
            case .custom_memo: _retValue = ""
            case .sleep_mode:
                if (info?.Extra ?? "" == "" || info?.Extra ?? "" == "-") {
                    _retValue = "device_sensor_sleeping_elapsed_time".localized
                } else {
                    let _nowUTCTimeDate = UI_Utility.convertStringToDate(info?.Time ?? "700101-000000", type: .yyMMdd_HHmmss)
                    let _infoTimeDate = UI_Utility.convertStringToDate(info?.Extra ?? "700101-000000", type: .yyMMdd_HHmmss)
                    let timeDifference = UI_Utility.getTimeDiff(fromDate: _nowUTCTimeDate!, toDate: _infoTimeDate!)
                    if (timeDifference.hour ?? 0 > 0) {
                        _retValue = "\("notification_sleep_end_for_ios".localized) (\(timeDifference.hour ?? 0)\("time_hour_short".localized)\(timeDifference.minute ?? 0 % 60)\("time_minute_short".localized))"
                    } else {
                        _retValue = "\("notification_sleep_end_for_ios".localized) (\(timeDifference.minute ?? 0)\("time_minute_short".localized))"
                    }
                }
            case .breast_milk:
                var _type = ""
                var _isTotal = false
                if let _total = info?.Extra {
                    if (_total != "-" && _total != "") {
                        _isTotal = true
                        _type = "\(_total)\("time_minute_short".localized)"
                    }
                }
                if (!_isTotal) {
                    var _totalMinute = 0
                    if let _left = info?.m_extra2 {
                        if (_left != "-" && _left != "") {
                            _totalMinute = Int(_left) ?? 0
                        }
                    }
                    if let _right = info?.m_extra3 {
                        if (_right != "-" && _right != "") {
                            _totalMinute += Int(_right) ?? 0
                        }
                    }
                    _type = "\(_totalMinute)\("time_minute_short".localized)"
                }
                
                _retValue = "\("notification_feeding_nursed_breast_milk".localized) (\(_type))"
            case .breast_feeding: _retValue = "\("notification_feeding_bottle_breast_milk".localized) (\(info?.Extra ?? "")ml)"
            case .feeding_milk: _retValue = "\("notification_feeding_bottle_formula_milk".localized) (\(info?.Extra ?? "")ml)"
            case .feeding_meal: _retValue = "\("notification_feeding_baby_food".localized) (\(info?.Extra ?? "")ml)"
            case .diaper_score:
                _retValue = "device_sensor_baby_status_check_diaper_detail".localized
            default: break
            }
        }
        
        return _retValue
    }
    
    func getNotiImage(notiType: DEVICE_NOTI_TYPE, extra: String) -> String {
        var _returnValue = ""
        switch notiType {
        case .pee_detected: _returnValue = "imgDiaperChangeNoneNormalDetail"
        case .poo_detected: _returnValue = "imgDiaperChangeNoneNormalDetail"
        case .abnormal_detected: _returnValue = "imgWarningNormalDetail"
        case .diaper_changed:
            if (Config.channel != .kc) {
                switch extra {
                case "2": _returnValue = "imgDiaperChangePeeNormalDetail"
                case "3": _returnValue = "imgDiaperChangePooNormalDetail"
                case "4": _returnValue = "imgDiaperChangePeePooNormalDetail"
                default: _returnValue = "imgDiaperChangeNoneNormalDetail"
                }
            } else {
                _returnValue = "imgDiaperNormalDetail"
            }
        case .fart_detected: _returnValue = "imgFartNormalDetail"
        case .detect_diaper_changed: _returnValue = "imgDiaperNormalDetail"
        case .low_temperature:
            switch Config.channel {
            case .goodmonit, .kao: _returnValue = "imgTempNormalSimpleDetail"
            case .monitXHuggies: _returnValue = "imgTempNormalSimpleDetail"
            case .kc: _returnValue = "imgKcTempErrorDetail_blue"
            }
        case .high_temperature:
            switch Config.channel {
            case .goodmonit, .kao: _returnValue = "imgTempNormalSimpleDetail"
            case .monitXHuggies: _returnValue = "imgTempNormalSimpleDetail"
            case .kc: _returnValue = "imgKcTempErrorDetail_red"
            }
        case .low_humidity:
            switch Config.channel {
            case .goodmonit, .kao: _returnValue = "imgHumNormalSimpleDetail"
            case .monitXHuggies: _returnValue = "imgHumNormalSimpleDetail"
            case .kc: _returnValue = "imgKcHumErrorDetail"
            }
        case .high_humidity:
            switch Config.channel {
            case .goodmonit, .kao: _returnValue = "imgHumNormalSimpleDetail"
            case .monitXHuggies: _returnValue = "imgHumNormalSimpleDetail"
            case .kc: _returnValue = "imgKcHumErrorDetail"
            }
        case .voc_warning: _returnValue = "imgVocNormalDetail"
        case .low_battery: _returnValue = "imgBattery100"
        case .disconnected: _returnValue = "imgConnectNormalDetail"
        case .connected: _returnValue = "imgConnectNormalDetail"
        case .sleep_mode: _returnValue = "imgNotiSleepModeDetail"
        case .breast_milk: _returnValue = "imgDiaryNotiType_BreastMilk"
        case .breast_feeding: _returnValue = "imgDiaryNotiType_BreastFeeding"
        case .feeding_milk: _returnValue = "imgDiaryNotiType_Milk"
        case .feeding_meal: _returnValue = "imgDiaryNotiType_Meal"
        case .diaper_score: _returnValue = "imgDiaperChangeNoneNormalDetail"
        default:
            break
        }
        
        return _returnValue
    }
    
    func getSpecialProcessing(notiType: DEVICE_NOTI_TYPE, extra: String) -> String {
        var _retValue = ""
        
        if (Config.channel != .kc) {
            switch notiType {
            case .low_temperature: _retValue = "notification_environment_low_temperature_title".localized + " (\(UIManager.instance.getTemperatureProcessingString(value: Double(extra)!)))"
            case .high_temperature: _retValue = "notification_environment_high_temperature_title".localized + " (\(UIManager.instance.getTemperatureProcessingString(value: Double(extra)!)))"
            case .low_humidity: _retValue = "notification_environment_low_humidity_title".localized + " (\(Int(Double(extra)!).description)%%)"
            case .high_humidity: _retValue = "notification_environment_high_humidity_title".localized + " (\(Int(Double(extra)!).description)%%)"
            default: break
            }
        } else {
            switch notiType {
            case .low_temperature: _retValue = "notification_environment_low_temperature_title".localized + " (\(UIManager.instance.getTemperatureProcessingString(value: Double(extra)!)))"
            case .high_temperature: _retValue = "notification_environment_high_temperature_title".localized + " (\(UIManager.instance.getTemperatureProcessingString(value: Double(extra)!)))"
            case .low_humidity: _retValue = "notification_environment_low_humidity_title".localized + " (\(Int(Double(extra)!).description)%%)"
            case .high_humidity: _retValue = "notification_environment_high_humidity_title".localized + " (\(Int(Double(extra)!).description)%%)"
            default: break
            }
        }
        return _retValue
    }
    
    var m_connectionTask: DispatchWorkItem?
    var m_connectionTimer: Timer?
    var m_connectionUpdateTime: Float = 0
    var m_connectionPopup: PopupView?
    var m_hubRegisterType: HUB_TYPES_REGISTER_TYPE = .new
    var m_peripheral: CBPeripheral?
    
    var m_connectHubInfo: HubConnectionController?
    func startConnection(registerType: HUB_TYPES_REGISTER_TYPE, bleInfo: BleInfo?, connectInfo: HubConnectionController?, apName: String, apPw: String, apSecurity: Int, index: Int, peripheral: CBPeripheral? = nil) {
        m_hubRegisterType = registerType
        m_connectHubInfo = connectInfo
        m_peripheral = peripheral
        m_connectionPopup = PopupManager.instance.withProgress(contentsKey: "dialog_contents_hub_ap_connecting".localized, confirmType: .cancle, okHandler: { () -> () in
            self.m_connectionTask?.cancel()
        })
        
        m_connectionTask = DispatchWorkItem {
            self.m_connectionTimer?.invalidate()
            self.m_connectionPopup!.removeFromSuperview()
//            if (Config.channel == .kc) {
                let _param = UIManager.instance.getBoardParam(board: BOARD_TYPE.connect_device_hub, boardId: 26)
                _ = PopupManager.instance.withErrorCode(codeString: "[Code204]", linkURL: "\(Config.BOARD_DEFAULT_URL)\(_param)", contentsKey: "dialog_contents_hub_ap_connection_failed", confirmType: .ok)
//            } else {
//                _ = PopupManager.instance.onlyContents(contentsKey: "dialog_contents_hub_ap_connection_failed", confirmType: .ok)
//            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Config.WIFI_REGIST_WAIT_TIME, execute: m_connectionTask!)
        m_connectionUpdateTime = 0
        self.m_connectionTimer?.invalidate()
        self.m_connectionTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(connectionHubUpdate), userInfo: nil, repeats: true)
        
        if connectInfo != nil {
            bleInfo!.controller!.m_packetCommend?.setHubAp(apName: apName, apPw: apPw, apSecurity: apSecurity, index: index)
        } else {
            Debug.print("[ERROR] connectInfo is null", event: .error)
        }
    }
    
    @objc func connectionHubUpdate() {
        m_connectionUpdateTime += 0.1
        if let _popup = m_connectionPopup {
            _popup.progressValue = m_connectionUpdateTime / Float(Config.WIFI_REGIST_WAIT_TIME)
        }
        
        if let _info = m_connectHubInfo {
            if (_info.m_isFinishWifi) {
                m_connectionTimer!.invalidate()
                m_connectionPopup!.removeFromSuperview()
                m_connectionTask?.cancel()
                
                if (_info.m_isConnectionStatus == 1) {
                    m_connectionPopup?.progressValue = 1
                    if (m_hubRegisterType == .package) {
                        let _vc = UIManager.instance.sceneMoveNaviPush(scene: .deviceRegisterPackageSetInfo) as? DeviceRegisterPackageSetInfoViewController
                        _vc?.m_peripheral = m_peripheral
                    } else {
                        if let _vc = UIManager.instance.sceneMoveNaviPush(scene: .deviceRegisterHubFinish) as? DeviceRegisterHubFinishViewController {
                            _vc.registerType = m_hubRegisterType
                            _vc.hubConnectionController = m_connectHubInfo
                            _vc.did = m_connectHubInfo?.m_device_id ?? 0
                            _vc.enc = m_connectHubInfo?.m_enc ?? ""
                        }
                    }
                }
            }
        } else {
            Debug.print("[ERROR] hub connect info is null", event: .error)
            m_connectionTimer!.invalidate()
            m_connectionPopup!.removeFromSuperview()
            m_connectionTask?.cancel()
        }
    }
    
    var m_connectLampInfo: LampConnectionController?
    func startLampConnection(registerType: HUB_TYPES_REGISTER_TYPE, bleInfo: BleLampInfo?, connectInfo: LampConnectionController?, apName: String, apPw: String, apSecurity: Int, index: Int, peripheral: CBPeripheral? = nil) {
        m_hubRegisterType = registerType
        m_connectLampInfo = connectInfo
        m_peripheral = peripheral
        m_connectionPopup = PopupManager.instance.withProgress(contentsKey: "dialog_contents_lamp_ap_connecting".localized, confirmType: .cancle, okHandler: { () -> () in
            self.m_connectionTask?.cancel()
        })
        
        m_connectionTask = DispatchWorkItem {
            self.m_connectionTimer?.invalidate()
            self.m_connectionPopup!.removeFromSuperview()
//            if (Config.channel == .kc) {
                let _param = UIManager.instance.getBoardParam(board: BOARD_TYPE.connect_device_hub, boardId: 26)
                _ = PopupManager.instance.withErrorCode(codeString: "[Code204]", linkURL: "\(Config.BOARD_DEFAULT_URL)\(_param)", contentsKey: "dialog_contents_hub_ap_connection_failed", confirmType: .ok)
//            } else {
//                _ = PopupManager.instance.onlyContents(contentsKey: "dialog_contents_hub_ap_connection_failed", confirmType: .ok)
//            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Config.WIFI_REGIST_WAIT_TIME, execute: m_connectionTask!)
        m_connectionUpdateTime = 0
        self.m_connectionTimer?.invalidate()
        self.m_connectionTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(connectionLampUpdate), userInfo: nil, repeats: true)
        
        if connectInfo != nil {
            bleInfo!.controller!.m_packetCommend?.setAp(apName: apName, apPw: apPw, apSecurity: apSecurity, index: index)
        } else {
            Debug.print("[ERROR] connectInfo is null", event: .error)
        }
    }
    
    @objc func connectionLampUpdate() {
        m_connectionUpdateTime += 0.1
        if let _popup = m_connectionPopup {
            _popup.progressValue = m_connectionUpdateTime / Float(Config.WIFI_REGIST_WAIT_TIME)
        }
        
        if let _info = m_connectLampInfo {
            if (_info.m_isFinishWifi) {
                m_connectionTimer!.invalidate()
                m_connectionPopup!.removeFromSuperview()
                m_connectionTask?.cancel()
                
                if (_info.m_isConnectionStatus == 1) {
                    m_connectionPopup?.progressValue = 1
                    if let _vc = UIManager.instance.sceneMoveNaviPush(scene: .deviceRegisterLampFinish) as? DeviceRegisterLampFinishViewController {
                        _vc.registerType = m_hubRegisterType
                        _vc.lampConnectionController = m_connectLampInfo
                        _vc.did = m_connectLampInfo?.m_parent?.bleInfo?.m_did ?? 0
                        _vc.enc = m_connectLampInfo?.m_parent?.bleInfo?.m_enc ?? ""
                    }
                }
            }
        } else {
            Debug.print("[ERROR] hub connect info is null", event: .error)
            m_connectionTimer!.invalidate()
            m_connectionPopup!.removeFromSuperview()
            m_connectionTask?.cancel()
        }
    }
    
    // none block
    var activityIndicator: UIActivityIndicatorView?
    func indicatorNoneBlock(isVisiable: Bool) {
        if (activityIndicator != nil) {
            activityIndicator!.removeFromSuperview()
            activityIndicator = nil
        }
        
        if (isVisiable) {
            if let _rootCurrentView = rootCurrentView {
                activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
                activityIndicator!.frame = CGRect(x: _rootCurrentView.view.frame.midX - 25, y: _rootCurrentView.view.frame.midY - 25 , width: 50, height: 50)
                activityIndicator!.hidesWhenStopped = true
                activityIndicator!.startAnimating()
                rootCurrentView?.view.addSubview(activityIndicator!)
            }
        }
    }
    
    func progressView(title: String) -> ProgressView
    {
        let popup: ProgressView = .fromNib()
        let _view = UIManager.instance.rootCurrentView?.view

//        let viewColor = UIColor.gray
//        popup.backgroundColor = viewColor.withAlphaComponent(0.4)
        popup.frame = (_view?.frame)!
        popup.setInit(title: title)
        _view?.addSubview(popup)
        return popup
    }

    var m_bluetoothPopup: PopupView?
    var isWarningDeviceMainBluetooth: Bool {
        get {
            if (Utility.isSimulator) {
                return false
            }
            
            if (!DataManager.instance.m_userInfo.isSignin) {
                return false
            }
            
            if (BleConnectionManager.instance.isStartManager) {
                return false
            }
            
            return DataManager.instance.m_dataController.device.m_sensor.isFoundDisconnectSensor
        }
    }
    
    func isBluetoothPopup() -> Bool {
        if (Utility.isSimulator) {
            return false
        }

        if (!DataManager.instance.m_userInfo.isSignin) {
            return false
        }
        
        if (BleConnectionManager.instance.isStartManager) {
            return false
        }
        
        _ = PopupManager.instance.onlyContents(contentsKey: "toast_need_to_enable_bluetooth_with_err", confirmType: .cancleSetup, okHandler: { () -> () in
            _ = Utility.urlOpen(UIManager.instance.getMoveBluetoothSetting())
        }, existKey: "need_to_enable_bluetooth")
        
        return true
    }
    
    func getMoveBluetoothSetting() -> String {
        #if GOODMONIT
            return UIApplicationOpenSettingsURLString
        #else
            return UIApplicationOpenSettingsURLString
//            return "App-Prefs:root=Bluetooth" // reject
        #endif
    }
    
    func setNaviHeight(identifier: String, view: UIView, height: CGFloat) {
        for _item in view.constraints {
            if let _identifier = _item.identifier {
                if (_identifier == identifier) {
                    _item.constant = height
                    return
                }
            }
        }
        
        for _subItem in view.subviews as [UIView] {
            for _item in _subItem.constraints {
                if let _identifier = _item.identifier {
                    if (_identifier == identifier) {
                        _item.constant = height
                        return
                    }
                }
            }
            setNaviHeight(identifier: identifier, view: _subItem, height: height)
        }
    }
    
    var m_hubFirmwareUpdate: [HubFirmwareUpdateInfo] = []
    var m_lampFirmwareUpdate: [LampFirmwareUpdateInfo] = []
    
    func getTemperatureProcessing(value: Double) -> Double {
        if (UIManager.instance.temperatureUnit == .Celsius) {
            return value
        } else {
            return UI_Utility.celsiusToFahrenheit(tempInC: value)
        }
    }
    
    func getTemperatureProcessingString(value: Double) -> String {
        var _return = 0.0
        if (UIManager.instance.temperatureUnit == .Celsius) {
            _return = value
        } else {
            _return = UI_Utility.celsiusToFahrenheit(tempInC: value)
        }
        _return = Double(floor(10 * _return) / 10)
        return "\(_return)\(UIManager.instance.temperatureUnitStr)"
    }
    
    func hubNaviTitle(type: HUB_TYPES_REGISTER_TYPE) -> String {
        switch type {
        case .new, .package:
            return "title_connection".localized
        case .changeWifi:
            return "setting_wireless_network_change_title".localized
        }
    }
    
    func getPolicyPrivacyURL(type: POLICY_AGREE_TYPE) -> String {
        switch type {
        case .goodmonit_privacy_gdpr:
            return Config.PRIVACY_GDPR_URL
        case .goodmonit_privacy:
            return Config.PRIVACY_URL
        case .huggies_privacy:
            return Config.HUGGIES_PRIVACY_URL
        case .kao_privacy_gdpr:
            return Config.KAO_PRIVACY_GDPR_URL
        case .kao_privacy:
            return Config.KAO_PRIVACY_URL
        default:
            return Config.PRIVACY_URL
        }
    }
    
    func getPolicyServiceURL(type: POLICY_AGREE_TYPE) -> String {
        switch type {
        case .huggies_service:
            return Config.HUGGIES_TERMS_URL
        case .kao_service:
            return Config.KAO_TERMS_URL
        default:
            return Config.TERMS_URL
        }
    }
    
    func getPolicyPrivacyType(isEU: Bool, channel: CHANNEL_TYPE) -> POLICY_AGREE_TYPE {
        switch channel {
        case .monitXHuggies:
            return POLICY_AGREE_TYPE.huggies_privacy
        case .goodmonit:
            if (isEU) {
                return POLICY_AGREE_TYPE.goodmonit_privacy_gdpr
            } else {
                return POLICY_AGREE_TYPE.goodmonit_privacy
            }
        case .kao:
            if (isEU) {
                return POLICY_AGREE_TYPE.kao_privacy_gdpr
            } else {
                return POLICY_AGREE_TYPE.kao_privacy
            }
        default:
            return POLICY_AGREE_TYPE.goodmonit_privacy
        }
    }
    
    func getPolicyServiceType(channel: CHANNEL_TYPE) -> POLICY_AGREE_TYPE {
        switch channel {
        case .monitXHuggies:
            return POLICY_AGREE_TYPE.huggies_service
        case .goodmonit:
            return POLICY_AGREE_TYPE.goodmonit_service
        case .kao:
            return POLICY_AGREE_TYPE.kao_service
        default:
            return POLICY_AGREE_TYPE.goodmonit_service
        }
    }
    
    func getBoardParam(board: BOARD_TYPE, boardId: Int = 0) -> String {
        
        var _retValue = "?board_type=\(board.rawValue)&lang=\(Config.languageType.rawValue)&os=\(Config.OS)&atype=\(Config.channel.rawValue)"
        
        if (boardId != 0) {
            _retValue += "&board_id=\(boardId)"
        }
        return _retValue
    }
    
    func getBoardParamSensorIntoHub() -> String {
        var _retValue = "?board_type=\(BOARD_TYPE.connect_device_hub.rawValue)&lang=\(Config.languageType.rawValue)&os=\(Config.OS)&atype=\(Config.channel.rawValue)"
        switch Config.channel {
        case .goodmonit, .kao:
            _retValue += "&board_id=\(19)"
            break
        case .monitXHuggies:
            _retValue += "&board_id=\(31)"
            break
        case .kc:
            _retValue += "&board_id=\(30)"
            break
        }
        
        return _retValue
    }
    
    func getTimeDiffHourAndMinute(time: Date) -> (Int, Int) {
        let _calendar: Set<Calendar.Component> = [.hour, .minute]
        let difference = NSCalendar.current.dateComponents(_calendar, from: Date(), to: time)
        
        if let _hour = difference.hour, let _min = difference.minute {
            return (_hour, _min)
        }
        return (0, 0)
    }
    
    func getTimeDiffHourAndMinuteAndSecond(time: Date) -> (Int, Int, Int) {
        let _calendar: Set<Calendar.Component> = [.hour, .minute, .second]
        let difference = NSCalendar.current.dateComponents(_calendar, from: Date(), to: time)
        
        if let _hour = difference.hour, let _min = difference.minute, let _second = difference.second {
            return (_hour, _min, _second)
        }
        return (0, 0, 0)
    }
    
    func getTimeDiffSecond(time: Date) -> Int {
        let _calendar: Set<Calendar.Component> = [.second]
        let difference = NSCalendar.current.dateComponents(_calendar, from: Date(), to: time)
        
        if let _second = difference.second {
            return _second
        }
        return 0
    }
    
    func getSensorMovementLevelString(type: SENSOR_MOVEMENT) -> String {
        var _movText = ""
        switch type {
        case .none:
            _movText = "movement_not_moving".localized
        case .level_1:
            _movText = "device_sensor_movement_sleeping".localized
        case .level_2:
            _movText = "device_sensor_movement_crawling".localized
        case .level_3:
            _movText = "device_sensor_movement_running".localized
        }
        return _movText
    }
}

class SleepModeTimer {
    static var isSleepTimer: Bool {
        get {
            if (sleepModeTimeLocal != "") {
                return true
            }
            return false
        }
    }
    
    private static var sleepModeTypeLocal: String {
        get { return Utility.getLocalString(name: "sleepModeType") }
        set { UserDefaults.standard.set(newValue, forKey: "sleepModeType") }
    }
    
    static var sleepModeType: SLEEP_MODE_TYPE {
        get {
            return SLEEP_MODE_TYPE(rawValue: Int(sleepModeTypeLocal) ?? 0) ?? .none
        }
        set {
            sleepModeTypeLocal = newValue.rawValue.description
        }
    }
    
    private static var sleepModeTimeLocal: String {
        get { return Utility.getLocalString(name: "sleepModeTime") }
        set { UserDefaults.standard.set(newValue, forKey: "sleepModeTime") }
    }
    
    static var recordStartSleepModeTime: String {
        get { return Utility.getLocalString(name: "RecordStartSleepModeTime") }
        set { UserDefaults.standard.set(newValue, forKey: "RecordStartSleepModeTime") }
    }
    
    static var recordStopSleepModeTime: String {
        get { return Utility.getLocalString(name: "RecordStopSleepModeTime") }
        set { UserDefaults.standard.set(newValue, forKey: "RecordStopSleepModeTime") }
    }
    
    static func startSleepMode() {
        sleepModeType = .none
        sleepModeTimeLocal = UI_Utility.nowUTCDate(type: .yyMMdd_HHmmss)
        recordStartSleepModeTime = UI_Utility.nowUTCDate(type: .yyMMdd_HHmmss)
        recordStopSleepModeTime = ""
    }
    
    static func stopSleepMode() {
        sleepModeTimeLocal = ""
        recordStopSleepModeTime = UI_Utility.nowUTCDate(type: .yyMMdd_HHmmss)
    }
}

class BreastMilkTimer {
    class Info {
        var direction: BREAST_MILK_DIRECTION_TYPE = .none
        
        init (direction: BREAST_MILK_DIRECTION_TYPE) {
            self.direction = direction
        }
        
        var playType: PLAY_TYPE {
            get {
                let _value = Utility.getLocalString(name: "breastMilkPlayType\(direction.rawValue)")
                return PLAY_TYPE(rawValue: Int(_value) ?? 0) ?? .none
                
            }
            set { UserDefaults.standard.set(newValue.rawValue.description, forKey: "breastMilkPlayType\(direction.rawValue)") }
        }
        
        var restTime: Int {
            get { return Utility.getLocalInt(name: "breastMilkRestTime\(direction.rawValue)") }
            set { UserDefaults.standard.set(newValue, forKey: "breastMilkRestTime\(direction.rawValue)") }
        }
        
        var startTime: String {
            get { return Utility.getLocalString(name: "breastMilkStartTime\(direction.rawValue)") }
            set { UserDefaults.standard.set(newValue, forKey: "breastMilkStartTime\(direction.rawValue)") }
        }
        
        var pauseTime: String {
            get { return Utility.getLocalString(name: "breastMilkPauseTime\(direction.rawValue)") }
            set { UserDefaults.standard.set(newValue, forKey: "breastMilkPauseTime\(direction.rawValue)") }
        }
        
        func playType(playType: PLAY_TYPE) {
            let _prevPlayType = self.playType
            self.playType = playType
            
            switch playType {
            case .none:
                break
            case .ready:
                restTime = 0
                startTime = ""
                pauseTime = ""
            case .start:
                switch _prevPlayType {
                case .pause,
                     .ready:
                    start()
                // start인 상태에서 start가 들어오면 puase로 변경해준다.
                case .start:
                    pause()
                default:
                    break
                }
            case .pause:
                pause()
            case .stop:
                break
            }
        }
        
        func start() {
            if (startTime == "") {
                startTime = UI_Utility.nowUTCDate(type: .yyMMdd_HHmmss)
            } else {
                let _pauseTime = UI_Utility.convertStringToDate(pauseTime, type: .yyMMdd_HHmmss) ?? Date()
                let _diff = UI_Utility.getTimeDiff(fromDate: _pauseTime, toDate: Date())
                self.restTime += _diff.second ?? 0
                self.pauseTime = ""
            }
            
            self.playType = PLAY_TYPE.start
        }
        
        func pause() {
            pauseTime = UI_Utility.nowUTCDate(type: .yyMMdd_HHmmss)
            self.playType = PLAY_TYPE.pause
        }
        
        func getTotalSec() -> Int {
            if (playType == .ready || playType == .none) {
                return 0
            }
            
            if (startTime == "") {
                return 0
            }
            
            let _startDate = UI_Utility.convertStringToDate(startTime, type: .yyMMdd_HHmmss)
            var _pauseDate = ""
            if (pauseTime == "") {
                _pauseDate = UI_Utility.nowUTCDate(type: .yyMMdd_HHmmss)
            } else {
                _pauseDate = pauseTime
            }
            let _endDate = UI_Utility.convertStringToDate(_pauseDate, type: .yyMMdd_HHmmss)
            let _diff = UI_Utility.getTimeDiff(fromDate: _startDate!, toDate: _endDate!)
            let _hour = _diff.hour ?? 0
            let _minute = _diff.minute ?? 0
            let _second = _diff.second ?? 0
            let _totalSec = _hour * 3600 + _minute * 60 + _second - restTime
            return _totalSec
        }
    }
    
    enum PLAY_TYPE: Int {
        case none = 0
        case ready = 1
        case start = 2
        case pause = 3
        case stop = 4
    }
    
    static var leftInfo: Info = Info(direction: .left)
    static var rightInfo: Info = Info(direction: .right)
    
    static var directionType: BREAST_MILK_DIRECTION_TYPE {
        get {
            let _value = Utility.getLocalString(name: "breastMilkDirectionType")
            return BREAST_MILK_DIRECTION_TYPE(rawValue: Int(_value) ?? 0) ?? .none
            
        }
        set { UserDefaults.standard.set(newValue.rawValue.description, forKey: "breastMilkDirectionType") }
    }
    
    static var isUseable: Bool {
        get {
            if (leftInfo.playType == .ready || leftInfo.playType == .start || leftInfo.playType == .pause
                || rightInfo.playType == .ready || rightInfo.playType == .start || rightInfo.playType == .pause) {
                return true
            }
            return false
        }
    }
    
    static var isReadyBoth: Bool {
        get {
            if (leftInfo.playType == .ready && rightInfo.playType == .ready) {
                return true
            }
            return false
        }
    }
    
    static func playType(playType: PLAY_TYPE, directionType: BREAST_MILK_DIRECTION_TYPE) {
        let _prevDirectionType = self.directionType
        let _nextDirectionType = directionType
        self.directionType = directionType
        switch _nextDirectionType {
        case .none:
            leftInfo.playType(playType: playType)
            rightInfo.playType(playType: playType)
        case .left:
            if (_prevDirectionType == .right && rightInfo.playType == .start) {
                rightInfo.playType(playType: .pause)
            }
            leftInfo.playType(playType: playType)
            break
        case .right:
            if (_prevDirectionType == .left && leftInfo.playType == .start) {
                leftInfo.playType(playType: .pause)
            }
            rightInfo.playType(playType: playType)
            break
        }
    }
}

extension String {
    func ToPacketTime() -> Date {
        let formatter = DateFormatter()
        
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        formatter.dateFormat = DATE_TYPE.yyMMdd_HHmmss.rawValue
        return formatter.date(from: self)!
    }
}

extension Date {
    func ToPacketTime() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.dateFormat = DATE_TYPE.yyMMdd_HHmmss.rawValue
        let dateString = dateFormatter.string(from: self)
        return dateString
    }
}

public extension UIAlertController {

    func setMessageAlignment(_ alignment : NSTextAlignment) {
        let paragraphStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        paragraphStyle.alignment = alignment

        let messageText = NSMutableAttributedString(
            string: self.message ?? "",
            attributes: [
                NSAttributedString.Key.paragraphStyle: paragraphStyle,
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12),
                NSAttributedString.Key.foregroundColor: COLOR_TYPE.lblDarkGray.color
            ]
        )

        self.setValue(messageText, forKey: "attributedMessage")
    }
}
