//
//  UserSetupNoticeController.swift
//  Monit
//
//  Created by john.lee on 2019. 3. 13..
//  Copyright © 2019년 맥. All rights reserved.
//

import UIKit

class CustomWebViewController: BaseViewController {
    @IBOutlet weak var lblNaviTitle: UILabel!
    @IBOutlet weak var webInnerView: UIView!
    
    var m_popup: CustomWebView?
    var m_url: String?
    var m_naviTitle: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        lblNaviTitle.text = m_naviTitle ?? ""
        if (Utility.currentReachabilityStatus != .notReachable) {
            if (m_popup == nil) {
                m_popup = .fromNib()
                m_popup!.frame = webInnerView.bounds
                webInnerView.addSubview(m_popup!)
                m_popup!.m_parent = self
            }
            
            if let _url = m_url {
                m_popup!.openUrl(url: _url)
            }
        }
    }
    
    func setInit(url: String?, naviTitle: String?) {
        m_url = url
        m_naviTitle = naviTitle
    }
    
    func closeWebView() {
        m_popup?.removeFromSuperview()
        m_popup = nil
        m_url = nil
    }
    
    @IBAction func onClick_back(_ sender: UIButton) {
        UIManager.instance.sceneMoveNaviPop()
        closeWebView()
    }
}
