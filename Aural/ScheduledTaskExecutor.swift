/*
    A utility class that provides a mechanism to schedule a repeating task that runs in a background thread. This is useful for daemon tasks, such as memory monitoring. See class MemoryMonitor, which makes use of this class.

    Wrapper around a GCD dispatch source timer.
*/

import Cocoa

class ScheduledTaskExecutor {
    
    // GCD dispatch source timer
    fileprivate var timer: DispatchSourceTimer
    
    // The task will pause for this duration between consecutive executions
    fileprivate var intervalMillis: Int
    
    // The code block to be executed
    fileprivate var task: () -> Void
    
    // The queue on which the task will be put
    fileprivate var queue: DispatchQueue
    
    // Flags indicating whether this timer is currently running
    fileprivate var running: Bool = false
    fileprivate var stopped: Bool = false
    
    init(intervalMillis: Int, task: @escaping () -> Void, queue: DispatchQueue) {
        
        self.intervalMillis = intervalMillis
        self.task = task
        self.queue = queue
        
        timer = DispatchSource.makeTimerSource(flags: DispatchSource.TimerFlags(rawValue: 0), queue: queue)
        
        // Allow a 10% time leeway
        timer.scheduleRepeating(deadline: DispatchTime.now(), interval: DispatchTimeInterval.milliseconds(intervalMillis), leeway: DispatchTimeInterval.milliseconds(intervalMillis / 10))
        
        timer.setEventHandler { [weak self] in
            self!.task()
        }
    }

    // Start/resume task execution
    func startOrResume() {
        
        if (stopped) {
            return
        }
        
        if (!running) {
            timer.resume()
            running = true
        }
    }
    
    // Pause task execution
    func pause() {
        
        if (stopped) {
            return
        }
        
        if (running) {
            timer.suspend()
            running = false
        }
    }
    
    func isRunning() -> Bool {
        return running
    }
    
    func getInterval() -> Int {
        return intervalMillis
    }
    
    func stop() {
        
        if (stopped) {
            return
        }
        
        let wasPaused = !running
        
        running = false
        stopped = true
        
        // Timer cannot be canceled while in a suspended state
        if (wasPaused) {
            timer.resume()
        }
        
        timer.cancel()
    }
    
    deinit {
        stop()
    }
}
