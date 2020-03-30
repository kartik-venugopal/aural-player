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
        
        if let track = playbackInfo.playingTrack?.track {
            
            let chapter = track.chapters[row]
            
            switch convertFromNSUserInterfaceItemIdentifier(tableColumn!.identifier) {
                
            case UIConstants.chapterIndexColumnID:
                
                let indexText: String = String(describing: row + 1)
                
                return createIndexTextCell(tableView, UIConstants.chapterIndexColumnID, indexText, row)
                
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
    
    private func createIndexTextCell(_ tableView: NSTableView, _ id: String, _ text: String, _ row: Int) -> IndexCellView? {
        
        if let cell = tableView.makeView(withIdentifier: convertToNSUserInterfaceItemIdentifier(id), owner: nil) as? IndexCellView {
            
            cell.textField?.font = TextSizes.playlistIndexFont
            cell.textField?.stringValue = text
            cell.textField?.show()
            cell.imageView?.hide()
            cell.row = row
            
            return cell
        }
        
        return nil
    }
    
    private func createTitleCell(_ tableView: NSTableView, _ id: String, _ text: String, _ row: Int) -> TrackNameCellView? {
        
        if let cell = tableView.makeView(withIdentifier: convertToNSUserInterfaceItemIdentifier(id), owner: nil) as? TrackNameCellView {
            
            cell.textField?.font = TextSizes.playlistTrackNameFont
            cell.textField?.stringValue = text
            cell.textField?.show()
            cell.row = row
            
            print("Created title cell with title:", text)
            
            return cell
        }
        
        return nil
    }
    
    private func createDurationCell(_ tableView: NSTableView, _ id: String, _ text: String, _ row: Int) -> DurationCellView? {
        
        if let cell = tableView.makeView(withIdentifier: convertToNSUserInterfaceItemIdentifier(id), owner: nil) as? DurationCellView {
            
            cell.textField?.font = TextSizes.playlistIndexFont
            cell.textField?.stringValue = text
            cell.textField?.show()
            cell.row = row
            
            return cell
        }
        
        return nil
    }
    
    // MARK: Constraints for Index cells
    
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
