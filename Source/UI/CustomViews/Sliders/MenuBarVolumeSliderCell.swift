import Cocoa

class MenuBarVolumeSliderCell: VolumeSliderCell {
    
    override var knobColor: NSColor {Colors.Constants.white70Percent}
    override var barRadius: CGFloat {0}
    override var knobRadius: CGFloat {0}
    
    override internal func drawBar(inside aRect: NSRect, flipped: Bool) {
        
        let knobFrame = knobRect(flipped: false)
        let halfKnobWidth = knobFrame.width / 2
        
        let leftRect = NSRect(x: aRect.minX, y: aRect.minY, width: max(halfKnobWidth, knobFrame.minX + halfKnobWidth), height: aRect.height)
        Colors.Constants.white70Percent.setFill()
        leftRect.fill()
        
        let rightRect = NSRect(x: knobFrame.maxX - halfKnobWidth, y: aRect.minY, width: aRect.width - (knobFrame.maxX - halfKnobWidth), height: aRect.height)
        Colors.Constants.white30Percent.setFill()
        rightRect.fill()
    }
}
