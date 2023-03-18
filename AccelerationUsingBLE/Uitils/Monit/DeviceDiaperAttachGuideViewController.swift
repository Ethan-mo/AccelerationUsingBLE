//
//  DeviceDiaperAttachViewController.swift
//  Monit
//
//  Created by john.lee on 05/09/2019.
//  Copyright © 2019 맥. All rights reserved.
//

import UIKit
import CoreBluetooth

class DeviceDiaperAttachGuideViewController: BaseViewController, UIScrollViewDelegate {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var lblGuideTitle: UILabel!
    @IBOutlet weak var btnClose: UIButton!
    
    var slides: [SlideBaseView] = [];

    var m_peripheral: CBPeripheral?
    var m_bleInfo: BleInfo? {
        get {
            return DataManager.instance.m_userInfo.connectSensor.getSensorByPeripheral(peripheral: m_peripheral)
        }
    }
    
    var hubStatusInfo: HubStatusInfo? {
        get {
            if let _info = DataManager.instance.m_userInfo.deviceStatus.m_hubStatus.getInfoByDeviceId(did: m_bleInfo?.controller?.m_hubConnectionController?.m_device_id ?? 0) {
                return _info
            }
            return nil
        }
    }
    
    var hubConnectionController: HubConnectionController? {
        get {
            return m_bleInfo?.controller?.m_hubConnectionController
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.delegate = self
        
        slides = createSlides()
        setupSlideScrollView(slides: slides)
        
        pageControl.numberOfPages = slides.count
        pageControl.currentPage = 0
        btnClose.isUserInteractionEnabled = false
        btnClose.backgroundColor = COLOR_TYPE._green_76_191_169_05.color
        view.bringSubview(toFront: pageControl)
        lblGuideTitle.text = "connection_monit_sensor_attaching_guide_title".localized
        btnClose.setTitleWithOutAnimation(title: "btn_close".localized.uppercased())
    }
    
    func createSlides() -> [SlideBaseView] {
        let _view1: DiaperAttach1View = .fromNib()
        _view1.setInit()
        let _view2: DiaperAttach2View = .fromNib()
        _view2.setInit()
        return [_view1, _view2]
    }
    
    func setupSlideScrollView(slides : [SlideBaseView]) {
        let _statusHeight = UIApplication.shared.statusBarFrame.height
        scrollView.contentSize = CGSize(width: view.frame.width * CGFloat(slides.count), height: scrollView.frame.height - _statusHeight)
        scrollView.showsHorizontalScrollIndicator = false; scrollView.showsVerticalScrollIndicator = false
        scrollView.isPagingEnabled = true
        
        for i in 0 ..< slides.count {
            slides[i].frame = CGRect(x: view.frame.width * CGFloat(i), y: 0, width: view.frame.width, height: scrollView.frame.height - _statusHeight)
            scrollView.addSubview(slides[i])
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if fmod(scrollView.contentOffset.x, scrollView.frame.maxX) == 0 {
            let _currentPage = Int(scrollView.contentOffset.x / scrollView.frame.maxX)
            pageControl.currentPage = _currentPage
            if (_currentPage == slides.count - 1) {
                btnClose.isUserInteractionEnabled = true
                btnClose.backgroundColor = COLOR_TYPE.green.color
            } else {
                btnClose.isUserInteractionEnabled = false
                btnClose.backgroundColor = COLOR_TYPE._green_76_191_169_05.color
            }
        }
    }
    
    func firmwareUpdate() {
        // 통합 업데이트 필요. 업데이트 끝나면 기기 화면 으로 이동시켜줘도 됨.
        var _isSensorUpdate = false
        let _lastSensorVer = DataManager.instance.m_configData.m_latestSensorVersion
        if (Utility.isUpdateVersion(latestVersion: _lastSensorVer, currentVersion: m_bleInfo?.m_firmware ?? "9.9.9")) {
            _isSensorUpdate = true
        }
        var _isSensorForceUpdate = false
        let _lastSensorForceVer = DataManager.instance.m_configData.m_latestSensorForceVersion
        if (Utility.isUpdateVersion(latestVersion: _lastSensorForceVer, currentVersion: m_bleInfo?.m_firmware ?? "9.9.9")) {
            _isSensorForceUpdate = true
        }
        var _isHubUpdate = false
        let _lastHubVer = DataManager.instance.m_configData.m_latestHubVersion
        if (hubConnectionController?.m_firmware ?? "9.9.9" != "") {
            if (Utility.isUpdateVersion(latestVersion: _lastHubVer, currentVersion: hubConnectionController?.m_firmware ?? "9.9.9")) {
                _isHubUpdate = true
            }
        }

        var _isHubForceUpdate = false
        let _lastHubForceVer = DataManager.instance.m_configData.m_latestHubForceVersion
        
        if (hubConnectionController?.m_firmware ?? "9.9.9" != "") {
            if (Utility.isUpdateVersion(latestVersion: _lastHubForceVer, currentVersion: hubConnectionController?.m_firmware ?? "9.9.9")) {
                _isHubForceUpdate = true
            }
        }

        #if DEBUG
//        _isSensorUpdate = true
//        _isSensorForceUpdate = true
//        _isHubUpdate = false
        #endif

        // (only sensor update)
        if (_isSensorUpdate && !_isHubUpdate) {
            _ = PopupManager.instance.onlyContents(contentsKey: _isSensorForceUpdate ? "contents_need_firmware_update_force" : "contents_need_firmware_update", confirmType: _isSensorForceUpdate ? .ok : .noYes,
                                                   okHandler: { () -> () in
                                                    let _view = UIManager.instance.sceneMoveNaviPush(scene: .deviceSetupSensorFirmware) as? DeviceSetupSensorFirmwareViewController
                                                    _view?.m_isForceInit = true
                                                    
                                                    let _detailInfo = DeviceDetailInfo()
                                                    _detailInfo.m_did = self.m_bleInfo?.m_did ?? 0
                                                    _view?.setInit(detailInfo: _detailInfo)
                                                    
                                                    UIManager.instance.m_deviceNeedHubPopup = true
            }, cancleHandler: { () -> () in
                if (self.hubConnectionController?.m_device_id == 0) {
                    self.confirmHub()
                } else {
                    _ = UIManager.instance.sceneMove(scene: .initView, animation: .coverVertical, isAnimation: false)
                }
            })
        // (hub / hub and sensor)
        } else if (_isHubUpdate) {
            _ = PopupManager.instance.onlyContents(contentsKey: _isHubForceUpdate ? "contents_need_firmware_update_force" : "contents_need_firmware_update", confirmType: _isHubForceUpdate ? .ok : .noYes,
                                                   okHandler: { () -> () in
                                                    let _view = UIManager.instance.sceneMoveNaviPush(scene: .deviceSetupHubFirmware) as? DeviceSetupHubFirmwareViewController
                                                    _view?.m_isForceInit = true
                                                    _view?.m_tmpSrl = self.hubConnectionController?.m_serialNumber ?? ""
                                                    _view?.m_tmpFwv = self.hubConnectionController?.m_firmware ?? ""
                                                    let _detailInfo = DeviceDetailInfo()
                                                    _detailInfo.m_did = self.hubConnectionController?.m_device_id ?? 0
                                                    _view?.m_detailInfo = _detailInfo
                                                    
                                                    if (_isSensorUpdate) {
                                                        _view?.m_isPackageUpdate = true
                                                        let _sensorDetailInfo = DeviceDetailInfo()
                                                        _sensorDetailInfo.m_did = self.m_bleInfo?.m_did ?? 0
                                                        _view?.m_sensorDetailInfo = _sensorDetailInfo
                                                    }
            }, cancleHandler: { () -> () in
                _ = UIManager.instance.sceneMove(scene: .initView, animation: .coverVertical, isAnimation: false)
            })
        // (no sensor, no hub update)
        } else {
            if (self.hubConnectionController?.m_device_id == 0) {
                self.confirmHub()
            } else {
                _ = UIManager.instance.sceneMove(scene: .initView, animation: .coverVertical, isAnimation: false)
            }
        }
    }
    
    func confirmHub() {
        _ = PopupManager.instance.onlyContents(contentsKey: "dialog_contents_ask_for_connectint_hub", confirmType: .ok,
                                               okHandler: { () -> () in
                                                UIManager.instance.setMoveNextScene(finishScenePush: .deviceRegisterHub, moveScene: .initView)
        })
    }
    
    @IBAction func onClick_close(_ sender: Any) {
        self.firmwareUpdate()
    }
    
    
}
