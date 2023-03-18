//
//  Debug.swift
//  AccelerationUsingBLE
//
//  Created by 모상현 on 2023/03/17.
//

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
}
