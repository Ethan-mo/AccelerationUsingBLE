//
//  DeviceSensorDetailGraphViewController.swift
//  Monit
//
//  Created by 맥 on 2018. 4. 17..
//  Copyright © 2018년 맥. All rights reserved.
//

import UIKit
import Charts

class DeviceSensorDetailGraphViewController: DeviceSensorDetailGraphBaseViewController {
    @IBOutlet var notiGraph: DeviceSensorDetailNotiGraphView!
    @IBOutlet var vocGraph: DeviceSensorDetailVocGraphView!
    @IBOutlet var moveGraph: DeviceSensorDetailMoveGraphView!
    @IBOutlet var sleepModeGraph: DeviceSensorDetailSleepModeGraphView!
    @IBOutlet weak var viewGraph: UIView!
    
    @IBOutlet weak var btnFilterDiaperHuggies: UIButton!
    @IBOutlet weak var lblFilterDiaperHuggies: UILabel!
    @IBOutlet weak var btnFilterVocHuggies: UIButton!
    @IBOutlet weak var lblFilterVocHuggies: UILabel!
    @IBOutlet weak var btnFilterSleepMode: UIButton!
    @IBOutlet weak var lblFilterSleepMode: UILabel!
    @IBOutlet weak var btnFilterMovHuggies: UIButton!
    @IBOutlet weak var lblFilterMovHuggies: UILabel!
    @IBOutlet weak var viewFilterHuggies: UIView!
    
    @IBOutlet weak var viewAverageDiaper: UIView!
    @IBOutlet weak var lblAverageDiaperCount: UILabel!
    @IBOutlet weak var viewAveragePee: UIView!
    @IBOutlet weak var lblAveragePeeCount: UILabel!
    @IBOutlet weak var viewAveragePoo: UIView!
    @IBOutlet weak var lblAveragePooCount: UILabel!
    
    override var screenType: SCREEN_TYPE { get { return .SENSOR_DETAIL_GRAPH } }
    static let maxValue: Int = 18
    
    enum GRAPH_TYPE {
        case diaper
        case mov
        case voc
        case sleepMode
    }
    
    var m_parent: DeviceSensorDetailPageViewController?
    var m_state: GRAPH_TYPE = .diaper
    
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
    }
    
    func setInitUI() {
        viewGraph.addSubview(notiGraph)
        viewGraph.addSubview(vocGraph)
        viewGraph.addSubview(moveGraph)
        viewGraph.addSubview(sleepModeGraph)
        
        UI_Utility.customViewShadow(view: viewAverageDiaper, radius: 10, offsetWidth: 1, offsetHeight: 1, color: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), opacity: 0.2)
    }
    
    func setUI() {
        setFilterButton(type: m_state)
        
        notiGraph.isHidden = true
        vocGraph.isHidden = true
        moveGraph.isHidden = true
        sleepModeGraph.isHidden = true
        
        switch m_state {
        case .diaper:
            notiGraph.frame.size.width = viewGraph.frame.width
            notiGraph.m_parent = self
            notiGraph.setCtrl()
            notiGraph.isHidden = false
        case .voc:
            vocGraph.frame = viewGraph.frame
            vocGraph.m_parent = self
            vocGraph.setCtrl()
            vocGraph.isHidden = false
        case .sleepMode:
            sleepModeGraph.frame = viewGraph.frame
            sleepModeGraph.m_parent = self
            sleepModeGraph.setCtrl()
            sleepModeGraph.isHidden = false
        case .mov:
            moveGraph.frame = viewGraph.frame
            moveGraph.m_parent = self
            moveGraph.setCtrl()
            moveGraph.isHidden = false
        }
    }
    
    func setFilterButton(type: GRAPH_TYPE) {
        btnFilterDiaperHuggies.setImage(UIImage(named: type == .diaper ?     "imgDiaperNormalDetail_Brown"   : "imgDiaperDisableDetail"), for: .normal)
        btnFilterVocHuggies.setImage(UIImage(named: type == .voc ?     "imgFartNormalDetail_Brown"   : "imgFartDisableDetail"), for: .normal)
        btnFilterSleepMode.setImage(UIImage(named: type == .sleepMode ?     "imgSleepNormalMain"   : "imgSleepDisableMain"), for: .normal)
        btnFilterMovHuggies.setImage(UIImage(named: type == .mov ?     "imgMoveNormalDetail"   : "imgMoveDisableDetail"), for: .normal)
        
        UI_Utility.customButtonShadow(button: btnFilterDiaperHuggies, radius: 1, offsetWidth: 0, offsetHeight: 1, color: type == .diaper ? COLOR_TYPE._brown_174_140_107.color.cgColor : UIColor.black.cgColor, opacity: 0.5)
        UI_Utility.customButtonShadow(button: btnFilterVocHuggies, radius: 1, offsetWidth: 0, offsetHeight: 1, color: type == .voc ? COLOR_TYPE._brown_174_140_107.color.cgColor : UIColor.black.cgColor, opacity: 0.5)
        UI_Utility.customButtonShadow(button: btnFilterSleepMode, radius: 1, offsetWidth: 0, offsetHeight: 1, color: type == .sleepMode ? COLOR_TYPE._brown_174_140_107.color.cgColor : UIColor.black.cgColor, opacity: 0.5)
        UI_Utility.customButtonShadow(button: btnFilterMovHuggies, radius: 1, offsetWidth: 0, offsetHeight: 1, color: type == .mov ? COLOR_TYPE._brown_174_140_107.color.cgColor : UIColor.black.cgColor, opacity: 0.5)
        
        lblFilterDiaperHuggies.textColor = type == .diaper ? COLOR_TYPE._brown_174_140_107.color : COLOR_TYPE.lblWhiteGray.color
        lblFilterVocHuggies.textColor = type == .voc ? COLOR_TYPE._brown_174_140_107.color : COLOR_TYPE.lblWhiteGray.color
        lblFilterSleepMode.textColor = type == .sleepMode ? COLOR_TYPE._blue_71_88_144.color : COLOR_TYPE.lblWhiteGray.color
        lblFilterMovHuggies.textColor = type == .mov ? COLOR_TYPE.purple.color : COLOR_TYPE.lblWhiteGray.color
        
        lblFilterDiaperHuggies.text = "sensor_graph_diaper".localized
        lblFilterVocHuggies.text = "device_sensor_voc".localized
        lblFilterSleepMode.text = "sensor_graph_sleeping".localized
        lblFilterMovHuggies.text = "device_sensor_activity_status".localized
    }
    
    @IBAction func onClick_filerDiaperHuggies(_ sender: UIButton) {
        m_state = .diaper
        setUI()
    }
    
    @IBAction func onClick_filterVocHuggies(_ sender: UIButton) {
        m_state = .voc
        setUI()
    }
    
    @IBAction func onClick_filterSleepModeHuggies(_ sender: UIButton) {
        m_state = .sleepMode
        setUI()
    }
    
    @IBAction func onClick_filterMovHuggies(_ sender: UIButton) {
        m_state = .mov
        setUI()
    }
}
