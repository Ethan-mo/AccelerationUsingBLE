//
//  DeviceSetupHubMainTableViewController.swift
//  Monit
//
//  Created by 맥 on 2017. 10. 2..
//  Copyright © 2017년 맥. All rights reserved.
//

import UIKit
import SwiftyJSON

class DeviceSetupHubMainContainViewController: BaseViewController {
    @IBOutlet weak var scView: UIScrollView!
    @IBOutlet weak var stView: UIStackView!

    // device name
    @IBOutlet weak var lblDeviceName: UILabel!
    @IBOutlet weak var btnDeviceName: UIButton!
    @IBOutlet weak var imgDeviceRightArrow: UIImageView!

    // ap info
    @IBOutlet weak var btnApName: UIButton!
    @IBOutlet weak var lblApName: UILabel!
    @IBOutlet weak var imgApRightArrow: UIImageView!
    @IBOutlet weak var lblApDescription: UILabel!

    // temp unit
    @IBOutlet weak var btnTempUnit: UIButton!
    @IBOutlet weak var lblTempUnit: UILabel!
    @IBOutlet weak var imgTempUnitRightArrow: UIImageView!

    // alarm noti off
    @IBOutlet weak var viewAlarmOffInfo: UIView!
    @IBOutlet weak var btnAlarmOffInfo: UIButton!
    @IBOutlet weak var lblAlarmOffStatus: UILabel!
    @IBOutlet weak var lblAlarmOffSummary: UILabel!
    @IBOutlet var conAlarmOff: NSLayoutConstraint!

    // alarm controll
    @IBOutlet weak var lblAlarmMasterTitle: UILabel!
    @IBOutlet weak var viewAlarmInfo: UIView!
    @IBOutlet weak var swMaster: UISwitch!
    @IBOutlet weak var btnTempTitle: UIButton!
    @IBOutlet weak var btnHumTitle: UIButton!
    @IBOutlet weak var imgTempRightArrow: UIImageView!
    @IBOutlet weak var imgHumRightArrow: UIImageView!
    @IBOutlet weak var viewAlarmSub: UIView!
    @IBOutlet var constAlarm: NSLayoutConstraint!
    @IBOutlet weak var viewAlarmLine: UIView!
    @IBOutlet weak var lblTemp: UILabel!
    @IBOutlet weak var lblTempDescription: UILabel!
    @IBOutlet weak var lblHum: UILabel!
    @IBOutlet weak var lblHumDescription: UILabel!
    
    // led
    @IBOutlet weak var lblLedTitle: UILabel!
    @IBOutlet weak var swLed: UISwitch!
    @IBOutlet weak var btnLed: UIButton!
    @IBOutlet weak var lblLed: UILabel!
    @IBOutlet weak var lblLedDescription: UILabel!
    @IBOutlet weak var imgLedRightArrow: UIImageView!
    @IBOutlet weak var conLed: NSLayoutConstraint!
    @IBOutlet weak var viewLedSub: UIView!

    // firmware
    @IBOutlet weak var btnFirmware: UIButton!
    @IBOutlet weak var lblFirmware: UILabel!
    @IBOutlet weak var lblFirmwareDescription: UILabel!
    @IBOutlet weak var imgFirmwareRightArrow: UIImageView!
    @IBOutlet weak var imgFirmwareNewAlarm: UIImageView!

    @IBOutlet weak var viewDeviceLeave: UIView!
    @IBOutlet weak var viewDeviceLeaveLine: UIView!
    @IBOutlet weak var btnDeviceLeave: UIButton!
    @IBOutlet weak var viewDeviceInit: UIView!
    @IBOutlet weak var viewDeviceInitLine: UIView!
    @IBOutlet weak var btnDeviceInit: UIButton!

    @IBOutlet weak var btnSerialTitle: UIButton!
    @IBOutlet weak var lblSeiral: UILabel!
    
    var m_parent: DeviceSetupHubMainViewController?
    
    var m_originFirmwareXPos: CGFloat = 0

