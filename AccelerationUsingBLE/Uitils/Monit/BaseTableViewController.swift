//
//  BaseTableViewController.swift
//  Monit
//
//  Created by 맥 on 2017. 9. 19..
//  Copyright © 2017년 맥. All rights reserved.
//

import UIKit

class BaseTableViewController: UITableViewController {

    var isUpdateView: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        Debug.print("[UI] \(self.classNameToString()) Base ViewWillAppear")
    }
    
    func reloadInfo() {
    }
}
