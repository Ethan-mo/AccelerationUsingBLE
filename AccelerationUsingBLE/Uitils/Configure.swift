//
//  Configure.swift
//  AccelerationUsingBLE
//
//  Created by 모상현 on 2023/02/08.
//

import Foundation

class Config {
    static let SLEEP_VALUE: Int = 13
}

enum BlePacketType: UInt8 {
    case DEVICE_ID            = 0x01
    case CLOUD_ID            = 0x02
    case HARDWARE_VERSION    = 0x03
    case FIRMWARE_VERSION    = 0x04
    case SENSOR_STATUS        = 0x05
    case LED_CONTROL        = 0x06
    case INITIALIZE            = 0x07
    case BABY_INFO            = 0x08
    case CURRENT_UTC        = 0x09
    
    case TOUCH                = 0x10
    case BATTERY            = 0x11
    case X_AXIS                = 0x12
    case Y_AXIS                = 0x13
    case Z_AXIS                = 0x14
    case ACCELERATION        = 0x15
    case TEMPERATURE        = 0x20
    case HUMIDITY            = 0x21
    case VOC                = 0x22
    case CO2                = 0x23
    case RAW_GAS            = 0x24
    case COMPENSATED_GAS    = 0x25
    case PRESSURE            = 0x26
    case ETHANOL            = 0x27
    case ACK                = 0x30
    
    case REQUEST            = 0x81
    case AUTO_POLLING        = 0x82
    case PART_NUMBER        = 0x90
    case SERIAL_NUMBER        = 0x91
    case DEVICE_NAME        = 0x92
    case MAC_ADDRESS        = 0x93
    case UTC_TIME_INFO      = 0x94
    
    case HUB_TYPES_DEVICE_ID            = 0x40
    case HUB_TYPES_CLOUD_ID            = 0x41
    case HUB_TYPES_FIRMWARE_VERSION    = 0x42
    case HUB_TYPES_AP_SECURITY        = 0x43
    case HUB_TYPES_AP_CONNECTION_STATUS   = 0x44
    
    case KEEP_ALIVE             = 0x45
    case DFU                    = 0x46
    case SENSITIVE              = 0x47
    case PENDING                = 0x48
    case HEATING                = 0x49
    case DIAPER_STATUS_COUNT    = 0x4B
    
    case FACTORY_MODE       = 0x50
    case LAMP_BRIGHT_CTRL       = 0x51
    
    case HUB_TYPES_AP_NAME            = 0xA0
    case HUB_TYPES_AP_PASSWORD        = 0xA1
    case HUB_TYPES_SERIAL_NUMBER        = 0xA2
    case HUB_TYPES_DEVICE_NAME        = 0xA3
    case HUB_TYPES_MAC_ADDRESS        = 0xA4
    case HUB_TYPES_WIFI_SCAN          = 0xA5
    
    case LATEST_PEE_DETECTION_TIME = 0xA7
    case LATEST_POO_DETECTION_TIME = 0xA8
    case LATEST_ABNORMAL_DETECTION_TIME = 0xA9
    case LATEST_FART_DETECTION_TIME = 0xAA
    case LATEST_DETACHMENT_DETECTION_TIME = 0xAB
    case LATEST_ATTACHMENT_DETECTION_TIME = 0xAC
    
    case DEVICE_RESET = 0x0F
}
enum BLE_COMMUNICATION_TYPE {
    case request
    case cmd
    case noti
}