    func setUI() {
        setNotiUI()

        setSwAlarmLed(isOn: m_parent!.hubStatusInfo?.isLed ?? false, isAnimation: false)
        
        // set enable ui
//        let _isMaster = m_parent!.m_detailInfo!.m_deviceType == .myDevice
        if (m_originFirmwareXPos == 0) {
            m_originFirmwareXPos = lblFirmware.bounds.origin.x
        }
        UIManager.instance.setContensEnable(isOn: m_parent!.isConnect, orginPosX: m_originFirmwareXPos, btnTitle: btnDeviceName, lblValue: lblDeviceName, imgArrow: imgDeviceRightArrow) // device name
        UIManager.instance.setContensEnable(isOn: true, orginPosX: m_originFirmwareXPos, btnTitle: btnApName, lblValue: lblApName, imgArrow: imgApRightArrow, lblDescription: lblApDescription) // ap info
        UIManager.instance.setContensEnable(isOn: m_parent!.isConnect, orginPosX: m_originFirmwareXPos, btnTitle: btnTempUnit, lblValue: lblTempUnit, imgArrow: imgTempUnitRightArrow) // temp unit
        UIManager.instance.setContentEnableSw(isOn: m_parent!.isConnect, lblTitle: lblAlarmMasterTitle, sw: swMaster)
        UIManager.instance.setContensEnable(isOn: m_parent!.isConnect, orginPosX: m_originFirmwareXPos, btnTitle: btnTempTitle, lblValue: lblTemp, imgArrow: imgTempRightArrow, lblDescription: lblTempDescription) // temp
        UIManager.instance.setContensEnable(isOn: m_parent!.isConnect, orginPosX: m_originFirmwareXPos, btnTitle: btnHumTitle, lblValue: lblHum, imgArrow: imgHumRightArrow, lblDescription: lblHumDescription) // hum
        UIManager.instance.setContensEnable(isOn: m_parent!.isConnect, orginPosX: m_originFirmwareXPos, btnTitle: btnLed, lblValue: lblLed, imgArrow: imgLedRightArrow, lblDescription: lblLedDescription) // led
        UIManager.instance.setContensEnable(isOn: m_parent!.isConnect, orginPosX: m_originFirmwareXPos, btnTitle: btnFirmware, lblValue: lblFirmware, imgArrow: imgFirmwareRightArrow, lblDescription: lblFirmwareDescription) // firmware
        UIManager.instance.setContensEnable(isOn: m_parent!.isConnect, orginPosX: m_originFirmwareXPos, btnTitle: btnSerialTitle, lblValue: lblSeiral, imgArrow: nil) // serial
//        UIManager.instance.setContentEnableForConnect(isOn: m_parent!.isConnect, isMaster: true, orginPosX: m_originFirmwareXPos, btnTitle: btnFirmware, lblValue: lblFirmware, imgArrow: nil) // firmware
        UIManager.instance.setContentEnableSw(isOn: m_parent!.isConnect, lblTitle: lblLedTitle, sw: swLed)
        
        setMasterPage(deviceType: m_parent!.m_detailInfo!.m_deviceType)

        lblDeviceName.text = m_parent!.hubStatusInfo?.m_name ?? ""
        lblApName.text = m_parent!.hubStatusInfo?.m_ap ?? ""
        lblFirmware.text = String(format: "%@ / %@", m_parent!.userInfo?.fwv ?? "", DataManager.instance.m_configData.m_latestHubVersion)
        
        if let _hubStatus = m_parent!.hubStatusInfo {
            let _tempmax = Double(_hubStatus.m_tempmax) / 100.0
            let _tempmaxValue = UIManager.instance.getTemperatureProcessing(value: _tempmax)
            
            let _tempmin = Double(_hubStatus.m_tempmin) / 100.0
            let _tempminValue =  UIManager.instance.getTemperatureProcessing(value: _tempmin)
            
            lblTemp.text = "\(_tempminValue)\(UIManager.instance.temperatureUnitStr) ~ \(_tempmaxValue)\(UIManager.instance.temperatureUnitStr)"
            lblHum.text = "\(_hubStatus.humminValue)% ~ \(_hubStatus.hummaxValue)%"
            lblLed.text = "\(_hubStatus.ledOnTimeStr) ~ \(_hubStatus.ledOffTimeStr)"
        }
        
        imgFirmwareNewAlarm.isHidden = true
        if (m_parent!.isConnect) {
            if (DataManager.instance.m_dataController.newAlarm.hubFirmware.isNewAlarmDetailSetupFirmware(did: m_parent!.m_detailInfo!.m_did)) {
                imgFirmwareNewAlarm.isHidden = false
            }
        }

        btnDeviceName.setTitle("setting_room_name".localized, for: .normal)
        btnApName.setTitle("setting_ap_info_title".localized, for: .normal)
        btnTempUnit.setTitle("device_environment_temperature_unit".localized, for: .normal)
        lblTempUnit.text = UIManager.instance.temperatureUnitStr
        btnAlarmOffInfo.setTitle("setting_device_enable_alarm".localized, for: .normal)
        lblAlarmOffSummary.text = "deviceSetupAlarmOffSummary".localized
        lblAlarmMasterTitle.text = "setting_device_enable_alarm".localized
        btnTempTitle.setTitle("device_environment_temperature".localized, for: .normal)
        btnHumTitle.setTitle("device_environment_humidity".localized, for: .normal)
        lblLedTitle.text = "setting_device_led_light".localized
        btnLed.setTitle("setting_device_led_light_on_time".localized, for: .normal)
        btnFirmware.setTitle("setting_device_firmware_version".localized, for: .normal)
        btnSerialTitle.setTitleWithOutAnimation(title: "setting_device_serial_number".localized)
        lblApDescription.text = "setting_ap_info_title_description".localized
        lblTempDescription.text = "setting_device_environment_temperature_description".localized
        lblHumDescription.text = "setting_device_environment_humidity_description".localized
        lblLedDescription.text = "setting_device_led_light_description".localized
        lblFirmwareDescription.text = "setting_device_firmware_version_description".localized
        lblSeiral.text = m_parent?.userInfo?.srl ?? ""
        
        self.view.layoutIfNeeded()
        
        goToScene()
    }
    
