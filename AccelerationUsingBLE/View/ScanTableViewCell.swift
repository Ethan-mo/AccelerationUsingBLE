//
//  ScanTableViewCell.swift
//  AccelerationUsingBLE
//
//  Created by 모상현 on 2023/02/07.
//

import UIKit

class ScanTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    // Peripheral의 이름을 표시할 Label입니다. ScanViewController뷰의 셀 내의 Label과 연결합니다.
    private let peripheralNameLabel: UILabel = {
       let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 16)
        lb.textColor = .black
        return lb
    }()
    
    // MARK: - Lifecycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubview(peripheralNameLabel)
        peripheralNameLabel.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, paddingTop: 8, paddingLeft: 12, paddingBottom: 8)

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// peripheral의 이름을 파라미터로 입력받아 Cell을 update합니다.
    func updatePeriphralsName(name : String?)
    {
        guard name != nil else { return }
        peripheralNameLabel.text = name
    }
}
