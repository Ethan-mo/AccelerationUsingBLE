//
//  DeviceMainViewController.swift
//  Monit
//
//  Created by 맥 on 2017. 9. 4..
//  Copyright © 2017년 맥. All rights reserved.
//

import UIKit
import SwiftyJSON
import Firebase

class DeviceMainViewController: BaseViewController {
    @IBOutlet weak var btnAddDevice: UIButton!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var btnGoodmonitLogo: UIButton!
    @IBOutlet weak var btnKcLogo: UIButton!
    @IBOutlet weak var btnShare: UIButton!
    
    override var screenType: SCREEN_TYPE { get { return .DEVICE_LIST } }
    var m_containerViewController: UIViewController?
    var m_hiddenModeCount: Int = 0
    var m_isLoad: Bool = false
    
    var isNotiArea : Bool {
        get {
            if #available(iOS 11.0, tvOS 11.0, *) {
                return UIApplication.shared.delegate?.window??.safeAreaInsets.top ?? 0 > 20
            }
            return false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        m_isLoad = true
        Debug.print("[UI][\(self.classNameToString()).viewDidLoad()]")
        if (Utility.isTopNotch || isNotiArea) {
            UIManager.instance.setNaviHeight(identifier: "naviHeight", view: self.view, height: 69.0 + Config.NOTCH_HEIGHT_PADDING)
        }
        
        btnShare.isHidden = true
        btnGoodmonitLogo.isHidden = true
        btnKcLogo.isHidden = true
        switch Config.channel {
        case .goodmonit, .kao:
           btnGoodmonitLogo.isHidden = false
           btnShare.isHidden = false
        case .monitXHuggies:
           btnGoodmonitLogo.isHidden = false
           btnShare.isHidden = false
        case .kc:
           btnKcLogo.isHidden = false
        }
        
//        NativePopupManager.instance.withTitle(title: "aaaa", message: "ssssss", completionHandler: { () -> () in })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (!(DataManager.instance.m_dataController.device.isDataVaildCheck)) {
            UIManager.instance.deviceRefrash()
        } else {
            BleConnectionManager.instance.update() // force scan
            BleConnectionLampManager.instance.update() // force scan
            sensorVaildCheck()
            setUI()
        }
        
