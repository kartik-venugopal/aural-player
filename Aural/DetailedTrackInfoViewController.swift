/*
    View controller for the "Track Info" popover
*/
import Cocoa

class DetailedTrackInfoViewController: NSViewController, PopoverViewDelegate {
    
    // The actual popover that is shown
    private var popover: NSPopover?
    
    // The view relative to which the popover is shown
    private var relativeToView: NSView?
    
    // Popover positioning parameters
    private let positioningRect = NSZeroRect
    private let preferredEdge = NSRectEdge.maxX
    
    // The table view that displays the track info
    @IBOutlet weak var trackInfoView: NSTableView!
    
    // Factory method to create an instance of this class, exposed as an instance of PopoverViewDelegate
    static func create(_ relativeToView: NSView) -> PopoverViewDelegate {
        
        let controller = DetailedTrackInfoViewController(nibName: "DetailedTrackInfo", bundle: Bundle.main)
        
        let popover = NSPopover()
        popover.behavior = .semitransient
        popover.contentViewController = controller!
        
        controller!.popover = popover
        controller!.relativeToView = relativeToView
        
        return controller!
    }
    
    override func viewWillAppear() {
        refresh()
    }
    
    // Called each time the popover is shown ... refreshes the data in the table view depending on which track is currently playing
    func refresh() {
        
        // Don't bother refreshing if not shown
        if (isShown()) {
            trackInfoView.reloadData()
            trackInfoView.scrollRowToVisible(0)
        }
    }
    
    func show() {
        
        if (!popover!.isShown) {
            popover!.show(relativeTo: positioningRect, of: relativeToView!, preferredEdge: preferredEdge)
        }
    }
    
    func isShown() -> Bool {
        return popover!.isShown
    }
    
    func close() {
        
        if (popover!.isShown) {
            popover!.performClose(self)
        }
    }
    
    func toggle() {
        
        if (popover!.isShown) {
            close()
        } else {
            show()
        }
    }
    
    @IBAction func closePopoverAction(_ sender: Any) {
        close()
    }
}
