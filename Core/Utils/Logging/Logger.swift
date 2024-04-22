//
//  Logger.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation
import os

class Logger {
    
    private let theLogger: os.Logger
    
    static func createLogger(callerFile: String = #file) -> Logger {
        .init(logger: .init(subsystem: Bundle.main.bundleIdentifier ?? "Aural", category: fileName(forCaller: callerFile)))
    }
    
    init(callerFile: String = #file) {
        self.theLogger = .init(subsystem: Bundle.main.bundleIdentifier ?? "Aural", category: Self.fileName(forCaller: callerFile))
    }
    
    private init(logger: os.Logger) {
        self.theLogger = logger
    }
    
    init(for object: Any) {
        self.theLogger = .init(subsystem: Bundle.main.bundleIdentifier ?? "Aural", category: String(describing: type(of: object)))
    }
    
    func info(_ message: String, callerFile: String = #file, callerFunction: String = #function, callerLine: Int = #line) {
        
        let callerFunctionWithSeparator = callerFunction == "Aural" ? "" : "\(callerFunction)_"
        theLogger.info("\(Self.fileName(forCaller: callerFile))_\(callerFunctionWithSeparator)\(callerLine): \(message, privacy: .public)")
    }
    
    func debug(_ message: String, callerFile: String = #file, callerFunction: String = #function, callerLine: Int = #line) {
        
        let callerFunctionWithSeparator = callerFunction == "Aural" ? "" : "\(callerFunction)_"
        theLogger.debug("\(Self.fileName(forCaller: callerFile))_\(callerFunctionWithSeparator)\(callerLine): \(message, privacy: .public)")
    }
    
    func warning(_ message: String, callerFile: String = #file, callerFunction: String = #function, callerLine: Int = #line) {
        
        let callerFunctionWithSeparator = callerFunction == "Aural" ? "" : "\(callerFunction)_"
        theLogger.warning("\(Self.fileName(forCaller: callerFile))_\(callerFunctionWithSeparator)\(callerLine): \(message, privacy: .public)")
    }
    
    func error(_ message: String, callerFile: String = #file, callerFunction: String = #function, callerLine: Int = #line) {
        
        let callerFunctionWithSeparator = callerFunction == "Aural" ? "" : "\(callerFunction)_"
        theLogger.error("\(Self.fileName(forCaller: callerFile))_\(callerFunctionWithSeparator)\(callerLine): \(message, privacy: .public)")
    }
    
    func critical(_ message: String, callerFile: String = #file, callerFunction: String = #function, callerLine: Int = #line) {
        
        let callerFunctionWithSeparator = callerFunction == "Aural" ? "" : "\(callerFunction)_"
        theLogger.critical("\(Self.fileName(forCaller: callerFile))_\(callerFunctionWithSeparator)\(callerLine): \(message, privacy: .public)")
    }
    
    private static func fileName(forCaller caller: String) -> String {
        
        let fileComponents = caller.split(separator: "/")
        
        if let fileName = fileComponents.last {
            return String(fileName).removingOccurrences(of: ".swift")
        }
        
        return "<Unknown>"
    }
}
