import Cocoa

class ConcurrencyUtils {
    
    static func executeSynchronized(_ lock: Any, closure: () -> Void) {
        
        objc_sync_enter(lock)
        closure()
        objc_sync_exit(lock)
    }
}

