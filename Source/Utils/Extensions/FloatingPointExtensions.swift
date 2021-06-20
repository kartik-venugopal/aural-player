import Foundation

extension FloatingPoint {
    
    func clamp(to range: ClosedRange<Self>) -> Self {
        
        if range.contains(self) {return self}
        
        if self < range.lowerBound {
            return range.lowerBound
        }
        
        if self > range.upperBound {
            return range.upperBound
        }
        
        return self
    }
}
