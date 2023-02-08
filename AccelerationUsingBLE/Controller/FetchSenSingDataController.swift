//
//  FetchSenSingDataController.swift
//  AccelerationUsingBLE
//
//  Created by 모상현 on 2023/02/15.
//

import UIKit
class FetchSensingDataController:UIViewController {
    // MARK: - Properties
    private let sensingDataLabel: UILabel = {
       let lb = UILabel()
        lb.text = "감지된 센서값은:"
        lb.font = UIFont.systemFont(ofSize: 16)
        lb.textColor = .white
        return lb
    }()
    private let sensingData: UILabel = {
       let lb = UILabel()
        lb.text = "값을 불러오지 못했습니다."
        lb.font = UIFont.systemFont(ofSize: 16)
        lb.textColor = .white
        return lb
    }()
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureNavigation()
    }
    // MARK: - Selector
    // MARK: - API
    // MARK: - Helper
    func configureUI() {
        view.backgroundColor = .black
        let stack = UIStackView(arrangedSubviews: [sensingDataLabel, sensingData])
        stack.axis = .horizontal
        stack.distribution = .fillProportionally
        view.addSubview(stack)
        
        stack.centerX(inView: self.view)
        stack.centerY(inView: self.view)
    }
    func configureNavigation() {
        self.navigationController?.navigationBar.prefersLargeTitles = false
    }
}

extension FetchSensingDataController:BluetoothSerialDelegate {
    func 블루투스기기에게메세지를받은후(message: String) {
        customAlert(view: self, mainTitle: "알림", mainMessage: "메세지도착\nmessage:[\(message)]") { _ in
            self.dismiss(animated: true)
        }
    }
}
