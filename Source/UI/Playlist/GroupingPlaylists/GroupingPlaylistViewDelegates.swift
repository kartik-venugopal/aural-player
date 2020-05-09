import Cocoa

/*
    Delegate base class for the NSOutlineView instances that display the "Artists", "Albums", and "Genres" (hierarchical/grouping) playlist views.
 */
class GroupingPlaylistViewDelegate: NSObject, NSOutlineViewDelegate {
 
    @IBOutlet weak var playlistView: NSOutlineView!
    
    // Delegate that relays accessor operations to the playlist
    private let playlist: PlaylistAccessorDelegateProtocol = ObjectGraph.playlistAccessorDelegate
    
    // Used to determine the currently playing track
    private let playbackInfo: PlaybackInfoDelegateProtocol = ObjectGraph.playbackInfoDelegate
    
    // Indicates the type of groups displayed by this NSOutlineView (intended to be overridden by subclasses)
    fileprivate var playlistType: PlaylistType
    
    private var cachedGroupIcon: NSImage!
    private var cachedGapImage: NSImage!
    
    init(_ playlistType: PlaylistType) {
        self.playlistType = playlistType
    }
    
    override func awakeFromNib() {
        OutlineViewHolder.instances[self.playlistType] = playlistView
        
        cachedGroupIcon = Images.imgGroup.applyingTint(Colors.Playlist.groupIconColor)
        cachedGapImage = Images.imgGap.applyingTint(Colors.Playlist.trackNameTextColor)
    }

    func changeGroupIconColor(_ color: NSColor) {
        cachedGroupIcon = Images.imgGroup.applyingTint(color)
    }
    
    func changeGapIndicatorColor(_ color: NSColor) {
        cachedGapImage = Images.imgGap.applyingTint(Colors.Playlist.trackNameTextColor)
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
                return 61
                
            } else if ga != nil || gb != nil {
                return 43
            }

