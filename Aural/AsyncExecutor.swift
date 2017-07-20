
import Cocoa

/*
    Helper class to dispatch a block of code for asynchronous execution to a GCD dispatch queue
*/
class AsyncExecutor {
    
    // Execute a block of code asynchronously
    static func execute(_ block: @escaping () -> Void, dispatchQueue: GCDDispatchQueue) {
        
        dispatchQueue.underlyingQueue.async(execute: { () -> Void in
            block()
        })
    }
}
