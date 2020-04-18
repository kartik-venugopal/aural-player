import Cocoa

/*
    Delegate for the chapters list NSTableView
 */
class ChaptersListViewDelegate: NSObject, NSTableViewDelegate {
    
    // Used to determine the currently playing track/chapter
    private let playbackInfo: PlaybackInfoDelegateProtocol = ObjectGraph.playbackInfoDelegate
    
    // Returns a custom view for a single row
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        return AuralTableRowView()
    }
    
    // Returns a view for a single column
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        if let track = playbackInfo.playingTrack?.track, track.hasChapters, row < playbackInfo.chapterCount {
            
            let chapter = track.chapters[row]
            let columnId: String = tableColumn!.identifier.rawValue
            
            switch columnId {
                
            case UIConstants.chapterIndexColumnID:
                
                // Display a marker icon if this chapter is currently playing
                return createIndexCell(tableView, String(describing: row + 1), row, row == playbackInfo.playingChapter?.index)
                
            case UIConstants.chapterTitleColumnID:
                
                return createTitleCell(tableView, chapter.title, row)
                
            case UIConstants.chapterStartTimeColumnID:
                
                return createDurationCell(tableView, columnId, StringUtils.formatSecondsToHMS(chapter.startTime), row)
                
            case UIConstants.chapterDurationColumnID:
                
                return createDurationCell(tableView, columnId, StringUtils.formatSecondsToHMS(chapter.duration), row)
                
            default: return nil
                
            }
        }
        
        return nil
    }
    
    private func createIndexCell(_ tableView: NSTableView, _ text: String, _ row: Int, _ showCurrentChapterMarker: Bool) -> BasicTableCellView? {
        
        if let cell = tableView.makeView(withIdentifier: convertToNSUserInterfaceItemIdentifier(UIConstants.chapterIndexColumnID), owner: nil) as? BasicTableCellView {
            
            cell.textFont = Fonts.Playlist.indexFont
            cell.selectedTextFont = Fonts.Playlist.indexFont
            
            cell.textColor = Colors.playlistIndexTextColor
            cell.selectedTextColor = Colors.playlistSelectedIndexTextColor
            
            cell.selectionFunction = {() -> Bool in
                return tableView.selectedRowIndexes.contains(row)
            }
            
            cell.textField?.stringValue = text
            cell.textField?.showIf_elseHide(!showCurrentChapterMarker)
            
            cell.imageView!.image = showCurrentChapterMarker ? Images.imgPlayingTrack : nil
            cell.imageView!.showIf_elseHide(showCurrentChapterMarker)
            
            return cell
        }
        
        return nil
    }
    
    private func createTitleCell(_ tableView: NSTableView, _ text: String, _ row: Int) -> BasicTableCellView? {
        
        if let cell = tableView.makeView(withIdentifier: convertToNSUserInterfaceItemIdentifier(UIConstants.chapterTitleColumnID), owner: nil) as? BasicTableCellView {
            
            cell.textFont = Fonts.Playlist.trackNameFont
            cell.selectedTextFont = Fonts.Playlist.trackNameFont
            
            cell.textColor = Colors.playlistTextColor
            cell.selectedTextColor = Colors.playlistSelectedTextColor
            
            cell.textField?.stringValue = text
            cell.textField?.show()
            
            cell.selectionFunction = {() -> Bool in
                return tableView.selectedRowIndexes.contains(row)
            }
            
            return cell
        }
        
        return nil
    }
    
    private func createDurationCell(_ tableView: NSTableView, _ id: String, _ text: String, _ row: Int) -> BasicTableCellView? {
        
        if let cell = tableView.makeView(withIdentifier: convertToNSUserInterfaceItemIdentifier(id), owner: nil) as? BasicTableCellView {
            
            cell.textFont = Fonts.Playlist.indexFont
            cell.selectedTextFont = Fonts.Playlist.indexFont
            
            cell.textColor = Colors.playlistIndexTextColor
            cell.selectedTextColor = Colors.playlistSelectedIndexTextColor
            
            cell.textField?.stringValue = text
            cell.textField?.show()
            
            cell.selectionFunction = {() -> Bool in
                return tableView.selectedRowIndexes.contains(row)
            }
            
            return cell
        }
        
        return nil
    }
    
    // Enables type selection, allowing the user to conveniently and efficiently find a chapter by typing its display name, which results in the chapter, if found, being selected within the list
    func tableView(_ tableView: NSTableView, typeSelectStringFor tableColumn: NSTableColumn?, row: Int) -> String? {
        
        if let track = playbackInfo.playingTrack?.track, let colID = tableColumn?.identifier.rawValue, colID == UIConstants.chapterTitleColumnID,
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
    private let playbackInfo: PlaybackInfoDelegateProtocol = ObjectGraph.playbackInfoDelegate
    
    // Returns the total number of playlist rows
    func numberOfRows(in tableView: NSTableView) -> Int {
        return playbackInfo.chapterCount
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToNSUserInterfaceItemIdentifier(_ input: String) -> NSUserInterfaceItemIdentifier {
    return NSUserInterfaceItemIdentifier(rawValue: input)
}
