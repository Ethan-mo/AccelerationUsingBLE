//
//  DeviceRegisterHubLightViewController.swift
//  Monit
//
//  Created by 맥 on 2017. 12. 4..
//  Copyright © 2017년 맥. All rights reserved.
//

import UIKit
import CoreBluetooth

class DeviceRegisterLampLightViewController: BaseViewController {
    @IBOutlet weak var lblNaviTItle: UILabel!
    @IBOutlet weak var lblContentTitle: UILabel!
    @IBOutlet weak var lblContentSummary: UITextView!
    
    @IBOutlet weak var btnConnect: UIButton!
    @IBOutlet weak var imgHowto: UIImageView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    var m_isSearch = false
    var m_task: DispatchWorkItem?
    var m_updateTimerLamp: Timer?
    var m_timeInterval: Double = 0.1
    var m_peripheral: CBPeripheral?
    var m_connectingPopup: PopupView?
    var m_lampTime: Double = 0
    var m_changeWifiAdvName: String? // if registerType is same as changewifi
    var registerType: HUB_TYPES_REGISTER_TYPE = .package
    
    var bleInfo: BleLampInfo? {
        get {
            return DataManager.instance.m_userInfo.connectLamp.getLampByPeripheral(peripheral: m_peripheral)
        }
    }
    
    var findingAdvName: String? {
        get {
            if (registerType == .changeWifi) {
                return m_changeWifiAdvName
            } else {
                return Config.LAMP_ADV_NAME
            }
        }
    }
    
    override func viewDidLoad() {
        isUpdateView = false
        super.viewDidLoad()
        Debug.print("[UI][\(self.classNameToString()).viewDidLoad()]")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUI()
    }
    
    override func reloadInfo() {
        super.reloadInfo()
        Debug.print("[UI][\(self.classNameToString()).reloadInfo()]")
        availableBluetooth()
    }
    
    func setUI() {
        availableBluetooth()
        
        btnConnect.layer.borderColor = COLOR_TYPE.mint.color.cgColor
        btnConnect.layer.borderWidth = 1
        
        animate()
        indicator.isHidden = true
        
        lblNaviTItle.text = UIManager.instance.hubNaviTitle(type: registerType)
        lblContentTitle.text = "connection_lamp_ready_title".localized
        lblContentSummary.text = "connection_lamp_ready_detail_step2".localized
        btnConnect.setTitle("btn_next".localized.uppercased(), for: .normal)
    }
    
    func availableBluetooth() {
        if (!BleConnectionLampManager.instance.isStartManager) {
            _ = PopupManager.instance.onlyContents(contentsKey: "toast_need_to_enable_bluetooth_with_err", confirmType: .ok, okHandler: { () -> () in
                _ = UIManager.instance.sceneMove(scene: .initView, animation: .coverVertical, isAnimation: false)
            }, existKey: "need_to_enable_bluetooth")
        }
    }
    
    func animate()
    {
        var images = [UIImage]()
        images.append(UIImage(named: "imgLampTutorial2_1")!)
        images.append(UIImage(named: "imgLampTutorial2_2")!)
        
        imgHowto.animationImages = images
        imgHowto.animationDuration = 2
        imgHowto.animationRepeatCount = 0
        imgHowto.startAnimating()
    }

    func setIndicator(isVisiable: Bool) {
        if (isVisiable) {
            indicator.isHidden = false
            indicator.startAnimating()
        } else {
            indicator.isHidden = true
            indicator.stopAnimating()
        }
    }
    
