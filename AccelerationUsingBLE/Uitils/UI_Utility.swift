//
//  UI_Utility.swift
//  AccelerationUsingBLE
//
//  Created by 모상현 on 2023/03/17.
//
import Foundation
import UIKit

class UI_Utility : UIView {
    static func checkMaxLength(textField: UITextField!, maxLength: Int) {
        if (textField.text!.count > maxLength) {
            textField.deleteBackward()
        }
    }
    
    static func checkMaxByte(textField: UITextField!, maxLength: Int) {
        let _buf = [UInt8](textField.text!.utf8)
        if (_buf.count > maxLength) {
            textField.deleteBackward()
        }
    }
    
    static func isContainString(data: String, character: String) -> Bool
    {
        if data.contains(character) {
            return true
        }
        
        return false
    }
    
    static func matches(for regex: String, in text: String) -> [String] {
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let nsString = text as NSString
            let results = regex.matches(in: text, range: NSRange(location: 0, length: nsString.length))
            return results.map { nsString.substring(with: $0.range)}
        } catch let error {
            Debug.print("invalid regex: \(error.localizedDescription)", event: .warning)
            return []
        }
    }
    
    static func textUnderline(_ txtLabel: UILabel?)
    {
        let text = txtLabel?.text
        let textRange = NSMakeRange(0, (text?.count)!)
        let attributedText = NSMutableAttributedString(string: text!)
        attributedText.addAttribute(NSAttributedString.Key.underlineStyle , value: NSUnderlineStyle.single.rawValue, range: textRange)
        // Add other attributes if needed
        txtLabel?.attributedText = attributedText
    }
    
    static func interpolate(source: UIColor, target: UIColor, percent: CGFloat) -> UIColor
    {
        let _source = source.components
        let _target = target.components
        
        let r = (_source.red + (_target.red - _source.red) * percent);
        let g = (_source.green + (_target.green - _source.green) * percent);
        let b = (_source.blue + (_target.blue - _source.blue) * percent);
        
        return UIColor(red: r, green: g, blue: b, alpha: 1.0)
    }
    
    // Convert from F to C (Double)
    static func fahrenheitToCelsius(tempInF:Double) ->Double {
        let _value = (tempInF - 32) * 10.0 / 18.0
        return (Double(Int(_value * 10)) / 10.0) as Double
    }
    
    // Convert from C to F (Integer)
    static func celsiusToFahrenheit(tempInC:Double) ->Double {
        let _value = tempInC * 1.8 + 32
        return (Double(Int(_value * 10)) / 10.0) as Double
    }
    
    static func customButtonBorder(button: UIButton, radius: CGFloat, width: CGFloat, color: CGColor) {
        button.layer.cornerRadius = radius
        button.layer.borderWidth = width
        button.layer.borderColor = color
    }
    
    static func customViewBorder(view: UIView, radius: CGFloat, width: CGFloat, color: CGColor) {
        view.layer.cornerRadius = radius
        view.layer.borderWidth = width
        view.layer.borderColor = color
    }
    
    static func customButtonShadow(button: UIButton?, radius: CGFloat, offsetWidth: CGFloat, offsetHeight: CGFloat, color: CGColor, opacity: Float) {
        button?.layer.shadowColor = color
        button?.layer.shadowOffset = CGSize(width: offsetWidth, height: offsetHeight)
        button?.layer.shadowRadius = radius
        button?.layer.shadowOpacity = opacity
    }
    
    static func customViewShadow(view: UIView, radius: CGFloat, offsetWidth: CGFloat, offsetHeight: CGFloat, color: CGColor, opacity: Float) {
        view.layer.shadowColor = color
        view.layer.shadowOffset = CGSize(width: offsetWidth, height: offsetHeight)
        view.layer.shadowRadius = radius
        view.layer.shadowOpacity = opacity
    }
    
    static func customButtonScaleAspectFit(button: UIButton?) {
        button?.contentMode = .scaleAspectFit
    }
    
    static func multiAttributedLabel(label: UILabel, arrAttributed: [LabelAttributed]) {
        let _arrAttributed = NSMutableAttributedString()
        for item in arrAttributed {
            _arrAttributed.append(item.attributedString)
        }
        label.attributedText = _arrAttributed
    }
    
    // utc to utc
    static func getDateByLanguageFromString(_ date: String, fromType: DATE_TYPE, language: LANGUAGE_TYPE) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = fromType.rawValue
        
        let date = dateFormatter.date(from: date)
        switch language {
        case .ko:
            dateFormatter.dateFormat = DATE_TYPE.yyyy_MM_dd.rawValue
            break
        case .jp:
            dateFormatter.dateFormat = DATE_TYPE.dd_MM_yyyy.rawValue
            break
        case .zh:
            dateFormatter.dateFormat = DATE_TYPE.dd_MM_yyyy.rawValue
            break
        case .en:
            dateFormatter.dateFormat = DATE_TYPE.MMM_dd_yyyy.rawValue
            break
        default:
            dateFormatter.dateFormat = DATE_TYPE.MMM_dd_yyyy.rawValue
            break
        }
        
        return  dateFormatter.string(from: date!)
    }
    
    // utc to local
    static func getDateByLanguageFromDate(_ date: Date, language: LANGUAGE_TYPE) -> String {
        let dateFormatter = DateFormatter()

        switch language {
        case .ko:
            dateFormatter.dateFormat = DATE_TYPE.yyyy_MM_dd.rawValue
            break
        case .jp:
            dateFormatter.dateFormat = DATE_TYPE.dd_MM_yyyy.rawValue
            break
        case .zh:
            dateFormatter.dateFormat = DATE_TYPE.dd_MM_yyyy.rawValue
            break
        case .en:
            dateFormatter.dateFormat = DATE_TYPE.MMM_dd_yyyy.rawValue
            break
        default:
            dateFormatter.dateFormat = DATE_TYPE.MMM_dd_yyyy.rawValue
            break
        }
        
        return  dateFormatter.string(from: date)
    }
    
    static func convertDateStringToString(_ date: String, fromType: DATE_TYPE, toType: DATE_TYPE) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = fromType.rawValue
        
        let date = dateFormatter.date(from: date)
        dateFormatter.dateFormat = toType.rawValue
        return  dateFormatter.string(from: date!)
    }
    
    // 요청한 시간을 utc시간으로 표현한다.
    static func convertStringToDate(_ date: String, type: DATE_TYPE) -> Date? {
        let formatter = DateFormatter()
        
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        formatter.dateFormat = type.rawValue
        //        Debug.print("\(date), \(formatter.date(from: date))")
        return formatter.date(from: date)
    }
    
    // 요청한 시간을 local 시간으로 표현한다.
    static func convertStringToLocalDate(_ date: String, type: DATE_TYPE) -> Date? {
        let formatter = DateFormatter()
        
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = type.rawValue
        //        Debug.print("\(date), \(formatter.date(from: date))")
        return formatter.date(from: date)
    }
    
    // date -> string으로 바꿀때 단순히 텍스트로 변경되는게 아니고 localTime -> utc로 바뀌어서 다르게 나올 수 있으니 주의한다.
    // utc -> utc로 나옴.
    static func convertDateToString(_ date: Date, type: DATE_TYPE) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.dateFormat = type.rawValue
        let dateString = dateFormatter.string(from:date)
        return dateString
    }
    
    static var nowYYMMD: String {
        get {
            let _date = Date().description
            
            let _yyRange = _date.index(_date.startIndex, offsetBy: 2)..<_date.index(_date.endIndex, offsetBy: -21)
            let _yy = String(_date[_yyRange])
            
            let _mmRange = _date.index(_date.startIndex, offsetBy: 5)..<_date.index(_date.endIndex, offsetBy: -18)
            let _mm = String(_date[_mmRange])
            
            let _ddRange = _date.index(_date.startIndex, offsetBy: 8)..<_date.index(_date.endIndex, offsetBy: -15)
            let _dd = String(_date[_ddRange])
            return "\(_yy)\(_mm)\(_dd)"
        }
    }
    
    static var nowTime: String {
        get {
            let _date = Date().description
            let start = _date.index(_date.startIndex, offsetBy: 8)
            let end = _date.index(_date.endIndex, offsetBy: -6)
            let range = start..<end
            return String(_date[range])
        }
    }
    
    //formatter 비용 비싸다. 필요할때만 쓸것 주의!
    // ltime
    static func nowLocalDate(type: DATE_TYPE) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = type.rawValue
        return dateFormatter.string(from: NSDate() as Date)
    }
    
    static func nowUTCDate(type: DATE_TYPE) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.dateFormat = type.rawValue
        return dateFormatter.string(from: NSDate() as Date)
    }
    
    static func localToUTC(date:String, fromType: DATE_TYPE = .full, toType: DATE_TYPE = .full) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = fromType.rawValue
        dateFormatter.calendar = NSCalendar.current
        dateFormatter.timeZone = TimeZone.current
        
        let dt = dateFormatter.date(from: date)
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.dateFormat = toType.rawValue
        
        return dateFormatter.string(from: dt!)
    }
    
    static func UTCToLocal(date:String, fromType: DATE_TYPE = .full, toType: DATE_TYPE = .full) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = fromType.rawValue
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        let dt = dateFormatter.date(from: date)
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = toType.rawValue
        
        return dateFormatter.string(from: dt!)
    }
    
    static func getDateToSliceDate(date: Date) -> (Int, Int, Int, Int, Int, Int) {
        let _date = date.description
        
        let _yyRange = _date.index(_date.startIndex, offsetBy: 2)..<_date.index(_date.endIndex, offsetBy: -21)
        let _yy = Int(_date[_yyRange]) ?? 0
        
        let _mmRange = _date.index(_date.startIndex, offsetBy: 5)..<_date.index(_date.endIndex, offsetBy: -18)
        let _mm = Int(_date[_mmRange]) ?? 0
        
        let _ddRange = _date.index(_date.startIndex, offsetBy: 8)..<_date.index(_date.endIndex, offsetBy: -15)
        let _dd = Int(_date[_ddRange]) ?? 0
        
        let _hhRange = _date.index(_date.startIndex, offsetBy: 11)..<_date.index(_date.endIndex, offsetBy: -12)
        let _hh = Int(_date[_hhRange]) ?? 0
        
        let _minuteRange = _date.index(_date.startIndex, offsetBy: 14)..<_date.index(_date.endIndex, offsetBy: -9)
        let _minute = Int(_date[_minuteRange]) ?? 0
        
        let _ssRange = _date.index(_date.startIndex, offsetBy: 17)..<_date.index(_date.endIndex, offsetBy: -6)
        let _ss = Int(_date[_ssRange]) ?? 0
        
        return (_yy, _mm, _dd, _hh, _minute, _ss)
    }
    
    static func getDateToSliceDateString(date: String = "") -> (Int, Int, Int, Int, Int, Int) {
        let _date = date
        
        let _yyRange = _date.index(_date.startIndex, offsetBy: 2)..<_date.index(_date.endIndex, offsetBy: -15)
        let _yy = Int(_date[_yyRange]) ?? 0
        
        let _mmRange = _date.index(_date.startIndex, offsetBy: 5)..<_date.index(_date.endIndex, offsetBy: -12)
        let _mm = Int(_date[_mmRange]) ?? 0
        
        let _ddRange = _date.index(_date.startIndex, offsetBy: 8)..<_date.index(_date.endIndex, offsetBy: -9)
        let _dd = Int(_date[_ddRange]) ?? 0
        
        let _hhRange = _date.index(_date.startIndex, offsetBy: 11)..<_date.index(_date.endIndex, offsetBy: -6)
        let _hh = Int(_date[_hhRange]) ?? 0
        
        let _minuteRange = _date.index(_date.startIndex, offsetBy: 14)..<_date.index(_date.endIndex, offsetBy: -3)
        let _minute = Int(_date[_minuteRange]) ?? 0
        
        let _ssRange = _date.index(_date.startIndex, offsetBy: 17)..<_date.index(_date.endIndex, offsetBy: 0)
        let _ss = Int(_date[_ssRange]) ?? 0
        
        return (_yy, _mm, _dd, _hh, _minute, _ss)
    }
    
    static func getTimeDiff(fromDate: Date, toDate: Date) -> DateComponents {
        return Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: fromDate, to: toDate)
    }
}

