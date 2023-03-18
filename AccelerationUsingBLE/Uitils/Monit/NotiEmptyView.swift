//
//  NotiEmptyView.swift
//  Monit
//
//  Created by 맥 on 2017. 12. 15..
//  Copyright © 2017년 맥. All rights reserved.
//

import UIKit

class NotiEmptyView: UIView {
    @IBOutlet weak var lblEmpty: UILabel!

    func setInfo() {
        lblEmpty.text = "notification_empty_view".localized
    }
}
