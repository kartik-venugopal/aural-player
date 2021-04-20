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
    
    // Enables type selection, allowing the user to conveniently and efficiently find a playlist track by typing its display name, which results in the track, if found, being selected within the playlist
    func outlineView(_ outlineView: NSOutlineView, typeSelectStringFor tableColumn: NSTableColumn?, item: Any) -> String? {
        
        // Only the track name column is used for type selection
        guard tableColumn?.identifier == .uid_trackName, let displayName = (item as? Track)?.displayName ?? (item as? Group)?.name else {return nil}
        
        if !(displayName.starts(with: "<") || displayName.starts(with: ">")) {
            return displayName
        }
        
        return nil
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
        cell.isGroup = false
        cell.rowSelectionStateFunction = {[weak outlineView, weak track] in

            if let theOutlineView = outlineView {
                return theOutlineView.selectedRowIndexes.contains(theOutlineView.row(forItem: track))
            }

            return false
        }
        
        cell.updateText(FontSchemes.systemScheme.playlist.trackTextFont, playlist.displayNameForTrack(self.playlistType, track))
        cell.realignText(yOffset: FontSchemes.systemScheme.playlist.trackTextYOffset)
        
        if track == playbackInfo.playingTrack {
            imgView.image = Images.imgPlayingTrack.applyingTint(Colors.Playlist.playingTrackIconColor)
        } else {
            imgView.image = nil
        }
        
        // Constraints
        cell.reActivateConstraints(imgViewCenterY: 0, imgViewLeading: 3, textFieldLeading: 11)
        
        return cell
    }
    
    private func createTrackDurationCell(_ outlineView: NSOutlineView, _ track: Track) -> GroupedItemDurationCellView? {
        
        guard let cell = outlineView.makeView(withIdentifier: .uid_duration, owner: nil) as? GroupedItemDurationCellView else {return nil}
        
        cell.playlistType = self.playlistType
        cell.isGroup = false
        cell.rowSelectionStateFunction = {[weak outlineView, weak track] in

            if let theOutlineView = outlineView {
                return theOutlineView.selectedRowIndexes.contains(theOutlineView.row(forItem: track))
            }

            return false
        }
        
        cell.updateText(FontSchemes.systemScheme.playlist.trackTextFont, ValueFormatter.formatSecondsToHMS(track.duration))
        cell.realignText(yOffset: FontSchemes.systemScheme.playlist.trackTextYOffset)
        
        return cell
    }
    
    // Creates a cell view containing text and an image. If the row containing the cell represents the playing track, the image will be the playing track animation.
    private func createGroupNameCell(_ outlineView: NSOutlineView, _ group: Group) -> GroupedItemNameCellView? {
        
        guard let cell = outlineView.makeView(withIdentifier: .uid_trackName, owner: nil) as? GroupedItemNameCellView else {return nil}
        
        cell.playlistType = self.playlistType
        cell.isGroup = true
        cell.rowSelectionStateFunction = {[weak outlineView, weak group] in

            if let theOutlineView = outlineView {
                return theOutlineView.selectedRowIndexes.contains(theOutlineView.row(forItem: group))
            }

            return false
        }
            
        cell.updateText(FontSchemes.systemScheme.playlist.groupTextFont, String(format: "%@ (%d)", group.name, group.size))
        cell.realignText(yOffset: FontSchemes.systemScheme.playlist.groupTextYOffset)
        cell.imageView?.image = AuralPlaylistOutlineView.cachedGroupIcon
        
        // Constraints
        cell.reActivateConstraints(imgViewCenterY: -1, imgViewLeading: 8, textFieldLeading: 5)
        
        return cell
    }
    
    private func createGroupDurationCell(_ outlineView: NSOutlineView, _ group: Group) -> GroupedItemDurationCellView? {
        
        guard let cell = outlineView.makeView(withIdentifier: .uid_duration, owner: nil) as? GroupedItemDurationCellView else {return nil}
        
        cell.playlistType = self.playlistType
        cell.isGroup = true
        cell.rowSelectionStateFunction = {[weak outlineView, weak group] in

            if let theOutlineView = outlineView {
                return theOutlineView.selectedRowIndexes.contains(theOutlineView.row(forItem: group))
            }

            return false
        }
        
        cell.updateText(FontSchemes.systemScheme.playlist.groupTextFont, ValueFormatter.formatSecondsToHMS(group.duration))
        cell.realignText(yOffset: FontSchemes.systemScheme.playlist.groupTextYOffset)
        
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
