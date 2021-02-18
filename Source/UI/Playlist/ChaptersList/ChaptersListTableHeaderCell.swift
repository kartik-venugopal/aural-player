import Cocoa

class ChaptersListTableHeaderCell: NSTableHeaderCell {
    
    override func draw(withFrame cellFrame: NSRect, in controlView: NSView) {
        
        Colors.windowBackgroundColor.setFill()
        cellFrame.fill()
        
        let attrsDict: [NSAttributedString.Key: Any] = [
            .font: FontSets.systemFontSet.playlist.chaptersListHeaderFont,
            .foregroundColor: Colors.Playlist.summaryInfoColor]
        
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
