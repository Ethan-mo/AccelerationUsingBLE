//
//  DeviceSensorDetailSensingView_DiaperChange.swift
//  Monit
//
//  Created by john.lee on 16/08/2019.
//  Copyright © 2019 맥. All rights reserved.
//

import UIKit
import AudioToolbox

class DeviceSensorDetailSensingView_DiaperChange: UIView {
    @IBOutlet weak var stView: UIStackView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblTitleSummary: UILabel!
    @IBOutlet weak var btnDate: UIButton!
    @IBOutlet weak var lblDateTitle: UILabel!
    @IBOutlet weak var lblDateValue: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var viewDateLineShort: UIView!
    @IBOutlet weak var viewDateLineLong: UIView!
    @IBOutlet weak var imgDateArrow: UIImageView!
    @IBOutlet weak var constDate: NSLayoutConstraint!
    
    @IBOutlet weak var btnTime: UIButton!
    @IBOutlet weak var lblTimeTitle: UILabel!
    @IBOutlet weak var lblTimeValue: UILabel!
    @IBOutlet weak var timePicker: UIDatePicker!
    @IBOutlet weak var viewTimeLineShort: UIView!
    @IBOutlet weak var viewTimeLineLong: UIView!
    @IBOutlet weak var imgTimeArrow: UIImageView!
    @IBOutlet weak var constTime: NSLayoutConstraint!
    
    @IBOutlet weak var btnOk: UIButton!
    @IBOutlet weak var btnCancle: UIButton!
    
    @IBOutlet weak var btnStatusPee: UIButton?
    @IBOutlet weak var lblStatusPee: UILabel!
    @IBOutlet weak var btnStatusPoo: UIButton?
    @IBOutlet weak var lblStatusPoo: UILabel!
    @IBOutlet weak var btnStatusPeePoo: UIButton?
    @IBOutlet weak var lblStatusPeePoo: UILabel!
    
    var parent: DeviceSensorDetailSensingBaseViewController?
    var dateValue: String = ""
    var timeValue: String = ""
    
    // only huggies
    var isStatusPee: Bool = false
    var isStatusPoo: Bool = false
    var isStatusPeePoo: Bool = false
    
