/*
    A timer for tasks that repeat at regular intervals.

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
    
    private var state: TimerState
    
    init(intervalMillis: Int, task: @escaping () -> Void, queue: DispatchQueue) {
        
        self.intervalMillis = intervalMillis
        self.task = task
        self.queue = queue
        
        self.state = .notStarted
        
        timer = DispatchSource.makeTimerSource(flags: DispatchSource.TimerFlags.strict, queue: queue)
        
        // Allow a 10% time leeway
        let interval = DispatchTimeInterval.milliseconds(intervalMillis)
        let leeway = DispatchTimeInterval.milliseconds(intervalMillis / 10)
        
        timer.schedule(deadline: .now(), repeating: interval, leeway: leeway)
        
        timer.setEventHandler { [weak self] in
            self?.task()
        }
    }

    // Start/resume task execution
    func startOrResume() {
        
        if state == .notStarted || state == .suspended {
            
            timer.resume()
            state = .running
        }
    }
    
    // Pause task execution
    func pause() {
        
        if state == .running {
            
            timer.suspend()
            state = .suspended
        }
    }
    
    var isRunning: Bool {
        return state == .running
    }
    
    var interval: Int {
        return intervalMillis
    }
    
    func stop() {
        
        if state == .stopped {
            return
        }
        
        // Timer cannot be canceled while in a suspended state
        if state != .running {
            timer.resume()
        }
        
        state = .stopped
        timer.cancel()
    }
    
    deinit {
        stop()
    }
}

// Enumerates the lifecycle phases of a DispatchSourceTimer
fileprivate enum TimerState {
    
    case notStarted, running, suspended, stopped
}
