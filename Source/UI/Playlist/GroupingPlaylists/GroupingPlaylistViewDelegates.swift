import Cocoa

/*
    Delegate base class for the NSOutlineView instances that display the "Artists", "Albums", and "Genres" (hierarchical/grouping) playlist views.
 */
class GroupingPlaylistViewDelegate: NSObject, NSOutlineViewDelegate {
 
    @IBOutlet weak var playlistView: NSOutlineView!
    
    // Delegate that relays accessor operations to the playlist
    private let playlist: PlaylistAccessorDelegateProtocol = ObjectGraph.playlistAccessorDelegate
    
    // Used to determine the currently playing track
    private let playbackInfo: PlaybackInfoDelegateProtocol = ObjectGraph.playbackInfoDelegate
    
    // Indicates the type of groups displayed by this NSOutlineView (intended to be overridden by subclasses)
    fileprivate var playlistType: PlaylistType
    
    init(_ playlistType: PlaylistType) {
        self.playlistType = playlistType
    }
    
    // Returns a view for a single row
    func outlineView(_ outlineView: NSOutlineView, rowViewForItem item: Any) -> NSTableRowView? {
        return PlaylistRowView()
    }
    
    // Determines the height of a single row
    func outlineView(_ outlineView: NSOutlineView, heightOfRowByItem item: Any) -> CGFloat {
        
        // Track or group
        return item is Track ? 26 : 28
    }
    
    // Returns a view for a single column
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        
        guard let columnId = tableColumn?.identifier else {return nil}
        
        // Track / Group name
        if columnId == .uid_trackName {

            if let group = item as? Group {
                return createGroupNameCell(outlineView, group)
                
            } else if let track = item as? Track {
                return createTrackNameCell(outlineView, track)
            }
            
        } // Duration
        else if columnId == .uid_duration {
            
            if let group = item as? Group {
                return createGroupDurationCell(outlineView, group)
                
            } else if let track = item as? Track {
                return createTrackDurationCell(outlineView, track)
            }
        }
        
        return nil
    }
    
    private func createTrackNameCell(_ outlineView: NSOutlineView, _ track: Track) -> GroupedItemNameCellView? {
        
        guard let cell = outlineView.makeView(withIdentifier: .uid_trackName, owner: nil) as? GroupedItemNameCellView else {return nil}
        
        cell.playlistType = self.playlistType
        cell.item = track
        cell.isGroup = false
        cell.rowSelectionStateFunction = {outlineView.selectedRowIndexes.contains(outlineView.row(forItem: track))}
        
        cell.updateText(Fonts.Playlist.trackNameFont, playlist.displayNameForTrack(self.playlistType, track))
        
        var image: NSImage?
        
        switch playbackInfo.state {
            
        case .playing, .paused:
            
            image = track == playbackInfo.playingTrack ? Images.imgPlayingTrack : nil
            
        case .transcoding:
            
            image = track == playbackInfo.transcodingTrack ? Images.imgTranscodingTrack : nil
            
        case .noTrack:
            
            image = nil
        }
        
        cell.imageView?.image = image?.applyingTint(Colors.Playlist.playingTrackIconColor)
        
        return cell
    }
    
    private func createTrackDurationCell(_ outlineView: NSOutlineView, _ track: Track) -> GroupedItemDurationCellView? {
        
        guard let cell = outlineView.makeView(withIdentifier: .uid_duration, owner: nil) as? GroupedItemDurationCellView else {return nil}
        
        cell.playlistType = self.playlistType
        cell.item = track
        cell.isGroup = false
        cell.rowSelectionStateFunction = {outlineView.selectedRowIndexes.contains(outlineView.row(forItem: track))}
        
        cell.updateText(Fonts.Playlist.indexFont, ValueFormatter.formatSecondsToHMS(track.duration))
        
        return cell
    }
    
    // Creates a cell view containing text and an image. If the row containing the cell represents the playing track, the image will be the playing track animation.
    private func createGroupNameCell(_ outlineView: NSOutlineView, _ group: Group) -> GroupedItemNameCellView? {
        
        guard let cell = outlineView.makeView(withIdentifier: .uid_trackName, owner: nil) as? GroupedItemNameCellView else {return nil}
        
        cell.playlistType = self.playlistType
        cell.item = group
        cell.isGroup = true
        cell.rowSelectionStateFunction = {outlineView.selectedRowIndexes.contains(outlineView.row(forItem: group))}
            
        cell.updateText(Fonts.Playlist.groupNameFont, String(format: "%@ (%d)", group.name, group.size))
        cell.imageView?.image = AuralPlaylistOutlineView.cachedGroupIcon
        
        return cell
    }
    
    private func createGroupDurationCell(_ outlineView: NSOutlineView, _ group: Group) -> GroupedItemDurationCellView? {
        
        guard let cell = outlineView.makeView(withIdentifier: .uid_duration, owner: nil) as? GroupedItemDurationCellView else {return nil}
        
        cell.playlistType = self.playlistType
        cell.item = group
        cell.isGroup = true
        cell.rowSelectionStateFunction = {outlineView.selectedRowIndexes.contains(outlineView.row(forItem: group))}
        
        cell.updateText(Fonts.Playlist.groupDurationFont, ValueFormatter.formatSecondsToHMS(group.duration))
        
        return cell
    }
}

class ArtistsPlaylistViewDelegate: GroupingPlaylistViewDelegate {
    
    @objc init() {
        super.init(.artists)
    }
}

class AlbumsPlaylistViewDelegate: GroupingPlaylistViewDelegate {
    
    @objc init() {
        super.init(.albums)
    }
}

class GenresPlaylistViewDelegate: GroupingPlaylistViewDelegate {
    
    @objc init() {
        super.init(.genres)
    }
}
