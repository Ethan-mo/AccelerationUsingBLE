//
//  DeviceRegisterHubFinishViewController.swift
//  Monit
//
//  Created by 맥 on 2017. 10. 9..
//  Copyright © 2017년 맥. All rights reserved.
//

import UIKit
import SwiftRangeSlider

class DeviceRegisterHubFinishViewController: BaseViewController {
    @IBOutlet weak var lblNaviTitle: UILabel!
    @IBOutlet weak var btnNaviNext: UIButton!
    @IBOutlet weak var lblContentTitle: UIButton!
    @IBOutlet weak var lblContentSummary: UIButton!
    
    @IBOutlet weak var btnOtherConnect: UIButton!

    @IBOutlet weak var imgHubCheckName: UIImageView!
    @IBOutlet weak var txtHubNameTitle: UILabel!
    @IBOutlet weak var txtHubName: UITextField!
    @IBOutlet weak var lblHubNameSub: UILabel!
    @IBOutlet weak var btnHubNameDelete: UIButton!
    
    @IBOutlet weak var imgCheckTempScale: UIImageView!
    @IBOutlet weak var lblTempScaleTitle: UILabel!
    @IBOutlet weak var btnTempScaleC: CustomCheckBox!
    @IBOutlet weak var btnTempScaleF: CustomCheckBox!
    
    @IBOutlet weak var lblTempRangeTitle: UILabel!
    @IBOutlet weak var lblTempRange: UILabel!
    @IBOutlet weak var tempRangeSlider: RangeSlider!
    
    @IBOutlet weak var lblHumRangeTitle: UILabel!
    @IBOutlet weak var lblHumRange: UILabel!
    @IBOutlet weak var humRangeSlider: RangeSlider!

    @IBOutlet weak var scrollViewSetHubInfo: UIStackView!
    
    class NameInfoForm: LabelFormDelegate {
        var txtName: UITextField?
        init (txtName: UITextField) {
            self.txtName = txtName
        }
        
        func setVaildVisible(isVisible: Bool) {
        }
        
        func isCustomVaild() -> Bool? {
            return nil
        }
    }
    
    override var screenType: SCREEN_TYPE { get { return .HUB_REGISTER_SUCCESS } }
    var registerType: HUB_TYPES_REGISTER_TYPE = .new
    
    var m_hubStatusInfo: HubStatusInfo?
    var hubStatusInfo: HubStatusInfo? {
        get {
            if let _info = DataManager.instance.m_userInfo.deviceStatus.m_hubStatus.getInfoByDeviceId(did: hubConnectionController?.m_device_id ?? 0) {
                return _info
            } else {
                return m_hubStatusInfo
            }
        }
    }
    var hubConnectionController: HubConnectionController?
    var did: Int = 0
    var enc: String = ""
    
    var m_hubNameForm: LabelFormController?
    var isEditTemp = false
    var isEditHum = false
    var originTempUnit: String = {
        return DataManager.instance.m_userInfo.configData.m_tempUnit
    }()
    
    override func viewDidLoad() {
        isUpdateView = false
        isKeyboardFrameUp = true
        super.viewDidLoad()
        Debug.print("[UI][\(self.classNameToString()).viewDidLoad()]")
        
        txtHubName.delegate = self
        
        m_hubStatusInfo = HubStatusInfo(did: hubConnectionController?.m_device_id ?? 0, name: "", power: 0, bright: 0, color: 0, attached: 0, temp: 0, hum: 0, voc: 0, ap: "", apse: "", tempmax: 3000, tempmin: 1800, hummax: 6000, hummin: 4000, offt: "0000", onnt: "0000", con: 0, offptime: "", onptime: "")
        
        if (DataManager.instance.m_userInfo.configData.m_tempUnit == "C") {
            btnTempScaleC.isChecked = true
        } else {
            btnTempScaleF.isChecked = true
        }
        
        hubConnectionController?.setCloudId()
        
        setRangeSliderUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUI()
    }
    
