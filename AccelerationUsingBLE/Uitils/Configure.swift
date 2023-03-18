//
//  Config.swift
//  Monit
//
//  Created by 맥 on 2017. 8. 23..
//  Copyright © 2017년 맥. All rights reserved.
//

import UIKit
import CoreBluetooth

typealias ActionResultAny = (Any?) -> ()
typealias ActionResultInt64 = (Int64) -> ()
typealias ActionResultString = (String) -> ()
typealias ActionResultBool = (Bool) -> ()
typealias Action = () -> ()

enum LANGUAGE_TYPE: String {
    case ko = "ko"
    case en = "en"
    case zh = "zh"
    case jp = "jp"
    case es = "es"
}

class DeviceDefine {
    static let MONIT_DEVICE_NAME = "MONIT_"

    static let EX_RX_SERVICE_UUID       = CBUUID(string: "6e400001-b5a3-f393-e0a9-e50e24dcca9e")
    static let EX_NOTIFICATION_DESCRIPTION_UUID = CBUUID(string: "00002902-0000-1000-8000-00805f9b34fb")
    static let EX_RX_CHAR_UUID          = CBUUID(string: "6e400002-b5a3-f393-e0a9-e50e24dcca9e")
    static let EX_TX_CHAR_UUID          = CBUUID(string: "6e400003-b5a3-f393-e0a9-e50e24dcca9e")
    
    static let RX_SERVICE_UUID          = CBUUID(string: "20c10001-71bd-11e7-8cf7-a6006ad3dba0")
    static let RX_CHAR_UUID             = CBUUID(string: "20c10002-71bd-11e7-8cf7-a6006ad3dba0")
    static let TX_CHAR_UUID             = CBUUID(string: "20c10003-71bd-11e7-8cf7-a6006ad3dba0")
    static let NOTIFICATION_DESCRIPTION_UUID = CBUUID(string: "00002902-0000-1000-8000-00805f9b34fb")
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

enum BundleIdentifierType: String {
    case none = ""
    case goodmonit = "com.monit.goodmonit"
    case huggies = "com.monit.monitxhuggies"
    case kc = "com.kcc.HuggiesxMonit"
    case kao = "com.monit.goodmonitkao"
}

enum DEVICE_TYPE: Int {
    case Sensor = 1
    case Hub = 2
    case Lamp = 3
}

enum BLE_COMMUNICATION_TYPE {
    case request
    case cmd
    case noti
}

enum SEX : Int {
    case man = 1
    case women = 0
}

enum WIFI_SECURITY_TYPE : Int {
    case NONE = 0
    case WEB = 1
    case WPA = 2
    case WPA2 = 3
    case WPA_TKIP = 4
    case WPA2_TKIP = 5
    case EAP = 6
    
    static let allValues = [NONE, WEB, WPA, WPA2, WPA_TKIP, WPA2_TKIP, EAP]
}
    
enum CHANNEL_TYPE: Int {
    case goodmonit = 0
    case monitXHuggies = 1
    case kc = 2
    case kao = 3
}

enum MONIT_SCHEME: String {
    case goodmonit = "goodmonit"
    case monitXHuggies = "monitxhuggies"
    case kc = "kchuggiesxmonit"
}

enum LOG_EVENT: Int {
    case normal = 0
    case warning = 1
    case error = 2
    case dev = 3
}

enum PACKET_TYPE : String
{
    case None = "None"
    
    case Init = "Init"
    case GetAppData = "GetAppData"
    case GetLocalAppData = "GetLocalAppData"
 
    // account
    case Signin = "Signin"
    case YKSignin = "YKSignin"
    case YKSigninOAuth2 = "YKSigninOAuth2"
    case GetPolicy = "GetPolicy"
    case SetPolicy = "SetPolicy"
    case Join1 = "Join1"
    case Join2 = "Join2"
    case Join3 = "Join3"
    case ResendAuth = "ResendAuth"
    case GetUserInfo = "GetUserInfo"
    case Signout = "Signout"
    case ChangePassword = "ChangePassword"
    case ChangePasswordV2 = "ChangePasswordV2"
    case ChangeNickname = "ChangeNickname"
    case FindPasswd = "FindPasswd"
    case ResetPassword = "ResetPassword"
    case Leave = "Leave"
    case UpdatePush = "UpdatePush"
    case SetDeviceAlarmStatus = "SetDeviceAlarmStatus"
    case SetDeviceAlarmStatusCommon = "SetDeviceAlarmStatusCommon"
    case GetNoticeV2 = "GetNoticeV2"
    case GetLatestInfo = "GetLatestInfo"
    case SetAppInfo = "SetAppInfo"
    case GetMaintenance = "GetMaintenance"
    case GetMaintenance_Notice = "GetMaintenance_Notice"
    case AccountActiveUser = "AccountActiveUser"
    case ChannelEvent = "ChannelEvent"
    case ScreenAnalytics = "ScreenAnalytics"
    
    // cloud
    case InviteCloudMember = "InviteCloudMember"
    case DeleteCloudMember = "DeleteCloudMember"
    case LeaveCloud = "LeaveCloud"
    case RequestBecomeCloudMember = "RequestBecomeCloudMember"
    case GetCloudNotification = "GetCloudNotification"
    
