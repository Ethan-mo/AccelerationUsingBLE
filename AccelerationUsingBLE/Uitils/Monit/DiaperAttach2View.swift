//
//  DiaperAttach2View.swift
//  Monit
//
//  Created by john.lee on 05/09/2019.
//  Copyright © 2019 맥. All rights reserved.
//

import UIKit

class DiaperAttach2View: SlideBaseView {
    @IBOutlet weak var viewTop: UIView!
    @IBOutlet weak var lblBottomTitle: UILabel!
    @IBOutlet weak var lblBottomSummary: VerticalAlignLabel!
    
    override func setInit() {
        super.setInit()
        lblBottomSummary.verticalAlignment = .top
        viewTop.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        viewTop.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        viewTop.layer.shadowOpacity = 0.5
        viewTop.layer.shadowRadius = 0.0
        viewTop.layer.masksToBounds = false
        lblBottomTitle.text = "connection_monit_sensor_attaching_guide_diaper_title".localized
        lblBottomSummary.text = "connection_monit_sensor_attaching_guide_diaper_description".localized
    }
}
