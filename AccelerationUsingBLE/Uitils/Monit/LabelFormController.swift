//
//  LabelFormController.swift
//  Monit
//
//  Created by 맥 on 2017. 9. 28..
//  Copyright © 2017년 맥. All rights reserved.
//

import UIKit

// 연결 시키기 위해 LabelFormPasswordController.setDelegate를 사용한다.
protocol LabelFormDelegate {
    func setVaildVisible(isVisible: Bool) // 유효하지 않을경우 화면에 보여줄 것을 호출한다
    func isCustomVaild() -> Bool? // 사용자정의 유효값을 사용한다.
}

class LabelFormController {
    var m_isEditing = false
    var m_isVaild = false
    
    var m_txtInput: UITextField?
    var m_lblDefault: UILabel?
    var m_btnDelete: UIButton?
    var m_imgCheck: UIImageView?
    var m_defaultText = ""
    var m_minLength = 0
    var m_mexLength = 50
    var m_maxByte = -1
    
    var m_delegate: LabelFormDelegate?
    
    init(txtInput: UITextField?, btnDelete: UIButton?, minLength:Int, maxLength:Int, maxByte:Int = -1, imgCheck: UIImageView? = nil) {
        self.m_txtInput = txtInput
        self.m_txtInput?.font = UIFont.boldSystemFont(ofSize: self.m_txtInput?.font?.pointSize ?? 15)
        self.m_btnDelete = btnDelete
        self.m_imgCheck = imgCheck
        self.m_minLength = minLength
        self.m_mexLength = maxLength
        self.m_maxByte = maxByte
        
        setInit()
    }
    
    func setInit() {
        m_isEditing = false
        m_txtInput?.text = ""
        m_lblDefault?.text = m_defaultText
        m_btnDelete?.isHidden = true
    }
    
    func setDefaultText(lblDefault: UILabel?, defaultText: String)  {
        self.m_lblDefault = lblDefault
        self.m_defaultText = defaultText
        self.m_lblDefault?.text = defaultText
    }
    
    func setDelegate(delegate: LabelFormDelegate) {
        self.m_delegate = delegate
        vaild()
    }
    
    func vaild() {
        let length = m_txtInput?.text?.count
        if (0 < length! && m_isEditing) {
            var _isVaild = false
            if (isCustomVaild() == nil) {
                if (m_minLength <= length! && length! <= m_mexLength) {
                    _isVaild = true
                }
            } else {
                if let _isCustomVaild = isCustomVaild(), _isCustomVaild {
                    if (m_minLength <= length! && length! <= m_mexLength) {
                        _isVaild = true
                    }
                }
            }
            
            if (_isVaild) {
                self.m_isVaild = true
                vaildUI(isVisible: false)
                m_imgCheck?.image = UIImage(named: "imgCheckEnable")
            } else {
                self.m_isVaild = false
                vaildUI(isVisible: true)
                m_imgCheck?.image = UIImage(named: "imgCheck")
            }
        }
        else {
            self.m_isVaild = false
            vaildUI(isVisible: false)
            m_imgCheck?.image = UIImage(named: "imgCheck")
        }
    }
    
    func isCustomVaild() -> Bool? {
        if (m_delegate != nil) {
            return m_delegate?.isCustomVaild()
        }
        return nil
    }
    
    // 입력된 옵션이 유효/유효하지않음에 따라 콜백을 실행한다.
    func vaildUI(isVisible: Bool)
    {
        if (m_delegate != nil) {
            m_delegate?.setVaildVisible(isVisible: isVisible)
        }
    }
    
    // 텍스트 박스가 수정 될때 호출해준다.
    func editing(isTrim: Bool = true, isRemoveSpecialChar: Bool = false) {
        if (!m_isEditing) {
            m_isEditing = true
            m_lblDefault?.text = ""
        }
        UIManager.instance.viewBtnDelete(textField: m_txtInput, btnDelete: m_btnDelete)
        UI_Utility.checkMaxLength(textField: m_txtInput, maxLength: m_mexLength)
        if (m_maxByte != -1) {
            UI_Utility.checkMaxByte(textField: m_txtInput, maxLength: m_maxByte)
        }
//        if (isTrim) {
//            m_txtInput?.text = m_txtInput!.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
//            m_txtInput?.text = m_txtInput!.text?.components(separatedBy: .whitespaces).joined()
//        }
//        if (isRemoveSpecialChar) { // 한글 벌어지는 에러 발생
//            m_txtInput?.text = m_txtInput!.text?.trimmingCharacters(in: CharacterSet.punctuationCharacters)
//        }
        vaild()
    }
    
    func onClick_delete() {
        setInit()
        vaild()
    }
}
