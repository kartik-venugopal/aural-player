import Foundation

class TranscoderDaemon {
    
    let immediateExecutionQueue: OperationQueue = OperationQueue()
    let backgroundExecutionQueue: OperationQueue = OperationQueue()
    
    var tasks: [Track: TranscodingTask] = [:]
    
    init() {
        
        immediateExecutionQueue.underlyingQueue = DispatchQueue.global(qos: .userInteractive)
        immediateExecutionQueue.maxConcurrentOperationCount = 1
        immediateExecutionQueue.qualityOfService = .userInteractive
        
        backgroundExecutionQueue.underlyingQueue = DispatchQueue.global(qos: .utility)
        backgroundExecutionQueue.maxConcurrentOperationCount = 1    // TODO: This value should come from preferences
        backgroundExecutionQueue.qualityOfService = .background
    }
    
    func submitImmediateTask(_ track: Track, _ command: Command, _ successHandler: @escaping ((_ command: Command) -> Void), _ failureHandler: @escaping ((_ command: Command) -> Void), _ cancellationHandler: @escaping (() -> Void)) {
        
        // Track is already being transcoded
        if let task = tasks[track] {
            
            // Running in foreground, nothing further to do
            if task.priority == .immediate {return}
            
            // Task is running in background, bring it to the foreground.
            doMoveTaskToForeground(task)
            return
        }
        
        doSubmitTask(track, command, successHandler, failureHandler, cancellationHandler, .immediate)
    }
    
    func submitBackgroundTask(_ track: Track, _ command: Command, _ successHandler: @escaping ((_ command: Command) -> Void), _ failureHandler: @escaping ((_ command: Command) -> Void), _ cancellationHandler: @escaping (() -> Void)) {
        
        // Track is already being transcoded. Just return.
        if tasks[track] != nil {return}
        
        doSubmitTask(track, command, successHandler, failureHandler, cancellationHandler, .background)
    }
    
    private func doSubmitTask(_ track: Track, _ command: Command, _ successHandler: @escaping ((_ command: Command) -> Void), _ failureHandler: @escaping ((_ command: Command) -> Void), _ cancellationHandler: @escaping (() -> Void), _ priority: TranscoderPriority) {
        
        let block = {
            
            let result = CommandExecutor.execute(command)
            
            if command.cancelled {
                cancellationHandler()
                return
            }
            
            if result.exitCode == 0 {
                // Success
                successHandler(command)
            } else {
                failureHandler(command)
            }
        }
        
        let operation = BlockOperation(block: block)
        operation.completionBlock = {
            
            // Task completed, remove it from the map
            self.tasks.removeValue(forKey: track)
        }
        
        priority == .immediate ? immediateExecutionQueue.addOperation(operation) : backgroundExecutionQueue.addOperation(operation)
        
        let task = TranscodingTask(track, priority, command, operation, block)
        tasks[track] = task
    }
    
    func cancelTask(_ track: Track) {
        
        if let task = tasks[track] {
            
            CommandExecutor.cancel(task.command)
            task.operation.cancel()
            tasks.removeValue(forKey: track)
        }
    }
    
    func moveTaskToBackground(_ track: Track) {

        if let task = tasks[track] {
            
            task.command.stopMonitoring()
            task.priority = .background
        }
    }

    func moveTaskToForeground(_ track: Track) {

        if let task = tasks[track] {
            doMoveTaskToForeground(task)
        }
    }
    
    // TODO: Because of the .background QoS, this is not straightforward. Perhaps always cancel the old task and start a new one ? Check time remaining on task and make decision ?
    func doMoveTaskToForeground(_ task: TranscodingTask) {
        
        task.command.startMonitoring()
        task.priority = .immediate
        
        let op = task.operation
        op.qualityOfService = .userInteractive
        task.command.process.qualityOfService = .userInteractive
        
        if !op.isExecuting && !op.isFinished {
            
            // This should prevent it from executing on the background queue
            op.cancel()
            
            // Duplicate the operation and add it to the immediate execution queue.
            let opClone = BlockOperation(block: task.block)
            opClone.completionBlock = {
                self.tasks.removeValue(forKey: task.track)
            }
            
            immediateExecutionQueue.addOperation(opClone)
        }
        
        // TODO: ???
        // If op is already executing, let it finish on the background queue. If finished, nothing left to do.
    }
}

class TranscodingTask {

    var track: Track

    var priority: TranscoderPriority
    
    var command: Command
    var startTime: Date! {return command.startTime}
    
    var operation: BlockOperation
    var block: (() -> Void)
    
    init(_ track: Track, _ priority: TranscoderPriority, _ command: Command, _ operation: BlockOperation, _ block: @escaping (() -> Void)) {
        
        self.track = track
        self.priority = priority
        self.command = command
        self.operation = operation
        self.block = block
    }
}

enum TranscoderPriority {
    
    case immediate
    case background
}
