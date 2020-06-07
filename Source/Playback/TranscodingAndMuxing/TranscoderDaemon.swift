import Foundation

class TranscoderDaemon: MessageSubscriber {
    
    let immediateExecutionQueue: OperationQueue = OperationQueue()
    let backgroundExecutionQueue: OperationQueue = OperationQueue()
    
    // TODO: This should be a ConcurrentMap
    var tasks: [Track: TranscodingTask] = [:]
    
    private let preferences: TranscodingPreferences
    
    init(_ preferences: TranscodingPreferences) {
        
        self.preferences = preferences
        
        immediateExecutionQueue.underlyingQueue = DispatchQueue.global(qos: .userInteractive)
        immediateExecutionQueue.maxConcurrentOperationCount = 1
        immediateExecutionQueue.qualityOfService = .userInteractive
        
        backgroundExecutionQueue.underlyingQueue = DispatchQueue.global(qos: .utility)
        backgroundExecutionQueue.maxConcurrentOperationCount = preferences.maxBackgroundTasks
        backgroundExecutionQueue.qualityOfService = .background
        
        SyncMessenger.subscribe(messageTypes: [.appExitRequest], subscriber: self)
    }
    
    func hasTaskForTrack(_ track: Track) -> Bool {
        return tasks[track] != nil
    }
    
    func submitImmediateTask(_ track: Track, _ command: MonitoredCommand, _ successHandler: @escaping ((_ command: MonitoredCommand) -> Void), _ failureHandler: @escaping ((_ command: MonitoredCommand) -> Void), _ cancellationHandler: @escaping (() -> Void)) {
        
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
    
    func submitBackgroundTask(_ track: Track, _ command: MonitoredCommand, _ successHandler: @escaping ((_ command: MonitoredCommand) -> Void), _ failureHandler: @escaping ((_ command: MonitoredCommand) -> Void), _ cancellationHandler: @escaping (() -> Void)) {
        
        // Track is already being transcoded. Just return.
        if tasks[track] != nil {return}
        
        doSubmitTask(track, command, successHandler, failureHandler, cancellationHandler, .background)
    }
    
    private func doSubmitTask(_ track: Track, _ command: MonitoredCommand, _ successHandler: @escaping ((_ command: MonitoredCommand) -> Void), _ failureHandler: @escaping ((_ command: MonitoredCommand) -> Void), _ cancellationHandler: @escaping (() -> Void), _ priority: TranscoderPriority) {
        
        let block = {
            
            NSLog("\nStarted transcoding: %@ ImmTasks=%d, BGTasks=%d", track.file.lastPathComponent, self.immediateExecutionQueue.operationCount, self.backgroundExecutionQueue.operationCount)
            
            let result = CommandExecutor.execute(command)
            
            if command.cancelled {
                
                cancellationHandler()
                NSLog("\nCancelled transcoding: %@ BGTasks=%d", track.file.lastPathComponent, self.backgroundExecutionQueue.operationCount)
                return
            }
            
            if result.exitCode == 0 && !command.errorDetected {
                // Success
                successHandler(command)
                NSLog("\nFinished transcoding: %@ ImmTasks=%d, BGTasks=%d", track.file.lastPathComponent, self.immediateExecutionQueue.operationCount, self.backgroundExecutionQueue.operationCount)
                
            } else {
                failureHandler(command)
                NSLog("\nFailed to transcode: %@ BGTasks=%d", track.file.lastPathComponent, self.backgroundExecutionQueue.operationCount)
            }
        }
        
        let operation = BlockOperation(block: block)
        operation.completionBlock = {
            
            // Task completed, remove it from the map
            self.tasks.removeValue(forKey: track)
        }
        
        priority == .immediate ? immediateExecutionQueue.addOperation(operation) : backgroundExecutionQueue.addOperation(operation)
        print("\nAdded task to", priority == .immediate ? "FG:" : "BG:", track.conciseDisplayName)
        
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
        
        if !op.isExecuting && !op.isFinished {
            
            // This should prevent it from executing on the background queue
            op.cancel()
            
            // Duplicate the operation and add it to the immediate execution queue.
            let opClone = BlockOperation(block: task.block)
            opClone.completionBlock = {
                self.tasks.removeValue(forKey: task.track)
            }
            
            print("\nMoved task to FG:", task.track.conciseDisplayName)
            immediateExecutionQueue.addOperation(opClone)
        }
        
        // If op is already executing, let it finish on the background queue. If finished, nothing left to do.
    }
    
    func setMaxBackgroundTasks(_ numTasks: Int) {
        backgroundExecutionQueue.maxConcurrentOperationCount = numTasks
    }
    
    // This function is invoked when the user attempts to exit the app. It checks if there is a track playing and if sound settings for the track need to be remembered.
    private func onExit() -> AppExitResponse {
        
        for (_, task) in tasks {
            CommandExecutor.cancel(task.command)
        }
        
        tasks.removeAll()
        
        // Proceed with exit
        return AppExitResponse.okToExit
    }
    
    // MARK: Message handling
    
    func processRequest(_ request: RequestMessage) -> ResponseMessage {
        
        if (request is AppExitRequest) {
            return onExit()
        }
        
        return EmptyResponse.instance
    }
}

class TranscodingTask {

    var track: Track

    var priority: TranscoderPriority
    
    var command: MonitoredCommand
    var startTime: Date! {return command.startTime}
    
    var operation: BlockOperation
    var block: (() -> Void)
    
    init(_ track: Track, _ priority: TranscoderPriority, _ command: MonitoredCommand, _ operation: BlockOperation, _ block: @escaping (() -> Void)) {
        
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
