//
//  InitViewController.swift
//  Monit
//
//  Created by 맥 on 2017. 9. 11..
//  Copyright © 2017년 맥. All rights reserved.
// Ethan 버전 업 첫번쨰(20220418)

import UIKit
import SwiftyJSON
import FirebaseAnalytics

// logo page
// (first, reset, leave, login, logout, join complete, session expired) in case
class InitViewController : BaseViewController {
    
    @IBOutlet weak var imgSplashGoodmonit: UIImageView!
    @IBOutlet weak var imgSplashMonitXHuggies: UIImageView!
    @IBOutlet weak var imgSplashKc: UIImageView!
    @IBOutlet weak var imgLogo: UIImageView!
    
    enum STATUS {
        case none
        case setAppData
        case appMaintenanceCheck
        case appUpdateCheck
        case commonCommand
        case loginCheck
        case setBle
        case setInit
        case setUserInfo
        case finish
        case setNotification
        case updateStatus
        case setEtc
        case initFail
        case exitApp
    }
    
    var m_status: STATUS = .none
    
    static var m_initUserDataFinished = false
    static var m_isOnce = false
    var m_updateTimer: Timer?
    var m_isFinishedAniamtion = false
    var m_isFinishedLoading = false
    var m_timeInterval: Double = 0.01
    var m_time: Double = 0
    var m_resedingCount: Int = 0
    
