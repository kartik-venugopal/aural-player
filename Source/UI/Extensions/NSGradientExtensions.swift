import Cocoa

extension NSGradient {
    
    // Returns an NSGradient with the start/end colors of this NSGradient reversed.
    func reversed() -> NSGradient {
        
        var start: NSColor = NSColor.white
        self.getColor(&start, location: nil, at: 0)
        
        var end: NSColor = NSColor.black
        self.getColor(&end, location: nil, at: 1)
        
        return NSGradient(starting: end, ending: start)!
    }
}
