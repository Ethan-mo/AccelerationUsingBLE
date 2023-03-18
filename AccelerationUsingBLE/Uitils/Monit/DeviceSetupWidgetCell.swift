//
//  ShareMemberShareDeviceCell.swift
//  Monit
//
//  Created by 맥 on 2018. 2. 21..
//  Copyright © 2018년 맥. All rights reserved.
//

import UIKit

class DeviceSetupWidgetCell: UICollectionViewCell {
    @IBOutlet weak var imgIcon: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblName: UILabel!
    
    var parent: DeviceSetupWidget?
    var type: DEVICE_TYPE = .Sensor
    var did: Int = 0
    
    func setInit(type: DEVICE_TYPE, did: Int, name: String) {
        self.type = type
        self.did = did
        switch type {
        case .Sensor:
            imgIcon.image = UIImage(named: "imgDeviceAddSensor")
            lblTitle.text = "device_type_diaper_sensor".localized
            lblName.text = name
        case .Hub:
            imgIcon.image = UIImage(named: "imgDeviceAddLamp")
            lblTitle.text = "device_type_hub".localized
            lblName.text = name
        case .Lamp:
            imgIcon.image = UIImage(named: "imgDeviceAddLamp")
            lblTitle.text = "device_type_lamp".localized
            lblName.text = name
        }

        let gesture = UITapGestureRecognizer(target: self, action:  #selector (self.onClick_cell (_:)))
        self.addGestureRecognizer(gesture)
        
        setBorderUI()
    }
    
    func setBorderUI() {
        let _isSelect = parent!.isContains(info: DeviceSetupWidgetInfo(type: self.type.rawValue, did: self.did))
        UI_Utility.customViewBorder(view: self, radius: 0, width: 1, color: _isSelect ? COLOR_TYPE.green.color.cgColor : COLOR_TYPE.lblWhiteGray.color.cgColor)
    }
    
    @objc func onClick_cell(_ sender: UIButton) {
        if (parent!.isContains(info: DeviceSetupWidgetInfo(type: self.type.rawValue, did: self.did))) {
            parent?.removeList(info: DeviceSetupWidgetInfo(type: self.type.rawValue, did: self.did))
//            DataManager.instance.m_dataController.widget.removeWidgetDevice(type: self.type, did: self.did)
        } else {
//            if (DataManager.instance.m_dataController.widget.getTotalCount >= 2) {
//                _ = PopupManager.instance.onlyContentsCustom(contents: "2개 이상 추가할 수 없습니다.", confirmType: .ok)
//                return
//            } else {
            parent?.addList(info: DeviceSetupWidgetInfo(type: self.type.rawValue, did: self.did))
//                DataManager.instance.m_dataController.widget.addWidgetDevice(type: type, did: did)
//            }
        }
        
        setBorderUI()
    }
}
