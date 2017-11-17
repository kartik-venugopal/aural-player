import Cocoa

class AuralPlaylistTableView: NSTableView {
    
//    // Storage var for clickedRow field
//    private var _clickedRow: Int = -1
//    
//    override var clickedRow: Int {
//        get {
//            return _clickedRow
//        }
//    }
    
//    override func mouseDown(with event: NSEvent) {
//        _clickedRow = self.row(at: convert(event.locationInWindow, from: nil))
//        super.mouseDown(with: event)
//    }
//    
    override func rightMouseDown(with event: NSEvent) {
        
        // Calculate the clicked row
        let row = self.row(at: convert(event.locationInWindow, from: nil))
        
        // Select the clicked row, implicitly clearing the previous selection
        self.selectRowIndexes(IndexSet(integer: row), byExtendingSelection: false)
        
        // Note that this view was clicked (this is required by the contextual menu)
        PlaylistViewContext.clickedView = self
        
        super.rightMouseDown(with: event)
    }
    
    override func menu(for event: NSEvent) -> NSMenu? {
        return self.menu
    }
}

class AuralPlaylistOutlineView: NSOutlineView {
    
    // Storage var for clickedRow field
//    private var _clickedRow: Int = -1
//    
//    override var clickedRow: Int {
//        get {
//            return _clickedRow
//        }
//    }
//    
//    override func mouseDown(with event: NSEvent) {
//        _clickedRow = self.row(at: convert(event.locationInWindow, from: nil))
//        super.mouseDown(with: event)
//    }
    
    override func rightMouseDown(with event: NSEvent) {
        
        // Calculate the clicked row
        let _clickedRow = self.row(at: convert(event.locationInWindow, from: nil))
        
        // Select the clicked row, implicitly clearing the previous selection
        self.selectRowIndexes(IndexSet(integer: _clickedRow), byExtendingSelection: false)
        
        // Note that this view was clicked (this is required by the contextual menu)
        PlaylistViewContext.clickedView = self
        
        super.rightMouseDown(with: event)
    }
    
    override func menu(for event: NSEvent) -> NSMenu? {
        return self.menu
    }
}
