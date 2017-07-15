/*
    Similar to ScheduledTaskExecutor, but can be stopped reliably (i.e. will wait/block till all pending tasks complete). This helps prevent race conditions in which dead pointers are dereferenced. Caller can be certain that, after calling stop(), no further task execution will take place. Used by BufferManager to schedule buffers reliably.

    Uses a serial NSOperationQueue, in conjunction with a GCD dispatch source timer, for reliable stopping capability. The GCD timer runs at regular intervals, and, instead of performing the task directly, puts the task on the NSOperationQueue, which then executes it.
*/

import Cocoa

class StoppableScheduledTaskExecutor: NSObject {
    
    // GCD dispatch source timer
    fileprivate var timer: DispatchSource?
    
    // The task will pause for this duration between consecutive executions
    fileprivate var intervalMillis: UInt32
    
    // The code block to be executed
    fileprivate var task: () -> Void
    
    // The queue on which the task will be put
    fileprivate var queue: String
    
    // Flags indicating whether this timer has been paused/stopped
    fileprivate var paused: Bool = false
    fileprivate var stopped: Bool = false
    
    // The operation queue that facilitates a blocking stop operation
    fileprivate var operationQueue: OperationQueue
    
    init(intervalMillis: UInt32, task: @escaping () -> Void, queue: String) {
        
        self.intervalMillis = intervalMillis
        self.task = task
        self.queue = queue
        
        let dispatchQueue = DispatchQueue(label: queue, attributes: [])
        
        timer = DispatchSource.makeTimerSource(flags: 0, queue: dispatchQueue) /*Migrator FIXME: Use DispatchSourceTimer to avoid the cast*/ as! DispatchSource
        
        let intervalNanos = UInt64(intervalMillis) * NSEC_PER_MSEC
        
        // Allow a 10% time leeway
        timer!.setTimer(start: DispatchTime.now(), interval: intervalNanos, leeway: intervalNanos / 10)
        
        // Serial operation queue
        operationQueue = OperationQueue()
        operationQueue.underlyingQueue = dispatchQueue
        operationQueue.maxConcurrentOperationCount = 1
        
        super.init()
        
        timer!.setEventHandler { [weak self] in
            
            // Push the task onto the operation queue
            if ((!self!.stopped) && (!self!.paused)) {
                self!.operationQueue.addOperation({self!.task()})
            }
        }
    }
    
    // Start executing the task
    func start() {
        
        if (timer != nil) {
            timer!.resume()
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
            timer!.suspend()
        }
        
        // Then, suspend operation of the tasks
        operationQueue.isSuspended = true
    }
    
    // Resume task execution
    func resume() {
        
        if (stopped || !paused) {
            return
        }
        
        paused = false
        operationQueue.isSuspended = false
        if (timer != nil) {
            timer!.resume()
        }
    }
    
    // Stop executing the task. Blocks till all pending tasks have finished executing.
    func stop() {
        
        if (stopped) {
            return
        }
        
        stopped = true
        if (timer != nil) {
            timer!.cancel()
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
