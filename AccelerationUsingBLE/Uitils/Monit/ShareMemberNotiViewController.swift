//
//  ShareMemberNotiViewController.swift
//  Monit
//
//  Created by 맥 on 2018. 3. 8..
//  Copyright © 2018년 맥. All rights reserved.
//

import UIKit

class ShareMemberNotiViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var table: UITableView!
    
    override var screenType: SCREEN_TYPE { get { return .SHARE_NOTI } }
    var m_parent: ShareMemberMainV2PageViewController!
    var m_flow = Flow()
    
    var m_dicFilter: Dictionary<String, Array<ShareMemberNotiInfo>>? // full data
    var m_section: [[ShareMemberNotiInfo]]? // sort full data
    var m_pagingData: [[ShareMemberNotiInfo]]? // paging data
    var m_nowPage:Int = 1
    var m_pagingSize:Int = 15
    
    var m_notiEmptyView: NotiEmptyView?

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
        setUI()
    }
    
    func reloadInfoChild() {
//        ScreenAnalyticsManager.instance.setScreen(screenType: screenType)
        setUI()
    }

    func setUI() {
        getFilterData()
    }
    
    func getFilterData() {
        var _dic = Dictionary<String, Array<ShareMemberNotiInfo>>()
        let _arrData = DataManager.instance.m_userInfo.shareMemberNoti.m_shareMemberNoti
        let _filterDate = _arrData.filter({ (v: ShareMemberNotiInfo) -> (Bool) in
            if SHARE_MEMBER_NOTI_TYPE(rawValue: v.m_noti) != nil {
//                if (v.m_type == type && v.m_did == did && _notiType != DEVICE_NOTI_TYPE.connected && _notiType != DEVICE_NOTI_TYPE.disconnected) {
                    return true
//                }
            }
            return false
        })
        
        var _addGroupList = [String]()
        for item in _filterDate {
            if (!_addGroupList.contains(item.m_castTimeInfo.m_lDate)) {
                _addGroupList.append(item.m_castTimeInfo.m_lDate)
                _dic.updateValue(Array<ShareMemberNotiInfo>(), forKey: item.m_castTimeInfo.m_lDate)
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
        var _dicValueSort = Dictionary<String, Array<ShareMemberNotiInfo>>()
        for (key, values) in m_dicFilter! {
            _dicValueSort.updateValue(values.sorted (by: {$0.m_castTimeInfo.m_timeCast > $1.m_castTimeInfo.m_timeCast}), forKey: key)
        }
        
        // sort key
        var _dicKeySort = [[ShareMemberNotiInfo]]()
        for (_,v) in Array(_dicValueSort).sorted(by: {UI_Utility.convertStringToDate($0.0, type: .yyyy_MM_dd)! > UI_Utility.convertStringToDate($1.0, type: .yyyy_MM_dd)!}) {
            _dicKeySort.append(v)
        }
        
        m_section = _dicKeySort
        
        setEmpty()
        setPage(nowPage: m_nowPage)
    }
    
    func setPage(nowPage: Int) {
        Debug.print("[ShareMemberNoti] totalCount: \(totalCount)", event: .dev)
        Debug.print("[ShareMemberNoti] nowCount: \(nowPageTotalCount)", event: .dev)
        Debug.print("[ShareMemberNoti] nowPage: \(m_nowPage)", event: .dev)
        
        var _setCount = nowPageTotalCount
        var _setPage = [[ShareMemberNotiInfo]]()
        if let _section = m_section {
            for item in _section {
                if (_setCount >= item.count) {
                    _setPage.append(item)
                    _setCount -= item.count
                } else {
                    var _newArrInfo = [ShareMemberNotiInfo]()
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
        }
    }
    
    func getSectionTitleByIndex(section: Int) -> String {
        var i = 0
        for item in m_pagingData! {
            if (i == section) {
                for itemChild in item {
                    return itemChild.m_castTimeInfo.m_lDate
                }
            }
            i += 1
        }
        return ""
    }
    
    func getSectionDataByIndex(section: Int) -> Array<ShareMemberNotiInfo> {
        var i = 0
        for item in m_pagingData! {
            if (i == section) {
                return item
            }
            i += 1
        }
        return Array<ShareMemberNotiInfo>()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return m_pagingData != nil ? m_pagingData!.count : 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return getSectionDataByIndex(section: section).count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let _arrData = getSectionDataByIndex(section: indexPath.section)
        let _cell = Bundle.main.loadNibNamed("ShareMemberNotiTableViewCell", owner: self, options: nil)?.first as! ShareMemberNotiTableViewCell
        let _info = _arrData[indexPath.row]
        _cell.m_parent = self
        _cell.m_notiInfo = _info
        _cell.setInit()
        return _cell
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
