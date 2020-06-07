import Foundation

class TranscoderDaemon: MessageSubscriber {
    
    let immediateExecutionQueue: OperationQueue = OperationQueue()
    let backgroundExecutionQueue: OperationQueue = OperationQueue()
    
    var tasks: ConcurrentMap<Track, TranscodingTask> = ConcurrentMap("transcoderDaemon-tasks")
    
    var transcodingTracks: [Track] {
        return tasks.keys
    }
    
    private let preferences: TranscodingPreferences
    
    init(_ preferences: TranscodingPreferences) {
        
        self.preferences = preferences
        
        immediateExecutionQueue.underlyingQueue = DispatchQueue.global(qos: .userInteractive)
        immediateExecutionQueue.maxConcurrentOperationCount = 2
        immediateExecutionQueue.qualityOfService = .userInteractive
        
        backgroundExecutionQueue.underlyingQueue = DispatchQueue.global(qos: .utility)
        backgroundExecutionQueue.maxConcurrentOperationCount = preferences.maxBackgroundTasks
        backgroundExecutionQueue.qualityOfService = .utility
        
        SyncMessenger.subscribe(messageTypes: [.appExitRequest], subscriber: self)
    }
    
    func hasTaskForTrack(_ track: Track) -> Bool {
        return tasks.hasForKey(track)
    }
    
    func submitImmediateTask(_ track: Track, _ command: MonitoredCommand, _ successHandler: @escaping ((_ command: MonitoredCommand) -> Void), _ failureHandler: @escaping ((_ command: MonitoredCommand) -> Void), _ cancellationHandler: @escaping (() -> Void)) {
        
        // Track is already being transcoded
        if let task = tasks[track] {
            
            // If running in foreground, nothing further to do
            if task.priority != .immediate {
                
                // Task is running in the background, bring it to the foreground.
                doMoveTaskToForeground(task)
            }
            
            return
        }
        
        doSubmitTask(track, command, successHandler, failureHandler, cancellationHandler, .immediate)
    }
    
    func submitBackgroundTask(_ track: Track, _ command: MonitoredCommand, _ successHandler: @escaping ((_ command: MonitoredCommand) -> Void), _ failureHandler: @escaping ((_ command: MonitoredCommand) -> Void), _ cancellationHandler: @escaping (() -> Void)) {
        
        // If track is already being transcoded, just return.
        if !tasks.hasForKey(track) {
            doSubmitTask(track, command, successHandler, failureHandler, cancellationHandler, .background)
        }
    }
    
    private func doSubmitTask(_ track: Track, _ command: MonitoredCommand, _ successHandler: @escaping ((_ command: MonitoredCommand) -> Void), _ failureHandler: @escaping ((_ command: MonitoredCommand) -> Void), _ cancellationHandler: @escaping (() -> Void), _ priority: TranscoderPriority) {
        
        let block = {
            
            NSLog("\nStarted transcoding: %@ ImmTasks=%d, BGTasks=%d", track.file.lastPathComponent,
                  self.immediateExecutionQueue.operationCount, self.backgroundExecutionQueue.operationCount)
            
            let result = CommandExecutor.execute(command)
            
            if command.cancelled {
                
                cancellationHandler()
                NSLog("\nCancelled transcoding: %@ ImmTasks=%d, BGTasks=%d", track.file.lastPathComponent, self.immediateExecutionQueue.operationCount, self.backgroundExecutionQueue.operationCount)
                
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
        
        let task = TranscodingTask(track, priority, command, operation, block)
        tasks[track] = task
        
        operation.completionBlock = {
            
            // Task completed, remove it from the map
            if let taskForTrack = self.tasks[track], taskForTrack == task {
                _ = self.tasks.remove(track)
            }
        }
        
        priority == .immediate ? immediateExecutionQueue.addOperation(operation) : backgroundExecutionQueue.addOperation(operation)
    }
    
    func cancelTask(_ track: Track) {
        
        if let task = tasks[track] {
            
            CommandExecutor.cancel(task.command)
            task.operation.cancel()
            
            _ = tasks.remove(track)
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
                
                // Task completed, remove it from the map
                if let taskForTrack = self.tasks[task.track], taskForTrack == task {
                    _ = self.tasks.remove(task.track)
                }
            }
            
            immediateExecutionQueue.addOperation(opClone)
        }
        
        // If op is already executing, let it finish on the background queue. If finished, nothing left to do.
    }
    
    func setMaxBackgroundTasks(_ numTasks: Int) {
        backgroundExecutionQueue.maxConcurrentOperationCount = numTasks
    }
    
    // This function is invoked when the user attempts to exit the app. It checks if there is a track playing and if sound settings for the track need to be remembered.
    private func onExit() -> AppExitResponse {
        
        for task in tasks.values {
            CommandExecutor.cancel(task.command)
        }
        
        tasks.removeAll()
        
        // Proceed with exit
        return AppExitResponse.okToExit
    }
    
    // MARK: Message handling
    
    func processRequest(_ request: RequestMessage) -> ResponseMessage {
        return request is AppExitRequest ? onExit() : EmptyResponse.instance
    }
}

class TranscodingTask: Equatable {
    
    var track: Track

    var priority: TranscoderPriority
    
    var command: MonitoredCommand
    var startTime: Date! {return command.startTime}
    
    var operation: BlockOperation
    var block: (() -> Void)
    
    // Unique ID (i.e. UUID) string ... used to differentiate two instances
    let id: String
    
    init(_ track: Track, _ priority: TranscoderPriority, _ command: MonitoredCommand, _ operation: BlockOperation, _ block: @escaping (() -> Void)) {
        
        self.track = track
        self.priority = priority
        self.command = command
        self.operation = operation
        self.block = block
        
        self.id = UUID().uuidString
    }
    
    static func == (lhs: TranscodingTask, rhs: TranscodingTask) -> Bool {
        return lhs.id == rhs.id
    }
}

enum TranscoderPriority {
    
    case immediate
    case background
}
