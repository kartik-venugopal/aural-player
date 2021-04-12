import Cocoa

/*
    Delegate base class for the NSOutlineView instances that display the "Artists", "Albums", and "Genres" (hierarchical/grouping) playlist views.
 */
class GroupingPlaylistViewDelegate: NSObject, NSOutlineViewDelegate {
 
    @IBOutlet weak var playlistView: AuralPlaylistOutlineView!
    
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
        cell.item = track
        cell.isGroup = false
        cell.rowSelectionStateFunction = {outlineView.selectedRowIndexes.contains(outlineView.row(forItem: track))}
        
        cell.updateText(FontSchemes.systemScheme.playlist.trackTextFont, playlist.displayNameForTrack(self.playlistType, track))
        cell.realignText(yOffset: FontSchemes.systemScheme.playlist.trackTextYOffset)
        
        if playbackInfo.state.isPlayingOrPaused, track == playbackInfo.playingTrack {
            
            if cell.rowSelectionStateFunction() {
                cell.imageView?.image = AuralPlaylistOutlineView.cachedPlayingTrackIconSelectedRows
            } else {
                cell.imageView?.image = AuralPlaylistOutlineView.cachedPlayingTrackIcon
            }
        }
        
        var image: NSImage?
        
        switch playbackInfo.state {
            
        case .playing, .paused:
            
            image = track == playbackInfo.playingTrack ? Images.imgPlayingTrack : nil
            
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
        
        cell.updateText(FontSchemes.systemScheme.playlist.trackTextFont, ValueFormatter.formatSecondsToHMS(track.duration))
        cell.realignText(yOffset: FontSchemes.systemScheme.playlist.trackTextYOffset)
        
        return cell
    }
    
    // Creates a cell view containing text and an image. If the row containing the cell represents the playing track, the image will be the playing track animation.
    private func createGroupNameCell(_ outlineView: NSOutlineView, _ group: Group) -> GroupedItemNameCellView? {
        
        guard let cell = outlineView.makeView(withIdentifier: .uid_trackName, owner: nil) as? GroupedItemNameCellView,
              let imgView = cell.imageView, let textField = cell.textField else {return nil}
        
        cell.playlistType = self.playlistType
        cell.item = group
        cell.isGroup = true
        cell.rowSelectionStateFunction = {outlineView.selectedRowIndexes.contains(outlineView.row(forItem: group))}
            
        cell.updateText(FontSchemes.systemScheme.playlist.groupTextFont, String(format: "%@ (%d)", group.name, group.size))
        cell.realignText(yOffset: FontSchemes.systemScheme.playlist.groupTextYOffset)
        
        if cell.rowSelectionStateFunction() {
            
            imgView.image = AuralPlaylistOutlineView.cachedGroupIconSelectedRows
            
            playlistView.disclosureTriangleForRow(outlineView.row(forItem: group))?.image = AuralPlaylistOutlineView.cachedDisclosureIconSelectedRows_collapsed
            
            playlistView.disclosureTriangleForRow(outlineView.row(forItem: group))?.alternateImage = AuralPlaylistOutlineView.cachedDisclosureIconSelectedRows_expanded
            
        } else {
            
            imgView.image = AuralPlaylistOutlineView.cachedGroupIcon
            
            playlistView.disclosureTriangleForRow(outlineView.row(forItem: group))?.image = AuralPlaylistOutlineView.cachedDisclosureIcon_collapsed
            
            playlistView.disclosureTriangleForRow(outlineView.row(forItem: group))?.alternateImage = AuralPlaylistOutlineView.cachedDisclosureIcon_expanded
        }
        
        // Constraints
        
        // Remove any existing constraints on the text field's 'top' and 'centerY' attributes
        cell.constraints.filter {$0.firstItem === imgView && $0.firstAttribute == .centerY}.forEach {cell.deactivateAndRemoveConstraint($0)}
        
        cell.constraints.filter {$0.firstItem === imgView && $0.firstAttribute == .leading}.forEach {cell.deactivateAndRemoveConstraint($0)}
        
        cell.constraints.filter {$0.firstItem === textField && $0.firstAttribute == .leading}.forEach {cell.deactivateAndRemoveConstraint($0)}

        let imgViewBottomConstraint = NSLayoutConstraint(item: imgView, attribute: .centerY, relatedBy: .equal, toItem: cell, attribute: .centerY, multiplier: 1.0, constant: -1)
        
        let imgViewLeadingConstraint = NSLayoutConstraint(item: imgView, attribute: .leading, relatedBy: .equal, toItem: cell, attribute: .leading, multiplier: 1.0, constant: 8)
        
        let textFieldLeadingConstraint = NSLayoutConstraint(item: textField, attribute: .leading, relatedBy: .equal, toItem: imgView, attribute: .trailing, multiplier: 1.0, constant: 5)
        
        cell.activateAndAddConstraint(imgViewBottomConstraint)
        cell.activateAndAddConstraint(imgViewLeadingConstraint)
        cell.activateAndAddConstraint(textFieldLeadingConstraint)
        
        return cell
    }
    
