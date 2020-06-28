import Cocoa

/*
    Delegate for the NSTableView that displays the "Tracks" (flat) playlist view.
 */
class TracksPlaylistViewDelegate: NSObject, NSTableViewDelegate {
    
    @IBOutlet weak var playlistView: NSTableView!
    
    // Delegate that relays accessor operations to the playlist
    private let playlist: PlaylistAccessorDelegateProtocol = ObjectGraph.playlistAccessorDelegate
    
    // Used to determine the currently playing track
    private let playbackInfo: PlaybackInfoDelegateProtocol = ObjectGraph.playbackInfoDelegate
    
    private var cachedGapImage: NSImage!
    
    override func awakeFromNib() {
        cachedGapImage = Images.imgGap.applyingTint(Colors.Playlist.trackNameTextColor)
    }
    
    func changeGapIndicatorColor(_ color: NSColor) {
        cachedGapImage = Images.imgGap.applyingTint(Colors.Playlist.trackNameTextColor)
    }
    
    // Returns a view for a single row
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        return PlaylistRowView()
    }
    
    // Enables type selection, allowing the user to conveniently and efficiently find a playlist track by typing its display name, which results in the track, if found, being selected within the playlist
    func tableView(_ tableView: NSTableView, typeSelectStringFor tableColumn: NSTableColumn?, row: Int) -> String? {
        
        // Only the track name column is used for type selection
        return tableColumn?.identifier == .uid_trackName ? playlist.trackAtIndex(row)?.conciseDisplayName : nil
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        
        if let track = playlist.trackAtIndex(row) {
            
            let gapBeforeTrack = playlist.getGapBeforeTrack(track) != nil
            let gapAfterTrack = playlist.getGapAfterTrack(track) != nil
            
            if gapAfterTrack && gapBeforeTrack {
                return 61
                
            } else if gapAfterTrack || gapBeforeTrack {
                return 43
            }
        }

        return 25
    }
    
    // Returns a view for a single column
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        guard let track = playlist.trackAtIndex(row), let columnId = tableColumn?.identifier else {return nil}
            
        let gapBeforeTrack = playlist.getGapBeforeTrack(track)
        let gapAfterTrack = playlist.getGapAfterTrack(track)
        
        switch columnId {
            
        case .uid_index:
            
            let indexText: String = String(row + 1)
            
            // Check if there is a track currently playing, and if this row matches that track.
            if let currentTrack = playbackInfo.currentTrack, currentTrack == track {
                
                var image: NSImage!
                
                switch playbackInfo.state {
                    
                case .playing, .paused:
                    
                    image = Images.imgPlayingTrack
                    
                case .waiting:
                    
                    image = Images.imgWaitingTrack
                    
                case .transcoding:
                    
                    image = Images.imgTranscodingTrack
                
                default: return nil // Impossible
                
                }
                
                return createIndexImageCell(tableView, gapBeforeTrack, gapAfterTrack, row, image.applyingTint(Colors.Playlist.playingTrackIconColor))
            }
            
            // Otherwise, create a text cell with the track index
            return createIndexTextCell(tableView, indexText, gapBeforeTrack, gapAfterTrack, row)
            
        case .uid_trackName:
            
            return createTrackNameCell(tableView, track.conciseDisplayName, gapBeforeTrack, gapAfterTrack, row)
            
        case .uid_duration:
            
            return createDurationCell(tableView, ValueFormatter.formatSecondsToHMS(track.duration), gapBeforeTrack, gapAfterTrack, row)
            
        default: return nil // Impossible
            
        }
    }
    
    private func createIndexTextCell(_ tableView: NSTableView, _ text: String, _ gapBefore: PlaybackGap? = nil, _ gapAfter: PlaybackGap? = nil, _ row: Int) -> IndexCellView? {
     
        guard let cell = tableView.makeView(withIdentifier: .uid_index, owner: nil) as? IndexCellView else {return nil}
        
        cell.rowSelectionStateFunction = {tableView.selectedRowIndexes.contains(row)}
        
        cell.updateText(Fonts.Playlist.indexFont, text)
        cell.updateForGaps(gapBefore != nil, gapAfter != nil)
        
        return cell
    }
    
    private func createIndexImageCell(_ tableView: NSTableView, _ gapBefore: PlaybackGap? = nil, _ gapAfter: PlaybackGap? = nil, _ row: Int, _ image: NSImage) -> IndexCellView? {
        
        guard let cell = tableView.makeView(withIdentifier: .uid_index, owner: nil) as? IndexCellView else {return nil}
            
        cell.rowSelectionStateFunction = {tableView.selectedRowIndexes.contains(row)}
        
        cell.updateImage(image)
        cell.updateForGaps(gapBefore != nil, gapAfter != nil)
        
        return cell
    }
    
    private func createTrackNameCell(_ tableView: NSTableView, _ text: String, _ gapBefore: PlaybackGap? = nil, _ gapAfter: PlaybackGap? = nil, _ row: Int) -> TrackNameCellView? {
        
        guard let cell = tableView.makeView(withIdentifier: .uid_trackName, owner: nil) as? TrackNameCellView else {return nil}
            
        cell.rowSelectionStateFunction = {tableView.selectedRowIndexes.contains(row)}
        
        cell.updateText(Fonts.Playlist.trackNameFont, text)
        
        cell.gapImage = cachedGapImage
        cell.updateForGaps(gapBefore != nil, gapAfter != nil)
        
        return cell
    }
    
    private func createDurationCell(_ tableView: NSTableView, _ text: String, _ gapBefore: PlaybackGap? = nil, _ gapAfter: PlaybackGap? = nil, _ row: Int) -> DurationCellView? {
        
        guard let cell = tableView.makeView(withIdentifier: .uid_duration, owner: nil) as? DurationCellView else {return nil}
        
        cell.rowSelectionStateFunction = {tableView.selectedRowIndexes.contains(row)}
        
        cell.updateText(Fonts.Playlist.indexFont, text)
        cell.updateForGaps(gapBefore != nil, gapAfter != nil, gapBefore?.duration, gapAfter?.duration)
        
        return cell
    }
}
