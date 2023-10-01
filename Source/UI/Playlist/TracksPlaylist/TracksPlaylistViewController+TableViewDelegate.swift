//
//  TracksPlaylistViewController+TableViewDelegate.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
    Delegate for the NSTableView that displays the "Tracks" (flat) playlist view.
 */
extension TracksPlaylistViewController: NSTableViewDelegate {
    
    private static let rowHeight: CGFloat = 30
    
    private var fontScheme: PlaylistFontScheme {fontSchemesManager.systemScheme.playlist}
    
    // Returns a view for a single row
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        PlaylistRowView()
    }
    
    // Enables type selection, allowing the user to conveniently and efficiently find a playlist track by typing its display name, which results in the track, if found, being selected within the playlist
    func tableView(_ tableView: NSTableView, typeSelectStringFor tableColumn: NSTableColumn?, row: Int) -> String? {
        
        // Only the track name column is used for type selection
        guard tableColumn?.identifier == .cid_trackName,
              let displayName = playlist.trackAtIndex(row)?.displayName else {return nil}
        
        if !(displayName.starts(with: "<") || displayName.starts(with: ">")) {
            return displayName
        }
        
        return nil
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {Self.rowHeight}
    
    // Returns a view for a single column
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        guard let track = playlist.trackAtIndex(row), let columnId = tableColumn?.identifier else {return nil}
            
        switch columnId {
            
        case .cid_index:
            
            // Check if there is a track currently playing, and if this row matches that track.
            if track == playbackInfo.playingTrack {
                return createIndexImageCell(tableView, row, Images.imgPlayingTrack.filledWithColor(Colors.Playlist.playingTrackIconColor))
            }
            
            // Otherwise, create a text cell with the track index
            return createIndexTextCell(tableView, String(row + 1), row)
            
        case .cid_trackName:
            
            return createTrackNameCell(tableView, track.displayName, row)
            
        case .cid_duration:
            
            return createDurationCell(tableView, ValueFormatter.formatSecondsToHMS(track.duration), row)
            
        default:
            
            return nil // Impossible
        }
    }
    
    private func createIndexTextCell(_ tableView: NSTableView, _ text: String, _ row: Int) -> IndexCellView? {
     
        guard let cell = tableView.makeView(withIdentifier: .cid_index, owner: nil) as? IndexCellView else {return nil}
        
        cell.rowSelectionStateFunction = {[weak tableView] in tableView?.isRowSelected(row) ?? false}
        cell.updateText(fontScheme.trackTextFont, text)
        cell.realignText(yOffset: fontScheme.trackTextYOffset)
        
        return cell
    }
    
    private func createIndexImageCell(_ tableView: NSTableView, _ row: Int, _ image: NSImage) -> IndexCellView? {
        
        guard let cell = tableView.makeView(withIdentifier: .cid_index, owner: nil) as? IndexCellView else {return nil}
            
        cell.rowSelectionStateFunction = {[weak tableView] in tableView?.isRowSelected(row) ?? false}
        cell.updateImage(image)
        
        return cell
    }
    
    private func createTrackNameCell(_ tableView: NSTableView, _ text: String, _ row: Int) -> TrackNameCellView? {
        
        guard let cell = tableView.makeView(withIdentifier: .cid_trackName, owner: nil) as? TrackNameCellView else {return nil}
            
        cell.rowSelectionStateFunction = {[weak tableView] in tableView?.isRowSelected(row) ?? false}
        cell.updateText(fontScheme.trackTextFont, text)
        cell.realignText(yOffset: fontScheme.trackTextYOffset)
        
        return cell
    }
    
    private func createDurationCell(_ tableView: NSTableView, _ text: String, _ row: Int) -> DurationCellView? {
        
        guard let cell = tableView.makeView(withIdentifier: .cid_duration, owner: nil) as? DurationCellView else {return nil}
        
        cell.rowSelectionStateFunction = {[weak tableView] in tableView?.isRowSelected(row) ?? false}
        cell.updateText(fontScheme.trackTextFont, text)
        cell.realignText(yOffset: fontScheme.trackTextYOffset)
        
        return cell
    }
}
