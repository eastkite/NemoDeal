//
//  Log.swift
//  modoohotdeal
//
//  Created by baedy on 2020/01/03.
//  Copyright © 2020 baedy. All rights reserved.
//

import Foundation

struct Log {
    
    typealias WriteHandler = (Log.Level, String, String, Int, Any?, DispatchQueue?) -> Void
    
    fileprivate static let timeFormat = DateFormatter().then { $0.dateFormat = "HH:mm:ss.SSS" }
    
    fileprivate static let consoleQueue = DispatchQueue(label: "console-log-queue")
    fileprivate static let fileoutQueue = DispatchQueue(label: "file-log-queue")
    
    static let _fileName = "HotDeal_Log.txt"
    
    static let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        .appendingPathComponent(Log._fileName)
    
    fileprivate static let writeConsole: WriteHandler = { level, file, function, line, message, queue in
        let execute: () -> Void = {
            let className = file.substring(to: file.index(file.reversed().index(of: ".")!.base, offsetBy: -1))
            var log = String()
            if let message = message {
                log = "\(className).\(function):\(line) - \(message)"
            } else {
                log = "\(className).\(function):\(line)"
            }
            print("\(Log.timeFormat.string(from: Date())) \(level.consoleSymbol) \(log)")
        }
        if let queue = queue {
            queue.async(execute: execute)
        } else {
            execute()
        }
    }
    
    fileprivate static let writeFile: WriteHandler = { level, file, function, line, message, queue in
        if let queue = queue {
            queue.async {
                let className = file.substring(to: file.index(file.reversed().index(of: ".")!.base, offsetBy: -1))
                var log = String()
                if let message = message {
                    log = "\(className).\(function):\(line) - \(message)"
                } else {
                    log = "\(className).\(function):\(line)"
                }
                
                let logText = "\(Log.timeFormat.string(from: Date())) \(level.consoleSymbol) \(log)"
                
                do {
                    let displayText = "\(logText) \n".data(using: String.Encoding.utf8)
                    if let fileHandle = FileHandle(forWritingAtPath: fileURL.path) {
                        defer {
                            fileHandle.closeFile()
                        }
                        fileHandle.seekToEndOfFile()
                        fileHandle.write(displayText!)
                    }
                    else {
                        try logText.write(toFile: fileURL.path, atomically: false, encoding: String.Encoding.utf8);
                    }
                }catch {}
            }
        }
    }
    
    static var isEnabledConsole = true
    static var isEnabledFile    = false
    
    fileprivate enum Destination {
        case console
        case file
        
        func write(_ level: Log.Level, _ file: String, _ function: String, _ line: Int, _ message: Any? = nil) -> Void {
            switch self {
            case .console where level == .debug || level == .error:
                Log.writeConsole(level, (file as NSString).lastPathComponent, function, line, message, nil)
            case .console:
                Log.writeConsole(level, (file as NSString).lastPathComponent, function, line, message, Log.consoleQueue)
            case .file:
                Log.writeFile(level, (file as NSString).lastPathComponent, function, line, message, Log.fileoutQueue)
            }
        }
    }
    
    enum Level {
        case verbose
        case debug
        case info
        case warning
        case error
        
        var consoleSymbol: String {
            switch self {
            case .verbose:  return "💬"
            case .debug:    return "ℹ️"
            case .info:     return "✅"
            case .warning:  return "⚠️"
            case .error:    return "❌"
            }
        }
        
        var fileSymbol: String {
            switch self {
            case .verbose:  return "V"
            case .debug:    return "D"
            case .info:     return "I"
            case .warning:  return "W"
            case .error:    return "E"
            }
        }
    }
    
}

extension Log {
    
    /// 호출 된 곳의 함수명을 출력
    ///
    /// - Parameter
    ///   - file:     파일명
    ///   - function: 함수명
    ///   - line:     라인
    static func trace(file: String = #file, _ function: String = #function, _ line: Int = #line) {
        #if DEBUG
        Log.Destination.console.write(.verbose, file, function, line, nil)
        #endif
    }
    
    /// 주어진 메세지를 verbose 타입으로 출력
    ///
    /// - Parameter
    ///   - message:  출력할 메세지
    ///   - file:     파일명
    ///   - function: 함수명
    ///   - line:     라인
    static func v(_ message: @autoclosure () -> Any, _ file: String = #file, _ function: String = #function, _ line: Int = #line) {
        #if DEBUG
        Log.Destination.console.write(.verbose, file, function, line, message())
        #endif
    }
    
    /// 주어진 메세지를 debug 타입으로 출력
    ///
    /// - Parameter
    ///   - message:  출력할 메세지
    ///   - file:     파일명
    ///   - function: 함수명
    ///   - line:     라인
    static func d(_ message: @autoclosure () -> Any, _ file: String = #file, _ function: String = #function, _ line: Int = #line) {
        #if DEBUG
        Log.Destination.console.write(.debug, file, function, line, message())
        #endif
    }
    
    /// 주어진 메세지를 info 타입으로 출력
    ///
    /// - Parameter
    ///   - message:  출력할 메세지
    ///   - file:     파일명
    ///   - function: 함수명
    ///   - line:     라인
    static func i(_ message: @autoclosure () -> Any, _ file: String = #file, _ function: String = #function, _ line: Int = #line) {
        #if DEBUG
        Log.Destination.console.write(.info, file, function, line, message())
        #endif
    }
    
    /// 주어진 메세지를 warning 타입으로 출력
    ///
    /// - Parameter
    ///   - message:  출력할 메세지
    ///   - file:     파일명
    ///   - function: 함수명
    ///   - line:     라인
    static func w(_ message: @autoclosure () -> Any, _ file: String = #file, _ function: String = #function, _ line: Int = #line) {
        #if DEBUG
        Log.Destination.console.write(.warning, file, function, line, message())
        #endif
    }
    
    /// 주어진 메세지를 error 타입으로 출력
    ///
    /// - Parameter
    ///   - message:  출력할 메세지
    ///   - file:     파일명
    ///   - function: 함수명
    ///   - line:     라인
    static func e(_ message: @autoclosure () -> Any, _ file: String = #file, _ function: String = #function, _ line: Int = #line) {
        #if DEBUG
        Log.Destination.console.write(.error, file, function, line, message())
        #endif
    }
    
    /// 주어진 메세지를 debug 타입으로 출력
    ///
    /// - Parameter
    ///   - message:  출력할 메세지
    ///   - file:     파일명
    ///   - function: 함수명
    ///   - line:     라인
    static func f(_ message: @autoclosure () -> Any, _ file: String = #file, _ function: String = #function, _ line: Int = #line) {
        #if DEBUG
        Log.Destination.file.write(.debug, file, function, line, message())
        #endif
    }
}

