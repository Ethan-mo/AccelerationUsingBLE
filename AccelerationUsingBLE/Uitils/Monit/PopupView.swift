//
//  PopupView.swift
//  Monit
//
//  Created by 맥 on 2017. 8. 23..
//  Copyright © 2017년 맥. All rights reserved.
//

import UIKit

class PopupDetailInfo
{
    var contentsType = PopupManager.CONTENTS_TYPE.none
    var title: String!
    var titleColor: UIColor?
    var contents: String!
    var contentsColor: UIColor?
    var buttonType: PopupView.CUSTOM_BUTTON_TYPE!
    var left: String!
    var leftColor: UIColor?
    var right: String!
    var rightColor: UIColor?
    var center: String!
    var centerColor: UIColor?
    var isTitleButton: Bool?
    var titleLinkUrl: String?
}

class PopupView: UIView {

    @IBOutlet weak var baseView: UIView!
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSummary: UILabel!
    @IBOutlet weak var imgCenterLIne: UIView!
    
    @IBOutlet weak var btnLeft: UIButton!
    @IBOutlet weak var btnRight: UIButton!
    @IBOutlet weak var btnCenter: UIButton!
    
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var progress: UIProgressView!

    @IBOutlet weak var chkRepeat: CustomCheckBox!
    @IBOutlet weak var btnTitle: UIButton!
    
    enum CONFIRM_TYPE
    {
        case none
        case noYes
        case cancleOK
        case cancle
        case cancleRetry
        case ok
        case cancleLeave
        case cancleSetup
        case close
    }
    
    enum CUSTOM_BUTTON_TYPE
    {
        case none
        case both
        case center
    }
    
    typealias CompletionHandlerOK = () -> Void
    typealias CompletionHandlerCancle = () -> Void
    typealias CompletionHandlerCheck = (Bool) -> ()
    var m_okHandler: CompletionHandlerOK?
    var m_cancleHandler: CompletionHandlerCancle?
    var m_checkHandler: CompletionHandlerCheck?
    var m_existType: String = ""
    var m_titleLinkUrl: String?
    var m_isInit = Flow()
    
    var progressValue: Float {
        get {
            return progress.progress
        }
        set {
            progress.progress = newValue
        }
    }
    
    func setInit() {
        m_isInit.one {
        }
    }
    
    func setButtonType(confirmType: CONFIRM_TYPE) {
        switch confirmType {
        case .none: setButtonInfo(customBntType: .none)
        case .noYes: setButtonInfo(customBntType: .both, leftTxt: "btn_no".localized, rightTxt: "btn_yes".localized, leftColor: COLOR_TYPE.lblGray.color, rightColor: COLOR_TYPE.mint.color)
        case .cancleOK: setButtonInfo(customBntType: .both, leftTxt: "btn_cancel".localized, rightTxt: "btn_ok".localized, leftColor: COLOR_TYPE.lblGray.color, rightColor: COLOR_TYPE.mint.color)
        case .cancle: setButtonInfo(customBntType: .center, centerTxt: "btn_cancel".localized, centerColor: COLOR_TYPE.lblGray.color)
        case .cancleRetry: setButtonInfo(customBntType: .both, leftTxt: "btn_cancel".localized, rightTxt: "btn_try_again".localized, leftColor: COLOR_TYPE.lblGray.color, rightColor: COLOR_TYPE.mint.color)
        case .ok: setButtonInfo(customBntType: .center, centerTxt: "btn_ok".localized, centerColor: COLOR_TYPE.lblGray.color)
        case .cancleLeave: setButtonInfo(customBntType: .both, leftTxt: "btn_cancel".localized, rightTxt: "btn_group_leave".localized, leftColor: COLOR_TYPE.lblGray.color, rightColor: COLOR_TYPE.mint.color)
        case .cancleSetup: setButtonInfo(customBntType: .both, leftTxt: "btn_cancel".localized, rightTxt: "title_setting".localized, leftColor: COLOR_TYPE.lblGray.color, rightColor: COLOR_TYPE.mint.color)
        case .close: setButtonInfo(customBntType: .center, centerTxt: "btn_close".localized, centerColor: COLOR_TYPE.lblGray.color)
        }
    }
    
    func setButtonType_checkBox(chkTxt: String, chkColor: UIColor? = nil) {
        chkRepeat.setTitle(chkTxt, for: .normal)

        if let _chkColor = chkColor {
            chkRepeat.setTitleColor(_chkColor, for: .normal)
        }

        chkRepeat.isHidden = false
    }
    
    func setDelegate(okHandler: CompletionHandlerOK?, cancleHandler: CompletionHandlerCancle?, checkHandler: CompletionHandlerCheck? = nil) {
        m_okHandler = okHandler
        m_cancleHandler = cancleHandler
        m_checkHandler = checkHandler
    }

