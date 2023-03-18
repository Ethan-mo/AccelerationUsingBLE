//
//  DeviceSensorPageViewController.swift
//  Monit
//
//  Created by 맥 on 2017. 9. 22..
//  Copyright © 2017년 맥. All rights reserved.
//

import UIKit

class DeviceHubDetailPageViewController: BasePageViewController /*, UIPageViewControllerDataSource, UIPageViewControllerDelegate */ {
    
    var m_parent: DeviceHubDetailViewController?
    var m_list: [UIViewController?] = [nil, nil, nil]

    var getCurrentIndex: Int {
        get {
            if (viewControllers?.first as? DeviceHubDetailSensingBaseViewController) != nil {
                return DeviceHubDetailViewController.CATEGORY.Sensing.rawValue
            }
            if (viewControllers?.first as? DeviceHubDetailGraphBaseViewController) != nil {
                return DeviceHubDetailViewController.CATEGORY.Graph.rawValue
            }
            if (viewControllers?.first as? DeviceHubDetailNotiViewController) != nil {
                return DeviceHubDetailViewController.CATEGORY.Noti.rawValue
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
        if let _view = viewControllers?.first as? DeviceHubDetailSensingBaseViewController {
            _view.reloadInfoChild()
        }
//        if let _view = viewControllers?.first as? DeviceHubDetailGraphBaseViewController {
//            _view.reloadInfoChild()
//        }
        if let _view = viewControllers?.first as? DeviceHubDetailNotiViewController {
            _view.reloadInfoChild()
        }
    }
    
    func getViewController(category: DeviceHubDetailViewController.CATEGORY) -> UIViewController? {
        var _vc: UIViewController?
        switch category {
        case .Sensing:
            _vc = m_list[DeviceHubDetailViewController.CATEGORY.Sensing.rawValue]
        case .Graph:
            _vc = m_list[DeviceHubDetailViewController.CATEGORY.Graph.rawValue]
        case .Noti:
            _vc = m_list[DeviceHubDetailViewController.CATEGORY.Noti.rawValue]
        }
        return _vc
    }
 
    func setInit() {
        switch Config.channel {
        case .goodmonit,
             .kao:
            if m_list[DeviceHubDetailViewController.CATEGORY.Sensing.rawValue] == nil {
                let _sb = UIStoryboard(name: SystemManager.instance.GetStoryBoardName(.hubDetailNavi), bundle: nil)
                let _sensing = _sb.instantiateViewController(withIdentifier: SCENE_CONTAINER.deviceHubDetailSensingContainer.rawValue) as? DeviceHubDetailSensingViewController
                _sensing!.m_parent = self
                m_list[DeviceHubDetailViewController.CATEGORY.Sensing.rawValue] = _sensing
            }
        case .monitXHuggies:
            if m_list[DeviceHubDetailViewController.CATEGORY.Sensing.rawValue] == nil {
                let _sb = UIStoryboard(name: SystemManager.instance.GetStoryBoardName(.hubDetailNavi), bundle: nil)
                let _sensing = _sb.instantiateViewController(withIdentifier: SCENE_CONTAINER.deviceHubDetailSensingContainer.rawValue) as? DeviceHubDetailSensingViewController
                _sensing!.m_parent = self
                m_list[DeviceHubDetailViewController.CATEGORY.Sensing.rawValue] = _sensing
            }
        case .kc:
            if m_list[DeviceHubDetailViewController.CATEGORY.Sensing.rawValue] == nil {
                let _sb = UIStoryboard(name: SystemManager.instance.GetStoryBoardName(.hubDetailNavi), bundle: nil)
                let _sensing = _sb.instantiateViewController(withIdentifier: SCENE_CONTAINER.deviceHubDetailSensingForKcContainer.rawValue) as? DeviceHubDetailSensingForKcViewController
                _sensing!.m_parent = self
                m_list[DeviceHubDetailViewController.CATEGORY.Sensing.rawValue] = _sensing
            }
        }
        
        switch Config.channel {
        case .goodmonit:
            if m_list[DeviceHubDetailViewController.CATEGORY.Graph.rawValue] == nil {
                let _sb = UIStoryboard(name: SystemManager.instance.GetStoryBoardName(.hubDetailNavi), bundle: nil)
                let _graph = _sb.instantiateViewController(withIdentifier: SCENE_CONTAINER.deviceHubDetailGraphContainer.rawValue) as? DeviceHubDetailGraphViewController
                _graph!.m_parent = self
                m_list[DeviceHubDetailViewController.CATEGORY.Graph.rawValue] = _graph
            }
        case .monitXHuggies:
            if m_list[DeviceHubDetailViewController.CATEGORY.Graph.rawValue] == nil {
                let _sb = UIStoryboard(name: SystemManager.instance.GetStoryBoardName(.hubDetailNavi), bundle: nil)
                let _graph = _sb.instantiateViewController(withIdentifier: SCENE_CONTAINER.deviceHubDetailGraphContainer.rawValue) as? DeviceHubDetailGraphViewController
                _graph!.m_parent = self
                m_list[DeviceHubDetailViewController.CATEGORY.Graph.rawValue] = _graph
            }
        case .kc:
            if m_list[DeviceHubDetailViewController.CATEGORY.Graph.rawValue] == nil {
                let _sb = UIStoryboard(name: SystemManager.instance.GetStoryBoardName(.hubDetailNavi), bundle: nil)
                let _graph = _sb.instantiateViewController(withIdentifier: SCENE_CONTAINER.deviceHubDetailGraphForKcContainer.rawValue) as? DeviceHubDetailGraphForKcViewController
                _graph!.m_parent = self
                m_list[DeviceHubDetailViewController.CATEGORY.Graph.rawValue] = _graph
            }
        case .kao:
            if m_list[DeviceHubDetailViewController.CATEGORY.Graph.rawValue] == nil {
                let _sb = UIStoryboard(name: SystemManager.instance.GetStoryBoardName(.hubDetailNavi), bundle: nil)
                let _graph = _sb.instantiateViewController(withIdentifier: SCENE_CONTAINER.deviceHubDetailGraphContainer.rawValue) as? DeviceHubDetailGraphViewController
                _graph!.m_parent = self
                m_list[DeviceHubDetailViewController.CATEGORY.Graph.rawValue] = _graph
            }
        }
        
        if m_list[DeviceHubDetailViewController.CATEGORY.Noti.rawValue] == nil {
            let _sb = UIStoryboard(name: SystemManager.instance.GetStoryBoardName(.hubDetailNavi), bundle: nil)
            let _noti = _sb.instantiateViewController(withIdentifier: SCENE_CONTAINER.deviceHubDetailNotiContainer.rawValue) as? DeviceHubDetailNotiViewController
            _noti!.m_parent = self
            _noti!.setInit(type: DEVICE_TYPE.Hub.rawValue, did: m_parent!.m_detailInfo!.m_did)
            m_list[DeviceHubDetailViewController.CATEGORY.Noti.rawValue] = _noti
        }
        setLoadView(category: .Sensing, isSlide: false)
    }
    
    func setUI() {
    }
   
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
//        Debug.print("didFinishAnimating")
        var _vcIndex = 0
        var _isFound = false
        for (i, item) in m_list.enumerated() {
            if (item == pageViewController.viewControllers?[0]) {
                _isFound = true
                _vcIndex = i
            }
        }
        if (!(_isFound)) {
            return
        }
        m_parent?.setCategory(category: DeviceHubDetailViewController.CATEGORY(rawValue: _vcIndex)!)
    }

    // manual menu
    func setLoadView(category: DeviceHubDetailViewController.CATEGORY, isSlide: Bool) {
        if let _sensingView = self.m_list[category.rawValue] as? DeviceHubDetailSensingBaseViewController {
            if (isSlide || !_sensingView.m_flow.isOne) {
                _sensingView.m_flow.isOne = true
                self.setViewControllers([_sensingView], direction: .reverse, animated: true, completion: { (Bool) in
//                    self.setScrollEnable(pageView: self, isEnable: true)
                })
            }
        }
 
        if let _sensingView = self.m_list[category.rawValue] as? DeviceHubDetailGraphBaseViewController {
            if (isSlide || !_sensingView.m_flow.isOne) {
                _sensingView.m_flow.isOne = true
                var _direction = UIPageViewControllerNavigationDirection.forward
                if (getCurrentIndex < category.rawValue) {
                    _direction = .forward
                } else {
                    _direction = .reverse
                }
                self.setViewControllers([_sensingView], direction: _direction, animated: true, completion: { (Bool) in
//                    self.setScrollEnable(pageView: self, isEnable: false)
                })
            }
        }
        
        if let _sensingView = self.m_list[category.rawValue] as? DeviceHubDetailNotiViewController {
            if (isSlide || !_sensingView.m_flow.isOne) {
                _sensingView.m_flow.isOne = true
                self.setViewControllers([_sensingView], direction: .forward, animated: true, completion: { (Bool) in
//                    self.setScrollEnable(pageView: self, isEnable: true)
                })
            }
        }

    }
}