            return 25

        } else {

            // Group
            return 28
        }
    }
    
    // Returns a view for a single column
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        
        switch tableColumn!.identifier.rawValue {
            
        case UIConstants.playlistNameColumnID:
            
            // Name
            
            if let group = item as? Group {
                
                let cell = createImageAndTextCell(outlineView, tableColumn!.identifier.rawValue, String(format: "%@ (%d)", group.name, group.size), cachedGroupIcon)
                
                cell?.item = group
                cell?.playlistType = self.playlistType
                
                return cell
                
            } else {
                
                let track = item as! Track
                
                let gapA = playlist.getGapAfterTrack(track)
                let gapB = playlist.getGapBeforeTrack(track)
                
                var image: NSImage?
                
                let isPlayingTrack: Bool = track == playbackInfo.playingTrack?.track
                
                switch playbackInfo.state {
                    
                case .playing, .paused:
                    
                    image = isPlayingTrack ? Images.imgPlayingTrack.applyingTint(Colors.Playlist.playingTrackIconColor) : nil
                    
                case .transcoding:
                    
                    image = isPlayingTrack ? Images.imgTranscodingTrack.applyingTint(Colors.Playlist.playingTrackIconColor) : nil
                    
                case .waiting:
                    
                    image = track == playbackInfo.waitingTrack?.track ? Images.imgWaitingTrack.applyingTint(Colors.Playlist.playingTrackIconColor) : nil
                    
                case .noTrack:
                    
                    image = nil
                }
                
                let cell = createImageAndTextCell_gaps(outlineView, tableColumn!.identifier.rawValue, playlist.displayNameForTrack(playlistType, track), image, isPlayingTrack, gapB, gapA)
                
                cell?.item = track
                cell?.playlistType = self.playlistType
                
                return cell
            }
            
        case UIConstants.playlistDurationColumnID:
            
            // Duration
            
            if let group = item as? Group {
                
                let cell = createDurationCell(outlineView, UIConstants.playlistDurationColumnID, true, ValueFormatter.formatSecondsToHMS(group.duration), nil, nil)
                cell?.item = group
                cell?.playlistType = self.playlistType
                return cell
                
            } else {
                
                let track = item as! Track
                
                let gapA = playlist.getGapAfterTrack(track)
                let gapB = playlist.getGapBeforeTrack(track)
                
                let cell = createDurationCell(outlineView, UIConstants.playlistDurationColumnID, false, ValueFormatter.formatSecondsToHMS(track.duration), gapB, gapA)
                cell?.item = track
                cell?.playlistType = self.playlistType
                return cell
            }
            
        default: return nil
            
        }
    }
    
    private func createImageAndTextCell_gaps(_ outlineView: NSOutlineView, _ id: String, _ text: String, _ image: NSImage?, _ isPlayingTrack: Bool = false, _ gapBefore: PlaybackGap? = nil, _ gapAfter: PlaybackGap? = nil) -> GroupedTrackNameCellView? {
        
        if let cell = outlineView.makeView(withIdentifier: convertToNSUserInterfaceItemIdentifier(id), owner: nil) as? GroupedTrackNameCellView {
            
            cell.textField?.font = Fonts.Playlist.trackNameFont
            cell.textField?.stringValue = text
            cell.textField?.setNeedsDisplay()
            
            cell.imageView?.image = image
            cell.isGroup = false
            
            let both = gapBefore != nil && gapAfter != nil
            let aOnly = gapAfter != nil && gapBefore == nil
            let bOnly = gapBefore != nil && gapAfter == nil
            
            if aOnly {
                
                cell.gapBeforeImg.hide()
                
                cell.gapAfterImg.image = cachedGapImage
                cell.gapAfterImg.show()
                
                adjustConstraints_mainFieldOnTop(cell)
                
            } else if bOnly {
                
                cell.gapBeforeImg.image = cachedGapImage
                cell.gapBeforeImg.show()
                
                cell.gapAfterImg.hide()
                
                adjustConstraints_beforeGapFieldOnTop(cell, cell.gapBeforeImg)
                
            } else if both {
                
                cell.gapBeforeImg.image = cachedGapImage
                cell.gapBeforeImg.show()
                
                cell.gapAfterImg.image = cachedGapImage
                cell.gapAfterImg.show()
                
                adjustConstraints_beforeGapFieldOnTop(cell, cell.gapBeforeImg)
                
            } else {
                
                // Neither
                cell.gapBeforeImg.hide()
                cell.gapAfterImg.hide()
                
                adjustConstraints_mainFieldOnTop(cell, -2)
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
        
        let mainFieldCentered = NSLayoutConstraint(item: main, attribute: .centerY, relatedBy: .equal, toItem: cell, attribute: .centerY, multiplier: 1.0, constant: 0)
        mainFieldCentered.isActive = true
        cell.addConstraint(mainFieldCentered)
        
        if let imgView = cell.imageView {
        
            let imgFieldCentered = NSLayoutConstraint(item: imgView, attribute: .centerY, relatedBy: .equal, toItem: main, attribute: .centerY, multiplier: 1.0, constant: 1)
            imgFieldCentered.isActive = true
            cell.addConstraint(imgFieldCentered)
        }
    }
    
    private func adjustConstraints_mainFieldOnTop(_ cell: NSTableCellView, _ topOffset: CGFloat = 0) {
        
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
        
        let mainFieldOnTop = NSLayoutConstraint(item: main, attribute: .top, relatedBy: .equal, toItem: cell, attribute: .top, multiplier: 1.0, constant: topOffset)
        mainFieldOnTop.isActive = true
        cell.addConstraint(mainFieldOnTop)
        
        if let imgView = cell.imageView {
            
            let imgFieldCentered = NSLayoutConstraint(item: imgView, attribute: .centerY, relatedBy: .equal, toItem: main, attribute: .centerY, multiplier: 1.0, constant: 3)
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
        
        let befFieldOnTop = NSLayoutConstraint(item: main, attribute: .top, relatedBy: .equal, toItem: gapView, attribute: .bottom, multiplier: 1.0, constant: -2)
        befFieldOnTop.isActive = true
        cell.addConstraint(befFieldOnTop)
        
        if let imgView = cell.imageView {
            
            let imgFieldCentered = NSLayoutConstraint(item: imgView, attribute: .centerY, relatedBy: .equal, toItem: main, attribute: .centerY, multiplier: 1.0, constant: 2)
            imgFieldCentered.isActive = true
            cell.addConstraint(imgFieldCentered)
        }
    }
    
    private func createDurationCell(_ outlineView: NSOutlineView, _ id: String, _ isGroup: Bool, _ text: String, _ gapBefore: PlaybackGap? = nil, _ gapAfter: PlaybackGap? = nil) -> GroupedTrackDurationCellView? {
        
        if let cell = outlineView.makeView(withIdentifier: convertToNSUserInterfaceItemIdentifier(id), owner: nil) as? GroupedTrackDurationCellView {
            
            cell.textField?.font = isGroup ? Fonts.Playlist.groupDurationFont : Fonts.Playlist.indexFont
            cell.textField?.stringValue = text
            cell.textField?.show()
            cell.isGroup = isGroup
            
            let both = gapBefore != nil && gapAfter != nil
            let aOnly = gapAfter != nil && gapBefore == nil
            let bOnly = gapBefore != nil && gapAfter == nil
            
            if aOnly {
                
                let gap = gapAfter!
                
                cell.gapBeforeTextField.hide()
                cell.gapAfterTextField.show()
                
                cell.gapAfterTextField.stringValue = ValueFormatter.formatSecondsToHMS(gap.duration)
                
                adjustConstraints_mainFieldOnTop(cell)
                
            } else if bOnly {
                
                let gap = gapBefore!
                
                cell.gapBeforeTextField.show()
                cell.gapAfterTextField.hide()
                
                cell.gapBeforeTextField.stringValue = ValueFormatter.formatSecondsToHMS(gap.duration)
                
                adjustConstraints_beforeGapFieldOnTop(cell, cell.gapBeforeTextField)
                
            } else if both {
                
                let gapA = gapAfter!
                let gapB = gapBefore!
                
                cell.gapBeforeTextField.show()
                cell.gapAfterTextField.show()
                
                cell.gapBeforeTextField.stringValue = ValueFormatter.formatSecondsToHMS(gapB.duration)
                cell.gapAfterTextField.stringValue = ValueFormatter.formatSecondsToHMS(gapA.duration)
                
                adjustConstraints_beforeGapFieldOnTop(cell, cell.gapBeforeTextField)
                
            } else {
                
                // Neither
                cell.gapBeforeTextField.hide()
                cell.gapAfterTextField.hide()
                
                adjustConstraints_mainFieldOnTop(cell, isGroup ? 1.5 : -2)
            }
            
            
            return cell
        }
        
        return nil
    }
    
    // Creates a cell view containing text and an image. If the row containing the cell represents the playing track, the image will be the playing track animation.
    private func createImageAndTextCell(_ outlineView: NSOutlineView, _ id: String, _ text: String, _ image: NSImage?, _ isPlayingTrack: Bool = false) -> GroupedTrackNameCellView? {
        
        if let cell = outlineView.makeView(withIdentifier: convertToNSUserInterfaceItemIdentifier(id), owner: nil) as? GroupedTrackNameCellView {
            
            cell.textField?.font = Fonts.Playlist.groupNameFont
            cell.textField?.stringValue = text
            cell.imageView?.image = image
            cell.isGroup = true
            
            cell.gapAfterImg.hide()
            cell.gapBeforeImg.hide()
            
            adjustConstraints_mainFieldCentered(cell)
            
            cell.textField!.setFrameOrigin(NSPoint.zero)
            
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
fileprivate func convertToNSUserInterfaceItemIdentifier(_ input: String) -> NSUserInterfaceItemIdentifier {
	return NSUserInterfaceItemIdentifier(rawValue: input)
}
