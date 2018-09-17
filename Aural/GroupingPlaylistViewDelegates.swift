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
        SyncMessenger.subscribe(messageTypes: [.playbackStateChangedNotification, .playlistTypeChangedNotification, .appInForegroundNotification, .appInBackgroundNotification], subscriber: self)
        
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
        
        switch tableColumn!.identifier {
            
        case UIConstants.playlistNameColumnID:
            
            // Name
            
            if let group = item as? Group {
                
                let cell = createImageAndTextCell(outlineView, tableColumn!.identifier, true, String(format: "%@ (%d)", group.name, group.size()), Images.imgGroup)
                cell?.item = group
                cell?.playlistType = self.playlistType
                return cell
                
            } else {
                
                let track = item as! Track
                
                let isPlayingTrack = track == playbackInfo.getPlayingTrack()?.track
                let image = isPlayingTrack ? Images.imgPlayingTrack : track.displayInfo.art
                
                let cell = createImageAndTextCell(outlineView, tableColumn!.identifier, false, playlist.displayNameForTrack(playlistType, track), image, isPlayingTrack)
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
        
        if let cell = outlineView.make(withIdentifier: id, owner: nil) as? GroupedTrackCellView {
            
            cell.textField?.stringValue = text
            cell.imageView?.image = image
            cell.isGroup = isGroup
            
            if (isPlayingTrack) {
                
                // Configure and show the image view
                let imgView = cell.imageView!
                
                imgView.canDrawSubviewsIntoLayer = true
                imgView.imageScaling = .scaleProportionallyDown
                imgView.animates = shouldAnimate()
                
                // Mark this cell for later
                animationCell = cell
            }
            
            return cell
        }
        
        return nil
    }
    
    // Creates a cell view containing only text
    private func createTextCell(_ outlineView: NSOutlineView, _ id: String, _ isGroup: Bool, _ text: String) -> GroupedTrackCellView? {
        
        if let cell = outlineView.make(withIdentifier: id, owner: nil) as? GroupedTrackCellView {
            
            cell.textField?.stringValue = text
            cell.isGroup = isGroup
            return cell
        }
        
        return nil
    }
    
    // Whenever the playing track is paused/resumed, the animation needs to be paused/resumed.
    private func playbackStateChanged(_ message: PlaybackStateChangedNotification) {
        
        animationCell?.imageView?.animates = shouldAnimate()
        
        switch (message.newPlaybackState) {
            
        case .noTrack:
            
            // The track is no longer playing
            animationCell = nil
            
        default: return
            
        }
    }
    
    func getID() -> String {
        return String(format: "%@-%@", self.className, String(describing: self.playlistType))
    }
    
    // MARK: Message handling
    
    // When the current playlist view changes, the animation state might need to change
    private func playlistTypeChanged(_ notification: PlaylistTypeChangedNotification) {
        animationCell?.imageView?.animates = shouldAnimate()
    }
    
    // When the app moves to the background, the animation should be disabled
    private func appInBackground() {
        animationCell?.imageView?.animates = false
    }
    
    // When the app moves to the foreground, the animation might need to be enabled
    private func appInForeground() {
        animationCell?.imageView?.animates = shouldAnimate()
    }
    
    // Helper function that determines whether or not the playing track animation should be shown animated
    private func shouldAnimate() -> Bool {
        
        // Animation enabled only if 1 - the appropriate playlist view is currently shown, 2 - a track is currently playing (not paused), and 3 - the app window is currently in the foreground
        
        let playing = playbackInfo.getPlaybackState() == .playing
        let showingThisPlaylistView = PlaylistViewState.current == self.playlistType
        
        return playing && WindowState.isInForeground() && showingThisPlaylistView
    }
    
    func consumeNotification(_ notification: NotificationMessage) {
        
        switch notification.messageType {
            
        case .playbackStateChangedNotification:
            
            playbackStateChanged(notification as! PlaybackStateChangedNotification)
            
        case .playlistTypeChangedNotification:
            
            playlistTypeChanged(notification as! PlaylistTypeChangedNotification)
            
        case .appInBackgroundNotification:
            
            appInBackground()
            
        case .appInForegroundNotification:
            
            appInForeground()
            
        default: return
            
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
    
    // Whether or not this cell is contained within a row that represents a group (as opposed to a track)
    var isGroup: Bool = false
    
    // This is used to determine which NSOutlineView contains this cell
    var playlistType: PlaylistType = .artists
    
    // The item represented by the row containing this cell
    var item: PlaylistItem?
    
    // When the background changes (as a result of selection/deselection) switch to the appropriate colors/fonts
    override var backgroundStyle: NSBackgroundStyle {
        
        didSet {
            
            // Check if this row is selected
            let outlineView = OutlineViewHolder.instances[self.playlistType]!
            let isSelRow = outlineView.selectedRowIndexes.contains(outlineView.row(forItem: item))
            
            if let textField = self.textField {
                
                textField.textColor = isSelRow ? (isGroup ? Colors.playlistGroupNameSelectedTextColor : Colors.playlistGroupItemSelectedTextColor) : (isGroup ? Colors.playlistGroupNameTextColor : Colors.playlistGroupItemTextColor)
                
                textField.font = isSelRow ? (isGroup ? Fonts.playlistGroupNameSelectedTextFont : Fonts.playlistGroupItemSelectedTextFont) : (isGroup ? Fonts.playlistGroupNameTextFont : Fonts.playlistGroupItemTextFont)
            }
        }
    }
}

/*
    Custom view for a NSTableView row that displays a single playlist track or group. Customizes the selection look and feel.
 */
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
}

// Utility class to hold NSOutlineView instances for convenient access
class OutlineViewHolder {
    
    // Mapping of playlist types to their corresponding outline views
    static var instances = [PlaylistType: NSOutlineView]()
}

class ArtistsPlaylistViewDelegate: GroupingPlaylistViewDelegate {
    
    init() {
        super.init(.artists)
    }
}

class AlbumsPlaylistViewDelegate: GroupingPlaylistViewDelegate {
    
    init() {
        super.init(.albums)
    }
}

class GenresPlaylistViewDelegate: GroupingPlaylistViewDelegate {
    
    init() {
        super.init(.genres)
    }
}
