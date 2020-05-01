import Cocoa

@IBDesignable
class EffectsUnitTabButtonCell: NSButtonCell {
    
    private let borderInsetX: CGFloat = 0
    private let borderInsetY: CGFloat = 2
    private let borderRadius: CGFloat = 3
    
    private var selectionBoxColor: NSColor {return Colors.selectedTabButtonColor}
    
    var unitState: EffectsUnitState = .bypassed
    
    private let imgWidth: CGFloat = 14, imgHeight: CGFloat = 14
    
    override func draw(withFrame cellFrame: NSRect, in controlView: NSView) {
        drawInterior(withFrame: cellFrame, in: controlView)
    }
    
    override func drawInterior(withFrame cellFrame: NSRect, in controlView: NSView) {
        
        // Draw image (left aligned)
        let rectWidth: CGFloat = cellFrame.width, rectHeight: CGFloat = cellFrame.height
        let xInset = (rectWidth - imgWidth) / 2
        let yInset = (rectHeight - imgHeight) / 2
        
        // Raise the selected tab image by a few pixels so it is prominent
        let imgRect = cellFrame.insetBy(dx: xInset, dy: yInset).offsetBy(dx: 0, dy: isOn ? -2 : 0)
        self.image?.draw(in: imgRect)
        
        // Selection underline
        if isOn {
            
            let drawRect = NSRect(x: cellFrame.centerX - (imgRect.width / 2), y: cellFrame.maxY - 2, width: imgRect.width, height: 2)
            
            selectionBoxColor.setFill()
            drawRect.fill()
        }
    }
}
