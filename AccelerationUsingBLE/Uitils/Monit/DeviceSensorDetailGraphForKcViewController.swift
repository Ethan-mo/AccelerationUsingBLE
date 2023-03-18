//
//  DeviceSensorDetailGraphViewController.swift
//  Monit
//
//  Created by 맥 on 2018. 4. 17..
//  Copyright © 2018년 맥. All rights reserved.
//

import UIKit
import Charts

class DeviceSensorDetailGraphForKcViewController: DeviceSensorDetailGraphBaseViewController {
    @IBOutlet var notiGraph: DeviceSensorDetailNotiGraphForKcView!
    @IBOutlet var moveGraph: DeviceSensorDetailMoveGraphForKcView!
    @IBOutlet weak var viewGraph: UIView!
    @IBOutlet weak var btnFilterDiaper: UIButton!
    @IBOutlet weak var lblFilterDiaper: UILabel!
    @IBOutlet weak var btnFilterPee: UIButton!
    @IBOutlet weak var lblFilterPee: UILabel!
    @IBOutlet weak var btnFilterPoo: UIButton!
    @IBOutlet weak var lblFilterPoo: UILabel!
    @IBOutlet weak var btnFilterFart: UIButton!
    @IBOutlet weak var lblFilterFart: UILabel!
    @IBOutlet weak var viewFilter: UIView!
    
    override var screenType: SCREEN_TYPE { get { return .SENSOR_DETAIL_GRAPH } }
    static let maxValue: Int = 18
    
    enum GRAPH_TYPE {
        case diaper
        case pee
        case poo
        case fart
        case mov
    }
    
    var m_parent: DeviceSensorDetailPageViewController?
    var m_state: GRAPH_TYPE = .diaper

    override func viewDidLoad() {
        super.viewDidLoad()
        Debug.print("[UI][\(self.classNameToString()).viewDidLoad()]")
        
        viewGraph.addSubview(notiGraph)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUI()
    }
    
    func reloadInfoChild() {
//        ScreenAnalyticsManager.instance.setScreen(screenType: screenType)
        setUI()
    }
    
    func setUI() {
        setFilterButton(type: m_state)
        
        notiGraph.isHidden = true
        moveGraph.isHidden = true

        notiGraph.frame = viewGraph.frame
        notiGraph.m_parent = self
        notiGraph.setCtrl(state: m_state)
        notiGraph.isHidden = false
    }

    func setFilterButton(type: GRAPH_TYPE) {
        btnFilterDiaper.setImage(UIImage(named: type == .diaper ?     "imgDiaperNormalDetail"   : "imgDiaperDisableDetail"), for: .normal)
        btnFilterPee.setImage(UIImage(named: type == .pee ?     "imgPeeNormalDetail"   : "imgPeeDisableDetail"), for: .normal)
        btnFilterPoo.setImage(UIImage(named: type == .poo ?     "imgPooNormalDetail"   : "imgPooDisableDetail"), for: .normal)
        btnFilterFart.setImage(UIImage(named: type == .fart ?     "imgFartNormalDetail"   : "imgFartDisableDetail"), for: .normal)

        UI_Utility.customButtonShadow(button: btnFilterDiaper, radius: 1, offsetWidth: 0, offsetHeight: 1, color: type == .diaper ? COLOR_TYPE.purple.color.cgColor : UIColor.black.cgColor, opacity: 0.5)
        UI_Utility.customButtonShadow(button: btnFilterPee, radius: 1, offsetWidth: 0, offsetHeight: 1, color: type == .pee ? COLOR_TYPE.purple.color.cgColor : UIColor.black.cgColor, opacity: 0.5)
        UI_Utility.customButtonShadow(button: btnFilterPoo, radius: 1, offsetWidth: 0, offsetHeight: 1, color: type == .poo ? COLOR_TYPE.purple.color.cgColor : UIColor.black.cgColor, opacity: 0.5)
        UI_Utility.customButtonShadow(button: btnFilterFart, radius: 1, offsetWidth: 0, offsetHeight: 1, color: type == .fart ? COLOR_TYPE.purple.color.cgColor : UIColor.black.cgColor, opacity: 0.5)
        
        lblFilterDiaper.textColor = type == .diaper ? COLOR_TYPE.purple.color : COLOR_TYPE.lblWhiteGray.color
        lblFilterPee.textColor = type == .pee ? COLOR_TYPE.purple.color : COLOR_TYPE.lblWhiteGray.color
        lblFilterPoo.textColor = type == .poo ? COLOR_TYPE.purple.color : COLOR_TYPE.lblWhiteGray.color
        lblFilterFart.textColor = type == .fart ? COLOR_TYPE.purple.color : COLOR_TYPE.lblWhiteGray.color
        
        lblFilterDiaper.text = "sensor_graph_diaper".localized
        lblFilterPee.text = "device_sensor_diaper_status_pee".localized
        lblFilterPoo.text = "device_sensor_diaper_status_poo".localized
        lblFilterFart.text = "device_sensor_diaper_status_fart".localized
    }
    
    @IBAction func onClick_filterDiaper(_ sender: UIButton) {
        m_state = .diaper
        setUI()
        
        ScreenAnalyticsManager.instance.googleTagManagerCustom(type: .sensor_graph_diaper_button_weekly, items: ["sensorid_\(m_parent?.m_parent?.m_detailInfo?.m_did ?? 0)" : UI_Utility.nowUTCDate(type: .yyMMdd_HHmmss)])
    }
    
    @IBAction func onClick_filterPee(_ sender: UIButton) {
        m_state = .pee
        setUI()
        
        ScreenAnalyticsManager.instance.googleTagManagerCustom(type: .sensor_graph_pee_button_weekly, items: ["sensorid_\(m_parent?.m_parent?.m_detailInfo?.m_did ?? 0)" : UI_Utility.nowUTCDate(type: .yyMMdd_HHmmss)])
    }
    
    @IBAction func onClick_filterPoo(_ sender: UIButton) {
        m_state = .poo
        setUI()
        
        ScreenAnalyticsManager.instance.googleTagManagerCustom(type: .sensor_graph_poo_button_weekly, items: ["sensorid_\(m_parent?.m_parent?.m_detailInfo?.m_did ?? 0)" : UI_Utility.nowUTCDate(type: .yyMMdd_HHmmss)])
    }
    
    @IBAction func onClick_filterFart(_ sender: UIButton) {
        m_state = .fart
        setUI()
        
        ScreenAnalyticsManager.instance.googleTagManagerCustom(type: .sensor_graph_fart_button_weekly, items: ["sensorid_\(m_parent?.m_parent?.m_detailInfo?.m_did ?? 0)" : UI_Utility.nowUTCDate(type: .yyMMdd_HHmmss)])
    }
}
