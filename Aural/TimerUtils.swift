/*
    Utility class that creates Timer objects and stores aggregate info for multiple timers (sum, avg exec time, etc.)
*/

import Foundation

open class TimerUtils {
    
    static var instance: TimerUtils = TimerUtils()
    
    // Map of method/operation name -> array of timers for that method/operation
    fileprivate var timers: [String: [Timer]] = [String: [Timer]]()
    
    static func start(_ tag: String) -> Timer {
        
        var timersForTag: [Timer]? = instance.timers[tag]
        
        if timersForTag == nil  {
            timersForTag = [Timer]()
            instance.timers[tag] = timersForTag
        }
        
        let timer: Timer = Timer()
        timer.start()
        instance.timers[tag]!.append(timer)
        
        return timer
    }
    
    static func printStats() {
        
        for (tag, timersForTag) in instance.timers {
            
            print("\nFor tag '" + tag + "' ...")
            let avg = avgForTimers(timersForTag)
            print("    Count / AvgTime", timersForTag.count, String(format: "%.2lf", avg) + " msec")
        }
    }
    
    static func printStats(_ forTag: String) {
        
        for (tag, timersForTag) in instance.timers {
            
            if (tag == forTag) {
            
                print("\nFor tag '" + tag + "' ...")
                let avg = avgForTimers(timersForTag)
                print("    Count / AvgTime", timersForTag.count, String(format: "%.2lf", avg) + " msec")
                
                return
            }
        }
    }
    
    fileprivate static func avgForTimers(_ timers: [Timer]) -> Double {
        var sum: Double = 0
        
        for timer in timers {
            sum += timer.durationMsecs!
        }
        
        return sum / Double(timers.count)
    }
}
