//
//  DeviceHubDetailNotiViewController.swift
//  Monit
//
//  Created by 맥 on 2018. 1. 3..
//  Copyright © 2018년 맥. All rights reserved.
//

import UIKit

class DeviceHubDetailNotiViewController: DeviceDetailNotiBaseViewController {

    @IBOutlet weak var viewFilter: UIView!
    @IBOutlet weak var btnTemFilter: UIButton!
    @IBOutlet weak var btnHumFilter: UIButton!
    @IBOutlet weak var btnVocWarningFilter: UIButton!
    @IBOutlet weak var stView: UIStackView!
    @IBOutlet weak var viewVoc: UIView!
    
    override var screenType: SCREEN_TYPE { get { return .HUB_DETAIL_NOTI } }
    var m_parent: DeviceHubDetailPageViewController?
    var m_arrHubNotiType = [DEVICE_NOTI_TYPE]()

    override func viewDidLoad() {
        super.viewDidLoad()
        viewVoc.isHidden = true
        switch Config.channel {
        case .goodmonit, .monitXHuggies:
            viewVoc.isHidden = false
        case .kc, .kao: break
        }
        stView.layoutIfNeeded()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if (Config.channel != .kc) {
            viewFilter.isHidden = true
            table.frame = view.frame
        }
        
        hubSetUI()
    }
    
    override func reloadInfoChild() {
        super.reloadInfoChild()
        hubSetUI()
    }
    
    func setInit(type: Int, did: Int) {
        m_arrHubNotiType.append(DEVICE_NOTI_TYPE.low_temperature)
        m_arrHubNotiType.append(DEVICE_NOTI_TYPE.high_temperature)
        m_arrHubNotiType.append(DEVICE_NOTI_TYPE.low_humidity)
        m_arrHubNotiType.append(DEVICE_NOTI_TYPE.high_humidity)

        switch Config.channel {
        case .goodmonit, .monitXHuggies, .kao:
            m_arrHubNotiType.append(DEVICE_NOTI_TYPE.voc_warning)
            m_arrHubNotiType.append(DEVICE_NOTI_TYPE.low_battery)
        case .kc: break
        }

        super.setInit(notiType: m_arrHubNotiType, type: type, did: did)
    }
    
    func hubSetUI() {
        if (Config.channel == .kc) {
            btnTemFilter.setImage(UIImage(named: m_arrHubNotiType.contains(.low_temperature) ?     "imgKcTempNormalDetail"   : "imgTempDisableDetail"), for: .normal)
            btnTemFilter.setImage(UIImage(named: m_arrHubNotiType.contains(.high_temperature) ?     "imgKcTempNormalDetail"   : "imgTempDisableDetail"), for: .normal)
            
            btnHumFilter.setImage(UIImage(named: m_arrHubNotiType.contains(.low_humidity) ?          "imgKcHumNormalDetail"      : "imgHumDisableDetail"), for: .normal)
            btnHumFilter.setImage(UIImage(named: m_arrHubNotiType.contains(.high_humidity) ?          "imgKcHumNormalDetail"      : "imgHumDisableDetail"), for: .normal)
        } else {
            btnTemFilter.setImage(UIImage(named: m_arrHubNotiType.contains(.low_temperature) ?     "imgTempNormalDetail"   : "imgTempDisableDetail"), for: .normal)
            btnTemFilter.setImage(UIImage(named: m_arrHubNotiType.contains(.high_temperature) ?     "imgTempNormalDetail"   : "imgTempDisableDetail"), for: .normal)
            
            btnHumFilter.setImage(UIImage(named: m_arrHubNotiType.contains(.low_humidity) ?          "imgHumNormalDetail"      : "imgHumDisableDetail"), for: .normal)
            btnHumFilter.setImage(UIImage(named: m_arrHubNotiType.contains(.high_humidity) ?          "imgHumNormalDetail"      : "imgHumDisableDetail"), for: .normal)
            
            btnVocWarningFilter.setImage(UIImage(named: m_arrHubNotiType.contains(.voc_warning) ?          "imgVocNormalDetail"      : "imgVocDisableDetail"), for: .normal)
        }
        
        UI_Utility.customButtonShadow(button: btnTemFilter, radius: 1, offsetWidth: 0, offsetHeight: 1, color: UIColor.black.cgColor, opacity: 0.5)
        UI_Utility.customButtonShadow(button: btnHumFilter, radius: 1, offsetWidth: 0, offsetHeight: 1, color: UIColor.black.cgColor, opacity: 0.5)
        UI_Utility.customButtonShadow(button: btnVocWarningFilter, radius: 1, offsetWidth: 0, offsetHeight: 1, color: UIColor.black.cgColor, opacity: 0.5)

        m_parent?.m_parent?.disableNewAlarmNoti()
    }
    
    func changeNoti(notiType: [DEVICE_NOTI_TYPE]) {
        for item in notiType {
            if (m_arrHubNotiType.contains(item)) {
                if let _index = m_arrHubNotiType.index(where: { $0 == item }) {
                    m_arrHubNotiType.remove(at: _index)
                }
            } else {
                m_arrHubNotiType.append(item)
            }
        }
        
        hubSetUI()
    }
    
    @IBAction func onClick_temFilter(_ sender: UIButton) {
        changeNoti(notiType: [.low_temperature, .high_temperature])
        setFilter(notiType: m_arrHubNotiType, type: m_type, did: m_did)
    }
    
    @IBAction func onClick_humFilter(_ sender: UIButton) {
        changeNoti(notiType: [.low_humidity, .high_humidity])
        setFilter(notiType: m_arrHubNotiType, type: m_type, did: m_did)
    }
    
    @IBAction func onClick_vocWarningFilter(_ sender: UIButton) {
        changeNoti(notiType: [.voc_warning])
        setFilter(notiType: m_arrHubNotiType, type: m_type, did: m_did)
    }
}
