/*
    Utility class that creates Timer objects and stores aggregate info for multiple timers (sum, avg exec time, etc.)
*/

import Foundation

public class TimerUtils {
    
    // Map of method/operation name -> array of timers for that method/operation
    private static var timers: [String: [Timer]] = [String: [Timer]]()
    
    static func start(tag: String) -> Timer {
        let timer: Timer = Timer()
        timer.start()
        
        var timersForTag: [Timer]? = timers[tag]
        
        if timersForTag == nil  {
            timersForTag = [Timer]()
            timers[tag] = timersForTag
        }
        
        timers[tag]!.append(timer)
        
        return timer
    }
    
    static func printStats() {
        
        for (tag, timersForTag) in timers {
            
            print("\nFor tag '" + tag + "' ...")
            let avg = avgForTimers(timersForTag)
            print("    Count=" + String(timersForTag.count) + ", AvgTime=" + String(format: "%.2lf", avg) + " msec")
        }
    }
    
    private static func avgForTimers(timers: [Timer]) -> Double {
        var sum: Double = 0
        
        for timer in timers {
            sum += timer.durationMsecs!
        }
        
        return sum / Double(timers.count)
    }
}