    // device
    case GetDeviceId = "GetDeviceId"
    case GetCloudId = "GetCloudId"
    case SetCloudId = "SetCloudId"
    case StartConnection = "StartConnection"
    case SetBabyInfo = "SetBabyInfo"
    case GetDeviceStatus = "GetDeviceStatus"
    case GetDeviceFullStatus = "GetDeviceFullStatus"
    case SetDeviceStatus = "SetDeviceStatus"
    case InitDevice = "InitDevice"
    case AvailableSerialNumber = "AvailableSerialNumber"
    case SetDiaperChanged = "SetDiaperChanged"
    case SetFeeding = "SetFeeding"
    case InitDiaperStatus = "InitDiaperStatus"
    case SetDeviceName = "SetDeviceName"
    case SetAlarmThreshold = "SetAlarmThreshold"
    case GetNotification = "GetNotification"
    //    case RemoveNotification = "RemoveNotification"
    case SetLedOnOffTime = "SetLedOnOffTime"
    case SetDeviceConnected = "SetDeviceConnected"
    case OTAUpdateDevice = "OTAUpdateDevice"
    case SetSensorConnectionLog = "SetSensorConnectionLog"
    case SetNotificationFeedback = "SetNotificationFeedback"
    case SetDiaperSensingLog = "SetDiaperSensingLog"
    case SetSensorSensitivity = "SetSensorSensitivity"
    case GetSensorFW = "GetSensorFW"
    case GetSensorFWV2 = "GetSensorFWV2"
    case GetHubGraphList = "GetHubGraphList"
    case GetLampGraphList = "GetLampGraphList"
    case GetSensorMovGraphList = "GetSensorMovGraphList"
    case GetSensorVocGraphList = "GetSensorVocGraphList"
    case GetSensorGraphAverage = "GetSensorGraphAverage"
    case GetDemoInfo = "GetDemoInfo"
    case GetNotificationEdit = "GetNotificationEdit"
    case SetNotificationEdit = "SetNotificationEdit"
    case OAuthGetAuth = "OAuthGetAuth"
    case GetHubTimerInfo = "GetHubTimerInfo"
    case SetSleepMode = "SetSleepMode"
    case SetHubBrightControl = "SetHubBrightControl"
}

enum ERR_COD : Int
{
    case unknown = 0
    
    case success = 200
    case invaildTokenExpire = 103
    case invaildToken = 104
    
    case signin_invaildEmail = 101
    case signin_invaildPw = 102
    
    case join_emailExist = 121
    case join_emailLeave = 123
    case join_emailSendFail = 124
    
    case join_emailAuthNone = 125
    
    case findPassword_invalidInfo = 131
    case findPassword_sendFail = 132
    
    case shareMember_emailExist = 141
    case shareMember_limitMember = 142
    case shareMember_alreadyMember = 143
    case shareMember_noneGroup = 144
    
    case sensor_already_register = 151
    case available_serial_number = 153
    case json_parse_err = 161
    case sensor_not_found_row = 165
    case sensor_not_found_deviceid = 166 // 암호화 값이 맞지 않을때도 포함
    
    case etc_err_162 = 162
    case etc_err_170 = 170
    case need_essential_value = 163
    
    case current_password_not_match = 173
}

// move viewController
enum SCENE_MOVE: String
{
    case initView = "initView"
    case mainSignin = "mainSignin"
//    case mainSigninGoodmonit = "mainSigninGoodmonit"
//    case mainSigninGoodmonitXHuggies = "mainSigninGoodmonitXHuggies"
    case policyMonitXHuggies = "policyMonitXHuggies"
    case joinEmailNavi = "joinEmailNavi"
    case joinEmailAuthNavi = "joinEmailAuthNavi"
    case joinUserInfoNavi = "joinUserInfoNavi"
    case mainDeviceNavi = "mainDeviceNavi"
    case shareMemberMainNavi = "shareMemberMainNavi"
    case userSetupMainNavi = "userSetupMainNavi"
    case findPassword = "findPassword"
    case deviceRegisterNavi = "deviceRegisterNavi"
    case deviceRegisterSensorBaby = "deviceRegisterSensorBaby"
    case sensorDetailNavi = "sensorDetailNavi"
    case hubDetailNavi = "hubDetailNavi"
    case lampDetailNavi = "lampDetailNavi"
}

enum SCENE_MOVE_PUSH : String
{
    case joinEmail = "joinEmail"
    case joinEmailAuth = "joinEmailAuth"
    case joinUserInfo = "joinUserInfo"
    case joinFinish = "joinFinish"
    case mainDevice = "mainDevice"
    case userSetupMain = "userSetupMain"
    case nickMonitXHuggies = "nickMonitXHuggies"
    case customWebView = "customWebView"
    
    case shareMemberMain = "shareMemberMain"
    case shareMemberDetail = "shareMemberDetail"
    case shareMemberInvite = "shareMemberInvite"
    
    case setupChangePassword = "setupChangePassword"
    case setupChangeNick = "setupChangeNick"
    case setupNUGU = "setupNUGU"
    case setupAssistant = "setupAssistant"
    
    case deviceRegister = "deviceRegister"
    case deviceRegisterSensor = "deviceRegisterSensor"
    case deviceRegisterSensorLight = "deviceRegisterSensorLight"
    case deviceRegisterSensorBaby = "deviceRegisterSensorBaby"
    case deviceRegisterSensorFinish = "deviceRegisterSensorFinish"
    case deviceRegisterHub = "deviceRegisterHub"
    case deviceRegisterHubLight = "deviceRegisterHubLight"
    case deviceRegisterHubConnecting = "deviceRegisterHubConnecting"
    case deviceRegisterHubWifi = "deviceRegisterHubWifi"
    case deviceRegisterHubWifiSelect = "deviceRegisterHubWifiSelect"
    case deviceRegisterHubWifiSelectPassword = "deviceRegisterHubWifiSelectPassword"
    case deviceRegisterHubFinish = "deviceRegisterHubFinish"
    case deviceRegisterHubWifiCustom = "deviceRegisterHubWifiCustom"
    case deviceRegisterHubWifiCustomSecu = "deviceRegisterHubWifiCustomSecu"
    case deviceRegisterPackageSensorOn = "deviceRegisterPackageSensorOn"
    case deviceRegisterPackageHubOn = "deviceRegisterPackageHubOn"
    case deviceRegisterPackageSensorIntoHub = "deviceRegisterPackageSensorIntoHub"
    case deviceRegisterPackageSetInfo = "deviceRegisterPackageSetInfo"
    case deviceRegisterLamp = "deviceRegisterLamp"
    case deviceRegisterLampLight = "deviceRegisterLampLight"
    case deviceRegisterLampWifi = "deviceRegisterLampWifi"
    case deviceRegisterLampWifiSelect = "deviceRegisterLampWifiSelect"
    case deviceRegisterLampWifiSelectPassword = "deviceRegisterLampWifiSelectPassword"
    case deviceRegisterLampFinish = "deviceRegisterLampFinish"
    case deviceRegisterLampWifiCustom = "deviceRegisterLampWifiCustom"
    case deviceRegisterLampWifiCustomSecu = "deviceRegisterLampWifiCustomSecu"
    case deviceDiaperAttachGuide = "deviceDiaperAttachGuide"
    
