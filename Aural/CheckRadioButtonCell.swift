/*
    Customizes the look n feel of check and radio buttons on all modal dialogs
 */
import Cocoa

class CheckRadioButtonCell: NSButtonCell {
    
    override func drawTitle(_ title: NSAttributedString, withFrame frame: NSRect, in controlView: NSView) -> NSRect {
        
        let textColor = state.rawValue == 0 ? Colors.boxTextColor : Colors.playlistSelectedTextColor
        let attrs: [NSAttributedStringKey: Any] = [
            .font: UIConstants.checkRadioButtonFont,
            .foregroundColor: textColor]
        
        let titleText = title.string
        
        let size: CGSize = titleText.size(withAttributes: attrs)
        let sx = frame.minX
        let sy = frame.minY + (frame.height - size.height) / 2 - 2
        
        let textRect = NSRect(x: sx, y: sy, width: size.width, height: size.height)
        titleText.draw(in: textRect, withAttributes: attrs)
        
        return frame
    }
}
