//
//  JoinFinishViewController.swift
//  Monit
//
//  Created by 맥 on 2018. 3. 13..
//  Copyright © 2018년 맥. All rights reserved.
//

import UIKit

class JoinFinishViewController: BaseViewController {
    @IBOutlet weak var lblNaviTitle: UILabel!
    @IBOutlet weak var btnNaviNext: UIButton!
    
    @IBOutlet weak var lblWelcome: UILabel!
    @IBOutlet weak var lblSummary: UILabel!
    @IBOutlet weak var lblShortid: UILabel!
    @IBOutlet weak var lblSummaryBottom: UILabel!
    
    @IBOutlet weak var imgLogoDefault: UIImageView!
    @IBOutlet weak var imgLogoKC: UIImageView!
    
    override var screenType: SCREEN_TYPE { get { return .JOIN_SUCCESS } }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setLogoUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUI()
    }
    
    func setLogoUI() {
        imgLogoDefault.isHidden = true
        imgLogoKC.isHidden = true
        switch Config.channel {
        case .kc: imgLogoKC.isHidden = false
        default: imgLogoDefault.isHidden = false
        }
    }
    
    func setUI() {
        lblNaviTitle.text = "title_signup".localized
        btnNaviNext.setTitle("btn_done".localized.uppercased(), for: .normal)
        lblWelcome.text = Config.channel == .kc ? "account_signup_welcome_title_kc".localized : "account_signup_welcome_title".localized
        lblSummary.text = "account_signup_welcome_membershipcode".localized
        
        let attrs1 = [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 14), NSAttributedStringKey.foregroundColor : COLOR_TYPE.lblDarkGray.color]
        
        let attrs2 = [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 14), NSAttributedStringKey.foregroundColor : COLOR_TYPE.mint.color]

        let attributedString1 = NSMutableAttributedString(string:  "\("account_shortid".localized): ", attributes:attrs1)
        
        let attributedString2 = NSMutableAttributedString(string: DataManager.instance.m_userInfo.short_id, attributes:attrs2)
        
        attributedString1.append(attributedString2)
        self.lblShortid.attributedText = attributedString1

        if (Config.channel == .kc) {
            lblSummaryBottom.isHidden = true
        } else {
            lblSummaryBottom.text = Config.channel == .kc ? "account_signup_welcome_description_kc".localized : "account_signup_welcome_description".localized
        }
        
    }
    
    @IBAction func onClick_naviBack(_ sender: UIButton) {
        _ = UIManager.instance.sceneMove(scene: .mainSignin, animation: .coverVertical, isAnimation: false)
    }
    
    @IBAction func onClick_naviNext(_ sender: UIButton) {
        _ = UIManager.instance.sceneMove(scene: .initView, animation: .coverVertical, isAnimation: false)
    }
}
