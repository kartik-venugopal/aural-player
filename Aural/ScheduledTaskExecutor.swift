/*
    A utility class that provides a mechanism to schedule a repeating task that runs in a background thread. This is useful for daemon tasks, such as memory monitoring. See class MemoryMonitor, which makes use of this class.

    Wrapper around a GCD dispatch source timer.
*/

import Cocoa

class ScheduledTaskExecutor {
    
    // GCD dispatch source timer
    private var timer: dispatch_source_t?
    
    // The task will pause for this duration between consecutive executions
    private var intervalMillis: UInt32
    
    // The code block to be executed
    private var task: () -> Void
    
    // The queue on which the task will be put
    private var queue: DispatchQueue
    
    // Flags indicating whether this timer is currently running
    private var running: Bool = false
    private var stopped: Bool = false
    
    init(intervalMillis: UInt32, task: () -> Void, queue: DispatchQueue) {
        
        self.intervalMillis = intervalMillis
        self.task = task
        self.queue = queue
        
        timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue.underlyingQueue)
        
        let intervalNanos = UInt64(intervalMillis) * NSEC_PER_MSEC
        
        // Allow a 10% time leeway
        dispatch_source_set_timer(timer!, DISPATCH_TIME_NOW, intervalNanos , intervalNanos / 10)
        
        dispatch_source_set_event_handler(timer!) { [weak self] in
            self!.task()
        }
    }

    // Start/resume task execution
    func startOrResume() {
        
        if (stopped) {
            return
        }
        
        if (!running && timer != nil) {
            dispatch_resume(timer!)
            running = true
        }
    }
    
    // Pause task execution
    func pause() {
        
        if (stopped) {
            return
        }
        
        if (running && timer != nil) {
            dispatch_suspend(timer!)
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
            dispatch_source_cancel(timer!)
        }
    }
    
    deinit {
        stop()
    }
}