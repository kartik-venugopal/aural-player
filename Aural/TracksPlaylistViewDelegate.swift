import Cocoa

/*
    Delegate for the NSTableView that displays the "Tracks" (flat) playlist view.
 */
class TracksPlaylistViewDelegate: NSObject, NSOutlineViewDelegate {
    
    // TODO: Reduce code duplication in the cell creation and constraint code
    
    @IBOutlet weak var playlistView: NSOutlineView!
    
    // Delegate that relays accessor operations to the playlist
    private let playlist: PlaylistAccessorDelegateProtocol = ObjectGraph.playlistAccessorDelegate
    
    // Used to determine the currently playing track
    private let playbackInfo: PlaybackInfoDelegateProtocol = ObjectGraph.playbackInfoDelegate
    
    override func awakeFromNib() {
        
        // Store the NSTableView in a variable for convenient subsequent access
        TableViewHolder.instance = playlistView
    }
    
    // Returns a view for a single row
    func outlineView(_ outlineView: NSOutlineView, rowViewForItem item: Any) -> NSTableRowView? {
        return AuralTableRowView()
    }
    
    func outlineView(_ outlineView: NSOutlineView, typeSelectStringFor tableColumn: NSTableColumn?, item: Any) -> String? {
        
        if let colID = tableColumn?.identifier.rawValue, colID != UIConstants.playlistNameColumnID {
            return nil
        }
        
        if let track = item as? Track {
            
            return track.conciseDisplayName
            
        } else if let chapter = item as? Chapter {
         
            return chapter.title
        }
        
        return nil
    }
    
