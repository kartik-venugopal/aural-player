
import Cocoa

/*
    Encapsulates a GCD dispatch queue with convenient initialization
*/
class DispatchQueue {
    
    var underlyingQueue: dispatch_queue_t!
    private static let defaultCustomQueueName: String = "Aural.queues.default"
    
    init(queueName: String) {
        // Assume custom queue
        self.underlyingQueue = dispatch_queue_create(queueName, nil)
    }
    
    init(queueType: QueueType) {
        
        // Intended to be used for main or global queue, but if custom queue, use the default custom queue name
        switch queueType {
        case .MAIN: self.underlyingQueue = dispatch_get_main_queue()
        case .GLOBAL: self.underlyingQueue = dispatch_get_global_queue(0, 0)
        case .CUSTOM: self.underlyingQueue = dispatch_queue_create(DispatchQueue.defaultCustomQueueName, nil)
        }
    }
}

// GCD dispatch queue type
enum QueueType {
    
    case MAIN
    case GLOBAL
    case CUSTOM
}