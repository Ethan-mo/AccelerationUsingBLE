//
//  WifiCustomSecuView.swift
//  Monit
//
//  Created by 맥 on 2017. 10. 9..
//  Copyright © 2017년 맥. All rights reserved.
//

import UIKit
import CoreBluetooth

class WifiCustomSecuView: UIView, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSummary: UILabel!
    
    @IBOutlet weak var table: UITableView!
    
    var m_detailInfo: WifiConnectDetailInfo?
    var m_arrSecuType = [WIFI_SECURITY_TYPE]()
    var m_selectValue: WIFI_SECURITY_TYPE?
    var registerType: HUB_TYPES_REGISTER_TYPE = .new
    var m_peripheral: CBPeripheral?
    
    var connectInfo: HubConnectionController? {
        get {
            if let _info = DataManager.instance.m_userInfo.connectSensor.getSensorByDeviceId(deviceId: m_detailInfo!.m_sensorDid) {
                return _info.controller!.m_hubConnectionController
            }
            return nil
        }
    }
    
    func setInfo(info: WifiConnectDetailInfo) {
        table.delegate = self
        table.dataSource = self
        self.m_detailInfo = info
        setSecurityList()
        
        if let _info = connectInfo {
            m_selectValue = WIFI_SECURITY_TYPE(rawValue: _info.m_apSecurityType)
        }
        
        lblTitle.text = "connection_hub_add_new_network_title".localized
        lblSummary.text = "connection_hub_network_security".localized
    }
    
    func setSecurityList() {
        m_arrSecuType.removeAll()
        for item in WIFI_SECURITY_TYPE.allValues {
            m_arrSecuType.append(item)
        }
    }
    
    func tableView(_  tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return m_arrSecuType.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = Bundle.main.loadNibNamed("WifiSecuTypeTableViewCell", owner: self, options: nil)?.first as! WifiSecuTypeTableViewCell
        
        if let _value = m_selectValue {
            cell.setInfo(type: m_arrSecuType[indexPath.row], isEnable: m_arrSecuType[indexPath.row] == _value)
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        Debug.print("section: \(indexPath.section)")
        Debug.print("row: \(indexPath.row)")
        
        m_selectValue = m_arrSecuType[indexPath.row]
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.001
    }
}
