import Cocoa

class GroupingViewController: NSViewController, NSOutlineViewDataSource, NSOutlineViewDelegate {
    
    // TODO: This will be non-nil and provided by ObjectGraph
    // TODO: Use delegate, not accessor directly
    internal var playlist: PlaylistAccessorProtocol = ObjectGraph.getPlaylistAccessor()
    
    internal var grouping: GroupType {return .artist}
    
    func outlineView(_ outlineView: NSOutlineView, rowViewForItem item: Any) -> NSTableRowView? {
        return PlaylistRowView()
    }
    
    func outlineView(_ outlineView: NSOutlineView, heightOfRowByItem item: Any) -> CGFloat {
        return item is Group ? 26 : 22
    }
    
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        
        if (item == nil) {
            return playlist.getNumberOfGroups(grouping)
            
        } else if let group = item as? Group {
            return group.tracks.count
        }
        
        // Tracks don't have children
        return 0
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        
        if (item == nil) {
            return playlist.getGroupAt(grouping, index)
        } else if let group = item as? Group {
            return group.tracks[index]
        }
        
        return "Muthusami"
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        
        if item is Group {
            return true
        }
        
        return false
    }
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        
        if (tableColumn?.identifier == "cv_groupName") {
            
            if let group = item as? Group {
                
                let view: GroupedTrackCellView? = outlineView.make(withIdentifier: (tableColumn?.identifier)!, owner: self) as? GroupedTrackCellView
                
                view!.textField?.stringValue = String(format: "%@ (%d)", group.name, group.size())
                view!.isName = true
                view!.imageView?.image = UIConstants.imgGroup
                
                return view
                
            } else if let track = item as? Track {
                
                let view: GroupedTrackCellView? = outlineView.make(withIdentifier: (tableColumn?.identifier)!, owner: self) as? GroupedTrackCellView
                
                view!.textField?.stringValue = playlist.displayNameFor(grouping, track)
                view!.isName = false
                view!.imageView?.image = track.displayInfo.art
                
                return view
            }
            
        } else if (tableColumn?.identifier == "cv_duration") {
            
            let view: GroupedTrackCellView? = outlineView.make(withIdentifier: (tableColumn?.identifier)!, owner: self) as? GroupedTrackCellView
            
            if let group = item as? Group {
                
                view!.textField?.stringValue = StringUtils.formatSecondsToHMS(group.duration)
                view?.isName = true
                view!.textField?.setFrameOrigin(NSPoint(x: 0, y: -12))
                
            } else if let track = item as? Track {
                
                view!.textField?.stringValue = StringUtils.formatSecondsToHMS(track.duration)
                view?.isName = false
            }
            
            return view
        }
        
        return nil
    }
}

/*
 Custom view for a single NSTableView cell. Customizes the look and feel of cells (in selected rows) - font and text color.
 */
class GroupedTrackCellView: NSTableCellView {
    
    var isName: Bool = false
    
    // When the background changes (as a result of selection/deselection) switch appropriate colours
    override var backgroundStyle: NSBackgroundStyle {
        
        didSet {
            
            if let field = self.textField {
                
                if (backgroundStyle == NSBackgroundStyle.dark) {
                    
                    // Selected
                    
                    if (isName) {
                        
                        field.textColor = Colors.playlistGroupNameSelectedTextColor
                        field.font = UIConstants.playlistGroupNameSelectedTextFont
                        
                    } else {
                        
                        field.textColor = Colors.playlistGroupItemSelectedTextColor
                        field.font = UIConstants.playlistGroupItemSelectedTextFont
                    }
                    
                } else {
                    
                    // Not selected
                    
                    if (isName) {
                        
                        field.textColor = Colors.playlistGroupNameTextColor
                        field.font = UIConstants.playlistGroupNameTextFont
                        
                    } else {
                        
                        field.textColor = Colors.playlistGroupItemTextColor
                        field.font = UIConstants.playlistGroupItemTextFont
                    }
                }
            }
        }
    }
}

class PlaylistArtistsTableViewController: GroupingViewController {
    
    override var grouping: GroupType {return .artist}
}

class PlaylistAlbumsTableViewController: GroupingViewController {
    
    override var grouping: GroupType {return .album}
}

class PlaylistGenresTableViewController: GroupingViewController {
    
    override var grouping: GroupType {return .genre}
}