    func goToScene() {
        if (UIManager.instance.m_finishScenePush == .deviceSetupHubFirmware) {
            UIManager.instance.m_finishScenePush = nil
            if (m_parent?.isConnect ?? false) {
                let _view = UIManager.instance.sceneMoveNaviPush(scene: .deviceSetupHubFirmware) as! DeviceSetupHubFirmwareViewController
                _view.m_isForceInit = true
                _view.m_detailInfo = m_parent?.m_detailInfo
            }
        }
    }
    
    func setNotiUI() {
        if (UIManager.instance.isNotificationAuth) {
            if let _almStatus = isAlarmStatus(almType: .all) {
                setSwAlarmMaster(isOn: _almStatus, isAnimation: false)
            }
            viewAlarmOffInfo.isHidden = true
            viewAlarmInfo.isHidden = false
            conAlarmOff.isActive = false
            constAlarm.isActive = true
        } else {
            viewAlarmOffInfo.isHidden = false
            viewAlarmInfo.isHidden = true
            conAlarmOff.isActive = true
            constAlarm.isActive = false
        }
    }
    
    func setMasterPage(deviceType: DEVICE_LIST_TYPE) {
        btnDeviceLeave.setTitle("setting_device_remove".localized, for: .normal)
        btnDeviceInit.setTitle("setting_device_initialize".localized, for: .normal)
        
        viewDeviceLeaveLine.isHidden = true
        viewDeviceLeave.isHidden = true
        viewDeviceInitLine.isHidden = true
        viewDeviceInit.isHidden = true
        
        switch deviceType {
        case .myDevice:
            viewDeviceInitLine.isHidden = false
            viewDeviceInit.isHidden = false
        case .otherDevice:
            viewDeviceLeaveLine.isHidden = false
            viewDeviceLeave.isHidden = false
            viewDeviceInitLine.isHidden = false
            viewDeviceInit.isHidden = false
        default: break
        }
    }
    
