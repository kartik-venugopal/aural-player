/*
    Customizes the look and feel of buttons that control the Effects tab group
 */

import Cocoa

@IBDesignable
class OnOffImageAndTextButtonCell: NSButtonCell {
    
    // Highlighting colors the button text to indicate that the effects unit represented by this button is currently active
    var shouldHighlight: Bool = false
    @IBInspectable var highlightColor: NSColor = Colors.tabViewButtonTextColor
    
    private let borderInsetX: CGFloat = 0
    private let borderInsetY: CGFloat = 2
    private let borderRadius: CGFloat = 2
    
    private let backgroundFillColor: NSColor = Colors.tabViewButtonBackgroundColor
    private let selectionBoxColor: NSColor = Colors.tabViewSelectionBoxColor
    
    private let unselectedTextColor: NSColor = Colors.tabViewButtonTextColor
    private let selectedTextColor: NSColor = Colors.playlistSelectedTextColor
    private let textFont: NSFont = Fonts.tabViewButtonFont_small
    private let boldTextFont: NSFont = Fonts.tabViewButtonBoldFont_small
    
    private let imgWidth: CGFloat = 11, imgHeight: CGFloat = 11
    
    override func drawInterior(withFrame cellFrame: NSRect, in controlView: NSView) {
        
        // Background
        backgroundFillColor.setFill()
        NSBezierPath.init(rect: cellFrame).fill()
        
        // Selection box
        if (state.rawValue == 1) {
            
            let drawRect = cellFrame.insetBy(dx: borderInsetX, dy: borderInsetY)
            selectionBoxColor.setFill()
            NSBezierPath.init(roundedRect: drawRect, xRadius: borderRadius, yRadius: borderRadius).fill()
        }
        
        // Title
        let textColor = shouldHighlight ? highlightColor : (state.rawValue == 0 ? unselectedTextColor : selectedTextColor)
        let font = state.rawValue == 1 ? boldTextFont : textFont
        
        let attrs: [String: AnyObject] = [
            convertFromNSAttributedStringKey(NSAttributedString.Key.font): font,
            convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor): textColor]
        
        // Draw image (left aligned)
        let rectWidth: CGFloat = cellFrame.width, rectHeight: CGFloat = cellFrame.height
        let xInset = (rectWidth - imgWidth) / 2
        let yInset = (rectHeight - imgHeight) / 2
        
        let imgRect = cellFrame.insetBy(dx: xInset, dy: yInset).offsetBy(dx: -(rectWidth / 2) + imgWidth - 1, dy: 0)
        self.image?.draw(in: imgRect)
        
        // Compute text size and position
        let size: CGSize = self.title.size(withAttributes: convertToOptionalNSAttributedStringKeyDictionary(attrs))
        let sx: CGFloat = self.image != nil ? imgRect.maxX + 4 : (rectWidth - size.width) / 2
        let sy = cellFrame.height - size.height - 5
        
        // Draw title (adjacent to image)
        self.title.draw(in: NSRect(x: sx, y: sy, width: size.width, height: size.height), withAttributes: convertToOptionalNSAttributedStringKeyDictionary(attrs))
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
