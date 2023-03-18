//
//  ShareMemberShareDeviceCell.swift
//  Monit
//
//  Created by 맥 on 2018. 2. 21..
//  Copyright © 2018년 맥. All rights reserved.
//

import UIKit

class ShareMemberShareDeviceCell: UICollectionViewCell {
    @IBOutlet weak var imgIcon: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblName: UILabel!
    
    func setInit(type: DEVICE_TYPE, name: String) {
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
    }
}
