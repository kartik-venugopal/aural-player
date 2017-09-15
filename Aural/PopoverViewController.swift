/*
    View controller for the "Track Info" popover
*/
import Cocoa

class PopoverViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate, PopoverViewDelegateProtocol {
    
    // The actual popover that is shown
    private var popover: NSPopover?
    
    // The view relative to which the popover is shown
    private var relativeToView: NSView?
    
    // Popover positioning parameters
    private let positioningRect = NSZeroRect
    private let preferredEdge = NSRectEdge.maxX
    
    // The table view that displays the track info
    @IBOutlet weak var trackInfoView: NSTableView!
    
    // Container for the key-value pairs of info displayed
    private var info: [(key: String, value: String)] = [(key: String, value: String)]()
    
    private let playbackInfoDelegate: PlaybackInfoDelegateProtocol = ObjectGraph.getPlaybackInfoDelegate()
    
    // Factory method
    static func create(_ relativeToView: NSView) -> PopoverViewDelegateProtocol {
        
        let controller = PopoverViewController(nibName: "PopoverViewController", bundle: Bundle.main)
        
        let popover = NSPopover()
        popover.behavior = .semitransient
        popover.contentViewController = controller!
        
        controller!.popover = popover
        controller!.relativeToView = relativeToView
        
        return controller!
    }
    
    override func viewDidLoad() {
        
        // Store a reference to trackInfoView that is easily accessible
        TrackInfoViewHolder.trackInfoView = trackInfoView
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
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        
        let _track = playbackInfoDelegate.getPlayingTrack()?.track
        if (_track == nil) {
            return 0
        }
        
        let track = _track!
        
        info.removeAll()
        
        info.append((key: "Filename", value: track.file.path))
        
        let audioAndFileInfo = track.audioAndFileInfo!
        let playbackInfo = track.playbackInfo!
        
        info.append((key: "Size", value: audioAndFileInfo.size!.toString()))
        info.append((key: "Format", value: audioAndFileInfo.format!))
        info.append((key: "Duration", value: Utils.formatDuration(track.duration)))
            
        if (track.displayInfo.artist != nil) {
            info.append((key: "Artist", value: track.displayInfo.artist!))
        }
        
        if (track.displayInfo.title != nil) {
            info.append((key: "Title", value: track.displayInfo.title!))
        }
        
        for (key, entry) in track.metadata {
            
            let formattedKey = entry.formattedKey()
            let value = entry.value
            
            // Some tracks have a "Format" metadata entry ... ignore it
            if (key.lowercased() != "format") {
                info.append((key: formattedKey, value: value))
            }
        }
        
        info.append((key: "Bit Rate", value: String(format: "%d kbps", audioAndFileInfo.bitRate!)))
        info.append((key: "Sample Rate", value: String(format: "%@ Hz", Utils.readableLongInteger(Int64(playbackInfo.sampleRate!)))))
        info.append((key: "Channels", value: String(playbackInfo.numChannels!)))
        info.append((key: "Frames", value: Utils.readableLongInteger(playbackInfo.frames!)))
        
        return info.count
    }
    
    // Each track info view row contains one key-value pair
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        return TrackInfoView.fromKeyAndValue(info[row].key, info[row].value)
    }
    
    // Adjust row height based on if the text wraps over to the next line
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        
        // Check if the text for the current row will exceed column width (value column)
        let keyString: NSString = info[row].key as NSString
        let keyStrSize: CGSize = keyString.size(withAttributes: [NSFontAttributeName: UIConstants.popoverKeyFont as AnyObject])
        
        let keyRowHeight: CGFloat
        if (keyStrSize.width > UIConstants.trackInfoKeyColumnWidth) {
            
            let rows = Int(keyStrSize.width / UIConstants.trackInfoKeyColumnWidth) + 1
            // This means the text has wrapped over to the second line
            // So, increase the row height
            keyRowHeight = CGFloat(rows) * UIConstants.trackInfoRowHeight * UIConstants.trackInfoLongTextRowHeightMultiplier
        } else {
            // No wrap, one row height is enough
            keyRowHeight = UIConstants.trackInfoRowHeight
        }
        
        // Check if the text for the current row will exceed column width (value column)
        let valueString: NSString = info[row].value as NSString
        let valueStrSize: CGSize = valueString.size(withAttributes: [NSFontAttributeName: UIConstants.popoverValueFont as AnyObject])
        
        let valueRowHeight: CGFloat
        if (valueStrSize.width > UIConstants.trackInfoValueColumnWidth) {
            
            let rows = Int(valueStrSize.width / UIConstants.trackInfoValueColumnWidth) + 1
            // This means the text has wrapped over to the second line
            // So, increase the row height
            valueRowHeight = CGFloat(rows) * UIConstants.trackInfoRowHeight * UIConstants.trackInfoLongTextRowHeightMultiplier
        } else {
            // No wrap, one row height is enough
            valueRowHeight = UIConstants.trackInfoRowHeight
        }
        
        return max(keyRowHeight, valueRowHeight)
    }
    
    // Completely disable row selection
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        return false
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

// Place to hold a reference to the trackInfoView object (used in TrackInfoView class)
class TrackInfoViewHolder {
    
    static var trackInfoView: NSTableView?
}