    func setUI() {
        if (registerType == .changeWifi) {
            scrollViewSetHubInfo.isHidden = true
        }
        
        lblNaviTitle.text = UIManager.instance.hubNaviTitle(type: registerType)
        btnNaviNext.setTitle("btn_done".localized.uppercased(), for: .normal)
        lblContentTitle.setTitleWithOutAnimation(title: "connection_hub_connected_title".localized + " ")
        if (registerType == .new) {
            lblContentSummary.setTitleWithOutAnimation(title: "connection_hub_connected_detail_with_setting".localized + " ")
        } else {
            lblContentSummary.setImage(UIImage(named: ""), for: .normal)
            lblContentSummary.setTitleWithOutAnimation(title: "connection_hub_connected_detail".localized + " ")
        }
        
        btnOtherConnect.setTitle("connection_connect_other_device".localized.uppercased(), for: .normal)

        UI_Utility.textUnderline(btnOtherConnect.titleLabel)
        
        txtHubNameTitle.text = "setting_room_name".localized
        lblTempScaleTitle.text = "device_environment_temperature_unit".localized
        lblTempRangeTitle.text = "setting_temperature_range".localized
        lblHumRangeTitle.text = "setting_humidity_range".localized
        
//        btnOtherConnect.isHidden = registerType == .changeWifi
        
        if (m_hubNameForm == nil) {
            m_hubNameForm = LabelFormController(txtInput: txtHubName, btnDelete: btnHubNameDelete, minLength: 1, maxLength: 24, imgCheck: imgHubCheckName) // maxLength: Config.MAX_BYTE_LENGTH_NAME
            m_hubNameForm!.setDefaultText(lblDefault: lblHubNameSub, defaultText: "setting_room_name_hint".localized)
            m_hubNameForm!.setDelegate(delegate: NameInfoForm(txtName: txtHubName))
        }
        
        btnTempScaleC.m_onClickHandler = { () -> () in
            self.btnTempScaleC.isChecked = true
            self.btnTempScaleF.isChecked = false
            DataManager.instance.m_userInfo.configData.m_tempUnit = "C"
            self.setRangeSliderUI()
            self.keyboardHide()
        }
        btnTempScaleF.m_onClickHandler = { () -> () in
            self.btnTempScaleC.isChecked = false
            self.btnTempScaleF.isChecked = true
            DataManager.instance.m_userInfo.configData.m_tempUnit = "F"
            self.setRangeSliderUI()
            self.keyboardHide()
        }
    }
    
    func setRangeSliderUI() {
        if let _statusInfo = hubStatusInfo {
            let _tempmin = Double(_statusInfo.m_tempmin) / 100.0
            let _tempminValue =  UIManager.instance.getTemperatureProcessing(value: _tempmin)
            let _tempmax = Double(_statusInfo.m_tempmax) / 100.0
            let _tempmaxValue = UIManager.instance.getTemperatureProcessing(value: _tempmax)
            
            let _hummin = Double(_statusInfo.m_hummin) / 100.0
            let _hummax = Double(_statusInfo.m_hummax) / 100.0
            
            tempRangeSlider.lowerValue = _tempminValue
            tempRangeSlider.upperValue = _tempmaxValue
            humRangeSlider.lowerValue = _hummin
            humRangeSlider.upperValue = _hummax
            
            if (UIManager.instance.temperatureUnit == .Celsius) {
                tempRangeSlider.minimumValue = 10
                tempRangeSlider.maximumValue = 40
            } else {
                tempRangeSlider.minimumValue = UI_Utility.celsiusToFahrenheit(tempInC: 10)
                tempRangeSlider.maximumValue = UI_Utility.celsiusToFahrenheit(tempInC: 40)
            }
            
            let _tempUnit = UIManager.instance.temperatureUnitStr
            lblTempRange.text = "\(Int(_tempminValue))\(_tempUnit) ~ \(Int(_tempmaxValue)) \(_tempUnit)"
            lblHumRange.text = "\(Int(_hummin))% ~ \(Int(_hummax))%"
        }
    }
    
    func needVaildPopup(_ key: String)
    {
        _ = PopupManager.instance.onlyContents(contentsKey: key, confirmType: .ok)
    }
    
