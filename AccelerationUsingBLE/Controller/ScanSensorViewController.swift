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
    }
    // MARK: - API
    // MARK: - Selector
    @objc func scanSensor() {
        
    }
    // MARK: - Helpers
    func configureUI() {
        configureNavigation()
        configureTableView()
        configureSerial()
    }
    func configureNavigation() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "ScanSensor"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(scanSensor))
    }
    func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.rowHeight = 60
    }
    func configureSerial() {
        serial = BluetoothSerial.init()
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
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as? ScanTableViewCell
        let peripheralName = peripheralList[indexPath.row].peripheral.name
        cell.update
    }
    
    
}
extension ScanSensorViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        <#code#>
    }
}

