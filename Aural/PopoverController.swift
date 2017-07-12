/*
    View controller for the "Track Info" popover
*/

import Cocoa

class PopoverController: NSViewController {
    
    @IBOutlet weak var trackInfoView: NSTableView!
    @IBOutlet var popoverView: NSView!
    @IBOutlet weak var lblTrackInfo: NSTextField!
    
    // Strong references
    var _trackInfoView: NSTableView!
    
    override func loadView() {
        super.loadView()
        
        // Store references to the table view for later use
        _trackInfoView = trackInfoView
        
        _trackInfoView.backgroundColor = NSColor.clearColor()
        _trackInfoView.reloadData()
        _trackInfoView.scrollRowToVisible(0)
    }
    
    // Called each time the popover is shown ... refreshes the data in the table view depending on which track is currently playing
    func refresh() {
        if (_trackInfoView != nil) {
            _trackInfoView.reloadData()
            _trackInfoView.scrollRowToVisible(0)
        }
    }
}
