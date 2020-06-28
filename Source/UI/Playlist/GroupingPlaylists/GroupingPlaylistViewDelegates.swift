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
    
    override func awakeFromNib() {
        OutlineViewHolder.instances[self.playlistType] = playlistView
    }

    // Returns a view for a single row
    func outlineView(_ outlineView: NSOutlineView, rowViewForItem item: Any) -> NSTableRowView? {
        return PlaylistRowView()
    }
    
    // Determines the height of a single row
    func outlineView(_ outlineView: NSOutlineView, heightOfRowByItem item: Any) -> CGFloat {
        
        if let track = item as? Track {

            let gapAfterTrack = playlist.getGapAfterTrack(track) != nil
            let gapBeforeTrack = playlist.getGapBeforeTrack(track) != nil

            if gapAfterTrack && gapBeforeTrack {
                return 61
                
            } else if gapAfterTrack || gapBeforeTrack {
                return 43
            }

            return 25

        } else {

            // Group
            return 28
        }
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
    
    private func createTrackNameCell(_ outlineView: NSOutlineView, _ track: Track) -> GroupedTrackNameCellView? {
        
        guard let cell = outlineView.makeView(withIdentifier: .uid_trackName, owner: nil) as? GroupedTrackNameCellView else {return nil}
        
        cell.playlistType = self.playlistType
        cell.item = track
        cell.isGroup = false
        
        cell.updateText(Fonts.Playlist.trackNameFont, playlist.displayNameForTrack(self.playlistType, track))
        
        var image: NSImage?
        
        switch playbackInfo.state {
            
        case .playing, .paused:
            
            image = track == playbackInfo.playingTrack ? Images.imgPlayingTrack : nil
            
        case .waiting:
            
            image = track == playbackInfo.waitingTrack ? Images.imgWaitingTrack : nil
            
        case .transcoding:
            
            image = track == playbackInfo.transcodingTrack ? Images.imgTranscodingTrack : nil
            
        case .noTrack:
            
            image = nil
        }
        
        cell.imageView?.image = image?.applyingTint(Colors.Playlist.playingTrackIconColor)
        
        let gapAfter = playlist.getGapAfterTrack(track)
        let gapBefore = playlist.getGapBeforeTrack(track)
        
        cell.gapImage = AuralPlaylistOutlineView.cachedGapImage
        cell.updateForGaps(gapBefore != nil, gapAfter != nil)
        
        return cell
    }
    
    private func createTrackDurationCell(_ outlineView: NSOutlineView, _ track: Track) -> GroupedTrackDurationCellView? {
        
        guard let cell = outlineView.makeView(withIdentifier: .uid_duration, owner: nil) as? GroupedTrackDurationCellView else {return nil}
        
        cell.playlistType = self.playlistType
        cell.item = track
        cell.isGroup = false
        
        cell.updateText(Fonts.Playlist.indexFont, ValueFormatter.formatSecondsToHMS(track.duration))
        
        let gapAfter = playlist.getGapAfterTrack(track)
        let gapBefore = playlist.getGapBeforeTrack(track)
        
        cell.updateForGaps(gapBefore != nil, gapAfter != nil, gapBefore?.duration, gapAfter?.duration)
        
        return cell
    }
    
    private func createGroupDurationCell(_ outlineView: NSOutlineView, _ group: Group) -> GroupedTrackDurationCellView? {
        
        guard let cell = outlineView.makeView(withIdentifier: .uid_duration, owner: nil) as? GroupedTrackDurationCellView else {return nil}
        
        cell.playlistType = self.playlistType
        cell.item = group
        cell.isGroup = true
        
        cell.updateText(Fonts.Playlist.groupDurationFont, ValueFormatter.formatSecondsToHMS(group.duration))
        cell.updateForGaps(false, false)
        
        return cell
    }
    
    // Creates a cell view containing text and an image. If the row containing the cell represents the playing track, the image will be the playing track animation.
    private func createGroupNameCell(_ outlineView: NSOutlineView, _ group: Group) -> GroupedTrackNameCellView? {
        
        guard let cell = outlineView.makeView(withIdentifier: .uid_trackName, owner: nil) as? GroupedTrackNameCellView else {return nil}
        
        cell.playlistType = self.playlistType
        cell.item = group
        cell.isGroup = true
            
        cell.updateText(Fonts.Playlist.groupNameFont, String(format: "%@ (%d)", group.name, group.size))
        cell.imageView?.image = AuralPlaylistOutlineView.cachedGroupIcon
        
        cell.updateForGaps(false, false)
        cell.textField?.setFrameOrigin(NSPoint.zero)
        
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
