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

extension Double {
    
    var roundedInt: Int {lround(self)}
    
    var floorInt: Int {Int(floor(self))}
}

extension Float {
    
    var roundedInt: Int {lroundf(self)}
    
    var floorInt: Int {Int(floorf(self))}
}

extension CGFloat {
    var roundedInt: Int {lroundf(Float(self))}
}
