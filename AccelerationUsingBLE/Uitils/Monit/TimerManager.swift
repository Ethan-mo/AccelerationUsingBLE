//
//  TimerManager.swift
//  Monit
//
//  Created by 맥 on 2017. 10. 30..
//  Copyright © 2017년 맥. All rights reserved.
//

import UIKit

class TimerManager {
    static var m_instance: TimerManager!
    static var instance: TimerManager {
        get {
            if (m_instance == nil) {
                m_instance = TimerManager()
            }
            
            return m_instance
        }
    }
    
    var m_interval = 1.0
    var m_fullStatusTimer: Timer?
    var m_fullStatusTime: Double = 0
    var m_statusTimer: Timer?
    var m_statusTime: Double = 0
    
    var isUpdateContinue: Bool {
        get {
            if (UIApplication.shared.applicationState == .background) {
                return true
            }
            
            return false
        }
    }
    
    func initFullStatusTime() {
        m_fullStatusTime = 0
    }
    
    func startFullStatus() {
        initFullStatusTime()
        self.m_fullStatusTimer?.invalidate()
        self.m_fullStatusTimer = Timer.scheduledTimer(timeInterval: m_interval, target: self, selector: #selector(fullStatusUpdate), userInfo: nil, repeats: true)
    }
    
    @objc func fullStatusUpdate() {
        if (m_fullStatusTime > Config.FULL_STATUS_TIME)
        {
            m_fullStatusTime = 0
            
            if (isUpdateContinue) {
                return
            }
            
            DataManager.instance.m_dataController.deviceNotiReady.sendReadyInfo()
            DataManager.instance.m_dataController.deviceStatus.updateFullStatus(handler: { (isSuccess) in
                if (isSuccess) {
                    UIManager.instance.currentUIReload()
                } else {
//                    UIManager.instance.deviceRefrash()
                }
            })
        } else {
            m_fullStatusTime += m_interval
        }
    }
    
    func initStatusTime() {
        m_statusTime = 0
    }
    
    func startStatus() {
        initStatusTime()
        self.m_statusTimer?.invalidate()
        self.m_statusTimer = Timer.scheduledTimer(timeInterval: m_interval, target: self, selector: #selector(statusUpdate), userInfo: nil, repeats: true)
    }
    
    @objc func statusUpdate() {
        if (m_statusTime > Config.STATUS_TIME)
        {
            m_statusTime = 0
            
            if (isUpdateContinue) {
                return
            }
            
            DataManager.instance.m_dataController.deviceNotiReady.sendReadyInfo()
            DataManager.instance.m_dataController.deviceStatus.updateStatus(handler: { (isSuccess) in
                if (isSuccess) {
                    UIManager.instance.currentUIReload()
                } else {
//                    UIManager.instance.deviceRefrash()
                }
            })
        } else {
            m_statusTime += m_interval
        }
    }
    
    func breakTimer() {
        m_fullStatusTimer?.invalidate()
        m_statusTimer?.invalidate()
    }
}

