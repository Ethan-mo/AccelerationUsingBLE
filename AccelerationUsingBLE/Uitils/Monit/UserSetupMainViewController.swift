//
//  UserSetupMainViewController.swift
//  Monit
//
//  Created by 맥 on 2017. 9. 7..
//  Copyright © 2017년 맥. All rights reserved.
//

import UIKit

class UserSetupMainViewController: BaseViewController {
    @IBOutlet weak var lblNaviTitle: UILabel!
    
    override var screenType: SCREEN_TYPE { get { return .ACCOUNT_INFO } }
    var m_child: UserSetupMainTableViewController?
    
    override func reloadInfo() {
        super.reloadInfo()
        Debug.print("[UI][\(self.classNameToString()).reloadInfo()]")
        setUI()
        m_child!.setUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUI()
        m_child!.setUI()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "userSetupMainContainerSegue")
        {
            m_child = segue.destination as? UserSetupMainTableViewController
            m_child!.m_parentView = self.view
        }
    }
    
    func setUI() {
        lblNaviTitle.text = "title_setting".localized
    }
    
    @IBAction func onClick_back(_ sender: UIButton) {
        UIManager.instance.sceneMoveNaviPop()
    }
}
