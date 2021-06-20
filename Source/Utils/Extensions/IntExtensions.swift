import Foundation

extension Int {
    
    static let ascendingIntComparator: (Int, Int) -> Bool = {$0 < $1}
    static let descendingIntComparator: (Int, Int) -> Bool = {$0 > $1}
    
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
    
    mutating func clamp(minValue: Self, maxValue: Self) {
        
        if self < minValue {
            self = minValue
            
        } else if self > maxValue {
            self = maxValue
        }
    }
    
    mutating func clamp(minValue: Self) {
        
        if self < minValue {
            self = minValue
        }
    }
    
    mutating func clamp(maxValue: Self) {
        
        if self > maxValue {
            self = maxValue
        }
    }
}
