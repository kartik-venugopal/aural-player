import Cocoa

class ChaptersListTableHeaderCell: NSTableHeaderCell {
    
    static var painInTheAssRect: NSRect?
    
    override func drawInterior(withFrame cellFrame: NSRect, in controlView: NSView) {
        print("drawInterior")
    }
    
    override func draw(withFrame cellFrame: NSRect, in controlView: NSView) {
        
        let cellPath = NSBezierPath(roundedRect: cellFrame, xRadius: 0, yRadius: 0)
        ColorSchemes.systemScheme.general.backgroundColor.setFill()
        cellPath.fill()
        
        let size = StringUtils.sizeOfString(stringValue, Fonts.Playlist.groupNameFont)
        
        var x: CGFloat = 0
        
        switch stringValue {
            
        case "#":
            
            x = cellFrame.maxX - (cellFrame.width / 2) - (size.width / 2)
            
        case "Title":
            
            x = cellFrame.minX
            
        case "Start Time", "Duration":
            
            x = cellFrame.maxX - size.width - 5
            
        default:
            
            return
        }
        
        let attrs: [String: AnyObject] = [
            convertFromNSAttributedStringKey(NSAttributedString.Key.font): Fonts.Playlist.groupNameFont,
            convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor): Colors.Playlist.groupNameTextColor]
    
        let rect = NSRect(x: x, y: cellFrame.minY, width: size.width, height: cellFrame.height)
        stringValue.draw(in: rect, withAttributes: convertToOptionalNSAttributedStringKeyDictionary(attrs))
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
