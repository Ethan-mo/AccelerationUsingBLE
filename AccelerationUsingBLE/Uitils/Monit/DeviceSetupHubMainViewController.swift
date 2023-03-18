//
//  DeviceSetupHubMainViewController.swift
//  Monit
//
//  Created by 맥 on 2017. 10. 2..
//  Copyright © 2017년 맥. All rights reserved.
//

import UIKit

class DeviceSetupHubMainViewController: BaseViewController {
    @IBOutlet weak var lblNaviTitle: UILabel!
    
    override var screenType: SCREEN_TYPE { get { return .HUB_SETUP_INFO } }
    var m_detailInfo: DeviceDetailInfo?
    var m_container: DeviceSetupHubMainContainViewController?
    
    func setUI() {
        lblNaviTitle.text = "title_setting".localized
    }
    
    var hubStatusInfo: HubStatusInfo? {
        get {
            return DataManager.instance.m_userInfo.deviceStatus.m_hubStatus.getInfoByDeviceId(did: m_detailInfo!.m_did)
        }
    }
    
    var isConnect: Bool {
        get {
            return DataManager.instance.m_dataController.device.m_hub.isConnect(type: m_detailInfo!.m_deviceType, did: m_detailInfo!.m_did)
        }
    }
    
    var userInfo: UserInfoDevice? {
        get {
            return DataManager.instance.m_dataController.device.getUserInfoByDid(did: m_detailInfo!.m_did, type: DEVICE_TYPE.Hub.rawValue)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUI()
        if let _container = m_container {
            _container.setUI()
        }
    }
    
    override func reloadInfo() {
        Debug.print("[UI][\(self.classNameToString()).reloadInfo()]")
        super.reloadInfo()
        setUI()
        if let _container = m_container {
            _container.setUI()
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "deviceSetupHubMainContainerSegue")
        {
            m_container = segue.destination as? DeviceSetupHubMainContainViewController
            m_container?.m_parent = self
        }
    }
    
    @IBAction func onClick_back(_ sender: UIButton) {
        UIManager.instance.sceneMoveNaviPop()
    }
}
