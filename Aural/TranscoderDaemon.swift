import Foundation

class TranscoderDaemon {
    
    let immediateExecutionQueue: DispatchQueue = DispatchQueue.global(qos: .userInteractive)
    let backgroundExecutionQueue: DispatchQueue = DispatchQueue.global(qos: .background)

    func submitTask(_ task: @escaping (() -> Void), _ priority: TranscoderPriority) {
        
        if priority == .immediate {
            immediateExecutionQueue.async(execute: task)
        } else {
            backgroundExecutionQueue.async(execute: task)
        }
    }
    
}

enum TranscoderPriority {
    
    case immediate
    case background
}
