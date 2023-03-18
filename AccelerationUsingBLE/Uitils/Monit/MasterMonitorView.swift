//
//  DebugView.swift
//  Monit
//
//  Created by 맥 on 2017. 10. 30..
//  Copyright © 2017년 맥. All rights reserved.
//

import UIKit

class MasterMonitorView: UIView {

    @IBOutlet weak var lblVersion: UILabel!
    @IBOutlet weak var lblAcInfo: UILabel!
    @IBOutlet weak var logView: UITextView!
    @IBOutlet weak var btnLogView1: UIButton!
    @IBOutlet weak var btnLogView2: UIButton!
    @IBOutlet weak var btnLogView3: UIButton!
    
    @IBOutlet weak var lblCameraIP: UILabel!
    @IBOutlet weak var txtCameraIP: UITextField!
    
    var camera_ip: String {
        get { return DataManager.instance.m_configData.getLocalStringAes256(name: "camera_ip") }
        set { DataManager.instance.m_configData.setLocalAes256(name: "camera_ip", value: newValue.description) }
    }
    
    func setInfo() {
        lblVersion.text = Config.debugBundleVersion
        btnLogView1.setTitle(ReportManager.instance.getDate(intervalDay: 0), for: .normal)
        btnLogView2.setTitle(ReportManager.instance.getDate(intervalDay: 1), for: .normal)
        btnLogView3.setTitle(ReportManager.instance.getDate(intervalDay: 2), for: .normal)
        
        lblCameraIP.text = camera_ip
    }

    @IBAction func onClick_killTest(_ sender: UIButton) {
        kill(getpid(), SIGKILL)
    }
    
    @IBAction func onClick_coredataInit(_ sender: UIButton) {
        DataManager.instance.m_userInfo.initInfo()
        DataManager.instance.m_coreDataInfo.initInfo()
        DataManager.instance.m_configData.isTerminateNoti = true
    }

    @IBAction func onClick_Close(_ sender: UIButton) {
        self.removeFromSuperview()
    }
    
    @IBAction func onClick_Crash(_ sender: UIButton) {
        fatalError()
    }
    
    @IBAction func onClick_LogView1(_ sender: UIButton) {
        logView.text = ReportManager.instance.read(intervalDay: 0)
    }
    
    @IBAction func onClick_LogView2(_ sender: UIButton) {
        logView.text = ReportManager.instance.read(intervalDay: 1)
    }
    
    @IBAction func onClick_LogView3(_ sender: UIButton) {
        logView.text = ReportManager.instance.read(intervalDay: 2)
    }
    
    @IBAction func onClick_LogDelete(_ sender: UIButton) {
        ReportManager.instance.deleteSpecific(interval: 0)
    }

    @IBAction func onClick_LogLevel(_ sender: UIButton) {
        if (Config.DEBUG_PRINT_LEVEL == .all) {
            Config.DEBUG_PRINT_LEVEL = .warning
        } else {
            Config.DEBUG_PRINT_LEVEL = .all
        }
    }
    
    @IBAction func onClick_sensor_Disconnect(_ sender: UIButton) {
        for item in DataManager.instance.m_userInfo.connectSensor.m_connectSensor {
            BleConnectionManager.instance.manager.cancelPeripheralConnection(item.peripheral!)
        }
    }
    
    @IBAction func onClick_cameraIPSave(_ sender: UIButton) {
        camera_ip = txtCameraIP.text ?? ""
    }
}
