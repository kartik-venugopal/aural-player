import Cocoa

extension NSRect {
    
    var centerX: CGFloat {
        return self.minX + (self.width / 2)
    }
    
    var centerY: CGFloat {
        return self.minY + (self.height / 2)
    }
}
