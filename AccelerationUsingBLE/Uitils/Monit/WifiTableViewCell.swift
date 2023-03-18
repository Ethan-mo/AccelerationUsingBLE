//
//  WifiTableViewCell.swift
//  Monit
//
//  Created by 맥 on 2017. 10. 9..
//  Copyright © 2017년 맥. All rights reserved.
//

import UIKit

class WifiTableViewCell: BaseTableViewCell {

    enum WIFI_TYPE {
        case auto
        case manual
    }
    
    enum WIFI_STRENGTH_TYPE {
        case full
    }
    
    @IBOutlet weak var lblTItle: UILabel!
    @IBOutlet weak var imgLock: UIImageView!
    @IBOutlet weak var imgWifi: UIImageView!
    @IBOutlet weak var imgAlreadyConnect: UIImageView!
    @IBOutlet weak var lblAlreadyConnect: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setInfo(type: WIFI_TYPE, name: String, strength: WIFI_STRENGTH_TYPE, isLock: Bool, apName: String) {
        imgLock.isHidden = false
        imgWifi.isHidden = false
        
        switch type {
        case .auto:
            let _buf = [UInt8](name.utf8)
            if (_buf.count >= 15) {
                lblTItle.text = "\(name).."
            } else {
                lblTItle.text = name
            }
        case .manual: lblTItle.text = "connection_hub_scanning_add_new_network".localized
        }
        
        switch strength {
        case .full: break // strength
        }
        
        if (!isLock) {
            imgLock.isHidden = true
        }
        
        if (type == .manual) {
            imgLock.isHidden = true
            imgWifi.isHidden = true
        }
        
        lblAlreadyConnect.text = "setting_ap_info_connected".localized
        imgAlreadyConnect.isHidden = true
        lblAlreadyConnect.isHidden = true
//        Debug.print("apName:\(apName), name:\(name)")
        if (apName.count > 0 && name.count > 0 && apName == name) {
            imgAlreadyConnect.isHidden = false
            lblAlreadyConnect.isHidden = false
        }
    }
}
