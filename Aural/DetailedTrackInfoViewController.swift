/*
    View controller for the "Detailed Track Info" popover
*/
import Cocoa

class DetailedTrackInfoViewController: NSViewController, PopoverViewDelegate, AsyncMessageSubscriber {
    
    // The actual popover that is shown
    private var popover: NSPopover!
    
    @IBOutlet weak var tabView: AuralTabView!
    
    // Displays track artwork
    @IBOutlet weak var artView: NSImageView!
    
    @IBOutlet weak var lyricsView: NSTextView! {
        
        didSet {
            lyricsView.font = Fonts.gillSans13Font
            lyricsView.alignment = .center
        }
    }
    
    // The table view that displays the track info
    @IBOutlet weak var metadataTable: NSTableView!
    
    // The table view that displays the track info
    @IBOutlet weak var audioTable: NSTableView!
    
    // The table view that displays the track info
    @IBOutlet weak var fileSystemTable: NSTableView!
    
    // Temporary holder for the currently shown track
    static var shownTrack: Track?
    
    // Popover positioning parameters
    private let positioningRect = NSZeroRect
    
    let subscriberId: String = "DetailedTrackInfoViewController"
    
    private let noLyricsText: String = "< No lyrics available for this track >"
    
    override var nibName: String? {return "DetailedTrackInfo"}
    
    override func awakeFromNib() {
        AsyncMessenger.subscribe([.trackInfoUpdated], subscriber: self, dispatchQueue: DispatchQueue.main)
    }
    
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
        
        [metadataTable, audioTable, fileSystemTable].forEach({
            $0?.reloadData()
            $0?.scrollRowToVisible(0)
        })
        
        artView?.image = track.displayInfo.art
        lyricsView?.string = track.lyrics ?? noLyricsText
    }
    
    func show(_ track: Track, _ relativeToView: NSView, _ preferredEdge: NSRectEdge) {
        
        refresh(track)
        
        if (!popover.isShown) {
            popover.show(relativeTo: positioningRect, of: relativeToView, preferredEdge: preferredEdge)
            tabView.selectTabViewItem(at: 0)
        }
        
        artView.image = track.displayInfo.art
        lyricsView?.string = track.lyrics ?? noLyricsText
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
    
    func consumeAsyncMessage(_ message: AsyncMessage) {
    
        if popover.isShown && message.messageType == .trackInfoUpdated {
            
            let msg = message as! TrackUpdatedAsyncMessage
                
            if msg.track == DetailedTrackInfoViewController.shownTrack {
                artView.image = msg.track.displayInfo.art
            }
        }
    }
}
