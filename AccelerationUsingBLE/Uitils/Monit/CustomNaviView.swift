//
//  CustomNaviView.swift
//  Monit
//
//  Created by 맥 on 2018. 2. 6..
//  Copyright © 2018년 맥. All rights reserved.
//

import UIKit

class CustomNaviView: UIView {
    var isNotiArea : Bool {
        get {
            if #available(iOS 11.0, tvOS 11.0, *) {
                return UIApplication.shared.delegate?.window??.safeAreaInsets.top ?? 0 > 20
            }
            return false
        }
    }
    
    func setInit() {
        if (Utility.isTopNotch || isNotiArea) {
            UIManager.instance.setNaviHeight(identifier: "naviHeight", view: self, height: 65.0 + Config.NOTCH_HEIGHT_PADDING)
            
//            if (!_isFound) {
//                self.frame = CGRect(x: 0, y: 0, width: frame.width, height: 75)
//                if let _superview = self.superview {
//                    _superview.layoutIfNeeded()
//                }
//            }

//            if (!_isFound) {
//                self.translatesAutoresizingMaskIntoConstraints = false
//                let heightConstraint = NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 75.0)
//                self.addConstraints([heightConstraint])
//            }
        }
    }
}
