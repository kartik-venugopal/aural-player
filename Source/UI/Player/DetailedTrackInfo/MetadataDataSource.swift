import Cocoa

/*
    Data source and delegate for the Detailed Track Info popover view
 */
class TrackInfoDataSource: NSObject, NSTableViewDataSource, NSTableViewDelegate {
    
    // The table view that displays the track info
    @IBOutlet weak var table: NSTableView! {
        
        didSet {
            TrackInfoViewHolder.tablesMap[self.tableId] = table
        }
    }
    
    // Used to measure table row height
    @IBOutlet var virtualKeyField: NSTextField!
    @IBOutlet var virtualValueField: NSTextField!
    
    // Container for the key-value pairs of info displayed
    var info: [(key: String, value: String)] = [(key: String, value: String)]()
    
    // Cached playing track instance (to avoid reloading the same data)
    var displayedTrack: Track?
    
    var tableId: TrackInfoTab {return .metadata}
    
    var keyTextAlignment: NSTextAlignment? {return nil}
    var valueTextAlignment: NSTextAlignment? {return nil}
    
    // Constants used to calculate row height
    
    let keyColumnBounds: NSRect = NSMakeRect(CGFloat(0), CGFloat(0), Dimensions.trackInfoKeyColumnWidth, CGFloat(Float.greatestFiniteMagnitude))
    
    let valueColumnBounds: NSRect = NSMakeRect(CGFloat(0), CGFloat(0), Dimensions.trackInfoValueColumnWidth, CGFloat(Float.greatestFiniteMagnitude))
    
    let value_unknown: String = "<Unknown>"
    
    // Compares two tracks for equality. True if and only if both are non-nil and their file paths are the same.
    func compareTracks(_ track1: Track?, _ track2: Track?) -> Bool {
        
        if (track1 == nil || track2 == nil) {
            return false
        }
        
        return track1!.file.path == track2!.file.path
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        
        // If no track is playing, no rows to display
        
        if let track = DetailedTrackInfoViewController.shownTrack {
            
            // If it's the same track playing (as last time view was refreshed), no need to reload the track info
            if (compareTracks(track, displayedTrack)) {
                return info.count
            }
            
            // A track is playing, add its info to the info array, as key-value pairs
            
            self.displayedTrack = track
            
            info.removeAll()
            info.append(contentsOf: infoForTrack(track))
            
            return info.count
        }
        
        return 0
    }
    
    // Each track info view row contains one key-value pair
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        return DetailedTrackInfoRowView.fromKeyAndValue(info[row].key, info[row].value, self.tableId, keyTextAlignment, valueTextAlignment)
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
    
    func infoForTrack(_ track: Track) -> [(key: String, value: String)] {
        return []
    }
}

// Place to hold a reference to the trackInfoView object (used in DetailedTrackInfoRowView class)
class TrackInfoViewHolder {
    
    static var tablesMap: [TrackInfoTab: NSTableView] = [:]
}

enum TrackInfoTab {
    
    case metadata
    case audio
    case coverArt
    case fileSystem
}

class MetadataDataSource: TrackInfoDataSource {
    
    override var tableId: TrackInfoTab {return .metadata}
    
    override func infoForTrack(_ track: Track) -> [(key: String, value: String)] {
        
        var trackInfo: [(key: String, value: String)] = []
        
        trackInfo.append((key: "Title", value: track.title ?? value_unknown))
        trackInfo.append((key: "Artist", value: track.artist ?? value_unknown))
        trackInfo.append((key: "Album", value: track.album ?? value_unknown))
        trackInfo.append((key: "Genre", value: track.genre ?? value_unknown))

        if let trackNum = track.trackNumber {

            if let totalTracks = track.totalTracks, totalTracks > 0 {
                trackInfo.append((key: "Track#", value: String(format: "%d / %d", trackNum, totalTracks)))
            } else if trackNum > 0 {
                trackInfo.append((key: "Track#", value: String(trackNum)))
            }
        }

        if let discNum = track.discNumber {

            if let totalDiscs = track.totalDiscs, totalDiscs > 0 {
                trackInfo.append((key: "Disc#", value: String(format: "%d / %d", discNum, totalDiscs)))
            } else if discNum > 0 {
                trackInfo.append((key: "Disc#", value: String(discNum)))
            }
        }

        // TODO: Sort the metadata so that junk comes last (e.g. iTunesNORM and UPC's, etc)

        var sortedArr = [(key: String, entry: MetadataEntry)]()

        for (_, entry) in track.auxiliaryMetadata {
            sortedArr.append((key: entry.key, entry: entry))
        }

        sortedArr.sort(by: {e1, e2 -> Bool in

            let t1 = e1.entry.format
            let t2 = e2.entry.format

            // If both entries are of the same metadata type (e.g. both are iTunes), compare their formatted keys (ascending order)
            if t1 == t2 {
                return e1.entry.key < e2.entry.key
            }

            // Entries have different metadata types, compare by their sort order
            return t1.sortOrder < t2.sortOrder
        })

        for (_, entry) in sortedArr {

            let fKey = entry.key.trim()

            if !fKey.isEmpty {
                trackInfo.append((key: fKey, value: entry.value.trim()))
            }
        }
        
        return trackInfo
    }
}
