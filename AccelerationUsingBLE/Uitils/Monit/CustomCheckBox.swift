//
//  CustomCheckBox.swift
//  Monit
//
//  Created by 맥 on 2018. 2. 8..
//  Copyright © 2018년 맥. All rights reserved.
//

import UIKit

class CustomCheckBox: UIButton {
    typealias OnClickHandler = () -> Void
    var m_onClickHandler: OnClickHandler?
    
    // Images
    let checkedImage = UIImage(named: "imgCheckRoundEnable")! as UIImage
    let uncheckedImage = UIImage(named: "imgCheckRound")! as UIImage
    
    // Bool property
    var isChecked: Bool = false {
        didSet{
            if isChecked == true {
                self.setImage(checkedImage, for: UIControlState.normal)
            } else {
                self.setImage(uncheckedImage, for: UIControlState.normal)
            }
        }
    }
    
    override func awakeFromNib() {
        self.addTarget(self, action:#selector(buttonClicked(sender:)), for: UIControlEvents.touchUpInside)
        self.isChecked = false
    }
    
    @objc func buttonClicked(sender: UIButton) {
        if sender == self {
            isChecked = !isChecked
        }
        m_onClickHandler?()
    }
}