        // huggies only
        if (Config.channel == .monitXHuggies) {
            DataManager.instance.m_configData.m_huggiesNickFlow.one {
                if (DataManager.instance.m_userInfo.shareMember.getMyGroupMasterInfo()?.nick ?? "" == "") {
//                    _ = UIManager.instance.sceneMoveNaviPush(scene: .nickMonitXHuggies)
                    nickChangePopup()
                }
            }
        }
    }
    
    override func reloadInfo() {
        super.reloadInfo()
        if (!m_isLoad) {
            return
        }
        Debug.print("[UI][\(self.classNameToString()).reloadInfo()]")
        if let _view = m_containerViewController as? DeviceMainTableViewController {
            _view.reloadInfoChild()
        }
        if let _ = m_containerViewController as? DeviceMainNoneViewController {
            DataManager.instance.m_dataController.deviceStatus.updateFullStatus(handler: { (isSuccess) in
            })
            
            if (!(DataManager.instance.m_dataController.device.isDataVaildCheck)) {
                UIManager.instance.deviceRefrash()
            }
        }
        setUI()
    }

    func setUI() {
        m_hiddenModeCount = 0

        let sb = UIStoryboard(name: SystemManager.instance.GetStoryBoardName(.mainDeviceNavi), bundle: nil)
        if (DataManager.instance.m_dataController.device.getTotalCount > 0) {
            if (m_containerViewController as? DeviceMainTableViewController) == nil {
                let _table = sb.instantiateViewController(withIdentifier: SCENE_CONTAINER.mainDeviceTableContainer.rawValue) as? DeviceMainTableViewController
                m_containerViewController = _table
                _table?.m_parent = self
                _table?.setInfo()
                
                btnAddDevice.isHidden = false
            }
        } else {
            if (m_containerViewController as? DeviceMainNoneViewController) == nil {
                let _noneTable = sb.instantiateViewController(withIdentifier: SCENE_CONTAINER.mainDeviceNoneTableContainer.rawValue) as? DeviceMainNoneViewController
                m_containerViewController = _noneTable
                _noneTable?.m_parent = self
                switch Config.channel {
                case .goodmonit, .kao: btnAddDevice.isHidden = false
                case .monitXHuggies: btnAddDevice.isHidden = false
                case .kc: btnAddDevice.isHidden = true
                }
            }
        }

        if (m_containerViewController != nil) {
            addChildViewController(m_containerViewController!)
             m_containerViewController?.view.translatesAutoresizingMaskIntoConstraints = false
            containerView.addSubview(m_containerViewController!.view)
            
            NSLayoutConstraint.activate([
                m_containerViewController!.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                m_containerViewController!.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
                m_containerViewController!.view.topAnchor.constraint(equalTo: containerView.topAnchor),
                m_containerViewController!.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
                ])
            
            m_containerViewController?.didMove(toParentViewController: self)
        }
        
        UIManager.instance.moveNextScene(dic: [.shareMemberMain : .shareMemberMain,
                                           .userSetupMain : .userSetupMain,
                                           .deviceRegisterHub : .deviceRegister,
                                           .deviceRegister : .deviceRegister
                                           ])
        printNoti()
    }
    
    func printNoti() {
        DataManager.instance.m_configData.m_noticeFlow.one {
            NetworkManager.instance.Request(Send_GetNoticeV2()) { (json) -> () in
                let receive = Receive_GetNoticeV2(json)
                switch receive.ecd {
                case .success:
                    for item in receive.data {
                        if (NOTICE_TYPE.alwaysRepeat == NOTICE_TYPE(rawValue: item.notice_type) ?? NOTICE_TYPE.alwaysRepeat) {
                            if (!DataManager.instance.m_configData.getRepeatNotice(key: "notice_\(item._id)")) {
                                let _detail = PopupDetailInfo()
                                _detail.title = item.title
                                _detail.titleColor = COLOR_TYPE.red.color
                                _detail.contents = item.contents
                                
                                if (item.board_id == 0) {
                                    _detail.buttonType = PopupView.CUSTOM_BUTTON_TYPE.center
                                    _detail.center = "btn_ok".localized
                                    _detail.centerColor = COLOR_TYPE.mint.color
                                    _ = PopupManager.instance.withCheckboxCustom(popupDetailInfo: _detail
                                        , chk: "btn_do_not_repeat".localized
                                        , checkHandler: { (isCheck) in
                                        if (isCheck) {
                                            DataManager.instance.m_configData.setRepeatNotice(key: "notice_\(item._id)")
                                        }
                                    })
                                } else {
                                    _detail.buttonType = PopupView.CUSTOM_BUTTON_TYPE.both
                                    _detail.left = "btn_ok".localized
                                    _detail.right = "btn_learnmore".localized
                                    _detail.rightColor = COLOR_TYPE.mint.color
                                    _ = PopupManager.instance.withCheckboxCustom(popupDetailInfo: _detail
                                        ,okHandler: { () in
                                            let _param = UIManager.instance.getBoardParam(board: BOARD_TYPE(rawValue: item.board_type) ?? BOARD_TYPE.notice, boardId: item.board_id)
                                            let _scene = UIManager.instance.sceneMoveNaviPush(scene: .customWebView, isAniamtion: false) as! CustomWebViewController
                                            
                                            if (!Config.IS_LIVE_SERVER) {
                                                _scene.setInit(url: "\(Config.BOARD_DEFAULT_DEV_URL)\(_param)", naviTitle: "notice_title".localized)
                                            } else {
                                                _scene.setInit(url: "\(Config.BOARD_DEFAULT_URL)\(_param)", naviTitle: "notice_title".localized)
                                            }
                                        }
                                        , chk: "btn_do_not_repeat".localized
                                        , checkHandler: { (isCheck) in
                                        if (isCheck) {
                                            DataManager.instance.m_configData.setRepeatNotice(key: "notice_\(item._id)")
                                        }
                                    })
                                }
                            }
                        }
                    }
                default: Debug.print("[ERROR] invaild errcod", event: .error)
                }
            }
        }
        
        if (DataManager.instance.m_configData.isTerminateApp) {
            DataManager.instance.m_configData.isTerminateApp = false
            if (DataManager.instance.m_configData.isTerminateNoti) {
                _ = PopupManager.instance.withCheckbox(titleKey: "cautions_title", titleColor: COLOR_TYPE.red.color, contentsKey: "connection_terminate_app_noti_detail", chkKey: "btn_do_not_repeat", btnKey: "btn_ok", btnColor: COLOR_TYPE.mint.color, checkHandler: { (isCheck) in
                    DataManager.instance.m_configData.isTerminateNoti = !isCheck
                })
            }
        }
        
//        #if DEBUG
//        _ = UIManager.instance.sceneMoveNaviPush(scene: .deviceDiaperAttachGuide)
//        #endif
    }
    
    func nickChangePopup() {
        let alert = UIAlertController(title: "account_change_nickname".localized, message: "dialog_contents_input_nickname".localized, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "btn_ok".localized, style: .default, handler: { (action: UIAlertAction!) in
            let textField = alert.textFields![0] // Force unwrapping because we know it exists.
            let _nick = textField.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            if (_nick.count > 0) {
                let send = Send_ChangeNickname()
                send.aid = DataManager.instance.m_userInfo.account_id
                send.token = DataManager.instance.m_userInfo.token
                send.nick = Utility.urlEncode(_nick)
                NetworkManager.instance.Request(send) { (json) -> () in
                    let receive = Receive_ChangeNickname(json)
                    switch receive.ecd {
                    case .success:
                        if let _Info = DataManager.instance.m_userInfo.shareMember.getMyGroupMasterInfo() {
                            _Info.nick = _nick
                        }
                        _ = PopupManager.instance.onlyContents(contentsKey: "toast_change_nickname_succeeded", confirmType: .ok)
                    default: Debug.print("[ERROR] invaild errcod", event: .error)
                    _ = PopupManager.instance.onlyContents(contentsKey: "toast_change_nickname_failed", confirmType: .ok)
                    }
                }
            } else {
                _ = PopupManager.instance.onlyContents(contentsKey: "account_warning_dialog_nickname", confirmType: .ok, okHandler: { () -> () in
                    self.nickChangePopup()
                })
            }
        }))

        alert.addTextField { (textField: UITextField!) -> Void in
            textField.text = ""
            let myNotificationCenter = NotificationCenter.default
            myNotificationCenter.addObserver(self, selector: #selector(self.changeTextField), name: NSNotification.Name.UITextFieldTextDidChange, object: nil)
        }
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func changeTextField (sender: NSNotification) {
        let _textField = sender.object as! UITextField
        UI_Utility.checkMaxLength(textField: _textField, maxLength: 12)
    }
    
    func sensorVaildCheck() {
        Debug.print("[BLE] sensorVaildCheck")
        for item in DataManager.instance.m_userInfo.connectSensor.m_connectSensor {
            var _isFound = false
            if let _arrTotalSensor = DataManager.instance.m_dataController.device.getTotalUserInfoList {
                for __arrTotalSensor in _arrTotalSensor {
                    if (__arrTotalSensor.did == item.m_did && __arrTotalSensor.type == DEVICE_TYPE.Sensor.rawValue) {
                        _isFound = true
                        break
                    }
                }
            }
            if (!_isFound) {
                if (item.controller?.m_status == .connectSuccess) {
                    Debug.print("[BLE][ERROR] delete did, disconnect sensor!!", event: .error)
                    BleConnectionManager.instance.disconnectDevice(peripheral: item.peripheral)
                }
            }
        }
    }
    
    func lampVaildCheck() {
        Debug.print("[BLE] lampVaildCheck")
        for item in DataManager.instance.m_userInfo.connectLamp.m_connectLamp {
            var _isFound = false
            if let _arrTotalSensor = DataManager.instance.m_dataController.device.getTotalUserInfoList {
                for __arrTotalSensor in _arrTotalSensor {
                    if (__arrTotalSensor.did == item.m_did && __arrTotalSensor.type == DEVICE_TYPE.Lamp.rawValue) {
                        _isFound = true
                        break
                    }
                }
            }
            if (!_isFound) {
                if (item.controller?.m_status == .connectSuccess) {
                    Debug.print("[BLE][ERROR] delete did, disconnect sensor!!", event: .error)
                    BleConnectionLampManager.instance.disconnectDevice(peripheral: item.peripheral)
                }
            }
        }
    }
    
    @IBAction func onClick_UserSetup(_ sender: UIButton) {
        _ = UIManager.instance.sceneMoveNaviPush(scene: .userSetupMain)
    }
    
    @IBAction func onClick_addDeivce(_ sender: UIButton) {
        _ = UIManager.instance.sceneMoveNaviPush(scene: .deviceRegister)
    }
    
    func debugMode() {
        let popup: MasterMonitorView = .fromNib()
        let _view = UIManager.instance.rootCurrentView?.view
        popup.frame = (_view?.frame)!
        _view?.addSubview(popup)
        popup.setInfo()
    }
    
    @IBAction func onClick_hiddenMode(_ sender: UIButton) {
        if (DataManager.instance.m_userInfo.configData.isMaster) {
            if (m_hiddenModeCount >= 5) {
                m_hiddenModeCount = 0
                debugMode()
            }
        }
        m_hiddenModeCount += 1
    }
    
    @IBAction func onClick_share(_ sender: UIButton) {
        _ = UIManager.instance.sceneMoveNaviPush(scene: .shareMemberMain)
    }
}
