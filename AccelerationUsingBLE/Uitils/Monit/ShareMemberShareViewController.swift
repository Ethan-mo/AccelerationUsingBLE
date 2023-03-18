//
//  ShareMemberShareViewController.swift
//  Monit
//
//  Created by 맥 on 2018. 2. 21..
//  Copyright © 2018년 맥. All rights reserved.
//

import UIKit

class ShareMemberShareViewController: BaseViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource {
    @IBOutlet weak var cvDevice: UICollectionView!
    @IBOutlet weak var constDevice: NSLayoutConstraint!
    @IBOutlet weak var cvMember: UICollectionView!
    @IBOutlet weak var constMember: NSLayoutConstraint!
    
    @IBOutlet weak var lblTopSummary: UILabel!
    @IBOutlet weak var lblGroupNameTitle: UILabel!
    @IBOutlet weak var lblGroupName: UILabel!
    @IBOutlet weak var lblDeviceTitle: UILabel!
    @IBOutlet weak var lblMemberTitle: UILabel!
    @IBOutlet weak var lblShortId: UILabel!
    @IBOutlet weak var lblBottomInfo: UILabel!
    
    enum SECTION: Int {
        case Device = 0
        case Member = 1
    }
    
    override var screenType: SCREEN_TYPE { get { return .SHARE_SHARE } }
    var m_parent: ShareMemberMainV2PageViewController!
    var m_flow = Flow()
    
    let m_memberCount = 4
    var reloadFlow = Flow()
    var deviceFlow = Flow()
    var memberFlow = Flow()
    var m_isMyGroup = true
    var m_groupIndex = 0
    var m_masterCloudId = 0
    var m_orginDeviceConst: CGFloat = 0.0
    var m_orginMemberConst: CGFloat = 0.0
    
    var masterInfo: UserInfoMember? {
        get {
            if (m_isMyGroup) {
                return DataManager.instance.m_userInfo.shareMember.getMyGroupMasterInfo()
            } else {
                return DataManager.instance.m_userInfo.shareMember.getOtherGroupMasterInfoByCloudId(cid: m_masterCloudId)
            }
        }
    }
    
    var memberInfo: Array<UserInfoMember>? {
        get {
            if (m_isMyGroup) {
                var _arr = [UserInfoMember]()
                if let _myGroup = DataManager.instance.m_userInfo.shareMember.myGroup {
                    for item in _myGroup {
                        if (item.cid == item.aid) {
                            continue
                        }
                        _arr.append(item)
                    }
                }
                return _arr
            } else {
                var _arr = [UserInfoMember]()
                if let _myGroup = DataManager.instance.m_userInfo.shareMember.otherGroup?[m_masterCloudId] {
                    for item in _myGroup {
                        if (item.cid == item.aid) {
                            continue
                        }
                        _arr.append(item)
                    }
                }
                return _arr
            }
        }
    }
    
    var deviceInfo: Array<UserInfoDevice>? {
        get {
            if (m_isMyGroup) {
                return DataManager.instance.m_userInfo.shareDevice.myGroup
            } else {
                return DataManager.instance.m_userInfo.shareDevice.otherGroup?[m_masterCloudId]
            }
        }
    }
    
    var groupName: String {
        get {
            var _groupName = ""
            if (m_isMyGroup) {
                _groupName = String(format: "%@ (%@)", masterInfo?.nick ?? "", "group_member_category_me".localized)
            } else {
                _groupName = String(format: "%@", masterInfo?.nick ?? "")
            }
            return _groupName
        }
    }
    
