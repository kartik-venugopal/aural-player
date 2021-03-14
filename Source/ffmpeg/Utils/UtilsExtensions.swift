import Foundation

///
/// Extensions that provide helper functions or properties for added convenience.
///

extension Int {
    
    mutating func clamp(minValue: Self, maxValue: Self) {
        
        if self < minValue {
            self = minValue
            
        } else if self > maxValue {
            self = maxValue
        }
    }
    
    func clampedTo(range: ClosedRange<Int>) -> Int {
        
        if range.contains(self) {return self}
        
        if self < range.lowerBound {
            return range.lowerBound
        }
        
        return range.upperBound
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

///
/// Measures the execution time of a code block, in seconds.
/// Useful for estimating performance of a function or code block.
///
/// - Parameter task: The code block whose execution time is to be measured.
///
func measureExecutionTime(_ task: () -> Void) -> Double {
    
    let startTime = CFAbsoluteTimeGetCurrent()
    task()
    return CFAbsoluteTimeGetCurrent() - startTime
}

func measureTimeTry(_ task: () throws -> Void) throws -> Double {
    
    let startTime = CFAbsoluteTimeGetCurrent()
    try task()
    return CFAbsoluteTimeGetCurrent() - startTime
}