class LabelAttributed {
    var attributedString: NSMutableAttributedString
    
    init (labelValue: String, attributed: [NSAttributedString.Key : Any]) {
        self.attributedString = NSMutableAttributedString(string:  labelValue, attributes: attributed)
    }
}

class UnderlinedLabel: UILabel {
    override var text: String? {
        didSet {
            guard let text = text else { return }
            let textRange = NSMakeRange(0, text.count)
            let attributedText = NSMutableAttributedString(string: text)
            attributedText.addAttribute(NSAttributedString.Key.underlineStyle , value: NSUnderlineStyle.single.rawValue, range: textRange)
            // Add other attributes if needed
            self.attributedText = attributedText
        }
    }
}

extension UIView {
    class func fromNib<T: UIView>() -> T {
        return Bundle.main.loadNibNamed(String(describing: T.self), owner: nil, options: nil)![0] as! T
    }
    
    func copyView<T: UIView>() -> T {
        return NSKeyedUnarchiver.unarchiveObject(with: NSKeyedArchiver.archivedData(withRootObject: self)) as! T
    }
}

extension UIButton {
    func setTitleWithOutAnimation(title: String?) {
        UIView.setAnimationsEnabled(false)
        
        setTitle(title, for: .normal)
        
        layoutIfNeeded()
        UIView.setAnimationsEnabled(true)
    }
}

