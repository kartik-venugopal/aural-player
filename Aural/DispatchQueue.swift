
import Cocoa

/*
    Encapsulates a GCD dispatch queue with convenient initialization
*/
class DispatchQueue {
    
    var underlyingQueue: Dispatch.DispatchQueue!
    fileprivate static let defaultCustomQueueName: String = "Aural.queues.default"
    
    init(queueName: String) {
        // Assume custom queue
        self.underlyingQueue = DispatchQueue(label: queueName, attributes: [])
    }
    
    init(queueType: QueueType) {
        
        // Intended to be used for main or global queue, but if custom queue, use the default custom queue name
        switch queueType {
        case .main: self.underlyingQueue = DispatchQueue.main
        case .global: self.underlyingQueue = DispatchQueue.global(priority: 0)
        case .custom: self.underlyingQueue = DispatchQueue(label: DispatchQueue.defaultCustomQueueName, attributes: [])
        }
    }
}

// GCD dispatch queue type
enum QueueType {
    
    case main
    case global
    case custom
}
