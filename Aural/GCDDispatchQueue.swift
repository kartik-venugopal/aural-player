
import Cocoa

/*
    Encapsulates a GCD dispatch queue with convenient initialization
 
    TODO: Get rid of this class
*/
class GCDDispatchQueue {
    
    var underlyingQueue: DispatchQueue
    fileprivate static let defaultCustomQueueName: String = "Aural.queues.default"
    
    init(queueName: String) {
        // Assume custom queue
        self.underlyingQueue = DispatchQueue(label: queueName, attributes: [])
    }
    
    // TODO: Find out who calls this init and make callers specify qos
    init(queueType: QueueType, _ qos: DispatchQoS.QoSClass = .default) {
        
        // Intended to be used for main or global queue, but if custom queue, use the default custom queue name
        switch queueType {
            
        case .main: self.underlyingQueue = DispatchQueue.main
            
        case .global: self.underlyingQueue = DispatchQueue.global(qos: qos)
            
        case .custom: self.underlyingQueue = DispatchQueue(label: GCDDispatchQueue.defaultCustomQueueName, attributes: [])
        }
    }
}

// GCD dispatch queue type
enum QueueType {
    
    case main
    case global
    case custom
}