    case sensorDetail = "sensorDetail"
    case hubDetail = "hubDetail"
    case lampDetail = "lampDetail"
    
    case deviceSetupSensorMain = "deviceSetupSensorMain"
    case deviceSetupBabyInfoMaster = "deviceSetupBabyInfoMaster"
    case deviceSetupBabyInfo = "deviceSetupBabyInfo"
    case deviceSetupSensorFirmware = "deviceSetupSensorFirmware"
    case deviceSetupSensorConnecting = "deviceSetupSensorConnecting"
    case deviceSetupSensorFirmwareUpdate = "deviceSetupSensorFirmwareUpdate"
    
    case deviceSetupHubMain = "deviceSetupHubMain"
    case deviceSetupHubDeviceName = "deviceSetupHubDeviceName"
    case deviceSetupHubWifi = "deviceSetupHubWifi"
    case deivceSetupHubTemp = "deivceSetupHubTemp"
    case deviceSetupHubHum = "deviceSetupHubHum"
    case deivceSetupHubLed = "deivceSetupHubLed"
    case deviceSetupHubFirmware = "deviceSetupHubFirmware"
    
    case deviceSetupLampMain = "deviceSetupLampMain"
    case deviceSetupLampDeviceName = "deviceSetupLampDeviceName"
    case deviceSetupLampWifi = "deviceSetupLampWifi"
    case deivceSetupLampTemp = "deivceSetupLampTemp"
    case deviceSetupLampHum = "deviceSetupLampHum"
    case deivceSetupLampLed = "deivceSetupLampLed"
    case deviceSetupLampFirmware = "deviceSetupLampFirmware"
    case deviceSetupLampConnecting = "deviceSetupLampConnecting"
    
    case deviceSetupWidget = "deviceSetupWidget"
}

enum SCENE_CONTAINER : String {
    case mainSigninGoodmonitContainer = "mainSigninGoodmonitContainer"
    case mainSigninMonitXHuggiesContainer = "mainSigninMonitXHuggiesContainer"
    case mainSigninKcContainer = "mainSigninKcContainer"
    
    case mainDeviceTableContainer = "mainDeviceTableContainer"
    case mainDeviceNoneTableContainer = "mainDeviceNoneTableContainer"
    
    case deviceSensorDetailSensingContainer = "deviceSensorDetailSensingContainer"
    case deviceSensorDetailSensingForKcContainer = "deviceSensorDetailSensingForKcContainer"
    case deviceSensorDetailGraphContainer = "deviceSensorDetailGraphContainer"
    case deviceSensorDetailGraphForKcContainer = "deviceSensorDetailGraphForKcContainer"
    case deviceSensorDetailNotiContainer = "deviceSensorDetailNotiContainer"
    case deviceSensorDetailNotiForHuggiesContainer = "deviceSensorDetailNotiForHuggiesContainer"
    case deviceHubDetailSensingContainer = "deviceHubDetailSensingContainer"
    case deviceHubDetailSensingForKcContainer = "deviceHubDetailSensingForKcContainer"
    case deviceHubDetailGraphContainer = "deviceHubDetailGraphContainer"
    case deviceHubDetailGraphForKcContainer = "deviceHubDetailGraphForKcContainer"
    case deviceHubDetailNotiContainer = "deviceHubDetailNotiContainer"
    case deviceLampDetailSensingContainer = "deviceLampDetailSensingContainer"
    case deviceLampDetailGraphContainer = "deviceLampDetailGraphContainer"
    case deviceLampDetailNotiContainer = "deviceLampDetailNotiContainer"
    
    case shareMemberShareContainer = "shareMemberShareContainer"
    case shareMemberGetSharedContainer = "shareMemberGetSharedContainer"
    case shareMemberNotiContainer = "shareMemberNotiContainer"
}

enum APP_ERR_COD: String {
    case exitApp = "0"
    case userInfo = "1"
    case initFullStatus = "2"
    case Send_SetDeviceName = "3"
    case Send_SetAlarmThreshold = "4"
    case Send_LeaveCloud = "5"
    case Send_InitDevice = "6"
    case Send_SetLedOnOffTime = "7"
    case Send_SetBabyInfo = "8"
    case Send_RequestBecomeCloudMember = "9"
    case Send_NotificationFeedback = "10"
    case setSensorInit = "11"
    case networkFailure = "13"
    case Send_SetAppInfo = "14"
}

enum NEW_ALARM_ITEM_TYPE: Int {
    case sensorNoti = 1
    case hubNoti = 2
    case lampNoti = 5
    case sensorFirmware = 3
    case hubFirmware = 4
    case lampFirmware = 6
    
    case deviceMain_sensorDiaper = 101
    case deviceMain_hub = 102
    case deviceMain_lamp = 103

    case sensorDetail_setup = 201
    case sensorDetail_notiList = 202
    case sensorSetupMain_firmware = 210
    case sensorSetupMain_firmwareUpdateMain = 211
    
    case hubDetail_setup = 203
    case hubSetupMain_firmware = 212
    case hubSetupMain_firmwareUpdateMain = 213
    case lampDetail_setup = 214
    case lampSetupMain_firmware = 215
    case lampSetupMain_firmwareUpdateMain = 216

    case hubDetail_notiList = 301
    case lampDetail_notiList = 302
}

enum ALRAM_TYPE : Int {
    case none = 0
    case all = 100
    case pee = 1
    case poo = 2
    case abnormal = 3
    case diaper_change = 4
    case fart = 5
    case move_detected = 8
    case sensor_diaper_change = 6
    case sensor_long_disconnected = 46
    case diaper_score = 110
    case auto_move_detected = 120
}

enum TEMPERATURE_UNIT: String {
    case Celsius = "Celsius"
    case Fahrenheit = "Fahrenheit"
}

enum NotificationType: Int {
    case DEVICE_ALL = 100
    
