//
//  ProgressView.swift
//  Monit
//
//  Created by 맥 on 2018. 1. 30..
//  Copyright © 2018년 맥. All rights reserved.
//

import UIKit

class ProgressView: UIView {
    @IBOutlet weak var progress: UIProgressView!
    @IBOutlet weak var lblTitle: UILabel!
    
    var progressValue: Float {
        get {
            return progress.progress
        }
        set {
            progress.progress = newValue
        }
    }
    
    func setInit(title: String) {
        lblTitle.text = title
        progressValue = 0
    }
    
    func close() {
        self.removeFromSuperview()
    }
}
