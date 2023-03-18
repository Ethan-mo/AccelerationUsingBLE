//
//  ShareMemberGetSharedViewController.swift
//  Monit
//
//  Created by 맥 on 2018. 3. 2..
//  Copyright © 2018년 맥. All rights reserved.
//

import UIKit

class ShareMemberGetSharedViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var lblTopSummary: UILabel!
    @IBOutlet weak var lblTableTitle: UILabel!
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var bottomView: UIView!
    
    override var screenType: SCREEN_TYPE { get { return .SHARE_RECEIVE } }
    var otherGroupCount: Int {
        get {
            let _count = DataManager.instance.m_userInfo.shareMember.otherGroup?.count ?? 0
            return _count != 0 ? _count : 1
        }
    }
    
    var isNoneOtherGroup: Bool {
        get {
            let _count = DataManager.instance.m_userInfo.shareMember.otherGroup?.count ?? 0
            return _count == 0 ? true : false
        }
    }
    
    var m_parent: ShareMemberMainV2PageViewController!
    var m_flow = Flow()
    var m_reloadFlow = Flow()
    var m_bottomViewSize: CGFloat = 20.0

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        table.estimatedRowHeight = 74
        table.rowHeight = UITableViewAutomaticDimension
        setUI()
    }

    func reloadInfoChild() {
//        ScreenAnalyticsManager.instance.setScreen(screenType: screenType)
        setUI()
    }
    
    func setUI() {
        self.table.separatorStyle = .none
        
        if (isNoneOtherGroup) {
            table.isHidden = true
        }
        
        m_reloadFlow.reset {
            self.table.reloadData()
        }
        
        lblTopSummary.text = "group_title_shared_description".localized
        lblTableTitle.text = "group_title_shared_list".localized
    }
    
    func deviceInfo(masterCid: Int) -> Array<UserInfoDevice>? {
        return DataManager.instance.m_userInfo.shareDevice.otherGroup?[masterCid]
    }
    
    func tableView(_  tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        Debug.print("otherGroupCount: \(otherGroupCount)")
        return otherGroupCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let _cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath) as! ShareMemberReceiveTableViewCell
        
        let _masterInfo = DataManager.instance.m_userInfo.shareMember.getOtherGroupMasterInfoByIndex(index: indexPath.row)
        
        _cell.setInit(index: indexPath.row, isNone: isNoneOtherGroup, masterInfo: _masterInfo)
        
        Debug.print("collectionViewLayout height:\(_cell.collection.collectionViewLayout.collectionViewContentSize.height)")

        let _deviceCount = deviceInfo(masterCid: _masterInfo?.aid ?? 0)?.count ?? 0

        _cell.collection.reloadData()
        _cell.frame = tableView.bounds
        _cell.layoutIfNeeded()
        _cell.collectionHeightConst.constant = _cell.collection.collectionViewLayout.collectionViewContentSize.height + m_bottomViewSize + (_deviceCount == 0 ? 50.0 : 0.0)

        return _cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        Debug.print("section: \(indexPath.section)")
        Debug.print("row: \(indexPath.row)")
        
        if (indexPath.section != 0) {
            if (isNoneOtherGroup) {
                return
            }
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        Debug.print("cell height: \(cell.frame.height)")
        let _bottomView = bottomView.copyView()
        cell.contentView.addSubview(_bottomView)
        _bottomView.frame = CGRect(x: 0 , y: cell.frame.height - 20, width: self.view.frame.size.width, height: _bottomView.frame.height)
    }
}