    case PEE_DETECTED = 1
    case POO_DETECTED = 2
    case ABNORMAL_DETECTED = 3
    case DIAPER_CHANGED = 4
    case FART_DETECTED = 5
    case DETECT_DIAPER_CHANGED = 6
    
    case MOVE_DETECTED = 8
    
    case LOW_TEMPERATURE = 21
    case HIGH_TEMPERATURE = 22
    case LOW_HUMIDITY = 23
    case HIGH_HUMIDITY = 24
    case VOC_WARNING = 25
    
    case LOW_BATTERY = 41
    case DISCONNECTED = 42
    case CONNECTED = 43
    case HUB_TYPES_DISCONNECTED = 44
    case HUB_TYPES_CONNECTED = 45
    
    case UPDATE_FULL_DATA = 50
    case UPDATE_CLOUD_DATA = 51
    case UPDATE_NOTI_DATA = 52
    case CLOUD_INIT_DEVICE = 68
    
    case OAUTH_LOGIN_SUCCSS = 70
    
    case SLEEP_MODE = 80
    
    case DIAPER_SCORE = 110
    
    case CUSTOM_MESSAGE = 203
}

// 삭제 예정
enum SCREEN_TYPE: Int {
    case none = 0
    case MONIT_SIGNIN =  101
    case MONITXHUGGIES_SIGNIN =  102
    case MONITXHUGGIES_POLICY =   103
    
    case JOIN_EMAIL_INPUT = 201
    case JOIN_EMAIL_AUTH = 202
    case JOIN_PARENT = 203
    case JOIN_SUCCESS = 204
    
    case PASSWORD_FIND =   301
    
    case ACCOUNT_INFO =   401
    case ACCOUNT_CHANGE_PASSWORD =   402
    case ACCOUNT_CHANGE_NICKNAME =   403
    case ACCOUNT_NUGU = 404
    
    case DEVICE_LIST =   501
    case DEVICE_REGISTER =   502
    case SENSOR_REGISTER_READY =   601
    case SENSOR_REGISTER_BABY_INFO =   602
    case SENSOR_REGISTER_SUCCESS =   603
    case HUB_REGISTER_READY =   701
    case HUB_REGISTER_SELECT_WIFI =   702
    case HUB_REGISTER_PASSWORD =   703
    case HUB_REGISTER_SUCCESS =   704
    case HUB_REGISTER_CUSTOM =   705
    case HUB_REGISTER_CUSTOM_SECURE =   706
    
    case SHARE_SHARE =   801
    case SHARE_RECEIVE =   802
    case SHARE_NOTI =   803
    
    case SENSOR_DETAIL_STATUS =   901
    case SENSOR_DETAIL_GRAPH =   902
    case SENSOR_DETAIL_NOTI =   903
    case SENSOR_SETUP_INFO =   1001
    case SENSOR_SETUP_BABYINFO =   1002
    case SENSOR_SETUP_FIRMWARE =   1003
    case SENSOR_SETUP_FIRMWARE_NEED_BLE = 1004
    case HUB_DETAIL_STATUS =   1101
    case HUB_DETAIL_GRAPH =   1102
    case HUB_DETAIL_NOTI =   1103
    case HUB_SETUP_INFO =   1201
    case HUB_SETUP_NAME =   1202
    case HUB_SETUP_TEMP =   1203
    case HUB_SETUP_HUM =   1204
    case HUB_SETUP_LED =   1205
    case HUB_SETUP_FIRMWARE =   1206
    
    case WIDGET_SETUP = 1301
}

enum LOG_PRINT_LEVEL: Int {
    case none = -1
    case print = 0
    case clsLog = 1
}

enum DEBUG_CONSOLE_PRINT_LEVEL: Int {
    case none = -1
    case normal = 0
    case warning = 1
    case error = 2
    case all = 10
}

enum SCHEME_KEY: String {
    case from = "from"
    case sitecode = "sitecode"
    case value = "value"
    case id_token = "id_token"
    case access_token = "access_token"
}

enum SCHEME_FROM_TYPE: String {
    case yk = "yk"
    case playground = "playground"
    case widget = "widget"
}

enum SCHEME_SITE_CODE: String {
    case signin = "signin"
}

enum HUB_TYPES_GRAPH_TYPE {
    case score
    case tem
    case hum
    case voc
}

class SchemeInfo {
    var m_from: SCHEME_FROM_TYPE?
    var m_sitecode = ""
    var m_value = ""
    var m_id_token = ""
    var m_access_token = ""
}

enum ChannelOSType: Int {
    case goodmonit_ios = 0
    case monitxhuggies_ios = 1
    case kc_ios = 2
    case kao_ios = 3
}

// 하기스에서 약관 동의를 안할 수 있으므로 앱에서 띄어줘야 함
enum POLICY_AGREE_TYPE: Int {
    case huggies_service = 1000
    case huggies_privacy = 2000
    case huggies_collect = 3000
    case huggies_3rdparty = 4000
    
    case goodmonit_service = 1001
    case goodmonit_privacy = 2001
    case goodmonit_privacy_gdpr = 2002
    
