//
//  RepeatingTaskExecutor.swift
//  Aural
//
//  Copyright © 2022 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

///
/// A timer that executes tasks that repeat at regular intervals.
///
/// Implemented as a wrapper around a GCD dispatch source timer.
///
class RepeatingTaskExecutor {
    
    // GCD dispatch source timer
    private var timer: DispatchSourceTimer
    
    // The code block to be executed
    private var task: () -> Void
    
    // The task will pause for this duration between consecutive executions
    var interval: Int {
        didSet {scheduleTimerTask()}
    }
    
    // The queue on which the task will be put
    private var queue: DispatchQueue
    
    private var state: TimerState
    
    init(intervalMillis: Int, task: @escaping () -> Void, queue: DispatchQueue) {
        
        self.interval = intervalMillis
        self.task = task
        self.queue = queue
        
        self.state = .notStarted
        
        timer = DispatchSource.makeTimerSource(flags: .strict, queue: queue)
        timer.setEventHandler {[weak self] in self?.task()}
        scheduleTimerTask()
    }
    
    func scheduleTimerTask() {
        
        // Allow a 10% time leeway
        let interval = DispatchTimeInterval.milliseconds(self.interval)
        let leeway = DispatchTimeInterval.milliseconds(self.interval / 10)

        timer.schedule(deadline: .now(), repeating: interval, leeway: leeway)
    }

    // Start/resume task execution
    func startOrResume() {
        
        if state.equalsOneOf(.notStarted, .suspended) {
            
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
