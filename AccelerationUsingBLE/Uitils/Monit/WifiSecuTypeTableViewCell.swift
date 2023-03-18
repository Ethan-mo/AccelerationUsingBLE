//
//  WifiSecuTypeTableViewCell.swift
//  Monit
//
//  Created by 맥 on 2017. 11. 17..
//  Copyright © 2017년 맥. All rights reserved.
//

import UIKit

class WifiSecuTypeTableViewCell: BaseTableViewCell {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var imgCheck: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setInfo(type: WIFI_SECURITY_TYPE, isEnable: Bool) {
        lblTitle.text = UIManager.instance.getWifiSecurityString(type: type)
        imgCheck.isHidden = !isEnable
    }
    
}
