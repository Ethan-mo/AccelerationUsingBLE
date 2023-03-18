//
//  DeviceSensorPageViewController.swift
//  Monit
//
//  Created by 맥 on 2017. 9. 22..
//  Copyright © 2017년 맥. All rights reserved.
//

import UIKit

class DeviceSensorDetailPageViewController: BasePageViewController /*, UIPageViewControllerDataSource, UIPageViewControllerDelegate*/ {

    var m_parent: DeviceSensorDetailViewController?
    var m_list: [UIViewController?] = [nil, nil, nil]

    var getCurrentIndex: Int {
        get {
            if (viewControllers?.first as? DeviceSensorDetailSensingBaseViewController) != nil {
                return DeviceSensorDetailViewController.CATEGORY.Sensing.rawValue
            }
            if (viewControllers?.first as? DeviceSensorDetailGraphViewController) != nil {
                return DeviceSensorDetailViewController.CATEGORY.Graph.rawValue
            }
            if (viewControllers?.first as? DeviceDetailNotiBaseViewController) != nil {
                return DeviceSensorDetailViewController.CATEGORY.Noti.rawValue
            }
            return 0
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Debug.print("[UI][\(self.classNameToString()).viewDidLoad()]")
//        self.dataSource = self
//        self.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUI()
    }
    
    func reloadInfoChild() {
        setUI()
        if let _view = viewControllers?.first as? DeviceSensorDetailSensingBaseViewController {
            _view.reloadInfoChild()
        }
//        if let _view = viewControllers?.first as? DeviceSensorDetailGraphViewController {
//            _view.reloadInfoChild()
//        }
        if let _view = viewControllers?.first as? DeviceDetailNotiBaseViewController {
            _view.reloadInfoChild()
        }
    }
    
    func getViewController(category: DeviceSensorDetailViewController.CATEGORY) -> UIViewController? {
        var _vc: UIViewController?
        switch category {
        case .Sensing:
            _vc = m_list[DeviceSensorDetailViewController.CATEGORY.Sensing.rawValue]
        case .Graph:
            _vc = m_list[DeviceSensorDetailViewController.CATEGORY.Graph.rawValue]
        case .Noti:
            _vc = m_list[DeviceSensorDetailViewController.CATEGORY.Noti.rawValue]
        }
        return _vc
    }
    
    // 사전에 로드한다.
    func setInit() {
        // Sensing
        switch Config.channel {
        case .goodmonit,
             .kao:
            if m_list[DeviceSensorDetailViewController.CATEGORY.Sensing.rawValue] == nil {
                let _sb = UIStoryboard(name: SystemManager.instance.GetStoryBoardName(.sensorDetailNavi), bundle: nil)
                let _sensing = _sb.instantiateViewController(withIdentifier: SCENE_CONTAINER.deviceSensorDetailSensingContainer.rawValue) as? DeviceSensorDetailSensingViewController
                _sensing!.m_parent = self
                m_list[DeviceSensorDetailViewController.CATEGORY.Sensing.rawValue] = _sensing
            }
        case .monitXHuggies:
            if m_list[DeviceSensorDetailViewController.CATEGORY.Sensing.rawValue] == nil {
                let _sb = UIStoryboard(name: SystemManager.instance.GetStoryBoardName(.sensorDetailNavi), bundle: nil)
                let _sensing = _sb.instantiateViewController(withIdentifier: SCENE_CONTAINER.deviceSensorDetailSensingContainer.rawValue) as? DeviceSensorDetailSensingViewController
                _sensing!.m_parent = self
                m_list[DeviceSensorDetailViewController.CATEGORY.Sensing.rawValue] = _sensing
            }
        case .kc:
            if m_list[DeviceSensorDetailViewController.CATEGORY.Sensing.rawValue] == nil {
                let _sb = UIStoryboard(name: SystemManager.instance.GetStoryBoardName(.sensorDetailNavi), bundle: nil)
                let _sensing = _sb.instantiateViewController(withIdentifier: SCENE_CONTAINER.deviceSensorDetailSensingForKcContainer.rawValue) as? DeviceSensorDetailSensingForKcViewController
                _sensing!.m_parent = self
                m_list[DeviceSensorDetailViewController.CATEGORY.Sensing.rawValue] = _sensing
            }
        }
        
        // Graph
        switch Config.channel {
        case .goodmonit,
             .kao:
            if m_list[DeviceSensorDetailViewController.CATEGORY.Graph.rawValue] == nil {
                let _sb = UIStoryboard(name: SystemManager.instance.GetStoryBoardName(.sensorDetailNavi), bundle: nil)
                let _graph = _sb.instantiateViewController(withIdentifier: SCENE_CONTAINER.deviceSensorDetailGraphContainer.rawValue) as? DeviceSensorDetailGraphViewController
                _graph!.m_parent = self
                m_list[DeviceSensorDetailViewController.CATEGORY.Graph.rawValue] = _graph
            }
        case .monitXHuggies:
            if m_list[DeviceSensorDetailViewController.CATEGORY.Graph.rawValue] == nil {
                let _sb = UIStoryboard(name: SystemManager.instance.GetStoryBoardName(.sensorDetailNavi), bundle: nil)
                let _graph = _sb.instantiateViewController(withIdentifier: SCENE_CONTAINER.deviceSensorDetailGraphContainer.rawValue) as? DeviceSensorDetailGraphViewController
                _graph!.m_parent = self
                m_list[DeviceSensorDetailViewController.CATEGORY.Graph.rawValue] = _graph
            }
        case .kc:
            if m_list[DeviceSensorDetailViewController.CATEGORY.Graph.rawValue] == nil {
                let _sb = UIStoryboard(name: SystemManager.instance.GetStoryBoardName(.sensorDetailNavi), bundle: nil)
                let _graph = _sb.instantiateViewController(withIdentifier: SCENE_CONTAINER.deviceSensorDetailGraphForKcContainer.rawValue) as? DeviceSensorDetailGraphForKcViewController
                _graph!.m_parent = self
                m_list[DeviceSensorDetailViewController.CATEGORY.Graph.rawValue] = _graph
            }
        }
        
        if (Config.channel == .monitXHuggies) {
//            if m_list[DeviceSensorDetailViewController.CATEGORY.Noti.rawValue] == nil {
//                let _sb = UIStoryboard(name: SystemManager.instance.GetStoryBoardName(.sensorDetailNavi), bundle: nil)
//                let _noti = _sb.instantiateViewController(withIdentifier: SCENE_CONTAINER.deviceSensorDetailNotiForHuggiesContainer.rawValue) as? DeviceSensorDetailNotiForHuggiesViewController
//                _noti!.m_parent = self
//                _noti!.setInit(type: DEVICE_TYPE.Sensor.rawValue, did: m_parent!.m_detailInfo!.m_did)
//                m_list[DeviceSensorDetailViewController.CATEGORY.Noti.rawValue] = _noti
//            }
            if m_list[DeviceSensorDetailViewController.CATEGORY.Noti.rawValue] == nil {
                let _sb = UIStoryboard(name: SystemManager.instance.GetStoryBoardName(.sensorDetailNavi), bundle: nil)
                let _noti = _sb.instantiateViewController(withIdentifier: SCENE_CONTAINER.deviceSensorDetailNotiContainer.rawValue) as? DeviceSensorDetailNotiViewController
                _noti!.m_parent = self
                _noti!.setInit(type: DEVICE_TYPE.Sensor.rawValue, did: m_parent!.m_detailInfo!.m_did)
                m_list[DeviceSensorDetailViewController.CATEGORY.Noti.rawValue] = _noti
            }
        } else {
            if m_list[DeviceSensorDetailViewController.CATEGORY.Noti.rawValue] == nil {
                let _sb = UIStoryboard(name: SystemManager.instance.GetStoryBoardName(.sensorDetailNavi), bundle: nil)
                let _noti = _sb.instantiateViewController(withIdentifier: SCENE_CONTAINER.deviceSensorDetailNotiContainer.rawValue) as? DeviceSensorDetailNotiViewController
                _noti!.m_parent = self
                _noti!.setInit(type: DEVICE_TYPE.Sensor.rawValue, did: m_parent!.m_detailInfo!.m_did)
                m_list[DeviceSensorDetailViewController.CATEGORY.Noti.rawValue] = _noti
            }
        }
        
        setLoadView(category: .Sensing, isSlide: false)
    }
    
    func setUI() {
    }

    func setLoadView(category: DeviceSensorDetailViewController.CATEGORY, isSlide: Bool) {
        if let _view = self.m_list[category.rawValue] as? DeviceSensorDetailSensingBaseViewController {
            if (isSlide || !_view.m_flow.isOne) {
                _view.m_flow.isOne = true
                self.setViewControllers([_view], direction: .reverse, animated: true, completion: { (Bool) in }) // 에니메이션 끝나기전 ui를 호출하면 에러.
            }
        }
        
        if let _view = self.m_list[category.rawValue] as? DeviceSensorDetailGraphBaseViewController {
            if (isSlide || !_view.m_flow.isOne) {
                _view.m_flow.isOne = true
                var _direction = UIPageViewControllerNavigationDirection.forward
                if (getCurrentIndex < category.rawValue) {
                    _direction = .forward
                } else {
                    _direction = .reverse
                }
                self.setViewControllers([_view], direction: _direction, animated: true, completion: { (Bool) in })
            }
        }
        
        if let _view = self.m_list[category.rawValue] as? DeviceDetailNotiBaseViewController {
            if (isSlide || !_view.m_flow.isOne) {
                _view.m_flow.isOne = true
                // * 에니메이션이 끝나기전 viewWillAppear이 먼저 호출 된다.
                self.setViewControllers([_view], direction: .forward, animated: true, completion: { (Bool) in
                })
            }
        }
    }
}
