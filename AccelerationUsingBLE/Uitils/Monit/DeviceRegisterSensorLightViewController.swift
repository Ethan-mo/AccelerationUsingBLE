//
//  DeviceRegisterSensorLightViewController.swift
//  Monit
//
//  Created by 맥 on 2017. 12. 1..
//  Copyright © 2017년 맥. All rights reserved.
//

import UIKit
import CoreBluetooth

class DeviceRegisterSensorLightViewController: BaseViewController {
    @IBOutlet weak var lblNaviTitle: UILabel!
    @IBOutlet weak var lblTitle: UIButton!
    @IBOutlet weak var lblSummary: UITextView!
    
    @IBOutlet weak var btnStartConnection: UIButton!
    @IBOutlet weak var imgHowto: UIImageView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    override var screenType: SCREEN_TYPE { get { return .SENSOR_REGISTER_READY } }
    var m_isSearch = false
    var m_task: DispatchWorkItem?
    var m_updateTimer: Timer?
    var m_timeInterval: Double = 0.1
    var m_peripheral: CBPeripheral?
    var m_connectingPopup: PopupView?
    var error_connectingPopup: PopupView?
    var m_time: Double = 0
    
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
        
        if (Config.channel == .kc) {
            animateKc()
        } else {
            animate()
        }
        
        indicator.isHidden = true
        
        lblNaviTitle.text = "title_connection".localized
        lblTitle.setTitleWithOutAnimation(title: "connection_monit_sensor_ready_title".localized + " ")
        lblSummary.text = "connection_monit_sensor_ready_detail_step2".localized
        btnStartConnection.setTitle("connection_start_connect".localized.uppercased(), for: .normal)
    }
    
    func availableBluetooth() {
        if (!BleConnectionManager.instance.isStartManager) {
            _ = PopupManager.instance.onlyContents(contentsKey: "toast_need_to_enable_bluetooth_with_err", confirmType: .ok, okHandler: { () -> () in
                _ = UIManager.instance.sceneMove(scene: .deviceRegisterNavi, animation: .coverVertical, isAnimation: false)
            }, existKey: "need_to_enable_bluetooth")
        }
    }
    
    func animate()
    {
        var images = [UIImage]()
        images.append(UIImage(named: "imgSensorTutorial2_1")!)
        images.append(UIImage(named: "imgSensorTutorial2_2")!)
        
        imgHowto.animationImages = images
        imgHowto.animationDuration = 2
        imgHowto.animationRepeatCount = 0
        imgHowto.startAnimating()
    }
    
    func animateKc()
      {
          var images = [UIImage]()
          images.append(UIImage(named: "imgKcSensorTutorial2_1")!)
          images.append(UIImage(named: "imgKcSensorTutorial2_2")!)
          
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
                    self.m_time = 0
                    self.m_peripheral = _peripheral
                    self.m_updateTimer?.invalidate()
                    self.m_updateTimer = Timer.scheduledTimer(timeInterval: self.m_timeInterval, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
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
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Config.SENSOR_REGIST_WAIT_TIME, execute: m_task!)
        
        BleConnectionManager.instance.startScan()
    }
    
    @objc func update() {
        m_time += m_timeInterval
        
        Debug.print("DeviceRegisterSensorLightViewController update", event: .dev)
        if (UIManager.instance.rootCurrentView as? DeviceRegisterSensorLightViewController == nil) {
            self.m_updateTimer?.invalidate()
        }
        
        if ((m_time > 2.0 && bleInfo == nil) || bleInfo?.controller?.m_status == .connectFail) {
            self.m_updateTimer?.invalidate()
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
                    if(_connectSensor.m_firmware == "1.0.0"){
                        Debug.print("[⚪️][⚪️][⚪️][⚪️][⚪️]")
                        self.error_connectingPopup = PopupManager.instance.withTitleCustom(title: "[Error]", contents: "do_not_firmware_update".localized, confirmType: .cancleOK, okHandler: {() -> () in
                            _ = Utility.urlOpen("itms-apps://itunes.apple.com/app/id1562270067")
                        },cancleHandler:{() -> () in
                            _ = UIManager.instance.sceneMove(scene:.initView, animation:.coverVertical, isAnimation: false)
                        })
                        
                    }else{
                    let _babyView = UIManager.instance.sceneMoveNaviPush(scene: .deviceRegisterSensorBaby) as! DeviceRegisterSensorBabyViewController
                        _babyView.m_peripheral = m_peripheral}
                } else {
//                    disconnectOtherSensor(sid: DataManager.instance.m_userInfo.shareMember.getMyGroupMasterInfo()?.sid ?? "") // 내 sid를 보여줌.
//                    disconnectOtherSensor(sid: bleInfo?.m_sid ?? "") // 센서의 sid 를 보여줌.
//                    ConfirmOtherSensor()
                    
                    disconnectOtherSensor(type: DEVICE_TYPE.Sensor.rawValue, did: _connectSensor.m_did, srl: _connectSensor.m_srl, enc: _connectSensor.m_enc, sid: DataManager.instance.m_userInfo.shareMember.getMyGroupMasterInfo()?.sid ?? "") // 내 sid를 보여줌.
                }
                self.m_connectingPopup?.removeFromSuperview()
                self.m_updateTimer?.invalidate()
            }
        }
    }
    
