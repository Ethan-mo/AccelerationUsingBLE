//
//  NativePopupManager.swift
//  Monit
//
//  Created by 맥 on 2017. 12. 21..
//  Copyright © 2017년 맥. All rights reserved.
//

import UIKit

class CustomUIAleartController : UIAlertController {
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        self.view.backgroundColor = UIColor.white
        self.view.tintColor = COLOR_TYPE.mint.color
        self.view.layer.cornerRadius = 12
    }
}

class NativePopupManager {
    static var m_instance: NativePopupManager!
    static var instance: NativePopupManager {
        get {
            if (m_instance == nil) {
                m_instance = NativePopupManager()
            }
            
            return m_instance
        }
    }
    
    func onlyContents(message: String, completionHandler: @escaping () -> Void) {
        let alert = CustomUIAleartController(title: "", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "btn_ok".localized, style: UIAlertActionStyle.default, handler: { (action) in
            completionHandler()
        }))

        let messageFont = [NSAttributedStringKey.font: UIFont(name: Config.FONT_NotoSans, size: 14.0)!, NSAttributedStringKey.foregroundColor : COLOR_TYPE.lblDarkGray.color]
        let messageAttrString = NSMutableAttributedString(string: alert.message!, attributes: messageFont)
        alert.setValue(messageAttrString, forKey: "attributedMessage")

        let _view = UIManager.instance.rootCurrentView!
        _view.present(alert, animated: false, completion: nil)
    }
    
    func toast(message : String) {
        if let _view = UIManager.instance.rootCurrentView?.view {
            let toastLabel = UILabel(frame: CGRect(x: _view.frame.size.width/2 - 125, y: _view.frame.size.height-100, width: 250, height: 35))
            toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
            toastLabel.textColor = UIColor.white
            toastLabel.textAlignment = .center;
            toastLabel.font = UIFont(name: "NotoSansCJKkr-Regular", size: 14.0)
            toastLabel.text = message
            toastLabel.alpha = 1.0
            toastLabel.layer.cornerRadius = 10;
            toastLabel.clipsToBounds  =  true
            _view.addSubview(toastLabel)
            UIView.animate(withDuration: 2.0, delay: 0.1, options: .curveEaseOut, animations: {
                toastLabel.alpha = 0.0
            }, completion: {(isCompleted) in
                toastLabel.removeFromSuperview()
            })
        } else {
            Debug.print("rootCurrentView is null", event: .warning)
        }
    }
}
