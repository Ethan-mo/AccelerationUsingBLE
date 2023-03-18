//
//  DeviceSensorDetailSensingViewController.swift
//  Monit
//
//  Created by 맥 on 2017. 9. 22..
//  Copyright © 2017년 맥. All rights reserved.
//

import UIKit

class DeviceLampDetailSensingViewController: BaseViewController {
    /// monitoring
    @IBOutlet weak var viewMonitoring: UIView!
    @IBOutlet weak var imgTemp: UIImageView!
    @IBOutlet weak var lblTempTitle: UILabel!
    @IBOutlet weak var lblTemp: UILabel!
    @IBOutlet weak var lblTempSymbol: UILabel!
    
    @IBOutlet weak var imgHum: UIImageView!
    @IBOutlet weak var lblHumTitle: UILabel!
    @IBOutlet weak var lblHum: UILabel!
    @IBOutlet weak var lblHumSymbol: UILabel!
    
    @IBOutlet weak var viewStatus: UIView!
    
    /// bright control
    @IBOutlet weak var viewBrightControl: UIView!
    @IBOutlet weak var btnBrightSwitch: UIButton!
    @IBOutlet weak var btnBrightDecrease: UIButton!
    @IBOutlet weak var btnBrightIncrease: UIButton!

    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var btnTimer: UIButton!
    @IBOutlet weak var lblTimer: UILabel!
    @IBOutlet weak var imgClock: UIImageView!
    @IBOutlet weak var lblRestTime: UILabel!
    @IBOutlet weak var lblRestTime2: UILabel!
    @IBOutlet weak var lblRestTimeCenter: UILabel!
    @IBOutlet weak var indicator: UIActivityIndicatorView?
    @IBOutlet weak var viewTimerProgress: UIView!
    
    @IBOutlet weak var viewHubControl: DeviceLampDetailSensingView_LampControl!
    
    /// Status
    @IBOutlet weak var viewStatusConnect: UIView!
    @IBOutlet weak var lblStatusTitle: UILabel!
    @IBOutlet weak var btnOperation: UIButton!
    @IBOutlet weak var lblOperationStatus: UILabel!
    
    var m_parent: DeviceLampDetailPageViewController?
    var m_flow = Flow()
    
    var m_imgTemp: UIImageView!
    var m_lblTempTitle: UILabel!
    var m_lblTemp: UILabel!
    var m_lblTempSymbol: UILabel!
    
    var m_imgHum: UIImageView!
    var m_lblHumTitle: UILabel!
    var m_lblHum: UILabel!
    var m_lblHumSymbol: UILabel!

    override var screenType: SCREEN_TYPE { get { return .HUB_DETAIL_STATUS } }
    var currentCircleSlider: CircleSlider!
    
    var expireTime: Date?
    var timeController = TimerController()
    var isBrightDisplayHidden: Bool = true
    var isBrightAvailable: Bool = false
    var helpMsgBtnCtrl: HelpMessageView?
    var helpMsgCtrlLevel: HelpMessageView?
    var helpMsgCtrlTime: HelpMessageView?
    var isBlankStatus: Bool = true
 
    enum SUMMARY {
        case disconnect
        case nice
        case tempLow
        case tempHigh
        case humLow
        case humHigh
        case voc
    }
    
