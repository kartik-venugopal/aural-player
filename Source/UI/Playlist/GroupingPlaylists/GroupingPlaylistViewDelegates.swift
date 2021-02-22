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
        return GroupingPlaylistRowView()
    }
    
    // Determines the height of a single row
    func outlineView(_ outlineView: NSOutlineView, heightOfRowByItem item: Any) -> CGFloat {
        30
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
        
        guard let cell = outlineView.makeView(withIdentifier: .uid_trackName, owner: nil) as? GroupedItemNameCellView,
            let imgView = cell.imageView else {return nil}
        
        cell.playlistType = self.playlistType
        cell.item = track
        cell.isGroup = false
        cell.rowSelectionStateFunction = {outlineView.selectedRowIndexes.contains(outlineView.row(forItem: track))}
        
        cell.updateText(FontSets.systemFontSet.playlist.trackTextFont, playlist.displayNameForTrack(self.playlistType, track))
        cell.realignText(yOffset: FontSets.systemFontSet.playlist.trackTextYOffset)
        
        var image: NSImage?
        
        switch playbackInfo.state {
            
        case .playing, .paused:
            
            image = track == playbackInfo.playingTrack ? Images.imgPlayingTrack : nil
            
        case .transcoding:
            
            image = track == playbackInfo.transcodingTrack ? Images.imgTranscodingTrack : nil
            
        case .noTrack:
            
            image = nil
        }
        
        imgView.image = image?.applyingTint(Colors.Playlist.playingTrackIconColor)
        
        return cell
    }
    
    private func createTrackDurationCell(_ outlineView: NSOutlineView, _ track: Track) -> GroupedItemDurationCellView? {
        
        guard let cell = outlineView.makeView(withIdentifier: .uid_duration, owner: nil) as? GroupedItemDurationCellView else {return nil}
        
        cell.playlistType = self.playlistType
        cell.item = track
        cell.isGroup = false
        cell.rowSelectionStateFunction = {outlineView.selectedRowIndexes.contains(outlineView.row(forItem: track))}
        
        cell.updateText(FontSets.systemFontSet.playlist.trackTextFont, ValueFormatter.formatSecondsToHMS(track.duration))
        cell.realignText(yOffset: FontSets.systemFontSet.playlist.trackTextYOffset)
        
        return cell
    }
    
    // Creates a cell view containing text and an image. If the row containing the cell represents the playing track, the image will be the playing track animation.
    private func createGroupNameCell(_ outlineView: NSOutlineView, _ group: Group) -> GroupedItemNameCellView? {
        
        guard let cell = outlineView.makeView(withIdentifier: .uid_trackName, owner: nil) as? GroupedItemNameCellView,
        let imgView = cell.imageView else {return nil}
        
        cell.playlistType = self.playlistType
        cell.item = group
        cell.isGroup = true
        cell.rowSelectionStateFunction = {outlineView.selectedRowIndexes.contains(outlineView.row(forItem: group))}
            
        cell.updateText(FontSets.systemFontSet.playlist.groupTextFont, String(format: "%@ (%d)", group.name, group.size))
        cell.realignText(yOffset: FontSets.systemFontSet.playlist.groupTextYOffset)
        imgView.image = AuralPlaylistOutlineView.cachedGroupIcon
        
        // Constraints
        
        // Remove any existing constraints on the text field's 'top' and 'centerY' attributes
        cell.constraints.filter {$0.firstItem === imgView && $0.firstAttribute == .centerY}.forEach {cell.deactivateAndRemoveConstraint($0)}

        let imgViewBottomConstraint = NSLayoutConstraint(item: imgView, attribute: .centerY, relatedBy: .equal, toItem: cell, attribute: .centerY, multiplier: 1.0, constant: -1)
        
        cell.activateAndAddConstraint(imgViewBottomConstraint)
        
        return cell
    }
    
    private func createGroupDurationCell(_ outlineView: NSOutlineView, _ group: Group) -> GroupedItemDurationCellView? {
        
        guard let cell = outlineView.makeView(withIdentifier: .uid_duration, owner: nil) as? GroupedItemDurationCellView else {return nil}
        
        cell.playlistType = self.playlistType
        cell.item = group
        cell.isGroup = true
        cell.rowSelectionStateFunction = {outlineView.selectedRowIndexes.contains(outlineView.row(forItem: group))}
        
        cell.updateText(FontSets.systemFontSet.playlist.groupTextFont, ValueFormatter.formatSecondsToHMS(group.duration))
        cell.realignText(yOffset: FontSets.systemFontSet.playlist.groupTextYOffset)
        
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
