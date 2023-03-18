//
//  DeviceMainTableViewController.swift
//  Monit
//
//  Created by 맥 on 2017. 9. 14..
//  Copyright © 2017년 맥. All rights reserved.
//

import UIKit

class DeviceMainTableViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {
    class CardViewInfo {
        var view: UIView?
        var height: CGFloat = 0
        
        init (view: UIView, height: CGFloat = 0) {
            self.view = view
            self.height = height
        }
    }

    @IBOutlet weak var table: UITableView!
    @IBOutlet var bottomView: UIView!
    @IBOutlet weak var lblBottomSummary: UILabel!
    @IBOutlet weak var imgShare: UIButton!
    
    var m_parent: DeviceMainViewController?
    var m_refreshControl: UIRefreshControl?
    var m_lstView: [CardViewInfo] = []
    
    enum DEVICE_FIRMWARE_UPDATE_TYPE {
        case none
        case normal
        case force
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Debug.print("[UI][\(self.classNameToString()).viewDidLoad()]")
        
        imgShare.isHidden = true
        if (Config.channel == .kc) {
            imgShare.isHidden = false
        }
        imgShare.setImage(UIImage(named: Config.channel == .kc ? "imgShareForKc" : "imgShare"), for: .normal)
        m_refreshControl = UIRefreshControl()
//        m_refreshControl!.addTarget(self, action: #selector(refresh), for: .valueChanged)
        table.addSubview(m_refreshControl!)
        
//        _ = UIManager.instance.isBluetoothPopup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUI()
    }
    
