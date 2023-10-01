//
//  GroupingPlaylistViewController+TableViewDelegate.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
    Delegate base class for the NSOutlineView instances that display the "Artists", "Albums", and "Genres" (hierarchical/grouping) playlist views.
 */
extension GroupingPlaylistViewController: NSOutlineViewDelegate {
    
    private static let rowHeight: CGFloat = 30
 
    // Returns a view for a single row
    func outlineView(_ outlineView: NSOutlineView, rowViewForItem item: Any) -> NSTableRowView? {
        GroupingPlaylistRowView()
    }
    
    // Determines the height of a single row
    func outlineView(_ outlineView: NSOutlineView, heightOfRowByItem item: Any) -> CGFloat {
        Self.rowHeight
    }
    
    // Enables type selection, allowing the user to conveniently and efficiently find a playlist track by typing its display name, which results in the track, if found, being selected within the playlist
    func outlineView(_ outlineView: NSOutlineView, typeSelectStringFor tableColumn: NSTableColumn?, item: Any) -> String? {
        
        // Only the track name column is used for type selection
        guard tableColumn?.identifier == .cid_trackName, let displayName = (item as? Track)?.displayName ?? (item as? Group)?.name else {return nil}
        
        if !(displayName.starts(with: "<") || displayName.starts(with: ">")) {
            return displayName
        }
        
        return nil
    }
    
    // Returns a view for a single column
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        
        guard let columnId = tableColumn?.identifier else {return nil}
        
        // Track / Group name
        if columnId == .cid_trackName {

            if let group = item as? Group {
                return createGroupNameCell(outlineView, group)
                
            } else if let track = item as? Track {
                return createTrackNameCell(outlineView, track)
            }
            
        } // Duration
        else if columnId == .cid_duration {
            
            if let group = item as? Group {
                return createGroupDurationCell(outlineView, group)
                
            } else if let track = item as? Track {
                return createTrackDurationCell(outlineView, track)
            }
        }
        
        return nil
    }
    
    private func createTrackNameCell(_ outlineView: NSOutlineView, _ track: Track) -> GroupedItemNameCellView? {
        
        guard let cell = outlineView.makeView(withIdentifier: .cid_trackName, owner: nil)
                as? GroupedItemNameCellView else {return nil}
        
        cell.playlistType = self.playlistType
        cell.isGroup = false
        cell.rowSelectionStateFunction = {[weak outlineView, weak track] in

            if let theOutlineView = outlineView, let theTrack = track {
                return theOutlineView.isItemSelected(theTrack)
            }

            return false
        }
        
        cell.updateText(fontSchemesManager.systemScheme.playlist.trackTextFont, playlist.displayNameForTrack(self.playlistType, track))
        cell.realignText(yOffset: fontSchemesManager.systemScheme.playlist.trackTextYOffset)
        
        if track == playbackInfo.playingTrack {
            cell.image = Images.imgPlayingTrack.filledWithColor(Colors.Playlist.playingTrackIconColor)
        } else {
            cell.image = nil
        }
        
        // Constraints
        cell.reActivateConstraints(imgViewCenterY: 0, imgViewLeading: 3, textFieldLeading: 7)
        
        return cell
    }
    
    private func createTrackDurationCell(_ outlineView: NSOutlineView, _ track: Track) -> GroupedItemDurationCellView? {
        
        guard let cell = outlineView.makeView(withIdentifier: .cid_duration, owner: nil) as? GroupedItemDurationCellView else {return nil}
        
        cell.playlistType = self.playlistType
        cell.isGroup = false
        cell.rowSelectionStateFunction = {[weak outlineView, weak track] in
            
            if let theOutlineView = outlineView, let theTrack = track {
                return theOutlineView.isItemSelected(theTrack)
            }

            return false
        }
        
        cell.updateText(fontSchemesManager.systemScheme.playlist.trackTextFont, ValueFormatter.formatSecondsToHMS(track.duration))
        cell.realignText(yOffset: fontSchemesManager.systemScheme.playlist.trackTextYOffset)
        
        return cell
    }
    
    // Creates a cell view containing text and an image. If the row containing the cell represents the playing track, the image will be the playing track animation.
    private func createGroupNameCell(_ outlineView: NSOutlineView, _ group: Group) -> GroupedItemNameCellView? {
        
        guard let cell = outlineView.makeView(withIdentifier: .cid_trackName, owner: nil) as? GroupedItemNameCellView else {return nil}
        
        cell.playlistType = self.playlistType
        cell.isGroup = true
        cell.rowSelectionStateFunction = {[weak outlineView, weak group] in

            if let theOutlineView = outlineView, let theGroup = group {
                return theOutlineView.isItemSelected(theGroup)
            }

            return false
        }
            
        cell.updateText(fontSchemesManager.systemScheme.playlist.groupTextFont, String(format: "%@ (%d)", group.name, group.size))
        cell.realignText(yOffset: fontSchemesManager.systemScheme.playlist.groupTextYOffset)
        cell.textField?.lineBreakMode = .byTruncatingMiddle
        cell.image = AuralPlaylistOutlineView.cachedGroupIcon
        
        // Constraints
        cell.reActivateConstraints(imgViewCenterY: -1, imgViewLeading: 7, textFieldLeading: 5)
        
        return cell
    }
    
    private func createGroupDurationCell(_ outlineView: NSOutlineView, _ group: Group) -> GroupedItemDurationCellView? {
        
        guard let cell = outlineView.makeView(withIdentifier: .cid_duration, owner: nil) as? GroupedItemDurationCellView else {return nil}
        
        cell.playlistType = self.playlistType
        cell.isGroup = true
        cell.rowSelectionStateFunction = {[weak outlineView, weak group] in

            if let theOutlineView = outlineView, let theGroup = group {
                return theOutlineView.isItemSelected(theGroup)
            }

            return false
        }
        
        cell.updateText(fontSchemesManager.systemScheme.playlist.groupTextFont, ValueFormatter.formatSecondsToHMS(group.duration))
        cell.realignText(yOffset: fontSchemesManager.systemScheme.playlist.groupTextYOffset)
        
        return cell
    }
}
