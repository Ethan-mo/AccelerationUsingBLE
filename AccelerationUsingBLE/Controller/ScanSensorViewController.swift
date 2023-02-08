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
    private var peripheralList: [(peripheral : CBPeripheral, RSSI : Float)] = []
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
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
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "ScanSensor"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(scanSensor))
    }
    func configureTableView() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.rowHeight = 60
        tableView.register(ScanTableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.anchor(top:topLayoutGuide.bottomAnchor,left: view.leftAnchor,bottom: bottomLayoutGuide.topAnchor, right: view.rightAnchor, paddingTop: 16, paddingBottom: 16)
        tableView.backgroundColor = .gray
    }
    func configureSerial() {
        serial.delegate = self
        peripheralList = []
        serial.startScan()
    }
    
}

extension ScanSensorViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return peripheralList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! ScanTableViewCell
        let peripheralName = peripheralList[indexPath.row].peripheral.name
        cell.updatePeriphralsName(name: peripheralName)
        return cell
    }
    
    
}
extension ScanSensorViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        serial.stopScan()
        let selectedPripheral = peripheralList[indexPath.row].peripheral
        serial.connectToPeripheral(selectedPripheral)
    }
}

extension ScanSensorViewController {
    func serialDidDiscoverPeripheral(peripheral: CBPeripheral, RSSI: NSNumber?) {
        // serial의 delegate에서 호출됩니다.
        // 이미 저장되어 있는 기기라면 return합니다.
        for existing in peripheralList {
            if existing.peripheral.identifier == peripheral.identifier {return}
        }
        // 신호의 세기에 따라 정렬하도록 합니다.
        let fRSSI = RSSI?.floatValue ?? 0.0
        peripheralList.append((peripheral : peripheral , RSSI : fRSSI))
        peripheralList.sort { $0.RSSI < $1.RSSI}
        // tableView를 다시 호출하여 검색된 기기가 반영되도록 합니다.
        tableView.reloadData()
    }
    func serialDidConnectPeripheral(peripheral: CBPeripheral) {
        // serial의 delegate에서 호출됩니다.
        // 연결 성공 시 alert를 띄우고, alert 확인 시 View를 dismiss합니다.
        let connectSuccessAlert = UIAlertController(title: "블루투스 연결 성공", message: "\(peripheral.name ?? "알수없는기기")와 성공적으로 연결되었습니다.", preferredStyle: .actionSheet)
        let confirm = UIAlertAction(title: "확인", style: .default, handler: { _ in self.dismiss(animated: true, completion: nil) } )
        connectSuccessAlert.addAction(confirm)
        serial.delegate = nil
        present(connectSuccessAlert, animated: true, completion: nil)
    }
}
