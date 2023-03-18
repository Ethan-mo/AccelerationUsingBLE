//
//  DeviceSensorDetailNotiTableViewController.swift
//  Monit
//
//  Created by 맥 on 2017. 9. 22..
//  Copyright © 2017년 맥. All rights reserved.
//

import UIKit
import Charts

class DeviceHubTypesDetailGraphViewController {
    static func getVocString(type: HUB_TYPES_VOC) -> String {
        var _retValue = ""
        switch type {
        case .none: break
        case .good: _retValue = "device_environment_voc_good".localized
        case .normal: _retValue = "device_environment_voc_normal".localized
        case .bad: _retValue = "device_environment_voc_not_good".localized
        case .veryBad: _retValue = "device_environment_voc_very_bad".localized
        }
        return _retValue
    }
}

class DeviceHubDetailGraphForKcViewController: BaseViewController, ChartViewDelegate {
    @IBOutlet weak var lineChartView: LineChartView!
    @IBOutlet weak var btnLeft: UIButton!
    @IBOutlet weak var btnRight: UIButton!
    @IBOutlet weak var lblDayTitle: UILabel!
    @IBOutlet weak var lblDayContents: UILabel!
    @IBOutlet weak var lblClickTitle: UILabel!
    @IBOutlet weak var lblClickInfo: UILabel!
    @IBOutlet weak var lblAvgTitle: UILabel!
    @IBOutlet weak var lblAvgInfo: UILabel!
//    @IBOutlet weak var btnScore: UIButton!
    @IBOutlet weak var btnTem: UIButton!
    @IBOutlet weak var btnHum: UIButton!
    @IBOutlet weak var btnVoc: UIButton!
//    @IBOutlet weak var lblScore: UILabel!
    @IBOutlet weak var lblTem: UILabel!
    @IBOutlet weak var lblHum: UILabel!
    @IBOutlet weak var lblVoc: UILabel!
    @IBOutlet weak var viewVoc: UIView!
    @IBOutlet weak var stViewFilter: UIStackView!
    
    struct FilterData {
        var m_xAxis: Double = 0.0
        var m_yAxis: Double = 0.0
    }

    class GraphXAxisFormatter: NSObject, IAxisValueFormatter {
        func stringForValue(_ value: Double, axis: AxisBase?) -> String {
            //        Debug.print(value)
            let _hour = Int(value) / 60
            if (_hour % 6 == 0) {
                if (Config.channel == .kc) {
                    switch (_hour) {
                    case 0: return "Mid\nnight"
                    case 6: return "6AM"
                    case 12: return "Noon"
                    case 18: return "6PM"
                    case 24: return "Mid\nnight"
                    default: break;
                    }
                }
                return _hour.description
            }
            return ""
        }
    }
    
    override var screenType: SCREEN_TYPE { get { return .HUB_DETAIL_GRAPH } }
    var m_parent: DeviceHubDetailPageViewController?
    var m_flow = Flow()
    var m_emptyView: GraphEmptyView?
    
    var isPageMin: Bool {
        get {
            if let index = m_date.index(of: m_nowDate) {
                if (index + 1 < m_date.count) {
                    return false
                }
            }
            return true
        }
    }
    
    var isPageMax: Bool {
        get {
            if let index = m_date.index(of: m_nowDate) {
                if (index > 0) {
                    return false
                }
            }
            return true
        }
    }
    
    var nowDateString: String {
        get {
            return m_nowDate
        }
    }
    
    var prevDateString: String {
        get {
            if let index = m_date.index(of: m_nowDate) {
                if (index + 1 < m_date.count) {
                    let _date = m_date[index + 1]
                    return String(_date[_date.index(_date.endIndex, offsetBy: -5)...])
                }
            }
            return ""
        }
    }
    
    var nextDateString: String {
        get {
            if let index = m_date.index(of: m_nowDate) {
                if (index > 0) {
                    let _date = m_date[index - 1]
                    return String(_date[_date.index(_date.endIndex, offsetBy: -5)...])
                }
            }
            return ""
        }
    }
    
