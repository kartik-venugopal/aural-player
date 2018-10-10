import Cocoa

/*
    Delegate for the NSTableView that displays the "Tracks" (flat) playlist view.
 */
class TracksPlaylistViewDelegate: NSObject, NSTableViewDelegate, MessageSubscriber {
    
    @IBOutlet weak var playlistView: NSTableView!
    
    // Delegate that relays accessor operations to the playlist
    private let playlist: PlaylistAccessorDelegateProtocol = ObjectGraph.getPlaylistAccessorDelegate()
    
    // Used to determine the currently playing track
    private let playbackInfo: PlaybackInfoDelegateProtocol = ObjectGraph.getPlaybackInfoDelegate()
    
    // Stores the cell containing the playing track animation, for convenient access when pausing/resuming the animation
    private var animationCell: TrackNameCellView?
    
    override func awakeFromNib() {
        
        // Subscribe to message notifications
        SyncMessenger.subscribe(messageTypes: [.playbackStateChangedNotification], subscriber: self)
        
        // Store the NSTableView in a variable for convenient subsequent access
        TableViewHolder.instance = playlistView
    }
    
    // Returns a view for a single row
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        return AuralTableRowView()
    }
    
    // Enables type selection, allowing the user to conveniently and efficiently find a playlist track by typing its display name, which results in the track, if found, being selected within the playlist
    func tableView(_ tableView: NSTableView, typeSelectStringFor tableColumn: NSTableColumn?, row: Int) -> String? {
        
        // Only the track name column is used for type selection
        let colID = tableColumn?.identifier.rawValue ?? ""
        if colID != UIConstants.playlistNameColumnID {
            return nil
        }
        
        return playlist.trackAtIndex(row)?.track.conciseDisplayName
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        
        if let track = playlist.trackAtIndex(row)?.track {
            
            let ga = playlist.getGapAfterTrack(track)
            let gb = playlist.getGapBeforeTrack(track)
            
            if ga != nil && gb != nil {
                return 58
            } else if ga != nil || gb != nil {
                return 40
            }
        }

        return 22
    }
    
    // Returns a view for a single column
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        if let track = playlist.trackAtIndex(row)?.track {
            
            let gapA = playlist.getGapAfterTrack(track)
            let gapB = playlist.getGapBeforeTrack(track)
            
            switch convertFromNSUserInterfaceItemIdentifier(tableColumn!.identifier) {
                
            case UIConstants.playlistIndexColumnID:
                
                // Track index
                let playingTrackIndex = playbackInfo.getPlayingTrack()?.index
                
                // If this row contains the playing track, display an animation, instead of the track index
                if (playingTrackIndex != nil && playingTrackIndex == row) {
                    
                    animationCell = createPlayingTrackAnimationCell(tableView)
                    return animationCell
                    
                } else {
                    
                    // Otherwise, create a text cell with the track index
                    return createDurationCell(tableView, UIConstants.playlistIndexColumnID, String(format: "%d.", row + 1), nil, nil, row)
                }
                
            case UIConstants.playlistNameColumnID:
                
                return createTrackNameCell(tableView, UIConstants.playlistNameColumnID, track.conciseDisplayName, gapB, gapA, row)
                
            case UIConstants.playlistDurationColumnID:
                
                return createDurationCell(tableView, UIConstants.playlistDurationColumnID, StringUtils.formatSecondsToHMS(track.duration), gapB, gapA, row)
                
            default: return nil
                
            }
        }
        
        return nil
    }
    
    private func createTrackNameCell(_ tableView: NSTableView, _ id: String, _ text: String, _ gapBefore: PlaybackGap? = nil, _ gapAfter: PlaybackGap? = nil, _ row: Int) -> TrackNameCellView? {
        
        if let cell = tableView.makeView(withIdentifier: convertToNSUserInterfaceItemIdentifier(id), owner: nil) as? TrackNameCellView {
            
            cell.textField?.stringValue = text
            cell.textField?.isHidden = false
            cell.row = row
            
            if cell.gapAfterImg == nil {
                return cell
            }
            
            let both = gapBefore != nil && gapAfter != nil
            let aOnly = gapAfter != nil && gapBefore == nil
            let bOnly = gapBefore != nil && gapAfter == nil
            
            if aOnly {
                
                print("\nA only")
                
                cell.gapBeforeImg.isHidden = true
                cell.gapAfterImg.isHidden = false
                
                adjustConstraints_mainFieldOnTop(cell)
                
                cell.gapAfterImg.setFrameOrigin(NSPoint.zero)
                
            } else if bOnly {
                
                print("\nB only")
                
                cell.gapBeforeImg.isHidden = false
                cell.gapAfterImg.isHidden = true
                
                adjustConstraints_beforeGapFieldOnTop(cell, cell.gapBeforeImg)
                
                cell.textField!.setFrameOrigin(NSPoint.zero)
                
            } else if both {
                
                print("\nBoth")
                
                cell.gapBeforeImg.isHidden = false
                cell.gapAfterImg.isHidden = false
                
                adjustConstraints_beforeGapFieldOnTop(cell, cell.gapBeforeImg)
                
                cell.gapAfterImg.setFrameOrigin(NSPoint.zero)
                
            } else {
                
                // Neither
                
                adjustConstraints_mainFieldOnTop(cell)
                
                cell.textField!.setFrameOrigin(NSPoint.zero)
            }
            
            
            return cell
        }
        
        return nil
    }
    
    private func createDurationCell(_ tableView: NSTableView, _ id: String, _ text: String, _ gapBefore: PlaybackGap? = nil, _ gapAfter: PlaybackGap? = nil, _ row: Int) -> DurationCellView? {
        
        if let cell = tableView.makeView(withIdentifier: convertToNSUserInterfaceItemIdentifier(id), owner: nil) as? DurationCellView {
            
            cell.textField?.stringValue = text
            cell.textField?.isHidden = false
            cell.row = row
            
            if cell.gapAfterTextField == nil {
                return cell
            }
            
            let both = gapBefore != nil && gapAfter != nil
            let aOnly = gapAfter != nil && gapBefore == nil
            let bOnly = gapBefore != nil && gapAfter == nil
            
            if aOnly {
                
                print("\nA only")
                
                let gap = gapAfter!
                
                cell.gapBeforeTextField.isHidden = true
                cell.gapAfterTextField.isHidden = false
                
                cell.gapAfterTextField.stringValue = id == UIConstants.playlistNameColumnID ? String(format: "[GAP: %.0lf seconds]", gap.duration) : StringUtils.formatSecondsToHMS(gap.duration)
                
                adjustConstraints_mainFieldOnTop(cell)
                
                cell.gapAfterTextField.setFrameOrigin(NSPoint.zero)
                
            } else if bOnly {
                
                print("\nB only")
                
                let gap = gapBefore!
                
                cell.gapBeforeTextField.isHidden = false
                cell.gapAfterTextField.isHidden = true
                
                cell.gapBeforeTextField.stringValue = id == UIConstants.playlistNameColumnID ? String(format: "[GAP: %.0lf seconds]", gap.duration) : StringUtils.formatSecondsToHMS(gap.duration)
                
                adjustConstraints_beforeGapFieldOnTop(cell, cell.gapBeforeTextField)
                
                cell.textField!.setFrameOrigin(NSPoint.zero)
                
            } else if both {
                
                print("\nBoth")
                
                let gapA = gapAfter!
                let gapB = gapBefore!
                
                cell.gapBeforeTextField.isHidden = false
                cell.gapAfterTextField.isHidden = false
                
                cell.gapBeforeTextField.stringValue = id == UIConstants.playlistNameColumnID ? String(format: "[GAP: %.0lf seconds]", gapB.duration) : StringUtils.formatSecondsToHMS(gapB.duration)
                
                cell.gapAfterTextField.stringValue = id == UIConstants.playlistNameColumnID ? String(format: "[GAP: %.0lf seconds]", gapA.duration) : StringUtils.formatSecondsToHMS(gapA.duration)
                
                adjustConstraints_beforeGapFieldOnTop(cell, cell.gapBeforeTextField)
                
                cell.gapAfterTextField.setFrameOrigin(NSPoint.zero)
                
            } else {
                
                // Neither
                
                adjustConstraints_mainFieldOnTop(cell)
                
                cell.textField!.setFrameOrigin(NSPoint.zero)
            }
            
            
            return cell
        }
        
        return nil
    }
    
    private func adjustConstraints_mainFieldOnTop(_ cell: NSTableCellView) {
        
        let main = cell.textField!
        
        for con in cell.constraints {
            
            if con.firstItem === main && con.firstAttribute == .top {
                
                print("Found con")
                con.isActive = false
                cell.removeConstraint(con)
                break
            }
        }
        
        let mainFieldOnTop = NSLayoutConstraint(item: main, attribute: .top, relatedBy: .equal, toItem: cell, attribute: .top, multiplier: 1.0, constant: 0)
        mainFieldOnTop.isActive = true
        cell.addConstraint(mainFieldOnTop)
    }
    
    private func adjustConstraints_beforeGapFieldOnTop(_ cell: NSTableCellView, _ gapView: NSView) {
        
        let main = cell.textField!
        
        for con in cell.constraints {
            
            if con.firstItem === main && con.firstAttribute == .top {
                
                print("Found con2")
                con.isActive = false
                cell.removeConstraint(con)
                break
            }
        }
        
        let befFieldOnTop = NSLayoutConstraint(item: main, attribute: .top, relatedBy: .equal, toItem: gapView, attribute: .bottom, multiplier: 1.0, constant: 0)
        befFieldOnTop.isActive = true
        cell.addConstraint(befFieldOnTop)
        
    }
    
    // Creates a cell view containing the animation for the currently playing track
    private func createPlayingTrackAnimationCell(_ tableView: NSTableView) -> TrackNameCellView? {
        
        if let cell = tableView.makeView(withIdentifier: convertToNSUserInterfaceItemIdentifier(UIConstants.playlistIndexColumnID), owner: nil) as? TrackNameCellView {
            
            // Configure and show the image view
            let imgView = cell.imageView!
            
            imgView.image = Images.imgPlayingTrack
            imgView.isHidden = false
            
            // Hide the text view
            cell.textField?.isHidden = true
            
            return cell
        }
        
        return nil
    }
    
    // MARK: Message handling
    
    func getID() -> String {
        return self.className
    }
    
    // Whenever the playing track is paused/resumed, the animation needs to be paused/resumed.
    private func playbackStateChanged(_ message: PlaybackStateChangedNotification) {
        
        switch (message.newPlaybackState) {
            
        case .noTrack:
            
            // The track is no longer playing
            animationCell = nil
            
        case .playing, .paused:
            
            animationCell?.imageView?.image = Images.imgPlayingTrack
            
        }
    }
    
    func consumeNotification(_ notification: NotificationMessage) {
        
        switch notification.messageType {
            
        case .playbackStateChangedNotification:
            
            playbackStateChanged(notification as! PlaybackStateChangedNotification)
            
        default: return
            
        }
    }
    
    func processRequest(_ request: RequestMessage) -> ResponseMessage {
        return EmptyResponse.instance
    }
}

// Utility class to hold an NSTableView instance for convenient access
class TableViewHolder {
    
    static var instance: NSTableView?
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSUserInterfaceItemIdentifier(_ input: NSUserInterfaceItemIdentifier) -> String {
	return input.rawValue
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToNSUserInterfaceItemIdentifier(_ input: String) -> NSUserInterfaceItemIdentifier {
	return NSUserInterfaceItemIdentifier(rawValue: input)
}
