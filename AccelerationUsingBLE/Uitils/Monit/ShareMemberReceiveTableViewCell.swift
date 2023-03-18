//
//  ShareMemberReceiveTableViewCell.swift
//  Monit
//
//  Created by 맥 on 2018. 3. 5..
//  Copyright © 2018년 맥. All rights reserved.
//

import UIKit
import SwiftyJSON

class ShareMemberReceiveTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var collection: UICollectionView!
    @IBOutlet weak var collectionHeightConst: NSLayoutConstraint!
    @IBOutlet weak var lblGroupTitle: UILabel!
    @IBOutlet weak var btnLeave: UIButton!
    @IBOutlet weak var lblNoneDevice: UILabel!
    
    var m_index = -1
    var m_isNone: Bool = false
    var m_masterInfo: UserInfoMember?
    var m_deviceFlow = Flow()
    
    var deviceInfo: Array<UserInfoDevice>? {
        get {
            return DataManager.instance.m_userInfo.shareDevice.otherGroup?[m_masterInfo?.cid ?? 0]
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.collection.delegate = self
        self.collection.dataSource = self
    }
    
    func setInit(index: Int, isNone: Bool, masterInfo: UserInfoMember?) {
        m_index = index
        m_isNone = isNone
        m_masterInfo = masterInfo
        setUI()
    }
    
    func setUI() {
        var _name = m_masterInfo?.nick ?? ""
        _name += " "
        let _shortid = m_masterInfo?.sid ?? ""
        
        let attrs1 = [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 16), NSAttributedStringKey.foregroundColor : COLOR_TYPE.lblDarkGray.color]
        
        let attrs2 = [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 14), NSAttributedStringKey.foregroundColor : COLOR_TYPE.lblGray.color]
        
        let attributedString1 = NSMutableAttributedString(string: _name, attributes:attrs1)
        
        let attributedString2 = NSMutableAttributedString(string: _shortid, attributes:attrs2)
        
        attributedString1.append(attributedString2)
        self.lblGroupTitle.attributedText = attributedString1
        btnLeave.setTitle("btn_group_leave".localized.uppercased(), for: .normal)
        if (deviceInfo?.count ?? 0 != 0) {
            lblNoneDevice.isHidden = true
        } else {
            lblNoneDevice.isHidden = false
            lblNoneDevice.text = "group_share_device_list_empty".localized
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return deviceInfo?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let _cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionCell", for: indexPath) as! ShareMemberShareDeviceCell

        let _info = deviceInfo?[indexPath.row]
        _cell.setInit(type: DEVICE_TYPE(rawValue: _info!.type)!, name: _info?.name ?? "")

        return _cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let _padding: CGFloat = 10
        let _height: CGFloat = 74.0
        
        let collectionViewSize = UIManager.instance.rootCurrentView!.view.frame.size.width - _padding

        return CGSize(width: collectionViewSize / 2, height: _height)
    }
    
    @IBAction func onClick_leave(_ sender: UIButton) {
        let _masterInfo = DataManager.instance.m_userInfo.shareMember.getOtherGroupMasterInfoByCloudId(cid: m_masterInfo?.aid ?? 0)
        let _popupInfo = PopupDetailInfo()
        _popupInfo.title = "dialog_group_leave_title".localized
        _popupInfo.contents = String(format: "dialog_contents_group_leave_confirm".localized, _masterInfo!.nick, _masterInfo!.sid)
        _popupInfo.buttonType = .both
        _popupInfo.left = "btn_cancel".localized
        _popupInfo.right = "btn_ok".localized
        _popupInfo.rightColor = COLOR_TYPE.mint.color
        _ = PopupManager.instance.setDetail(popupDetailInfo: _popupInfo, okHandler: { () -> () in
            let send = Send_LeaveCloud()
            send.aid = DataManager.instance.m_userInfo.account_id
            send.token = DataManager.instance.m_userInfo.token
            send.tid = _masterInfo!.aid
            NetworkManager.instance.Request(send) { (json) -> () in
                self.getReceiveData(json)
            }
        })
    }
    
    func getReceiveData(_ json: JSON) {
        let receive = Receive_LeaveCloud(json)
        switch receive.ecd {
        case .success:
            //            DataManager.instance.m_userInfo.shareMember.leaveGroup(cloudId: m_masterCloudId)
            //            DataManager.instance.m_userInfo.shareDevice.leaveGroup(cloudId: m_masterCloudId)
            
            _ = PopupManager.instance.onlyContents(contentsKey: "toast_leave_group_succeeded", confirmType: .ok, okHandler: { () -> () in
                UIManager.instance.setMoveNextScene(finishScenePush: .shareMemberMain, moveScene: .initView)
            })
        case .shareMember_noneGroup: _ = PopupManager.instance.onlyContents(contentsKey: "toast_leave_group_failed", confirmType: .ok)
        default: Debug.print("[ERROR] invaild errcod", event: .error)
        }
    }
}
