import Cocoa

/*
    Delegate for the NSTableView that displays track chapters
 */
class ChaptersViewDelegate: NSObject, NSTableViewDelegate {
    
    @IBOutlet weak var chaptersView: NSTableView!
    
    // Delegate that relays accessor operations to the playlist
    private let playlist: PlaylistAccessorDelegateProtocol = ObjectGraph.playlistAccessorDelegate
    
    // Used to determine the currently playing track
    private let playbackInfo: PlaybackInfoDelegateProtocol = ObjectGraph.playbackInfoDelegate
    
    override func awakeFromNib() {
    }
    
    // Returns a view for a single row
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        return AuralTableRowView()
    }
    
    // Returns a view for a single column
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        if let track = playbackInfo.playingTrack?.track, track.hasChapters, row < playbackInfo.chapterCount {
            
            let chapter = track.chapters[row]
            
            switch convertFromNSUserInterfaceItemIdentifier(tableColumn!.identifier) {
                
            case UIConstants.chapterIndexColumnID:
                
                if row == playbackInfo.playingChapter {
                    return createIndexImageCell(tableView, UIConstants.chapterIndexColumnID, String(describing: row + 1), row)
                }
                
                return createIndexTextCell(tableView, UIConstants.chapterIndexColumnID, String(describing: row + 1), row)
                
            case UIConstants.chapterTitleColumnID:
                
                return createTitleCell(tableView, UIConstants.chapterTitleColumnID, chapter.title, row)
                
            case UIConstants.chapterStartTimeColumnID:
                
                return createDurationCell(tableView, UIConstants.chapterStartTimeColumnID, StringUtils.formatSecondsToHMS(chapter.startTime), row)
                
            case UIConstants.chapterDurationColumnID:
                
                return createDurationCell(tableView, UIConstants.chapterDurationColumnID, StringUtils.formatSecondsToHMS(chapter.duration), row)
                
            default: return nil
                
            }
        }
        
        return nil
    }
    
    private func createIndexTextCell(_ tableView: NSTableView, _ id: String, _ text: String, _ row: Int) -> BasicTableCellView? {
        
        if let cell = tableView.makeView(withIdentifier: convertToNSUserInterfaceItemIdentifier(id), owner: nil) as? BasicTableCellView {
            
            cell.textFont = TextSizes.playlistTrackNameFont
            cell.selectedTextFont = TextSizes.playlistTrackNameFont
            
            cell.textColor = Colors.playlistIndexTextColor
            cell.selectedTextColor = Colors.playlistSelectedIndexTextColor
            
            cell.selectionFunction = {() -> Bool in
                return tableView.selectedRowIndexes.contains(row)
            }
            
            cell.textField?.stringValue = text
            cell.textField?.show()
            cell.imageView?.hide()
            cell.row = row
            
            return cell
        }
        
        return nil
    }
    
    private func createIndexImageCell(_ tableView: NSTableView, _ id: String, _ text: String, _ row: Int) -> BasicTableCellView? {
        
        if let cell = tableView.makeView(withIdentifier: convertToNSUserInterfaceItemIdentifier(id), owner: nil) as? BasicTableCellView {
            
            // Configure and show the image view
            let imgView = cell.imageView!
            
            imgView.image = Images.imgPlayingTrack
            imgView.show()
            
            // Hide the text view
            cell.textField?.hide()
            
            cell.textFont = TextSizes.playlistTrackNameFont
            cell.selectedTextFont = TextSizes.playlistTrackNameFont
            
            cell.textColor = Colors.playlistIndexTextColor
            cell.selectedTextColor = Colors.playlistSelectedIndexTextColor
            
            cell.selectionFunction = {() -> Bool in
                return tableView.selectedRowIndexes.contains(row)
            }
            
            cell.textField?.stringValue = text
            cell.row = row
            
            return cell
        }
        
        return nil
    }
    
    private func createTitleCell(_ tableView: NSTableView, _ id: String, _ text: String, _ row: Int) -> BasicTableCellView? {
        
        if let cell = tableView.makeView(withIdentifier: convertToNSUserInterfaceItemIdentifier(id), owner: nil) as? BasicTableCellView {
            
            cell.textFont = TextSizes.playlistTrackNameFont
            cell.selectedTextFont = TextSizes.playlistTrackNameFont
            
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
            
            cell.textFont = TextSizes.playlistTrackNameFont
            cell.selectedTextFont = TextSizes.playlistTrackNameFont
            
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
    
    // Creates a cell view containing the animation for the currently playing track
    private func createPlayingTrackImageCell(_ tableView: NSTableView, _ id: String, _ text: String, _ row: Int) -> IndexCellView? {
        return createIndexImageCell(tableView, id, text, row, Images.imgPlayingTrack)
    }
    
    private func createIndexImageCell(_ tableView: NSTableView, _ id: String, _ text: String, _ row: Int, _ image: NSImage) -> IndexCellView? {
        
        if let cell = tableView.makeView(withIdentifier: convertToNSUserInterfaceItemIdentifier(UIConstants.playlistIndexColumnID), owner: nil) as? IndexCellView {
            
            // Configure and show the image view
            let imgView = cell.imageView!
            
            imgView.image = image
            imgView.show()
            
            // Hide the text view
            cell.textField?.hide()
            
            cell.textField?.stringValue = text
            cell.row = row
            
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
    Data source for the NSTableView that displays track chapters
 */
class ChaptersViewDataSource: NSObject, NSTableViewDataSource {
    
    // Used to determine if a track is currently playing
    private let playbackInfo: PlaybackInfoDelegateProtocol = ObjectGraph.playbackInfoDelegate
    
    // Returns the total number of playlist rows
    func numberOfRows(in tableView: NSTableView) -> Int {
        return playbackInfo.playingTrack?.track.chapters.count ?? 0
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSUserInterfaceItemIdentifier(_ input: NSUserInterfaceItemIdentifier) -> String {
    return input.rawValue
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToNSUserInterfaceItemIdentifier(_ input: String) -> NSUserInterfaceItemIdentifier {
    return NSUserInterfaceItemIdentifier(rawValue: input)
}
