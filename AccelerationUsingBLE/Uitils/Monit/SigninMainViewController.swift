//
//  SigninMainGoodmonitViewController.swift
//  Monit
//
//  Created by 맥 on 2018. 1. 10..
//  Copyright © 2018년 맥. All rights reserved.
//

import UIKit
class SigninMainViewController : BaseViewController {
    @IBOutlet weak var containerView: UIView!

    var m_containerViewController: UIViewController?

    override func viewDidLoad() {
        isUpdateView = false
        super.viewDidLoad()
        Debug.print("[UI][\(self.classNameToString()).viewDidLoad()]")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUI()
    }
    
    func setUI() {
        // init
        PopupManager.instance.m_list.removeAll()
        
        if (m_containerViewController != nil) {
            m_containerViewController!.view.removeFromSuperview()
            m_containerViewController!.removeFromParentViewController()
            m_containerViewController = nil
        }
        
        let sb = UIStoryboard(name: SystemManager.instance.GetStoryBoardName(.mainSignin), bundle: nil)
        switch Config.channel {
        case .goodmonit, .monitXHuggies:
            let _vc = sb.instantiateViewController(withIdentifier: SCENE_CONTAINER.mainSigninGoodmonitContainer.rawValue) as? SigninMainGoodmonitViewController
            m_containerViewController = _vc
            _vc?.m_parent = self
            /// 20221121 - 국내Monit Sever를 사용하기 위한 조치
//        case .monitXHuggies:
//            let _vc = sb.instantiateViewController(withIdentifier: SCENE_CONTAINER.mainSigninMonitXHuggiesContainer.rawValue) as? SigninMainMonitXHuggiesViewController
//            m_containerViewController = _vc
//            _vc?.m_parent = self
        case .kc:
            let _vc = sb.instantiateViewController(withIdentifier: SCENE_CONTAINER.mainSigninKcContainer.rawValue) as? SigninMainKcViewController
            m_containerViewController = _vc
            _vc?.m_parent = self
        case .kao:
            let _vc = sb.instantiateViewController(withIdentifier: SCENE_CONTAINER.mainSigninGoodmonitContainer.rawValue) as? SigninMainGoodmonitViewController
            m_containerViewController = _vc
            _vc?.m_parent = self
        }

        if (m_containerViewController != nil) {
            addChildViewController(m_containerViewController!)
            m_containerViewController?.view.translatesAutoresizingMaskIntoConstraints = false
            containerView.addSubview(m_containerViewController!.view)
            
            NSLayoutConstraint.activate([
                m_containerViewController!.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                m_containerViewController!.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
                m_containerViewController!.view.topAnchor.constraint(equalTo: containerView.topAnchor),
                m_containerViewController!.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
                ])
        }
    }
}

