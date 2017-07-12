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
    private var queue: String
    
    // Flags indicating whether this timer has been paused/stopped
    private var paused: Bool = false
    private var stopped: Bool = false
    
    init(intervalMillis: UInt32, task: () -> Void, queue: String) {
        
        self.intervalMillis = intervalMillis
        self.task = task
        self.queue = queue
        
        let dispatchQueue = dispatch_queue_create(queue, nil)
        
        timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatchQueue)
        
        let intervalNanos = UInt64(intervalMillis) * NSEC_PER_MSEC
        
        // Allow a 10% time leeway
        dispatch_source_set_timer(timer!, DISPATCH_TIME_NOW, intervalNanos , intervalNanos / 10)
        
        dispatch_source_set_event_handler(timer!) { [weak self] in
            
            if ((!self!.stopped) && (!self!.paused)) {
                self!.task()
            }
        }
    }
    
    // Start executing the task
    func start() {
        
        if (timer != nil) {
            dispatch_resume(timer!)
        }
    }
    
    // Pause task execution
    func pause() {
        
        if (stopped || paused) {
            return
        }
        
        paused = true
        if (timer != nil) {
            dispatch_suspend(timer!)
        }
    }
    
    // Resume task execution
    func resume() {
        
        if (stopped || !paused) {
            return
        }
        
        paused = false
        if (timer != nil) {
            dispatch_resume(timer!)
        }
    }
    
    // Stop executing the task
    func stop() {
        
        if (stopped) {
            return
        }
        
        stopped = true
        if (timer != nil) {
            dispatch_source_cancel(timer!)
            
            while (dispatch_source_testcancel(timer!) == 0) {
                // Wait for timer to be cancelled
            }
        }
    }
    
    func isStopped() -> Bool {
        return stopped
    }
    
    func isPaused() -> Bool {
        return paused
    }
    
    deinit {
        self.stop()
    }
}