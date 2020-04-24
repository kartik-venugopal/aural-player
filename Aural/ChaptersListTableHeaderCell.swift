import Cocoa

class ChaptersListTableHeaderCell: NSTableHeaderCell {
    
    override func draw(withFrame cellFrame: NSRect, in controlView: NSView) {
        
        let cellPath = NSBezierPath(roundedRect: cellFrame, xRadius: 0, yRadius: 0)
        Colors.windowBackgroundColor.setFill()
        cellPath.fill()
        
        let attrs: [String: AnyObject] = [
            convertFromNSAttributedStringKey(NSAttributedString.Key.font): Fonts.Playlist.chaptersListHeaderFont,
            convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor): Colors.Playlist.summaryInfoColor]
        
        let attrsDict = convertToOptionalNSAttributedStringKeyDictionary(attrs)
        
        let size: CGSize = stringValue.size(withAttributes: attrsDict)
        
        // Calculate the x co-ordinate for text rendering, according to its intended aligment
        var x: CGFloat = 0
        
        switch stringValue {
            
        case "#":
            
            // Center alignment
            x = cellFrame.maxX - (cellFrame.width / 2) - (size.width / 2)
            
        case "Title":
            
            // Left alignment
            x = cellFrame.minX
            
        case "Start Time", "Duration":
            
            // Right alignment
            x = cellFrame.maxX - size.width - 5
            
        default:
            
            return
        }
    
        let rect = NSRect(x: x, y: cellFrame.minY, width: size.width, height: cellFrame.height)
        stringValue.draw(in: rect, withAttributes: attrsDict)
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
