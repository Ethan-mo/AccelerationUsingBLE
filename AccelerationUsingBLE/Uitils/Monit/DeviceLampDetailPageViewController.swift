//
//  DeviceSensorPageViewController.swift
//  Monit
//
//  Created by 맥 on 2017. 9. 22..
//  Copyright © 2017년 맥. All rights reserved.
//

import UIKit

class DeviceLampDetailPageViewController: BasePageViewController /*, UIPageViewControllerDataSource, UIPageViewControllerDelegate */ {
    
    var m_parent: DeviceLampDetailViewController?
    var m_list: [UIViewController?] = [nil, nil, nil]

    var getCurrentIndex: Int {
        get {
            if (viewControllers?.first as? DeviceLampDetailSensingViewController) != nil {
                return DeviceLampDetailViewController.CATEGORY.Sensing.rawValue
            }
            if (viewControllers?.first as? DeviceLampDetailGraphViewController) != nil {
                return DeviceLampDetailViewController.CATEGORY.Graph.rawValue
            }
            if (viewControllers?.first as? DeviceLampDetailNotiViewController) != nil {
                return DeviceLampDetailViewController.CATEGORY.Noti.rawValue
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
        if let _view = viewControllers?.first as? DeviceLampDetailSensingViewController {
            _view.reloadInfoChild()
        }
        if let _view = viewControllers?.first as? DeviceLampDetailGraphViewController {
            _view.reloadInfoChild()
        }
        if let _view = viewControllers?.first as? DeviceLampDetailNotiViewController {
            _view.reloadInfoChild()
        }
    }
    
    func getViewController(category: DeviceLampDetailViewController.CATEGORY) -> UIViewController? {
        var _vc: UIViewController?
        switch category {
        case .Sensing:
            _vc = m_list[DeviceLampDetailViewController.CATEGORY.Sensing.rawValue]
        case .Graph:
            _vc = m_list[DeviceLampDetailViewController.CATEGORY.Graph.rawValue]
        case .Noti:
            _vc = m_list[DeviceLampDetailViewController.CATEGORY.Noti.rawValue]
        }
        return _vc
    }
 
    func setInit() {
        if m_list[DeviceLampDetailViewController.CATEGORY.Sensing.rawValue] == nil {
            let _sb = UIStoryboard(name: SystemManager.instance.GetStoryBoardName(.lampDetailNavi), bundle: nil)
            let _sensing = _sb.instantiateViewController(withIdentifier: SCENE_CONTAINER.deviceLampDetailSensingContainer.rawValue) as? DeviceLampDetailSensingViewController
            _sensing!.m_parent = self
            m_list[DeviceLampDetailViewController.CATEGORY.Sensing.rawValue] = _sensing
        }
        
        if m_list[DeviceLampDetailViewController.CATEGORY.Graph.rawValue] == nil {
            let _sb = UIStoryboard(name: SystemManager.instance.GetStoryBoardName(.lampDetailNavi), bundle: nil)
            let _graph = _sb.instantiateViewController(withIdentifier: SCENE_CONTAINER.deviceLampDetailGraphContainer.rawValue) as? DeviceLampDetailGraphViewController
            _graph!.m_parent = self
            m_list[DeviceLampDetailViewController.CATEGORY.Graph.rawValue] = _graph
        }
        
        if m_list[DeviceLampDetailViewController.CATEGORY.Noti.rawValue] == nil {
            let _sb = UIStoryboard(name: SystemManager.instance.GetStoryBoardName(.lampDetailNavi), bundle: nil)
            let _noti = _sb.instantiateViewController(withIdentifier: SCENE_CONTAINER.deviceLampDetailNotiContainer.rawValue) as? DeviceLampDetailNotiViewController
            _noti!.m_parent = self
            _noti!.setInit(type: DEVICE_TYPE.Lamp.rawValue, did: m_parent!.m_detailInfo!.m_did)
            m_list[DeviceLampDetailViewController.CATEGORY.Noti.rawValue] = _noti
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
        m_parent?.setCategory(category: DeviceLampDetailViewController.CATEGORY(rawValue: _vcIndex)!)
    }

    // manual menu
    func setLoadView(category: DeviceLampDetailViewController.CATEGORY, isSlide: Bool) {
        if let _sensingView = self.m_list[category.rawValue] as? DeviceLampDetailSensingViewController {
            if (isSlide || !_sensingView.m_flow.isOne) {
                _sensingView.m_flow.isOne = true
                self.setViewControllers([_sensingView], direction: .reverse, animated: true, completion: { (Bool) in
//                    self.setScrollEnable(pageView: self, isEnable: true)
                })
            }
        }
 
        if let _sensingView = self.m_list[category.rawValue] as? DeviceLampDetailGraphViewController {
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
        
        if let _sensingView = self.m_list[category.rawValue] as? DeviceLampDetailNotiViewController {
            if (isSlide || !_sensingView.m_flow.isOne) {
                _sensingView.m_flow.isOne = true
                self.setViewControllers([_sensingView], direction: .forward, animated: true, completion: { (Bool) in
//                    self.setScrollEnable(pageView: self, isEnable: true)
                })
            }
        }

    }
}