    // Determines the height of a single row
    func outlineView(_ outlineView: NSOutlineView, heightOfRowByItem item: Any) -> CGFloat {
        
        if let track = item as? Track {
            
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
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        
        let row = outlineView.row(forItem: item)
        
        if let track = item as? Track, let colID = tableColumn?.identifier {
            
            switch colID.rawValue {
                
            case UIConstants.playlistIndexColumnID:
                
                return createCell(outlineView, colID, String(describing: row + 1), row)
                
            case UIConstants.playlistNameColumnID:
                
                return createNameCell(outlineView, colID, track.conciseDisplayName, row)
                
            case UIConstants.playlistDurationColumnID:
                
                return createDurationCell(outlineView, colID, StringUtils.formatSecondsToHMS(track.duration), row)
                
            default:
                
                return nil
            }
            
        } else if let chapter = item as? Chapter, let colID = tableColumn?.identifier {
            
            switch colID.rawValue {
                
            case UIConstants.playlistNameColumnID:
                
                return createNameCell(outlineView, colID, chapter.title, row)
                
            case UIConstants.playlistDurationColumnID:
                
                return createDurationCell(outlineView, colID, StringUtils.formatSecondsToHMS(chapter.duration), row)
                
            default:
                
                return nil
            }
        }
        
        return nil
    }
    
    private func createCell(_ outlineView: NSOutlineView, _ id: NSUserInterfaceItemIdentifier, _ text: String, _ row: Int) -> NSTableCellView? {
        
        
        
        if let cell = outlineView.makeView(withIdentifier: id, owner: nil) as? IndexCellView {
            
            cell.textField?.stringValue = text
            cell.textField?.show()
            cell.imageView?.hide()
            cell.row = row
            
//            print("Created cell:", text)
            
            return cell
        }
        
        return nil
    }
    
    private func createNameCell(_ outlineView: NSOutlineView, _ id: NSUserInterfaceItemIdentifier, _ text: String, _ row: Int) -> NSTableCellView? {
        
        if let cell = outlineView.makeView(withIdentifier: id, owner: nil) as? TrackNameCellView {
            
            cell.textField?.stringValue = text
            cell.textField?.show()
            cell.imageView?.hide()
            cell.row = row
            
            cell.gapBeforeImg.hide()
            cell.gapAfterImg.hide()
            
            cell.placeTextFieldOnTop()
            
//            print("Created Name cell:", text, cell.textField?.isHidden, cell.textField?.textColor, cell.frame)
            
            return cell
        }
        
        return nil
    }
    
    private func createDurationCell(_ outlineView: NSOutlineView, _ id: NSUserInterfaceItemIdentifier, _ text: String, _ row: Int) -> NSTableCellView? {
        
        if let cell = outlineView.makeView(withIdentifier: id, owner: nil) as? DurationCellView {
            
            cell.textField?.stringValue = text
            cell.textField?.show()
            cell.row = row
            
            cell.gapBeforeTextField.hide()
            cell.gapAfterTextField.hide()
            
            cell.placeTextFieldOnTop()
            
//            print("Created Duration cell:", text)
            
            return cell
        }
        
        return nil
    }
    
//    // Returns a view for a single column
//    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
//
//        if let track = item as? Track {
//
//        switch tableColumn!.identifier.rawValue {
//
//        case UIConstants.playlistIndexColumnID:
//
//            let index = playlist.indexOfTrack(track)
//
//
//        case UIConstants.playlistNameColumnID:
//
//            // Name
//
//                let track = item as! Track
//
//                let gapA = playlist.getGapAfterTrack(track)
//                let gapB = playlist.getGapBeforeTrack(track)
//
//                var image: NSImage?
//
//                let isPlayingTrack: Bool = track == playbackInfo.playingTrack?.track
//
//                switch playbackInfo.state {
//
//                case .playing, .paused:
//
//                    image = isPlayingTrack ? Images.imgPlayingTrack : nil
//
//                case .transcoding:
//
//                    image = isPlayingTrack ? Images.imgTranscodingTrack : nil
//
//                case .waiting:
//
//                    image = track == playbackInfo.waitingTrack?.track ? Images.imgWaitingTrack : nil
//
//                case .noTrack:
//
//                    image = nil
//
//                let cell = createImageAndTextCell_gaps(outlineView, tableColumn!.identifier.rawValue, false, playlist.displayNameForTrack(playlistType, track), image, isPlayingTrack, gapB, gapA)
//
//                cell?.item = track
//                cell?.playlistType = self.playlistType
//                return cell
//            }
//
//        case UIConstants.playlistDurationColumnID:
//
//            // Duration
//
//            if let group = item as? Group {
//
//                let cell = createDurationCell(outlineView, UIConstants.playlistDurationColumnID, true, StringUtils.formatSecondsToHMS(group.duration), nil, nil)
//                cell?.item = group
//                cell?.playlistType = self.playlistType
//                return cell
//
//            } else {
//
//                let track = item as! Track
//
//                let gapA = playlist.getGapAfterTrack(track)
//                let gapB = playlist.getGapBeforeTrack(track)
//
//                let cell = createDurationCell(outlineView, UIConstants.playlistDurationColumnID, false, StringUtils.formatSecondsToHMS(track.duration), gapB, gapA)
//                cell?.item = track
//                cell?.playlistType = self.playlistType
//                return cell
//            }
//
//        default: return nil
//
//        }
//    }
//
//    private func createIndexTextCell(_ outlineView: NSOutlineView, _ id: String, _ text: String, _ gapBefore: PlaybackGap? = nil, _ gapAfter: PlaybackGap? = nil, _ row: Int) -> IndexCellView? {
//
//        if let cell = outlineView.makeView(withIdentifier: convertToNSUserInterfaceItemIdentifier(id), owner: nil) as? IndexCellView {
//
//            cell.textField?.stringValue = text
//            cell.textField?.show()
//            cell.imageView?.hide()
//            cell.row = row
//
//            let aOnly = gapAfter != nil && gapBefore == nil
//            let bOnly = gapBefore != nil && gapAfter == nil
//
//            if aOnly {
//
//                cell.adjustIndexConstraints_afterGapOnly()
//
//            } else if bOnly {
//
//                cell.adjustIndexConstraints_beforeGapOnly()
//
//            } else {
//
//                cell.adjustIndexConstraints_centered()
//            }
//
//            return cell
//        }
//
//        return nil
//    }
//
//    private func createTrackNameCell(_ outlineView: NSOutlineView, _ id: String, _ text: String, _ gapBefore: PlaybackGap? = nil, _ gapAfter: PlaybackGap? = nil, _ row: Int) -> TrackNameCellView? {
//
//        if let cell = tableView.makeView(withIdentifier: convertToNSUserInterfaceItemIdentifier(id), owner: nil) as? TrackNameCellView {
//
//            cell.textField?.stringValue = text
//            cell.textField?.show()
//            cell.row = row
//
//            let both = gapBefore != nil && gapAfter != nil
//            let aOnly = gapAfter != nil && gapBefore == nil
//            let bOnly = gapBefore != nil && gapAfter == nil
//
//            if aOnly {
//
//                cell.gapBeforeImg.hide()
//                cell.gapAfterImg.show()
//
//                cell.placeTextFieldOnTop()
//
//            } else if bOnly {
//
//                cell.gapBeforeImg.show()
//                cell.gapAfterImg.hide()
//
//                cell.placeTextFieldBelowView(cell.gapBeforeImg)
//
//            } else if both {
//
//                cell.gapBeforeImg.show()
//                cell.gapAfterImg.show()
//
//                cell.placeTextFieldBelowView(cell.gapBeforeImg)
//
//            } else {
//
//                // Neither
//                cell.gapBeforeImg.hide()
//                cell.gapAfterImg.hide()
//
//                cell.placeTextFieldOnTop()
//            }
//
//            return cell
//        }
//
//        return nil
//    }
//
//    private func createDurationCell(_ tableView: NSTableView, _ id: String, _ text: String, _ gapBefore: PlaybackGap? = nil, _ gapAfter: PlaybackGap? = nil, _ row: Int) -> DurationCellView? {
//
//        if let cell = tableView.makeView(withIdentifier: convertToNSUserInterfaceItemIdentifier(id), owner: nil) as? DurationCellView {
//
//            cell.textField?.stringValue = text
//            cell.textField?.show()
//            cell.row = row
//
//            if cell.gapAfterTextField == nil {
//                return cell
//            }
//
//            let both = gapBefore != nil && gapAfter != nil
//            let aOnly = gapAfter != nil && gapBefore == nil
//            let bOnly = gapBefore != nil && gapAfter == nil
//
//            if aOnly {
//
//                let gap = gapAfter!
//
//                cell.gapBeforeTextField.hide()
//                cell.gapAfterTextField.show()
//
//                cell.gapAfterTextField.stringValue = StringUtils.formatSecondsToHMS(gap.duration)
//
//                cell.placeTextFieldOnTop()
//
//            } else if bOnly {
//
//                let gap = gapBefore!
//
//                cell.gapBeforeTextField.show()
//                cell.gapAfterTextField.hide()
//
//                cell.gapBeforeTextField.stringValue = StringUtils.formatSecondsToHMS(gap.duration)
//
//                cell.placeTextFieldBelowView(cell.gapBeforeTextField)
//
//            } else if both {
//
//                let gapA = gapAfter!
//                let gapB = gapBefore!
//
//                cell.gapBeforeTextField.show()
//                cell.gapAfterTextField.show()
//
//                cell.gapBeforeTextField.stringValue = StringUtils.formatSecondsToHMS(gapB.duration)
//                cell.gapAfterTextField.stringValue = StringUtils.formatSecondsToHMS(gapA.duration)
//
//                cell.placeTextFieldBelowView(cell.gapBeforeTextField)
//
//            } else {
//
//                // Neither
//                cell.gapBeforeTextField.hide()
//                cell.gapAfterTextField.hide()
//
//                cell.placeTextFieldOnTop()
//            }
//
//            return cell
//        }
//
//        return nil
//    }
//
//    // MARK: Constraints for Index cells
//
//    // Creates a cell view containing the animation for the currently playing track
//    private func createPlayingTrackImageCell(_ tableView: NSTableView, _ id: String, _ text: String, _ gapBefore: PlaybackGap? = nil, _ gapAfter: PlaybackGap? = nil, _ row: Int) -> IndexCellView? {
//
//        return createIndexImageCell(tableView, id, text, gapBefore, gapAfter, row, Images.imgPlayingTrack)
//    }
//
//    // Creates a cell view containing the animation for the currently playing track
//    private func createTranscodingTrackImageCell(_ tableView: NSTableView, _ id: String, _ text: String, _ gapBefore: PlaybackGap? = nil, _ gapAfter: PlaybackGap? = nil, _ row: Int) -> IndexCellView? {
//
//        return createIndexImageCell(tableView, id, text, gapBefore, gapAfter, row, Images.imgTranscodingTrack)
//    }
//
//    // Creates a cell view containing the animation for the currently playing track
//    private func createWaitingImageCell(_ tableView: NSTableView, _ id: String, _ text: String, _ gapBefore: PlaybackGap? = nil, _ gapAfter: PlaybackGap? = nil, _ row: Int) -> IndexCellView? {
//
//        return createIndexImageCell(tableView, id, text, gapBefore, gapAfter, row, Images.imgWaitingTrack)
//    }
//
//    private func createIndexImageCell(_ tableView: NSTableView, _ id: String, _ text: String, _ gapBefore: PlaybackGap? = nil, _ gapAfter: PlaybackGap? = nil, _ row: Int, _ image: NSImage) -> IndexCellView? {
//
//        if let cell = tableView.makeView(withIdentifier: convertToNSUserInterfaceItemIdentifier(UIConstants.playlistIndexColumnID), owner: nil) as? IndexCellView {
//
//            // Configure and show the image view
//            let imgView = cell.imageView!
//
//            imgView.image = image
//            imgView.show()
//
//            // Hide the text view
//            cell.textField?.hide()
//
//            cell.textField?.stringValue = text
//            cell.row = row
//
//            let aOnly = gapAfter != nil && gapBefore == nil
//            let bOnly = gapBefore != nil && gapAfter == nil
//
//            if aOnly {
//
//                cell.adjustIndexConstraints_afterGapOnly()
//
//            } else if bOnly {
//
//                cell.adjustIndexConstraints_beforeGapOnly()
//
//            } else {
//
//                cell.adjustIndexConstraints_centered()
//            }
//
//            return cell
//        }
//
//        return nil
//    }
//
//    // -----------------------------------------------------------------------
//
//    private func createImageAndTextCell_gaps(_ outlineView: NSOutlineView, _ id: String, _ isGroup: Bool, _ text: String, _ image: NSImage?, _ isPlayingTrack: Bool = false, _ gapBefore: PlaybackGap? = nil, _ gapAfter: PlaybackGap? = nil) -> GroupedTrackNameCellView? {
//
//        if let cell = outlineView.makeView(withIdentifier: convertToNSUserInterfaceItemIdentifier(id), owner: nil) as? GroupedTrackNameCellView {
//
//            cell.textField?.stringValue = text
//            cell.imageView?.image = image
//            cell.isGroup = isGroup
//
//            let both = gapBefore != nil && gapAfter != nil
//            let aOnly = gapAfter != nil && gapBefore == nil
//            let bOnly = gapBefore != nil && gapAfter == nil
//
//            if aOnly {
//
//                cell.gapBeforeImg.hide()
//                cell.gapAfterImg.show()
//
//                adjustConstraints_mainFieldOnTop(cell)
//
//            } else if bOnly {
//
//                cell.gapBeforeImg.show()
//                cell.gapAfterImg.hide()
//
//                adjustConstraints_beforeGapFieldOnTop(cell, cell.gapBeforeImg)
//
//            } else if both {
//
//                cell.gapBeforeImg.show()
//                cell.gapAfterImg.show()
//
//                adjustConstraints_beforeGapFieldOnTop(cell, cell.gapBeforeImg)
//
//            } else {
//
//                // Neither
//                cell.gapBeforeImg.hide()
//                cell.gapAfterImg.hide()
//
//                adjustConstraints_mainFieldOnTop(cell)
//            }
//
//            return cell
//        }
//
//        return nil
//    }
//
//    private func adjustConstraints_mainFieldCentered(_ cell: NSTableCellView) {
//
//        let main = cell.textField!
//
//        for con in cell.constraints {
//
//            if con.firstItem === main && (con.firstAttribute == .top || con.firstAttribute == .centerY) {
//
//                con.isActive = false
//                cell.removeConstraint(con)
//            }
//
//            if con.secondItem === main && (con.secondAttribute == .top || con.secondAttribute == .centerY) {
//
//                con.isActive = false
//                cell.removeConstraint(con)
//            }
//        }
//
//        let mainFieldCentered = NSLayoutConstraint(item: main, attribute: .centerY, relatedBy: .equal, toItem: cell, attribute: .centerY, multiplier: 1.0, constant: 0)
//        mainFieldCentered.isActive = true
//        cell.addConstraint(mainFieldCentered)
//
//        if let imgView = cell.imageView {
//
//            let imgFieldCentered = NSLayoutConstraint(item: imgView, attribute: .centerY, relatedBy: .equal, toItem: main, attribute: .centerY, multiplier: 1.0, constant: 0)
//            imgFieldCentered.isActive = true
//            cell.addConstraint(imgFieldCentered)
//        }
//    }
//
//    private func adjustConstraints_mainFieldOnTop(_ cell: NSTableCellView) {
//
//        let main = cell.textField!
//
//        for con in cell.constraints {
//
//            if con.firstItem === main && (con.firstAttribute == .top || con.firstAttribute == .centerY) {
//
//                con.isActive = false
//                cell.removeConstraint(con)
//            }
//
//            if con.secondItem === main && (con.secondAttribute == .top || con.secondAttribute == .centerY) {
//
//                con.isActive = false
//                cell.removeConstraint(con)
//            }
//        }
//
//        let offset = cell.identifier!.rawValue == UIConstants.playlistDurationColumnID ? 2 : 0
//
//        let mainFieldOnTop = NSLayoutConstraint(item: main, attribute: .top, relatedBy: .equal, toItem: cell, attribute: .top, multiplier: 1.0, constant: CGFloat(offset))
//        mainFieldOnTop.isActive = true
//        cell.addConstraint(mainFieldOnTop)
//
//        if let imgView = cell.imageView {
//
//            let imgFieldCentered = NSLayoutConstraint(item: imgView, attribute: .centerY, relatedBy: .equal, toItem: main, attribute: .centerY, multiplier: 1.0, constant: 0)
//            imgFieldCentered.isActive = true
//            cell.addConstraint(imgFieldCentered)
//        }
//    }
//
//    private func adjustConstraints_beforeGapFieldOnTop(_ cell: NSTableCellView, _ gapView: NSView) {
//
//        let main = cell.textField!
//
//        for con in cell.constraints {
//
//            if con.firstItem === main && (con.firstAttribute == .top || con.firstAttribute == .centerY) {
//
//                con.isActive = false
//                cell.removeConstraint(con)
//            }
//
//            if con.secondItem === main && (con.secondAttribute == .top || con.secondAttribute == .centerY) {
//
//                con.isActive = false
//                cell.removeConstraint(con)
//            }
//        }
//
//        let offset = cell.identifier!.rawValue == UIConstants.playlistDurationColumnID ? 3 : 0
//
//        let befFieldOnTop = NSLayoutConstraint(item: main, attribute: .top, relatedBy: .equal, toItem: gapView, attribute: .bottom, multiplier: 1.0, constant: CGFloat(offset))
//        befFieldOnTop.isActive = true
//        cell.addConstraint(befFieldOnTop)
//
//        if let imgView = cell.imageView {
//
//            let imgFieldCentered = NSLayoutConstraint(item: imgView, attribute: .centerY, relatedBy: .equal, toItem: main, attribute: .centerY, multiplier: 1.0, constant: 0)
//            imgFieldCentered.isActive = true
//            cell.addConstraint(imgFieldCentered)
//        }
//    }
//
//    private func createDurationCell(_ outlineView: NSOutlineView, _ id: String, _ isGroup: Bool, _ text: String, _ gapBefore: PlaybackGap? = nil, _ gapAfter: PlaybackGap? = nil) -> GroupedTrackDurationCellView? {
//
//        if let cell = outlineView.makeView(withIdentifier: convertToNSUserInterfaceItemIdentifier(id), owner: nil) as? GroupedTrackDurationCellView {
//
//            cell.textField?.stringValue = text
//            cell.textField?.show()
//            cell.isGroup = isGroup
//
//            let both = gapBefore != nil && gapAfter != nil
//            let aOnly = gapAfter != nil && gapBefore == nil
//            let bOnly = gapBefore != nil && gapAfter == nil
//
//            if aOnly {
//
//                let gap = gapAfter!
//
//                cell.gapBeforeTextField.hide()
//                cell.gapAfterTextField.show()
//
//                cell.gapAfterTextField.stringValue = StringUtils.formatSecondsToHMS(gap.duration)
//
//                adjustConstraints_mainFieldOnTop(cell)
//
//            } else if bOnly {
//
//                let gap = gapBefore!
//
//                cell.gapBeforeTextField.show()
//                cell.gapAfterTextField.hide()
//
//                cell.gapBeforeTextField.stringValue = StringUtils.formatSecondsToHMS(gap.duration)
//
//                adjustConstraints_beforeGapFieldOnTop(cell, cell.gapBeforeTextField)
//
//            } else if both {
//
//                let gapA = gapAfter!
//                let gapB = gapBefore!
//
//                cell.gapBeforeTextField.show()
//                cell.gapAfterTextField.show()
//
//                cell.gapBeforeTextField.stringValue = StringUtils.formatSecondsToHMS(gapB.duration)
//                cell.gapAfterTextField.stringValue = StringUtils.formatSecondsToHMS(gapA.duration)
//
//                adjustConstraints_beforeGapFieldOnTop(cell, cell.gapBeforeTextField)
//
//            } else {
//
//                // Neither
//                cell.gapBeforeTextField.hide()
//                cell.gapAfterTextField.hide()
//
//                adjustConstraints_mainFieldOnTop(cell)
//            }
//
//
//            return cell
//        }
//
//        return nil
//    }
//
//    // Creates a cell view containing text and an image. If the row containing the cell represents the playing track, the image will be the playing track animation.
//    private func createImageAndTextCell(_ outlineView: NSOutlineView, _ id: String, _ isGroup: Bool, _ text: String, _ image: NSImage?, _ isPlayingTrack: Bool = false) -> GroupedTrackNameCellView? {
//
//        if let cell = outlineView.makeView(withIdentifier: convertToNSUserInterfaceItemIdentifier(id), owner: nil) as? GroupedTrackNameCellView {
//
//            cell.textField?.stringValue = text
//            cell.imageView?.image = image
//            cell.isGroup = isGroup
//
//            cell.gapAfterImg.hide()
//            cell.gapBeforeImg.hide()
//
//            adjustConstraints_mainFieldCentered(cell)
//
//            cell.textField!.setFrameOrigin(NSPoint.zero)
//
//            return cell
//        }
//
//        return nil
//    }
//
//    // Creates a cell view containing only text
//    private func createTextCell(_ outlineView: NSOutlineView, _ id: String, _ isGroup: Bool, _ text: String) -> GroupedTrackDurationCellView? {
//
//        if let cell = outlineView.makeView(withIdentifier: convertToNSUserInterfaceItemIdentifier(id), owner: nil) as? GroupedTrackDurationCellView {
//
//            cell.textField?.stringValue = text
//            cell.isGroup = isGroup
//
//            cell.gapAfterTextField.hide()
//            cell.gapBeforeTextField.hide()
//
//            return cell
//        }
//
//        return nil
//    }
}

// Utility class to hold an NSTableView instance for convenient access
class TableViewHolder {
    
    static var instance: NSOutlineView?
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSUserInterfaceItemIdentifier(_ input: NSUserInterfaceItemIdentifier) -> String {
	return input.rawValue
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToNSUserInterfaceItemIdentifier(_ input: String) -> NSUserInterfaceItemIdentifier {
	return NSUserInterfaceItemIdentifier(rawValue: input)
}
