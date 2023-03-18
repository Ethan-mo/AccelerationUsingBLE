//
//  DataController_ShareMember.swift
//  Monit
//
//  Created by 맥 on 2017. 9. 21..
//  Copyright © 2017년 맥. All rights reserved.
//

import Foundation

class DataController_ShareMember {
    
    func setInit(member: Array<UserInfoMember>?) {
        saveLocal(arrData: member)
        DataManager.instance.m_userInfo.shareMember.sort()
    }

    func saveLocal(arrData: Array<UserInfoMember>?) {
        let _arrData = arrData
        
        // myGroup
        var _myGroup = [UserInfoMember]()
        for item in _arrData! {
            if (item.cid == DataManager.instance.m_userInfo.account_id)
            {
                let _member = UserInfoMember(cid: item.cid, aid: item.aid, nick: item.nick, sid: item.sid, ftype: item.ftype)
                _myGroup.append(_member)
            }
        }
        DataManager.instance.m_userInfo.shareMember.myGroup = _myGroup
        
        // otherGroup
        var _otherGroup = Dictionary<Int, Array<UserInfoMember>>()
        var _groupList = [Int]()
        for item in _arrData! {
            if (item.cid != DataManager.instance.m_userInfo.account_id) {
                if (!_groupList.contains(item.cid)) {
                    _groupList.append(item.cid)
                    _otherGroup.updateValue(Array<UserInfoMember>(), forKey: item.cid)
                }
            }
        }
        
        for item in _arrData! {
            if (item.cid != DataManager.instance.m_userInfo.account_id)
            {
                let _member = UserInfoMember(cid: item.cid, aid: item.aid, nick: item.nick, sid: item.sid, ftype: item.ftype)
                _otherGroup[item.cid]?.append(_member)
            }
        }
        DataManager.instance.m_userInfo.shareMember.otherGroup = _otherGroup
    }
    
    func loadLocal() -> Array<UserInfoMember>? {
        var _arrData = [UserInfoMember]()
        
        // my group
        for item in DataManager.instance.m_userInfo.shareMember.myGroup! {
            _arrData.append(item)
        }
        // other group
        for (_, values) in DataManager.instance.m_userInfo.shareMember.otherGroup! {
            for item in values {
                _arrData.append(item)
            }
        }
        return _arrData
    }
}
