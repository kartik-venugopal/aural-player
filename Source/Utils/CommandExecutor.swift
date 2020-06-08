import Foundation

class CommandExecutor {
    
    static let cancellationExitCode: Int32 = -1
    
    static func execute(_ cmd: Command) -> CommandResult {
        
        var outputAsLines: [String]?
        var outputAsObject: NSDictionary? = nil
        var error: [String] = []
        
        let task = cmd.process
        
        if let monitoredCmd = cmd as? MonitoredCommand {
            monitoredCmd.startTime = Date()
        }
        
        task.launch()
        
        // End task after timeout interval
        if let timeout = cmd.timeout {
            
            DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + timeout, execute: {
                
                if task.isRunning {
                    task.terminate()
                    NSLog("Timed out command: %@, with args: %@", cmd.process.launchPath!, cmd.process.arguments!)
                }
            })
        }
        
        task.waitUntilExit()
        
        if let monitoredCmd = cmd as? MonitoredCommand, monitoredCmd.cancelled {
            // Task may have been canceled
            return CommandResult(nil as [String]?, error, cancellationExitCode)
        }
        
        let status = task.terminationStatus
        
        if cmd.readOutput, let outpipe = task.standardOutput as? Pipe {
            
            let outdata = outpipe.fileHandleForReading.readDataToEndOfFile()
            
            if let outputType = cmd.outputType, outputType == .json {
                
                do {
                    
                    if let dict = try JSONSerialization.jsonObject(with: outdata, options: JSONSerialization.ReadingOptions()) as? NSDictionary {
                        outputAsObject = dict
                    }
                    
                } catch let error as NSError {
                    NSLog("Error reading JSON output for command: %@, with args: %@. \nCause:", cmd.process.launchPath!, cmd.process.arguments!, error.description)
                }
                
            } else {
                
                if var string = String(data: outdata, encoding: .utf8) {
                    
                    string = string.trimmingCharacters(in: .newlines)
                    outputAsLines = string.components(separatedBy: "\n")
                }
            }
        }
        
        if cmd.readErr, let errpipe = task.standardError as? Pipe {
            
            let errdata = errpipe.fileHandleForReading.readDataToEndOfFile()
            if var string = String(data: errdata, encoding: .utf8) {
                
                string = string.trimmingCharacters(in: .newlines)
                error = string.components(separatedBy: "\n")
            }
        }
        
        if let outputType = cmd.outputType, outputType == .json {
            return CommandResult(outputAsObject, error, status)
        } else {
            return CommandResult(outputAsLines, error, status)
        }
    }
    
    static func cancel(_ cmd: MonitoredCommand) {
        
        if cmd.process.isRunning {
            cmd.process.terminate()
        }
        
        cmd.cancelled = true
        cmd.enableMonitoring = false
    }
}

class Command {
    
    var process: Process
    var timeout: Double?
    var readOutput: Bool
    var readErr: Bool
    var outputType: CommandOutputType?
    
    init(_ cmd : String, _ args : [String], _ timeout: Double?, _ readOutput: Bool, _ readErr: Bool, _ outputType: CommandOutputType?) {
        
        process = Process()
        process.launchPath = cmd
        process.arguments = args
        process.qualityOfService = .userInteractive
        
        process.standardOutput = Pipe()
        process.standardError = Pipe()
        
        self.timeout = timeout
        
        self.readOutput = readOutput
        self.readErr = readErr
        self.outputType = outputType
    }
    
    static func createWithOutput(cmd : String, args : [String], timeout: Double?, readOutput: Bool, readErr: Bool, _ outputFormat: CommandOutputType?) -> Command {
        return Command(cmd, args, timeout, readOutput, readErr, outputFormat)
    }
    
    static func createSimpleCommand(cmd : String, args : [String], timeout: Double?) -> Command {
        return Command(cmd, args, timeout, false, false, nil)
    }
}

class MonitoredCommand: Command {
    
