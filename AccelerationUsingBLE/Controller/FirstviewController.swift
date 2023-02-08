//
//  FirstviewController.swift
//  AccelerationUsingBLE
//
//  Created by 모상현 on 2023/02/08.
//

import Foundation
import UIKit

class FirstViewController:UIViewController {
    // MARK: - Properties
    private lazy var scanButton: UIButton = {
        let bt = UIButton(type: .infoLight)
        bt.setTitle("Scan", for: .normal)
        bt.tintColor = .red
        bt.backgroundColor = .blue
        bt.addTarget(self, action: #selector(nextPage), for: .touchUpInside)
        return bt
    }()
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        serial = BluetoothSerial.init()
    }
    // MARK: - Selector
    @objc func nextPage() {
        let controller = ScanSensorViewController()
        navigationController?.pushViewController(controller, animated: true)
    }
    // MARK: - Helper
    func configureUI() {
        view.backgroundColor = .gray
        
        view.addSubview(scanButton)
        scanButton.centerX(inView: view.self)
        scanButton.centerY(inView: view.self)
    }
}
