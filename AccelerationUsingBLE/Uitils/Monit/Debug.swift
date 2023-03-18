//
//  Debug.swift
//  Monit
//
//  Created by 맥 on 2017. 8. 24..
//  Copyright © 2017년 맥. All rights reserved.
//

#if GOODMONIT || HUGGIES || KC
import FirebaseCrashlytics
#endif

class Debug {
    private struct Args: CustomStringConvertible, CustomDebugStringConvertible {
        let args: [Any]
        let separator: String
        var description: String {
            return args.map { "\($0)" }.joined(separator: separator)
        }
        var debugDescription: String {
            return args
                .map { ($0 as? CustomDebugStringConvertible)?.debugDescription ?? "\($0)" }
                .joined(separator: separator)
        }
    }
    
    #if !GOODMONIT && !HUGGIES && !KC
    class func print(_ items: Any..., event: LOG_EVENT = .normal, separator: String = " ", terminator: String = "\n",
                     file: StaticString = #file,
                     function: StaticString = #function,
                     line: Int = #line)
    {
        let output = "\(file).\(function) line \(line)"
        
        // console logging
        switch Config.DEBUG_PRINT_LEVEL {
        case .all:
            switch event {
            case .dev: Swift.print("\(items)") // Swift.print(Args(args: items, separator: separator), separator: separator, terminator: terminator)
            case .normal: Swift.print("\(items)") // Swift.print(Args(args: items, separator: separator), separator: separator, terminator: terminator)
            case .warning: Swift.print("\(items)") // Swift.print(Args(args: items, separator: separator), separator: separator, terminator: terminator)
            case .error: Swift.print("[❗️] \(items) $ \(output)")
            }
        case .normal:
            switch event {
            case .normal: Swift.print("\(items)")  // Swift.print(Args(args: items, separator: separator), separator: separator, terminator: terminator)
            case .warning: Swift.print("\(items)")  // Swift.print(Args(args: items, separator: separator), separator: separator, terminator: terminator)
            case .error: Swift.print("[❗️] \(items) $ \(output)")
            default: break
            }
        case .warning:
            switch event {
            case .warning: Swift.print("\(items)") // Swift.print(Args(args: items, separator: separator), separator: separator, terminator: terminator)
            case .error: Swift.print("[❗️] \(items) $ \(output)")
            default: break
            }
        case .error:
            switch event {
            case .error: Swift.print("[❗️] \(items) $ \(output)")
            default: break
            }
        case .none: break
        }
    }
    #else

    class func print(_ items: Any..., event: LOG_EVENT = .normal, separator: String = " ", terminator: String = "\n",
                     file: StaticString = #file,
                     function: StaticString = #function,
                     line: Int = #line)
    {
        let output: String
        if let filename = URL(string: String(describing: file))?.lastPathComponent.components(separatedBy: ".").first {
            output = "\(filename).\(function) line \(line)"
        } else {
            output = "\(file).\(function) line \(line)"
        }
        
        // firebase logging
        switch event {
        case .normal: break
        case .warning: Crashlytics.crashlytics().log(output)
        case .error: Crashlytics.crashlytics().log(output)
        case .dev: break
        }
        
        // write logging
        #if DEBUG
        switch event {
        case .normal: break
        case .warning: ReportManager.instance.write("\(items)")
        case .error: ReportManager.instance.write("[❗️] \(items) $ \(output)")
        case .dev: break
        }
        #else
        if (DataManager.instance.m_userInfo.configData.isMonitoring) {
            switch event {
            case .normal: ReportManager.instance.write(items)
            case .warning: ReportManager.instance.write("\(items)")
            case .error: ReportManager.instance.write("[❗️] \(items) $ \(output)")
            case .dev: break
            }
        }
        #endif
        
        // console logging
        switch Config.DEBUG_PRINT_LEVEL {
        case .all:
            switch event {
            case .dev: Swift.print("\(UI_Utility.nowTime):\(items)") // Swift.print(Args(args: items, separator: separator), separator: separator, terminator: terminator)
            case .normal: Swift.print("\(UI_Utility.nowTime):\(items)") // Swift.print(Args(args: items, separator: separator), separator: separator, terminator: terminator)
            case .warning: Swift.print("\(UI_Utility.nowTime):\(items)") // Swift.print(Args(args: items, separator: separator), separator: separator, terminator: terminator)
            case .error: Swift.print("\(UI_Utility.nowTime):[❗️] \(items) $ \(output)")
            }
        case .normal:
            switch event {
            case .normal: Swift.print("\(UI_Utility.nowTime):\(items)")  // Swift.print(Args(args: items, separator: separator), separator: separator, terminator: terminator)
            case .warning: Swift.print("\(UI_Utility.nowTime):\(items)")  // Swift.print(Args(args: items, separator: separator), separator: separator, terminator: terminator)
            case .error: Swift.print("\(UI_Utility.nowTime)[❗️] \(items) $ \(output)")
            default: break
            }
        case .warning:
            switch event {
            case .warning: Swift.print("\(UI_Utility.nowTime):\(items)") // Swift.print(Args(args: items, separator: separator), separator: separator, terminator: terminator)
            case .error: Swift.print("\(UI_Utility.nowTime)[❗️] \(items) $ \(output)")
            default: break
            }
        case .error:
            switch event {
            case .error: Swift.print("\(UI_Utility.nowTime)[❗️] \(items) $ \(output)")
            default: break
            }
        case .none: break
        }
    }
    #endif
}