    @IBAction func onClick_tempUnit(_ sender: UIButton) {
        let send = Send_SetAppInfo()
        send.aid = DataManager.instance.m_userInfo.account_id
        send.token = DataManager.instance.m_userInfo.token
        send.temunit = DataManager.instance.m_userInfo.configData.getReverseTempUnit
        NetworkManager.instance.Request(send) { (json) -> () in
            let receive = Receive_SetAppInfo(json)
            switch receive.ecd {
            case .success:
                DataManager.instance.m_userInfo.configData.m_tempUnit = DataManager.instance.m_userInfo.configData.getReverseTempUnit
                Widget_Utility.setSharedInfo(channel: Config.channelOsNum, key: .temperatureUnit, value: DataManager.instance.m_userInfo.configData.m_tempUnit)
                
                ScreenAnalyticsManager.instance.googleTagManagerCustom(type: .hub_setting_temperature_scale, items: ["hubid_\(self.m_parent!.m_detailInfo!.m_did)" : "\(DataManager.instance.m_userInfo.configData.m_tempUnit)"])
                UIManager.instance.currentUIReload()
            default:
                Debug.print("[ERROR] Send_SetAppInfo invaild errcod", event: .error)
                let _errStr = String(format: "dialog_contents_err_communication_with_server".localized, APP_ERR_COD.Send_SetAppInfo.rawValue)
                _ = PopupManager.instance.onlyContentsCustom(contents: _errStr, confirmType: .ok)
            }
        }
    }
    
    func setSwAlarmMaster(isOn: Bool, isAnimation: Bool) {
        if (isAnimation) {
            UIView.animate(withDuration: 0.2, animations: {
                self.constAlarm?.constant = (isOn ? 215 : 48)
                self.view!.layoutIfNeeded()
            })
        } else {
            self.constAlarm?.constant = (isOn ? 215 : 48)
            self.view!.layoutIfNeeded()
        }
        viewAlarmSub.isHidden = !isOn
        swMaster.setOn(isOn, animated: false)
    }
    
    func setSwAlarmMasterInfoChange(isOn: Bool) {
        DataManager.instance.m_dataController.userInfo.shareDevice.changeAlarm(did: m_parent!.m_detailInfo!.m_did, type: DEVICE_TYPE.Hub.rawValue, almType: .all, isOn: isOn)
    }
    
    func isAlarmStatus(almType: ALRAM_TYPE) -> Bool? {
        return DataManager.instance.m_userInfo.shareDevice.isAlarmStatus(did: m_parent!.m_detailInfo!.m_did, type: DEVICE_TYPE.Hub.rawValue, almType: almType)
    }
    
    @IBAction func editingChange_master(_ sender: UISwitch) {
        setSwAlarmMaster(isOn: sender.isOn, isAnimation: true)
        setSwAlarmMasterInfoChange(isOn: sender.isOn)
        
        ScreenAnalyticsManager.instance.googleTagManagerCustom(type: .hub_setting_alarm_enabled, items: ["hubid_\(self.m_parent!.m_detailInfo!.m_did)" : "\(sender.isOn ? "true" : "false")"])
    }
    
    @IBAction func onClick_deviceName(_ sender: UIButton) {
        if let _vc = UIManager.instance.sceneMoveNaviPush(scene: .deviceSetupHubDeviceName) as? DeviceSetupHubDeviceNameViewController {
            _vc.m_detailInfo = m_parent!.m_detailInfo
        }
    }
    
    @IBAction func onClick_setAP(_ sender: UIButton) {
        if let _vc = UIManager.instance.sceneMoveNaviPush(scene: .deviceRegisterHubConnecting) as? DeviceRegisterHubConnectingViewController {
            _vc.registerType = .changeWifi
        }
    }
    
    @IBAction func onClick_temp(_ sender: UIButton) {
        let _deviceSetupTemp = UIManager.instance.sceneMoveNaviPush(scene: .deivceSetupHubTemp) as! DeviceSetupHubTempViewController
        _deviceSetupTemp.m_detailInfo = m_parent?.m_detailInfo
    }
    
