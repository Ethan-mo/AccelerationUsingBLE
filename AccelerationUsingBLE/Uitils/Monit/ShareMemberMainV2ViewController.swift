//
//  ShareMemberMainV2ViewController.swift
//  Monit
//
//  Created by 맥 on 2018. 2. 28..
//  Copyright © 2018년 맥. All rights reserved.
//

import UIKit

class ShareMemberMainV2ViewController: BaseViewController {
    @IBOutlet weak var lblNaviTitle: UILabel!
    @IBOutlet weak var btnShare: UIButton!
    @IBOutlet weak var btnGetShared: UIButton!
    @IBOutlet weak var btnNoti: UIButton!
    @IBOutlet weak var imgDotShare: UIImageView!
    @IBOutlet weak var imgDotGetShared: UIImageView!
    @IBOutlet weak var imgDotNoti: UIImageView!
    
    enum CATEGORY: Int {
        case Share = 0
        case GetShared = 1
        case Noti = 2
    }
    
    var initReloadFlow = Flow()
    var getNotiFlow = Flow()
    var m_container: ShareMemberMainV2PageViewController?
    var isNotiArea : Bool {
        get {
            if #available(iOS 11.0, tvOS 11.0, *) {
                return UIApplication.shared.delegate?.window??.safeAreaInsets.top ?? 0 > 20
            }
            return false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Debug.print("[UI][\(self.classNameToString()).viewDidLoad()]")
        if (Utility.isTopNotch || isNotiArea) {
            UIManager.instance.setNaviHeight(identifier: "naviHeight", view: self.view, height: 65.0 + Config.NOTCH_HEIGHT_PADDING)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUI()
        initReloadFlow.reset {
            if let _container = m_container {
                _container.reloadInfoChild()
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getNotiFlow.one {
            reloadNoti()
        }
    }
    
    override func reloadInfo() {
        super.reloadInfo()
        Debug.print("[UI][\(self.classNameToString()).reloadInfo()]")
        setUI()
        if let _container = m_container {
            _container.reloadInfoChild()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "shareMemberContainerSegue")
        {
            m_container = segue.destination as? ShareMemberMainV2PageViewController
            m_container?.m_parent = self
            m_container?.setInit()
        }
    }
    
    func setUI() {
        lblNaviTitle.text = "group_mygroup".localized
        btnShare.setTitle("group_share".localized.uppercased(), for: .normal)
        btnGetShared.setTitle("group_title_shared".localized.uppercased(), for: .normal)
        btnNoti.setTitle("tab_notification".localized.uppercased(), for: .normal)
    }
    
    func setCategory(category: CATEGORY) {
        btnShare.setTitleColor(COLOR_TYPE.lblGray.color, for: .normal)
        btnGetShared.setTitleColor(COLOR_TYPE.lblGray.color, for: .normal)
        btnNoti.setTitleColor(COLOR_TYPE.lblGray.color, for: .normal)
        imgDotShare.image = UIImage(named: "imgDotWhite")
        imgDotGetShared.image = UIImage(named: "imgDotWhite")
        imgDotNoti.image = UIImage(named: "imgDotWhite")
        
        switch category {
        case .Share:
            btnShare.setTitleColor(COLOR_TYPE.mint.color, for: .normal)
            imgDotShare.image = UIImage(named: "imgDotMint")
        case .GetShared:
            btnGetShared.setTitleColor(COLOR_TYPE.mint.color, for: .normal)
            imgDotGetShared.image = UIImage(named: "imgDotMint")
        case .Noti:
            btnNoti.setTitleColor(COLOR_TYPE.mint.color, for: .normal)
            imgDotNoti.image = UIImage(named: "imgDotMint")
        }
    }
    
    func reloadNoti() {
        DataManager.instance.m_dataController.shareMemberNoti.updateNoti()
    }
    
    @IBAction func onClick_back(_ sender: UIButton) {
        UIManager.instance.sceneMoveNaviPop()
    }
    
    @IBAction func onClick_share(_ sender: UIButton) {
        setCategory(category: .Share)
        m_container?.setLoadView(category: .Share, isSlide: true)
    }
    
    @IBAction func onClick_getShared(_ sender: UIButton) {
        setCategory(category: .GetShared)
        m_container?.setLoadView(category: .GetShared, isSlide: true)
    }
    
    @IBAction func onClick_noti(_ sender: UIButton) {
        setCategory(category: .Noti)
        m_container?.setLoadView(category: .Noti, isSlide: true)
    }
}
