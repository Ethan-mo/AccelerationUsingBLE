//
//  PopupManager.swift
//  Monit
//
//  Created by 맥 on 2017. 8. 24..
//  Copyright © 2017년 맥. All rights reserved.
//

import UIKit

class PopupManager : UIView {
    static var m_instance: PopupManager!
    static var instance: PopupManager {
        get {
            if (m_instance == nil) {
                m_instance = PopupManager()
            }
            
            return m_instance
        }
    }
    
    enum CONTENTS_TYPE
    {
        case none
        case withLoading
        case withProgress
        case checkBox
    }

    var m_list = [PopupView]()
    
    func removePopup(popup: PopupView?) {
        if let _popup = popup {
            if let index = m_list.index(where: { $0 === _popup }) {
                m_list.remove(at: index)
            }
        }
    }
    
    // common
    func withTitle(titleKey: String, contentsKey: String, confirmType: PopupView.CONFIRM_TYPE, okHandler: PopupView.CompletionHandlerOK? = nil, cancleHandler: PopupView.CompletionHandlerCancle? = nil, existKey: String = "") -> PopupView
    {
        let view = setPopup(existKey: existKey)
        if (view.m_isInit.isOne) {
            return view
        }
        
        view.setInit()
        view.setDelegate(okHandler: okHandler, cancleHandler: cancleHandler)
        view.setContentsInfo(contentsType: .none, title: titleKey.localized, contents: contentsKey.localized)
        view.setButtonType(confirmType: confirmType)
        return view
    }
    
    // common
    func onlyContents(contentsKey: String, confirmType: PopupView.CONFIRM_TYPE, okHandler: PopupView.CompletionHandlerOK? = nil, cancleHandler: PopupView.CompletionHandlerCancle? = nil, existKey: String = "") -> PopupView
    {
        let view = setPopup(existKey: existKey)
        if (view.m_isInit.isOne) {
            return view
        }
        
        view.m_existType = existKey
        view.setInit()
        view.setDelegate(okHandler: okHandler, cancleHandler: cancleHandler)
        view.setContentsInfo(contentsType: .none, contents: contentsKey.localized)
        view.setButtonType(confirmType: confirmType)
        return view
    }
    
    func withLoading(contentsKey: String, confirmType: PopupView.CONFIRM_TYPE, okHandler: PopupView.CompletionHandlerOK? = nil, cancleHandler: PopupView.CompletionHandlerCancle? = nil) -> PopupView
    {
        let view = setPopup()
        view.setInit()
        view.setDelegate(okHandler: okHandler, cancleHandler: cancleHandler)
        view.setContentsInfo(contentsType: .withLoading, contents: contentsKey.localized)
        view.setButtonType(confirmType: confirmType)
        return view
    }
    
    func withProgress(contentsKey: String, confirmType: PopupView.CONFIRM_TYPE, okHandler: PopupView.CompletionHandlerOK? = nil, cancleHandler: PopupView.CompletionHandlerCancle? = nil) -> PopupView
    {
        let view = setPopup()
        view.setInit()
        view.setDelegate(okHandler: okHandler, cancleHandler: cancleHandler)
        view.setContentsInfo(contentsType: .withProgress, contents: contentsKey.localized)
        view.setButtonType(confirmType: confirmType)
        return view
    }
    
    func withCheckbox(titleKey: String, titleColor: UIColor? = nil, contentsKey: String, chkKey: String, btnKey: String, btnColor: UIColor?, checkHandler: PopupView.CompletionHandlerCheck? = nil) -> PopupView
    {
        let view = setPopup()
        view.setInit()
        view.setDelegate(okHandler: nil, cancleHandler: nil, checkHandler: checkHandler)
        view.setContentsInfo(contentsType: .checkBox, title: titleKey.localized, contents: contentsKey.localized, titleColor: titleColor)
        view.setButtonInfo(customBntType: .center, centerTxt: btnKey.localized, centerColor: btnColor)
        view.setButtonType_checkBox(chkTxt: chkKey.localized)
        return view
    }
    
    
    func withErrorCode(codeString: String, linkURL: String?, contentsKey: String, confirmType: PopupView.CONFIRM_TYPE, okHandler: PopupView.CompletionHandlerOK? = nil, cancleHandler: PopupView.CompletionHandlerCancle? = nil, existKey: String = "") -> PopupView
    {
        let view = setPopup(existKey: existKey)
        if (view.m_isInit.isOne) {
            return view
        }
        
        view.m_existType = existKey
        view.setInit()
        view.setDelegate(okHandler: okHandler, cancleHandler: cancleHandler)
        view.setContentsInfo(contentsType: .none, title: codeString, contents: contentsKey.localized, isTitleButton: true, titleLinkUrl: linkURL)
        view.setButtonType(confirmType: confirmType)
        return view
    }
    
    
    func withTitleCustom(title: String, contents: String, confirmType: PopupView.CONFIRM_TYPE, okHandler: PopupView.CompletionHandlerOK? = nil, cancleHandler: PopupView.CompletionHandlerCancle? = nil, existKey: String = "") -> PopupView
    {
        let view = setPopup(existKey: existKey)
        if (view.m_isInit.isOne) {
            return view
        }
        
        view.m_existType = existKey
        view.setInit()
        view.setDelegate(okHandler: okHandler, cancleHandler: cancleHandler)
        view.setContentsInfo(contentsType: .none, title: title, contents: contents)
        view.setButtonType(confirmType: confirmType)
        return view
    }
    
