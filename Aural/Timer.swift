/*
    Utility class to time code execution.
*/

import Foundation

public class Timer: NSObject {
    
    var startTime: NSDate?
    var endTime: NSDate?
    
    var durationSecs: Double? {
        get {
            return endTime!.timeIntervalSinceDate(startTime!)
        }
    }
    
    var durationMsecs: Double? {
        get {
            return durationSecs! * 1000
        }
    }
    
    override init() {
    }
    
    public func start() {
        startTime = NSDate()
    }
    
    public func end() {
        endTime = NSDate()
    }
}