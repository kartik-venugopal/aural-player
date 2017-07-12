
import Cocoa

/*
    Helper class to dispatch a block of code for asynchronous execution to a GCD dispatch queue
*/
class AsyncExecutor {
    
    // Execute a block of code asynchronously
    static func execute(block: () -> Void) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), { () -> Void in
            
            block()
        })
    }
}
