//
//  DeviceMainNoneTableViewController.swift
//  Monit
//
//  Created by 맥 on 2017. 9. 14..
//  Copyright © 2017년 맥. All rights reserved.
//

import UIKit

class DeviceMainNoneViewController: BaseViewController {
    @IBOutlet weak var lblSummary: UILabel!
    @IBOutlet weak var btnRegister: UIButton!
    @IBOutlet weak var imgShare: UIButton!
    @IBOutlet weak var viewSummary: UIView!
    @IBOutlet weak var viewRegister: UIView!
    @IBOutlet weak var viewHuggiesRegister: UIView!
    @IBOutlet weak var lblHelpAddArrow: UILabel!
    
    var m_parent: DeviceMainViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imgShare.isHidden = true
        imgShare.setImage(UIImage(named: Config.channel == .kc ? "imgShareForKc" : "imgShare"), for: .normal)
        
        viewSummary.isHidden = true
        viewRegister.isHidden = true
        viewHuggiesRegister.isHidden = true
        if (Config.channel != .kc) {
            viewHuggiesRegister.isHidden = false
        } else {
            viewSummary.isHidden = false
            viewRegister.isHidden = false
            imgShare.isHidden = false
        }
        
        lblHelpAddArrow.text = "device_no_registered_devices".localized
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUI()
    }

    func setUI() {
        lblSummary.text = "device_no_registered_devices".localized
        btnRegister.setTitle("btn_register_device".localized, for: .normal)
    }

    @IBAction func onClick_AddDevice(_ sender: UIButton) {
        _ = UIManager.instance.sceneMoveNaviPush(scene: .deviceRegister)
    }
    
    @IBAction func onClick_share(_ sender: UIButton) {
        _ = UIManager.instance.sceneMoveNaviPush(scene: .shareMemberMain)
    }
}
