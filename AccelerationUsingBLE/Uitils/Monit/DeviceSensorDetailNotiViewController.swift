//
//  DeviceSensorDetailNotiViewController.swift
//  Monit
//
//  Created by 맥 on 2018. 1. 3..
//  Copyright © 2018년 맥. All rights reserved.
//

import UIKit

class DeviceSensorDetailNotiViewController: DeviceDetailNotiBaseViewController {

    @IBOutlet var feedbackV2View: FeedbackMenuV2View!
    @IBOutlet weak var viewFilter: UIView!
    @IBOutlet weak var btnDiaperFilter: UIButton!
    @IBOutlet weak var btnPeeFilter: UIButton!
    @IBOutlet weak var btnPooFilter: UIButton!
    @IBOutlet weak var btnFartFilter: UIButton!
    @IBOutlet weak var btnWarningFilter: UIButton!

    override var screenType: SCREEN_TYPE { get { return .SENSOR_DETAIL_NOTI } }
    var m_parent: DeviceSensorDetailPageViewController?
    var m_arrSensorNotiType = [DEVICE_NOTI_TYPE]()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if (DataManager.instance.m_userInfo.configData.isBeta) {
            setFeedbackV2ViewUI()
        }
        if (Config.channel != .kc) {
            viewFilter.isHidden = true
            table.frame = view.frame
        }
        
