//
//  DataController_hubGraph.swift
//  Monit
//
//  Created by 맥 on 2017. 9. 27..
//  Copyright © 2017년 맥. All rights reserved.
//

import Foundation
import SwiftyJSON

class DiaperSensingLogSet {
    var m_tem: String = ""
    var m_hum: String = ""
    var m_voc: String = ""
    var m_cap: String = ""
    var m_act: String = ""
    var m_sen: String = ""
    var m_mlv: String = ""
    var m_eth: String = ""
    var m_co2: String = ""
    var m_pres: String = ""
    var m_comp: String = ""
    
    init (tem: String, hum: String, voc: String, cap: String, act: String, sen: String, mlv: String, eth: String, co2: String, pres: String, comp: String) {
        self.m_tem = tem
        self.m_hum = hum
        self.m_voc = voc
        self.m_cap = cap
        self.m_act = act
        self.m_sen = sen
        self.m_mlv = mlv
        self.m_eth = eth
        self.m_co2 = co2
        self.m_pres = pres
        self.m_comp = comp
    }
}

class DiaperSensingLogInfo: DiaperSensingLogSet {
    var m_id: Int = 0
    var m_did: Int = 0
    var m_time: String = ""
    var m_cnt: Int = 0
    var m_cnt_second: Int = 0
    var m_castTimeInfo: CastDateFormat?

    init(id: Int, did: Int, time: String?, cnt: Int, cnt_second: Int, dataSet: DiaperSensingLogSet) {
        super.init(tem: dataSet.m_tem, hum: dataSet.m_hum, voc: dataSet.m_voc, cap: dataSet.m_cap, act: dataSet.m_act, sen: dataSet.m_sen, mlv: dataSet.m_mlv, eth: dataSet.m_eth, co2: dataSet.m_co2, pres: dataSet.m_pres, comp: dataSet.m_comp)
        self.m_id = id
        self.m_did = did
        if let _time = time {
            self.m_castTimeInfo = CastDateFormat(time: _time)
        }
        self.m_time = time ?? ""
        self.m_cnt = cnt
        self.m_cnt_second = cnt_second
    }
    
    func updateInfo(info: DiaperSensingLogSet) {
        if (info.m_tem != "") {
            self.m_cnt += 1 // m_tem이 들어올때만 카운트를 올려준다.
            self.m_tem = self.m_tem == "" ? info.m_tem : "\(info.m_tem),\(self.m_tem)"
        }
        if (info.m_hum != "") {
            self.m_hum = self.m_hum == "" ? info.m_hum : "\(info.m_hum),\(self.m_hum)"
        }
        if (info.m_voc != "") {
            self.m_voc = self.m_voc == "" ? info.m_voc : "\(info.m_voc),\(self.m_voc)"
        }
        if (info.m_cap != "") {
            self.m_cap = self.m_cap == "" ? info.m_cap : "\(info.m_cap),\(self.m_cap)"
        }
        if (info.m_act != "") {
            self.m_act = self.m_act == "" ? info.m_act : "\(info.m_act),\(self.m_act)"
        }
        if (info.m_sen != "") {
            self.m_sen = self.m_sen == "" ? info.m_sen : "\(info.m_sen),\(self.m_sen)"
        }
        if (info.m_mlv != "") {
            self.m_mlv = self.m_mlv == "" ? info.m_mlv : "\(info.m_mlv),\(self.m_mlv)"
        }
        if (info.m_eth != "") {
            self.m_cnt_second += 1 // m_eth이 들어올때만 카운트를 올려준다.
            self.m_eth = self.m_eth == "" ? info.m_eth : "\(info.m_eth),\(self.m_eth)"
        }
        if (info.m_co2 != "") {
            self.m_co2 = self.m_co2 == "" ? info.m_co2 : "\(info.m_co2),\(self.m_co2)"
        }
        if (info.m_pres != "") {
            self.m_pres = self.m_pres == "" ? info.m_pres : "\(info.m_pres),\(self.m_pres)"
        }
        if (info.m_comp != "") {
            self.m_comp = self.m_comp == "" ? info.m_comp : "\(info.m_comp),\(self.m_comp)"
        }
    }
}

