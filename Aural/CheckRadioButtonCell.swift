import Cocoa

class CheckRadioButtonCell: NSButtonCell {
    
    override func drawTitle(_ title: NSAttributedString, withFrame frame: NSRect, in controlView: NSView) -> NSRect {
        
        let textColor = state == 0 ? UIConstants.colorScheme.boxTextColor : UIConstants.colorScheme.playlistSelectedTextColor
        let attrs: [String: AnyObject] = [
            NSFontAttributeName: UIConstants.checkRadioButtonFont,
            NSForegroundColorAttributeName: textColor]
        
        let titleText = title.string
        
        let size: CGSize = titleText.size(withAttributes: attrs)
        let sx = frame.minX
        let sy = frame.minY + (frame.height - size.height) / 2 - 2
        
        let textRect = NSRect(x: sx, y: sy, width: size.width, height: size.height)
        titleText.draw(in: textRect, withAttributes: attrs)
        
        return frame
    }
}
