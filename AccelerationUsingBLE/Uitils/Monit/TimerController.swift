//
//  TimerController.swift
//  Monit
//
//  Created by john.lee on 2019. 3. 21..
//  Copyright © 2019년 맥. All rights reserved.
//

import Foundation

class TimerController {
    var m_updateTimer: Timer?
    var m_interval: Double = 0.1
    var m_during: Double = 0
    var m_finishTime: Double = 0
    var m_updateCallback: Action?
    var m_finishCallback: Action?
    
    var isPlaying: Bool {
        get {
            if (m_updateTimer != nil) {
                return true
            }
            return false
        }
    }
    
    func start(interval: Double = 0.1, finishTime: Double = 0, updateCallback: Action? = nil, finishCallback: Action? = nil) {
        self.m_during = 0
        self.m_interval = interval
        self.m_finishTime = finishTime
        self.m_updateCallback = updateCallback
        self.m_finishCallback = finishCallback
        self.m_updateTimer?.invalidate()
        self.m_updateTimer = Timer.scheduledTimer(timeInterval: m_interval, target: self, selector: #selector(update), userInfo: nil, repeats: true)
    }
    
    func reset() {
        self.m_during = 0
        self.m_updateTimer?.invalidate()
        self.m_updateTimer = Timer.scheduledTimer(timeInterval: m_interval, target: self, selector: #selector(update), userInfo: nil, repeats: true)
    }
    
    @objc func update() {
        if (m_finishTime != 0 && m_during >= m_finishTime) {
            stop()
        }
        m_updateCallback?()
        m_during += m_interval
    }
    
    func stop() {
        m_during = 0
        m_updateTimer?.invalidate()
        m_updateTimer = nil
        m_finishCallback?()
    }
}
