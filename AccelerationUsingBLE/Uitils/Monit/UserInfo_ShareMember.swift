//
//  UserInfo_ShareInfo.swift
//  Monit
//
//  Created by 맥 on 2017. 9. 8..
//  Copyright © 2017년 맥. All rights reserved.
//

import UIKit
import CoreData

class UserInfoMember {
    var cid: Int = 0
    var aid: Int = 0
    var nick: String = ""
    var sid: String = ""
    var ftype: Int = 0
    
    init(cid: Int, aid: Int, nick: String, sid: String, ftype: Int) {
        self.cid = cid
        self.aid = aid
        self.nick = nick
        self.sid = sid
        self.ftype = ftype
    }
}

class UserInfo_ShareMember {
    
    var myGroup: Array<UserInfoMember>?
    var otherGroup : Dictionary<Int, Array<UserInfoMember>>?
  
    func sort() {
        // my group
        var i = 0
        for item in myGroup! {
            if (item.cid == item.aid) {
                break
            }
            i += 1
        }
        let element = myGroup!.remove(at: i)
        myGroup!.insert(element, at: 0)
        
        /// other group
        // group master
        for (key, values) in otherGroup! {
            var i = 0
            for item in values {
                if (item.cid == item.aid) {
                    break
                }
                i += 1
            }
            var _copyValues = values
            let element = _copyValues.remove(at: i)
            _copyValues.insert(element, at: 0)
            otherGroup?[key] = _copyValues
        }
        // my id
        for (key, values) in otherGroup! {
            var i = 0
            for item in values {
                if (item.aid == DataManager.instance.m_userInfo.account_id) {
                    break
                }
                i += 1
            }
            var _copyValues = values
            let element = _copyValues.remove(at: i)
            _copyValues.insert(element, at: 0)
            otherGroup?[key] = _copyValues
        }
    }
    
    func getAllGroupByCid(cid: Int) -> UserInfoMember? {
        if let _myGroup = myGroup {
            for item in _myGroup {
                if (item.aid == cid) {
                    return item
                }
            }
        }
        
        if let _otherGroup = getOtherGroupMasterInfoByCloudId(cid: cid) {
            return _otherGroup
        }
        return nil
    }
    
    func getMyGroupMasterInfo() -> UserInfoMember? {
        if let _myGroup = myGroup {
            for item in _myGroup {
                if (item.aid == DataManager.instance.m_userInfo.account_id) {
                    return item
                }
            }
        }
        return nil
    }
    
    func getOtherGroupInfoByIndex(index: Int) -> Array<UserInfoMember>? {
        var _addCount = 0
        for (_, values) in otherGroup! {
            if (_addCount == index) {
                return values
            }
            _addCount += 1
        }
        return nil
    }
    
    func getOtherGroupMasterInfoByCloudId(cid: Int) -> UserInfoMember? {
        if let _arrInfo = otherGroup?[cid] {
            for item in _arrInfo {
                if (item.aid == cid) {
                    return item
                }
            }
        }
        return nil
    }

    func getOtherGroupMasterInfoByIndex(index: Int) -> UserInfoMember? {
        if let _arrInfo = getOtherGroupInfoByIndex(index: index) {
            for item in _arrInfo {
                if (item.aid == item.cid) {
                    return item
                }
            }
        }
        return nil
    }
    
    func addMyGroupMember(addMember: UserInfoMember) {
        myGroup?.append(addMember)
    }
    
    func deleteMyGroupMember(aid: Int) {
        var _isFound = false
        var i = 0
        for item in myGroup! {
            if (item.aid == aid) {
                _isFound = true
                break
            }
            i += 1
        }
        if (_isFound) {
            myGroup?.remove(at: i)
        }
    }
    
    func leaveGroup(cloudId: Int) {
        otherGroup?.removeValue(forKey: cloudId)
    }
}