// id를 발급하기 위해 코어데이터에 먼저 삽입 후, 런타임 데이터에 저장한다.
class DataController_DiaperSensingLog {
    func saveData(info: DiaperSensingLogInfo) {
        // 저장된 열 있으면 업데이트
        if let _arr = DataManager.instance.m_coreDataInfo.storeDiaperSensingLog.loadByDid(did: info.m_did), _arr.count > 0 {
            var _isAdd = false
            if let _max = _arr.max(by: { $0.m_castTimeInfo!.m_timeCast < $1.m_castTimeInfo!.m_timeCast }) {
                // 마지막 열이 카운트가 30개가 지났으면 새로운 열로 추가.
                if (_max.m_cnt >= Config.SENSOR_AUTO_POLLING_SENDING_TIME && _max.m_cnt_second >= Config.SENSOR_AUTO_POLLING_SENDING_TIME) {
                    _isAdd = true
                }
                // 마지막 열이 2초가 지났으면 새로운 열로 추가. (끊어져서 시간 간격이 벌어진 경우)
                let _diff = Calendar.current.dateComponents([.second], from: _max.m_castTimeInfo!.m_timeCast.adding(second: _max.m_cnt - 1), to: info.m_castTimeInfo!.m_timeCast)
                if (Int(_diff.second ?? 0) > 2) {
                    _isAdd = true
                }
                
                if (_isAdd) {
                    addItem(item: info, isBackground: SystemManager.instance.getApplicationStatus() == .background)
                    sendingData(id: _max.m_id, did: nil)
                } else {
                    _max.updateInfo(info: info)
                    DataManager.instance.m_coreDataInfo.storeDiaperSensingLog.updateItem(info: _max)
                }
            }
        // 저장된 열 없으면 추가.
        } else {
            addItem(item: info, isBackground: SystemManager.instance.getApplicationStatus() == .background)
        }
    }
    
    func sendingData(id: Int?, did: Int?) {
        if let _id = id {
            if let _info = DataManager.instance.m_coreDataInfo.storeDiaperSensingLog.loadById(id: _id) {
                sendPacket(info: _info)
            }
        } else if let _did = did {
            if let _arr = DataManager.instance.m_coreDataInfo.storeDiaperSensingLog.loadByDid(did: _did) {
                for item in _arr {
                    sendPacket(info: item)
                }
            }
        } else {
            if let _arr = DataManager.instance.m_coreDataInfo.storeDiaperSensingLog.load() {
                for item in _arr {
                    sendPacket(info: item)
                }
            }
        }
    }
    
    func sendPacket(info: DiaperSensingLogInfo) {
        let _send = Send_SetDiaperSensingLog()
        _send.aid = DataManager.instance.m_userInfo.account_id
        _send.token = DataManager.instance.m_userInfo.token
        _send.did = info.m_did
        _send.tem = info.m_tem
        _send.hum = info.m_hum
        _send.voc = info.m_voc
        _send.cap = info.m_cap
        _send.act = info.m_act
        _send.sen = info.m_sen
        _send.mlv = info.m_mlv
        _send.eth = info.m_eth
        _send.co2 = info.m_co2
        _send.pres = info.m_pres
        _send.comp = info.m_comp
        _send.time = info.m_castTimeInfo!.m_timeCast.adding(second: info.m_cnt - 1).ToPacketTime()
        _send.isIndicator = false
        _send.isErrorPopupOn = false
        _send.logPrintLevel = .dev
        NetworkManager.instance.Request(_send) { (json) -> () in
            let receive = Receive_SetDiaperSensingLog(json)
            switch receive.ecd {
            case .success: DataManager.instance.m_coreDataInfo.storeDiaperSensingLog.deleteItemsById(id: info.m_id)
            default: Debug.print("[ERROR] invaild errcod", event: .error)
            }
        }
    }
    
    func addItem(item: DiaperSensingLogInfo, isBackground: Bool = false) {
        let _entity = DataManager.instance.m_coreDataInfo.getEntity(name: DataManager.instance.m_coreDataInfo.storeDiaperSensingLog.m_entityName)
        _ = DataManager.instance.m_coreDataInfo.storeDiaperSensingLog.addItemToEntity(entity: _entity!, item: item, isBackground: isBackground)
        if (isBackground) {
            DataManager.instance.m_coreDataInfo.backgroundSaveData()
        } else {
            DataManager.instance.m_coreDataInfo.saveData()
        }
    }
}

