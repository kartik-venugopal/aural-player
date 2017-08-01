/*
    Custom view controller for the NSTableView that displays the playlist. Creates table cells with the necessary track information.
*/

import Cocoa
import AVFoundation

class PlaylistViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {
    
    var playlist: Playlist = Playlist.instance()
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return playlist.size()
    }
    
    // Each playlist view row contains one track, with name and duration
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        
        let track = (playlist.getTrackAt(row)?.track)!
        let trackName = track.shortDisplayName
        let duration = Utils.formatDuration((track.duration)!)
        
        let view = PlaylistSongView()
        view.trackName = trackName
        view.duration = duration
        view.tableView = tableView
        
        return view
    }
    
    // Drag n drop
    func tableView(_ tableView: NSTableView, validateDrop info: NSDraggingInfo, proposedRow row: Int, proposedDropOperation dropOperation: NSTableViewDropOperation) -> NSDragOperation {
        
        // No validation required here
        return NSDragOperation.copy;
    }
    
    // Drag n drop
    func tableView(_ tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation: NSTableViewDropOperation) -> Bool {
        
        let objects = info.draggingPasteboard().readObjects(forClasses: [NSURL.self], options: nil)
        
        let appDelegate = NSApplication.shared().delegate as! AppDelegate
        appDelegate.addTracks(objects! as! [URL])
        
        return true
    }
}
