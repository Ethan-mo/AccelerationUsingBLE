//
//  SnoozeView.swift
//  Monit
//
//  Created by john.lee on 2018. 12. 5..
//  Copyright © 2018년 맥. All rights reserved.
//

import UIKit

class SnoozeView: UIView {
    @IBOutlet weak var imgSnooze: UIImageView!
    
    func setSnooze(isOn: Bool) {
        if (isOn) {
            imgSnooze.image = UIImage(named: "imgSnoozeOnLarge")
        } else {
            imgSnooze.image = UIImage(named: "imgSnoozeOffLarge")
        }
    }
    
}
