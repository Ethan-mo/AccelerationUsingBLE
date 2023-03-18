//
//  HelpMessageView.swift
//  Monit
//
//  Created by john.lee on 2019. 3. 15..
//  Copyright © 2019년 맥. All rights reserved.
//

import UIKit

class HelpMessageView: UIView {
    
    @IBOutlet weak var btnHelpMessage: UIButton!
    @IBOutlet weak var lblTitle: VerticalAlignLabel!
    @IBOutlet weak var lblContents: VerticalAlignLabel!
    @IBOutlet weak var imgHelpMessage: UIImageView!
    
    enum HELP_MESSAGE_TYPE {
        case none
        case bottom_left
        case bottom_right
        case bottom_center
        case top_left
        case top_right
        case top_center
    }
    
    
    var helpMessageId: String = ""
    var helpMessageType: HELP_MESSAGE_TYPE = .none
    var isOnceCheck: Bool = false
    var title: String = ""
    var contents: String = ""
    var nextHandler: Action?
    
    var parentView: UIView?
    
    func setInit(helpMessageId: String, helpMessageType: HELP_MESSAGE_TYPE, title: String, contents: String, isOnceCheck: Bool, nextHandler: Action? = nil) {
        self.helpMessageId = helpMessageId
        self.helpMessageType = helpMessageType
        self.isOnceCheck = isOnceCheck
        self.title = title
        self.contents = contents
        self.nextHandler = nextHandler
    }
    
    func setInitUI(parent: UIView) {
        self.parentView = parent
        self.parentView?.isHidden = false
        self.setUI()
    }
    
    func setUI() {
        if (isOnceCheck) {
            if (DataManager.instance.m_configData.getRepeatNotice(key: "helpMessage_\(self.helpMessageId)")) {
                windowClose()
                self.nextHandler?()
                return
            }
        }
        
        guard (parentView != nil) else { return }
        
        let _parentPosY = self.parentView!.frame.minY
        self.frame = self.parentView!.bounds
        self.parentView?.addSubview(self)
        self.parentView?.frame.origin.y = _parentPosY
        self.lblTitle.verticalAlignment = .top
        self.lblContents.verticalAlignment = .top
 
        // set message image
        switch helpMessageType {
        case .top_left:
            imgHelpMessage.image = UIImage(named: "imgHelpMessageTopLeft")
        case .top_right:
            imgHelpMessage.image = UIImage(named: "imgHelpMessageTopRight")
        case .top_center:
            imgHelpMessage.image = UIImage(named: "imgHelpMessageTopCenter")
        case .bottom_left:
            imgHelpMessage.image = UIImage(named: "imgHelpMessageBottomLeft")
        case .bottom_right:
            imgHelpMessage.image = UIImage(named: "imgHelpMessageBottomRight")
        case .bottom_center:
            imgHelpMessage.image = UIImage(named: "imgHelpMessageBottomCenter")
        default: break
        }
        
        // set top image posistion
        switch helpMessageType {
        case .top_left, .top_right, .top_center:
            lblTitle.frame = CGRect(x: lblTitle.frame.minX, y: lblTitle.frame.minY - 10, width: lblTitle.frame.width, height: lblTitle.frame.height)
            lblContents.frame = CGRect(x: lblContents.frame.minX, y: lblContents.frame.minY - 10, width: lblContents.frame.width, height: lblContents.frame.height)
            btnHelpMessage.frame = CGRect(x: btnHelpMessage.frame.minX, y: btnHelpMessage.frame.minY - 10, width: btnHelpMessage.frame.width, height: btnHelpMessage.frame.height)
        case .bottom_left, .bottom_right, .bottom_center:
            lblTitle.frame = CGRect(x: lblTitle.frame.minX, y: lblTitle.frame.minY, width: lblTitle.frame.width, height: lblTitle.frame.height)
            lblContents.frame = CGRect(x: lblContents.frame.minX, y: lblContents.frame.minY, width: lblContents.frame.width, height: lblContents.frame.height)
            btnHelpMessage.frame = CGRect(x: btnHelpMessage.frame.minX, y: btnHelpMessage.frame.minY, width: btnHelpMessage.frame.width, height: btnHelpMessage.frame.height)
        default: break
        }
        
        // print contents
        if (title == "" && contents != "") {
            let _attributed1 = LabelAttributed(labelValue: contents, attributed: [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 12)])
            UI_Utility.multiAttributedLabel(label: lblTitle, arrAttributed: [_attributed1])
            lblContents.isHidden = true
        } else {
            lblTitle.text = title
            lblContents.text = contents
        }
    }
    
    func windowClose() {
        self.removeFromSuperview()
        self.parentView?.isHidden = true
    }
    
    @IBAction func onClick_close(_ sender: UIButton) {
        DataManager.instance.m_configData.setRepeatNotice(key: "helpMessage_\(self.helpMessageId)")
        windowClose()
        self.nextHandler?()
    }
}
