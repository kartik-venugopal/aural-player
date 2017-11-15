/*
    Customizes the look and feel of buttons that control the Effects tab group
 */

import Cocoa

class OnOffImageAndTextButtonCell: NSButtonCell {
    
    // Highlighting colors the button text to indicate that the effects unit represented by this button is currently active
    var shouldHighlight: Bool = false
    var highlightColor: NSColor = Colors.tabViewButtonTextColor
    
    private let backgroundFillColor: NSColor = Colors.tabViewButtonBackgroundColor
    private let borderInsetX: CGFloat = 1
    private let borderInsetY: CGFloat = 1
    private let borderRadius: CGFloat = 2
    private let borderLineWidth: CGFloat = 1.5
    private let borderStrokeColor: NSColor = Colors.tabViewButtonOutlineColor
    private let selectionBoxColor: NSColor = Colors.tabViewSelectionBoxColor
    
    private let unselectedTextColor: NSColor = Colors.tabViewButtonTextColor
    private let selectedTextColor: NSColor = Colors.playlistSelectedTextColor
    private let textFont: NSFont = Fonts.tabViewButtonFont
    private let boldTextFont: NSFont = Fonts.tabViewButtonBoldFont
    private let imgWidth: CGFloat = 12, imgHeight: CGFloat = 12
    
    override func drawInterior(withFrame cellFrame: NSRect, in controlView: NSView) {
        
        // Background
        backgroundFillColor.setFill()
        NSBezierPath.init(rect: cellFrame).fill()
        
        // Selection box
        if (state == 1) {
            
            let drawRect = cellFrame.insetBy(dx: borderInsetX, dy: borderInsetY)
            selectionBoxColor.setFill()
            NSBezierPath.init(roundedRect: drawRect, xRadius: borderRadius, yRadius: borderRadius).fill()
        }
        
        // Title
        let textColor = shouldHighlight ? highlightColor : (state == 0 ? unselectedTextColor : selectedTextColor)
        let font = state == 1 ? boldTextFont : textFont
        
        let attrs: [String: AnyObject] = [
            NSFontAttributeName: font,
            NSForegroundColorAttributeName: textColor]
        
        // Compute text size and position
        let size: CGSize = self.title.size(withAttributes: attrs)
        let sx: CGFloat = 22
        let sy = cellFrame.height - size.height - 5
        
        // Draw title (adjacent to image)
        self.title.draw(in: NSRect(x: sx, y: sy, width: size.width, height: size.height), withAttributes: attrs)
        
        // Draw image (left aligned)
        let rectWidth: CGFloat = cellFrame.width, rectHeight: CGFloat = cellFrame.height
        
        let xInset = (rectWidth - imgWidth) / 2
        let yInset = (rectHeight - imgHeight) / 2
        
        let imgRect = cellFrame.insetBy(dx: xInset, dy: yInset).offsetBy(dx: -(rectWidth / 2) + 12, dy: 0)
        self.image?.draw(in: imgRect)
    }
}

class MultiImageButton: NSButton {
    
    var offStateImage: NSImage?
    var onStateImage: NSImage?
}
