//
//  ChaptersListViewDelegate.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
    Delegate for the chapters list NSTableView
 */
class ChaptersListViewDelegate: NSObject, NSTableViewDelegate {
    
    // Used to determine the currently playing track/chapter
    private let playbackInfo: PlaybackInfoDelegateProtocol = objectGraph.playbackInfoDelegate
    
    private let fontSchemesManager: FontSchemesManager = objectGraph.fontSchemesManager
    
    // Returns a custom view for a single row
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        return PlaylistRowView()
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 30
    }
    
    // Returns a view for a single column
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        guard let columnId = tableColumn?.identifier,
              let track = playbackInfo.playingTrack, track.hasChapters, row < playbackInfo.chapterCount
               else {return nil}
            
        let chapter = track.chapters[row]
        
        var cell: ChaptersListTableCellView!
        
        switch columnId {
            
        case .uid_chapterIndex:
            
            // Display a marker icon if this chapter is currently playing
            cell = createIndexCell(tableView, String(row + 1), row, row == playbackInfo.playingChapter?.index)
            
        case .uid_chapterTitle:
            
            cell = createTitleCell(tableView, chapter.title, row)
            
        case .uid_chapterStartTime:
            
            cell = createDurationCell(tableView, columnId, ValueFormatter.formatSecondsToHMS(chapter.startTime), row)
            
        case .uid_chapterDuration:
            
            cell = createDurationCell(tableView, columnId, ValueFormatter.formatSecondsToHMS(chapter.duration), row)
            
        default: return nil
            
        }
        
        cell.realignText(yOffset: fontSchemesManager.systemScheme.playlist.trackTextYOffset)
        return cell
    }
    
    private func createIndexCell(_ tableView: NSTableView, _ text: String, _ row: Int, _ showCurrentChapterMarker: Bool) -> ChaptersListTableCellView? {
        
        guard let cell = tableView.makeView(withIdentifier: .uid_chapterIndex, owner: nil) as? ChaptersListTableCellView else {return nil}
        
        cell.unselectedTextFont = fontSchemesManager.systemScheme.playlist.trackTextFont
        cell.selectedTextFont = fontSchemesManager.systemScheme.playlist.trackTextFont
        
        cell.unselectedTextColor = Colors.Playlist.indexDurationTextColor
        cell.selectedTextColor = Colors.Playlist.indexDurationSelectedTextColor
        
        cell.rowSelectionStateFunction = {[weak tableView] in tableView?.selectedRowIndexes.contains(row) ?? false}
        
        cell.text = text
        cell.textField?.showIf(!showCurrentChapterMarker)
        
        cell.image = showCurrentChapterMarker ? Images.imgPlayingTrack.filledWithColor(Colors.Playlist.playingTrackIconColor) : nil
        cell.imageView?.showIf(showCurrentChapterMarker)
        
        return cell
    }
    
    private func createTitleCell(_ tableView: NSTableView, _ text: String, _ row: Int) -> ChaptersListTableCellView? {
        
        guard let cell = tableView.makeView(withIdentifier: .uid_chapterTitle, owner: nil) as? ChaptersListTableCellView else {return nil}
        
        cell.unselectedTextFont = fontSchemesManager.systemScheme.playlist.trackTextFont
        cell.selectedTextFont = fontSchemesManager.systemScheme.playlist.trackTextFont
        
        cell.unselectedTextColor = Colors.Playlist.trackNameTextColor
        cell.selectedTextColor = Colors.Playlist.trackNameSelectedTextColor
        
        cell.text = text
        cell.textField?.show()
        
        cell.rowSelectionStateFunction = {[weak tableView] in tableView?.selectedRowIndexes.contains(row) ?? false}
        
        return cell
    }
    
    private func createDurationCell(_ tableView: NSTableView, _ id: NSUserInterfaceItemIdentifier, _ text: String, _ row: Int) -> ChaptersListTableCellView? {
        
        guard let cell = tableView.makeView(withIdentifier: id, owner: nil) as? ChaptersListTableCellView else {return nil}
        
        cell.unselectedTextFont = fontSchemesManager.systemScheme.playlist.trackTextFont
        cell.selectedTextFont = fontSchemesManager.systemScheme.playlist.trackTextFont
        
        cell.unselectedTextColor = Colors.Playlist.indexDurationTextColor
        cell.selectedTextColor = Colors.Playlist.indexDurationSelectedTextColor
        
        cell.text = text
        cell.textField?.show()
        
        cell.rowSelectionStateFunction = {[weak tableView] in tableView?.selectedRowIndexes.contains(row) ?? false}
        
        return cell
    }
    
    // Enables type selection, allowing the user to conveniently and efficiently find a chapter by typing its display name, which results in the chapter, if found, being selected within the list
    func tableView(_ tableView: NSTableView, typeSelectStringFor tableColumn: NSTableColumn?, row: Int) -> String? {
        
        if let track = playbackInfo.playingTrack,
           tableColumn?.identifier == .uid_chapterTitle,
           row < playbackInfo.chapterCount {
            
            return track.chapters[row].title
        }
        
        return nil
    }
}

/*
    Data source for the NSTableView that displays the chapters list
 */
class ChaptersListViewDataSource: NSObject, NSTableViewDataSource {
    
    // Used to determine if a track is currently playing
    private let playbackInfo: PlaybackInfoDelegateProtocol = objectGraph.playbackInfoDelegate
    
    // Returns the total number of playlist rows (i.e. the number of chapters for the currently playing track)
    func numberOfRows(in tableView: NSTableView) -> Int {playbackInfo.chapterCount}
}