    func sendHubName() {
        let send = Send_SetDeviceName()
        send.aid = DataManager.instance.m_userInfo.account_id
        send.token = DataManager.instance.m_userInfo.token
        send.type = DEVICE_TYPE.Hub.rawValue
        send.did = hubConnectionController?.m_device_id ?? 0
        send.enc = hubConnectionController?.m_enc ?? ""
        send.name = Utility.urlEncode(txtHubName.text!)
        NetworkManager.instance.Request(send) { (json) -> () in
            let receive = Receive_SetDeviceName(json)
            switch receive.ecd {
            case .success:
                self.hubStatusInfo!.m_name = self.txtHubName.text!
            default:
                Debug.print("[ERROR] Receive_SetDeviceName invaild errcod", event: .error)
                let _errStr = String(format: "dialog_contents_err_communication_with_server".localized, APP_ERR_COD.Send_SetDeviceName.rawValue)
                _ = PopupManager.instance.onlyContentsCustom(contents: _errStr, confirmType: .ok, okHandler: { () -> () in
                })
            }
        }
    }
    
    func sendTemp() {
        guard (isEditTemp) else { return }
        
        let send = Send_SetAlarmThreshold()
        send.aid = DataManager.instance.m_userInfo.account_id
        send.token = DataManager.instance.m_userInfo.token
        send.type = DEVICE_TYPE.Hub.rawValue
        send.did = hubConnectionController?.m_device_id ?? 0
        send.enc = hubConnectionController?.m_enc ?? ""
        send.tmin = hubStatusInfo!.m_tempmin
        send.tmax = hubStatusInfo!.m_tempmax
        NetworkManager.instance.Request(send) { (json) -> () in
            let receive = Receive_SetAlarmThreshold(json)
            switch receive.ecd {
            case .success: break
            default:
                Debug.print("[ERROR] Send_SetAlarmThreshold invaild errcod", event: .error)
                let _errStr = String(format: "dialog_contents_err_communication_with_server".localized, APP_ERR_COD.Send_SetAlarmThreshold.rawValue)
                _ = PopupManager.instance.onlyContentsCustom(contents: _errStr, confirmType: .ok)
            }
        }
    }
    
    func sendHum() {
        guard (isEditHum) else { return }
        
        let send = Send_SetAlarmThreshold()
        send.aid = DataManager.instance.m_userInfo.account_id
        send.token = DataManager.instance.m_userInfo.token
        send.type = DEVICE_TYPE.Hub.rawValue
        send.did = hubConnectionController?.m_device_id ?? 0
        send.enc = hubConnectionController?.m_enc ?? ""
        send.hmin = hubStatusInfo!.m_hummin
        send.hmax = hubStatusInfo!.m_hummax
        NetworkManager.instance.Request(send) { (json) -> () in
            let receive = Receive_SetAlarmThreshold(json)
            switch receive.ecd {
            case .success: break
            default:
                Debug.print("[ERROR] Send_SetAlarmThreshold invaild errcod", event: .error)
                let _errStr = String(format: "dialog_contents_err_communication_with_server".localized, APP_ERR_COD.Send_SetAlarmThreshold.rawValue)
                _ = PopupManager.instance.onlyContentsCustom(contents: _errStr, confirmType: .ok)
            }
        }
    }
    
    func setTempUnit() {
        guard (DataManager.instance.m_userInfo.configData.m_tempUnit != originTempUnit) else { return }
        
        let send = Send_SetAppInfo()
        send.aid = DataManager.instance.m_userInfo.account_id
        send.token = DataManager.instance.m_userInfo.token
        send.temunit = DataManager.instance.m_userInfo.configData.m_tempUnit
        NetworkManager.instance.Request(send) { (json) -> () in
            let receive = Receive_SetAppInfo(json)
            switch receive.ecd {
            case .success:
                Widget_Utility.setSharedInfo(channel: Config.channelOsNum, key: .temperatureUnit, value: DataManager.instance.m_userInfo.configData.m_tempUnit)
            default:
                Debug.print("[ERROR] Send_SetAppInfo invaild errcod", event: .error)
                let _errStr = String(format: "dialog_contents_err_communication_with_server".localized, APP_ERR_COD.Send_SetAppInfo.rawValue)
                _ = PopupManager.instance.onlyContentsCustom(contents: _errStr, confirmType: .ok)
            }
        }
    }
    
    func keyboardHide() {
        self.view.endEditing(true)
    }
    
