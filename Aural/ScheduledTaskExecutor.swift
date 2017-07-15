/*
    A utility class that provides a mechanism to schedule a repeating task that runs in a background thread. This is useful for daemon tasks, such as memory monitoring. See class MemoryMonitor, which makes use of this class.

    Wrapper around a GCD dispatch source timer.
*/

import Cocoa

class ScheduledTaskExecutor {
    
    // GCD dispatch source timer
    fileprivate var timer: DispatchSource?
    
    // The task will pause for this duration between consecutive executions
    fileprivate var intervalMillis: UInt32
    
    // The code block to be executed
    fileprivate var task: () -> Void
    
    // The queue on which the task will be put
    fileprivate var queue: DispatchQueue
    
    // Flags indicating whether this timer is currently running
    fileprivate var running: Bool = false
    fileprivate var stopped: Bool = false
    
    init(intervalMillis: UInt32, task: @escaping () -> Void, queue: DispatchQueue) {
        
        self.intervalMillis = intervalMillis
        self.task = task
        self.queue = queue
        
        timer = (DispatchSource.makeTimerSource(flags: DispatchSource.TimerFlags(rawValue: 0), queue: queue.underlyingQueue) /*Migrator FIXME: Use DispatchSourceTimer to avoid the cast*/ as! DispatchSource)
        
        let intervalNanos = UInt64(intervalMillis) * NSEC_PER_MSEC
        
        // Allow a 10% time leeway
        timer!.setTimer(start: DispatchTime.now(), interval: intervalNanos , leeway: intervalNanos / 10)
        
        timer!.setEventHandler { [weak self] in
            self!.task()
        }
    }

    // Start/resume task execution
    func startOrResume() {
        
        if (stopped) {
            return
        }
        
        if (!running && timer != nil) {
            timer!.resume()
            running = true
        }
    }
    
    // Pause task execution
    func pause() {
        
        if (stopped) {
            return
        }
        
        if (running && timer != nil) {
            timer!.suspend()
            running = false
        }
    }
    
    func isRunning() -> Bool {
        return running
    }
    
    func getInterval() -> UInt32 {
        return intervalMillis
    }
    
    func stop() {
        
        if (stopped) {
            return
        }
        
        running = false
        stopped = true
        
        if (timer != nil) {
            timer!.cancel()
        }
    }
    
    deinit {
        stop()
    }
}