    case kao_service = 1003
    case kao_privacy = 2003
    case kao_privacy_gdpr = 2004
    case kao_3rdparty = 4003
}

enum DATE_TYPE: String {
    case yyyyMMdd = "yyyyMMdd"
    case yyMMdd = "yyMMdd"
    case full = "yyyy-MM-dd HH:mm:ss"
    case yyyy_MM_dd = "yyyy.MM.dd"
    case MMM_dd_yyyy = "MMM dd,yyyy"
    case dd_MM_yyyy = "dd.MM.yyyy"
    case yyMMdd_HHmmss = "yyMMdd-HHmmss"
    case yyyy = "yyyy"
    case MM = "MM"
    case dd = "dd"
    case HHmm = "HHmm"
    case HH = "HH"
    case ENGLISH_MONTHLY_dd = "MMM,yyyy"
}

enum COMMON_SOUND_TYPE: String {
    case noti_mommy = "girl_mommy"
    case noti_daddy = "girl_daddy"
}

enum SENSOR_FIRMWARE_MODE_TYPE: Int {
    case mode0 = 0
    case mode1 = 1
    case mode2 = 2
    case mode32 = 32
    case mode128 = 128
}

enum HUB_FIRMWARE_MODE_TYPE: Int {
    case mode0 = 0
    case mode1 = 1
    case mode2 = 2
    case mode32 = 32
    case mode128 = 128
}

enum LAMP_FIRMWARE_MODE_TYPE: Int {
    case mode0 = 0
    case mode1 = 1
    case mode2 = 2
    case mode32 = 32
    case mode128 = 128
}

enum SENSOR_FIRMWARE_MODE_VERSION: String {
    case mode10 = "1.1.0"
}

enum HUB_TYPES_REGISTER_TYPE: String {
    case new = "new"
    case changeWifi = "changeWifi"
    case package = "package"
}

enum NOTICE_TYPE: Int {
    case alwaysRepeat = 1
}

enum ETC_CHANNEL_TYPE: Int {
    case playground = 1
}

enum ETC_CHANNEL_EVENT_TYPE: Int {
    case default_link = 1
}

enum HUB_TYPES_BRIGHT_TYPE: Int {
    case start = -1
    case off = 0
    case level_1 = 102
    case level_2 = 511
    case level_3 = 1023
}

enum HUB_TYPES_BRIGHT_V2_TYPE: Int {
    case level_1 = 16
    case level_2 = 102
    case level_3 = 204
    case level_4 = 511
    case level_5 = 1023
}

enum NOTI_EDIT_TYPE: Int {
    case none = 0
    case delete = 1
    case modify = 2
}

enum SLEEP_MODE_TYPE: Int {
    case none = 0
    case naps = 1
    case night_sleep = 2
}

enum BREAST_MILK_DIRECTION_TYPE: Int {
    case none = 0
    case left = 1
    case right = 2
}

enum BOARD_TYPE: Int {
    case notice = 1
    case connect_device_sensor = 10
    case connect_device_hub = 11
    case connect_device_info = 12
}

enum GOOGLE_TAG_MANAGER_TYPE: String {
    case account_terms_and_conditions
    case account_privacy_policy
    case account_customer_support
    
    case group
    
    case hub_setting_temperature_scale
    case hub_setting_alarm_enabled
    case hub_setting_temperature_range
    case hub_setting_humidity_range
    case hub_setting_led_indicator_enabled
    case hub_setting_led_indicator_enabled_time
    
    case lamp_setting_temperature_scale
    case lamp_setting_alarm_enabled
    case lamp_setting_temperature_range
    case lamp_setting_humidity_range
    case lamp_setting_led_indicator_enabled
    case lamp_setting_led_indicator_enabled_time
    
    case sensor_alarm_pee_detected
    case sensor_alarm_poo_detected
    case sensor_alarm_fart_detected
    case sensor_alarm_diaper_changed
    
    case sensor_graph_diaper_button_weekly
    case sensor_graph_diaper_button_monthly
    case sensor_graph_pee_button_weekly
    case sensor_graph_pee_button_monthly
    case sensor_graph_poo_button_weekly
    case sensor_graph_poo_button_monthly
    case sensor_graph_fart_button_weekly
    case sensor_graph_fart_button_monthly
    
    case sensor_setting_alarm_enabled
    case sensor_setting_pee_alarm_enabled
    case sensor_setting_poo_alarm_enabled
    case sensor_setting_fart_alarm_enabled
    case sensor_setting_connection_alarm_enabled
    
    case hub_alarm_high_temperature_detected
    case hub_alarm_low_temperature_detected
    case hub_alarm_high_humidity_detected
    case hub_alarm_low_humidity_detected
    case lamp_alarm_high_temperature_detected
    case lamp_alarm_low_temperature_detected
    case lamp_alarm_high_humidity_detected
    case lamp_alarm_low_humidity_detected
    