    func startConnection() {
        if (UIManager.instance.isBluetoothPopup()) {
            return
        }
        
        if (registerType == .changeWifi) {
            if (bleInfo == nil) {
                let _scene = UIManager.instance.sceneMoveNaviPush(scene: .deviceSetupLampConnecting) as? DeviceSetupLampConnectingViewController
                _scene?.setInit(detailInfo: nil, connectType: .normal)
            } else {
                connectWifi()
            }
            return
        }

        let popup = PopupManager.instance.withLoading(contentsKey: "dialog_contents_scanning".localized, confirmType: .cancle, okHandler: { () -> () in
            self.m_task?.cancel()
            BleConnectionLampManager.instance.stopScan()
        })
        
        m_task = DispatchWorkItem {
            BleConnectionLampManager.instance.stopScan()
            popup.removeFromSuperview()
            
            // 스캔후 기기를 찾음
            if (BleConnectionLampManager.instance.isFindDevice(selectAdvName: self.findingAdvName)) {
                // peripheral으로 연결 진행
                if let _peripheral = BleConnectionLampManager.instance.selectDevice(selectAdvName: self.findingAdvName) {
                    self.m_lampTime = 0
                    self.m_peripheral = _peripheral
                    self.m_updateTimerLamp?.invalidate()
                    self.m_updateTimerLamp = Timer.scheduledTimer(timeInterval: self.m_timeInterval, target: self, selector: #selector(self.lampUpdate), userInfo: nil, repeats: true)
                    self.m_connectingPopup = PopupManager.instance.withLoading(contentsKey: "dialog_contents_scanning".localized, confirmType: .cancle)
                    self.m_connectingPopup?.btnCenter.isEnabled = false
                // peripheral 가져오기 실패
                } else {
                    _ = PopupManager.instance.onlyContents(contentsKey: "dialog_contents_not_detected_all", confirmType: .ok)
                }
            } else {
                _ = PopupManager.instance.onlyContents(contentsKey: "dialog_contents_not_detected_all", confirmType: .ok)
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Config.SENSOR_REGIST_WAIT_TIME, execute: m_task!)
        
        BleConnectionLampManager.instance.startScan()
    }
    
    @objc func lampUpdate() {
        m_lampTime += m_timeInterval
        
        //        Debug.print("DeviceRegisterPackageSensorIntoHubViewController sensorUpdate", event: .dev)
        if (UIManager.instance.rootCurrentView as? DeviceRegisterLampLightViewController == nil) {
            self.m_updateTimerLamp?.invalidate()
        }
        
        if ((m_lampTime > 2.0 && bleInfo == nil) || bleInfo?.controller?.m_status == .connectFail) {
            self.m_updateTimerLamp?.invalidate()
            _ = PopupManager.instance.onlyContents(contentsKey: "device_sensor_disconnected", confirmType: .ok, okHandler: { () -> () in
                _ = UIManager.instance.sceneMove(scene: .initView, animation: .coverVertical, isAnimation: false)
            })
        }
        
        if let _connectDevice = bleInfo {
            if (_connectDevice.controller!.m_status == .connectSuccess && _connectDevice.m_adv.contains(self.findingAdvName ?? "")) {
                if (_connectDevice.m_cid == DataManager.instance.m_userInfo.account_id) {
                    connectWifi()
                } else {
                    disconnectOtherLamp(type: DEVICE_TYPE.Lamp.rawValue, did: _connectDevice.m_did, srl: _connectDevice.m_srl, enc: _connectDevice.m_enc, sid: DataManager.instance.m_userInfo.shareMember.getMyGroupMasterInfo()?.sid ?? "")
                }
                self.m_connectingPopup?.removeFromSuperview()
                self.m_updateTimerLamp?.invalidate()
            }
        }
    }
    
    func connectWifi() {
        if let _connectDevice = bleInfo {
            _connectDevice.controller?.startLampConnection()
            if let _lampCtrl = _connectDevice.controller?.m_lampConnectionController {
                if (_lampCtrl.m_status == .connectSuccess) {
                    if let view = UIManager.instance.sceneMoveNaviPush(scene: .deviceRegisterLampWifi) as? DeviceRegisterLampWifiViewController {
                        view.registerType = registerType
                        view.m_peripheral = m_peripheral
                        view.setInfo(info: LampWifiConnectDetailInfo(lampDid: _lampCtrl.bleInfo?.m_did ?? 0))
                        Debug.print("Move deviceRegisterHubWifi", event: .warning)
                    }
                } else {
                    _ = PopupManager.instance.onlyContents(contentsKey: "connection_hub_put_sensor_detail_step2", confirmType: .ok)
                    DataManager.instance.m_dataController.deviceStatus.deleteLamp(did: self.bleInfo?.m_did ?? 0, adv: self.bleInfo?.m_adv ?? "")
                }
            } else {
                // 허브 컨트롤러 없음 // 기타 에러sensor
                _ = PopupManager.instance.onlyContents(contentsKey: "dialog_contents_not_detected_all", confirmType: .ok)
                DataManager.instance.m_dataController.deviceStatus.deleteLamp(did: self.bleInfo?.m_did ?? 0, adv: self.bleInfo?.m_adv ?? "")
            }
        }
    }
    
    func disconnectOtherLamp(type: Int, did: Int, srl: String, enc: String, sid: String){
            let _popupInfo = PopupDetailInfo()
            let _contents = type == DEVICE_TYPE.Lamp.rawValue ? "dialog_contents_lamp_already_registered".localized : "dialog_contents_lamp_already_registered".localized
        
            _popupInfo.title = type == DEVICE_TYPE.Lamp.rawValue ? "[Code102]" : "[Code202]"
            _popupInfo.contents = "\(_contents)\(sid)"
            _popupInfo.buttonType = .both /// 버튼은 2가지를 선택할 수 있도록
            _popupInfo.left = "btn_device_initialize".localized /// 왼쪽 버튼은 "초기화"
            _popupInfo.right = "btn_ok".localized /// 오른쪽 버튼은 "확인"
            _popupInfo.leftColor = COLOR_TYPE.red.color /// 왼쪽 버튼은 빨간색
            _popupInfo.rightColor = COLOR_TYPE.mint.color /// 오른쪽 버튼은 민트색
            
            _popupInfo.isTitleButton = false
            PopupManager.instance.setDetail(popupDetailInfo: _popupInfo
                                            , okHandler: { () -> () in
                }, cancleHandler: { () -> () in
                self.inputPopup(type: type, did: did, srl: srl, enc: enc, sid: sid)
            })
        }
        /*
        func disconnectOtherLamp(sid: String) {
            _ = PopupManager.instance.onlyContentsCustom(contents: "\("dialog_contents_already_registered_invite_request".localized)\(sid)", confirmType: .close)
            DataManager.instance.m_dataController.deviceStatus.deleteLamp(did: self.bleInfo?.m_did ?? 0, adv: self.bleInfo?.m_adv ?? "")
        }*/
        func inputPopup(type: Int, did: Int, srl: String, enc: String, sid: String){
            var _message = String(format: type == DEVICE_TYPE.Lamp.rawValue ? "dialog_contents_Lamp_already_registered_init".localized : "dialog_contents_Lamp_already_registered_init".localized)
            _message += "\(sid)"
            let alert = UIAlertController(title: "", message: _message, preferredStyle: .alert)
            alert.addTextField { (textField) in
                textField.text = ""
            }
            alert.setMessageAlignment(.left)

            // [초기화] 버튼을 눌렀을 때
            let _action_ok = UIAlertAction(title: "btn_device_initialize".localized, style: .default, handler: { (action: UIAlertAction!) in
                let textField = alert.textFields![0]
                if (textField.text!.count > 0) {
                    if (textField.text!.lowercased() == sid.lowercased()) {
                        self.deviceInit(type: type, did: did, srl: srl, enc: enc)
                    } else {
                        _ = PopupManager.instance.onlyContents(contentsKey: type == DEVICE_TYPE.Lamp.rawValue ? "warning_invalid_short_id" : "warning_invalid_short_id", confirmType: .ok, okHandler: { () -> () in
                            self.inputPopup(type: type, did: did, srl: srl, enc: enc, sid: sid)
                        })
                    }
                } else {
                    self.inputPopup(type: type, did: did, srl: srl, enc: enc, sid: sid)
                }
            })
            _action_ok.setValue(COLOR_TYPE.red.color, forKey: "titleTextColor")
            alert.addAction(_action_ok)

            // [취소]버튼을 눌렀을 때
            let _action_cancle = UIAlertAction(title: "btn_cancel".localized, style: .cancel, handler: { (action: UIAlertAction!) in })
            _action_cancle.setValue(COLOR_TYPE.lblGray.color, forKey: "titleTextColor")
            alert.addAction(_action_cancle)

            self.present(alert, animated: true, completion: nil)
        }
    func deviceInit(type: Int, did: Int, srl: String, enc: String) {
        let send = Send_InitDevice()
        send.aid = DataManager.instance.m_userInfo.account_id
        send.token = DataManager.instance.m_userInfo.token
        send.type = type
        send.did = did
        send.enc = enc
        NetworkManager.instance.Request(send) { (json) -> () in
            let receive = Receive_InitDevice(json)
            switch receive.ecd {
            case .success:
                _ = PopupManager.instance.onlyContents(contentsKey: type == DEVICE_TYPE.Lamp.rawValue ? "toast_lamp_initialize_succeeded".localized : "toast_lamp_initialize_succeeded".localized, confirmType: .ok)
                self.startConnection()
            default: break
            }
        }
    }
    
    @IBAction func onClick_back(_ sender: UIButton) {
        UIManager.instance.sceneMoveNaviPop()
    }
    
    @IBAction func onClick_next(_ sender: UIButton) {
        startConnection()
    }
}