    func setInit(isMyGroup: Bool) {
        m_isMyGroup = isMyGroup
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Debug.print("[UI][\(self.classNameToString()).viewDidLoad()]")

        cvDevice.layer.borderColor = COLOR_TYPE.lblWhiteGray.color.cgColor
        cvDevice.layer.borderWidth = 1
        
        m_orginDeviceConst = constDevice.constant
        m_orginMemberConst = constMember.constant
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
        lblGroupName.text = groupName
        lblShortId.text = masterInfo?.sid ?? ""
        lblDeviceTitle.text = getSectionTitle(section: .Device)
        lblMemberTitle.text = getSectionTitle(section: .Member)
        
        if (m_isMyGroup) {
            lblBottomInfo.text = "group_share_member_description".localized
        } else {
            lblBottomInfo.text = "group_leave_description".localized
        }
        
        reloadFlow.reset {
            deviceFlow = Flow()
            memberFlow = Flow()
            self.cvDevice.reloadData()
            self.cvMember.reloadData()
        }
        
        lblTopSummary.text = "group_title_sharing_description".localized
        lblGroupNameTitle.text = "group_title_name".localized
        
        if (getSectionRowCount(section: .Device) > 0) {
            cvDevice.isHidden = false
        } else {
            cvDevice.isHidden = true
            constDevice.constant = 50
        }
    }

    func getSectionTitle(section: SECTION?) -> String {
        var _returnValue = ""
        switch section! {
        case .Device:
            if (deviceInfo != nil) {
                let _listString = String(format: "group_title_device_count".localized, getSectionRowCount(section: .Device).description)
                _returnValue = "\(_listString)"
            }
        case .Member:
            if (memberInfo != nil) {
                let _listString = String(format: "group_title_shared_member_count".localized, getSectionRowCount(section: .Member).description)
                _returnValue = "\(_listString)"
            }
        }
        return _returnValue
    }
    
    func  getSectionRowCount(section: SECTION?) -> Int {
        var _returnValue = 0
        switch section! {
        case .Device:
            if (deviceInfo != nil) {
                _returnValue = deviceInfo!.count
            }
        case .Member:
            if (memberInfo != nil) {
                _returnValue = memberInfo!.count
            }
        }
        return _returnValue
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (collectionView == cvDevice) {
            return getSectionRowCount(section: SECTION(rawValue: section))
        } else if (collectionView == cvMember) {
            return m_memberCount
        }
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if (collectionView == cvDevice) {
            let _cell = collectionView.dequeueReusableCell(withReuseIdentifier: "deviceCell", for: indexPath) as! ShareMemberShareDeviceCell
            
            let _info = deviceInfo?[indexPath.row]
            _cell.setInit(type: DEVICE_TYPE(rawValue: _info!.type)!, name: _info?.name ?? "")
            
            deviceFlow.one {
                constDevice.constant = m_orginDeviceConst + cvDevice.contentSize.height - _cell.bounds.height
                cvDevice.frame.size.height = cvDevice.contentSize.height
            }
            return _cell
        } else if (collectionView == cvMember) {
            let _cell = collectionView.dequeueReusableCell(withReuseIdentifier: "memberCell", for: indexPath) as! ShareMemberShareMemberCell
            
            var _isNone = true
            var _name = ""
            var _shortid = ""
            if let _memberInfo = memberInfo {
                for item in _memberInfo {
                    if (indexPath.row + 1 == item.ftype) {
                        _isNone = false
                        _name = item.nick
                        _shortid = item.sid
                        break
                    }
                }
            }
            _cell.setInit(parent: self, index: indexPath.row, isNone: _isNone, name: _name, shortid: _shortid)

            if (_isNone) {
                _cell.layer.borderColor = COLOR_TYPE.lblWhiteGray.color.cgColor
                _cell.layer.borderWidth = 1
            } else {
                _cell.layer.borderColor = COLOR_TYPE.green.color.cgColor
                _cell.layer.borderWidth = 1
            }
       
            memberFlow.one {
                constMember.constant = m_orginMemberConst + cvMember.contentSize.height - _cell.bounds.height
                cvMember.frame.size.height = cvMember.contentSize.height
            }
            return _cell
        }
        
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        var _padding: CGFloat = 0.0
        var _height: CGFloat = 0.0
        if (collectionView == cvDevice) {
            _height = 74.0
            _padding = 0
            let collectionViewSize = collectionView.frame.size.width - _padding
            return CGSize(width: collectionViewSize/2, height: _height)
        } else if (collectionView == cvMember) {
            _height = 74.0
            _padding = 14.0 * 4
            let collectionViewSize = collectionView.frame.size.width - _padding
            return CGSize(width: collectionViewSize/2, height: _height)
        }
        return CGSize()
    }
}