    case hub_graph_temperature
    case hub_graph_humidity
    case lamp_graph_temperature
    case lamp_graph_humidity
}

extension NSURLRequest {
    #if DEBUG
    static func allowsAnyHTTPSCertificate(forHost host: String) -> Bool {
        return true
    }
    #endif
}

enum COLOR_TYPE
{
    case mint
    case lblGray
    case lblWhiteGray
    case green
    case _green_36_145_124
    case _green_76_191_169_05
    case red
    case _red_217_117_117
    case orange
    case _orange_244_167_119
    case warningRed
    case blue
    case _blue_13_97_164
    case _blue_71_88_144
    case lblDarkGray
    case purple
    case gaugeBlue
    case gaugeGreen
    case gaugeYellow
    case gaugeRed
    case backgroundGray
    case swEnableBG
    case swDisableBG
    case _black_35_35_35
    case _black_77_77_77
    case _gray_234_234_234
    case _gray_151_151_151_30
    case _brown_174_140_107
    case _brown_194_141_103
}

extension COLOR_TYPE {
    var color: UIColor {
        switch self {
        case .mint:
            return UIColor(red: 76/255.0, green: 191/255.0, blue: 169/255, alpha: 1.0)
        case .lblGray:
            return UIColor(red: 151/255.0, green: 151/255.0, blue: 151/255, alpha: 1.0)
        case .lblWhiteGray:
            return UIColor(red: 219/255.0, green: 220/255.0, blue: 220/255, alpha: 1.0)
        case .green:
            return UIColor(red: 79/255.0, green: 191/255.0, blue: 169/255, alpha: 1.0)
        case ._green_36_145_124:
            return UIColor(red: 36/255.0, green: 145/255.0, blue: 124/255, alpha: 1.0)
        case ._green_76_191_169_05:
            return UIColor(red: 76/255.0, green: 191/255.0, blue: 169/255, alpha: 0.5)
        case .blue:
            return UIColor(red: 97/255.0, green: 152/255.0, blue: 202/255, alpha: 1.0)
        case ._blue_13_97_164:
            return UIColor(red: 13/255.0, green: 97/255.0, blue: 164/255, alpha: 1.0)
        case ._blue_71_88_144:
            return UIColor(red: 71/255.0, green: 88/255.0, blue: 144/255, alpha: 1.0)
        case .red:
            return UIColor(red: 235/255.0, green: 123/255.0, blue: 111/255, alpha: 1.0)
        case ._red_217_117_117:
            return UIColor(red: 217/255.0, green: 117/255.0, blue: 117/255, alpha: 1.0)
        case .orange:
            return UIColor(red: 255/255.0, green: 146/255.0, blue: 78/255, alpha: 1.0)
        case ._orange_244_167_119:
            return UIColor(red: 244/255.0, green: 167/255.0, blue: 119/255, alpha: 1.0)
        case .lblDarkGray:
            return UIColor(red: 88/255.0, green: 88/255.0, blue: 88/255, alpha: 1.0)
        case .purple:
            return UIColor(red: 154/255.0, green: 128/255.0, blue: 185/255, alpha: 1.0)
        case .gaugeBlue:
            return UIColor(red: 97/255.0, green: 152/255.0, blue: 202/255, alpha: 1.0)
        case .gaugeGreen:
            return UIColor(red: 137/255.0, green: 209/255.0, blue: 103/255, alpha: 1.0)
        case .gaugeYellow:
            return UIColor(red: 249/255.0, green: 203/255.0, blue: 113/255, alpha: 1.0)
        case .gaugeRed:
            return UIColor(red: 235/255.0, green: 123/255.0, blue: 111/255, alpha: 1.0)
        case .backgroundGray:
            return UIColor(red: 249/255.0, green: 249/255.0, blue: 249/255, alpha: 1.0)
        case .swEnableBG:
            return UIColor(red: 76/255.0, green: 191/255.0, blue: 169/255, alpha: 1.0)
        case .swDisableBG:
            return UIColor(red: 76/255.0, green: 191/255.0, blue: 169/255, alpha: 0.5)
        case ._black_77_77_77:
            return UIColor(red: 77/255.0, green: 77/255.0, blue: 77/255, alpha: 1.0)
        case ._black_35_35_35:
            return UIColor(red: 35/255.0, green: 35/255.0, blue: 35/255, alpha: 1.0)
        case .warningRed:
            return UIColor(red: 237/255.0, green: 142/255.0, blue: 141/255, alpha: 1.0)
        case ._gray_234_234_234:
            return UIColor(red: 234/255.0, green: 234/255.0, blue: 234/255, alpha: 1.0)
        case ._gray_151_151_151_30:
            return UIColor(red: 151/255.0, green: 151/255.0, blue: 151/255, alpha: 0.3)
        case ._brown_174_140_107:
            return UIColor(red: 174/255.0, green: 140/255.0, blue: 107/255, alpha: 1.0)
        case ._brown_194_141_103:
            return UIColor(red: 194/255.0, green: 141/255.0, blue: 103/255, alpha: 1.0)
        }
    }
}

enum DEVICE_NOTI_TYPE: Int {
    case pee_detected = 1
    case poo_detected = 2
    case abnormal_detected = 3
    case diaper_changed = 4
    case fart_detected = 5
    case detect_diaper_changed = 6
    
    case move_detected = 8
    
    case low_temperature = 21
    case high_temperature = 22
    case low_humidity = 23
    case high_humidity = 24
    case voc_warning = 25
    
    case low_battery = 41
    case disconnected = 42
    case connected = 43
    case hub_types_disconnected = 44
    case hub_types_connected = 45
    case sensor_long_disconnected = 46
    
    case sleep_mode = 80
    
    case breast_milk = 91 // 모유
    case breast_feeding = 92 // 유축
    case feeding_milk = 93 // 분유
    case feeding_meal = 94 // 이유식
    
    case diaper_score = 110
    
    case custom_memo = 200
    case custom_status = 202
}

enum PUSH_TYPE: Int {
    case fcm = 0
    case pushy = 1
}

class Config {
    #if DEBUG // modifiable
    static let IS_LIVE_SERVER = true // dev 서버면 하기스는 https://mykbrand.stiscloudbonds.com 에서 진행해야함.
    static var DEBUG_PRINT_LEVEL: DEBUG_CONSOLE_PRINT_LEVEL = .all
    
    // prod
    static let MONIT_X_HUGGIES_OAUTH2_SIGNUP_URL: String = "http://yksso.co.kr/account/join?client_id=2&return_url=monitxhuggies%3a%2f%2f%3ffrom%3dyk&site_code=MONIT&state=demchk5hdk21"
    static let MONIT_X_HUGGIES_OAUTH2_SIGNIN_URL: String = "http://yksso.co.kr/login?client_id=2&return_url=monitxhuggies%3a%2f%2f%3ffrom%3dyk&site_code=MONIT&state=demchk5hdk21"
    static let MONIT_X_HUGGIES_OAUTH2_SIGNOUT_URL: String = "https://yksso.co.kr/api/v1/logout"
    
//    // dev
//    static let MONIT_X_HUGGIES_OAUTH2_SIGNUP_URL: String = "http://fo.qa.sso.euc.kr/account/join?client_id=2&return_url=monitxhuggies%3a%2f%2f%3ffrom%3dyk&site_code=MONIT&state=demchk5hdk21"
//    static let MONIT_X_HUGGIES_OAUTH2_SIGNIN_URL: String = "http://fo.qa.sso.euc.kr/login?client_id=2&return_url=monitxhuggies%3a%2f%2f%3ffrom%3dyk&site_code=MONIT&state=demchk5hdk21"
    static let IS_DEBUG = true
    #endif
    // QA 통합 SSO MO: https://qa1.m.ykbrand.co.kr 가입 테스트 주소.
    
