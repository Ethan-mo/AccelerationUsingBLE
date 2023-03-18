//
//  DeviceLampDetailNotiViewController.swift
//  Monit
//
//  Created by 맥 on 2018. 1. 3..
//  Copyright © 2018년 맥. All rights reserved.
//

import UIKit

class DeviceLampDetailNotiViewController: DeviceDetailNotiBaseViewController {

    @IBOutlet weak var viewFilter: UIView!
    @IBOutlet weak var btnTemFilter: UIButton!
    @IBOutlet weak var btnHumFilter: UIButton!
    @IBOutlet weak var stView: UIStackView!
    
    override var screenType: SCREEN_TYPE { get { return .HUB_DETAIL_NOTI } }
    var m_parent: DeviceLampDetailPageViewController?
    var m_arrLampNotiType = [DEVICE_NOTI_TYPE]()

    override func viewDidLoad() {
        super.viewDidLoad()
        stView.layoutIfNeeded()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if (Config.channel != .kc) {
            viewFilter.isHidden = true
            table.frame = view.frame
        }
        
        lampSetUI()
    }
    
    override func reloadInfoChild() {
        super.reloadInfoChild()
        lampSetUI()
    }
    
    func setInit(type: Int, did: Int) {
        m_arrLampNotiType.append(DEVICE_NOTI_TYPE.low_temperature)
        m_arrLampNotiType.append(DEVICE_NOTI_TYPE.high_temperature)
        m_arrLampNotiType.append(DEVICE_NOTI_TYPE.low_humidity)
        m_arrLampNotiType.append(DEVICE_NOTI_TYPE.high_humidity)
        m_arrLampNotiType.append(DEVICE_NOTI_TYPE.low_battery)

        super.setInit(notiType: m_arrLampNotiType, type: type, did: did)
    }
    
    func lampSetUI() {
        btnTemFilter.setImage(UIImage(named: m_arrLampNotiType.contains(.low_temperature) ?     "imgTempNormalDetail"   : "imgTempDisableDetail"), for: .normal)
        btnTemFilter.setImage(UIImage(named: m_arrLampNotiType.contains(.high_temperature) ?     "imgTempNormalDetail"   : "imgTempDisableDetail"), for: .normal)
        
        btnHumFilter.setImage(UIImage(named: m_arrLampNotiType.contains(.low_humidity) ?          "imgHumNormalDetail"      : "imgHumDisableDetail"), for: .normal)
        btnHumFilter.setImage(UIImage(named: m_arrLampNotiType.contains(.high_humidity) ?          "imgHumNormalDetail"      : "imgHumDisableDetail"), for: .normal)
        
        UI_Utility.customButtonShadow(button: btnTemFilter, radius: 1, offsetWidth: 0, offsetHeight: 1, color: UIColor.black.cgColor, opacity: 0.5)
        UI_Utility.customButtonShadow(button: btnHumFilter, radius: 1, offsetWidth: 0, offsetHeight: 1, color: UIColor.black.cgColor, opacity: 0.5)

        m_parent?.m_parent?.disableNewAlarmNoti()
    }
    
    func changeNoti(notiType: [DEVICE_NOTI_TYPE]) {
        for item in notiType {
            if (m_arrLampNotiType.contains(item)) {
                if let _index = m_arrLampNotiType.index(where: { $0 == item }) {
                    m_arrLampNotiType.remove(at: _index)
                }
            } else {
                m_arrLampNotiType.append(item)
            }
        }
        
        lampSetUI()
    }
    
    @IBAction func onClick_temFilter(_ sender: UIButton) {
        changeNoti(notiType: [.low_temperature, .high_temperature])
        setFilter(notiType: m_arrLampNotiType, type: m_type, did: m_did)
    }
    
    @IBAction func onClick_humFilter(_ sender: UIButton) {
        changeNoti(notiType: [.low_humidity, .high_humidity])
        setFilter(notiType: m_arrLampNotiType, type: m_type, did: m_did)
    }
}
