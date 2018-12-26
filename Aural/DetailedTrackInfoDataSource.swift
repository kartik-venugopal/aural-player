import Cocoa

/*
    Data source and delegate for the Detailed Track Info popover view
 */
class DetailedTrackInfoDataSource: NSObject, NSTableViewDataSource, NSTableViewDelegate {
    
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
    private let playbackInfoDelegate: PlaybackInfoDelegateProtocol = ObjectGraph.playbackInfoDelegate
    
    // Constants used to calculate row height
    
    private let keyColumnBounds: NSRect = NSMakeRect(CGFloat(0), CGFloat(0), Dimensions.trackInfoKeyColumnWidth, CGFloat(Float.greatestFiniteMagnitude))
    
    private let valueColumnBounds: NSRect = NSMakeRect(CGFloat(0), CGFloat(0), Dimensions.trackInfoValueColumnWidth, CGFloat(Float.greatestFiniteMagnitude))
    
    override func awakeFromNib() {
        
        // Store a reference to trackInfoView that is easily accessible
        TrackInfoViewHolder.trackInfoView = trackInfoView
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
        
        let _track = DetailedTrackInfoViewController.shownTrack
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
        
        if let audioInfo = track.audioInfo {
            info.append((key: "Format", value: audioInfo.format!))
        }
        
        info.append((key: "Size", value: track.fileSystemInfo.size!.toString()))
        
        info.append((key: "Duration", value: StringUtils.formatSecondsToHMS(track.duration)))
        
        if let artist = track.displayInfo.artist {
            info.append((key: "Artist", value: artist))
        }
        
        if let title = track.displayInfo.title {
            info.append((key: "Title", value: title))
        }
        
        if let album = track.groupingInfo.album {
            info.append((key: "Album", value: album))
        }
        
        if let discNum = track.groupingInfo.discNumber {
            info.append((key: "Disc#", value: String(discNum)))
        }
        
        if let trackNum = track.groupingInfo.trackNumber {
            info.append((key: "Track#", value: String(trackNum)))
        }
        
        if let genre = track.groupingInfo.genre {
            info.append((key: "Genre", value: genre))
        }
        
        for (key, entry) in track.metadata {
            
            // Some tracks have a "Format" metadata entry ... ignore it
            if (key.lowercased() != "format") {
                info.append((key: entry.formattedKey(), value: entry.value))
            }
        }
        
        if let audioInfo = track.audioInfo {
            info.append((key: "Bit Rate", value: String(format: "%d kbps", audioInfo.bitRate!)))
        }
        
        if let playbackInfo = track.playbackInfo {
            
            info.append((key: "Sample Rate", value: String(format: "%@ Hz", StringUtils.readableLongInteger(Int64(playbackInfo.sampleRate!)))))
            info.append((key: "Channels", value: String(playbackInfo.numChannels!)))
            info.append((key: "Frames", value: StringUtils.readableLongInteger(playbackInfo.frames!)))
        }
        
        return info.count
    }
    
    // Each track info view row contains one key-value pair
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        return DetailedTrackInfoRowView.fromKeyAndValue(info[row].key, info[row].value)
    }
    
    // Adjust row height based on if the text wraps over to the next line
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        
        let keyText = info[row].key
        let valueText = info[row].value
        
        // Set the key and value within the virtual text fields (which are not displayed)
        virtualKeyField.stringValue = keyText
        virtualValueField.stringValue = valueText
        
        // And then compute row height from their cell sizes
        let keyHeight = virtualKeyField.cell!.cellSize(forBounds: keyColumnBounds).height
        let valueHeight = virtualValueField.cell!.cellSize(forBounds: valueColumnBounds).height
        
        // The desired row height is the maximum of the two heights, plus some padding
        return max(keyHeight, valueHeight) + 5
    }
    
    // Completely disable row selection
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        return false
    }
}

// Place to hold a reference to the trackInfoView object (used in DetailedTrackInfoRowView class)
class TrackInfoViewHolder {
    
    static var trackInfoView: NSTableView?
}
