/*
    View controller for the "Track Info" popover
*/
import Cocoa

class DetailedTrackInfoViewController: NSViewController, PopoverViewDelegate {
    
    // The actual popover that is shown
    private var popover: NSPopover!
    
    @IBOutlet weak var artView: NSImageView!
    static var shownTrack: Track?
    
    // Popover positioning parameters
    private let positioningRect = NSZeroRect
    
    // The table view that displays the track info
    @IBOutlet weak var trackInfoView: NSTableView!
    
    override var nibName: String? {return "DetailedTrackInfo"}
    
    static func create() -> DetailedTrackInfoViewController {
        
        let controller = DetailedTrackInfoViewController()
        
        let popover = NSPopover()
        popover.behavior = .semitransient
        popover.contentViewController = controller
        
        controller.popover = popover
        
        return controller
    }
    
    // Called each time the popover is shown ... refreshes the data in the table view depending on which track is currently playing
    func refresh(_ track: Track) {
        
        DetailedTrackInfoViewController.shownTrack = track
        
        trackInfoView?.reloadData()
        trackInfoView?.scrollRowToVisible(0)
    }
    
    func show(_ track: Track, _ relativeToView: NSView, _ preferredEdge: NSRectEdge) {
        
        refresh(track)
        
        if (!popover.isShown) {
            popover.show(relativeTo: positioningRect, of: relativeToView, preferredEdge: preferredEdge)
        }
        
        artView.image = track.displayInfo.art ?? nil
    }
    
    func isShown() -> Bool {
        return popover.isShown
    }
    
    func close() {
        
        if (popover.isShown) {
            popover.performClose(self)
        }
    }
    
    func toggle(_ track: Track, _ relativeToView: NSView, _ preferredEdge: NSRectEdge) {
        
        if (popover.isShown) {
            close()
        } else {
            show(track, relativeToView, preferredEdge)
        }
    }
    
    @IBAction func closePopoverAction(_ sender: Any) {
        close()
    }
}