    func onlyContentsCustom(contents: String, confirmType: PopupView.CONFIRM_TYPE, okHandler: PopupView.CompletionHandlerOK? = nil, cancleHandler: PopupView.CompletionHandlerCancle? = nil, existKey: String = "") -> PopupView
    {
        let view = setPopup(existKey: existKey)
        if (view.m_isInit.isOne) {
            return view
        }
        
        view.m_existType = existKey
        view.setInit()
        view.setDelegate(okHandler: okHandler, cancleHandler: cancleHandler)
        view.setContentsInfo(contentsType: .none, contents: contents)
        view.setButtonType(confirmType: confirmType)
        return view
    }
    
    func withCheckboxCustom(popupDetailInfo: PopupDetailInfo, okHandler: PopupView.CompletionHandlerOK? = nil, cancleHandler: PopupView.CompletionHandlerCancle? = nil, existKey: String = "", chk: String, checkHandler: PopupView.CompletionHandlerCheck? = nil) -> PopupView
    {
        let view = setPopup()
        view.setInit()
        view.setDelegate(okHandler: okHandler, cancleHandler: cancleHandler, checkHandler: checkHandler)
        view.setContentsInfo(contentsType: .checkBox, title: popupDetailInfo.title, contents: popupDetailInfo.contents, titleColor: popupDetailInfo.titleColor, contentsColor: popupDetailInfo.contentsColor)
        view.setButtonInfo(customBntType: popupDetailInfo.buttonType, leftTxt: popupDetailInfo.left, rightTxt: popupDetailInfo.right, centerTxt: popupDetailInfo.center, leftColor: popupDetailInfo.leftColor ,rightColor: popupDetailInfo.rightColor, centerColor: popupDetailInfo.centerColor)
        view.setButtonType_checkBox(chkTxt: chk)
        return view
    }
    
    // all custom
    @discardableResult
    func setDetail(popupDetailInfo: PopupDetailInfo, okHandler: PopupView.CompletionHandlerOK? = nil, cancleHandler: PopupView.CompletionHandlerCancle? = nil, existKey: String = "") -> PopupView {
        let view = setPopup(existKey: existKey)
        if (view.m_isInit.isOne) {
            return view
        }
        
        view.m_existType = existKey
        view.setInit()
        view.setDelegate(okHandler: okHandler, cancleHandler: cancleHandler)
        view.setContentsInfo(contentsType: popupDetailInfo.contentsType, title: popupDetailInfo.title, contents: popupDetailInfo.contents, titleColor: popupDetailInfo.titleColor, contentsColor: popupDetailInfo.contentsColor, isTitleButton: popupDetailInfo.isTitleButton, titleLinkUrl: popupDetailInfo.titleLinkUrl)
        view.setButtonInfo(customBntType: popupDetailInfo.buttonType, leftTxt: popupDetailInfo.left, rightTxt: popupDetailInfo.right, centerTxt: popupDetailInfo.center, leftColor: popupDetailInfo.leftColor ,rightColor: popupDetailInfo.rightColor, centerColor: popupDetailInfo.centerColor)
        return view
    }
    
    func setPopup(existKey: String = "") -> PopupView
    {
        var _lstDel: [PopupView] = []
        if (existKey != "") {
            for item in m_list {
                if (item.m_existType == existKey) {
                    _lstDel.append(item)
                }
            }
        }
        for item in _lstDel {
            item.removeFromSuperview()
            if let index = m_list.index(where: { $0 === item }) {
                m_list.remove(at: index)
            }
        }
        
        let popup: PopupView = .fromNib()
        let _view = UIManager.instance.rootCurrentView?.view

        // 팝업뷰 배경색(회색)
        let viewColor = UIColor.gray
        // 반튜명 부모뷰
        popup.backgroundColor = viewColor.withAlphaComponent(0.4)
        popup.frame = (_view?.frame)! // 팝업뷰를 화면크기에 맞추기
        
//        // 팝업창 배경색 (흰색)
//        let baseViewColor = UIColor.white
//        // 팝업배경
//        popup.baseView.backgroundColor = baseViewColor.withAlphaComponent(0.8)
        // 팝업테두리 둥글게
        popup.baseView.layer.cornerRadius = 9.0
        _view?.addSubview(popup)
        m_list.append(popup)
        return popup
    }
}
