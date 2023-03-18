//
//  ShareMemberMainV2PageViewController.swift
//  Monit
//
//  Created by 맥 on 2018. 3. 2..
//  Copyright © 2018년 맥. All rights reserved.
//

import UIKit

class ShareMemberMainV2PageViewController: BasePageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    var m_parent: ShareMemberMainV2ViewController?
    var m_list: [UIViewController?] = [nil, nil, nil]

    var getCurrentIndex: Int {
        get {
            if (viewControllers?.first as? ShareMemberShareViewController) != nil {
                return ShareMemberMainV2ViewController.CATEGORY.Share.rawValue
            }
            if (viewControllers?.first as? ShareMemberGetSharedViewController) != nil {
                return ShareMemberMainV2ViewController.CATEGORY.GetShared.rawValue
            }
            if (viewControllers?.first as? ShareMemberNotiViewController) != nil {
                return ShareMemberMainV2ViewController.CATEGORY.Noti.rawValue
            }
            return 0
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Debug.print("[UI][\(self.classNameToString()).viewDidLoad()]")
        self.dataSource = self
        self.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUI()
    }

    func reloadInfoChild() {
        setUI()
        if let _view = viewControllers?.first as? ShareMemberShareViewController {
            _view.reloadInfoChild()
        }
        if let _view = viewControllers?.first as? ShareMemberGetSharedViewController {
            _view.reloadInfoChild()
        }
        if let _view = viewControllers?.first as? ShareMemberNotiViewController {
            _view.reloadInfoChild()
        }
    }
    
    func getViewController(category: ShareMemberMainV2ViewController.CATEGORY) -> UIViewController? {
        var _vc: UIViewController?
        switch category {
        case .Share:
            _vc = m_list[ShareMemberMainV2ViewController.CATEGORY.Share.rawValue]
        case .GetShared:
            _vc = m_list[ShareMemberMainV2ViewController.CATEGORY.GetShared.rawValue]
        case .Noti:
            _vc = m_list[ShareMemberMainV2ViewController.CATEGORY.Noti.rawValue]
        }
        return _vc
    }

    func setInit() {
        if m_list[ShareMemberMainV2ViewController.CATEGORY.Share.rawValue] == nil {
            let _sb = UIStoryboard(name: SystemManager.instance.GetStoryBoardName(.shareMemberMainNavi), bundle: nil)
            let _share = _sb.instantiateViewController(withIdentifier: SCENE_CONTAINER.shareMemberShareContainer.rawValue) as? ShareMemberShareViewController
            _share!.m_parent = self
            m_list[ShareMemberMainV2ViewController.CATEGORY.Share.rawValue] = _share
        }
        
        if m_list[ShareMemberMainV2ViewController.CATEGORY.GetShared.rawValue] == nil {
            let _sb = UIStoryboard(name: SystemManager.instance.GetStoryBoardName(.shareMemberMainNavi), bundle: nil)
            let _getShared = _sb.instantiateViewController(withIdentifier: SCENE_CONTAINER.shareMemberGetSharedContainer.rawValue) as? ShareMemberGetSharedViewController
            _getShared!.m_parent = self
            m_list[ShareMemberMainV2ViewController.CATEGORY.GetShared.rawValue] = _getShared
        }

        if m_list[ShareMemberMainV2ViewController.CATEGORY.Noti.rawValue] == nil {
            let _sb = UIStoryboard(name: SystemManager.instance.GetStoryBoardName(.shareMemberMainNavi), bundle: nil)
            let _noti = _sb.instantiateViewController(withIdentifier: SCENE_CONTAINER.shareMemberNotiContainer.rawValue) as? ShareMemberNotiViewController
            _noti!.m_parent = self
            m_list[ShareMemberMainV2ViewController.CATEGORY.Noti.rawValue] = _noti
        }
        setLoadView(category: .Share, isSlide: false)
    }
    
    func setUI() {
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        //        Debug.print("viewControllerBefore")
        var _vcIndex = 0
        var _isFound = false
        for (i, item) in m_list.enumerated() {
            if (item == viewController) {
                _isFound = true
                _vcIndex = i
            }
        }
        if (!(_isFound)) {
            return nil
        }
        let previousIndex = _vcIndex - 1
        guard previousIndex >= 0 else { return nil }
        guard m_list.count > previousIndex else { return nil }
        return getViewController(category: ShareMemberMainV2ViewController.CATEGORY(rawValue: previousIndex)!)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        //        Debug.print("viewControllerAfter")
        var _vcIndex = 0
        var _isFound = false
        for (i, item) in m_list.enumerated() {
            if (item == viewController) {
                _isFound = true
                _vcIndex = i
            }
        }
        if (!(_isFound)) {
            return nil
        }
        let nextIndex = _vcIndex + 1
        guard m_list.count != nextIndex else { return nil }
        guard m_list.count > nextIndex else { return nil }
        return getViewController(category: ShareMemberMainV2ViewController.CATEGORY(rawValue: nextIndex)!)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        //        Debug.print("didFinishAnimating")
        var _vcIndex = 0
        var _isFound = false
        for (i, item) in m_list.enumerated() {
            if (item == pageViewController.viewControllers![0]) {
                _isFound = true
                _vcIndex = i
            }
        }
        if (!(_isFound)) {
            return
        }
        m_parent?.setCategory(category: ShareMemberMainV2ViewController.CATEGORY(rawValue: _vcIndex)!)
    }

    func setLoadView(category: ShareMemberMainV2ViewController.CATEGORY, isSlide: Bool) {
        if let _view = getViewController(category: category) as? ShareMemberShareViewController {
            if (isSlide || !_view.m_flow.isOne) {
                _view.m_flow.isOne = true
                self.setViewControllers([_view], direction: .reverse, animated: true, completion: { (Bool) in })
            }
        }
        
        if let _view = getViewController(category: category) as? ShareMemberGetSharedViewController {
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
        
        if let _view = getViewController(category: category) as? ShareMemberNotiViewController {
            if (isSlide || !_view.m_flow.isOne) {
                _view.m_flow.isOne = true
                self.setViewControllers([_view], direction: .forward, animated: true, completion: { (Bool) in })
            }
        }
    }
}
