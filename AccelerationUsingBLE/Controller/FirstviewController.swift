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
        let bt = UIButton(type: .system)
        bt.setTitle("Scan", for: .normal)
        bt.tintColor = UIColor.systemBlue
        bt.backgroundColor = .white
        bt.layer.cornerRadius = 15
        bt.layer.borderColor = UIColor.systemBlue.cgColor
        bt.addTarget(self, action: #selector(nextPage), for: .touchUpInside)
        return bt
    }()
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.statusBarStyle = .lightContent
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
        view.configureGradientLayer(self.view, firstColor: UIColor.systemBlue.cgColor, secondColor: UIColor.white.cgColor)
        
        view.addSubview(scanButton)
        scanButton.setDimensions(width: 150, height: 60)
        scanButton.centerX(inView: view.self)
        scanButton.centerY(inView: view.self)
    }
}
