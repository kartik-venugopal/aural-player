/*
    Utility class to time code execution.
*/

import Foundation

open class CodeTimer: NSObject {
    
    var startTime: Date?
    var endTime: Date?
    
    var durationSecs: Double? {
        get {
            if (endTime != nil) {
                return endTime!.timeIntervalSince(startTime!)
            }
            
            return Date().timeIntervalSince(startTime!)
        }
    }
    
    var durationMsecs: Double? {
        get {
            return durationSecs! * 1000
        }
    }
    
    override init() {
    }
    
    open func start() {
        startTime = Date()
    }
    
    open func end() {
        endTime = Date()
    }
}