    override func viewDidAppear(_ animated: Bool) {
        Debug.print("[⚪️][Init] InitViewController viewDidAppear")
        
//        Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
//            AnalyticsParameterItemID: "my_item_id"
//        ])
        
        m_updateTimer?.invalidate()
        m_updateTimer = Timer.scheduledTimer(timeInterval: m_timeInterval, target: self, selector: #selector(update), userInfo: nil, repeats: true)
        
        if (!InitViewController.m_isOnce) {
            firstInit()
        } else {
            notFirstInit()
        }
        
        alwaysInit()
    }
    
    func firstInit() {
        InitViewController.m_isOnce = true

//         #if DEBUG
//             m_isFinishedAniamtion = true
//             imgLogo.isHidden = true
//         #else
        DispatchQueue.main.async {
            self.perform(#selector(self.animateStop), with: nil, afterDelay: 3)
            self.imgLogo.isHidden = true
            self.animate()
            
        }
//         #endif
    }
    
    func notFirstInit() {
        m_isFinishedAniamtion = true
        imgLogo.isHidden = false
    }
    
    func alwaysInit() {
        m_resedingCount = 0
        printChannel()
        changeState(category: .setAppData)
    }
    
    func printChannel() {
        #if GOODMONIT && !DEBUG
        Debug.print("GOODMONIT CHANNELING RELEASE")
        #elseif GOODMONIT && DEBUG
        Debug.print("GOODMONIT CHANNELING DEBUG")
        #endif
        
        #if HUGGIES && !DEBUG
        Debug.print("HUGGIES CHANNELING RELEASE")
        #elseif HUGGIES && DEBUG
        Debug.print("HUGGIES CHANNELING DEBUG")
        #endif
        
        #if KC && !DEBUG
        Debug.print("KC CHANNELING RELEASE")
        #elseif KC && DEBUG
        Debug.print("KC CHANNELING DEBUG")
        #endif
    }
    
    func changeState(category: STATUS) {
        if (category == m_status) {
            return
        }
        m_status = category
        switch category {
        case .setAppData:
            Debug.print("[⚪️][Init] STATUS.setAppData")
            setInitAppData()
        case .appUpdateCheck:
            Debug.print("[⚪️][Init] STATUS.appUpdateCheck")
            checkUpdate()
        case .appMaintenanceCheck:
            Debug.print("[⚪️][Init] STATUS.appMaintenanceCheck")
            checkMaintenance()
        case .commonCommand:
            Debug.print("[⚪️][Init] STATUS.commonCommand")
            commonCommand()
        case .loginCheck:
            Debug.print("[⚪️][Init] STATUS.loginCheck")
            checkLogin()
        case .setBle:
            Debug.print("[⚪️][Init] STATUS.setBle")
            setBle()
        case .setInit:
            Debug.print("[⚪️][Init] STATUS.setInit")
            setInitInfo()
        case .setUserInfo:
            Debug.print("[⚪️][Init] STATUS.setUserInfo")
            getUserInfo()
        case .finish:
            Debug.print("[⚪️][Init] STATUS.finish")
            setFinish()
        case .setNotification:
            Debug.print("[⚪️][Init] STATUS.setNotification")
            setNotification()
        case .updateStatus:
            Debug.print("[⚪️][Init] STATUS.updateStatus")
            updateStatus()
        case .setEtc:
            Debug.print("[⚪️][Init] STATUS.setEtc")
            setEtc()
        case .initFail:
            Debug.print("[⚪️][Init] STATUS.initFail")
            initFail()
        case .exitApp:
            Debug.print("[⚪️][Init] STATUS.exitApp")
            exitApp()
        default: break
        }
    }
    
    func setInitAppData() {
        if (DataManager.instance.m_configData.appData == "" || DataManager.instance.m_configData.localAppData == "") {
            let _send = Send_GetAppData()
            _send.os = Config.OS
            _send.atype = Config.channelOsNum
            _send.isResending = true
            NetworkManager.instance.Request(_send) { (json) -> () in
                let receive = Receive_GetAppData(json)
                switch receive.ecd {
                case .success:
                    DataManager.instance.m_configData.appData = receive.appdata ?? ""
                    DataManager.instance.m_configData.localAppData = receive.appdata2 ?? ""
                    
                    Widget_Utility.setSharedInfo(channel: Config.channelOsNum, key: .appData, value: receive.appdata ?? "")
                    self.changeState(category: .appMaintenanceCheck)
                default:
                    Debug.print("[⚪️][Init][ERROR] invaild errcod", event: .error)
                    self.changeState(category: .exitApp)
                }
            }
        } else {
            changeState(category: .appUpdateCheck)
        }
    }
    
//    func setInitLocalAppData() {
//        if (DataManager.instance.m_configData.localAppData == "") {
//            let _send = Send_GetLocalAppData()
//            _send.os = Config.OS
//            _send.atype = Config.channelOsNum
//            _send.isResending = true
//            NetworkManager.instance.Request(_send) { (json) -> () in
//                let receive = Receive_GetLocalAppData(json)
//                switch receive.ecd {
//                case .success:
//                    DataManager.instance.m_configData.localAppData = receive.appdata ?? ""
//
////                    Widget_Utility.setSharedInfo(channel: Config.channelOsNum, key: .appData, value: receive.appdata ?? "")
//                    self.changeState(category: .appMaintenanceCheck)
//                default:
//                    Debug.print("[⚪️][Init][ERROR] invaild errcod", event: .error)
//                    self.changeState(category: .exitApp)
//                }
//            }
//        } else {
//            changeState(category: .appUpdateCheck)
//        }
//    }
    
    func checkMaintenance() {
        SystemManager.instance.checkMaintenance(handler: { () in
            self.changeState(category: .appUpdateCheck)
        })
    }
    
    func checkUpdate() {
        let _send = Send_GetLastestInfo()
        _send.isResending = true
        _send.isIndicator = false
        _send.isErrorPopupOn = false
        _send.os = Config.OS
        _send.atype = Config.channelOsNum
        _send.logPrintLevel = .warning
        NetworkManager.instance.Request(_send) { (json) -> () in
            let receive = Receive_GetLastestInfo(json)
            switch receive.ecd {
            case .success:
                DataManager.instance.m_configData.m_latestSensorVersion = receive.monit ?? ""
                DataManager.instance.m_configData.m_latestHubVersion = receive.hub ?? ""
                DataManager.instance.m_configData.m_latestLampVersion = receive.lamp ?? ""
                DataManager.instance.m_configData.m_latestSensorForceVersion = receive.monit_force ?? ""
                DataManager.instance.m_configData.m_latestHubForceVersion = receive.hub_force ?? ""
                DataManager.instance.m_configData.m_latestLampForceVersion = receive.lamp_force ?? ""
                
                if let _version = receive.app {
                    if (!(SystemManager.instance.isEqualVersion(checkVersion: _version))) {
                        Debug.print("update!!")
                        DispatchQueue.global().async {
                            DispatchQueue.main.async {
                                self.goUpdate()
                            }
                        }
                    } else {
                        self.changeState(category: .commonCommand)
                    }
                }
            default:
                Debug.print("[⚪️][Init][ERROR] invaild errcod", event: .error)
                self.changeState(category: .commonCommand)
            }
        }
    }
    
    func goUpdate() {
        _ = PopupManager.instance.onlyContents(contentsKey: "dialog_contents_update_available", confirmType: .ok, okHandler: { () -> () in
            if (!(Utility.urlOpen(Config.appStoreUrl))) {
                self.changeState(category: .commonCommand)
            }
        })
    }
    
    func commonCommand() {
        DataManager.instance.m_configData.m_commonCommand.one {
            SystemManager.instance.accountActiveUserLog()
        }
        self.changeState(category: .loginCheck)
    }
    
    func checkLogin() {
        if (!DataManager.instance.m_userInfo.isSignin) {
            m_isFinishedLoading = true
        } else {
            changeState(category: .setInit)
        }
    }
    
    @objc func update() {
        m_time += m_timeInterval

        if (m_isFinishedAniamtion && m_isFinishedLoading) {
            m_isFinishedAniamtion = false
            m_isFinishedLoading = false
            m_updateTimer?.invalidate()
            changeState(category: .finish)
        } else {
            if (UIManager.instance.rootCurrentView as? InitViewController == nil) {
                m_updateTimer?.invalidate()
                if (!DataManager.instance.m_userInfo.isSignin) {
                    InitViewController.m_initUserDataFinished = false
                } else {
                    InitViewController.m_initUserDataFinished = true
                }
            }
        }
    }
    
    @objc func animateStop() {
        m_isFinishedAniamtion = true
    }
    
    func setNotification() {
        DataManager.instance.m_configData.m_pushFlow.one {
            if (Config.IS_FCM) {
                NotificationManager.instance.setFcm()
            } else {
                NotificationManager.instance.setPushy()
            }
        }
        changeState(category: .setUserInfo)
    }
    
    // set init
    func setInitInfo() {
        DataManager.instance.m_configData.m_initInfoFlow.one {
            ReportManager.instance.delete(exceptInterval: 2)
            Debug.print("[⚪️][Init] isAppStoreVersion: \(Config.isAppStoreVersion)")
            Debug.print("[⚪️][Init] CFBundleShortVersionString: \(Config.bundleVersion)")
            let send = Send_Init()
            send.aid = DataManager.instance.m_userInfo.account_id
            send.token = DataManager.instance.m_userInfo.token
            send.lang = Config.lang
            send.ltime = UI_Utility.nowLocalDate(type: .yyMMdd_HHmmss)
            send.device = "\(UIDevice.current.modelName)/\(UIDevice.current.systemVersion)"
            send.os = Config.OS
            send.ver = Config.bundleVersion
            send.atype = Config.channelOsNum
            send.isIndicator = false
            send.logPrintLevel = .warning
            send.isResending = true
            NetworkManager.instance.Request(send) { (json) -> () in
                self.getReceiveInit(json)
                return
            }
        }
        
        DataManager.instance.m_configData.m_initInfoFlow.reset {
            changeState(category: .setNotification)
        }
    }
    
    func getReceiveInit(_ json: JSON) {
        let receive = Receive_Init(json)
        switch receive.ecd {
        case .success, .join_emailAuthNone:
            DataManager.instance.m_userInfo.configData.m_rmode = receive.rmode ?? 0
            DataManager.instance.m_userInfo.configData.m_tempUnit = receive.temunit ?? "C"
            Widget_Utility.setSharedInfo(channel: Config.channelOsNum, key: .temperatureUnit, value: receive.temunit ?? "C")
            
            switch receive.step! {
            case 1,2,3:
                if (DataManager.instance.m_userInfo.configData.isMonitoring) {
//                    ReportManager.instance.fileSend(isMonitoring: true)
                }
            default: break
            }
            
            getDemoInfo()
            getPolicy()
            
            switch receive.step! {
            case 1: _ = UIManager.instance.sceneMove(scene: .joinEmailAuthNavi, animation: .coverVertical, isAnimation: false)
            case 2: _ = UIManager.instance.sceneMove(scene: .joinUserInfoNavi, animation: .coverVertical, isAnimation: false)
            case 3:
                Widget_Utility.setSharedInfo(channel: Config.channelOsNum, key: .account_id, value: DataManager.instance.m_userInfo.account_id.description)
                Widget_Utility.setSharedInfo(channel: Config.channelOsNum, key: .token, value: DataManager.instance.m_userInfo.token)
                
                changeState(category: .setNotification)
            default:
                Debug.print("[⚪️][Init][ERROR] invaild errcod", event: .error)
                self.changeState(category: .initFail)
            }
        default:
            Debug.print("[⚪️][Init][ERROR] invaild errcod", event: .error)
            self.changeState(category: .initFail)
        }
    }
    
    func getDemoInfo() {
        let send = Send_GetDemoInfo()
        send.os = Config.OS
        send.isIndicator = false
        send.logPrintLevel = .warning
        send.isResending = true
        NetworkManager.instance.Request(send) { (json) -> () in
            let receive = Receive_GetDemoInfo(json)
            switch receive.ecd {
            case .success:
                DataManager.instance.m_userInfo.configData.m_demoInfo.m_threshold = receive.threshold ?? 30
                DataManager.instance.m_userInfo.configData.m_demoInfo.m_count_time = receive.count_time ?? 3
                DataManager.instance.m_userInfo.configData.m_demoInfo.m_alarm_delay = receive.alarm_delay ?? 2.0
                DataManager.instance.m_userInfo.configData.m_demoInfo.m_ignore_delay = receive.ignore_delay ?? 3.0
            default:
                Debug.print("[⚪️][Init][ERROR] getDemoInfo() invaild errcod", event: .error)
            }
        }
    }
    
    func getPolicy() {
        let send = Send_GetPolicy()
        send.aid = DataManager.instance.m_userInfo.account_id
        send.token = DataManager.instance.m_userInfo.token
        NetworkManager.instance.Request(send) { (json) -> () in
            let receive = Receive_GetPolicy(json)
            switch receive.ecd {
            case .success: DataManager.instance.m_userInfo.arrPolicy = receive.data
            default: Debug.print("[⚪️][Init][ERROR] getPolicy() invaild errcod", event: .error)
            }
        }
    }
    
    // get user info
    func getUserInfo() {
        DataManager.instance.m_dataController.userInfo.updateUserInfo(handler: { (isSuccess) in
            if (isSuccess) {
                self.changeState(category: .updateStatus)
            } else {
                let _errStr = String(format: "dialog_contents_err_communication_with_server".localized, APP_ERR_COD.userInfo.rawValue)
                _ = PopupManager.instance.onlyContentsCustom(contents: _errStr, confirmType: .ok, okHandler: { () -> () in
                    self.changeState(category: .initFail)
                })
            }
        })
    }
    
    func updateStatus() {
        DataManager.instance.m_dataController.deviceStatus.initFullStatus(handler: { (isSuccess) in
            if (isSuccess) {
                self.changeState(category: .setEtc)
            } else {
                let _errStr = String(format: "dialog_contents_err_communication_with_server".localized, APP_ERR_COD.initFullStatus.rawValue)
                _ = PopupManager.instance.onlyContentsCustom(contents: _errStr, confirmType: .ok, okHandler: { () -> () in
                    self.changeState(category: .initFail)
                })
            }
        })
    }
    
    func setEtc() {
        DataManager.instance.m_configData.m_etcInfoFlow.one {
            DataManager.instance.m_dataController.deviceNoti.setInit()
            DataManager.instance.m_dataController.deviceNotiReady.setInit()
            DataManager.instance.m_dataController.shareMemberNoti.setInit()
            DataManager.instance.m_dataController.storeConnectedSensor.setInit()
            DataManager.instance.m_dataController.storeConnectedLamp.setInit()
            DataManager.instance.m_dataController.hubGraph.setInit()
            DataManager.instance.m_dataController.lampGraph.setInit()
            DataManager.instance.m_dataController.newAlarm.setInit()
            DataManager.instance.m_dataController.sensorMovGraph.setInit()
            DataManager.instance.m_dataController.sensorVocGraph.setInit()
            DataManager.instance.m_dataController.diaperSensingLog.sendingData(id: nil, did: nil)
        }
        self.changeState(category: .setBle)
    }
    
    func setBle() {
        BleConnectionManager.instance.initManager()
        BleConnectionLampManager.instance.initManager()
        m_isFinishedLoading = true
    }
    
    func setFinish() {
        if (!DataManager.instance.m_userInfo.isSignin) {
            InitViewController.m_initUserDataFinished = false

            if (DataManager.instance.m_configData.m_initInfoFlow.isOne) {
                SystemManager.instance.resetData()
            }
            
            _ = UIManager.instance.sceneMove(scene: .mainSignin, animation: .coverVertical, isAnimation: false)
            // 팝업 공지사항
            switch Config.channel {
            case .monitXHuggies:
                break
                /// 20221121 - 국내Monit Sever를 사용하기 위한 조치
//                _ = PopupManager.instance.withTitleCustom(title: "notice_title".localized, contents: "rast_notice".localized, confirmType: .cancleOK, okHandler: {() -> () in
//                    _ = Utility.urlOpen("itms-apps://itunes.apple.com/app/id1290625994")
//                },cancleHandler:{() -> () in return})
            default:
                break
            }
            
        } else {
            InitViewController.m_initUserDataFinished = true
            _ = UIManager.instance.sceneMove(scene: .mainDeviceNavi, animation: .coverVertical, isAnimation: false)
        }
        
//        ScreenAnalyticsManager.instance.goForegroundSession()
    }
    func animate()
    {
        // MARK: 1. 여기는 Huggies가 아닌 goodmonit으로 해야함.
        switch Config.channel {
        case .goodmonit,
             .monitXHuggies,/// 20221121 추가
             .kao:
            imgSplashGoodmonit.image = UIImage(named: "imgSplash_28")!
            imgSplashGoodmonit.animationDuration = 2
            imgSplashGoodmonit.animationRepeatCount = 1
            imgSplashGoodmonit.isHidden = false
            var images = [UIImage]()
            for i in 1...28 {
                images.append(UIImage(named: "imgSplash_\(i)")!)
            }
            imgSplashGoodmonit.animationImages = images
            imgSplashGoodmonit.startAnimating()
            Debug.print("[⚪️][Init] animationDuration: \(imgSplashGoodmonit.animationDuration)")
            self.perform(#selector(animateFinished_goodmonit), with: nil, afterDelay: imgSplashGoodmonit.animationDuration)
            
            /// 20221121 - 국내Monit Sever를 사용하기 위한 조치
//        case .monitXHuggies:
//            imgSplashMonitXHuggies.isHidden = false
//            self.perform(#selector(animateFinished_monitXHuggies), with: nil, afterDelay: 1)
        case .kc:
            imgSplashKc.isHidden = false
            self.perform(#selector(animateFinished_kc), with: nil, afterDelay: 1)
        }
        
    }
    
    @objc func animateFinished_goodmonit() {
        imgSplashGoodmonit.stopAnimating()
        self.perform(#selector(animateFinishedDelay), with: nil, afterDelay: 0.5)
    }
    
    @objc func animateFinished_monitXHuggies() {
        imgSplashGoodmonit.stopAnimating()
        self.perform(#selector(animateFinishedDelay), with: nil, afterDelay: 0.5)
        /// 20221121 - 국내Monit Sever를 사용하기 위한 조치
        //animateFinishedDelay()
    }
    
    @objc func animateFinished_kc() {
        animateFinishedDelay()
    }
    
    @objc func animateFinishedDelay() {
        m_isFinishedAniamtion = true
    }
    
    func initFail() {
        SystemManager.instance.logOut()
    }
    
    func exitApp() {
        let _errStr = String(format: "dialog_contents_err_communication_with_server".localized, APP_ERR_COD.exitApp.rawValue)
        _ = PopupManager.instance.onlyContentsCustom(contents: _errStr, confirmType: .ok, okHandler: { () -> () in
            SystemManager.instance.exitApp()
        })
    }
}

