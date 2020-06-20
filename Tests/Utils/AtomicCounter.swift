import Foundation

class AtomicCounter {
    
    private (set) var value : Int = 0
    
    func increment() {
        
        ConcurrencyUtils.executeSynchronized(self, closure: {
            value.increment()
        })
    }
    
    func incrementAndGet() -> Int {
        
        var returnValue: Int = value
        
        ConcurrencyUtils.executeSynchronized(self, closure: {
            value.increment()
            returnValue = value
        })
        
        return returnValue
    }
    
    func getAndIncrement() -> Int {
        
        var returnValue: Int = value
        
        ConcurrencyUtils.executeSynchronized(self, closure: {
            returnValue = value
            value.increment()
        })
        
        return returnValue
    }
}