    static var callbackOpQueue: OperationQueue = {
        
        let queue = OperationQueue()
        queue.underlyingQueue = DispatchQueue.global(qos: .userInteractive)
        queue.maxConcurrentOperationCount = 2
        queue.qualityOfService = .userInteractive
        
        return queue
    }()
 
    var track: Track
    var errorDetected: Bool = false
    
    var enableMonitoring: Bool
    var callback: ((_ command: MonitoredCommand, _ output: String) -> Void)?
    
    var stdOutPipe: Pipe?
    var stdErrPipe: Pipe?
    var pipes: [Pipe] = []
    var registeredPipeCallback: Bool = false
    
    var cancelled: Bool = false
    
    var startTime: Date!
    
    init(_ track: Track, _ cmd : String, _ args : [String], _ qualityOfService: QualityOfService, _ timeout: Double?, _ callback: ((_ command: MonitoredCommand, _ output: String) -> Void)?, _ enableMonitoring: Bool, _ readOutput: Bool, _ readErr: Bool, _ outputType: CommandOutputType?) {
        
        self.track = track
        
        self.enableMonitoring = enableMonitoring
        self.callback = callback
        
        super.init(cmd, args, timeout, readOutput, readErr, outputType)
        
        self.stdOutPipe = process.standardOutput as? Pipe
        self.stdErrPipe = process.standardError as? Pipe
        self.pipes = [stdOutPipe, stdErrPipe].compactMap {$0}
    }
    
    func startMonitoring() {
        
        enableMonitoring = true
        
        if callback != nil && !registeredPipeCallback {
            
            pipes.forEach({self.registerCallbackForPipe($0)})
            registeredPipeCallback = true
        }
    }
    
    func stopMonitoring() {
        
        enableMonitoring = false
        
        if registeredPipeCallback {
            
            pipes.forEach({self.unregisterCallbackForPipe($0)})
            registeredPipeCallback = false
        }
    }
    
    private func registerCallbackForPipe(_ pipe: Pipe) {
        
        DispatchQueue.main.async {
            pipe.fileHandleForReading.waitForDataInBackgroundAndNotify()
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.NSFileHandleDataAvailable,
                                               object: pipe.fileHandleForReading, queue: MonitoredCommand.callbackOpQueue) {
                                                notification in
            
            if self.process.isRunning && self.enableMonitoring {
                
                // Gather output and invoke callback
                let output = pipe.fileHandleForReading.availableData
                let outputString = String(data: output, encoding: String.Encoding.utf8) ?? ""
                
                if let theCallback = self.callback {
                    theCallback(self, outputString)
                }
                
                // If not done on the main thread, this doesn't work.
                // TODO: Investigate this further.
                DispatchQueue.main.async {
                    
                    // Continue monitoring
                    pipe.fileHandleForReading.waitForDataInBackgroundAndNotify()
                }
            }
        }
    }
    
    private func unregisterCallbackForPipe(_ pipe: Pipe) {
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.NSFileHandleDataAvailable, object: pipe.fileHandleForReading)
    }
    
    static func create(track: Track, cmd : String, args : [String], qualityOfService: QualityOfService, timeout: Double?, callback: @escaping ((_ command: MonitoredCommand, _ output: String) -> Void), enableMonitoring: Bool) -> MonitoredCommand {
        
        return MonitoredCommand(track, cmd, args, qualityOfService, timeout, callback, enableMonitoring, false, false, nil)
    }
}

class CommandResult {
    
    var output: [String]?
    var outputAsObject: NSDictionary?
    var error: [String]
    var exitCode: Int32
    
    init(_ output: [String]?, _ error: [String], _ exitCode: Int32) {
        
        self.output = output
        self.error = error
        self.exitCode = exitCode
    }
    
    init(_ outputAsObject: NSDictionary?, _ error: [String], _ exitCode: Int32) {
        
        self.outputAsObject = outputAsObject
        self.error = error
        self.exitCode = exitCode
    }
}

enum CommandOutputType {
    
    case lines
    case json
}
