import Cocoa

@IBDesignable
class EffectsUnitTabButtonCell: NSButtonCell {
    
    private let borderInsetX: CGFloat = 0
    private let borderInsetY: CGFloat = 2
    private let borderRadius: CGFloat = 3
    
    private var backgroundFillColor: NSColor {return Colors.Effects.tabButtonColor}
    private var selectionBoxColor: NSColor {return Colors.Effects.selectedTabButtonColor}
    
    var unitState: EffectsUnitState = .bypassed
    
    private let imgWidth: CGFloat = 16, imgHeight: CGFloat = 16
    
    override func drawInterior(withFrame cellFrame: NSRect, in controlView: NSView) {
        
        // Background
        backgroundFillColor.setFill()
        NSBezierPath.init(rect: cellFrame).fill()
        
        // Selection box
        if isOn {
            
            let drawRect = cellFrame.insetBy(dx: borderInsetX, dy: borderInsetY)
            selectionBoxColor.setFill()
            NSBezierPath.init(roundedRect: drawRect, xRadius: borderRadius, yRadius: borderRadius).fill()
        }
        
        // Draw image (left aligned)
        let rectWidth: CGFloat = cellFrame.width, rectHeight: CGFloat = cellFrame.height
        let xInset = (rectWidth - imgWidth) / 2
        let yInset = (rectHeight - imgHeight) / 2
        
        let imgRect = cellFrame.insetBy(dx: xInset, dy: yInset)
        self.image?.draw(in: imgRect)
    }
}