//    func disconnectOtherSensor(sid: String) {
//        _ = PopupManager.instance.onlyContentsCustom(contents: "\("dialog_contents_already_registered_invite_request".localized)\(sid)", confirmType: .close)
//        DataManager.instance.m_dataController.deviceStatus.deleteSensor(did: self.bleInfo?.m_did ?? 0, adv: self.bleInfo?.m_adv ?? "")
//    }
    
    func ConfirmOtherSensor() {
        _ = PopupManager.instance.onlyContents(contentsKey: "dialog_contents_already_registered", confirmType: .noYes, okHandler: { () -> () in
            let _send = Send_RequestBecomeCloudMember()
            _send.aid = DataManager.instance.m_userInfo.account_id
            _send.token = DataManager.instance.m_userInfo.token
            _send.cid = self.bleInfo?.m_cid ?? 0
            NetworkManager.instance.Request(_send) { (json) -> () in
                let _receive = Receive_RequestBecomeCloudMember(json)
                switch _receive.ecd {
                case .success,
                     .shareMember_alreadyMember:
                    _ = UIManager.instance.sceneMoveNaviPush(scene: .deviceRegisterSensorFinish) as! DeviceRegisterSensorFinishViewController
                case .shareMember_limitMember:
                    DataManager.instance.m_dataController.deviceStatus.deleteSensor(did: self.bleInfo?.m_did ?? 0, adv: self.bleInfo?.m_adv ?? "")
                    _ = PopupManager.instance.onlyContents(contentsKey: "toast_invite_group_member_exceeded", confirmType: .ok, okHandler: { () -> () in
                    })
                default:
                    Debug.print("[ERROR] invaild errcod", event: .error)
                    let _errStr = String(format: "dialog_contents_err_communication_with_server".localized, APP_ERR_COD.Send_RequestBecomeCloudMember.rawValue)
                    _ = PopupManager.instance.onlyContentsCustom(contents: _errStr, confirmType: .ok, okHandler: { () -> () in
                    })
                }
            }
        }, cancleHandler: { () -> () in
            DataManager.instance.m_dataController.deviceStatus.deleteSensor(did: self.bleInfo?.m_did ?? 0, adv: self.bleInfo?.m_adv ?? "")
        })
    }
    
    func disconnectOtherSensor(type: Int, did: Int, srl: String, enc: String, sid: String) {
           let _popupInfo = PopupDetailInfo()
           let _contents = type == DEVICE_TYPE.Sensor.rawValue ? "dialog_contents_sensor_already_registered".localized : "dialog_contents_hub_already_registered".localized
           _popupInfo.title = type == DEVICE_TYPE.Sensor.rawValue ? "[Code102] " : "[Code202] "
           _popupInfo.contents = "\(_contents)\(sid)"
        
//        if (Config.channel == .kc ) {
            _popupInfo.buttonType = .both
            _popupInfo.left = "btn_device_initialize".localized
            _popupInfo.right = "btn_ok".localized
            _popupInfo.leftColor = COLOR_TYPE.red.color
            _popupInfo.rightColor = COLOR_TYPE.mint.color
//        } else {
//            _popupInfo.buttonType = .center
//            _popupInfo.center = "btn_ok".localized
//            _popupInfo.centerColor = COLOR_TYPE.mint.color
//        }
           
           _popupInfo.isTitleButton = true
           let _param = type == DEVICE_TYPE.Sensor.rawValue ? UIManager.instance.getBoardParam(board: BOARD_TYPE.connect_device_sensor, boardId: 24) : UIManager.instance.getBoardParam(board: BOARD_TYPE.connect_device_hub, boardId: 27)
           _popupInfo.titleLinkUrl = "\(Config.BOARD_DEFAULT_URL)\(_param)"
           _ = PopupManager.instance.setDetail(popupDetailInfo: _popupInfo
           , okHandler: { () -> () in
               DataManager.instance.m_dataController.deviceStatus.deleteSensor(did: self.bleInfo?.m_did ?? 0, adv: self.bleInfo?.m_adv ?? "")
           }, cancleHandler: { () -> () in
            self.inputPopup(type: type, did: did, srl: srl, enc: enc, sid: sid)
           })
       }
       
       func inputPopup(type: Int, did: Int, srl: String, enc: String, sid: String) {
           var _message = String(format: type == DEVICE_TYPE.Sensor.rawValue ? "dialog_contents_sensor_already_registered_init".localized : "dialog_contents_sensor_already_registered_init".localized)
        _message += "\(sid)"
           let alert = UIAlertController(title: "", message: _message, preferredStyle: .alert)
           alert.addTextField { (textField) in
               textField.text = ""
               //textField.placeholder = "invite_member_hint".localized
           }
           alert.setMessageAlignment(.left)
           
        // 시리얼 넘버 체크
//           let _action_ok = UIAlertAction(title: "btn_device_initialize".localized, style: .default, handler: { (action: UIAlertAction!) in
//               let textField = alert.textFields![0] // Force unwrapping because we know it exists.
//               if (textField.text!.count > 0) {
//                   let send = Send_AvailableSerialNumber()
//                   send.aid = DataManager.instance.m_userInfo.account_id
//                   send.token = DataManager.instance.m_userInfo.token
//                   send.type = type
//                   send.did = did
//                   send.srl = textField.text!
//                   NetworkManager.instance.Request(send) { (json) -> () in
//                       let receive = Receive_AvailableSerialNumber(json)
//                       switch receive.ecd {
//                       case .success: self.deviceInit(type: type, did: did, srl: srl, enc: enc)
//                       case .available_serial_number:
//                           _ = PopupManager.instance.onlyContents(contentsKey: type == DEVICE_TYPE.Sensor.rawValue ? "toast_sensor_initialize_wrong_serialnumber" : "toast_hub_initialize_wrong_serialnumber", confirmType: .ok, okHandler: { () -> () in
//                               self.inputPopup(type: type, did: did, srl: srl, enc: enc)
//                           })
//                       default: Debug.print("[ERROR] invaild errcod", event: .error)
//                       }
//                   }
//               } else {
//                   DataManager.instance.m_dataController.deviceStatus.deleteSensor(did: self.bleInfo?.m_did ?? 0, adv: self.bleInfo?.m_adv ?? "")
//               }
//           })
//           _action_ok.setValue(COLOR_TYPE.red.color, forKey: "titleTextColor")
//           alert.addAction(_action_ok)
       
        // 회원코드 체크
        let _action_ok = UIAlertAction(title: "btn_device_initialize".localized, style: .default, handler: { (action: UIAlertAction!) in
            let textField = alert.textFields![0] // Force unwrapping because we know it exists.
            if (textField.text!.count > 0) {
                if (textField.text!.lowercased() == sid.lowercased()) {
                    self.deviceInit(type: type, did: did, srl: srl, enc: enc)
                } else {
                    _ = PopupManager.instance.onlyContents(contentsKey: type == DEVICE_TYPE.Sensor.rawValue ? "warning_invalid_short_id" : "warning_invalid_short_id", confirmType: .ok, okHandler: { () -> () in
                        self.inputPopup(type: type, did: did, srl: srl, enc: enc, sid: sid)
                    })
                }
            } else {
                self.inputPopup(type: type, did: did, srl: srl, enc: enc, sid: sid)
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
    
    @IBAction func onClick_StartConnection(_ sender: UIButton) {
        startConnection()
    }
    
    @IBAction func onClick_help(_ sender: Any) {
        let _param = UIManager.instance.getBoardParam(board: BOARD_TYPE.connect_device_sensor, boardId: 18)
        let _scene = UIManager.instance.sceneMoveNaviPush(scene: .customWebView, isAniamtion: false) as! CustomWebViewController
        _scene.setInit(url: "\(Config.BOARD_DEFAULT_URL)\(_param)", naviTitle: "help".localized)
    }
}