extension UIColor {
    var coreImageColor: CIColor {
        return CIColor(color: self)
    }
    var components: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        let coreImageColor = self.coreImageColor
        return (coreImageColor.red, coreImageColor.green, coreImageColor.blue, coreImageColor.alpha)
    }
}

extension UILabel {
    
    func setLineSpacing(lineSpacing: CGFloat = 0.0, lineHeightMultiple: CGFloat = 0.0) {
        
        guard let labelText = self.text else { return }
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacing
        paragraphStyle.lineHeightMultiple = lineHeightMultiple
        
        let attributedString:NSMutableAttributedString
        if let labelattributedText = self.attributedText {
            attributedString = NSMutableAttributedString(attributedString: labelattributedText)
        } else {
            attributedString = NSMutableAttributedString(string: labelText)
        }
        
        // (Swift 4.2 and above) Line spacing attribute
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))
        
        
        // (Swift 4.1 and 4.0) Line spacing attribute
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))
        
        self.attributedText = attributedString
    }
}

extension UITextField {
    func addDoneCancelToolbar(doneString: String, cancelString: String? = nil, onDone: (target: Any, action: Selector)? = nil, onCancel: (target: Any, action: Selector)? = nil) {
        let onCancel = onCancel ?? (target: self, action: #selector(cancelButtonTapped))
        let onDone = onDone ?? (target: self, action: #selector(doneButtonTapped))

        let toolbar: UIToolbar = UIToolbar()
        toolbar.barStyle = .default
        toolbar.items = [
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil),
            UIBarButtonItem(title: doneString, style: .plain, target: onDone.target, action: onDone.action)
        ]
        
        if (cancelString != nil) {
            toolbar.items?.append(UIBarButtonItem(title: cancelString, style: .done, target: onCancel.target, action: onCancel.action))
        }
        toolbar.sizeToFit()

        self.inputAccessoryView = toolbar
    }

    // Default actions:
    @objc func doneButtonTapped() { self.resignFirstResponder() }
    @objc func cancelButtonTapped() { self.resignFirstResponder() }
}