    // conetns core
    func setContentsInfo(contentsType: PopupManager.CONTENTS_TYPE, title: String? = nil, contents: String? = nil ,titleColor: UIColor? = nil, contentsColor: UIColor? = nil, isTitleButton: Bool? = false, titleLinkUrl: String? = nil, lblSummaryAttrs: NSAttributedString? = nil) {
        lblTitle.text = title
        btnTitle.setTitleWithOutAnimation(title: title)
        if (titleLinkUrl != nil) {
//            UI_Utility.textUnderline(btnTitle.titleLabel)
            m_titleLinkUrl = titleLinkUrl
        }
        
        if let _attrs = lblSummaryAttrs {
            lblSummary.attributedText = _attrs
        } else {
            lblSummary.text = contents
        }
        
        if let _titleColor = titleColor {
            lblTitle.textColor = _titleColor
        }
        if let _contentsColor = contentsColor {
            lblSummary.textColor = _contentsColor
        }
        

        lblTitle.isHidden = true
        btnTitle.isHidden = true
        lblSummary.isHidden = true
        indicator.isHidden = true
        progress.isHidden = true
        
        var _offsetY: CGFloat = 0
        var _labelOffsetY: CGFloat = 0
        
        if (title != nil) {
            if let _isTitleButton = isTitleButton, _isTitleButton {
                btnTitle.isHidden = false
                btnTitle.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16.0)
            } else {
                lblTitle.isHidden = false
            }
            lblTitle.font = UIFont.boldSystemFont(ofSize: 16.0)
            lblSummary.isHidden = false
            lblSummary.font = lblSummary.font.withSize(12)
            _offsetY = 30
            _labelOffsetY = 30
        } else {
            lblSummary.isHidden = false
            lblSummary.font = lblSummary.font.withSize(14)
            _offsetY = 0
            _labelOffsetY = 0
        }

        switch contentsType {
        case .withLoading:
            indicator.isHidden = false
            indicator.startAnimating()
            _offsetY += 30
            _labelOffsetY += 30
        case .withProgress:
            progress.isHidden = false
//            ResizeForView(offsetY: 50, labelOffsetY: 0)
            _offsetY += 30
            _labelOffsetY += 0
        case .checkBox:
            _offsetY += 30
            _labelOffsetY += 0
        default: break
        }
        ResizeForView(offsetY: _offsetY, labelOffsetY: _labelOffsetY)
    }

    // button core
    func setButtonInfo(customBntType: CUSTOM_BUTTON_TYPE, leftTxt: String? = nil, rightTxt: String? = nil, centerTxt: String? = nil, leftColor: UIColor? = nil, rightColor: UIColor? = nil, centerColor: UIColor? = nil) {
        
        btnLeft.setTitle(leftTxt, for: .normal)
        btnRight.setTitle(rightTxt, for: .normal)
        btnCenter.setTitle(centerTxt, for: .normal)

        if let _leftColor = leftColor {
            btnLeft.setTitleColor(_leftColor, for: .normal)
        }
        if let _rightColor = rightColor {
            btnRight.setTitleColor(_rightColor, for: .normal)
        }
        if let _centerColor = centerColor {
            btnCenter.setTitleColor(_centerColor, for: .normal)
        }
    
        btnLeft.isHidden = true
        btnRight.isHidden = true
        btnCenter.isHidden = true
        imgCenterLIne.isHidden = true
        chkRepeat.isHidden = true

        switch customBntType {
        case .none: break
        case .both:
            imgCenterLIne.isHidden = false
            btnLeft.isHidden = false
            btnRight.isHidden = false
        case .center:
            btnCenter.isHidden = false
        }
    }
    
    func ResizeForView(offsetY : CGFloat, labelOffsetY: CGFloat) {
        lblSummary.numberOfLines = 0
        lblSummary.lineBreakMode = NSLineBreakMode.byWordWrapping
        lblSummary.sizeToFit()
        
//        let _width = (lblSummary.frame.width + 50 > 264 ? lblSummary.frame.width + 50 : 264)
        let maxSize = CGSize(width: 234, height: lblSummary.frame.height)
        // let size = lblSummary.sizeThatFits(maxSize)
        lblSummary.frame =  CGRect(origin: CGPoint(x: 15, y: 22 + labelOffsetY), size: maxSize) // inspector에 있는 정보에 영향을 받음 (상단정렬상태에서 + 22 아래로 증가)

        baseView.frame = CGRect(x: 0, y: 0, width: 264, height: lblSummary.frame.height + 87 + offsetY) // lblSummary.frame.height + baseView.frame.height - 33 + offsetY = 41.5 + 141.5 - 33 + 20 | 62.5 + 162.5 - 33 + 20
        baseView.center = self.center
    }
    
    @IBAction func onClick_Left(_ sender: UIButton) {
        self.removeFromSuperview()
        PopupManager.instance.removePopup(popup: self)
        m_checkHandler?(chkRepeat.isChecked)
        m_cancleHandler?()
    }
    
    @IBAction func onClick_Right(_ sender: UIButton) {
        self.removeFromSuperview()
        PopupManager.instance.removePopup(popup: self)
        m_checkHandler?(chkRepeat.isChecked)
        m_okHandler?()
    }
    
    @IBAction func onClick_Center(_ sender: UIButton) {
        self.removeFromSuperview()
        PopupManager.instance.removePopup(popup: self)
        m_checkHandler?(chkRepeat.isChecked)
        m_okHandler?()
    }
    
    @IBAction func onClick_title(_ sender: UIButton) {
        if let _titleLinkUrl = m_titleLinkUrl {
            let _scene = UIManager.instance.sceneMoveNaviPush(scene: .customWebView, isAniamtion: false) as! CustomWebViewController
                   _scene.setInit(url: _titleLinkUrl, naviTitle: "help".localized)
        }
    }
}
