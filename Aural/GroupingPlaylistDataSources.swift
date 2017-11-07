import Cocoa

class GroupingPlaylistDataSource: NSViewController, NSOutlineViewDataSource, NSOutlineViewDelegate, MessageSubscriber {
    
    private let playlist: PlaylistAccessorDelegateProtocol = ObjectGraph.getPlaylistAccessorDelegate()
    
    // Used to determine the currently playing track
    private let playbackInfo: PlaybackInfoDelegateProtocol = ObjectGraph.getPlaybackInfoDelegate()
    
    internal var grouping: GroupType {return .artist}

    // Used to pause/resume the playing track animation
    private var animationCell: GroupedTrackCellView?
    
    // Handles all drag/drop operations
    private var dragDropDelegate: GroupingPlaylistDragDropDelegate = GroupingPlaylistDragDropDelegate()
    
    override func viewDidLoad() {
        
        dragDropDelegate.setGrouping(self.grouping)
        
        // Subscribe to playbackStateChangedNotifications so that the playing track animation can be paused/resumed, in response to the playing track being paused/resumed
        SyncMessenger.subscribe(messageTypes: [.playbackStateChangedNotification], subscriber: self)
    }
    
    func outlineView(_ outlineView: NSOutlineView, rowViewForItem item: Any) -> NSTableRowView? {
        return GroupingPlaylistRowView()
    }
    
    func outlineView(_ outlineView: NSOutlineView, heightOfRowByItem item: Any) -> CGFloat {
        return item is Group ? 26 : 22
    }
    
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        
        if (item == nil) {
            return playlist.numberOfGroups(grouping)
        } else if let group = item as? Group {
            return group.size()
        }
        
        // Tracks don't have children
        return 0
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        
        if (item == nil) {
            return playlist.groupAtIndex(grouping, index)
        } else if let group = item as? Group {
            return group.trackAtIndex(index)
        }
        
        return "Muthusami"
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        return item is Group
    }
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        
        if (tableColumn?.identifier == "cv_groupName") {
            
            if let group = item as? Group {
                
                let view: GroupedTrackCellView? = outlineView.make(withIdentifier: (tableColumn?.identifier)!, owner: self) as? GroupedTrackCellView
                
                view!.textField?.stringValue = String(format: "%@ (%d)", group.name, group.size())
                view!.isGroup = true
                view!.imageView?.image = UIConstants.imgGroup
                
                return view
                
            } else if let track = item as? Track {
                
                let view: GroupedTrackCellView? = outlineView.make(withIdentifier: (tableColumn?.identifier)!, owner: self) as? GroupedTrackCellView
                
                view!.textField?.stringValue = playlist.displayNameForTrack(grouping, track)
                view!.isGroup = false
                
                let playingTrack = playbackInfo.getPlayingTrack()?.track
                
                // If this row contains the playing track, display an animation, instead of the track index
                if (track == playingTrack) {
                    
                    let playbackState = playbackInfo.getPlaybackState()
                    view!.imageView?.image = UIConstants.imgPlayingTrack
                    
                    // Configure and show the image view
                    let imgView = view!.imageView!
                    
                    imgView.canDrawSubviewsIntoLayer = true
                    imgView.imageScaling = .scaleProportionallyDown
                    imgView.animates = (playbackState == .playing)
                    
                    animationCell = view
                    
                } else {
                    view!.imageView?.image = track.displayInfo.art
                }
                
                return view
            }
            
        } else if (tableColumn?.identifier == "cv_duration") {
            
            let view: GroupedTrackCellView? = outlineView.make(withIdentifier: (tableColumn?.identifier)!, owner: self) as? GroupedTrackCellView
            
            if let group = item as? Group {
                
                view!.textField?.stringValue = StringUtils.formatSecondsToHMS(group.duration)
                view?.isGroup = true
                view!.textField?.setFrameOrigin(NSPoint(x: 0, y: -12))
                
            } else if let track = item as? Track {
                
                view!.textField?.stringValue = StringUtils.formatSecondsToHMS(track.duration)
                view?.isGroup = false
            }
            
            return view
        }
        
        return nil
    }
    
    // Creates a cell view containing text
    private func createCell(_ outlineView: NSOutlineView, _ id: String, _ text: String, _ image: NSImage, isPlayingTrack: Bool = false, animate: Bool = false) -> GroupedTrackCellView? {
        
        if let cell = outlineView.make(withIdentifier: id, owner: nil) as? GroupedTrackCellView {
            
            cell.textField?.stringValue = text
            cell.imageView?.image = image
            
            if (isPlayingTrack) {
                
                // Configure and show the image view
                let imgView = cell.imageView!
                
                imgView.canDrawSubviewsIntoLayer = true
                imgView.imageScaling = .scaleProportionallyDown
                imgView.animates = animate
            }
            
            return cell
        }
        
        return nil
    }
    
    // Creates a cell view containing the animation for the currently playing track
    private func createPlayingTrackAnimationCell(_ tableView: NSTableView, _ animate: Bool) -> GroupedTrackCellView? {
        
        if let cell = tableView.make(withIdentifier: "cv_groupName", owner: nil) as? GroupedTrackCellView {
            
            // Configure and show the image view
            let imgView = cell.imageView!
            
            imgView.canDrawSubviewsIntoLayer = true
            imgView.imageScaling = .scaleProportionallyDown
            imgView.animates = animate
            imgView.image = UIConstants.imgPlayingTrack
            
            return cell
        }
        
        return nil
    }
    
    func outlineView(_ outlineView: NSOutlineView, writeItems items: [Any], to pasteboard: NSPasteboard) -> Bool {
        return dragDropDelegate.outlineView(outlineView, writeItems: items, to: pasteboard)
    }
    
    func outlineView(_ outlineView: NSOutlineView, validateDrop info: NSDraggingInfo, proposedItem item: Any?, proposedChildIndex index: Int) -> NSDragOperation {
        return dragDropDelegate.outlineView(outlineView, validateDrop: info, proposedItem: item, proposedChildIndex: index)
    }
    
    func outlineView(_ outlineView: NSOutlineView, acceptDrop info: NSDraggingInfo, item: Any?, childIndex index: Int) -> Bool {
        
        return dragDropDelegate.outlineView(outlineView, acceptDrop: info, item: item, childIndex: index)
    }
    
    // Whenever the playing track is paused/resumed, the animation needs to be paused/resumed.
    private func playbackStateChanged(_ state: PlaybackState) {
        
        switch (state) {
            
        case .playing:
            
            animationCell?.imageView?.animates = true
            
        case .paused:
            
            animationCell?.imageView?.animates = false
            
        default:
            
            // Release the animation cell because the track is no longer playing
            animationCell?.imageView?.animates = false
            animationCell = nil
        }
    }
    
    func consumeNotification(_ notification: NotificationMessage) {
        
        if (notification is PlaybackStateChangedNotification) {
            
            let msg = notification as! PlaybackStateChangedNotification
            playbackStateChanged(msg.newPlaybackState)
            return
        }
    }
    
    func processRequest(_ request: RequestMessage) -> ResponseMessage {
        return EmptyResponse.instance
    }
}

