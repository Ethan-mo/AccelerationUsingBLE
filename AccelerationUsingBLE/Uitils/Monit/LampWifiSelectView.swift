//
//  WifiSelectView.swift
//  Monit
//
//  Created by 맥 on 2017. 10. 9..
//  Copyright © 2017년 맥. All rights reserved.
//

import UIKit
import CoreBluetooth

class LampWifiSelectView: UIView, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var lblSummary: UILabel!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var btnRefresh: UIButton!
    @IBOutlet weak var lblRefresh: UILabel!
    
    var m_detailInfo: LampWifiConnectDetailInfo?
    var m_arrList = [WifiSelectItemInfo]()
    var m_scanUpdateTime: Float = 0
    var m_scanTimer: Timer?
    var registerType: HUB_TYPES_REGISTER_TYPE = .new
    var m_peripheral: CBPeripheral?

    var bleInfo: BleLampInfo? {
        get {
            return DataManager.instance.m_userInfo.connectLamp.getLampByDeviceId(deviceId: m_detailInfo!.m_lampDid)
        }
    }
    
    var connectInfo: LampConnectionController? {
        get {
            if let _info = DataManager.instance.m_userInfo.connectLamp.getLampByDeviceId(deviceId: m_detailInfo!.m_lampDid) {
                return _info.controller!.m_lampConnectionController
            }
            return nil
        }
    }
    
    var alreadyLamp: LampStatusInfo? {
        get {
            return DataManager.instance.m_userInfo.deviceStatus.m_lampStatus.getInfoByDeviceId(did: m_detailInfo?.m_lampDid ?? 0)
        }
    }
    
    func setInfo(info: LampWifiConnectDetailInfo) {
        table.delegate = self
        table.dataSource = self
        m_detailInfo = info
        btnRefresh.isHidden = true
        lblRefresh.isHidden = true
        startScaning()

        lblSummary.text = "connection_hub_scan_network_list".localized
        lblRefresh.text = "btn_refresh".localized
    }
    
    func startScaning() {
        self.m_scanTimer?.invalidate()
        m_scanUpdateTime = 0
        if connectInfo != nil {
            bleInfo!.controller!.m_packetCommend?.setLampWifiScan()
            indicator.isHidden = false
            indicator.startAnimating()
            btnRefresh.isHidden = true
            lblRefresh.isHidden = true
        } else {
            Debug.print("[ERROR] startScaning connectInfo is null", event: .error)
        }
        
        self.m_scanTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(scanUpdate), userInfo: nil, repeats: true)
    }
    
    @objc func scanUpdate() {
        m_scanUpdateTime += 0.5
        
        if (UIManager.instance.rootCurrentView as? DeviceRegisterLampWifiSelectViewController == nil && UIManager.instance.rootCurrentView as? CustomWebViewController == nil) {
            m_scanTimer?.invalidate()
        }
        
        if (m_scanUpdateTime >= 9) {
            indicator.isHidden = true
            indicator.stopAnimating()
            btnRefresh.isHidden = false
            lblRefresh.isHidden = false
            
            if let _connectInfo = connectInfo {
                if (_connectInfo.m_scanList.count > 0) {
                    var _isScanSuccess = false
                    for item in _connectInfo.m_scanList {
                        if (item.m_rssi != 255) {
                            _isScanSuccess = true
                            break
                        }
                    }
                    if (!_isScanSuccess) {
                        // error
                        Debug.print("[ERROR] scanning list all -1", event: .error)
                        reconnect()
                    }
                    
                } else {
                    // no list
                    Debug.print("[ERROR] not found lamp scanning list", event: .error)
                    reconnect()
                }
            }
            
            var _isFound = false
            for item in m_arrList {
                if (item as? EtcWifiSelectItemInfo != nil) {
                    _isFound = true
                    break
                }
            }
            if (!_isFound) {
                m_arrList.append(EtcWifiSelectItemInfo())
                table.reloadData()
            }
            m_scanTimer?.invalidate()
        }
        
//        // rescan
//        // rescan 빼고 위에 m_scanTimer?.invalidate() 추가.
//        if (m_scanUpdateTime >= 15) {
//            if (m_arrList.count == 1) {
//                startScaning()
//            }
//        }
        
        // 데이터가 들어오면 바로 적용
        if let _connectInfo = connectInfo {
            if (_connectInfo.m_scanList.count > 0) {
                for itemScanInfo in _connectInfo.m_scanList {
                    if (itemScanInfo.m_idx == 255) {
                        continue
                    }
                    if (itemScanInfo.m_apName.count == 0) {
                        continue
                    }
                    var _isFound = false
                    for item in m_arrList {
                        if (item.m_ssid == itemScanInfo.m_apName) {
                            _isFound = true
                            break
                        }
                    }
                    if (!_isFound) {
                        let _info = WifiSelectItemInfo()
                        _info.m_security = itemScanInfo.m_secuType
                        _info.m_ssid = itemScanInfo.m_apName
                        _info.m_index = itemScanInfo.m_idx
                        m_arrList.append(_info)
                        table.reloadData()
                    }
                }
            }
        }
    }
    
    func reconnect() {
//        if (Config.channel == .kc) {
            let _param = UIManager.instance.getBoardParam(board: BOARD_TYPE.connect_device_hub, boardId: 20)
            _ = PopupManager.instance.withErrorCode(codeString: "[Code203]", linkURL: "\(Config.BOARD_DEFAULT_URL)\(_param)", contentsKey: "dialog_connection_not_received_ap_info_lamp", confirmType: .ok)
//        } else {
//            _ = PopupManager.instance.onlyContents(contentsKey: "dialog_connection_not_received_ap_info", confirmType: .ok, okHandler: { () -> () in
//            })
//        }
    }
    
    func tableView(_  tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return m_arrList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        let cell = Bundle.main.loadNibNamed("WifiTableViewCell", owner: self, options: nil)?.first as! WifiTableViewCell

        let _info = m_arrList[indexPath.row]
        if (_info as? EtcWifiSelectItemInfo) == nil {
            cell.setInfo(type: .auto, name: _info.m_ssid, strength: .full, isLock:  _info.m_security == 0 ? false : true, apName: alreadyLamp?.m_ap ?? "")
        } else {
            cell.setInfo(type: .manual, name: "", strength: .full, isLock: false, apName: "")
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        Debug.print("section: \(indexPath.section)")
        Debug.print("row: \(indexPath.row)")
        
        let _info = m_arrList[indexPath.row]
        if (_info as? EtcWifiSelectItemInfo == nil) {
            if let _secuType = WIFI_SECURITY_TYPE(rawValue: _info.m_security) {
                if (_secuType == .NONE) {
                    UIManager.instance.startLampConnection(registerType: registerType, bleInfo: bleInfo, connectInfo: connectInfo, apName: _info.m_ssid, apPw: "", apSecurity: 0, index: _info.m_index, peripheral: m_peripheral)
                } else {
                    if let _connectInfo = connectInfo {
                        _connectInfo.m_apName = _info.m_ssid
                        _connectInfo.m_apSecurityType = _info.m_security
                        _connectInfo.m_apIndex = _info.m_index
                        
                        if let _view = UIManager.instance.sceneMoveNaviPush(scene: .deviceRegisterLampWifiSelectPassword) as? DeviceRegisterLampWifiSelectPasswordViewController {
                            _view.registerType = registerType
                            _view.m_peripheral = m_peripheral
                            _view.setInfo(info: m_detailInfo!)
                        }
                    } else {
                        Debug.print("[ERROR] connectInfo is null", event: .error)
                    }
                }
            }
        } else {
            if let _view = UIManager.instance.sceneMoveNaviPush(scene: .deviceRegisterLampWifiCustom) as? DeviceRegisterLampWifiCustomViewController {
                _view.registerType = registerType
                _view.m_peripheral = m_peripheral
                _view.setInfo(info: m_detailInfo!)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    @IBAction func onClick_refresh(_ sender: UIButton) {
        m_arrList.removeAll()
        table.reloadData()
        startScaning()
    }
}
