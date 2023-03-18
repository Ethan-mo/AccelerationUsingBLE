//
//  FetchSenSingDataController.swift
//  AccelerationUsingBLE
//
//  Created by 모상현 on 2023/02/15.
//

import UIKit
class FetchSensingDataController:UIViewController {
    // MARK: - Properties
    var count = 0
    private let logTextView: UITextView = {
       let tv = UITextView()
        tv.font = UIFont.systemFont(ofSize: 16)
        tv.textColor = .black
        tv.text = "gd"
        tv.backgroundColor = .white
        return tv
    }()
    
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
        serial.delegate = self
        configureUI()
        configureNavigation()
    }
    // MARK: - Selector
    // MARK: - API
    // MARK: - Helper
    func configureUI() {
        view.backgroundColor = .black
        let stack = UIStackView(arrangedSubviews: [logTextView, sensingDataLabel, sensingData])
        stack.axis = .vertical
        stack.distribution = .fillProportionally
        view.addSubview(stack)
        
        logTextView.setDimensions(width: 300, height: 300)
        
        stack.centerX(inView: self.view)
        stack.centerY(inView: self.view)
    }
    func configureNavigation() {
        self.navigationController?.navigationBar.prefersLargeTitles = false
    }
}

extension FetchSensingDataController:BluetoothSerialDelegate {
    func 블루투스기기에게메세지를받은후(message: String) {
        
        //let text = logTextView.text + message + String(count)
        logTextView.text += message + String(count) + "\n"
        count += 1
//        customAlert(view: self, mainTitle: "알림", mainMessage: "메세지도착\nmessage:[\(message)]") { _ in
//            self.dismiss(animated: true)
//        }
        
    }
}
