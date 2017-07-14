
import Cocoa

/*
    Helper class to dispatch a block of code for asynchronous execution to a GCD dispatch queue
*/
class AsyncExecutor {
    
    // Execute a block of code asynchronously
    static func execute(block: () -> Void, dispatchQueue: DispatchQueue) {
        
        dispatch_async(dispatchQueue.underlyingQueue, { () -> Void in
            block()
        })
    }
}
