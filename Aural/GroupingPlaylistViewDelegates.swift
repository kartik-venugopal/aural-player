import Cocoa

/*
    Delegate base class for the NSOutlineView instances that display the "Artists", "Albums", and "Genres" (hierarchical/grouping) playlist views.
 */
class GroupingPlaylistViewDelegate: NSObject, NSOutlineViewDelegate {
 
    @IBOutlet weak var playlistView: NSOutlineView!
    
    // Delegate that relays accessor operations to the playlist
    private let playlist: PlaylistAccessorDelegateProtocol = ObjectGraph.getPlaylistAccessorDelegate()
    
    // Used to determine the currently playing track
    private let playbackInfo: PlaybackInfoDelegateProtocol = ObjectGraph.getPlaybackInfoDelegate()
    
    // Indicates the type of groups displayed by this NSOutlineView (intended to be overridden by subclasses)
    fileprivate var playlistType: PlaylistType
    
    init(_ playlistType: PlaylistType) {
        self.playlistType = playlistType
    }
    
    override func awakeFromNib() {
        OutlineViewHolder.instances[self.playlistType] = playlistView
    }
    
    // Returns a view for a single row
    func outlineView(_ outlineView: NSOutlineView, rowViewForItem item: Any) -> NSTableRowView? {
        return GroupingPlaylistRowView()
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

            return 22

        } else {

            // Group
            return 26
        }
    }
    
    // Returns a view for a single column
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        
        switch convertFromNSUserInterfaceItemIdentifier(tableColumn!.identifier) {
            
        case UIConstants.playlistNameColumnID:
            
            // Name
            
            if let group = item as? Group {
                
                let cell = createImageAndTextCell(outlineView, convertFromNSUserInterfaceItemIdentifier(tableColumn!.identifier), true, String(format: "%@ (%d)", group.name, group.size()), Images.imgGroup)
                cell?.item = group
                cell?.playlistType = self.playlistType
                return cell
                
            } else {
                
                let track = item as! Track
                
                let gapA = playlist.getGapAfterTrack(track)
                let gapB = playlist.getGapBeforeTrack(track)
                
                let isPlayingTrack = track == playbackInfo.getPlayingTrack()?.track
                let isWaitingTrack = track == playbackInfo.getWaitingTrack()?.track
                let image = isPlayingTrack ? Images.imgPlayingTrack : (isWaitingTrack ? Images.imgWaitingTrack : track.displayInfo.art)
                
                let cell = createImageAndTextCell_gaps(outlineView, convertFromNSUserInterfaceItemIdentifier(tableColumn!.identifier), false, playlist.displayNameForTrack(playlistType, track), image, isPlayingTrack, gapB, gapA)
                
                cell?.item = track
                cell?.playlistType = self.playlistType
                return cell
            }
            
        case UIConstants.playlistDurationColumnID:
            
            // Duration
            
            if let group = item as? Group {
                
                let cell = createTextCell(outlineView, UIConstants.playlistDurationColumnID, true, StringUtils.formatSecondsToHMS(group.duration))
                cell?.item = group
                cell?.playlistType = self.playlistType
                return cell
                
            } else {
                
                let track = item as! Track
                
                let gapA = playlist.getGapAfterTrack(track)
                let gapB = playlist.getGapBeforeTrack(track)
                
                let cell = createDurationCell(outlineView, UIConstants.playlistDurationColumnID, false, StringUtils.formatSecondsToHMS(track.duration), gapB, gapA)
                cell?.item = track
                cell?.playlistType = self.playlistType
                return cell
            }
            
        default: return nil
            
        }
    }
    
    private func createImageAndTextCell_gaps(_ outlineView: NSOutlineView, _ id: String, _ isGroup: Bool, _ text: String, _ image: NSImage?, _ isPlayingTrack: Bool = false, _ gapBefore: PlaybackGap? = nil, _ gapAfter: PlaybackGap? = nil) -> GroupedTrackNameCellView? {
        
        if let cell = outlineView.makeView(withIdentifier: convertToNSUserInterfaceItemIdentifier(id), owner: nil) as? GroupedTrackNameCellView {
            
            cell.textField?.stringValue = text
            cell.imageView?.image = image
            cell.isGroup = isGroup
            
            let both = gapBefore != nil && gapAfter != nil
            let aOnly = gapAfter != nil && gapBefore == nil
            let bOnly = gapBefore != nil && gapAfter == nil
            
            if aOnly {
                
                cell.gapBeforeImg.isHidden = true
                cell.gapAfterImg.isHidden = false
                
                adjustConstraints_mainFieldOnTop(cell)
                
            } else if bOnly {
                
                cell.gapBeforeImg.isHidden = false
                cell.gapAfterImg.isHidden = true
                
                adjustConstraints_beforeGapFieldOnTop(cell, cell.gapBeforeImg)
                
            } else if both {
                
                cell.gapBeforeImg.isHidden = false
                cell.gapAfterImg.isHidden = false
                
                adjustConstraints_beforeGapFieldOnTop(cell, cell.gapBeforeImg)
                
            } else {
                
                // Neither
                cell.gapBeforeImg.isHidden = true
                cell.gapAfterImg.isHidden = true
                
                adjustConstraints_mainFieldOnTop(cell)
            }
            
            return cell
        }
        
        return nil
    }
    
    private func adjustConstraints_mainFieldCentered(_ cell: NSTableCellView) {
        
        let main = cell.textField!
        
        for con in cell.constraints {
            
            if con.firstItem === main && (con.firstAttribute == .top || con.firstAttribute == .centerY) {
                
                con.isActive = false
                cell.removeConstraint(con)
            }
            
            if con.secondItem === main && (con.secondAttribute == .top || con.secondAttribute == .centerY) {
                
                con.isActive = false
                cell.removeConstraint(con)
            }
        }
        
        let mainFieldOnTop = NSLayoutConstraint(item: main, attribute: .centerY, relatedBy: .equal, toItem: cell, attribute: .centerY, multiplier: 1.0, constant: 0)
        mainFieldOnTop.isActive = true
        cell.addConstraint(mainFieldOnTop)
        
        if let imgView = cell.imageView {
        
            let imgFieldCentered = NSLayoutConstraint(item: imgView, attribute: .centerY, relatedBy: .equal, toItem: main, attribute: .centerY, multiplier: 1.0, constant: 0)
            imgFieldCentered.isActive = true
            cell.addConstraint(imgFieldCentered)
        }
    }
    
    private func adjustConstraints_mainFieldOnTop(_ cell: NSTableCellView) {
        
        let main = cell.textField!
        
        for con in cell.constraints {
            
            if con.firstItem === main && (con.firstAttribute == .top || con.firstAttribute == .centerY) {
                
                con.isActive = false
                cell.removeConstraint(con)
            }
            
            if con.secondItem === main && (con.secondAttribute == .top || con.secondAttribute == .centerY) {
                
                con.isActive = false
                cell.removeConstraint(con)
            }
        }
        
        let mainFieldOnTop = NSLayoutConstraint(item: main, attribute: .top, relatedBy: .equal, toItem: cell, attribute: .top, multiplier: 1.0, constant: 0)
        mainFieldOnTop.isActive = true
        cell.addConstraint(mainFieldOnTop)
        
        if let imgView = cell.imageView {
            
            let imgFieldCentered = NSLayoutConstraint(item: imgView, attribute: .centerY, relatedBy: .equal, toItem: main, attribute: .centerY, multiplier: 1.0, constant: 0)
            imgFieldCentered.isActive = true
            cell.addConstraint(imgFieldCentered)
        }
    }
    
    private func adjustConstraints_beforeGapFieldOnTop(_ cell: NSTableCellView, _ gapView: NSView) {
        
        let main = cell.textField!
        
        for con in cell.constraints {
            
            if con.firstItem === main && (con.firstAttribute == .top || con.firstAttribute == .centerY) {
                
                con.isActive = false
                cell.removeConstraint(con)
            }
            
            if con.secondItem === main && (con.secondAttribute == .top || con.secondAttribute == .centerY) {
                
                con.isActive = false
                cell.removeConstraint(con)
            }
        }
        
        let befFieldOnTop = NSLayoutConstraint(item: main, attribute: .top, relatedBy: .equal, toItem: gapView, attribute: .bottom, multiplier: 1.0, constant: 0)
        befFieldOnTop.isActive = true
        cell.addConstraint(befFieldOnTop)
        
        if let imgView = cell.imageView {
            
            let imgFieldCentered = NSLayoutConstraint(item: imgView, attribute: .centerY, relatedBy: .equal, toItem: main, attribute: .centerY, multiplier: 1.0, constant: 0)
            imgFieldCentered.isActive = true
            cell.addConstraint(imgFieldCentered)
        }
    }
    
    private func createDurationCell(_ outlineView: NSOutlineView, _ id: String, _ isGroup: Bool, _ text: String, _ gapBefore: PlaybackGap? = nil, _ gapAfter: PlaybackGap? = nil) -> GroupedTrackDurationCellView? {
        
        if let cell = outlineView.makeView(withIdentifier: convertToNSUserInterfaceItemIdentifier(id), owner: nil) as? GroupedTrackDurationCellView {
            
            cell.textField?.stringValue = text
            cell.textField?.isHidden = false
            
            if cell.gapAfterTextField == nil {
                return cell
            }
            
            let both = gapBefore != nil && gapAfter != nil
            let aOnly = gapAfter != nil && gapBefore == nil
            let bOnly = gapBefore != nil && gapAfter == nil
            
            if aOnly {
                
                let gap = gapAfter!
                
                cell.gapBeforeTextField.isHidden = true
                cell.gapAfterTextField.isHidden = false
                
                cell.gapAfterTextField.stringValue = StringUtils.formatSecondsToHMS(gap.duration)
                
                adjustConstraints_mainFieldOnTop(cell)
                
                cell.gapAfterTextField.setFrameOrigin(NSPoint.zero)
                
            } else if bOnly {
                
                let gap = gapBefore!
                
                cell.gapBeforeTextField.isHidden = false
                cell.gapAfterTextField.isHidden = true
                
                cell.gapBeforeTextField.stringValue = StringUtils.formatSecondsToHMS(gap.duration)
                
                adjustConstraints_beforeGapFieldOnTop(cell, cell.gapBeforeTextField)
                
                cell.textField!.setFrameOrigin(NSPoint.zero)
                
            } else if both {
                
                let gapA = gapAfter!
                let gapB = gapBefore!
                
                cell.gapBeforeTextField.isHidden = false
                cell.gapAfterTextField.isHidden = false
                
                cell.gapBeforeTextField.stringValue = StringUtils.formatSecondsToHMS(gapB.duration)
                cell.gapAfterTextField.stringValue = StringUtils.formatSecondsToHMS(gapA.duration)
                
                adjustConstraints_beforeGapFieldOnTop(cell, cell.gapBeforeTextField)
                
                cell.gapAfterTextField.setFrameOrigin(NSPoint.zero)
                
            } else {
                
                // Neither
                cell.gapBeforeTextField.isHidden = true
                cell.gapAfterTextField.isHidden = true
                
                adjustConstraints_mainFieldOnTop(cell)
                
                cell.textField!.setFrameOrigin(NSPoint.zero)
            }
            
            
            return cell
        }
        
        return nil
    }
    
    // Creates a cell view containing text and an image. If the row containing the cell represents the playing track, the image will be the playing track animation.
    private func createImageAndTextCell(_ outlineView: NSOutlineView, _ id: String, _ isGroup: Bool, _ text: String, _ image: NSImage?, _ isPlayingTrack: Bool = false) -> GroupedTrackNameCellView? {
        
        if let cell = outlineView.makeView(withIdentifier: convertToNSUserInterfaceItemIdentifier(id), owner: nil) as? GroupedTrackNameCellView {
            
            cell.textField?.stringValue = text
            cell.imageView?.image = image
            cell.isGroup = isGroup
            
            cell.gapAfterImg.isHidden = true
            cell.gapBeforeImg.isHidden = true
            
            adjustConstraints_mainFieldCentered(cell)
            
            cell.textField!.setFrameOrigin(NSPoint.zero)
            
            return cell
        }
        
        return nil
    }
    
    // Creates a cell view containing only text
    private func createTextCell(_ outlineView: NSOutlineView, _ id: String, _ isGroup: Bool, _ text: String) -> GroupedTrackDurationCellView? {
        
        if let cell = outlineView.makeView(withIdentifier: convertToNSUserInterfaceItemIdentifier(id), owner: nil) as? GroupedTrackDurationCellView {
            
            cell.textField?.stringValue = text
            cell.isGroup = isGroup
            
            cell.gapAfterTextField.isHidden = true
            cell.gapBeforeTextField.isHidden = true
            
            return cell
        }
        
        return nil
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

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSUserInterfaceItemIdentifier(_ input: NSUserInterfaceItemIdentifier) -> String {
	return input.rawValue
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToNSUserInterfaceItemIdentifier(_ input: String) -> NSUserInterfaceItemIdentifier {
	return NSUserInterfaceItemIdentifier(rawValue: input)
}
