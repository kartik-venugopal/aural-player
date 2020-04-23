import Cocoa

class ChaptersListTableHeaderCell: NSTableHeaderCell {
    
    override func drawInterior(withFrame cellFrame: NSRect, in controlView: NSView) {
        print("drawInterior")
    }
    
    override func draw(withFrame cellFrame: NSRect, in controlView: NSView) {
        
        let attrs: [String: AnyObject] = [
            convertFromNSAttributedStringKey(NSAttributedString.Key.font): Fonts.Playlist.groupNameFont,
            convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor): Colors.Playlist.groupNameTextColor]
        
        stringValue.draw(in: cellFrame.insetBy(dx: 1, dy: 1), withAttributes: convertToOptionalNSAttributedStringKeyDictionary(attrs))
        
        controlView.isHidden = true
        
//        // Bottom line
//        let drawRect = cellFrame.insetBy(dx: 0, dy: 16).offsetBy(dx: 0, dy: 10)
//        let roundedPath = NSBezierPath.init(rect: drawRect)
//
//        let lineColor = Colors.Constants.white30Percent
//        lineColor.setFill()
//        roundedPath.fill()
//
//        // Right Partition line
//        let cw = cellFrame.width
//        let pline = cellFrame.insetBy(dx: cw / 2 - 1.5, dy: 5).offsetBy(dx: cw / 2 - 3, dy: -3)
//
//        let path = NSBezierPath.init(rect: pline)
//        lineColor.setFill()
//        path.fill()
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
