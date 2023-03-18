//
//  DeviceSensorDetailSensingViewController.swift
//  Monit
//
//  Created by 맥 on 2017. 9. 22..
//  Copyright © 2017년 맥. All rights reserved.
//

import UIKit
import AudioToolbox

class DeviceSensorDetailSensingBaseViewController: BaseViewController {
    var m_parent: DeviceSensorDetailPageViewController?
    var m_flow = Flow()
    
    @IBOutlet var popupChangeDiaper: DeviceSensorDetailSensingView_DiaperChange!
    @IBOutlet weak var popupChangeDiaperPos: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUI()
    }
    
    func reloadInfoChild() {
        setUI()
    }
    
    func setUI() {
    }
    
    func btnChangeDiaperAnimation() {
    }
}
