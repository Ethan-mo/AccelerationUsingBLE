//
//  GraphEmptyView.swift
//  Monit
//
//  Created by john.lee on 2018. 5. 28..
//  Copyright © 2018년 맥. All rights reserved.
//

import UIKit

class GraphEmptyView: UIView {
    @IBOutlet weak var lblEmpty: UILabel!
    
    func setInfo() {
        lblEmpty.text = "hub_graph_no_data".localized
    }
}
