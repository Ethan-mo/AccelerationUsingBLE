//
//  CardNotice.swift
//  Monit
//
//  Created by john.lee on 2018. 9. 18..
//  Copyright © 2018년 맥. All rights reserved.
//

import UIKit

class CardNoticeView: UIView {
    @IBOutlet weak var btnMove: UIButton!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var imgIcon: UIImageView!
    @IBOutlet weak var imgArrow: UIImageView!
    @IBOutlet weak var viewCard: UIView!
    
    var m_idx: Int = 0
    var m_clickHandler: ActionResultAny?
    
    enum CARD_TYPE: String {
        case info = "info"
        case warning = "warning"
    }
    
    enum CUSTOM_TYPE {
        case firmware
        case bluetooth
    }
    
    func setInit(idx: Int, type: CARD_TYPE, customType: CUSTOM_TYPE, description: String, height: CGFloat, handler: ActionResultAny? = nil) {
        self.m_idx = idx
        switch type {
        case .info:
            setInfoUI()
            break
        case .warning:
            setWarningUI()
            break
        }
        lblDescription.text = description
        if (Config.channel != .kc) {
            if (Config.IS_AVOBE_OS13) {
                if (customType == .bluetooth) {
                    imgArrow.isHidden = true
                }
            }
        }
        m_clickHandler = handler
    }

    func setInfoUI() {
        lblDescription.textColor = COLOR_TYPE.mint.color
        imgIcon.image = UIImage(named: "imgSetupMint")
        imgArrow.image = UIImage(named: "imgRightArrowMint")
        
        setBtnInfo()
    }
    
    func setWarningUI() {
        lblDescription.textColor = COLOR_TYPE.warningRed.color
        imgIcon.image = UIImage(named: "imgWarningRed")
        imgArrow.image = UIImage(named: "imgNextRed")
        
        setBtnWarning()
    }
    
    func setBtnInfo()
    {
        UI_Utility.customButtonBorder(button: btnMove, radius: 0, width: 1, color: COLOR_TYPE.mint.color.cgColor)
        UI_Utility.customButtonShadow(button: btnMove, radius: 1, offsetWidth: 2, offsetHeight: 2, color: UIColor.black.cgColor, opacity: 0.2)
    }
    
    func setBtnWarning()
    {
        UI_Utility.customButtonBorder(button: btnMove, radius: 0, width: 1, color: COLOR_TYPE.warningRed.color.cgColor)
        UI_Utility.customButtonShadow(button: btnMove, radius: 1, offsetWidth: 2, offsetHeight: 2, color: UIColor.black.cgColor, opacity: 0.2)
    }
    
    @IBAction func onClick_move(_ sender: UIButton) {
        m_clickHandler?(m_idx)
    }
}
