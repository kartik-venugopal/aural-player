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
    
    // Used to measure table row height
    @IBOutlet var virtualKeyField: NSTextField!
    @IBOutlet var virtualValueField: NSTextField!
    
    // Container for the key-value pairs of info displayed
    private var info: [(key: String, value: String)] = [(key: String, value: String)]()
    
    // Cached playing track instance (to avoid reloading the same data)
    private var playingTrack: Track?
    
    // Delegate that retrieves playing track info
    private let playbackInfoDelegate: PlaybackInfoDelegateProtocol = ObjectGraph.getPlaybackInfoDelegate()
    
    // Factory method to create an instance of this class, exposed as an instance of PopoverViewDelegateProtocol
    static func create(_ relativeToView: NSView) -> PopoverViewDelegateProtocol {
        
        let controller = PopoverViewController(nibName: NSNib.Name(rawValue: "PopoverViewController"), bundle: Bundle.main)
        
        let popover = NSPopover()
        popover.behavior = .semitransient
        popover.contentViewController = controller
        
        controller.popover = popover
        controller.relativeToView = relativeToView
        
        return controller
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
    
    // Compares two tracks for equality. True if and only if both are non-nil and their file paths are the same.
    private func compareTracks(_ track1: Track?, _ track2: Track?) -> Bool {
        
        if (track1 == nil || track2 == nil) {
            return false
        }
        
        return track1!.file.path == track2!.file.path
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        
        // If no track is playing, no rows to display
        
        let _track = playbackInfoDelegate.getPlayingTrack()?.track
        if (_track == nil) {
            return 0
        }
        
        // If it's the same track playing (as last time view was refreshed), no need to reload the track info
        if (compareTracks(_track, playingTrack)) {
            return info.count
        }
        
        // A track is playing, add its info to the info array, as key-value pairs
        
        let track = _track!
        self.playingTrack = _track!
        
        info.removeAll()
        
        info.append((key: "Filename", value: track.file.path))
        
        let audioInfo = track.audioInfo!
        let playbackInfo = track.playbackInfo!
        
        info.append((key: "Size", value: track.fileSystemInfo.size!.toString()))
        info.append((key: "Format", value: audioInfo.format!))
        info.append((key: "Duration", value: StringUtils.formatSecondsToHMS(track.duration)))
            
        if (track.displayInfo.artist != nil) {
            info.append((key: "Artist", value: track.displayInfo.artist!))
        }
        
        if (track.displayInfo.title != nil) {
            info.append((key: "Title", value: track.displayInfo.title!))
        }
        
        for (key, entry) in track.metadata {
            
            // Some tracks have a "Format" metadata entry ... ignore it
            if (key.lowercased() != "format") {
                info.append((key: entry.formattedKey(), value: entry.value))
            }
        }
        
        info.append((key: "Bit Rate", value: String(format: "%d kbps", audioInfo.bitRate!)))
        info.append((key: "Sample Rate", value: String(format: "%@ Hz", StringUtils.readableLongInteger(Int64(playbackInfo.sampleRate!)))))
        info.append((key: "Channels", value: String(playbackInfo.numChannels!)))
        info.append((key: "Frames", value: StringUtils.readableLongInteger(playbackInfo.frames!)))
        
        return info.count
    }
    
    // Each track info view row contains one key-value pair
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        return TrackInfoView.fromKeyAndValue(info[row].key, info[row].value)
    }
    
    // Adjust row height based on if the text wraps over to the next line
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        
        let keyText = info[row].key
        let valueText = info[row].value
        
        // Set the key and value within the virtual text fields (which are not displayed)
        virtualKeyField.stringValue = keyText
        virtualValueField.stringValue = valueText
        
        // And then compute row height from their cell sizes
        let keyHeight = virtualKeyField.cell!.cellSize(forBounds: NSMakeRect(CGFloat(0.0), CGFloat(0.0), UIConstants.trackInfoKeyColumnWidth, CGFloat(Float.greatestFiniteMagnitude))).height
        
        let valueHeight = virtualValueField.cell!.cellSize(forBounds: NSMakeRect(CGFloat(0.0), CGFloat(0.0), UIConstants.trackInfoValueColumnWidth, CGFloat(Float.greatestFiniteMagnitude))).height
        
        // The desired row height is the maximum of the two heights, plus some padding
        return max(keyHeight, valueHeight) + 5
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