    var nowDayContents: String {
        get {
            let _nowDateStr = UI_Utility.nowUTCDate(type: .yyyy_MM_dd)
            let _nowDate = UI_Utility.convertStringToDate(_nowDateStr, type: .yyyy_MM_dd)
            let _currentDate = UI_Utility.convertStringToDate(m_nowDate, type: .yyyy_MM_dd)
            let componenets = Calendar.current.dateComponents([.day], from: _currentDate!, to: _nowDate!)
            if let day = componenets.day {
                if (day == 0) {
                    return "hub_graph_today".localized
                } else {
                    return String(format: "hub_graph_ago".localized, day.description)
                }
            }
            return ""
        }
    }
  
    var avgValue: String {
        get {
            var _arrInfo = [Double]()
            for item in m_filterData {
                if let _info = item.m_statusInfo {
                    let _temp = Double(_info.m_temp) / 100.0
                    let _tempValue = UIManager.instance.getTemperatureProcessing(value: _temp)
                    
                    if (_tempValue == -0.01) {
                        continue
                    }
                    switch m_state {
                    case .score: _arrInfo.append(Double(_info.scoreValue))
                    case .tem: _arrInfo.append(_tempValue)
                    case .hum: _arrInfo.append(_info.humValue)
                    case .voc:
                        if (_info.vocValue != -0.01) {
                            _arrInfo.append(_info.vocValue)
                        }
                    }
                }
            }
            if (_arrInfo.count == 0) {
                return "-"
            }
            
            var _total: Double = 0.0
            for item in _arrInfo {
                _total += item
            }
            let _avg = (_total / Double(_arrInfo.count))
            let _avgToDouble = (Double(Int(_avg * 10)) / 10.0) as Double
            
            switch m_state {
            case .score: return _avgToDouble.description
            case .tem: return Int(_avg).description
            case .hum: return _avgToDouble.description
            case .voc: return DeviceHubTypesDetailGraphViewController.getVocString(type: HubTypesStatusInfoBase.getVocType(attached: 1, value: Int(_avg * 100)))
            }
        }
    }
    
    var avgValueColor: UIColor {
        get {
            var _arrInfo = [Double]()
            for item in m_filterData {
                if let _info = item.m_statusInfo {
                    let _temp = Double(_info.m_temp) / 100.0
                    let _tempValue = UIManager.instance.getTemperatureProcessing(value: _temp)
                    
                    if (_tempValue == -0.01) {
                        continue
                    }
                    switch m_state {
                    case .score: _arrInfo.append(Double(_info.scoreValue))
                    case .tem: _arrInfo.append(_tempValue)
                    case .hum: _arrInfo.append(_info.humValue)
                    case .voc:
                        if (_info.vocValue != -0.01) {
                            _arrInfo.append(_info.vocValue)
                        }
                    }
                }
            }
            
            if (_arrInfo.count == 0) {
                return Config.channel == .kc ? COLOR_TYPE.green.color : COLOR_TYPE.blue.color
            }
            
            var _total: Double = 0
            for item in _arrInfo {
                _total += item
            }
            let _avg = Double(_total / Double(_arrInfo.count))
            return getColorByValue(value: m_state == .score ? Int(_avg) : Int(_avg * 100))
        }
    }
    
    var nowValue: String {
        get {
            var _retValue = "-"
            let _lastDate = NSDate(timeIntervalSinceNow: TimeInterval(-600)) as Date
            let _lst = DataManager.instance.m_userInfo.hubGraph.m_lst
            for item in _lst {
//                Debug.print("\(_lastDate), \(item.m_timeCast)")
                if (_lastDate <= item.m_castTimeInfo.m_timeCast) {
                    if let _info = item.m_statusInfo {
                        let _temp = Double(_info.m_temp) / 100.0
                        let _tempValue = UIManager.instance.getTemperatureProcessing(value: _temp)
                        
                        if (_tempValue != -0.01) {
                            switch m_state {
                            case .score: _retValue = Double(_info.scoreValue).description
                            case .tem: _retValue = Int(_tempValue).description
                            case .hum: _retValue = _info.humValue.description
                            case .voc:
                                if (_info.vocValue != -0.01) {
                                    _retValue = DeviceHubTypesDetailGraphViewController.getVocString(type: _info.voc)
                                }
                            }
                            break
                        }
                    }
                }
            }
            return _retValue.description
        }
    }
    