    #if !DEBUG
    static let IS_LIVE_SERVER = true
    static var DEBUG_PRINT_LEVEL: DEBUG_CONSOLE_PRINT_LEVEL = .none

    // prod
    static let MONIT_X_HUGGIES_OAUTH2_SIGNUP_URL: String = "http://yksso.co.kr/account/join?client_id=2&return_url=monitxhuggies%3a%2f%2f%3ffrom%3dyk&site_code=MONIT&state=demchk5hdk21"
    static let MONIT_X_HUGGIES_OAUTH2_SIGNIN_URL: String = "http://yksso.co.kr/login?client_id=2&return_url=monitxhuggies%3a%2f%2f%3ffrom%3dyk&site_code=MONIT&state=demchk5hdk21"
    static let MONIT_X_HUGGIES_OAUTH2_SIGNOUT_URL: String = "https://yksso.co.kr/api/v1/logout"
    static let IS_DEBUG = false
    #endif
    static let DEFAULT_WEB_PROTOCAL: String = "https://"
    
    static var DEFAULT_WEB_URL: String {
        get {
            if (IS_LIVE_SERVER) {
                switch channel {
                case .goodmonit:
                    return "monitservice.goodmonit.com"
                case .monitXHuggies:
                    return "monitservice.goodmonit.com"
                case .kc:
                    return  "huggiesxmonit.goodmonit.com" // "monitkcdev.azurewebsites.net"
                case .kao:
                    return "monitservice.goodmonit.com"
                }
            } else {
                switch channel {
                case .goodmonit:
                    return "monitdev.azurewebsites.net"
                case .monitXHuggies:
                    return "monitdev.azurewebsites.net"
                case .kc:
                    return  "monitkcdev.azurewebsites.net"
                case .kao:
                    return "monitdev.azurewebsites.net"
                }
            }
        }
    }
    
//    static let DEFAULT_WEB_URL: String = IS_LIVE_SERVER ? "monit.azurewebsites.net" : "monitdev.azurewebsites.net"
    static let WEB_URL : String = DEFAULT_WEB_PROTOCAL + DEFAULT_WEB_URL + "/app"
    static let APP_DATA_WEB_URL : String = DEFAULT_WEB_PROTOCAL + DEFAULT_WEB_URL + "/app/start"
    static let WEB_ETC_URL: String = "https://website.goodmonit.com"
    
    // terms 서비스 이용 약관
    // privacy 개인 정보 처리 방침
    
    // 해외
    static let TERMS_URL: String = WEB_ETC_URL + "/legal/service/" + Config.languageType.rawValue
    static let PRIVACY_URL: String = WEB_ETC_URL + "/legal/privacy/" + Config.languageType.rawValue
    static let PRIVACY_GDPR_URL: String = WEB_ETC_URL + "/legal/privacy/gdpr"
    static let WARRANTY_URL: String = WEB_ETC_URL + "/legal/warranty/" + Config.languageType.rawValue
    
    // 국내
    static var HUGGIES_TERMS_URL: String = WEB_ETC_URL + "/legal/service/" + Config.languageType.rawValue
    static var HUGGIES_PRIVACY_URL: String = WEB_ETC_URL + "/legal/privacy/" + Config.languageType.rawValue
    static var HUGGIES_WARRANTY_URL: String = WEB_ETC_URL + "/legal/warranty/" + Config.languageType.rawValue
    static var HUGGIES_COLLECT_URL: String = WEB_ETC_URL + "/legal/collect/" + Config.languageType.rawValue
    static var HUGGIES_THIRDPARTY_URL: String = WEB_ETC_URL + "/legal/disclosure3rdparty/" + Config.languageType.rawValue
    
    // kc
    static var KC_TERMS_URL: String = "https://www.huggies.com/en-us/HuggiesxMonit/terms-and-conditions"
    static var KC_PRIVACY_URL: String = "https://www.huggies.com/en-us/HuggiesxMonit/privacy-policy"
    static var KC_SUPPORT_URL: String = "https://www.huggies.com/en-us/HuggiesxMonit/support-faqs/"
    
    // kao
    static var KAO_TERMS_URL: String = "https://m.goodmonit.co.kr/monit_legal/baby_service_en.html#enp_mbris"
    static var KAO_PRIVACY_URL: String = "https://m.goodmonit.co.kr/monit_legal/baby_privacy_en.html"
    static var KAO_PRIVACY_GDPR_URL: String = "https://m.goodmonit.co.kr/monit_legal/baby_privacy_en_gdpr.html#enp_mbris"
    static var KAO_THIRDPARTY_URL: String = "https://m.goodmonit.co.kr/monit_legal/baby_3rdparty_disclosure_kao.html#enp_mbris"
    
    static var SUPPORT_URL: String = WEB_ETC_URL + "/support/support/" + Config.languageType.rawValue
    static var BOARD_DEFAULT_URL: String = WEB_ETC_URL + "/Board/"
    static var BOARD_DEFAULT_DEV_URL: String = "https://monitetcservicedev.azurewebsites.net/Board/"
    
    
    static let OS = 2

    static let MONIT_YK_LOGIN_URL: String = DEFAULT_WEB_PROTOCAL + DEFAULT_WEB_URL + "/yk/login"
    static let WEB_URL_YK_SIGNIN: String = DEFAULT_WEB_PROTOCAL + DEFAULT_WEB_URL + "/app"
    
    static let FONT_NotoSans: String = "NotoSansCJKkr-Regular"
    static let DATE_INIT: String = "700101-000000"
    
    #if FCM
    static let IS_FCM: Bool = true
    #else
    static let IS_FCM: Bool = false
    #endif
    
    static var IS_AVOBE_OS13: Bool {
        get {
            if #available(iOS 13.0, *) {
                return true
            }
            return false
        }
    }
    
    static var oldDate3: Date {
        get {
            return NSDate(timeIntervalSinceNow: TimeInterval(-86400 * 3)) as Date
        }
    }
    
    static var oldDate7: Date {
        get {
            return NSDate(timeIntervalSinceNow: TimeInterval(-86400 * 7)) as Date
        }
    }
    
