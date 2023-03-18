//
//  DeviceRegisterPackage.swift
//  Monit
//
//  Created by john.lee on 27/08/2019.
//  Copyright © 2019 맥. All rights reserved.
//

import UIKit
import CoreBluetooth

class DeviceRegisterPackageSensorIntoHubViewController: BaseViewController {
    @IBOutlet weak var lblNaviTitle: UILabel!
    @IBOutlet weak var lblTitle: UIButton!
    @IBOutlet weak var lblSummary: VerticalAlignLabel!
    
    @IBOutlet weak var btnStartConnection: UIButton!
    @IBOutlet weak var imgHowto: UIImageView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    override var screenType: SCREEN_TYPE { get { return .SENSOR_REGISTER_READY } }
    var m_isSearch = false
    var m_task: DispatchWorkItem?
    var m_updateTimerSensor: Timer?
    var m_updateTimerHub: Timer?
    var m_timeInterval: Double = 0.1
    var m_peripheral: CBPeripheral?
    var m_connectingPopup: PopupView?
    var m_sensorTime: Double = 0
    var m_hubTime: Double = 0
    var registerType: HUB_TYPES_REGISTER_TYPE = .package
    
    var bleInfo: BleInfo? {
        get {
            return DataManager.instance.m_userInfo.connectSensor.getSensorByPeripheral(peripheral: m_peripheral)
        }
    }
    
    override func viewDidLoad() {
        isUpdateView = false
        m_category = .registerSensor
        super.viewDidLoad()
        Debug.print("[UI][\(self.classNameToString()).viewDidLoad()]")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        availableBluetooth()
        setUI()
    }
    
    override func reloadInfo() {
        super.reloadInfo()
        Debug.print("[UI][\(self.classNameToString()).reloadInfo()]")
        availableBluetooth()
    }
    
    func setUI() {
        btnStartConnection.layer.borderColor = COLOR_TYPE.mint.color.cgColor
        btnStartConnection.layer.borderWidth = 1
        
        animate()
        indicator.isHidden = true
        
        lblNaviTitle.text = UIManager.instance.hubNaviTitle(type: registerType)
        lblTitle.setTitleWithOutAnimation(title: "connection_package_ready_title".localized + " ")
        lblSummary.text = "connection_package_put_sensor_detail".localized
        btnStartConnection.setTitleWithOutAnimation(title: "connection_start_connect".localized.uppercased())
    }
    
