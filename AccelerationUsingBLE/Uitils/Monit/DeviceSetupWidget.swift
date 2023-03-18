//
//  DeviceSetupWidget.swift
//  Monit
//
//  Created by john.lee on 2019. 3. 21..
//  Copyright © 2019년 맥. All rights reserved.
//

import UIKit

class DeviceSetupWidgetInfo {
    var type: Int = 0
    var did: Int = 0
    init (type: Int, did: Int) {
        self.type = type
        self.did = did
    }
}

class DeviceSetupWidget: BaseViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource {
    @IBOutlet weak var lblNaviTitle: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var cvDevice: UICollectionView!
    @IBOutlet weak var constDevice: NSLayoutConstraint!
    @IBOutlet weak var btnSave: UIButton!
    
    override var screenType: SCREEN_TYPE { get { return .WIDGET_SETUP } }
    
    var setDeviceList: [DeviceSetupWidgetInfo]?

    var deviceInfo: Array<UserInfoDevice>? {
        get {
            return DataManager.instance.m_dataController.device.getTotalUserInfoList
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        lblNaviTitle.text = "widget_settings".localized
        lblTitle.text = "widget_settings_choose_device".localized
        btnSave.setTitle("btn_save".localized.uppercased(), for: .normal)
        
        if (setDeviceList == nil) {
            setDeviceList = []
            if let _lstDevice = deviceInfo {
                for item in _lstDevice {
                    if (DataManager.instance.m_dataController.widget.isContainsDevice(type: DEVICE_TYPE(rawValue: item.type)!, did: item.did)) {
                        setDeviceList!.append(DeviceSetupWidgetInfo(type: item.type, did: item.did))
                    }
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func isContains(info: DeviceSetupWidgetInfo) -> Bool {
        return setDeviceList!.contains(where: { $0.type == info.type && $0.did == info.did })
    }
    
    func addList(info: DeviceSetupWidgetInfo) {
        if (!setDeviceList!.contains(where: { $0.type == info.type && $0.did == info.did })) {
            setDeviceList?.append(info)
        }
    }
    
    func removeList(info: DeviceSetupWidgetInfo) {
        if let index = setDeviceList!.index(where: { $0.type == info.type && $0.did == info.did }) {
            setDeviceList!.remove(at: index)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return deviceInfo!.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let _cell = collectionView.dequeueReusableCell(withReuseIdentifier: "deviceCell", for: indexPath) as! DeviceSetupWidgetCell
        
        let _info = deviceInfo?[indexPath.row]
        _cell.parent = self
        _cell.setInit(type: DEVICE_TYPE(rawValue: _info!.type)!, did: _info!.did, name: _info?.name ?? "")

        return _cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let _padding: CGFloat = 15.0
        let _height: CGFloat = 74.0
        return CGSize(width: cvDevice.bounds.size.width / 2.0 - _padding, height: _height)
    }
    
    @IBAction func onClick_back(_ sender: UIButton) {
        UIManager.instance.sceneMoveNaviPop()
    }
    
    @IBAction func onClick_save(_ sender: UIButton) {
        if let _lstAll = deviceInfo, let _lstSet = setDeviceList {
            for item in _lstAll {
                if (_lstSet.contains(where: { $0.type == item.type && $0.did == item.did })) {
                    if (!DataManager.instance.m_dataController.widget.isContainsDevice(type: DEVICE_TYPE(rawValue: item.type)!, did: item.did)) {
                        DataManager.instance.m_dataController.widget.addWidgetDevice(type: DEVICE_TYPE(rawValue: item.type)!, did: item.did)
                    }
                } else {
                    if (DataManager.instance.m_dataController.widget.isContainsDevice(type: DEVICE_TYPE(rawValue: item.type)!, did: item.did)) {
                        DataManager.instance.m_dataController.widget.removeWidgetDevice(type: DEVICE_TYPE(rawValue: item.type)!, did: item.did)
                    }
                }
            }
        }
        _ = PopupManager.instance.onlyContents(contentsKey: "toast_change_widget_setting_succeeded", confirmType: .noYes, okHandler: { () -> () in
            UIManager.instance.sceneMoveNaviPop()
        }, cancleHandler: { () -> () in
        })
    }
}