    static var bundleIdentifier: String {
        get {
            if let version = Bundle.main.infoDictionary?["CFBundleIdentifier"] as? String {
                return version
            }
            return ""
        }
    }
    
    static var bundleIdentifierType: BundleIdentifierType {
        get {
            if let _type = BundleIdentifierType(rawValue: bundleIdentifier) {
                return _type
            }
            return .none
        }
    }
    
    static var appStoreUrl: String {
        get {
            switch Config.bundleIdentifierType {
            case .goodmonit: return "itms-apps://itunes.apple.com/app/id1290625994"
            case .huggies: return "itms-apps://itunes.apple.com/app/id1336308361"
            case .kc: return "itms-apps://itunes.apple.com/app/id1448340598"
            case .kao: return "itms-apps://itunes.apple.com/app/id"
            default: return "itms-apps://itunes.apple.com/app/id1290625994"
            }

//            return "itms-beta://itunes.apple.com/app/id1290625994"
        }
    }
    
    static var bundleID: String {
        get {
            switch Config.bundleIdentifierType {
            case .goodmonit: return "1290625994"
            case .huggies: return "1336308361"
            case .kc: return "1448340598"
            case .kao: return "?"
            default: return "1290625994"
            }
        }
    }
    
    static var channelOsNum: Int {
        get {
            switch Config.bundleIdentifierType {
            case .goodmonit:
                return ChannelOSType.goodmonit_ios.rawValue
            case .huggies:
                return ChannelOSType.monitxhuggies_ios.rawValue
            case .kc:
                return ChannelOSType.kc_ios.rawValue
            case .kao:
                return ChannelOSType.kao_ios.rawValue
            default:
                return ChannelOSType.goodmonit_ios.rawValue
            }
        }
    }
    
    static var channel: CHANNEL_TYPE {
        get {
            switch Config.bundleIdentifierType {
            case BundleIdentifierType.goodmonit:
                return .goodmonit
            case BundleIdentifierType.huggies:
                return .monitXHuggies
            case BundleIdentifierType.kc:
                return .kc
            case BundleIdentifierType.kao:
                return .kao
            default:
                return .goodmonit
            }
        }
    }
    

    static var bundleVersion: String {
        get {
            if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                return version
            }
            return ""
        }
    }
    
    static var debugBundleVersion: String {
        get {
            var _retValue = ""
            if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                _retValue += version
            }
            if let version = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
                _retValue += "(\(version))"
            }
            return _retValue
        }
    }

    static var lang: String {
        get {
            if let _regionCode = Locale.current.regionCode {
                Debug.print("System Region Code: \(_regionCode)", event: .warning)
            }
            if let _languageCode = Locale.current.languageCode {
                Debug.print("System Language Code: \(_languageCode)", event: .warning)
            }
            return Locale.current.languageCode!
        }
    }
    
    static var languageType: LANGUAGE_TYPE {
        get {
            if let _lang = LANGUAGE_TYPE(rawValue: lang) {
                return _lang
            } else {
                return .en
            }
        }
    }
    
    static let MAX_BYTE_LENGTH_NAME = 24
    static let MIN_PASSWORD_LENGTH = 8
    static let MAX_PASSWORD_LENGTH = 64
    
    static let FULL_STATUS_TIME: Double = 600
    static let STATUS_TIME: Double = 10
    static let SCAN_INTERVAL_TIME: Double = 10
    static let SCANNING_TIME: Double = 1
    static let SENSOR_REGIST_WAIT_TIME: Double = 5
    static let WIFI_REGIST_WAIT_TIME: Double = 30
    static let HUB_TYPES_GRAPH_UPDATE_LIMIT: Double = 300.0
    static let SENSOR_MOV_GRAPH_UPDATE_LIMIT: Double = 60.0
    static let HUB_TYPES_INIT_WAIT_TIME: Double = 20
    
    static let NETWORK_MANAGER_REQUEST_TIMEOUT: Double = 10
    static let NETWORK_MANAGER_RESEDNING_COUNT: Int = 3
    
    static let NOTCH_HEIGHT_PADDING: CGFloat = 17
    
    static let SENSOR_FIRMWARE_LIMIT_OS_VERSION: String = "9.0"
    static let SENSOR_FIRMWARE_LIMIT_BATTERY: Int  = 3000
    static let SENSOR_FIRMWARE_SCAN_TIMEOUT: Double = 8.0
    static let SENSOR_FIRMWARE_SCAN_INTERVAL: Double = 0.5
    static let SENSOR_FIRMWARE_LIMIT_UPDATE_VERSION: String = "0.4.0" // 해당값 이상 버전만 가능
    static let SENSOR_FIRMWARE_LIMIT_SENSITIVE_VERSION: String = "1.0.4" // 해당값 이상 버전만 가능
    static let SENSOR_FIRMWARE_LIMIT_HEATING_VERSION: String = "1.4.0" // 해당값 이상 버전만 가능
    static let SENSOR_FIRMWARE_LIMIT_AUTO_POLLING_VERSION: String = "1.3.5" // 해당값 이상 버전만 가능
    static let SENSOR_AUTO_POLLING_SENDING_TIME: Int = 30
    static let HUB_TYPES_BRIGHT_CONTROLLER_AVAILABLE_SERIAL: [String] = ["HKM", "HKU"]
    static let HUB_TYPES_BRIGHT_CONTROLLER_AVAILABLE_VER: String = "1.3.0"
    
    static let SENSOR_ADV_NAME: String = "MONIT_Diaper"
    static let LAMP_ADV_NAME: String = "MONIT_Lamp"
    
    static let NUGU_APPSTORE: String = "itms-apps://itunes.apple.com/app/id1142864065"
    static let ASSISTANT_APPSTORE: String = "itms-apps://itunes.apple.com/app/id1220976145"
    static let ASSISTANT_LINK_URL: String = "https://assistant.google.com/services/invoke/uid/00000058d7533117?intent=actions.intent.MAIN"
    
    static let SLEEP_VALUE: Int = 13
}
