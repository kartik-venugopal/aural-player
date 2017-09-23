/*
    Utility class to time code execution.
*/

import Foundation

open class CodeTimer: NSObject {
    
    var startTime: Date?
    var endTime: Date?
    
    var durationSecs: Double? {
        get {
            return endTime!.timeIntervalSince(startTime!)
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