/*
    Custom view for a single NSTableView cell. Customizes the look and feel of cells (in selected rows) - font and text color.
 */
class GroupedTrackCellView: NSTableCellView {
    var isGroup: Bool = false
}

class GroupingPlaylistRowView: NSTableRowView {
    
    // Draws a fancy rounded rectangle around the selected track in the playlist view
    override func drawSelection(in dirtyRect: NSRect) {
        
        if self.selectionHighlightStyle != NSTableViewSelectionHighlightStyle.none {
            
            let selectionRect = self.bounds.insetBy(dx: 1, dy: 0)
            
            let selectionPath = NSBezierPath.init(roundedRect: selectionRect, xRadius: 2, yRadius: 2)
            Colors.playlistSelectionBoxColor.setFill()
            selectionPath.fill()
        }
    }
    
    override func drawBackground(in dirtyRect: NSRect) {
        
        UIConstants.groupingPlaylistViewColumnIndexes.forEach({
            
            let cell = self.view(atColumn: $0) as! GroupedTrackCellView
            
            cell.textField?.textColor = isSelected ? (cell.isGroup ? Colors.playlistGroupNameSelectedTextColor : Colors.playlistGroupItemSelectedTextColor) : (cell.isGroup ? Colors.playlistGroupNameTextColor : Colors.playlistGroupItemTextColor)
            
            cell.textField?.font = isSelected ? (cell.isGroup ? UIConstants.playlistGroupNameSelectedTextFont : UIConstants.playlistGroupItemSelectedTextFont) : (cell.isGroup ? UIConstants.playlistGroupNameTextFont : UIConstants.playlistGroupItemTextFont)
        })
        
        super.drawBackground(in: dirtyRect)
    }
}

class ArtistsPlaylistDataSource: GroupingPlaylistDataSource {
    
    override var grouping: GroupType {return .artist}
}

class AlbumsPlaylistDataSource: GroupingPlaylistDataSource {
    
    override var grouping: GroupType {return .album}
}

class GenresPlaylistDataSource: GroupingPlaylistDataSource {
    
    override var grouping: GroupType {return .genre}
}