    @IBAction func onClick_hum(_ sender: UIButton) {
        let _deviceSetupHum = UIManager.instance.sceneMoveNaviPush(scene: .deviceSetupHubHum) as! DeviceSetupHubHumViewController
        _deviceSetupHum.m_detailInfo = m_parent?.m_detailInfo
    }
    
    @IBAction func onClick_firmware(_ sender: UIButton) {
        Debug.print("[HubSetup] onClick_firmware", event: .warning)
        let _view = UIManager.instance.sceneMoveNaviPush(scene: .deviceSetupHubFirmware) as! DeviceSetupHubFirmwareViewController
        _view.m_detailInfo = m_parent?.m_detailInfo

    }
    
    @IBAction func onClick_deviceLeave(_ sender: UIButton) {
        _ = PopupManager.instance.onlyContents(contentsKey: "dialog_contents_remove_device", confirmType: .cancleOK, okHandler: { () -> () in
            self.confirmDeviceLeave()
        })
    }
    
    @IBAction func onClick_deviceInit(_ sender: UIButton) {
        _ = PopupManager.instance.onlyContents(contentsKey: "dialog_contents_initialize_device", confirmType: .cancleOK, okHandler: { () -> () in
            self.confirmDeviceInit()
        })
    }
    
    func confirmDeviceLeave() {
        if let _info = DataManager.instance.m_userInfo.shareMember.getOtherGroupMasterInfoByCloudId(cid: m_parent!.m_detailInfo!.m_cid) {
            let send = Send_LeaveCloud()
            send.aid = DataManager.instance.m_userInfo.account_id
            send.token = DataManager.instance.m_userInfo.token
            send.tid = _info.aid
            NetworkManager.instance.Request(send) { (json) -> () in
                self.receiveLeaveCloud(json)
            }
        } else {
            let _errStr = String(format: "dialog_contents_err_communication_with_server".localized, APP_ERR_COD.Send_LeaveCloud.rawValue)
            _ = PopupManager.instance.onlyContentsCustom(contents: _errStr, confirmType: .ok)
            return
        }
    }
    
    func confirmDeviceInit() {
        deviceInitProgress() // 서버 에러코드 발생시 중단
        
        let send = Send_InitDevice()
        send.aid = DataManager.instance.m_userInfo.account_id
        send.token = DataManager.instance.m_userInfo.token
        send.type = DEVICE_TYPE.Hub.rawValue
        send.did = m_parent!.m_detailInfo!.m_did
        send.enc = m_parent!.userInfo!.enc
        NetworkManager.instance.Request(send) { (json) -> () in
            self.receiveInitDevice(json)
        }
    }
    
