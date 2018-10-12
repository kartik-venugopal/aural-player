import Cocoa

/*
    Delegate base class for the NSOutlineView instances that display the "Artists", "Albums", and "Genres" (hierarchical/grouping) playlist views.
 */
class GroupingPlaylistViewDelegate: NSObject, NSOutlineViewDelegate, MessageSubscriber {
 
    @IBOutlet weak var playlistView: NSOutlineView!
    
    // Delegate that relays accessor operations to the playlist
    private let playlist: PlaylistAccessorDelegateProtocol = ObjectGraph.getPlaylistAccessorDelegate()
    
    // Used to determine the currently playing track
    private let playbackInfo: PlaybackInfoDelegateProtocol = ObjectGraph.getPlaybackInfoDelegate()
    
    // Indicates the type of groups displayed by this NSOutlineView (intended to be overridden by subclasses)
    fileprivate var playlistType: PlaylistType
    
    // Stores the cell containing the playing track animation, for convenient access when pausing/resuming the animation
    private var animationCell: GroupedTrackCellView?
    
    init(_ playlistType: PlaylistType) {
        self.playlistType = playlistType
    }
    
    override func awakeFromNib() {
        
        // Subscribe to message notifications
        SyncMessenger.subscribe(messageTypes: [.playbackStateChangedNotification], subscriber: self)
        
        OutlineViewHolder.instances[self.playlistType] = playlistView
    }
    
    // Returns a view for a single row
    func outlineView(_ outlineView: NSOutlineView, rowViewForItem item: Any) -> NSTableRowView? {
        return GroupingPlaylistRowView()
    }
    
    // Determines the height of a single row
    func outlineView(_ outlineView: NSOutlineView, heightOfRowByItem item: Any) -> CGFloat {
        
        // Group rows are taller than track rows
        return item is Group ? 26 : 22
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
                
                let isPlayingTrack = track == playbackInfo.getPlayingTrack()?.track
                let image = isPlayingTrack ? Images.imgPlayingTrack : track.displayInfo.art
                
                let cell = createImageAndTextCell(outlineView, convertFromNSUserInterfaceItemIdentifier(tableColumn!.identifier), false, playlist.displayNameForTrack(playlistType, track), image, isPlayingTrack)
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
                
                let cell = createTextCell(outlineView, UIConstants.playlistDurationColumnID, false, StringUtils.formatSecondsToHMS(track.duration))
                cell?.item = track
                cell?.playlistType = self.playlistType
                return cell
            }
            
        default: return nil
            
        }
    }
    
    // Creates a cell view containing text and an image. If the row containing the cell represents the playing track, the image will be the playing track animation.
    private func createImageAndTextCell(_ outlineView: NSOutlineView, _ id: String, _ isGroup: Bool, _ text: String, _ image: NSImage?, _ isPlayingTrack: Bool = false) -> GroupedTrackCellView? {
        
        if let cell = outlineView.makeView(withIdentifier: convertToNSUserInterfaceItemIdentifier(id), owner: nil) as? GroupedTrackCellView {
            
            cell.textField?.stringValue = text
            cell.imageView?.image = image
            cell.isGroup = isGroup
            
            if (isPlayingTrack) {
                
                // Mark this cell for later
                animationCell = cell
            }
            
            return cell
        }
        
        return nil
    }
    
    // Creates a cell view containing only text
    private func createTextCell(_ outlineView: NSOutlineView, _ id: String, _ isGroup: Bool, _ text: String) -> GroupedTrackCellView? {
        
        if let cell = outlineView.makeView(withIdentifier: convertToNSUserInterfaceItemIdentifier(id), owner: nil) as? GroupedTrackCellView {
            
            cell.textField?.stringValue = text
            cell.isGroup = isGroup
            return cell
        }
        
        return nil
    }
    
    // Whenever the playing track is paused/resumed, the animation needs to be paused/resumed.
    private func playbackStateChanged(_ message: PlaybackStateChangedNotification) {
        
        switch (message.newPlaybackState) {
            
        case .noTrack:
            
            // The track is no longer playing
            animationCell = nil
            
        case .playing, .paused, .waiting:
            
            animationCell?.imageView?.image = Images.imgPlayingTrack
            
        }
    }
    
    func getID() -> String {
        return String(format: "%@-%@", self.className, String(describing: self.playlistType))
    }
    
    // MARK: Message handling
    
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
