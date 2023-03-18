//
//  DeviceDetailNotiBaseViewController.swift
//  Monit
//
//  Created by 맥 on 2018. 1. 3..
//  Copyright © 2018년 맥. All rights reserved.
//

import UIKit

class DeviceDetailNotiBaseViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var table: UITableView!
    
    var m_dicFilter: Dictionary<String, Array<DeviceNotiInfo>>? // full data
    var m_section: [[DeviceNotiInfo]]? // sort full data
    var m_pagingData: [[DeviceNotiInfo]]? // paging data
    var m_nowPage:Int = 1
    var m_pagingSize:Int = 15
    var m_flow = Flow()
    
    var m_notiEmptyView: NotiEmptyView?
    var m_type: Int = 1
    var m_did: Int = 0
    var m_arrNotiType = [DEVICE_NOTI_TYPE]()
    var m_lastIdx: Int = -1
    
    var totalCount: Int {
        get {
            var _totalCount = 0
            if let _section = m_section {
                for item in _section {
                    _totalCount += item.count
                }
            }
            return _totalCount
        }
    }
    
    var totalPage: Int {
        get {
            var _totalPage = 1
            if (totalCount >=  m_pagingSize) {
                _totalPage = totalCount / m_pagingSize
                if (totalCount % m_pagingSize != 0) {
                    _totalPage += 1
                }
            }
            return _totalPage
        }
    }
    
    var nowPageTotalCount: Int {
        get {
            if (m_nowPage * m_pagingSize < totalCount) {
                return m_nowPage * m_pagingSize
            } else {
                return totalCount
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Debug.print("[UI][\(self.classNameToString()).viewDidLoad()]")
        table.delegate = self
        table.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getLastIdx()
        setUI()
    }
    
    func reloadInfoChild() {
//        ScreenAnalyticsManager.instance.setScreen(screenType: screenType)
        setUI()
    }
    
    func setInit(notiType: [DEVICE_NOTI_TYPE], type: Int, did: Int) {
        m_arrNotiType = notiType
        m_type = type
        m_did = did
    }
    
    func setUI() {
        leavedNotiNewAlarmUpdate()
        getFilterData(notiType: m_arrNotiType, type: m_type, did: m_did)
    }
    
    func getLastIdx() {
        var _finalItemType: NEW_ALARM_ITEM_TYPE = .sensorNoti
        switch DEVICE_TYPE(rawValue: m_type) ?? .Sensor {
        case .Sensor: _finalItemType = .sensorNoti
        case .Hub: _finalItemType = .hubNoti
        case .Lamp: _finalItemType = .lampNoti
        }
        var _itemType: NEW_ALARM_ITEM_TYPE = .sensorDetail_notiList
        switch DEVICE_TYPE(rawValue: m_type) ?? .Sensor {
        case .Sensor: _itemType = .sensorDetail_notiList
        case .Hub: _itemType = .hubDetail_notiList
        case .Lamp: _itemType = .lampDetail_notiList
        }
        
        let _extra = DataManager.instance.m_userInfo.newAlarm.getExtraByInfo(info: NewAlarmInfo(id: nil, aid: DataManager.instance.m_userInfo.account_id, did: m_did, deviceType: m_type, finalItemType: _finalItemType.rawValue, itemType: _itemType.rawValue))
        self.m_lastIdx = _extra != "" ? Int(_extra)! : -1
    }
    
    func leavedNotiNewAlarmUpdate() {
        DataManager.instance.m_dataController.newAlarm.noti.leavedNotiNewAlarmUpdate(type: m_type, did: m_did)
    }
    
    func setFilter(notiType: [DEVICE_NOTI_TYPE], type: Int, did: Int) {
        m_arrNotiType = notiType
        m_type = type
        m_did = did
        getFilterData(notiType: m_arrNotiType, type: m_type, did: m_did)
    }
    
    func getFilterData(notiType: [DEVICE_NOTI_TYPE], type: Int, did: Int) {
        var _dic = Dictionary<String, Array<DeviceNotiInfo>>()
        let _arrData = DataManager.instance.m_userInfo.deviceNoti.m_deviceNoti
        let _filterDate = _arrData.filter({ (v: DeviceNotiInfo) -> (Bool) in
            if (v.m_type == type && v.m_did == did) {
                if let _notiType = DEVICE_NOTI_TYPE(rawValue: v.m_noti) {
                    if (notiType.contains(_notiType)) {
                        if (_notiType == .sleep_mode && v.m_castExtraTimeInfo == nil) {
                            return false
                        }
                        
                        return true
                    }
                }
            }
            return false
        })
//        var _filterDate = [DeviceNotiInfo]()
//        for item in _arrData {
//            if (item.m_type == type && item.m_did == did) {
//                if let _notiType = DEVICE_NOTI_TYPE(rawValue: item.m_noti) {
//                    if (notiType.contains(_notiType)) {
//                        _filterDate.append(
        
//        for item in _arrData {
//            Debug.print("NotiData: nid:\(item.m_nid), notiType:\(item.m_noti), time:\(item.m_castTimeInfo.m_time), extra:\(item.Extra), extra2:\(item.m_extra2), extra3:\(item.m_extra3), memo:\(item.m_memo)")
//        }
        
        var _addGroupList = [String]()
        for item in _filterDate {
            if (!_addGroupList.contains(item.m_castTimeInfo.m_lDate)) {
                _addGroupList.append(item.m_castTimeInfo.m_lDate)
                _dic.updateValue(Array<DeviceNotiInfo>(), forKey: item.m_castTimeInfo.m_lDate)
            }
        }
        
        for item in _filterDate {
            _dic[item.m_castTimeInfo.m_lDate]?.append(item)
        }
        m_dicFilter = _dic
        
        sort()
    }
    
    func sort() {
        // sort values
        var _dicValueSort = Dictionary<String, Array<DeviceNotiInfo>>()
        for (key, values) in m_dicFilter! {
            _dicValueSort.updateValue(values.sorted (by: {$0.m_castTimeInfo.m_timeCast > $1.m_castTimeInfo.m_timeCast}), forKey: key)
        }
        
        // sort key
        var _dicKeySort = [[DeviceNotiInfo]]()
        for (_,v) in Array(_dicValueSort).sorted(by: {UI_Utility.convertStringToDate($0.0, type: .yyyy_MM_dd)! > UI_Utility.convertStringToDate($1.0, type: .yyyy_MM_dd)!}) {
            _dicKeySort.append(v)
        }
        
        m_section = _dicKeySort
        
        setEmpty()
        setPage(nowPage: m_nowPage)
    }
    
    func setPage(nowPage: Int) {
        Debug.print("[NotiBase] totalCount: \(totalCount)", event: .dev)
        Debug.print("[NotiBase] nowCount: \(nowPageTotalCount)", event: .dev)
        Debug.print("[NotiBase] nowPage: \(m_nowPage)", event: .dev)
        
        var _setCount = nowPageTotalCount
        var _setPage = [[DeviceNotiInfo]]()
        if let _section = m_section {
            for item in _section {
                if (_setCount >= item.count) {
                    _setPage.append(item)
                    _setCount -= item.count
                } else {
                    var _newArrInfo = [DeviceNotiInfo]()
                    for itemChild in item {
                        if (_setCount == 0) {
                            break
                        }
                        _newArrInfo.append(itemChild)
                        _setCount -= 1
                    }
                    _setPage.append(_newArrInfo)
                }
            }
        }
        m_pagingData = _setPage
        
        self.m_flow.reset {
            self.table.reloadData()
        }
    }
    
    func nextPage() {
        if (totalPage > m_nowPage) {
            m_nowPage += 1
        } else {
            return
        }
        setPage(nowPage: m_nowPage)
    }
    
    func setEmpty() {
        if (m_notiEmptyView == nil) {
            m_notiEmptyView = .fromNib()
            m_notiEmptyView!.frame = table.bounds
            m_notiEmptyView!.setInfo()
            self.table.addSubview(m_notiEmptyView!)
        }
        
        if let _sention = m_section {
            if (_sention.count > 0) {
                if (_sention[0].count > 0) {
                    setEmptyVisiable(isEnable: false)
                } else {
                    setEmptyVisiable(isEnable: true)
                }
            } else {
                setEmptyVisiable(isEnable: true)
            }
        } else {
            setEmptyVisiable(isEnable: true)
        }
    }
    
    func setEmptyVisiable(isEnable: Bool) {
        if (isEnable) {
            m_notiEmptyView!.isHidden = false
            table.tableFooterView = UIView()
        } else {
            m_notiEmptyView!.isHidden = true
//            self.table.addSubview(UIView(frame: CGRect(x: 0, y: 0, width: table.frame.size.width, height: 1)))
        }
    }
    
    func getSectionTitleByIndex(section: Int) -> String {
        var i = 0
        for item in m_pagingData! {
            if (i == section) {
                for itemChild in item {
//                    return itemChild.m_castTimeInfo.m_lDate
                    return UI_Utility.getDateByLanguageFromString(itemChild.m_castTimeInfo.m_lDate, fromType: .yyyy_MM_dd, language: Config.languageType)
                }
            }
            i += 1
        }
        return ""
    }
    
    func getSectionDataByIndex(section: Int) -> Array<DeviceNotiInfo> {
        var i = 0
        for item in m_pagingData! {
            if (i == section) {
                return item
            }
            i += 1
        }
        return Array<DeviceNotiInfo>()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return m_pagingData != nil ? m_pagingData!.count : 0
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func sendRemoveNotification(info: DeviceNotiInfo?, currentCell: DeviceNotiTableBaseViewCell) {
        if (info == nil) {
            Debug.print("[ERROR] no item", event: .error)
            return
        }
        currentCell.deleteItem()
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            if let _currentCell = tableView.cellForRow(at: indexPath) as? DeviceNotiTableBaseViewCell {
                sendRemoveNotification(info: _currentCell.m_deviceNotiInfo, currentCell: _currentCell)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "btn_remove".localized
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return getSectionDataByIndex(section: section).count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let _arrData = getSectionDataByIndex(section: indexPath.section)
        if let _cell = Bundle.main.loadNibNamed("DeviceNotiTableViewCell", owner: self, options: nil)?.first as? DeviceNotiTableViewCell {
            _cell.m_parent = self
            _cell.m_deviceNotiInfo = _arrData[indexPath.row]
            _cell.m_sectionIndex = indexPath.section
            _cell.m_index = indexPath.row
            _cell.setInit()
            return _cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 53
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 42
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerFrame = tableView.frame
        
        let title = UILabel()
        title.frame =  CGRectMake(20, 17, headerFrame.size.width-20, 20)
        title.font = UIFont.boldSystemFont(ofSize: 12)
        title.text = getSectionTitleByIndex(section: section)
        title.textColor = COLOR_TYPE.lblGray.color
        
        let headerView:UIView = UIView(frame: CGRectMake(0, 0, headerFrame.size.width, headerFrame.size.height))
        headerView.addSubview(title)
        headerView.backgroundColor = COLOR_TYPE.backgroundGray.color
        headerView.layer.borderColor = COLOR_TYPE.lblWhiteGray.color.cgColor
        headerView.layer.borderWidth = 1
        
        return headerView
    }
    
    func CGRectMake(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat) -> CGRect {
        return CGRect(x: x, y: y, width: width, height: height)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let scrollViewHeight = scrollView.frame.size.height
        let scrollContentSizeHeight = scrollView.contentSize.height
        let scrollOffset = scrollView.contentOffset.y

        if (scrollOffset == 0) {
            // then we are at the top
        }
        else if (scrollOffset + scrollViewHeight >= scrollContentSizeHeight - 20) {
            nextPage()
        }
    }
}
