import Foundation

class TranscoderDaemon {
    
    let immediateExecutionQueue: DispatchQueue = DispatchQueue.global(qos: .userInteractive)
    let backgroundExecutionQueue: DispatchQueue = DispatchQueue.global(qos: .background)
    
    var map: [Track: Command] = [:]

    func submitTask(_ track: Track, _ command: Command, _ successHandler: @escaping (() -> Void), _ failureHandler: @escaping (() -> Void), _ cancellationHandler: @escaping (() -> Void), _ priority: TranscoderPriority) {
        
        let task = {
            
            let result = CommandExecutor.execute(command)
            
            if command.cancelled {
                cancellationHandler()
                return
            }
            
            if result.exitCode == 0 {
                // Success
                successHandler()
            } else {
                failureHandler()
            }
        }
        
        if priority == .immediate {
            immediateExecutionQueue.async(execute: task)
        } else {
            backgroundExecutionQueue.async(execute: task)
        }
        
        map[track] = command
    }
    
    func cancelTask(_ track: Track) {
        
        if let task = map[track] {
            CommandExecutor.cancel(task)
        }
    }
}

//class TranscodingTask {
//
//    var track: Track
//    var command: Command
//    var startTime: Date
//    var successHandler: (() -> Void)
//    var failureHandler: (() -> Void)
//
//
//}

enum TranscoderPriority {
    
    case immediate
    case background
}
