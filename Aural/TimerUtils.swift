/*
    Utility class that creates Timer objects and stores aggregate info for multiple timers (sum, avg exec time, etc.)
*/

import Foundation

open class TimerUtils {
    
    static var instance: TimerUtils = TimerUtils()
    
    // Map of method/operation name -> array of timers for that method/operation
    private var timers: ConcurrentMap<String, [CodeTimer]> = ConcurrentMap<String, [CodeTimer]>("TimerUtils")
//    private var timers: [String: [CodeTimer]] = [String: [CodeTimer]]()
    
    static func start(_ tag: String) -> CodeTimer {
        
        var timersForTag: [CodeTimer]? = instance.timers.getForKey(tag)
        
        if timersForTag == nil  {
            timersForTag = [CodeTimer]()
            instance.timers.put(tag, timersForTag!)
        }
        
        let timer: CodeTimer = CodeTimer()
        timer.start()
        
        timersForTag!.append(timer)
        
        instance.timers.put(tag, timersForTag!)
        
        return timer
    }
    
    static func printStats() {
        
        for (tag, timersForTag) in instance.timers.kvPairs() {
            
            print("\nFor tag '" + tag + "' ...")
            let avg = avgForTimers(timersForTag)
            print("    Count / AvgTime", timersForTag.count, String(format: "%.3lf", avg) + " msec")
        }
        
        print("\n-----------------------------------------")
    }
    
    static func printStats(_ forTag: String) {
        
        for (tag, timersForTag) in instance.timers.kvPairs() {
            
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