    var nowValueColor: UIColor {
        get {
            let _lastDate = NSDate(timeIntervalSinceNow: TimeInterval(-600)) as Date
            let _lst = DataManager.instance.m_userInfo.hubGraph.m_lst
            for item in _lst {
                //                Debug.print("\(_lastDate), \(item.m_timeCast)")
                if (_lastDate <= item.m_castTimeInfo.m_timeCast) {
                    if let _info = item.m_statusInfo {
                        return getColorByHubStatusInfo(info: _info)
                    }
                }
            }
            return Config.channel == .kc ? COLOR_TYPE.green.color : COLOR_TYPE.blue.color
        }
    }

    var m_state: HUB_TYPES_GRAPH_TYPE = .tem
    var m_lastUpdateTime: Date? // reload될때 시간을 체크하여 가져온다. (다른 noti와 다름.)
    var m_date: [String] = {
        var _todayDate = UI_Utility.nowLocalDate(type: .yyyy_MM_dd)
        var _date: [String] = [_todayDate]
        return _date
    }()
    var m_nowDate: String = {
        return UI_Utility.nowLocalDate(type: .yyyy_MM_dd)
    }()
    var m_filterData: [HubGraphInfo] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Debug.print("[UI][\(self.classNameToString()).viewDidLoad()]")
        viewVoc.isHidden = true
        switch Config.channel {
        case .goodmonit, .monitXHuggies: viewVoc.isHidden = false
        case .kc, .kao: break
        }
        
