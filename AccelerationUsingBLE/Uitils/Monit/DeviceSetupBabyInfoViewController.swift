//
//  DeviceSetupBabyInfoViewController.swift
//  Monit
//
//  Created by 맥 on 2017. 9. 28..
//  Copyright © 2017년 맥. All rights reserved.
//

import UIKit

class DeviceSetupBabyInfoViewController: BaseViewController {
    @IBOutlet weak var lblNaviTitle: UILabel!
    @IBOutlet weak var lblNameTitle: UILabel!
    @IBOutlet weak var lblBirthTitle: UILabel!
    @IBOutlet weak var lblSexTitle: UILabel!
    
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblSex: UILabel!
    @IBOutlet weak var lblBirthday: UILabel!
    
    override var screenType: SCREEN_TYPE { get { return .SENSOR_SETUP_BABYINFO } }
    var m_detailInfo: DeviceDetailInfo?
    var sensorStatusInfo: SensorStatusInfo? {
        get {
            return DataManager.instance.m_userInfo.deviceStatus.m_sensorStatus.getInfoByDeviceId(did: m_detailInfo!.m_did)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUI()
    }

    func setUI() {
        if (sensorStatusInfo == nil || sensorStatusInfo!.m_bday == "000101" || sensorStatusInfo!.m_bday == "000000" || sensorStatusInfo!.m_bday == "700101") {
            lblName.text = ""
            lblSex.text = ""
            lblBirthday.text = ""
        } else {
            lblName.text = sensorStatusInfo!.m_name
            lblSex.text = SEX.man == SEX(rawValue: sensorStatusInfo!.m_sex) ? "sex_baby_boy".localized : "sex_baby_girl".localized
            lblBirthday.text = UI_Utility.convertDateStringToString(sensorStatusInfo!.m_bday, fromType: .yyMMdd, toType: .yyyy_MM_dd)
        }
        
        lblNaviTitle.text = "setting_device_babyinfo".localized
        lblNameTitle.text = "account_baby_name".localized
        lblBirthTitle.text = "account_baby_birthday".localized
        lblSexTitle.text = "account_baby_sex".localized
     }

    @IBAction func onClick_back(_ sender: UIButton) {
        UIManager.instance.sceneMoveNaviPop()
    }
}
