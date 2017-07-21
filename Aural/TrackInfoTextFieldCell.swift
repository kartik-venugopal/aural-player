import Cocoa

// TODO: Implement this so that text is vertically center-aligned
class TrackInfoTextFieldCell: NSTextFieldCell {
    
        override func drawingRect(forBounds rect: NSRect) -> NSRect {
            
//            let text: NSString = (self.controlView as! NSTextField).stringValue as NSString
//            
//            let size: CGSize = text.size(withAttributes: [NSFontAttributeName: UIConstants.popoverValueFont as AnyObject])
//            
//            var height: CGFloat
//            
//            if (size.width > UIConstants.trackInfoValueColumnWidth) {
//                
//                let rows = Int(size.width / UIConstants.trackInfoValueColumnWidth) + 1
//                // This means the text has wrapped over to the second line
//                // So, increase the row height
//                height = CGFloat(rows) * UIConstants.trackInfoValueRowHeight * UIConstants.trackInfoLongValueRowHeightMultiplier
//            } else {
//                // No wrap, one row height is enough
//                height = UIConstants.trackInfoValueRowHeight
//            }
//            
//            print(rect)
//            
//            let newRect = NSRect(x: 0, y: -10, width: rect.size.width, height: height)
//            
            return super.drawingRect(forBounds: rect)
        }
}