        lineChartView.delegate = self
        lblClickTitle.text = "hub_graph_now".localized
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUI()
        clickInit()
    }

    func reloadInfoChild() {
//        ScreenAnalyticsManager.instance.setScreen(screenType: screenType)
        setUI()
        clickInit()
    }

    func setUI() {
        lblAvgTitle.text = "hub_graph_average".localized
        setDateSort()
        setDateUI()
        setFilterButton(type: m_state)
        setDataFilter()
        setMultiAttribute(label: lblAvgInfo, type: m_state, value: avgValue, fontColor: avgValueColor)
        
        reloadNoti()
    }

    func setDateSort() {
        for item in 1...6 {
            let _lDate = UI_Utility.convertDateToString(NSDate(timeIntervalSinceNow: TimeInterval(-86400 * item)) as Date, type: .yyyy_MM_dd)
            if (!m_date.contains(_lDate)) {
                m_date.append(_lDate)
            }
        }
        
//        for item in DataManager.instance.m_userInfo.hubGraph.m_lst {
//            if let _info = item.m_statusInfo {
//                if (_info.humValue != -0.01) {
//                    if (!m_date.contains(item.m_castTimeInfo.m_lDate)) {
//                        m_date.append(item.m_castTimeInfo.m_lDate)
//                    }
//                }
//            }
//        }
//
//        m_date.sort { (object1, object2) -> Bool in
//            return UIManager.instance.convertStringToDate(object1, type: .yyyy_MM_dd)! > UIManager.instance.convertStringToDate(object2, type: .yyyy_MM_dd)!
//        }
//        Debug.print(m_date)
    }
    
    func setDateUI() {
        btnLeft.isHidden = false
        btnRight.isHidden = false
        if (isPageMin) {
            btnLeft.isHidden = true
        }
        if (isPageMax) {
            btnRight.isHidden = true
        }
//        btnLeft.setTitle(prevDateString, for: .normal)
//        btnRight.setTitle(nextDateString, for: .normal)
        lblDayTitle.text = nowDayContents
        lblDayContents.text = UI_Utility.getDateByLanguageFromString(m_nowDate, fromType: .yyyy_MM_dd, language: Config.languageType)
    }
    
    func setFilterButton(type: HUB_TYPES_GRAPH_TYPE) {
        if (Config.channel == .kc) {
            btnTem.setImage(UIImage(named: type == .tem ?     "imgKcTempNormalDetail"   : "imgTempDisableDetail"), for: .normal)
            btnHum.setImage(UIImage(named: type == .hum ?     "imgKcHumNormalDetail"   : "imgHumDisableDetail"), for: .normal)
            btnVoc.setImage(UIImage(named: type == .voc ?     "imgKcVocNormalDetail"   : "imgVocDisableDetail"), for: .normal)
            
            //        UI_Utility.customButtonShadow(button: btnScore, radius: 1, offsetWidth: 0, offsetHeight: 1, color: type == .score ? COLOR_TYPE.green.color.cgColor : UIColor.black.cgColor, opacity: 0.5)
            UI_Utility.customButtonShadow(button: btnTem, radius: 1, offsetWidth: 0, offsetHeight: 1, color: type == .tem ? COLOR_TYPE.green.color.cgColor : UIColor.black.cgColor, opacity: 0.5)
            UI_Utility.customButtonShadow(button: btnHum, radius: 1, offsetWidth: 0, offsetHeight: 1, color: type == .hum ? COLOR_TYPE.green.color.cgColor : UIColor.black.cgColor, opacity: 0.5)
            UI_Utility.customButtonShadow(button: btnVoc, radius: 1, offsetWidth: 0, offsetHeight: 1, color: type == .voc ? COLOR_TYPE.green.color.cgColor : UIColor.black.cgColor, opacity: 0.5)
            
            //        lblScore.textColor = type == .score ? COLOR_TYPE.green.color : COLOR_TYPE.lblWhiteGray.color
            lblTem.textColor = type == .tem ? COLOR_TYPE.green.color : COLOR_TYPE.lblWhiteGray.color
            lblHum.textColor = type == .hum ? COLOR_TYPE.green.color : COLOR_TYPE.lblWhiteGray.color
            lblVoc.textColor = type == .voc ? COLOR_TYPE.green.color : COLOR_TYPE.lblWhiteGray.color
        } else {
            btnTem.setImage(UIImage(named: type == .tem ?     "imgTempNormalDetail"   : "imgTempDisableDetail"), for: .normal)
            btnHum.setImage(UIImage(named: type == .hum ?     "imgHumNormalDetail"   : "imgHumDisableDetail"), for: .normal)
            btnVoc.setImage(UIImage(named: type == .voc ?     "imgVocNormalDetail"   : "imgVocDisableDetail"), for: .normal)
            
            //        UI_Utility.customButtonShadow(button: btnScore, radius: 1, offsetWidth: 0, offsetHeight: 1, color: type == .score ? COLOR_TYPE.green.color.cgColor : UIColor.black.cgColor, opacity: 0.5)
            UI_Utility.customButtonShadow(button: btnTem, radius: 1, offsetWidth: 0, offsetHeight: 1, color: type == .tem ? COLOR_TYPE.blue.color.cgColor : UIColor.black.cgColor, opacity: 0.5)
            UI_Utility.customButtonShadow(button: btnHum, radius: 1, offsetWidth: 0, offsetHeight: 1, color: type == .hum ? COLOR_TYPE.blue.color.cgColor : UIColor.black.cgColor, opacity: 0.5)
            UI_Utility.customButtonShadow(button: btnVoc, radius: 1, offsetWidth: 0, offsetHeight: 1, color: type == .voc ? COLOR_TYPE.blue.color.cgColor : UIColor.black.cgColor, opacity: 0.5)
            
            //        lblScore.textColor = type == .score ? COLOR_TYPE.blue.color : COLOR_TYPE.lblWhiteGray.color
            lblTem.textColor = type == .tem ? COLOR_TYPE.blue.color : COLOR_TYPE.lblWhiteGray.color
            lblHum.textColor = type == .hum ? COLOR_TYPE.blue.color : COLOR_TYPE.lblWhiteGray.color
            lblVoc.textColor = type == .voc ? COLOR_TYPE.blue.color : COLOR_TYPE.lblWhiteGray.color
        }
        
//        lblScore.text = "hub_graph_score".localized
        lblTem.text = "hub_graph_temperature".localized
        lblHum.text = "hub_graph_humidity".localized
        lblVoc.text = "hub_graph_voc".localized
    }
    
    func setPrevPage() {
        if let index = m_date.index(of: m_nowDate) {
            if (index + 1 < m_date.count) {
                m_nowDate = m_date[index + 1]
            }
        }
        Debug.print("[GRAPH HUB] prev NowDate: \(m_nowDate)")
    }
    
    func setNextPage() {
        if let index = m_date.index(of: m_nowDate) {
            if (index > 0) {
                m_nowDate = m_date[index - 1]
            }
        }
        Debug.print("[GRAPH HUB] next NowDate: \(m_nowDate)")
    }
    
    func setMultiAttribute(label: UILabel, type: HUB_TYPES_GRAPH_TYPE, value: String, fontColor: UIColor) {
        var _addValue = ""
        switch type {
        case .score: _addValue = " /100"
        case .tem: _addValue =
            " \(UIManager.instance.temperatureUnitStr)"
        case .hum: _addValue = " %"
        case .voc: break
        }

        let _attributed1 = LabelAttributed(labelValue: value, attributed: [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 20), NSAttributedStringKey.foregroundColor : fontColor])
        let _attributed2 = LabelAttributed(labelValue: _addValue, attributed: [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 14), NSAttributedStringKey.foregroundColor : COLOR_TYPE.lblGray.color])
        
        UI_Utility.multiAttributedLabel(label: label, arrAttributed: [_attributed1, _attributed2])
    }
    
    func setDataFilter() {
        let _lst = DataManager.instance.m_userInfo.hubGraph.m_lst
        self.m_filterData = _lst.filter({ (item: HubGraphInfo) -> (Bool) in
            if let _detailInfo = m_parent!.m_parent!.m_detailInfo {
                if (item.m_did == _detailInfo.m_did) {
                    if (item.m_castTimeInfo.m_lDate == m_nowDate) {
                        return true
                    }
                }
            }
            return false
        })

        self.m_filterData.sort { (object1, object2) -> Bool in
            return object1.m_castTimeInfo.m_timeCast < object2.m_castTimeInfo.m_timeCast
        }
//        for item in self.m_filterData {
//            Debug.print("tem:\(item.m_tem), hum:\(item.m_hum), voc:\(item.m_voc), \(item.m_xAxisValue) \(item.m_time)")
//        }
    }

    func reloadNoti() {
        setChartUI()
        if (m_lastUpdateTime == nil || m_lastUpdateTime! < NSDate(timeIntervalSinceNow: TimeInterval(-1 * Config.HUB_TYPES_GRAPH_UPDATE_LIMIT)) as Date) {
            if let _detailInfo = m_parent!.m_parent!.m_detailInfo {
                self.m_lastUpdateTime = Date()
                UIManager.instance.indicator(true)
                DataManager.instance.m_dataController.hubGraph.updateByDid(did: _detailInfo.m_did, handler: { (isSuccess) -> () in
                    if (isSuccess) {
                        UIManager.instance.indicator(false)
                        UIManager.instance.currentUIReload()
                    }
                })
            }
        }
    }

    func clickInit() {
        lblClickTitle.text = "hub_graph_now".localized
        setMultiAttribute(label: lblClickInfo, type: m_state, value: nowValue, fontColor: nowValueColor)
    }
    
    func getColorByValue(value: Int) -> UIColor {
        var _retValue: UIColor = Config.channel == .kc ? COLOR_TYPE.green.color : COLOR_TYPE.blue.color
        switch m_state {
        case .score:
            switch HubStatusInfo.getScoreType(value: value) {
            case .good: _retValue = COLOR_TYPE.green.color
            case .normal: _retValue = COLOR_TYPE.gaugeGreen.color
            case .bad: _retValue = COLOR_TYPE.gaugeYellow.color
            case .veryBad: _retValue = COLOR_TYPE.gaugeRed.color
            }
        case .tem, .hum, .voc:
            let _tempValue = UIManager.instance.temperatureUnit == .Celsius ? value : Int(UI_Utility.fahrenheitToCelsius(tempInF: Double(value / 100)) * 100)
            if let _status = DataManager.instance.m_userInfo.deviceStatus.m_hubStatus.getInfoByDeviceId(did: m_parent!.m_parent!.m_detailInfo?.m_did ?? -1) {
                let _info = HubStatusInfo(did: m_parent!.m_parent!.m_detailInfo?.m_did ?? -1, name: "", power: 0, bright: 0, color: 0, attached: 1, temp: _tempValue, hum: value, voc: value, ap: "", apse: "", tempmax: _status.m_tempmax, tempmin: _status.m_tempmin, hummax: _status.m_hummax, hummin: _status.m_hummin, offt: "", onnt: "", con: 0, offptime: "", onptime: "")
                _retValue = getColorByHubStatusInfo(info: _info)
            }
        }
        return _retValue
    }

    func getColorByHubStatusInfo(info: HubStatusInfo?) -> UIColor {
        var _retValue: UIColor = Config.channel == .kc ? COLOR_TYPE.green.color : COLOR_TYPE.blue.color
        if let _info = info {
            let _temp = Double(_info.m_temp) / 100.0
            let _tempValue = UIManager.instance.getTemperatureProcessing(value: _temp)
            
            if (_tempValue != -0.01) {
                switch m_state {
                case .score:
                    switch _info.score {
                    case .good: _retValue = COLOR_TYPE.green.color
                    case .normal: _retValue = COLOR_TYPE.gaugeGreen.color
                    case .bad: _retValue = COLOR_TYPE.gaugeYellow.color
                    case .veryBad: _retValue = COLOR_TYPE.gaugeRed.color
                    }
                case .tem:
                    switch _info.temp {
                    case .normal: _retValue = Config.channel == .kc ? COLOR_TYPE.green.color : COLOR_TYPE.blue.color
                    case .low: _retValue = Config.channel == .kc ? COLOR_TYPE.blue.color : COLOR_TYPE.red.color
                    case .high: _retValue = Config.channel == .kc ? COLOR_TYPE.red.color : COLOR_TYPE.red.color
                    }
                case .hum:
                    switch _info.hum {
                    case .normal: _retValue = Config.channel == .kc ? COLOR_TYPE.green.color : COLOR_TYPE.blue.color
                    case .low, .high: _retValue = Config.channel == .kc ? COLOR_TYPE.orange.color : COLOR_TYPE.red.color
                    }
                case .voc:
                    switch _info.voc {
                    case .good, .normal: _retValue = COLOR_TYPE.blue.color
                    case .bad, .veryBad: _retValue = COLOR_TYPE.gaugeRed.color
                    default: break
                    }
                }
            }
        }
        return _retValue
    }
    
    func setChartUI() {
        var _arrFilterData: [FilterData] = []
        var _arrHighlightsEntry: [Highlight] = []
        var _chartYValues: [ChartDataEntry] = []
        var _chartYColors: [NSUIColor] = []
        let _chartData = LineChartData()

        for item in m_filterData {
            if let _info = item.m_statusInfo {
                let _temp = Double(_info.m_temp) / 100.0
                let _tempValue = UIManager.instance.getTemperatureProcessing(value: _temp)
                
                if (_tempValue != -0.01) {
                    var _filterData = FilterData()
                    _filterData.m_xAxis = Double(item.m_xAxisValue)
                    switch m_state {
                    case .score:
                        _filterData.m_yAxis = Double(_info.scoreValue)
                        _chartYValues.append(ChartDataEntry(x: item.m_xAxisValue, y: Double(_info.scoreValue)))
                        _chartYColors.append(getColorByHubStatusInfo(info: _info))
                        _arrFilterData.append(_filterData)
                    case .tem:
                        _filterData.m_yAxis = Double(_tempValue)
                        _chartYValues.append(ChartDataEntry(x: item.m_xAxisValue, y: Double(_tempValue)))
                        _chartYColors.append(getColorByHubStatusInfo(info: _info))
                        _arrFilterData.append(_filterData)
                    case .hum:
                        _filterData.m_yAxis = Double(_info.humValue)
                        _chartYValues.append(ChartDataEntry(x: item.m_xAxisValue, y: Double(_info.humValue)))
                        _chartYColors.append(getColorByHubStatusInfo(info: _info))
                        _arrFilterData.append(_filterData)
                    case .voc:
                        if (_info.vocValue != -0.01) {
                            _filterData.m_yAxis = Double(_info.vocValue)
                            _chartYValues.append(ChartDataEntry(x: item.m_xAxisValue, y: Double(_info.vocValue)))
                            _chartYColors.append(getColorByHubStatusInfo(info: _info))
                            _arrFilterData.append(_filterData)
                        }
                    }
                }
            }
        }

        var _minFilterData: FilterData?
        var _maxFilterData: FilterData?
        for item in _arrFilterData {
            if (_minFilterData == nil) {
                _minFilterData = item
            }
            if (_maxFilterData == nil) {
                _maxFilterData = item
            }
            
            if (_minFilterData!.m_yAxis > item.m_yAxis) {
                _minFilterData = item
            }
            if (_maxFilterData!.m_yAxis < item.m_yAxis) {
                _maxFilterData = item
            }
        }
        
        if (_minFilterData != nil) {
            _arrHighlightsEntry.append(Highlight(x: Double(_minFilterData!.m_xAxis), y: Double(_minFilterData!.m_yAxis), dataSetIndex: 0))
        }
        if (_maxFilterData != nil) {
            _arrHighlightsEntry.append(Highlight(x: Double(_maxFilterData!.m_xAxis), y: Double(_maxFilterData!.m_yAxis), dataSetIndex: 0))
        }
       
        var _axisMinimum = _minFilterData?.m_yAxis ?? 0.0
        var _axisMaximum = _maxFilterData?.m_yAxis ?? 100.0
        _axisMaximum = _axisMaximum == 0 ? 100.0 : _axisMaximum
        
        let _offset = (_axisMaximum - _axisMinimum) / 2
        _axisMinimum -= _offset
        _axisMaximum += _offset
        Debug.print("[GRAPH HUB] axisMinimum: \(_axisMinimum)", event: .dev)
        Debug.print("[GRAPH HUB] axisMaximum: \(_axisMaximum)", event: .dev)

        let _ds = LineChartDataSet(values: _chartYValues, label: nil)
        _ds.drawCircleHoleEnabled = false
        _ds.colors = _chartYColors
        _ds.lineWidth = 2
        _ds.drawCirclesEnabled = false
        _ds.circleRadius = 1
        _ds.drawValuesEnabled = false
        _chartData.addDataSet(_ds)

        lineChartView.leftAxis.axisMinimum = _axisMinimum
        lineChartView.leftAxis.axisMaximum = _axisMaximum
        lineChartView.leftAxis.drawGridLinesEnabled = false
        lineChartView.leftAxis.drawLabelsEnabled = false
        lineChartView.clipValuesToContentEnabled = false
        lineChartView.leftAxis.labelFont = UIFont(name: Config.FONT_NotoSans, size: 10.0)!

        lineChartView.rightAxis.drawGridLinesEnabled = false
        lineChartView.rightAxis.drawLabelsEnabled = false
        lineChartView.rightAxis.labelFont = UIFont(name: Config.FONT_NotoSans, size: 10.0)!

        lineChartView.xAxis.drawGridLinesEnabled = true
        lineChartView.xAxis.drawAxisLineEnabled = false
        lineChartView.xAxis.gridColor = COLOR_TYPE.lblWhiteGray.color
        lineChartView.xAxis.axisRange = 1440
        lineChartView.xAxis.axisMinimum = 0
        lineChartView.xAxis.axisMaximum = 1440
        lineChartView.xAxis.labelPosition = .bottom
        lineChartView.xAxis.valueFormatter = GraphXAxisFormatter()
        lineChartView.xAxis.labelCount = 13
        lineChartView.xAxis.forceLabelsEnabled = true
        lineChartView.xAxis.granularity = 1
        lineChartView.xAxis.labelFont = UIFont(name: Config.FONT_NotoSans, size: 9.0)!
        
        lineChartView.data = _chartData
        lineChartView.chartDescription?.text = ""
        lineChartView.pinchZoomEnabled = false
        lineChartView.scaleXEnabled = false
        lineChartView.scaleYEnabled = false
        lineChartView.legend.enabled = false

        let marker: HubTypesGraphBalloonMarker = HubTypesGraphBalloonMarker(state: m_state, color: COLOR_TYPE.lblGray.color, font: UIFont(name: Config.FONT_NotoSans, size: 12)!, textColor: UIColor.white, insets: UIEdgeInsets(top: 0, left: 7.0, bottom: 4.0, right: 7.0))
//        marker.image = UIImage(named: "imgCheckRound")
        
        if let _minValue = _minFilterData {
            marker.m_bttomOffsetValue = _minValue.m_yAxis
        }

        marker.minimumSize = CGSize(width: 30.0, height: 30.0)
        lineChartView.marker = marker
        lineChartView.highlightValues(_arrHighlightsEntry)
        
        setEmptyGraph(isEnable: _arrFilterData.count <= 0)
    }
    
    func setEmptyGraph(isEnable: Bool) {
        if (isEnable) {
            if (m_emptyView == nil) {
                m_emptyView = .fromNib()
                m_emptyView!.frame = lineChartView.bounds
                m_emptyView!.setInfo()
                self.lineChartView.addSubview(m_emptyView!)
            }
            m_emptyView?.isHidden = false
        } else {
            m_emptyView?.isHidden = true
        }
    }
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        Debug.print("[GRAPH HUB] chartValueSelected \(entry.y)", event: .dev)
        for item in m_filterData {
            if (item.m_xAxisValue == entry.x) {
                var _value = "-"
                switch m_state {
                case .score: _value = entry.y.description
                case .tem: _value = Int(entry.y).description
                case .hum: _value = entry.y.description
                case .voc: _value = DeviceHubTypesDetailGraphViewController.getVocString(type: HubTypesStatusInfoBase.getVocType(attached: 1, value: Int(entry.y * 100)))
                }
                lblClickTitle.text = item.m_castTimeInfo.m_lNotiTime
                let _color = getColorByValue(value: m_state == .score ? Int(entry.y) : Int(entry.y * 100))
                setMultiAttribute(label: lblClickInfo,
                                  type: m_state,
                                  value: _value,
                                  fontColor: _color)
                break
            }
        }
    }
    
    @IBAction func onClick_prev(_ sender: UIButton) {
        setPrevPage()
        clickInit()
        setUI()
    }
    
    @IBAction func onClick_next(_ sender: UIButton) {
        setNextPage()
        clickInit()
        setUI()
    }
    
    @IBAction func onClick_score(_ sender: UIButton) {
        m_state = .score
        clickInit()
        setUI()
    }
    
    @IBAction func onClick_tem(_ sender: UIButton) {
        m_state = .tem
        clickInit()
        setUI()
        
        ScreenAnalyticsManager.instance.googleTagManagerCustom(type: .hub_graph_temperature, items: ["hubid_\(m_parent!.m_parent!.m_detailInfo!.m_did)" : UI_Utility.nowUTCDate(type: .yyMMdd_HHmmss)])
    }
    
    @IBAction func onClick_hum(_ sender: UIButton) {
        m_state = .hum
        clickInit()
        setUI()
        
        ScreenAnalyticsManager.instance.googleTagManagerCustom(type: .hub_graph_humidity, items: ["hubid_\(m_parent!.m_parent!.m_detailInfo!.m_did)" : UI_Utility.nowUTCDate(type: .yyMMdd_HHmmss)])
    }
    
    @IBAction func onClick_voc(_ sender: UIButton) {
        m_state = .voc
        clickInit()
        setUI()
    }
}
