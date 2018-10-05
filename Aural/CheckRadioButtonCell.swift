/*
    Customizes the look n feel of check and radio buttons on all modal dialogs
 */
import Cocoa

class CheckRadioButtonCell: NSButtonCell {
    
    override func drawTitle(_ title: NSAttributedString, withFrame frame: NSRect, in controlView: NSView) -> NSRect {
        
        let textColor = state.rawValue == 0 ? Colors.boxTextColor : Colors.playlistSelectedTextColor
        let attrs: [String: AnyObject] = [
            convertFromNSAttributedStringKey(NSAttributedString.Key.font): Fonts.checkRadioButtonFont,
            convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor): textColor]
        
        let titleText = title.string
        
        let size: CGSize = titleText.size(withAttributes: convertToOptionalNSAttributedStringKeyDictionary(attrs))
        let sx = frame.minX
        let sy = frame.minY + (frame.height - size.height) / 2 - 2
        
        let textRect = NSRect(x: sx, y: sy, width: size.width, height: size.height)
        titleText.draw(in: textRect, withAttributes: convertToOptionalNSAttributedStringKeyDictionary(attrs))
        
        return frame
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
	return input.rawValue
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}