    func availableBluetooth() {
        if (!BleConnectionManager.instance.isStartManager) {
            _ = PopupManager.instance.onlyContents(contentsKey: "toast_need_to_enable_bluetooth_with_err", confirmType: .ok, okHandler: { () -> () in
                _ = UIManager.instance.sceneMove(scene: .initView, animation: .coverVertical, isAnimation: false)
            }, existKey: "need_to_enable_bluetooth")
        }
    }
    // 이걸 사용해서 MECS 수정
    func animate()
    {
        var images = [UIImage]()
        images.append(UIImage(named: "imgKcHubTutorial3_1")!)
        images.append(UIImage(named: "imgKcHubTutorial3_2")!)
        images.append(UIImage(named: "imgKcHubTutorial3_3")!)
        images.append(UIImage(named: "imgKcHubTutorial3_4")!)
        
        imgHowto.animationImages = images
        imgHowto.animationDuration = 3
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
    //Ethan 수정내용 #2
    /// Sensor를 검색하고 연결하는 동작을 수행한다.
    /// 여기서 Sensor firmware를 파악해서 MECS의 펌웨어를 갖고 있다면, 수정해준다.
    func startConnection() {
        if (UIManager.instance.isBluetoothPopup()) {
            return
        }
        
        let popup = PopupManager.instance.withLoading(contentsKey: "dialog_contents_scanning".localized, confirmType: .cancle, okHandler: { () -> () in
            self.m_task?.cancel()
            BleConnectionManager.instance.stopScan()
        })
        
        m_task = DispatchWorkItem {
            BleConnectionManager.instance.stopScan()
            popup.removeFromSuperview()
            
            // 스캔후 기기를 찾음
            if (BleConnectionManager.instance.isFindDevice()) {
                // peripheral으로 연결 진행
                if let _peripheral = BleConnectionManager.instance.selectDevice() {
                    self.m_sensorTime = 0
                    self.m_peripheral = _peripheral
                    self.m_updateTimerSensor?.invalidate()
                    self.m_updateTimerSensor = Timer.scheduledTimer(timeInterval: self.m_timeInterval, target: self, selector: #selector(self.sensorUpdate), userInfo: nil, repeats: true)
                    self.m_connectingPopup = PopupManager.instance.withLoading(contentsKey: "dialog_contents_connecting".localized, confirmType: .cancle) 
                    self.m_connectingPopup?.btnCenter.isEnabled = false
                // peripheral 가져오기 실패
                } else {
                    let _param = UIManager.instance.getBoardParam(board: BOARD_TYPE.connect_device_sensor, boardId: 25)
                    _ = PopupManager.instance.withErrorCode(codeString: "[Code100] ", linkURL: "\(Config.BOARD_DEFAULT_URL)\(_param)", contentsKey: "dialog_contents_not_detected_monit", confirmType: .ok)
//                    _ = PopupManager.instance.onlyContents(contentsKey: "dialog_contents_not_detected_monit", confirmType: .ok) // 기존방식으로 사용할 수도 있음
                }
            // 스캔후 기기를 찾지 못함
            } else {
                // 직접 연결된 상태 확인
                let _arrSensor = DataManager.instance.m_userInfo.connectSensor.successConnectSensor
                // 블루투스로 직접 연결된 센서로 허브만 추가진행
                if (_arrSensor.count > 0) {
                    self.m_sensorTime = 0
                    self.m_peripheral = _arrSensor[0].peripheral
                    self.m_updateTimerSensor?.invalidate()
                    self.m_updateTimerSensor = Timer.scheduledTimer(timeInterval: self.m_timeInterval, target: self, selector: #selector(self.sensorUpdate), userInfo: nil, repeats: true)
                    self.m_connectingPopup = PopupManager.instance.withLoading(contentsKey: "dialog_contents_connecting".localized, confirmType: .cancle)
                    self.m_connectingPopup?.btnCenter.isEnabled = false
                // 불루투스로 직접 연결된 센서가 없음,
                } else {
                    var _isMySensorFound = false
                    if let _myDevice = DataManager.instance.m_userInfo.shareDevice.myGroup {
                        for item  in _myDevice {
                            if (item.type == DEVICE_TYPE.Sensor.rawValue) {
                                _isMySensorFound = true
                            }
                        }
                    }
                    // 블루투스 연결은 아니나 & 이미 연결한 기기가 있음 (직접 연결되지 않은 상태)
                    if (_isMySensorFound) {
                        let _param = UIManager.instance.getBoardParamSensorIntoHub()
                        _ = PopupManager.instance.withErrorCode(codeString: "[Code200] ", linkURL: "\(Config.BOARD_DEFAULT_URL)\(_param)", contentsKey: "connection_hub_put_sensor_detail_step2", confirmType: .ok)
//                        _ = PopupManager.instance.onlyContents(contentsKey: "connection_hub_put_sensor_detail_step2", confirmType: .ok)
                    // 이미 연결한 기기도 없음
                    } else {
                        BleConnectionManager.instance.sendLog()
                        // 다시 검색 하겠냐는 메시지 출력
                        if (!self.m_isSearch) {
                            self.m_isSearch = true
                            let _param = UIManager.instance.getBoardParam(board: BOARD_TYPE.connect_device_sensor, boardId: 25)
                            _ = PopupManager.instance.withErrorCode(codeString: "[Code100] ", linkURL: "\(Config.BOARD_DEFAULT_URL)\(_param)", contentsKey: "dialog_contents_not_detected_monit", confirmType: .cancleRetry, okHandler: { () -> () in
                                self.startConnection()
                            })
//                            _ = PopupManager.instance.onlyContents(contentsKey: "dialog_contents_not_detected_monit", confirmType: .cancleRetry, okHandler: { () -> () in // 기존방식으로 사용할 수도 있음
//                                self.startConnection()
//                            })
                        // 검색된 기기 없음 메시지 출력
                        } else {
                            self.m_isSearch = false
                            let _param = UIManager.instance.getBoardParam(board: BOARD_TYPE.connect_device_sensor, boardId: 25)
                            _ = PopupManager.instance.withErrorCode(codeString: "[Code100] ", linkURL: "\(Config.BOARD_DEFAULT_URL)\(_param)", contentsKey: "dialog_contents_not_detected_monit", confirmType: .ok) // 기존방식으로 사용할 수도 있음
//                            _ = PopupManager.instance.onlyContents(contentsKey: "dialog_contents_not_detected_monit", confirmType: .ok)
                        }
                    }
                }
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Config.SENSOR_REGIST_WAIT_TIME, execute: m_task!)
        
        BleConnectionManager.instance.startScan()
    }
    
    @objc func sensorUpdate() {
        m_sensorTime += m_timeInterval
        
//        Debug.print("DeviceRegisterPackageSensorIntoHubViewController sensorUpdate", event: .dev)
        if (UIManager.instance.rootCurrentView as? DeviceRegisterPackageSensorIntoHubViewController == nil) {
            self.m_updateTimerSensor?.invalidate()
        }
        
        if ((m_sensorTime > 2.0 && bleInfo == nil) || bleInfo?.controller?.m_status == .connectFail) {
            self.m_updateTimerSensor?.invalidate()
            let _param = UIManager.instance.getBoardParam(board: BOARD_TYPE.connect_device_sensor, boardId: 28)
            _ = PopupManager.instance.withErrorCode(codeString: "[Code101] ", linkURL: "\(Config.BOARD_DEFAULT_URL)\(_param)", contentsKey: "device_sensor_disconnected", confirmType: .ok, okHandler: { () -> () in
                _ = UIManager.instance.sceneMove(scene: .initView, animation: .coverVertical, isAnimation: false)
            })
//            _ = PopupManager.instance.onlyContents(contentsKey: "device_sensor_disconnected", confirmType: .ok, okHandler: { () -> () in
//                _ = UIManager.instance.sceneMove(scene: .initView, animation: .coverVertical, isAnimation: false)
//            })
        }
        
        if let _connectSensor = bleInfo {
            if (_connectSensor.controller!.m_status == .connectSuccess) {
                if (_connectSensor.m_cid == DataManager.instance.m_userInfo.account_id) {
                    connectSensorForHub()
                } else {
                    disconnectOtherSensor(type: DEVICE_TYPE.Sensor.rawValue, did: _connectSensor.m_did, srl: _connectSensor.m_srl, enc: _connectSensor.m_enc, sid: DataManager.instance.m_userInfo.shareMember.getMyGroupMasterInfo()?.sid ?? "") // 내 sid를 보여줌.
                    self.m_connectingPopup?.removeFromSuperview()
                }
                self.m_updateTimerSensor?.invalidate()
            }
        }
    }
    
    func connectSensorForHub() {
        if let _connectSensor = bleInfo {
            _connectSensor.controller?.startHubConnection() // once
        }
        
        self.m_hubTime = 0
        self.m_updateTimerHub?.invalidate()
        self.m_updateTimerHub = Timer.scheduledTimer(timeInterval: self.m_timeInterval, target: self, selector: #selector(self.hubUpdate), userInfo: nil, repeats: true)
    }
    
    @objc func hubUpdate() {
        m_hubTime += m_timeInterval
        
        if (UIManager.instance.rootCurrentView as? DeviceRegisterPackageSensorIntoHubViewController == nil) {
            self.m_updateTimerHub?.invalidate()
        }
        
        if (m_hubTime > 1.0) {
            if let _connectSensor = bleInfo {
                if let _hubCtrl = _connectSensor.controller?.m_hubConnectionController {
                    if (_hubCtrl.m_status == .connectSuccess) {
                        let _isAlready = DataManager.instance.m_userInfo.shareMember.getOtherGroupMasterInfoByCloudId(cid: _hubCtrl.m_cloud_id) != nil ? true : false
                        if (_hubCtrl.m_cloud_id == DataManager.instance.m_userInfo.account_id || _isAlready) {
                            if let view = UIManager.instance.sceneMoveNaviPush(scene: .deviceRegisterHubWifi) as? DeviceRegisterHubWifiViewController {
                                view.registerType = registerType
                                view.m_peripheral = m_peripheral
                                view.setInfo(info: WifiConnectDetailInfo(sensorDid: _hubCtrl.bleInfo?.m_did ?? 0, hubDid: _hubCtrl.m_device_id))
                                Debug.print("Move deviceRegisterHubWifi", event: .warning)
                            }
                        } else {
                            disconnectOtherSensor(type: DEVICE_TYPE.Hub.rawValue, did: _hubCtrl.m_device_id, srl: _hubCtrl.m_serialNumber, enc: _hubCtrl.m_enc, sid: DataManager.instance.m_userInfo.shareMember.getMyGroupMasterInfo()?.sid ?? "") // 내 sid를 보여줌
                        }
                    } else {
                        // 20초 초과, 연결실패, 센서 허브에 꼽혀있지 않을시
                        if (m_hubTime > 20.0 || _hubCtrl.m_status == .connectFail || !_hubCtrl.isHubConnectCheck) {
                            let _param = UIManager.instance.getBoardParamSensorIntoHub()
                            _ = PopupManager.instance.withErrorCode(codeString: "[Code200] ", linkURL: "\(Config.BOARD_DEFAULT_URL)\(_param)", contentsKey: "connection_hub_put_sensor_detail_step2", confirmType: .ok)
                            //                        _ = PopupManager.instance.onlyContents(contentsKey: "connection_hub_put_sensor_detail_step2", confirmType: .ok)
                            DataManager.instance.m_dataController.deviceStatus.deleteSensor(did: self.bleInfo?.m_did ?? 0, adv: self.bleInfo?.m_adv ?? "")
                        } else {
                            return
                        }
                    }
                } else {
                    // 허브 컨트롤러 없음 // 기타 에러
                    let _param = UIManager.instance.getBoardParam(board: BOARD_TYPE.connect_device_sensor, boardId: 25)
                    _ = PopupManager.instance.withErrorCode(codeString: "[Code100] ", linkURL: "\(Config.BOARD_DEFAULT_URL)\(_param)", contentsKey: "dialog_contents_not_detected_monit", confirmType: .ok)
//                    _ = PopupManager.instance.onlyContents(contentsKey: "dialog_contents_not_detected_monit", confirmType: .ok)
                    DataManager.instance.m_dataController.deviceStatus.deleteSensor(did: self.bleInfo?.m_did ?? 0, adv: self.bleInfo?.m_adv ?? "")
                }
            } else {
                // 갑자기 센서 연결 끊어짐 // 기타 에러
                let _param = UIManager.instance.getBoardParam(board: BOARD_TYPE.connect_device_sensor, boardId: 25)
                _ = PopupManager.instance.withErrorCode(codeString: "[Code100] ", linkURL: "\(Config.BOARD_DEFAULT_URL)\(_param)", contentsKey: "dialog_contents_not_detected_monit", confirmType: .ok)
//                _ = PopupManager.instance.onlyContents(contentsKey: "dialog_contents_not_detected_monit", confirmType: .ok)
            }
            self.m_updateTimerHub?.invalidate()
            self.m_connectingPopup?.removeFromSuperview()
        }
    }
    
    // 패키지 연결은 시리얼로 작업되어 있음 (kc만 사용중이므로)
    func disconnectOtherSensor(type: Int, did: Int, srl: String, enc: String, sid: String) {
        let _popupInfo = PopupDetailInfo()
        let _contents = type == DEVICE_TYPE.Sensor.rawValue ? "dialog_contents_sensor_already_registered".localized : "dialog_contents_hub_already_registered".localized
        _popupInfo.title = type == DEVICE_TYPE.Sensor.rawValue ? "[Code102] " : "[Code202] "
        _popupInfo.contents = "\(_contents)\(sid)"
        _popupInfo.buttonType = .both
        _popupInfo.left = "btn_device_initialize".localized
        _popupInfo.right = "btn_ok".localized
        _popupInfo.leftColor = COLOR_TYPE.red.color
        _popupInfo.rightColor = COLOR_TYPE.mint.color
        _popupInfo.isTitleButton = true
        let _param = type == DEVICE_TYPE.Sensor.rawValue ? UIManager.instance.getBoardParam(board: BOARD_TYPE.connect_device_sensor, boardId: 24) : UIManager.instance.getBoardParam(board: BOARD_TYPE.connect_device_hub, boardId: 27)
        _popupInfo.titleLinkUrl = "\(Config.BOARD_DEFAULT_URL)\(_param)"
        _ = PopupManager.instance.setDetail(popupDetailInfo: _popupInfo
        , okHandler: { () -> () in
            DataManager.instance.m_dataController.deviceStatus.deleteSensor(did: self.bleInfo?.m_did ?? 0, adv: self.bleInfo?.m_adv ?? "")
        }, cancleHandler: { () -> () in
            self.inputPopup(type: type, did: did, srl: srl, enc: enc)
        })
    }
    
    func inputPopup(type: Int, did: Int, srl: String, enc: String) {
        let _message = String(format: type == DEVICE_TYPE.Sensor.rawValue ? "dialog_contents_sensor_initialize_with_serialnumber".localized : "dialog_contents_hub_initialize_with_serialnumber".localized)
        let alert = UIAlertController(title: "", message: _message, preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.text = ""
            //textField.placeholder = "group_invite_member_hint".localized
        }
        alert.setMessageAlignment(.left)
        
        let _action_ok = UIAlertAction(title: "btn_device_initialize".localized, style: .default, handler: { (action: UIAlertAction!) in
            let textField = alert.textFields![0] // Force unwrapping because we know it exists.
            if (textField.text!.count > 0) {
                let send = Send_AvailableSerialNumber()
                send.aid = DataManager.instance.m_userInfo.account_id
                send.token = DataManager.instance.m_userInfo.token
                send.type = type
                send.did = did
                send.srl = textField.text!
                NetworkManager.instance.Request(send) { (json) -> () in
                    let receive = Receive_AvailableSerialNumber(json)
                    switch receive.ecd {
                    case .success: self.deviceInit(type: type, did: did, srl: srl, enc: enc)
                    case .available_serial_number:
                        _ = PopupManager.instance.onlyContents(contentsKey: type == DEVICE_TYPE.Sensor.rawValue ? "toast_sensor_initialize_wrong_serialnumber" : "toast_hub_initialize_wrong_serialnumber", confirmType: .ok, okHandler: { () -> () in
                            self.inputPopup(type: type, did: did, srl: srl, enc: enc)
                        })
                    default: Debug.print("[ERROR] invaild errcod", event: .error)
                    }
                }
            } else {
                DataManager.instance.m_dataController.deviceStatus.deleteSensor(did: self.bleInfo?.m_did ?? 0, adv: self.bleInfo?.m_adv ?? "")
            }
        })
        _action_ok.setValue(COLOR_TYPE.red.color, forKey: "titleTextColor")
        alert.addAction(_action_ok)
        
        let _action_cancle = UIAlertAction(title: "btn_cancel".localized, style: .cancel, handler: { (action: UIAlertAction!) in
            DataManager.instance.m_dataController.deviceStatus.deleteSensor(did: self.bleInfo?.m_did ?? 0, adv: self.bleInfo?.m_adv ?? "")
        })
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
                _ = PopupManager.instance.onlyContents(contentsKey: type == DEVICE_TYPE.Sensor.rawValue ? "toast_sensor_initialize_succeeded" : "toast_hub_initialize_succeeded", confirmType: .ok)
            default: break
            }
            DataManager.instance.m_dataController.deviceStatus.deleteSensor(did: self.bleInfo?.m_did ?? 0, adv: self.bleInfo?.m_adv ?? "")
        }
    }
    
    @IBAction func onClick_back(_ sender: UIButton) {
        UIManager.instance.sceneMoveNaviPop()
    }
    
    @IBAction func onClick_next(_ sender: UIButton) {
        startConnection()
    }
    
    @IBAction func onClick_help(_ sender: Any) {
        let _param = UIManager.instance.getBoardParamSensorIntoHub()
        let _scene = UIManager.instance.sceneMoveNaviPush(scene: .customWebView, isAniamtion: false) as! CustomWebViewController
        _scene.setInit(url: "\(Config.BOARD_DEFAULT_URL)\(_param)", naviTitle: "help".localized)
    }
}
