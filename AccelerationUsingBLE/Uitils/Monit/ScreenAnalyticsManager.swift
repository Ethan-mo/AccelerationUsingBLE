//
//  ScreenAnalyticsManagerViewController.swift
//  Monit
//
//  Created by john.lee on 2018. 11. 1..
//  Copyright © 2018년 맥. All rights reserved.
//

import Foundation
import Firebase

public class ScreenAnalyticsManager {
    static var m_instance: ScreenAnalyticsManager!
    static var instance: ScreenAnalyticsManager {
        get {
            if (m_instance == nil) {
                m_instance = ScreenAnalyticsManager()
            }
            
            return m_instance
        }
    }
    
    var m_currentScreen: SCREEN_TYPE = .none
    var m_stTime: String?

    func setScreen(screenType: SCREEN_TYPE) {
        guard (screenType != .none) else { return }
        if (m_currentScreen == screenType) {
            return
        }
        Debug.print("screen: \(m_currentScreen) -> \(screenType)", event: .dev)
        if (m_currentScreen != .none) {
            sendScreenAnalytics()
        }
        setCurrentScreen(screenType: screenType)
    }
    
    func setCurrentScreen(screenType: SCREEN_TYPE) {
        m_currentScreen = screenType
        m_stTime = UI_Utility.nowUTCDate(type: .yyMMdd_HHmmss)
    }
    
    func initCurrentScreen() {
        m_currentScreen = .none
        m_stTime = nil
    }
    
    func goForegroundSession() {
        sendBackgroundInfo()

        if let _currentView = UIManager.instance.rootCurrentView as? BaseViewController {
            setScreen(screenType: _currentView.screenType)
        } else {
            Debug.print("[⚪️][Init][ERROR] goForegroundSession() _currentView is null", event: .error)
        }
    }
    
    func goBackgroundSession() {
        Debug.print("screen: \(m_currentScreen) -> background", event: .warning)
        DataManager.instance.m_configData.backgroundScType = m_currentScreen.rawValue
        DataManager.instance.m_configData.backgroundScStTime = m_stTime ?? ""
        DataManager.instance.m_configData.backgroundScEdTime = UI_Utility.nowUTCDate(type: .yyMMdd_HHmmss)
        initCurrentScreen()
    }
    
    func initBackgroundInfo() {
        DataManager.instance.m_configData.backgroundScType = 0
        DataManager.instance.m_configData.backgroundScStTime = ""
        DataManager.instance.m_configData.backgroundScEdTime = ""
    }
    
    func sendBackgroundInfo() {
        guard (DataManager.instance.m_configData.backgroundScType != 0) else { return }
        Debug.print("[Screen] SendBackgroundInfo", event: .warning)
        
        let _send = Send_ScreenAnalytics()
        _send.isIndicator = false
        _send.isErrorPopupOn = false
        _send.aid = DataManager.instance.m_userInfo.account_id
        _send.sctype = DataManager.instance.m_configData.backgroundScType
        _send.stime = DataManager.instance.m_configData.backgroundScStTime
        _send.etime = DataManager.instance.m_configData.backgroundScEdTime
        NetworkManager.instance.Request(_send) { (json) -> () in
            let receive = Receive_ScreenAnalytics(json)
            switch receive.ecd {
            case .success: self.initBackgroundInfo()
            default: Debug.print("[⚪️][Init][ERROR] sendBackgroundInfo invaild errcod", event: .error)
            }
        }
    }
    
    func sendScreenAnalytics() {
        let _send = Send_ScreenAnalytics()
        _send.isIndicator = false
        _send.isErrorPopupOn = false
        _send.aid = DataManager.instance.m_userInfo.account_id
        _send.sctype = m_currentScreen.rawValue
        _send.stime = m_stTime
        _send.etime = UI_Utility.nowUTCDate(type: .yyMMdd_HHmmss)
        NetworkManager.instance.Request(_send) { (json) -> () in
            let receive = Receive_ScreenAnalytics(json)
            switch receive.ecd {
            case .success: break
            default: Debug.print("[⚪️][Init][ERROR] sendScreenAnalytics invaild errcod", event: .error)
            }
        }
    }
    
    func googleTagManagerForEvent(type: GOOGLE_TAG_MANAGER_TYPE, category: String = "", action: String = "", lable: String = "") {
        var _dicData = [String: String]()
        if (category != "") {
            _dicData.updateValue(category, forKey: "event_category")
        }
        if (action != "") {
            _dicData.updateValue(action, forKey: "event_action")
        }
        if (lable != "") {
            _dicData.updateValue(lable, forKey: "event_label")
        }
       
        Analytics.logEvent(type.rawValue, parameters: _dicData)
    }
    
//    func googleTagManagerCustom(type: GOOGLE_TAG_MANAGER_TYPE, key: String, value: String) {
//        Analytics.logEvent(type.rawValue, parameters: [key: value])
//    }
    
    func googleTagManagerCustom(type: GOOGLE_TAG_MANAGER_TYPE, items: [String: String]) {
        Analytics.logEvent(type.rawValue, parameters: items)
    }
}
