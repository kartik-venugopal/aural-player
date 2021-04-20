import Cocoa

/*
    Delegate for the chapters list NSTableView
 */
class ChaptersListViewDelegate: NSObject, NSTableViewDelegate {
    
    // Used to determine the currently playing track/chapter
    private let playbackInfo: PlaybackInfoDelegateProtocol = ObjectGraph.playbackInfoDelegate
    
    // Returns a custom view for a single row
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        return PlaylistRowView()
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 30
    }
    
    // Returns a view for a single column
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        guard let track = playbackInfo.playingTrack, track.hasChapters, row < playbackInfo.chapterCount, let columnId = tableColumn?.identifier else {return nil}
            
        let chapter = track.chapters[row]
        
        switch columnId {
            
        case .uid_chapterIndex:
            
            // Display a marker icon if this chapter is currently playing
            return createIndexCell(tableView, String(row + 1), row, row == playbackInfo.playingChapter?.index)
            
        case .uid_chapterTitle:
            
            return createTitleCell(tableView, chapter.title, row)
            
        case .uid_chapterStartTime:
            
            return createDurationCell(tableView, columnId, ValueFormatter.formatSecondsToHMS(chapter.startTime), row)
            
        case .uid_chapterDuration:
            
            return createDurationCell(tableView, columnId, ValueFormatter.formatSecondsToHMS(chapter.duration), row)
            
        default: return nil
            
        }
    }
    
    private func createIndexCell(_ tableView: NSTableView, _ text: String, _ row: Int, _ showCurrentChapterMarker: Bool) -> BasicTableCellView? {
        
        guard let cell = tableView.makeView(withIdentifier: .uid_chapterIndex, owner: nil) as? BasicTableCellView else {return nil}
        
        cell.textFont = FontSchemes.systemScheme.playlist.trackTextFont
        cell.selectedTextFont = FontSchemes.systemScheme.playlist.trackTextFont
        
        cell.textColor = Colors.Playlist.indexDurationTextColor
        cell.selectedTextColor = Colors.Playlist.indexDurationSelectedTextColor
        
        cell.rowSelectionStateFunction = {[weak tableView] in tableView?.selectedRowIndexes.contains(row) ?? false}
        
        cell.textField?.stringValue = text
        cell.textField?.showIf(!showCurrentChapterMarker)
        
        cell.imageView?.image = showCurrentChapterMarker ? Images.imgPlayingTrack.applyingTint(Colors.Playlist.playingTrackIconColor) : nil
        cell.imageView?.showIf(showCurrentChapterMarker)
        
        return cell
    }
    
    private func createTitleCell(_ tableView: NSTableView, _ text: String, _ row: Int) -> BasicTableCellView? {
        
        guard let cell = tableView.makeView(withIdentifier: .uid_chapterTitle, owner: nil) as? BasicTableCellView else {return nil}
        
        cell.textFont = FontSchemes.systemScheme.playlist.trackTextFont
        cell.selectedTextFont = FontSchemes.systemScheme.playlist.trackTextFont
        
        cell.textColor = Colors.Playlist.trackNameTextColor
        cell.selectedTextColor = Colors.Playlist.trackNameSelectedTextColor
        
        cell.textField?.stringValue = text
        cell.textField?.show()
        
        cell.rowSelectionStateFunction = {[weak tableView] in tableView?.selectedRowIndexes.contains(row) ?? false}
        
        return cell
    }
    
    private func createDurationCell(_ tableView: NSTableView, _ id: NSUserInterfaceItemIdentifier, _ text: String, _ row: Int) -> BasicTableCellView? {
        
        guard let cell = tableView.makeView(withIdentifier: id, owner: nil) as? BasicTableCellView else {return nil}
        
        cell.textFont = FontSchemes.systemScheme.playlist.trackTextFont
        cell.selectedTextFont = FontSchemes.systemScheme.playlist.trackTextFont
        
        cell.textColor = Colors.Playlist.indexDurationTextColor
        cell.selectedTextColor = Colors.Playlist.indexDurationSelectedTextColor
        
        cell.textField?.stringValue = text
        cell.textField?.show()
        
        cell.rowSelectionStateFunction = {[weak tableView] in tableView?.selectedRowIndexes.contains(row) ?? false}
        
        return cell
    }
    
    // Enables type selection, allowing the user to conveniently and efficiently find a chapter by typing its display name, which results in the chapter, if found, being selected within the list
    func tableView(_ tableView: NSTableView, typeSelectStringFor tableColumn: NSTableColumn?, row: Int) -> String? {
        
        if let track = playbackInfo.playingTrack, tableColumn?.identifier == .uid_chapterTitle, row < playbackInfo.chapterCount {
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
    private let playbackInfo: PlaybackInfoDelegateProtocol = ObjectGraph.playbackInfoDelegate
    
    // Returns the total number of playlist rows (i.e. the number of chapters for the currently playing track)
    func numberOfRows(in tableView: NSTableView) -> Int {playbackInfo.chapterCount}
}
