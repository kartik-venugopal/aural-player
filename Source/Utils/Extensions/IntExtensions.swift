import Foundation

extension Int {
    
    mutating func increment() {
        self += 1
    }
    
    mutating func incrementAndGet() -> Int {
        
        self += 1
        return self
    }
    
    mutating func decrement() {
        self -= 1
    }
    
    mutating func decrementAndGet() -> Int {
        
        self -= 1
        return self
    }
}
