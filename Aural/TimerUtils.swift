/*
    Utility class that creates Timer objects and stores aggregate info for multiple timers (sum, avg exec time, etc.)
*/

import Foundation

open class TimerUtils {
    
    static var instance: TimerUtils = TimerUtils()
    
    // Map of method/operation name -> array of timers for that method/operation
    private var timers: [String: [CodeTimer]] = [String: [CodeTimer]]()
    
    static func start(_ tag: String) -> CodeTimer {
        
        var timersForTag: [CodeTimer]? = instance.timers[tag]
        
        if timersForTag == nil  {
            timersForTag = [CodeTimer]()
            instance.timers[tag] = timersForTag
        }
        
        let timer: CodeTimer = CodeTimer()
        timer.start()
        instance.timers[tag]!.append(timer)
        
        return timer
    }
    
    static func printStats() {
        
        for (tag, timersForTag) in instance.timers {
            
            print("\nFor tag '" + tag + "' ...")
            let avg = avgForTimers(timersForTag)
            print("    Count / AvgTime", timersForTag.count, String(format: "%.3lf", avg) + " msec")
        }
    }
    
    static func printStats(_ forTag: String) {
        
        for (tag, timersForTag) in instance.timers {
            
            if (tag == forTag) {
            
                print("\nFor tag '" + tag + "' ...")
                let avg = avgForTimers(timersForTag)
                print("    Count / AvgTime", timersForTag.count, String(format: "%.3lf", avg) + " msec")
                
                return
            }
        }
    }
    
    private static func avgForTimers(_ timers: [CodeTimer]) -> Double {
        var sum: Double = 0
        
        for timer in timers {
            sum += timer.durationMsecs!
        }
        
        return sum / Double(timers.count)
    }
}
