import Foundation

extension Int {
    
    mutating func increment() {
        self += 1
    }
    
    mutating func incrementAndGet() -> Int {
        
        self += 1
        return self
    }
    
    mutating func getAndIncrement() -> Int {
        
        let returnValue = self
        self += 1
        return returnValue
    }
    
    mutating func decrement() {
        self -= 1
    }
    
    mutating func decrementAndGet() -> Int {
        
        self -= 1
        return self
    }
    
    mutating func getAndDecrement() -> Int {
        
        let returnValue = self
        self -= 1
        return returnValue
    }
}