    var isAvailableBright: Bool {
        get {
            return true
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setInitUI()
        setUI()
    }
 
    func reloadInfoChild() {
        setUI()
        viewHubControl.reloadInfoChild()
    }
    
    func setInitUI() {
        pickerView.delegate = viewHubControl
        pickerView.dataSource = viewHubControl
        viewHubControl.setInit(parent: self)
        
        UI_Utility.customViewBorder(view: viewMonitoring, radius: 20, width: 1, color: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0))
        UI_Utility.customViewBorder(view: viewBrightControl, radius: 20, width: 1, color: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0))
        UI_Utility.customViewBorder(view: viewStatusConnect, radius: 20, width: 1, color: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0))
        
        UI_Utility.customViewShadow(view: viewMonitoring, radius: 20, offsetWidth: 0.1, offsetHeight: 0.1, color: #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1), opacity: 0.2)
        UI_Utility.customViewShadow(view: viewBrightControl, radius: 20, offsetWidth: 0.1, offsetHeight: 0.1, color: #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1), opacity: 0.2)
        UI_Utility.customViewShadow(view: viewStatusConnect, radius: 20, offsetWidth: 0.1, offsetHeight: 0.1, color: #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1), opacity: 0.2)
    }
    
    func setUI() {
        if let _statusInfo = m_parent!.m_parent!.lampStatusInfo {
            let _temp = Double(_statusInfo.m_temp) / 100.0
            let _tempValue = UIManager.instance.getTemperatureProcessing(value: _temp)
            
            m_imgTemp = imgTemp
            m_lblTempTitle = lblTempTitle
            m_lblTemp = lblTemp
            m_lblTempSymbol = lblTempSymbol
            m_imgHum = imgHum
            m_lblHumTitle = lblHumTitle
            m_lblHum = lblHum
            m_lblHumSymbol = lblHumSymbol

            setHum(hum: _statusInfo.hum, value: _statusInfo.humValue)
            setTemp(temp: _statusInfo.temp, value: _tempValue)
            setOperation()
            
            if (!DataManager.instance.m_dataController.device.m_hub.m_brightController.isRunningTimer(did: m_parent?.m_parent?.lampStatusInfo?.m_did ?? 0)) {
            }
            setConnect(isConnect: m_parent!.m_parent!.isConnect)
        }
        
        m_lblTempSymbol.text = UIManager.instance.temperatureUnitStr
        m_lblTempTitle.text = "device_environment_temperature".localized
        m_lblHumTitle.text = "device_environment_humidity".localized
    }
    
    func setTemp(temp: HUB_TYPES_TEMP, value: Double) {
        m_lblTemp.isHidden = false
        m_lblTempSymbol.isHidden = false
        m_lblTempTitle.textColor = COLOR_TYPE.lblGray.color
        m_lblTemp.textColor = COLOR_TYPE.lblDarkGray.color
        
        switch temp {
        case .normal:
            m_imgTemp.image = UIImage(named: "imgTempNormalDetail")
        case .low:
            m_imgTemp.image = UIImage(named: "imgTempErrorDetail")
            m_lblTempTitle.textColor = COLOR_TYPE.red.color
            m_lblTemp.textColor = COLOR_TYPE.red.color
        case .high:
            m_imgTemp.image = UIImage(named: "imgTempErrorDetail")
            m_lblTempTitle.textColor = COLOR_TYPE.red.color
            m_lblTemp.textColor = COLOR_TYPE.red.color
        }
        
        let _value = Double(floor(10 * value) / 10)
        m_lblTemp.text = "\(_value)"
    }
    
    func setHum(hum: HUB_TYPES_HUM, value: Double) {
        m_lblHum.isHidden = false
        m_lblHumSymbol.isHidden = false
        m_lblHumTitle.textColor = COLOR_TYPE.lblGray.color
        m_lblHum.textColor = COLOR_TYPE.lblDarkGray.color
        
        switch hum {
        case .normal:
            m_imgHum.image = UIImage(named: "imgHumNormalDetail")
        case .low,
             .high:
            m_imgHum.image = UIImage(named: "imgHumErrorDetail")
            m_lblHumTitle.textColor = COLOR_TYPE.orange.color
            m_lblHum.textColor = COLOR_TYPE.orange.color
        }
        
        let _value = Double(floor(10 * value) / 10)
        m_lblHum.text = "\(_value)"
    }
     func setOperation() {
           lblOperationStatus.isHidden = false
           lblOperationStatus.textColor = COLOR_TYPE.lblDarkGray.color
           btnOperation.setImage(UIImage(named: "imgConnectNormalDetail"), for: .normal)
           lblOperationStatus.text = "연결되었습니다."
       }

       func setConnect(isConnect: Bool) {
           if (isConnect) {
           } else {
               m_imgTemp.image = UIImage(named: "imgTempDisableDetail")
               m_lblTemp.isHidden = true
               m_lblTempSymbol.isHidden = true
               m_lblTempTitle.textColor = COLOR_TYPE.lblWhiteGray.color
               
               m_imgHum.image = UIImage(named: "imgHumDisableDetail")
               m_lblHum.isHidden = true
               m_lblHumSymbol.isHidden = true
               m_lblHumTitle.textColor = COLOR_TYPE.lblWhiteGray.color
               
               btnOperation.setImage(UIImage(named: "imgConnectDisableDetail"), for: .normal)
               lblOperationStatus.text = "연결이 끊어졌습니다.\n전원 혹은 네트워크 상태를 확인해주세요."
               lblOperationStatus.textColor = COLOR_TYPE.lblGray.color
           }
       }
       
       @IBAction func onClick_Bright_switch(_ sender: UIButton) {
           viewHubControl.onClick_Bright_switch(sender)
       }
       
       @IBAction func onClick_Bright_decrease(_ sender: UIButton) {
           viewHubControl.onClick_Bright_decrease(sender)
       }
       
       @IBAction func onClick_Bright_increase(_ sender: UIButton) {
           viewHubControl.onClick_Bright_increase(sender)
       }
       
       @IBAction func onClick_btnTimer(_ sender: UIButton) {
          viewHubControl.onClick_btnTimer(sender)
       }
}
