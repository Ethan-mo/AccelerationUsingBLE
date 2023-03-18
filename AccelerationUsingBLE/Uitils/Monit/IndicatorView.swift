//
//  IndicatorView.swift
//  Monit
//
//  Created by 맥 on 2017. 8. 30..
//  Copyright © 2017년 맥. All rights reserved.
//

import UIKit

class IndicatorView: UIView {

    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    func start() {
        indicator.isHidden = false
        indicator.startAnimating()
    }
    
    func stop() {
        indicator.stopAnimating()
        indicator.isHidden = true
        self.removeFromSuperview()
    }
    
}
