//
//  DeviceRegisterHubConnectingViewController.swift
//  Monit
//
//  Created by 맥 on 2017. 10. 9..
//  Copyright © 2017년 맥. All rights reserved.
//

import UIKit
import SystemConfiguration.CaptiveNetwork

class DeviceRegisterHubConnectingViewController: BaseViewController {
    @IBOutlet weak var lblNaviTItle: UILabel!
    @IBOutlet weak var lblContentTitle: UIButton!
    @IBOutlet weak var lblContentSummary: UILabel!
    
    @IBOutlet weak var btnConnection: UIButton!
    @IBOutlet weak var imgHowto: UIImageView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    override var screenType: SCREEN_TYPE { get { return .HUB_REGISTER_READY } }
    var m_updateTimer: Timer?
    var m_timeInterval: Double = 0.1
    var m_time: Double = 0
    var registerType: HUB_TYPES_REGISTER_TYPE = .new
    
    var isConnectSensor: Bool {
        get {
            return DataManager.instance.m_userInfo.connectSensor.successConnectSensor.count > 0
        }
    }
    
    override func viewDidLoad() {
        isUpdateView = false
        super.viewDidLoad()
        Debug.print("[UI][\(self.classNameToString()).viewDidLoad()]")
        setInit()
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
    
    func setInit() {
        connectSensor()
    }
    
    func setUI() {
        setIndicator(isVisiable: false)
        
        btnConnection.layer.borderColor = COLOR_TYPE.mint.color.cgColor
        btnConnection.layer.borderWidth = 1
        
        animate()
        
        lblNaviTItle.text = UIManager.instance.hubNaviTitle(type: registerType)
        lblContentTitle.setTitleWithOutAnimation(title: registerType == .new ? "connection_hub_put_sensor_title".localized + " " : "connection_hub_put_sensor_title".localized + " ")
        lblContentSummary.text = "connection_hub_put_sensor_detail_step2".localized
        btnConnection.setTitle("connection_start_connect".localized.uppercased(), for: .normal)
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
        if (Config.channel == .kc) {
            images.append(UIImage(named: "imgKcHubTutorial3_1")!)
            images.append(UIImage(named: "imgKcHubTutorial3_2")!)
            images.append(UIImage(named: "imgKcHubTutorial3_3")!)
            images.append(UIImage(named: "imgKcHubTutorial3_4")!)
        } else {
            images.append(UIImage(named: "imgHubTutorial3_1")!)
            images.append(UIImage(named: "imgHubTutorial3_2")!)
            images.append(UIImage(named: "imgHubTutorial3_3")!)
            images.append(UIImage(named: "imgHubTutorial3_4")!)
        }

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

    @IBAction func onClick_back(_ sender: UIButton) {
        UIManager.instance.sceneMoveNaviPop()
    }
    
    @IBAction func onClick_connect(_ sender: UIButton) {
        if (!isConnectSensor) {
            _ = PopupManager.instance.onlyContents(contentsKey: "toast_sensor_is_not_connected_directly", confirmType: .ok)
            return
        }
        
        var _isFound = false
        for item in DataManager.instance.m_userInfo.connectSensor.successConnectSensor {
            if (item.controller!.m_hubConnectionController!.isHubConnectCheck) {
                _isFound = true
                break
            }
        }
        if (!_isFound) {
            let _param = UIManager.instance.getBoardParamSensorIntoHub()
            _ = PopupManager.instance.withErrorCode(codeString: "[Code200] ", linkURL: "\(Config.BOARD_DEFAULT_URL)\(_param)", contentsKey: "connection_hub_put_sensor_detail_step2", confirmType: .ok)
        }
        
        connectSensor()
    }
    
    func connectSensor() {
        for item in DataManager.instance.m_userInfo.connectSensor.successConnectSensor {
            item.controller?.startHubConnection() // once
        }

        self.m_updateTimer?.invalidate()
        self.m_updateTimer = Timer.scheduledTimer(timeInterval: self.m_timeInterval, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
    }
    
    @objc func update() {
        m_time += m_timeInterval

        if (UIManager.instance.rootCurrentView as? DeviceRegisterHubConnectingViewController == nil) {
            self.m_updateTimer?.invalidate()
        }
        
        for item in DataManager.instance.m_userInfo.connectSensor.successConnectSensor {
            if let _hubCtrl = item.controller?.m_hubConnectionController {
                if (_hubCtrl.m_status == .connectSuccess) {
                    let _isAlready = DataManager.instance.m_userInfo.shareMember.getOtherGroupMasterInfoByCloudId(cid: _hubCtrl.m_cloud_id) != nil ? true : false
                    if (_hubCtrl.m_cloud_id == DataManager.instance.m_userInfo.account_id || _isAlready) {
                        if let view = UIManager.instance.sceneMoveNaviPush(scene: .deviceRegisterHubWifi) as? DeviceRegisterHubWifiViewController {
                            view.registerType = registerType
                            view.setInfo(info: WifiConnectDetailInfo(sensorDid: _hubCtrl.bleInfo?.m_did ?? 0, hubDid: _hubCtrl.m_device_id))
                            Debug.print("Move deviceRegisterHubWifi", event: .warning)
                        }
                    } else {
//                        disconnectOtherSensor(sid: DataManager.instance.m_userInfo.shareMember.getMyGroupMasterInfo()?.sid ?? "") // 내 sid를 보여줌
//                        disconnectOtherSensor(sid: _hubCtrl.m_sid) // 센서의 sid를 보여줌
//                        ConfirmOtherHub(hubCid: _hubCtrl.m_cloud_id, sensorDid: _hubCtrl.bleInfo?.m_did ?? 0, hubDid: _hubCtrl.m_device_id)
                        disconnectOtherSensor(type: DEVICE_TYPE.Hub.rawValue, did: _hubCtrl.m_device_id, srl: _hubCtrl.m_serialNumber, enc: _hubCtrl.m_enc, sid: DataManager.instance.m_userInfo.shareMember.getMyGroupMasterInfo()?.sid ?? "") // 내 sid를 보여줌
                    }
                    self.m_updateTimer?.invalidate()
                }
            }
        }
    }
    
//    func disconnectOtherSensor(sid: String) {
//        _ = PopupManager.instance.onlyContentsCustom(contents: "\("dialog_contents_already_registered_invite_request".localized)\(sid)", confirmType: .close)
//    }
    
    func ConfirmOtherHub(hubCid: Int, sensorDid: Int, hubDid: Int) {
        _ = PopupManager.instance.onlyContents(contentsKey: "dialog_contents_already_registered", confirmType: .noYes, okHandler: { () -> () in
            let _send = Send_RequestBecomeCloudMember()
            _send.aid = DataManager.instance.m_userInfo.account_id
            _send.token = DataManager.instance.m_userInfo.token
            _send.cid = hubCid
            NetworkManager.instance.Request(_send) { (json) -> () in
                let _receive = Receive_RequestBecomeCloudMember(json)
                switch _receive.ecd {
                case .success,
                     .shareMember_alreadyMember:
                    if let view = UIManager.instance.sceneMoveNaviPush(scene: .deviceRegisterHubWifi) as? DeviceRegisterHubWifiViewController {
                        
                        
                        view.setInfo(info: WifiConnectDetailInfo(sensorDid: sensorDid, hubDid: hubDid))
                        Debug.print("Move deviceRegisterHubWifi", event: .warning)
                    }
                case .shareMember_limitMember:
                    _ = PopupManager.instance.onlyContents(contentsKey: "toast_invite_group_member_exceeded", confirmType: .ok, okHandler: { () -> () in
                    })
                default:
                    Debug.print("[ERROR] invaild errcod", event: .error)
                    let _errStr = String(format: "dialog_contents_err_communication_with_server".localized, APP_ERR_COD.Send_SetBabyInfo.rawValue)
                    _ = PopupManager.instance.onlyContentsCustom(contents: _errStr, confirmType: .ok, okHandler: { () -> () in
                    })
                }
            }
        }, cancleHandler: { () -> () in
        })
    }
    
    func disconnectOtherSensor(type: Int, did: Int, srl: String, enc: String, sid: String) {
              let _popupInfo = PopupDetailInfo()
              let _contents = type == DEVICE_TYPE.Sensor.rawValue ? "dialog_contents_sensor_already_registered".localized : "dialog_contents_hub_already_registered".localized
              _popupInfo.title = type == DEVICE_TYPE.Sensor.rawValue ? "[Code102] " : "[Code202] "
              _popupInfo.contents = "\(_contents)\(sid)"
           
//           if (Config.channel == .kc ) {
               _popupInfo.buttonType = .both
               _popupInfo.left = "btn_device_initialize".localized
               _popupInfo.right = "btn_ok".localized
               _popupInfo.leftColor = COLOR_TYPE.red.color
               _popupInfo.rightColor = COLOR_TYPE.mint.color
//           } else {
//               _popupInfo.buttonType = .center
//               _popupInfo.center = "btn_ok".localized
//               _popupInfo.centerColor = COLOR_TYPE.mint.color
//           }
              
              _popupInfo.isTitleButton = true
              let _param = type == DEVICE_TYPE.Sensor.rawValue ? UIManager.instance.getBoardParam(board: BOARD_TYPE.connect_device_sensor, boardId: 24) : UIManager.instance.getBoardParam(board: BOARD_TYPE.connect_device_hub, boardId: 27)
              _popupInfo.titleLinkUrl = "\(Config.BOARD_DEFAULT_URL)\(_param)"
              _ = PopupManager.instance.setDetail(popupDetailInfo: _popupInfo
              , okHandler: { () -> () in
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
//              let _action_ok = UIAlertAction(title: "btn_device_initialize".localized, style: .default, handler: { (action: UIAlertAction!) in
//                  let textField = alert.textFields![0] // Force unwrapping because we know it exists.
//                  if (textField.text!.count > 0) {
//                      let send = Send_AvailableSerialNumber()
//                      send.aid = DataManager.instance.m_userInfo.account_id
//                      send.token = DataManager.instance.m_userInfo.token
//                      send.type = type
//                      send.did = did
//                      send.srl = textField.text!
//                      NetworkManager.instance.Request(send) { (json) -> () in
//                          let receive = Receive_AvailableSerialNumber(json)
//                          switch receive.ecd {
//                          case .success: self.deviceInit(type: type, did: did, srl: srl, enc: enc)
//                          case .available_serial_number:
//                              _ = PopupManager.instance.onlyContents(contentsKey: type == DEVICE_TYPE.Sensor.rawValue ? "toast_sensor_initialize_wrong_serialnumber" : "toast_hub_initialize_wrong_serialnumber", confirmType: .ok, okHandler: { () -> () in
//                                  self.inputPopup(type: type, did: did, srl: srl, enc: enc)
//                              })
//                          default: Debug.print("[ERROR] invaild errcod", event: .error)
//                          }
//                      }
//                  } else {
//                  }
//              })
//              _action_ok.setValue(COLOR_TYPE.red.color, forKey: "titleTextColor")
//              alert.addAction(_action_ok)
        
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
              }
          }
    
    @IBAction func onClick_help(_ sender: Any) {
        let _param = UIManager.instance.getBoardParamSensorIntoHub()
        let _scene = UIManager.instance.sceneMoveNaviPush(scene: .customWebView, isAniamtion: false) as! CustomWebViewController
        _scene.setInit(url: "\(Config.BOARD_DEFAULT_URL)\(_param)", naviTitle: "help".localized)
    }
}