    func firmwareUpdate() {
        var _isHubUpdate = false
        let _lastHubVer = DataManager.instance.m_configData.m_latestHubVersion
        if (hubConnectionController?.m_firmware ?? "9.9.9" != "") {
            if (Utility.isUpdateVersion(latestVersion: _lastHubVer, currentVersion: hubConnectionController?.m_firmware ?? "9.9.9")) {
                _isHubUpdate = true
            }
        }
        
        var _isHubForceUpdate = false
        let _lastHubForceVer = DataManager.instance.m_configData.m_latestHubForceVersion
        
        if (hubConnectionController?.m_firmware ?? "9.9.9" != "") {
            if (Utility.isUpdateVersion(latestVersion: _lastHubForceVer, currentVersion: hubConnectionController?.m_firmware ?? "9.9.9")) {
                _isHubForceUpdate = true
            }
        }
        
        #if DEBUG
//                _isHubUpdate = true
//        _isHubForceUpdate = true
        #endif
        
        if (_isHubUpdate) {
            _ = PopupManager.instance.onlyContents(contentsKey: _isHubForceUpdate ? "contents_need_firmware_update_force" : "contents_need_firmware_update", confirmType: _isHubForceUpdate ? .ok : .noYes,
                                                   okHandler: { () -> () in
                                                    let _view = UIManager.instance.sceneMoveNaviPush(scene: .deviceSetupHubFirmware) as? DeviceSetupHubFirmwareViewController
                                                    _view?.m_isForceInit = true
                                                    _view?.m_tmpSrl = self.hubConnectionController?.m_serialNumber ?? ""
                                                    _view?.m_tmpFwv = self.hubConnectionController?.m_firmware ?? ""
                                                    let _detailInfo = DeviceDetailInfo()
                                                    _detailInfo.m_did = self.hubConnectionController?.m_device_id ?? 0
                                                    _view?.m_detailInfo = _detailInfo
            }, cancleHandler: { () -> () in
                _ = UIManager.instance.sceneMove(scene: .initView, animation: .coverVertical, isAnimation: false)
            })
            // (no hub update)
        } else {
            _ = UIManager.instance.sceneMove(scene: .initView, animation: .coverVertical, isAnimation: false)
        }
    }
    
    @IBAction func editing_hubName(_ sender: UITextField) {
        m_hubNameForm?.editing(isTrim: false, isRemoveSpecialChar: true)
    }
    
    @IBAction func onClick_hubNameDelete(_ sender: UIButton) {
        m_hubNameForm?.onClick_delete()
    }

    @IBAction func onClick_otherConnect(_ sender: UIButton) {
        if (registerType == .new) {
            UIManager.instance.setMoveNextScene(finishScenePush: .deviceRegister, moveScene: .initView)
        }
    }
    
    @IBAction func editing_temRangeSlider(_ sender: RangeSlider) {
        isEditTemp = true
        
        hubStatusInfo?.m_tempmin = Int(UIManager.instance.temperatureUnit == .Fahrenheit ? UI_Utility.fahrenheitToCelsius(tempInF: sender.lowerValue) * 100 : sender.lowerValue * 100)
        
        hubStatusInfo?.m_tempmax = Int(UIManager.instance.temperatureUnit == .Fahrenheit ? UI_Utility.fahrenheitToCelsius(tempInF: sender.upperValue) * 100 : sender.upperValue * 100)
        
        setRangeSliderUI()
        keyboardHide()
    }
    
    @IBAction func editing_humRangeSlider(_ sender: RangeSlider) {
        isEditHum = true
        
        hubStatusInfo?.m_hummin = Int(sender.lowerValue * 100.0)
        hubStatusInfo?.m_hummax = Int(sender.upperValue * 100.0)
        setRangeSliderUI()
        keyboardHide()
    }
    
    @IBAction func onClick_Complete(_ sender: UIButton) {
        guard (registerType != .changeWifi) else {
            _ = UIManager.instance.sceneMove(scene: .initView, animation: .coverVertical, isAnimation: false)
            return
        }
        
        guard (m_hubNameForm!.m_isVaild) else {
            needVaildPopup("setting_warning_dialog_room_name")
            return
        }
        
        sendHubName()
        setTempUnit()
        sendTemp()
        sendHum()
        
        self.firmwareUpdate()
    }
    
    @IBAction func onClick_helpHub(_ sender: Any) {
        let _param = UIManager.instance.getBoardParam(board: BOARD_TYPE.connect_device_info, boardId: 22)
        let _scene = UIManager.instance.sceneMoveNaviPush(scene: .customWebView, isAniamtion: false) as! CustomWebViewController
        _scene.setInit(url: "\(Config.BOARD_DEFAULT_URL)\(_param)", naviTitle: "help".localized)
        keyboardHide()
    }
}
