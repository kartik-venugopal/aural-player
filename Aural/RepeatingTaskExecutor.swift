/*
    A timer for repeating tasks.

    Wrapper around a GCD dispatch source timer.
*/

import Cocoa

class RepeatingTaskExecutor {
    
    // GCD dispatch source timer
    private var timer: DispatchSourceTimer
    
    // The task will pause for this duration between consecutive executions
    private var intervalMillis: Int
    
    // The code block to be executed
    private var task: () -> Void
    
    // The queue on which the task will be put
    private var queue: DispatchQueue
    
    // Flags indicating whether this timer is currently running
    private var running: Bool = false
    private var stopped: Bool = false
    
    init(intervalMillis: Int, task: @escaping () -> Void, queue: DispatchQueue) {
        
        self.intervalMillis = intervalMillis
        self.task = task
        self.queue = queue
        
        timer = DispatchSource.makeTimerSource(flags: DispatchSource.TimerFlags(rawValue: 0), queue: queue)
        
        // Allow a 10% time leeway
        timer.schedule(deadline: DispatchTime.now(), repeating: DispatchTimeInterval.milliseconds(intervalMillis),
                       leeway: DispatchTimeInterval.milliseconds(intervalMillis / 10))
        
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
