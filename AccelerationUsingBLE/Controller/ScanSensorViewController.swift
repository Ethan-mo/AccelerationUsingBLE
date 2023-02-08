//
//  ScanSensorViewController.swift
//  AccelerationUsingBLE
//
//  Created by 모상현 on 2023/02/07.
//

import UIKit
import CoreBluetooth

private let reuseIdentifier: String = "ScanTableViewCell"

class ScanSensorViewController: UIViewController, BluetoothSerialDelegate {
    // MARK: - Properties
    private let tableView = UITableView()
    private var 주변블루투스기기들: [(peripheral : CBPeripheral, RSSI : Float)] = []
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.statusBarStyle = .lightContent
        configureUI()
        configureSerial()
    }
    // MARK: - API
    // MARK: - Selector
    @objc func scanSensor() {
        print("DEBUG: 블루투스를 탐색합니다.")
        configureSerial()
    }
    // MARK: - Helpers
    func configureUI() {
        view.backgroundColor = .white
        configureNavigation()
        configureTableView()
    }
    func configureNavigation() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.backgroundColor = .systemBlue
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.tintColor = .white
        navigationItem.title = "ScanSensor"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(scanSensor))
    }
    func configureTableView() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.rowHeight = 60
        tableView.register(ScanTableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.frame = view.frame
    }
    func configureSerial() {
        serial.delegate = self
        주변블루투스기기들 = []
        serial.startScan()
    }
    
}

extension ScanSensorViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 주변블루투스기기들.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! ScanTableViewCell
        let peripheralName = 주변블루투스기기들[indexPath.row].peripheral.name
        cell.updatePeriphralsName(name: peripheralName)
        return cell
    }
    
}
extension ScanSensorViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        serial.stopScan()
        let selectedPripheral = 주변블루투스기기들[indexPath.row].peripheral
        serial.connectToPeripheral(selectedPripheral)
    }
}

extension ScanSensorViewController {
    func 블루투스기기가검색이된후(peripheral: CBPeripheral, RSSI: NSNumber?) {
        // serial의 delegate에서 호출됩니다.
        // 이미 저장되어 있는 기기라면 return합니다.
        for existing in 주변블루투스기기들 {
            if existing.peripheral.identifier == peripheral.identifier {return}
        }
        // 신호의 세기에 따라 정렬하도록 합니다.
        let fRSSI = RSSI?.floatValue ?? 0.0
        주변블루투스기기들.append((peripheral : peripheral , RSSI : fRSSI))
        주변블루투스기기들.sort { $0.RSSI < $1.RSSI}
        // tableView를 다시 호출하여 검색된 기기가 반영되도록 합니다.
        tableView.reloadData()
    }
    func 블루투스기기가연결이된후(peripheral: CBPeripheral) {
        // serial의 delegate에서 호출됩니다.
        // 연결 성공 시 alert를 띄우고, alert 확인 시 View를 dismiss합니다.
        customAlert(view: self, mainTitle: "알림", mainMessage: "\(peripheral.name ?? "알수없는기기")와 성공적으로 연결되었습니다.") { _ in
            self.dismiss(animated: true)
            let controller = FetchSensingDataController()
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
}