    var m_deviceInitPopup: PopupView?
    var m_deviceInitUpdateTime: Double = 0
    var m_deviceInitTimer: Timer?
    func deviceInitProgress() {
        m_deviceInitPopup = PopupManager.instance.withProgress(contentsKey: "dialog_contents_initializing_device".localized, confirmType: .close, okHandler: { () -> () in
        })
        m_deviceInitPopup?.btnCenter.isEnabled = false

        m_deviceInitUpdateTime = 0
        self.m_deviceInitTimer?.invalidate()
        self.m_deviceInitTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(deviceInitProgressUpdate), userInfo: nil, repeats: true)
    }
    
    @objc func deviceInitProgressUpdate() {
        m_deviceInitUpdateTime += 0.1
        if let _popup = m_deviceInitPopup {
            _popup.progressValue = Float(m_deviceInitUpdateTime / Config.HUB_TYPES_INIT_WAIT_TIME)
        }
        
        if (m_deviceInitUpdateTime >= Config.HUB_TYPES_INIT_WAIT_TIME) {
            m_deviceInitTimer!.invalidate()
            m_deviceInitPopup!.removeFromSuperview()
            _ = UIManager.instance.sceneMove(scene: .initView, animation: .coverVertical, isAnimation: false)
        }
    }
    
    func receiveLeaveCloud(_ json: JSON) {
        let receive = Receive_LeaveCloud(json)
        switch receive.ecd {
        case .success:
            DataManager.instance.m_userInfo.deviceNoti.deleteItemByDid(type: DEVICE_TYPE.Hub.rawValue, did: m_parent!.m_detailInfo!.m_did)
            _ = UIManager.instance.sceneMove(scene: .initView, animation: .coverVertical, isAnimation: false)
        case .shareMember_noneGroup:
            _ = PopupManager.instance.onlyContents(contentsKey: "toast_leave_group_failed", confirmType: .ok)
        default:
            Debug.print("[ERROR] Receive_LeaveCloud invaild errcod", event: .error)
            let _errStr = String(format: "dialog_contents_err_communication_with_server".localized, APP_ERR_COD.Send_LeaveCloud.rawValue)
            _ = PopupManager.instance.onlyContentsCustom(contents: _errStr, confirmType: .ok)
        }
    }

    func receiveInitDevice(_ json: JSON) {
        let receive = Receive_InitDevice(json)
        switch receive.ecd {
        case .success:
            DataManager.instance.m_userInfo.deviceNoti.deleteItemByDid(type: DEVICE_TYPE.Hub.rawValue, did: m_parent!.m_detailInfo!.m_did)
            DataManager.instance.m_userInfo.hubGraph.deleteItemByDid(did: m_parent!.m_detailInfo!.m_did)
        default:
            Debug.print("[ERROR] Receive_InitDevice invaild errcod", event: .error)
            m_deviceInitTimer!.invalidate()
            m_deviceInitPopup!.removeFromSuperview()
            
            let _errStr = String(format: "dialog_contents_err_communication_with_server".localized, APP_ERR_COD.Send_InitDevice.rawValue)
            _ = PopupManager.instance.onlyContentsCustom(contents: _errStr, confirmType: .ok)
        }
    }

    @IBAction func onClick_alarmSetting(_ sender: UIButton) {
        _ = Utility.urlOpen(UIApplicationOpenSettingsURLString)
    }
    
    @IBAction func editingChange_led(_ sender: UISwitch) {
        setSwAlarmLed(isOn: sender.isOn, isAnimation: true)
        setSwAlarmLedInfoChange(isOn: sender.isOn)
        
        ScreenAnalyticsManager.instance.googleTagManagerCustom(type: .hub_setting_led_indicator_enabled, items: ["hubid_\(m_parent!.m_detailInfo!.m_did)" : "\(sender.isOn ? "true" : "false")"])
    }
    
    func setSwAlarmLed(isOn: Bool, isAnimation: Bool) {
        if (isAnimation) {
            UIView.animate(withDuration: 0.2, animations: {
                self.conLed?.constant = (isOn ? 129 : 48)
                self.lblLedDescription.isHidden = !isOn
                self.view!.layoutIfNeeded()
            })
        } else {
            self.conLed?.constant = (isOn ? 129 : 48)
            self.lblLedDescription.isHidden = !isOn
            self.view!.layoutIfNeeded()
        }
        viewLedSub.isHidden = !isOn
        swLed.setOn(isOn, animated: false)
    }
    
    func setSwAlarmLedInfoChange(isOn: Bool) {
        m_parent!.hubStatusInfo!.isLed = isOn
        let send = Send_SetLedOnOffTime()
        send.aid = DataManager.instance.m_userInfo.account_id
        send.token = DataManager.instance.m_userInfo.token
        send.type = DEVICE_TYPE.Hub.rawValue
        send.did = m_parent!.m_detailInfo!.m_did
        send.enc = m_parent!.userInfo!.enc
        send.onnt = m_parent!.hubStatusInfo!.m_onnt
        send.offt = m_parent!.hubStatusInfo!.m_offt
        NetworkManager.instance.Request(send) { (json) -> () in
            let receive = Receive_SetLedOnOffTime(json)
            switch receive.ecd {
            case .success: break
            default: Debug.print("[ERROR] Receive_SetLedOnOffTime invaild errcod", event: .error)
            }
        }
    }
    
    @IBAction func onClick_settingLed(_ sender: UIButton) {
        let _vc = UIManager.instance.sceneMoveNaviPush(scene: .deivceSetupHubLed) as? DeviceSetupHubLedViewController
        _vc?.m_detailInfo = m_parent!.m_detailInfo
    }
}
