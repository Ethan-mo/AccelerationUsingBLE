//
//  DeviceSensorDetailNotiTableViewController.swift
//  Monit
//
//  Created by 맥 on 2017. 9. 22..
//  Copyright © 2017년 맥. All rights reserved.
//

import UIKit
import Charts

class DeviceHubDetailGraphViewController: DeviceHubDetailGraphBaseViewController {
    @IBOutlet var commonGraph: DeviceHubDetailGraphCommonGraphView!
    @IBOutlet weak var viewGraph: UIView!
    
    @IBOutlet weak var btnFilterTem: UIButton!
    @IBOutlet weak var lblFilterTem: UILabel!
    @IBOutlet weak var btnFilterHum: UIButton!
    @IBOutlet weak var lblFilterHum: UILabel!
    @IBOutlet weak var viewFilter: UIView!

    enum GRAPH_TYPE {
        case tem
        case hum
    }
    
    var m_parent: DeviceHubDetailPageViewController?
    var m_state: HUB_TYPES_GRAPH_TYPE = .tem
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Debug.print("[UI][\(self.classNameToString()).viewDidLoad()]")
        setInitUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUI()
    }
    
    func reloadInfoChild() {
        setUI()
        commonGraph.setUI()
    }
    
    func setInitUI() {
        viewGraph.addSubview(commonGraph)
    }
    
    func setUI() {
        setFilterButton(type: m_state)
        commonGraph.isHidden = true
        commonGraph.frame.size.width = viewGraph.frame.width
        commonGraph.m_parent = self
        if (!commonGraph.m_initFlow.isOne) {
            commonGraph.setCtrl(state: m_state)
        } else {
            commonGraph.setChangeType(state: m_state)
        }
        commonGraph.isHidden = false
    }
    
    func setFilterButton(type: HUB_TYPES_GRAPH_TYPE) {
        btnFilterTem.setImage(UIImage(named: type == .tem ?     "imgTempNormalDetail"   : "imgTempDisableDetail"), for: .normal)
        btnFilterHum.setImage(UIImage(named: type == .hum ?     "imgHumNormalDetail"   : "imgHumDisableDetail"), for: .normal)
        
        UI_Utility.customButtonShadow(button: btnFilterTem, radius: 1, offsetWidth: 0, offsetHeight: 1, color: type == .tem ? COLOR_TYPE.blue.color.cgColor : UIColor.black.cgColor, opacity: 0.5)
        UI_Utility.customButtonShadow(button: btnFilterHum, radius: 1, offsetWidth: 0, offsetHeight: 1, color: type == .hum ? COLOR_TYPE.blue.color.cgColor : UIColor.black.cgColor, opacity: 0.5)
        
        lblFilterTem.textColor = type == .tem ? COLOR_TYPE.blue.color : COLOR_TYPE.lblWhiteGray.color
        lblFilterHum.textColor = type == .hum ? COLOR_TYPE.blue.color : COLOR_TYPE.lblWhiteGray.color
        
        lblFilterTem.text = "hub_graph_temperature".localized
        lblFilterHum.text = "hub_graph_humidity".localized
    }
    
    @IBAction func onClick_tem(_ sender: UIButton) {
        m_state = .tem
        setUI()
    }
    
    @IBAction func onClick_hum(_ sender: UIButton) {
        m_state = .hum
        setUI()
    }
}
