/*
    Similar to ScheduledTaskExecutor, but can be stopped reliably (i.e. will wait/block till all pending tasks complete). This helps prevent race conditions in which dead pointers are dereferenced. Caller can be certain that, after calling stop(), no further task execution will take place. Used by BufferManager to schedule buffers reliably.

    Uses a serial NSOperationQueue, in conjunction with a GCD dispatch source timer, for reliable stopping capability. The GCD timer runs at regular intervals, and, instead of performing the task directly, puts the task on the NSOperationQueue, which then executes it.
*/

import Cocoa

class StoppableScheduledTaskExecutor: NSObject {
    
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
    
    // The operation queue that facilitates a blocking stop operation
    private var operationQueue: NSOperationQueue
    
    init(intervalMillis: UInt32, task: () -> Void, queue: String) {
        
        self.intervalMillis = intervalMillis
        self.task = task
        self.queue = queue
        
        let dispatchQueue = dispatch_queue_create(queue, nil)
        
        timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatchQueue)
        
        let intervalNanos = UInt64(intervalMillis) * NSEC_PER_MSEC
        
        // Allow a 10% time leeway
        dispatch_source_set_timer(timer!, DISPATCH_TIME_NOW, intervalNanos, intervalNanos / 10)
        
        // Serial operation queue
        operationQueue = NSOperationQueue()
        operationQueue.underlyingQueue = dispatchQueue
        operationQueue.maxConcurrentOperationCount = 1
        
        super.init()
        
        dispatch_source_set_event_handler(timer!) { [weak self] in
            
            // Push the task onto the operation queue
            if ((!self!.stopped) && (!self!.paused)) {
                self!.operationQueue.addOperationWithBlock({self!.task()})
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
        
        // First, stop queueing more tasks
        if (timer != nil) {
            dispatch_suspend(timer!)
        }
        
        // Then, suspend operation of the tasks
        operationQueue.suspended = true
    }
    
    // Resume task execution
    func resume() {
        
        if (stopped || !paused) {
            return
        }
        
        paused = false
        operationQueue.suspended = false
        if (timer != nil) {
            dispatch_resume(timer!)
        }
    }
    
    // Stop executing the task. Blocks till all pending tasks have finished executing.
    func stop() {
        
        if (stopped) {
            return
        }
        
        stopped = true
        if (timer != nil) {
            dispatch_source_cancel(timer!)
        }
        
        operationQueue.cancelAllOperations()
        
        // NOTE - This crucial part prevents race conditions
        operationQueue.waitUntilAllOperationsAreFinished()
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