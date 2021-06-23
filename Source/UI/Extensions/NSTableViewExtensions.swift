import Cocoa

extension NSTableView {
    
    func enableDragDrop() {
        self.registerForDraggedTypes([.data, .file_URL])
    }
    
    func pageUp() {
        
        // Determine if the first row currently displayed has been truncated so it is not fully visible
        let visibleRect = self.visibleRect
        
        let firstRowShown = self.rows(in: visibleRect).lowerBound
        let firstRowShownRect = self.rect(ofRow: firstRowShown)
        
        let truncationAmount =  visibleRect.minY - firstRowShownRect.minY
        let truncationRatio = truncationAmount / firstRowShownRect.height
        
        // If the first row currently displayed has been truncated more than 10%, show it again in the next page
        
        let lastRowToShow = truncationRatio > 0.1 ? firstRowShown : firstRowShown - 1
        let lastRowToShowRect = self.rect(ofRow: lastRowToShow)
        
        // Calculate the scroll amount, as a function of the last row to show next, using the visible rect origin (i.e. the top of the first row in the playlist) as the stopping point
        
        let scrollAmount = min(visibleRect.origin.y, visibleRect.maxY - lastRowToShowRect.maxY)
        
        if scrollAmount > 0 {
            
            let up = visibleRect.origin.applying(CGAffineTransform.init(translationX: 0, y: -scrollAmount))
            self.enclosingScrollView?.contentView.scroll(to: up)
        }
    }
    
    func pageDown() {
        
        // Determine if the last row currently displayed has been truncated so it is not fully visible
        let visibleRect = self.visibleRect
        let visibleRows = self.rows(in: visibleRect)
        
        let lastRowShown = visibleRows.lowerBound + visibleRows.length - 1
        let lastRowShownRect = self.rect(ofRow: lastRowShown)
        
        let lastRowInPlaylistRect = self.rect(ofRow: self.numberOfRows - 1)
        
        // If the first row currently displayed has been truncated more than 10%, show it again in the next page
        
        let truncationAmount = lastRowShownRect.maxY - visibleRect.maxY
        let truncationRatio = truncationAmount / lastRowShownRect.height
        
        let firstRowToShow = truncationRatio > 0.1 ? lastRowShown : lastRowShown + 1
        let firstRowToShowRect = self.rect(ofRow: firstRowToShow)
        
        // Calculate the scroll amount, as a function of the first row to show next, using the visible rect maxY (i.e. the bottom of the last row in the playlist) as the stopping point

        let scrollAmount = min(firstRowToShowRect.origin.y - visibleRect.origin.y, lastRowInPlaylistRect.maxY - visibleRect.maxY)
        
        if scrollAmount > 0 {
            
            let down = visibleRect.origin.applying(CGAffineTransform.init(translationX: 0, y: scrollAmount))
            self.enclosingScrollView?.contentView.scroll(to: down)
        }
    }
    
    func customizeHeader<C>(heightIncrease: CGFloat, customCellType: C.Type) where C: NSTableHeaderCell {
        
        guard let header = self.headerView else {return}
        
        header.resize(header.width, header.height + heightIncrease)
        
        if let clipView = enclosingScrollView?.documentView as? NSClipView {
            clipView.resize(clipView.width, clipView.height + heightIncrease)
        }
        
        header.wantsLayer = true
        header.layer?.backgroundColor = NSColor.black.cgColor
        
        tableColumns.forEach {
            
            let col = $0
            let header = C.init()
            
            header.stringValue = col.headerCell.stringValue
            header.isBordered = false
            
            col.headerCell = header
        }
    }
}

extension NSPasteboard.PasteboardType {

    // Enables drag/drop reordering of playlist rows
    static let data: NSPasteboard.PasteboardType = NSPasteboard.PasteboardType(rawValue: String(kUTTypeData))
    
    // Enables drag/drop adding of tracks into the playlist from Finder
    static let file_URL: NSPasteboard.PasteboardType = NSPasteboard.PasteboardType(rawValue: String(kUTTypeFileURL))
}