    private func createGroupDurationCell(_ outlineView: NSOutlineView, _ group: Group) -> GroupedItemDurationCellView? {
        
        guard let cell = outlineView.makeView(withIdentifier: .uid_duration, owner: nil) as? GroupedItemDurationCellView else {return nil}
        
        cell.playlistType = self.playlistType
        cell.item = group
        cell.isGroup = true
        cell.rowSelectionStateFunction = {outlineView.selectedRowIndexes.contains(outlineView.row(forItem: group))}
        
        cell.updateText(FontSchemes.systemScheme.playlist.groupTextFont, ValueFormatter.formatSecondsToHMS(group.duration))
        cell.realignText(yOffset: FontSchemes.systemScheme.playlist.groupTextYOffset)
        
        return cell
    }
    
    // TODO: The following 2 functions will be used to change the disclosure triangle and group icon images when row selecttion changes.
    
    func outlineView(_ outlineView: NSOutlineView, selectionIndexesForProposedSelection proposedSelectionIndexes: IndexSet) -> IndexSet {

        print("\n")
        let selRows = playlistView.selectedRowIndexes.toArray()
        NSLog("OV IS changing ... \(selRows)")
        unselItems = selRows.map {playlistView.item(atRow: $0)}

        return proposedSelectionIndexes
    }

    private var unselItems: [Any] = []

    func outlineViewSelectionDidChange(_ notification: Notification) {

        print("\n")
        let selRows = playlistView.selectedRowIndexes.toArray()
        NSLog("OV DID change ... \(selRows)")
        
        if let playingTrack = playbackInfo.playingTrack {
            
            let playingTrackRow: Int = playlistView.row(forItem: playingTrack)
            
            print("Playing track row: \(playingTrackRow)")
            
            if playingTrackRow >= 0, let icon = playlistView.iconForRow(playingTrackRow) {
                
                DispatchQueue.main.async {
                    
                    if selRows.contains(playingTrackRow) {
                        icon.image = AuralPlaylistOutlineView.cachedPlayingTrackIconSelectedRows
                    } else {
                        icon.image = AuralPlaylistOutlineView.cachedPlayingTrackIcon
                    }
                }
            }
        }
        

        for row in selRows {
            
            if playlistView.item(atRow: row) is Group {
                
                playlistView.disclosureTriangleForRow(row)?.image = AuralPlaylistOutlineView.cachedDisclosureIconSelectedRows_collapsed
                
                playlistView.disclosureTriangleForRow(row)?.alternateImage = AuralPlaylistOutlineView.cachedDisclosureIconSelectedRows_expanded
                
                playlistView.iconForRow(row)?.image = AuralPlaylistOutlineView.cachedGroupIconSelectedRows
            }
        }

        // TODO: This doesn't work when double-clicking a group for playback, because the row indices change.
        
        for row in unselItems.map({playlistView.row(forItem: $0)}) {
            
            if playlistView.item(atRow: row) is Group, !selRows.contains(row) {
                
                playlistView.disclosureTriangleForRow(row)?.image = AuralPlaylistOutlineView.cachedDisclosureIcon_collapsed
                
                playlistView.disclosureTriangleForRow(row)?.alternateImage = AuralPlaylistOutlineView.cachedDisclosureIcon_expanded
                
                playlistView.iconForRow(row)?.image = AuralPlaylistOutlineView.cachedGroupIcon
            }
        }
        
        unselItems = selRows.compactMap {playlistView.item(atRow: $0)}
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
