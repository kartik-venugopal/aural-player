import Foundation

class CommandExecutor {
    
    static let cancellationExitCode: Int32 = -1
    
    static func execute(_ cmd: Command) -> CommandResult {
        
        var output : [String] = []
        var error : [String] = []
        
        let task = cmd.process
        
        cmd.startTime = Date()
        task.launch()
        
        // End task after timeout interval
        if let timeout = cmd.timeout {
            
            DispatchQueue.global(qos: .userInteractive).asyncAfter(deadline: .now() + timeout, execute: {
                task.terminate()
            })
        }
        
        task.waitUntilExit()
        
        if cmd.cancelled {
            // Task may have been canceled
            return CommandResult(output, error, cancellationExitCode)
        }
        
        let status = task.terminationStatus
        
        if cmd.readOutput {
            
            let outpipe = task.standardOutput as! Pipe
            
            let outdata = outpipe.fileHandleForReading.readDataToEndOfFile()
            if var string = String(data: outdata, encoding: .utf8) {
                string = string.trimmingCharacters(in: .newlines)
                output = string.components(separatedBy: "\n")
            }
        }
        
        if cmd.readErr {
            
            let errpipe = task.standardError as! Pipe
            
            let errdata = errpipe.fileHandleForReading.readDataToEndOfFile()
            if var string = String(data: errdata, encoding: .utf8) {
                string = string.trimmingCharacters(in: .newlines)
                error = string.components(separatedBy: "\n")
            }
        }
        
        return CommandResult(output, error, status)
    }
    
    static func cancel(_ cmd: Command) {
        
        if cmd.process.isRunning {
            cmd.process.terminate()
        }
        
        cmd.cancelled = true
        cmd.enableMonitoring = false
    }
}

class Command {
 
    var track: Track
    var process: Process
    var timeout: Double?
    var readOutput: Bool
    var readErr: Bool
    var errorDetected: Bool = false
    
    var enableMonitoring: Bool
    var callback: ((_ command: Command, _ output: String) -> Void)?
    
    var cancelled: Bool = false
    
    var startTime: Date!
    
    init(_ track: Track, _ cmd : String, _ args : [String], _ qualityOfService: QualityOfService, _ timeout: Double?, _ callback: ((_ command: Command, _ output: String) -> Void)?, _ enableMonitoring: Bool, _ readOutput: Bool, _ readErr: Bool) {
        
        self.track = track
        
        process = Process()
        process.launchPath = cmd
        process.arguments = args
        process.qualityOfService = qualityOfService
        
        self.timeout = timeout
        
        self.enableMonitoring = enableMonitoring
        self.callback = callback
        
        self.readOutput = readOutput
        self.readErr = readErr
        
        if callback != nil || (readOutput || readErr) {
            
            let outpipe = Pipe()
            process.standardOutput = outpipe
            
            let errpipe = Pipe()
            process.standardError = errpipe
            
            if enableMonitoring && callback != nil {
                registerCallbackForPipe(outpipe)
                registerCallbackForPipe(errpipe)
            }
        }
    }
    
    func startMonitoring() {
        
        if !enableMonitoring && callback != nil {
            
            enableMonitoring = true
            
            registerCallbackForPipe(process.standardOutput as! Pipe)
            registerCallbackForPipe(process.standardError as! Pipe)
        }
    }
    
    func stopMonitoring() {
        enableMonitoring = false
    }
    
    private func registerCallbackForPipe(_ pipe: Pipe) {
        
        pipe.fileHandleForReading.waitForDataInBackgroundAndNotify()
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.NSFileHandleDataAvailable, object: pipe.fileHandleForReading , queue: nil) {
            notification in
            
            if self.process.isRunning && self.enableMonitoring {
                
                // Gather output and invoke callback
                let output = pipe.fileHandleForReading.availableData
                let outputString = String(data: output, encoding: String.Encoding.utf8) ?? ""
                
                self.callback!(self, outputString)
                
                // Continue monitoring
                pipe.fileHandleForReading.waitForDataInBackgroundAndNotify()
            }
        }
    }
    
    static func createMonitoredCommand(track: Track, cmd : String, args : [String], qualityOfService: QualityOfService, timeout: Double?, callback: @escaping ((_ command: Command, _ output: String) -> Void), enableMonitoring: Bool) -> Command {
        
        return Command(track, cmd, args, qualityOfService, timeout, callback, enableMonitoring, false, false)
    }
    
    static func createCommandWithOutput(track: Track, cmd : String, args : [String], qualityOfService: QualityOfService, timeout: Double?, readOutput: Bool, readErr: Bool) -> Command {
        
        return Command(track, cmd, args, qualityOfService, timeout, nil, false, readOutput, readErr)
    }
    
    static func createSimpleCommand(track: Track, cmd : String, args : [String], qualityOfService: QualityOfService, timeout: Double?) -> Command {
        
        return Command(track, cmd, args, qualityOfService, timeout, nil, false, false, false)
    }
}

class CommandResult {

    var output: [String]
    var error: [String]
    var exitCode: Int32
    
    init(_ output: [String], _ error: [String], _ exitCode: Int32) {
        
        self.output = output
        self.error = error
        self.exitCode = exitCode
    }
}