        sensorSetUI()
    }
    
    override func reloadInfoChild() {
        super.reloadInfoChild()
        sensorSetUI()
    }
    
    func setInit(type: Int, did: Int) {
        if (Config.channel != .kc) {
            m_arrSensorNotiType.append(DEVICE_NOTI_TYPE.pee_detected)
            m_arrSensorNotiType.append(DEVICE_NOTI_TYPE.poo_detected)
            m_arrSensorNotiType.append(DEVICE_NOTI_TYPE.diaper_changed)
            m_arrSensorNotiType.append(DEVICE_NOTI_TYPE.sleep_mode)
            m_arrSensorNotiType.append(DEVICE_NOTI_TYPE.diaper_score)
        } else {
            m_arrSensorNotiType.append(DEVICE_NOTI_TYPE.pee_detected)
            m_arrSensorNotiType.append(DEVICE_NOTI_TYPE.poo_detected)
            m_arrSensorNotiType.append(DEVICE_NOTI_TYPE.abnormal_detected)
            m_arrSensorNotiType.append(DEVICE_NOTI_TYPE.diaper_changed)
        }
        
        if (DataManager.instance.m_userInfo.configData.isBeta) {
            m_arrSensorNotiType.removeAll()
            if (DataManager.instance.m_userInfo.shareDevice.isAlarmStatus(did: did, type: DEVICE_TYPE.Sensor.rawValue, almType: ALRAM_TYPE.fart) ?? false ) {
                m_arrSensorNotiType.append(DEVICE_NOTI_TYPE.fart_detected)
            }
            
            m_arrSensorNotiType.append(DEVICE_NOTI_TYPE.pee_detected)
            m_arrSensorNotiType.append(DEVICE_NOTI_TYPE.poo_detected)
            m_arrSensorNotiType.append(DEVICE_NOTI_TYPE.abnormal_detected)
            m_arrSensorNotiType.append(DEVICE_NOTI_TYPE.diaper_changed)
            m_arrSensorNotiType.append(DEVICE_NOTI_TYPE.detect_diaper_changed)
            m_arrSensorNotiType.append(DEVICE_NOTI_TYPE.custom_memo)
            m_arrSensorNotiType.append(DEVICE_NOTI_TYPE.custom_status)
            m_arrSensorNotiType.append(DEVICE_NOTI_TYPE.sleep_mode)
            m_arrSensorNotiType.append(DEVICE_NOTI_TYPE.diaper_score)
        }

        super.setInit(notiType: m_arrSensorNotiType, type: type, did: did)
    }
    
    func sensorSetUI() {
        btnDiaperFilter.setImage(UIImage(named: m_arrSensorNotiType.contains(.diaper_changed) ?     "imgDiaperNormalDetail"   : "imgDiaperDisableDetail"), for: .normal)
        btnPeeFilter.setImage(UIImage(named: m_arrSensorNotiType.contains(.pee_detected) ?          "imgPeeNormalDetail"      : "imgPeeDisableDetail"), for: .normal)
        btnPooFilter.setImage(UIImage(named: m_arrSensorNotiType.contains(.poo_detected) ?          "imgPooNormalDetail"      : "imgPooDisableDetail"), for: .normal)
        btnFartFilter.setImage(UIImage(named: m_arrSensorNotiType.contains(.fart_detected) ?        "imgFartNormalDetail"     : "imgFartDisableDetail"), for: .normal)
        btnWarningFilter.setImage(UIImage(named: m_arrSensorNotiType.contains(.abnormal_detected) ? "imgWarningNormalDetail"  : "imgWarningDisableDetail"), for: .normal)
        
        UI_Utility.customButtonShadow(button: btnDiaperFilter, radius: 1, offsetWidth: 0, offsetHeight: 1, color: UIColor.black.cgColor, opacity: 0.5)
        UI_Utility.customButtonShadow(button: btnPeeFilter, radius: 1, offsetWidth: 0, offsetHeight: 1, color: UIColor.black.cgColor, opacity: 0.5)
        UI_Utility.customButtonShadow(button: btnPooFilter, radius: 1, offsetWidth: 0, offsetHeight: 1, color: UIColor.black.cgColor, opacity: 0.5)
        UI_Utility.customButtonShadow(button: btnFartFilter, radius: 1, offsetWidth: 0, offsetHeight: 1, color: UIColor.black.cgColor, opacity: 0.5)
        UI_Utility.customButtonShadow(button: btnWarningFilter, radius: 1, offsetWidth: 0, offsetHeight: 1, color: UIColor.black.cgColor, opacity: 0.5)
        
        m_parent?.m_parent?.disableNewAlarmNoti()
    }

    func setFeedbackV2ViewUI() {
        self.view.addSubview(feedbackV2View)
        feedbackV2View.m_parent = self
        feedbackV2View.setUI()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (DataManager.instance.m_userInfo.configData.isBeta) {
            let _arrData = getSectionDataByIndex(section: indexPath.section)
            let _cell = Bundle.main.loadNibNamed("DeviceNotiTableForTesterViewCell", owner: self, options: nil)?.first as! DeviceNotiTableForTesterViewCell
            let _info = _arrData[indexPath.row]
            _cell.m_parent = self
            _cell.m_deviceNotiInfo = _info
            _cell.m_sectionIndex = indexPath.section
            _cell.m_index = indexPath.row
            _cell.setInit()
            return _cell
        } else {
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
    }
    
    func changeNoti(notiType: DEVICE_NOTI_TYPE) {
        if (m_arrSensorNotiType.contains(notiType)) {
            if let _index = m_arrSensorNotiType.index(where: { $0 == notiType }) {
                m_arrSensorNotiType.remove(at: _index)
            }
        } else {
            m_arrSensorNotiType.append(notiType)
        }
        
        sensorSetUI()
    }

    @IBAction func onClick_diaperFilter(_ sender: UIButton) {
        changeNoti(notiType: .diaper_changed)
        setFilter(notiType: m_arrSensorNotiType, type: m_type, did: m_did)
    }
    
    @IBAction func onClick_peeFilter(_ sender: UIButton) {
        changeNoti(notiType: .pee_detected)
        setFilter(notiType: m_arrSensorNotiType, type: m_type, did: m_did)
    }
    
    @IBAction func onClick_pooFilter(_ sender: UIButton) {
        changeNoti(notiType: .poo_detected)
        setFilter(notiType: m_arrSensorNotiType, type: m_type, did: m_did)
    }
    
    @IBAction func onClick_fartFilter(_ sender: UIButton) {
        changeNoti(notiType: .fart_detected)
        setFilter(notiType: m_arrSensorNotiType, type: m_type, did: m_did)
    }
    
    @IBAction func onClick_warningFilter(_ sender: UIButton) {
        changeNoti(notiType: .abnormal_detected)
        setFilter(notiType: m_arrSensorNotiType, type: m_type, did: m_did)
    }
}