    func refresh() {
        Debug.print("refresh", event: .warning)
        _ = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(reloadData), userInfo: nil, repeats: false)
    }
    
    @objc func reloadData() {
        SystemManager.instance.refrashData(handler: { () in
            self.m_refreshControl?.endRefreshing()
            self.setUI()
        })
    }

    func setInfo() {
    }
    
    func reloadInfoChild() {
        setUI()
    }
    
    func setUI() {
        table.separatorStyle = .none
        setView()
        table.reloadData()
        goToScene()
        needHubPopup()
        needLampPopup()
    }
    
    func setView() {
        setTopView()
        bottomView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 100)
        lblBottomSummary.text = "swipe_down_to_refresh".localized
        table.tableFooterView = bottomView
    }
    
    func setTopView() {
        m_lstView.removeAll()
        
        if (UIManager.instance.isWarningDeviceMainBluetooth) {
            let _view: CardNoticeView = .fromNib()
            let _height: CGFloat = 66
            _view.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: _height)
            _view.setInit(idx: 0, type: .warning, customType: .bluetooth, description: "contents_need_bluetooth_reseting".localized, height: _height, handler: { (value) in
                if (Config.channel == .kc) {
                    let _param = UIManager.instance.getBoardParam(board: BOARD_TYPE.connect_device_sensor, boardId: 29)
                    let _scene = UIManager.instance.sceneMoveNaviPush(scene: .customWebView, isAniamtion: false) as! CustomWebViewController
                    _scene.setInit(url: "\(Config.BOARD_DEFAULT_URL)\(_param)", naviTitle: "help".localized)
                } else {
                    if (Config.IS_AVOBE_OS13) {
                    } else {
                        _ = Utility.urlOpen(UIManager.instance.getMoveBluetoothSetting()) // 앱 설정으로만 가게됨
                    }
                }
            })
            
            m_lstView.append(CardViewInfo(view: _view, height: _height))
        }
        
        if let _arrTotalSensor = DataManager.instance.m_dataController.device.getTotalUserInfoList {
            var _i: Int = 0
            for item in _arrTotalSensor {
                if (item.type == DEVICE_TYPE.Sensor.rawValue) {
                    var _updateType: DEVICE_FIRMWARE_UPDATE_TYPE = .none
                    let _lastVer = DataManager.instance.m_configData.m_latestSensorVersion
                    if (Utility.isUpdateVersion(latestVersion: _lastVer, currentVersion: item.fwv)) {
                        _updateType = .normal
                    }
                    let _lastForceVer = DataManager.instance.m_configData.m_latestSensorForceVersion
                    if (Utility.isUpdateVersion(latestVersion: _lastForceVer, currentVersion: item.fwv)) {
                        _updateType = .force
                    }
                    
                    #if DEBUG
//                    _updateType = .force
                    #endif

                    switch _updateType {
                    case .normal, .force:
                        let _view: CardNoticeView = .fromNib()
                        let _height: CGFloat = _updateType == .normal ? 66 : 80
                        _view.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: _height)
                        _view.setInit(idx: _i, type: .info, customType: .firmware, description: "[\(item.name)] \(_lastVer) \(_updateType == .normal ? "contents_need_sensor_firmware_update".localized : "contents_need_sensor_firmware_update_force".localized)", height: _height, handler: { (value) in
                            if let _value = value as? Int {
                                UIManager.instance.m_finishScenePush = .deviceSetupSensorFirmware
                                self.moveDetail(rowIndex: _value, isAnimation: false)
                            }
                        })
                        m_lstView.append(CardViewInfo(view: _view, height: _height))
                    default:
                        break
                    }
                }
                if (item.type == DEVICE_TYPE.Hub.rawValue) {
                    var _updateType: DEVICE_FIRMWARE_UPDATE_TYPE = .none
                    let _lastVer = DataManager.instance.m_configData.m_latestHubVersion
                    if (Utility.isUpdateVersion(latestVersion: _lastVer, currentVersion: item.fwv)) {
                        _updateType = .normal
                    }
                    let _lastForceVer = DataManager.instance.m_configData.m_latestHubForceVersion
                    if (Utility.isUpdateVersion(latestVersion: _lastForceVer, currentVersion: item.fwv)) {
                        _updateType = .force
                    }
                    
                    #if DEBUG
//                    _updateType = .force
                    #endif
                    
                    switch _updateType {
                    case .normal, .force:
                        let _view: CardNoticeView = .fromNib()
                        let _height: CGFloat = _updateType == .normal ? 66 : 80
                        _view.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: _height)
                        _view.setInit(idx: _i, type: .info, customType: .firmware, description: "[\(item.name)] \(_lastVer) \(_updateType == .normal ? "contents_need_hub_firmware_update".localized : "contents_need_hub_firmware_update_force".localized)", height: _height, handler: { (value) in
                            if let _value = value as? Int {
                                UIManager.instance.m_finishScenePush = .deviceSetupHubFirmware
                                self.moveDetail(rowIndex: _value, isAnimation: false)
                            }
                        })
                        m_lstView.append(CardViewInfo(view: _view, height: _height))
                    default:
                        break
                    }
                }
                if (item.type == DEVICE_TYPE.Lamp.rawValue) {
                    var _updateType: DEVICE_FIRMWARE_UPDATE_TYPE = .none
                    let _lastVer = DataManager.instance.m_configData.m_latestLampVersion
                    if (Utility.isUpdateVersion(latestVersion: _lastVer, currentVersion: item.fwv)) {
                        _updateType = .normal
                    }
                    let _lastForceVer = DataManager.instance.m_configData.m_latestLampForceVersion
                    if (Utility.isUpdateVersion(latestVersion: _lastForceVer, currentVersion: item.fwv)) {
                        _updateType = .force
                    }
                    
                    #if DEBUG
                    //                    _updateType = .force
                    #endif
                    
                    switch _updateType {
                    case .normal, .force:
                        let _view: CardNoticeView = .fromNib()
                        let _height: CGFloat = _updateType == .normal ? 66 : 80
                        _view.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: _height)
                        _view.setInit(idx: _i, type: .info, customType: .firmware, description: "[\(item.name)] \(_lastVer) \(_updateType == .normal ? "contents_need_hub_firmware_update".localized : "contents_need_hub_firmware_update_force".localized)", height: _height, handler: { (value) in
                            if let _value = value as? Int {
                                UIManager.instance.m_finishScenePush = .deviceSetupLampFirmware
                                self.moveDetail(rowIndex: _value, isAnimation: false)
                            }
                        })
                        m_lstView.append(CardViewInfo(view: _view, height: _height))
                    default:
                        break
                    }
                }
                _i += 1
            }
        }
        
        if (m_lstView.count == 0) {
            table.tableHeaderView = nil
        } else {
            let _topView = UIView()
            var _height: CGFloat = 0
            for item in m_lstView {
                _height += item.height
            }
            _topView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: CGFloat(_height))
            
            // stackview 써서 뷰마다 사이즈 지정 잘 안됨..
            let stackView   = UIStackView(frame: _topView.bounds)
            stackView.axis  = .vertical
            stackView.distribution  = .fillEqually
            stackView.alignment = .fill
            stackView.spacing   = 0
            stackView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            for item in m_lstView {
                stackView.addArrangedSubview(item.view!)
            }
            _topView.addSubview(stackView)
            table.tableHeaderView = _topView
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DataManager.instance.m_dataController.device.getTotalCount
    }

    // 개별로 할 필요 없고, 원본 데이터만 갱신해주면, 여기 클래스에서 reload 하면 갱신됨.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let _info = DataManager.instance.m_dataController.device.getUserInfoByIndex(index: indexPath.row) {
            var cell: UITableViewCell?
            switch DEVICE_TYPE(rawValue: _info.type)! {
            case .Sensor:
                switch Config.channel {
                case .goodmonit, .kao:
                    cell = Bundle.main.loadNibNamed("ConnectSensorTableViewCell", owner: self, options: nil)?.first as! ConnectSensorTableViewCell
                case .monitXHuggies:
                    cell = Bundle.main.loadNibNamed("ConnectSensorTableViewCell", owner: self, options: nil)?.first as! ConnectSensorTableViewCell
                case .kc:
                    cell = Bundle.main.loadNibNamed("ConnectSensorForKcTableViewCell", owner: self, options: nil)?.first as! ConnectSensorForKcTableViewCell
                }
            case .Hub:
                switch Config.channel {
                case .goodmonit, .kao:
                    cell = Bundle.main.loadNibNamed("ConnectHubTableViewCell", owner: self, options: nil)?.first as! ConnectHubTableViewCell
                case .monitXHuggies:
                    cell = Bundle.main.loadNibNamed("ConnectHubTableViewCell", owner: self, options: nil)?.first as! ConnectHubTableViewCell
                case .kc:
                    cell = Bundle.main.loadNibNamed("ConnectHubForKcTableViewCell", owner: self, options: nil)?.first as! ConnectHubForKcTableViewCell
                }
            case .Lamp:
                cell = Bundle.main.loadNibNamed("ConnectLampTableViewCell", owner: self, options: nil)?.first as! ConnectLampTableViewCell
            }
            
            let _detailInfo = DeviceDetailInfo()
            _detailInfo.m_deviceType = DataManager.instance.m_dataController.device.getStatusByIndex(index: indexPath.row)
            _detailInfo.m_index = indexPath.row
            if let _getDeviceInfo = DataManager.instance.m_dataController.device.getUserInfoByIndex(index: indexPath.row) {
                _detailInfo.m_cid = _getDeviceInfo.cid
                _detailInfo.m_did = _getDeviceInfo.did
            }
            
            if let _sensorSell = cell as? ConnectSensorTableViewCell {
                _sensorSell.m_detailInfo = _detailInfo
                _sensorSell.setInit()
            }
            if let _sensorSell = cell as? ConnectSensorForKcTableViewCell {
                _sensorSell.m_detailInfo = _detailInfo
                _sensorSell.setInit()
            }
            
            if let _hubSell = cell as? ConnectHubTableViewCell {
                _hubSell.m_detailInfo = _detailInfo
                _hubSell.setInit()
            }
            if let _hubSell = cell as? ConnectHubForKcTableViewCell {
                _hubSell.m_detailInfo = _detailInfo
                _hubSell.setInit()
            }
            
            if let _lampSell = cell as? ConnectLampTableViewCell {
                _lampSell.m_detailInfo = _detailInfo
                _lampSell.setInit()
            }
            return cell!
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        Debug.print("section: \(indexPath.section)")
        Debug.print("row: \(indexPath.row)")

        moveDetail(rowIndex: indexPath.row)
    }
    
    func moveDetail(rowIndex: Int, isAnimation: Bool = true) {
        let _detailInfo = DeviceDetailInfo()
        var _deviceType = 0
        _detailInfo.m_deviceType = DataManager.instance.m_dataController.device.getStatusByIndex(index: rowIndex)
        if let _getDeviceInfo = DataManager.instance.m_dataController.device.getUserInfoByIndex(index: rowIndex) {
            _detailInfo.m_cid = _getDeviceInfo.cid
            _detailInfo.m_did = _getDeviceInfo.did
            _deviceType = _getDeviceInfo.type
        }
        
        let _vc: UIViewController?
        switch DEVICE_TYPE(rawValue: _deviceType)! {
        case .Sensor:
            _vc = UIManager.instance.sceneMoveNaviPush(scene: .sensorDetail, isAniamtion: isAnimation) as! DeviceSensorDetailViewController
        case .Hub:
            _vc = UIManager.instance.sceneMoveNaviPush(scene: .hubDetail, isAniamtion: isAnimation) as! DeviceHubDetailViewController
        case .Lamp: // todo. lamp
            _vc = UIManager.instance.sceneMoveNaviPush(scene: .lampDetail, isAniamtion: isAnimation) as! DeviceLampDetailViewController
        }
        
        if let _sensor = _vc as? DeviceSensorDetailViewController {
            _sensor.m_detailInfo = _detailInfo
        }
        if let _hub = _vc as? DeviceHubDetailViewController {
            _hub.m_detailInfo = _detailInfo
        }
        if let _lamp = _vc as? DeviceLampDetailViewController {
            _lamp.m_detailInfo = _detailInfo
        }
    }
    
    func goToScene() {
        if (UIManager.instance.m_finishScenePush == .deviceSetupSensorFirmware || UIManager.instance.m_finishScenePush == .deviceSetupHubFirmware || UIManager.instance.m_finishScenePush == .deviceSetupLampFirmware) {
            if (UIManager.instance.m_moveSceneDeviceType != 0 && UIManager.instance.m_moveSceneDeviceID != 0) {
                goToDeviceDetail(type: UIManager.instance.m_moveSceneDeviceType, did: UIManager.instance.m_moveSceneDeviceID)
            } else {
                UIManager.instance.m_finishScenePush = nil
            }
            
            UIManager.instance.m_moveSceneDeviceType = 0
            UIManager.instance.m_moveSceneDeviceID = 0
        }
    }
    
    func goToDeviceDetail(type: Int, did: Int) {
        if let _arrTotalSensor = DataManager.instance.m_dataController.device.getTotalUserInfoList {
            var _i: Int = 0
            for item in _arrTotalSensor {
                if (item.type == type && item.did == did) {
                    moveDetail(rowIndex: _i, isAnimation: false)
                }
                _i += 1
            }
        }
    }
    
    func needHubPopup() {
        if (UIManager.instance.m_finishScenePush == nil) {
            if (UIManager.instance.m_deviceNeedHubPopup) {
                if let _arrHub = DataManager.instance.m_userInfo.deviceStatus.m_hubStatus.m_hubTypes {
                    if (_arrHub.count == 0) {
                        _ = PopupManager.instance.onlyContents(contentsKey: "dialog_contents_ask_for_connectint_hub", confirmType: .noYes,
                                                               okHandler: { () -> () in
                                                                UIManager.instance.setMoveNextScene(finishScenePush: .deviceRegisterHub, moveScene: .initView)
                        })
                    }
                }
                UIManager.instance.m_deviceNeedHubPopup = false
            }
        }
    }
    
    func needLampPopup() {
        if (UIManager.instance.m_finishScenePush == nil) {
            if (UIManager.instance.m_deviceNeedLampPopup) {
                if let _arrLamp = DataManager.instance.m_userInfo.deviceStatus.m_lampStatus.m_hubTypes {
                    if (_arrLamp.count == 0) {
                        _ = PopupManager.instance.onlyContents(contentsKey: "dialog_contents_ask_for_connectint_hub", confirmType: .noYes,
                                                               okHandler: { () -> () in
                                                                UIManager.instance.setMoveNextScene(finishScenePush: .deviceRegisterLamp, moveScene: .initView)
                        })
                    }
                }
                UIManager.instance.m_deviceNeedLampPopup = false
            }
        }
    }
    
    var canRefresh = true
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < -80 { //change 100 to whatever you want
            if canRefresh && !self.m_refreshControl!.isRefreshing {
                self.canRefresh = false
                self.m_refreshControl!.beginRefreshing()
                self.refresh() // your viewController refresh function
            }
        } else if scrollView.contentOffset.y >= 0 {
            self.canRefresh = true
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.001
    }

    @IBAction func onClick_share(_ sender: UIButton) {
        _ = UIManager.instance.sceneMoveNaviPush(scene: .shareMemberMain)
    }
}