    override func awakeFromNib() {
        datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        timePicker.addTarget(self, action: #selector(timeChanged(_:)), for: .valueChanged)
        
        lblTitle.text = "dialog_sensor_diaper_changed_date_time".localized
        lblTitleSummary.text = "dialog_sensor_diaper_change_record".localized
        lblStatusPee.text = "device_sensor_diaper_status_pee".localized
        lblStatusPoo.text = "device_sensor_diaper_status_poo".localized
        lblStatusPeePoo.text = "device_sensor_diaper_status_mixed".localized
        btnCancle.setTitle("btn_cancel".localized.uppercased(), for: .normal)
        btnOk.setTitle("btn_ok".localized.uppercased(), for: .normal)
    }

    func setInit(parent :DeviceSensorDetailSensingBaseViewController) {
        self.parent = parent
        setInitUI()
        setUI()
    }
    
    func setInitUI() {
        if (Config.channel != .kc) {
            setStatusInitUI()
        }
    }
    
    func setPopupSize() {
        self.layoutIfNeeded()
        let _x = (UIScreen.main.bounds.width / 2) - (stView.frame.width / 2)
        let _y = (UIScreen.main.bounds.height / 2) - (stView.frame.height / 2)
        self.frame = CGRect(x: _x, y: _y, width: stView.frame.width, height: stView.frame.height)
        UI_Utility.customViewBorder(view: self, radius: 20, width: 1, color: COLOR_TYPE.blue.color.cgColor)
    }
    
    func setUI() {
        initDateUI()
        initTimeUI()
        if (Config.channel != .kc) {
            setStatusUI()
        }
        
        setPopupSize()
    }
    
    func initDateUI() {
        let _strUTCDate = UI_Utility.nowUTCDate(type: .full)
        let _strLocalDate = UI_Utility.UTCToLocal(date: _strUTCDate, fromType: .full, toType: .full)
        let _localDate = UI_Utility.convertStringToLocalDate(_strLocalDate, type: .full)
        
        datePicker.setDate(_localDate!, animated: false)
        setVisiableDate(isOn: false, isAnimation: false)
        
        setDateValue(date: _localDate!)
    }
    
    func initTimeUI() {
        let _strUTCDate = UI_Utility.nowUTCDate(type: .full)
        let _strLocalDate = UI_Utility.UTCToLocal(date: _strUTCDate, fromType: .full, toType: .full)
        let _localDate = UI_Utility.convertStringToLocalDate(_strLocalDate, type: .full)

        timePicker.setDate(_localDate!, animated: false)
        setVisiableTime(isOn: true, isAnimation: false)
        
        setTimeValue(date: _localDate!)
    }
    
    @objc func dateChanged(_ sender: UIDatePicker) {
        setDateValue(date: sender.date)
    }
    
    @objc func timeChanged(_ sender: UIDatePicker) {
        setTimeValue(date: sender.date)
    }
    
    func setDateValue(date: Date) {
        let _dateValue = UI_Utility.getDateByLanguageFromDate(date, language: Config.languageType)
        lblDateValue.text = _dateValue
        
        let components = Calendar.current.dateComponents([.year, .month, .day], from: date)
        if let day = components.day, let month = components.month, let year = components.year {
            let _year = String(year)
            let _month = month.description.count == 1 ? "0\(month.description)" : month.description
            let _day = day.description.count == 1 ? "0\(day.description)" : day.description
            let _index = _year.index(_year.startIndex, offsetBy: 2)
            dateValue = _year[_index...] + _month + _day
        }
    }
    
    func setTimeValue(date: Date) {
        let dateFormatter = DateFormatter()
        switch Config.languageType {
        case .ko:
            dateFormatter.dateFormat = "h:mm a"
            break
        case .jp:
            dateFormatter.dateFormat = "h:mm a"
            break
        case .zh:
            dateFormatter.dateFormat = "h:mm a"
            break
        case .en:
            dateFormatter.dateFormat = "h:mm a"
            break
        default:
            dateFormatter.dateFormat = "h:mm a"
            break
        }
        
        let _dateValue = dateFormatter.string(from: date)
        lblTimeValue.text = _dateValue
        
        let components = Calendar.current.dateComponents([.hour, .minute, .second], from: date)
        if let hour = components.hour, let minute = components.minute, let second = components.second {
            let _hour = hour.description.count == 1 ? "0\(hour.description)" : hour.description
            let _minute = minute.description.count == 1 ? "0\(minute.description)" : minute.description
            let _second = second.description.count == 1 ? "0\(second.description)" : second.description
            
            timeValue = _hour + _minute + _second
        }
    }
    
    func setVisiableDate(isOn: Bool, isAnimation: Bool) {
        if (isAnimation) {
            UIView.animate(withDuration: 0.2, animations: {
                self.constDate?.constant = (isOn ? 155 : 48)
                self.layoutIfNeeded()
                self.setPopupSize()
            })
        } else {
            self.constDate?.constant = (isOn ? 155 : 48)
            self.layoutIfNeeded()
            self.setPopupSize()
        }
        datePicker.isHidden = !isOn
        viewDateLineShort.isHidden = !isOn
//        viewDateLineLong.isHidden = isOn
        imgDateArrow.image = UIImage(named: isOn ? "imgDownArrow" : "imgUpArrow")
    }
    
    func setVisiableTime(isOn: Bool, isAnimation: Bool) {
        if (isAnimation) {
            UIView.animate(withDuration: 0.2, animations: {
                self.constTime?.constant = (isOn ? 155 : 48)
                self.layoutIfNeeded()
                self.setPopupSize()
            })
        } else {
            self.constTime?.constant = (isOn ? 155 : 48)
            self.layoutIfNeeded()
            self.setPopupSize()
        }
        timePicker.isHidden = !isOn
        viewTimeLineShort.isHidden = !isOn
        viewTimeLineLong.isHidden = isOn
        imgTimeArrow.image = UIImage(named: isOn ? "imgDownArrow" : "imgUpArrow")
    }
    
    func setStatusInitUI() {
        setStatusPee(isEnabled: false)
        setStatusPoo(isEnabled: false)
        setStatusPeePoo(isEnabled: false)
    }
    
    func setStatusUI() {
    }

    func setStatusPee(isEnabled: Bool) {
        if (isEnabled) {
            isStatusPee = true
            btnStatusPee?.setImage(UIImage(named: "imgDiaperChangePeeNormalDetail"), for: .normal)
        } else {
            isStatusPee = false
            btnStatusPee?.setImage(UIImage(named: "imgDiaperChangePeeDisableDetail"), for: .normal)
        }
    }

    func setStatusPoo(isEnabled: Bool) {
        if (isEnabled) {
            isStatusPoo = true
            btnStatusPoo?.setImage(UIImage(named: "imgDiaperChangePooNormalDetail"), for: .normal)
        } else {
            isStatusPoo = false
            btnStatusPoo?.setImage(UIImage(named: "imgDiaperChangePooDisableDetail"), for: .normal)
        }
    }
    
    func setStatusPeePoo(isEnabled: Bool) {
        if (isEnabled) {
            isStatusPeePoo = true
            btnStatusPeePoo?.setImage(UIImage(named: "imgDiaperChangePeePooNormalDetail"), for: .normal)
        } else {
            isStatusPeePoo = false
            btnStatusPeePoo?.setImage(UIImage(named: "imgDiaperChangePeePooDisableDetail"), for: .normal)
        }
    }
    
    @IBAction func onClick_date(_ sender: Any) {
        let _isHidden = datePicker.isHidden
        setVisiableDate(isOn: _isHidden, isAnimation: true)
        setVisiableTime(isOn: !_isHidden, isAnimation: false)
    }
    
    @IBAction func onClick_time(_ sender: Any) {
        let _isHidden = timePicker.isHidden
        setVisiableTime(isOn: _isHidden, isAnimation: true)
        setVisiableDate(isOn: !_isHidden, isAnimation: false)
    }
    
    @IBAction func onClick_cancle(_ sender: Any) {
        self.removeFromSuperview()
    }
    
    @IBAction func onClick_ok(_ sender: Any) {
        let _utcDate = UI_Utility.localToUTC(date: "\(dateValue)-\(timeValue)", fromType: .yyMMdd_HHmmss, toType: .yyMMdd_HHmmss)

        let send = Send_SetDiaperChanged()
        send.aid = DataManager.instance.m_userInfo.account_id
        send.token = DataManager.instance.m_userInfo.token
        send.type = DEVICE_TYPE.Sensor.rawValue
        send.did = parent!.m_parent!.m_parent!.m_detailInfo!.m_did
        send.enc = parent!.m_parent!.m_parent!.userInfo!.enc
        send.time = _utcDate
        send.extra = "-"
        if (isStatusPee) {
            send.extra = "2"
        }
        if (isStatusPoo) {
            send.extra = "3"
        }
        if (isStatusPeePoo) {
            send.extra = "4"
        }
        
        NetworkManager.instance.Request(send) { (json) -> () in
            let receive = Receive_SetDiaperChanged(json)
            switch receive.ecd {
            case .success:
                DataManager.instance.m_dataController.device.m_sensor.initDiaper(did: self.parent!.m_parent!.m_parent!.m_detailInfo!.m_did)
                // after noti item
                NotificationManager.instance.playSound()
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
                
                if (Config.channel == .kc) {
                    self.parent?.btnChangeDiaperAnimation()
                } else {
                    _ = PopupManager.instance.onlyContents(contentsKey: "notification_diaper_status_diaper_changed_detail", confirmType: .ok)
                    DataManager.instance.m_dataController.deviceNoti.updateForDetailView()
                }
                break
            default:
                Debug.print("[ERROR] invaild errcod", event: .error)
            }
        }
        self.removeFromSuperview()
    }

    @IBAction func onClick_statusPee(_ sender: UIButton) {
        setStatusPee(isEnabled: !isStatusPee)
        setStatusUI()
        
        if (isStatusPee) {
            setStatusPoo(isEnabled: false)
            setStatusPeePoo(isEnabled: false)
        }
    }
    
    @IBAction func onClick_statusPoo(_ sender: UIButton) {
        setStatusPoo(isEnabled: !isStatusPoo)
        setStatusUI()
        
        if (isStatusPoo) {
            setStatusPee(isEnabled: false)
            setStatusPeePoo(isEnabled: false)
        }
    }
    
    @IBAction func onClick_statusPeePoo(_ sender: UIButton) {
        setStatusPeePoo(isEnabled: !isStatusPeePoo)
        setStatusUI()
        
        if (isStatusPeePoo) {
            setStatusPee(isEnabled: false)
            setStatusPoo(isEnabled: false)
        }
    }
    
}
